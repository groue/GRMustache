// The MIT License
//
// Copyright (c) 2012 Gwendal Roué
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <objc/message.h>
#import "GRMustacheContext_private.h"
#import "GRMustacheTag_private.h"
#import "GRMustacheExpression_private.h"
#import "GRMustacheTemplate_private.h"
#import "GRMustacheFilterLibrary_private.h"
#import "GRMustacheError.h"
#import "GRMustacheTemplateOverride_private.h"
#import "JRSwizzle.h"

#if !defined(NS_BLOCK_ASSERTIONS)
BOOL GRMustacheContextDidCatchNSUndefinedKeyException;
#endif

static BOOL shouldPreventNSUndefinedKeyException = NO;

GRMustacheTree GRMustacheTreeCreate(id object)
{
    if (object == nil) {
        return (GRMustacheTree){ .own = NO, .treeRef = NULL };
    } else {
        CFTreeContext ctx;
        ctx.version = 0;
        ctx.info = object;
        ctx.retain = CFRetain;
        ctx.release = CFRelease;
        ctx.copyDescription = NULL;
        CFTreeRef treeRef = CFTreeCreate(NULL, &ctx);
        return (GRMustacheTree){ .own = YES, .treeRef = treeRef };
    }
}

GRMustacheTree GRMustacheTreeDerive(GRMustacheTree *tree, id object)
{
    if (tree->treeRef) {
        if (object) {
            CFTreeContext ctx;
            ctx.version = 0;
            ctx.info = object;
            ctx.retain = CFRetain;
            ctx.release = CFRelease;
            ctx.copyDescription = NULL;
            CFTreeRef treeRef = CFTreeCreate(NULL, &ctx);
            CFTreeAppendChild(tree->treeRef, treeRef);
            return (GRMustacheTree){ .own = YES, .treeRef = treeRef };
        } else {
            return (GRMustacheTree){ .own = NO, .treeRef = tree->treeRef };
        }
    } else {
        return GRMustacheTreeCreate(object);
    }
}

void GRMustacheTreeRelease(GRMustacheTree *tree)
{
    if (tree->own) {
        CFTreeRemove(tree->treeRef);
        CFRelease(tree->treeRef);
    }
}

id GRMustacheTreeGetValue(GRMustacheTree *tree)
{
    if (tree->treeRef) {
        CFTreeContext ctx;
        ctx.version = 0;
        ctx.info = nil;
        ctx.retain = CFRetain;
        ctx.release = CFRelease;
        ctx.copyDescription = NULL;
        CFTreeGetContext(tree->treeRef, &ctx);
        return ctx.info;
    } else {
        return nil;
    }
}

void GRMustacheTreeEnumerateValuesUpToRoot(GRMustacheTree *tree, void(^block)(id value, BOOL *stop))
{
    CFTreeContext ctx;
    ctx.version = 0;
    ctx.info = nil;
    ctx.retain = CFRetain;
    ctx.release = CFRelease;
    ctx.copyDescription = NULL;
    
    BOOL stop = NO;
    for (CFTreeRef treeRef = tree->treeRef; treeRef; treeRef = CFTreeGetParent(treeRef)) {
        CFTreeGetContext(treeRef, &ctx);
        block(ctx.info, &stop);
        if (stop) { break; }
    }
}

void GRMustacheTreeEnumerateValuesFromCFTreeRef(CFTreeRef treeRef, void *context, void(^block)(void *context, id value, void(^next)(void *context)))
{
    if (!treeRef) {
        block(context, nil, NULL);
        return;
    }
    
    CFTreeContext ctx;
    ctx.version = 0;
    ctx.info = nil;
    ctx.retain = CFRetain;
    ctx.release = CFRelease;
    ctx.copyDescription = NULL;

    CFTreeGetContext(treeRef, &ctx);
    CFTreeRef parent = CFTreeGetParent(treeRef);
    void(^next)(void *context) = nil;
    if (parent) {
        next = ^(void *context){ GRMustacheTreeEnumerateValuesFromCFTreeRef(parent, context, block); };
    }
    block(context, ctx.info, next);
}


@interface GRMustacheContext()
+ (BOOL)objectIsFoundationCollectionWhoseImplementationOfValueForKeyReturnsAnotherCollection:(id)object;
+ (BOOL)objectIsTagDelegate:(id)object;

- (id)initWithContextTree:(GRMustacheTree)contextTree delegateTree:(GRMustacheTree)delegateTree templateOverrideTree:(GRMustacheTree)templateOverrideTree;

+ (void)setupPreventionOfNSUndefinedKeyException;
+ (void)beginPreventionOfNSUndefinedKeyExceptionFromObject:(id)object;
+ (void)endPreventionOfNSUndefinedKeyExceptionFromObject:(id)object;
+ (NSMutableSet *)preventionOfNSUndefinedKeyExceptionObjects;

/**
 * Sends the `valueForKey:` message to super_data->receiver with the provided
 * key, using the implementation of super_data->super_class, and returns the
 * result.
 *
 * Should [GRMustacheContext preventNSUndefinedKeyExceptionAttack] method have
 * been called earlier, temporarily swizzle _object_ so that it does not raise
 * any NSUndefinedKeyException.
 *
 * Should `valueForKey:` raise an NSUndefinedKeyException, returns nil.
 *
 * @param key         The searched key
 * @param super_data  A pointer to a struct objc_super
 *
 * @return The result of the implementation of `valueForKey:` in
 *         super_data->super_class, or nil should an NSUndefinedKeyException be
 *         raised.
 *
 * @see GRMustacheProxy
 */
+ (id)valueForKey:(NSString *)key inSuper:(struct objc_super *)super_data GRMUSTACHE_API_INTERNAL;

@end

@implementation GRMustacheContext

- (void)dealloc
{
    GRMustacheTreeRelease(&_contextTree);
    GRMustacheTreeRelease(&_delegateTree);
    GRMustacheTreeRelease(&_templateOverrideTree);
    [super dealloc];
}

+ (void)preventNSUndefinedKeyExceptionAttack
{
    shouldPreventNSUndefinedKeyException = YES;
}

+ (id)context
{
    static GRMustacheContext *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        GRMustacheTree contextTree = GRMustacheTreeCreate([GRMustacheFilterLibrary filterLibrary]);
        GRMustacheTree delegateTree = GRMustacheTreeCreate(nil);
        GRMustacheTree templateOverrideTree = GRMustacheTreeCreate(nil);
        instance = [[GRMustacheContext alloc] initWithContextTree:contextTree delegateTree:delegateTree templateOverrideTree:templateOverrideTree];
    });
    return instance;
}

- (GRMustacheContext *)contextByAddingTagDelegate:(id<GRMustacheTagDelegate>)tagDelegate
{
    if (tagDelegate == nil) {
        return self;
    }
    
    GRMustacheTree contextTree = GRMustacheTreeDerive(&_contextTree, nil);
    GRMustacheTree delegateTree = GRMustacheTreeDerive(&_delegateTree, tagDelegate);
    GRMustacheTree templateOverrideTree = GRMustacheTreeDerive(&_templateOverrideTree, nil);
    
    return [[[GRMustacheContext alloc] initWithContextTree:contextTree delegateTree:delegateTree templateOverrideTree:templateOverrideTree] autorelease];
}

- (GRMustacheContext *)contextByAddingObject:(id)contextObject
{
    if (contextObject == nil) {
        return self;
    }
    
    GRMustacheTree contextTree = GRMustacheTreeDerive(&_contextTree, contextObject);
    GRMustacheTree templateOverrideTree = GRMustacheTreeDerive(&_templateOverrideTree, nil);
    
    GRMustacheTree delegateTree;
    if ([GRMustacheContext objectIsTagDelegate:contextObject]) {
        delegateTree = GRMustacheTreeDerive(&_delegateTree, contextObject);
    } else {
        delegateTree = GRMustacheTreeDerive(&_delegateTree, nil);
    }
    
    return [[[GRMustacheContext alloc] initWithContextTree:contextTree delegateTree:delegateTree templateOverrideTree:templateOverrideTree] autorelease];
}

- (GRMustacheContext *)contextByAddingTemplateOverride:(GRMustacheTemplateOverride *)templateOverride
{
    if (templateOverride == nil) {
        return self;
    }
    
    GRMustacheTree contextTree = GRMustacheTreeDerive(&_contextTree, nil);
    GRMustacheTree delegateTree = GRMustacheTreeDerive(&_delegateTree, nil);
    GRMustacheTree templateOverrideTree = GRMustacheTreeDerive(&_templateOverrideTree, templateOverride);
    
    return [[[GRMustacheContext alloc] initWithContextTree:contextTree delegateTree:delegateTree templateOverrideTree:templateOverrideTree] autorelease];
}

- (id)currentContextValue
{
    return GRMustacheTreeGetValue(&_contextTree);
}

- (id)contextValueForKey:(NSString *)key
{
    __block id contextValue = nil;
    GRMustacheTreeEnumerateValuesUpToRoot(&_contextTree, ^(id contextObject, BOOL *stop){
        contextValue = [GRMustacheContext valueForKey:key inObject:contextObject];
        if (contextValue != nil) { *stop = YES; }
    });
    return contextValue;
}

- (void)renderObject:(id)object withTag:(GRMustacheTag *)tag usingBlock:(void(^)(id value))block
{
    GRMustacheTreeEnumerateValuesFromCFTreeRef(_delegateTree.treeRef, object, ^(void *object, id<GRMustacheTagDelegate> delegate, void (^next)(void *object)) {
        if ([delegate respondsToSelector:@selector(mustacheTag:willRenderObject:)]) {
            object = [delegate mustacheTag:tag willRenderObject:object];
        }
        
        if (next) {
            next(object);
        } else {
            block(object);
        }

        if ([delegate respondsToSelector:@selector(mustacheTag:didRenderObject:)]) {
            [delegate mustacheTag:tag didRenderObject:object];
        }
    });
}

- (id<GRMustacheTemplateComponent>)resolveTemplateComponent:(id<GRMustacheTemplateComponent>)component
{
    __block id<GRMustacheTemplateComponent> resolvedComponent = component;
    GRMustacheTreeEnumerateValuesUpToRoot(&_templateOverrideTree, ^(GRMustacheTemplateOverride *templateOverride, BOOL *stop){
        resolvedComponent = [templateOverride resolveTemplateComponent:resolvedComponent];
    });
    return resolvedComponent;
}


#pragma mark - Private

+ (id)valueForKey:(NSString *)key inObject:(id)object
{
    // We don't want to use NSArray, NSSet and NSOrderedSet implementation
    // of valueForKey:, because they return another collection: see issue #21
    // and "anchored key should not extract properties inside an array" test in
    // src/tests/Public/v4.0/GRMustacheSuites/compound_keys.json
    //
    // Still, we do not want to prevent access to [NSArray count]. We thus
    // invoke NSObject's implementation of valueForKey: for those objects, with
    // our valueForKey:inSuper: method.
    
    if ([self objectIsFoundationCollectionWhoseImplementationOfValueForKeyReturnsAnotherCollection:object]) {
        return [self valueForKey:key inSuper:&(struct objc_super){ object, [NSObject class] }];
    }
    
    
    // For other objects, return the result of their own implementation of
    // valueForKey: (but use our valueForKey:inSuper: with nil super_class, so
    // that we can prevent or catch NSUndefinedKeyException).
    
    return [self valueForKey:key inSuper:&(struct objc_super){ object, nil }];
}

+ (id)valueForKey:(NSString *)key inSuper:(struct objc_super *)super_data
{
    if (super_data->receiver == nil) {
        return nil;
    }
    
    @try {
        if (shouldPreventNSUndefinedKeyException) {
            [self beginPreventionOfNSUndefinedKeyExceptionFromObject:super_data->receiver];
        }
        
        // We accept nil super_data->super_class, as a convenience for our
        // implementation of valueForKey:inObject:.
#if !defined(__cplusplus)  &&  !__OBJC2__
        if (super_data->class)  // support for 32bits MacOS (see declaration of struct objc_super in <objc/message.h>)
#else
        if (super_data->super_class)
#endif
        {
            return objc_msgSendSuper(super_data, @selector(valueForKey:), key);
        } else {
            return [super_data->receiver valueForKey:key];
        }
    }
    
    @catch (NSException *exception) {
        
        // Swallow NSUndefinedKeyException only
        
        if (![[exception name] isEqualToString:NSUndefinedKeyException]) {
            [exception raise];
        }
#if !defined(NS_BLOCK_ASSERTIONS)
        else {
            // For testing purpose
            GRMustacheContextDidCatchNSUndefinedKeyException = YES;
        }
#endif
    }
    
    @finally {
        if (shouldPreventNSUndefinedKeyException) {
            [self endPreventionOfNSUndefinedKeyExceptionFromObject:super_data->receiver];
        }
    }
    
    return nil;
}

- (id)initWithContextTree:(GRMustacheTree)contextTree delegateTree:(GRMustacheTree)delegateTree templateOverrideTree:(GRMustacheTree)templateOverrideTree
{
    self = [super init];
    if (self) {
        _contextTree = contextTree;
        _delegateTree = delegateTree;
        _templateOverrideTree = templateOverrideTree;
    }
    return self;
}

+ (BOOL)objectIsFoundationCollectionWhoseImplementationOfValueForKeyReturnsAnotherCollection:(id)object
{
    // Returns YES if object is NSArray, NSSet, or NSOrderedSet.
    //
    // [NSObject isKindOfClass:] is slow.
    //
    // Our strategy: provide a fast path for objects whose implementation of
    // valueForKey: is the same as NSObject, NSDictionary and NSManagedObject,
    // by comparing implementations of valueForKey:. The slow path is for other
    // objects, for which we check whether they are NSArray, NSSet, or
    // NSOrderedSet with isKindOfClass:. We can not compare implementations for
    // those classes, because they are class clusters and that we can't be sure
    // they provide a single implementation of valueForKey:
    
    if (object == nil) {
        return NO;
    }
    
    static SEL valueForKeySelector = nil;
    if (valueForKeySelector == nil) {
        valueForKeySelector = @selector(valueForKey:);
    }
    IMP objectIMP = class_getMethodImplementation([object class], valueForKeySelector);
    
    // Fast path: objects using NSObject's implementation of valueForKey: are not collections
    {
        static IMP NSObjectIMP = nil;
        if (NSObjectIMP == nil) {
            NSObjectIMP = class_getMethodImplementation([NSObject class], valueForKeySelector);
        }
        if (objectIMP == NSObjectIMP) {
            return NO;
        }
    }
    
    // Fast path: objects using NSDictionary's implementation of valueForKey: are not collections
    {
        static IMP NSDictionaryIMP = nil;
        if (NSDictionaryIMP == nil) {
            NSDictionaryIMP = class_getMethodImplementation([NSDictionary class], valueForKeySelector);
        }
        if (objectIMP == NSDictionaryIMP) {
            return NO;
        }
    }
    
    // Fast path: objects using NSManagedObject's implementation of valueForKey: are not collections
    {
        // NSManagedObject may not be linked. Don't name it directly.
        static BOOL NSManagedObjectIMPComputed = NO;
        static IMP NSManagedObjectIMP = nil;
        if (NSManagedObjectIMPComputed == NO) {
            Class NSManagedObjectClass = NSClassFromString(@"NSManagedObject");
            if (NSManagedObjectClass) {
                NSManagedObjectIMP = class_getMethodImplementation(NSManagedObjectClass, valueForKeySelector);
            }
            NSManagedObjectIMPComputed = YES;
        }
        if (objectIMP == NSManagedObjectIMP) {
            return NO;
        }
    }
    
    // Slow path: NSArray, NSSet and NSOrderedSet are collections
    {
        // NSOrderedSet is iOS >= 5 or OSX >= 10.7. Don't name it directly.
        static BOOL NSOrderedSetClassComputed = NO;
        static Class NSOrderedSetClass = nil;
        if (NSOrderedSetClassComputed == NO) {
            NSOrderedSetClass = NSClassFromString(@"NSOrderedSet");
            NSOrderedSetClassComputed = YES;
        }
        
        return ([object isKindOfClass:[NSArray class]] ||
                [object isKindOfClass:[NSSet class]] ||
                (NSOrderedSetClass && [object isKindOfClass:NSOrderedSetClass]));
    }
}

+ (BOOL)objectIsTagDelegate:(id)object
{
    static CFMutableDictionaryRef cache = nil;
    if (cache == nil) {
        cache = CFDictionaryCreateMutable(NULL, 0, NULL, NULL);
    }
    
    Class aClass = [object class];
    NSNumber *isDelegate = CFDictionaryGetValue(cache, aClass);
    
    if (!isDelegate) {
        isDelegate = [NSNumber numberWithBool:[object conformsToProtocol:@protocol(GRMustacheTagDelegate)]];
        CFDictionaryAddValue(cache, aClass, isDelegate);
    }
    
    return [isDelegate boolValue];
}

#pragma mark - NSUndefinedKeyException prevention

+ (void)setupPreventionOfNSUndefinedKeyException
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        // Swizzle [NSObject valueForUndefinedKey:]
        
        [NSObject jr_swizzleMethod:@selector(valueForUndefinedKey:)
                        withMethod:@selector(GRMustacheContextValueForUndefinedKey_NSObject:)
                             error:nil];
        
        
        // Swizzle [NSManagedObject valueForUndefinedKey:]
        
        Class NSManagedObjectClass = NSClassFromString(@"NSManagedObject");
        if (NSManagedObjectClass) {
            [NSManagedObjectClass jr_swizzleMethod:@selector(valueForUndefinedKey:)
                                        withMethod:@selector(GRMustacheContextValueForUndefinedKey_NSManagedObject:)
                                             error:nil];
        }
    });
}

+ (void)beginPreventionOfNSUndefinedKeyExceptionFromObject:(id)object
{
    [self setupPreventionOfNSUndefinedKeyException];
    [[self preventionOfNSUndefinedKeyExceptionObjects] addObject:object];
}

+ (void)endPreventionOfNSUndefinedKeyExceptionFromObject:(id)object
{
    [[self preventionOfNSUndefinedKeyExceptionObjects] removeObject:object];
}

+ (NSMutableSet *)preventionOfNSUndefinedKeyExceptionObjects
{
    static NSString const * GRMustacheContextPreventionOfNSUndefinedKeyExceptionObjects = @"GRMustacheContextPreventionOfNSUndefinedKeyExceptionObjects";
    NSMutableSet *silentObjects = [[[NSThread currentThread] threadDictionary] objectForKey:GRMustacheContextPreventionOfNSUndefinedKeyExceptionObjects];
    if (silentObjects == nil) {
        silentObjects = [NSMutableSet set];
        [[[NSThread currentThread] threadDictionary] setObject:silentObjects forKey:GRMustacheContextPreventionOfNSUndefinedKeyExceptionObjects];
    }
    return silentObjects;
}

@end

@implementation NSObject(GRMustacheContextPreventionOfNSUndefinedKeyException)

// NSObject
- (id)GRMustacheContextValueForUndefinedKey_NSObject:(NSString *)key
{
    if ([[GRMustacheContext preventionOfNSUndefinedKeyExceptionObjects] containsObject:self]) {
        return nil;
    }
    return [self GRMustacheContextValueForUndefinedKey_NSObject:key];
}

// NSManagedObject
- (id)GRMustacheContextValueForUndefinedKey_NSManagedObject:(NSString *)key
{
    if ([[GRMustacheContext preventionOfNSUndefinedKeyExceptionObjects] containsObject:self]) {
        return nil;
    }
    return [self GRMustacheContextValueForUndefinedKey_NSManagedObject:key];
}

@end
