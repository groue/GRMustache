// The MIT License
//
// Copyright (c) 2013 Gwendal Roué
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
#import "GRMustacheError.h"
#import "GRMustacheTemplateOverride_private.h"
#import "JRSwizzle.h"

#if !defined(NS_BLOCK_ASSERTIONS)
BOOL GRMustacheContextDidCatchNSUndefinedKeyException;
#endif

static BOOL shouldPreventNSUndefinedKeyException = NO;

@interface GRMustacheContext()

// Context stack:
// If _contextObject is nil, the stack is empty.
// If _contextObject is not nil, the top of the stack is _contextObject, and the rest of the stack is _contextParent.
@property (nonatomic, retain) GRMustacheContext *contextParent;
@property (nonatomic, retain) id contextObject;

// Protected context stack
@property (nonatomic, retain) GRMustacheContext *protectedContextParent;
@property (nonatomic, retain) id protectedContextObject;

// Hidden context stack
@property (nonatomic, retain) GRMustacheContext *hiddenContextParent;
@property (nonatomic, retain) id hiddenContextObject;

// Tag delegate stack
@property (nonatomic, retain) GRMustacheContext *tagDelegateParent;
@property (nonatomic, retain) id<GRMustacheTagDelegate> tagDelegate;

// Template override stack
@property (nonatomic, retain) GRMustacheContext *templateOverrideParent;
@property (nonatomic, retain) id templateOverride;

+ (BOOL)objectIsFoundationCollectionWhoseImplementationOfValueForKeyReturnsAnotherCollection:(id)object;
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
@synthesize contextParent=_contextParent;
@synthesize contextObject=_contextObject;
@synthesize protectedContextParent=_protectedContextParent;
@synthesize protectedContextObject=_protectedContextObject;
@synthesize hiddenContextParent=_hiddenContextParent;
@synthesize hiddenContextObject=_hiddenContextObject;
@synthesize tagDelegateParent=_tagDelegateParent;
@synthesize tagDelegate=_tagDelegate;
@synthesize templateOverrideParent=_templateOverrideParent;
@synthesize templateOverride=_templateOverride;

- (void)dealloc
{
    [_contextParent release];
    [_contextObject release];
    [_protectedContextParent release];
    [_protectedContextObject release];
    [_hiddenContextParent release];
    [_hiddenContextObject release];
    [_tagDelegateParent release];
    [_tagDelegate release];
    [_templateOverrideParent release];
    [_templateOverride release];
    [super dealloc];
}

+ (void)preventNSUndefinedKeyExceptionAttack
{
    shouldPreventNSUndefinedKeyException = YES;
}

// TODO: put away in private section
+ (NSMutableSet *)writableKeysForClass:(Class)klass
{
    // Returns a set of writable properties declared by klass
    NSMutableSet *keys = [NSMutableSet set];
    unsigned int count = 0;
    objc_property_t *properties = class_copyPropertyList(klass, &count);
    for (unsigned int i=0; i<count; ++i) {
        const char *attrs = property_getAttributes(properties[i]);
        if (!strstr(attrs, ",R,")) {    // not read-only
            [keys addObject:[NSString stringWithCString:property_getName(properties[i]) encoding:NSUTF8StringEncoding]];
        }
    }
    free(properties);
    return keys;
}

// TODO: expose in public API
- (NSSet *)customWritableKeys
{
    // Returns a set of writable properties declared by self, minus those declared by GRMustacheContext itself:
    // These are supposed to be the writable properties of GRMustacheContext subclasses.
    NSMutableSet *keys = [GRMustacheContext writableKeysForClass:[self class]];
    [keys minusSet:[GRMustacheContext writableKeysForClass:[GRMustacheContext class]]];
    return keys;
}

// TODO: put away in private section
- (void)copyCustomWritableKeysFromContext:(GRMustacheContext *)context
{
    for (NSString *key in [self customWritableKeys]) {
        id value = [GRMustacheContext valueForKey:key inSuper:&(struct objc_super){ context, [NSObject class] }];
        [self setValue:value forKey:key];
    }
}

+ (instancetype)context
{
    return [[[self alloc] init] autorelease];
}

+ (instancetype)contextWithObject:(id)object
{
    GRMustacheContext *context = [[[self alloc] init] autorelease];
    
    // initialize context stack
    context.contextObject = [object retain];
        
    // initialize tag delegate stack
    if ([object conformsToProtocol:@protocol(GRMustacheTagDelegate)]) {
        context.tagDelegate = [object retain];
    }
    
    return context;
}

+ (instancetype)contextWithProtectedObject:(id)object
{
    GRMustacheContext *context = [[[self alloc] init] autorelease];
    
    // initialize protected context stack
    context.protectedContextObject = [object retain];
    
    return context;
}

+ (instancetype)contextWithTagDelegate:(id<GRMustacheTagDelegate>)tagDelegate
{
    GRMustacheContext *context = [[[self alloc] init] autorelease];
    
    // initialize tag delegate stack
    context.tagDelegate = [tagDelegate retain];
    
    return context;
}

- (instancetype)contextByAddingTagDelegate:(id<GRMustacheTagDelegate>)tagDelegate
{
    if (tagDelegate == nil) {
        return self;
    }
    
    GRMustacheContext *context = [[[[self class] alloc] init] autorelease];
    
    // copy identical stacks
    context.contextParent = _contextParent;
    context.contextObject = _contextObject;
    context.protectedContextParent = _protectedContextParent;
    context.protectedContextObject = _protectedContextObject;
    context.hiddenContextParent = _hiddenContextParent;
    context.hiddenContextObject = _hiddenContextObject;
    context.templateOverrideParent = _templateOverrideParent;
    context.templateOverride = _templateOverride;
    
    // update tag delegate stack
    if (_tagDelegate) { context.tagDelegateParent = self; }
    context.tagDelegate = tagDelegate;
    
    [context copyCustomWritableKeysFromContext:self];
    return context;
}

- (instancetype)contextByAddingObject:(id)object
{
    if (object == nil) {
        return self;
    }
    
    GRMustacheContext *context = [[[[self class] alloc] init] autorelease];
    
    // copy identical stacks
    context.protectedContextParent = _protectedContextParent;
    context.protectedContextObject = _protectedContextObject;
    context.hiddenContextParent = _hiddenContextParent;
    context.hiddenContextObject = _hiddenContextObject;
    context.templateOverrideParent = _templateOverrideParent;
    context.templateOverride = _templateOverride;
    
    // Update context stack
    if (_contextObject) { context.contextParent = self; }
    context.contextObject = object;
    
    // update or copy tag delegate stack
    if ([object conformsToProtocol:@protocol(GRMustacheTagDelegate)]) {
        if (_tagDelegate) { context.tagDelegateParent = self; }
        context.tagDelegate = object;
    } else {
        context.tagDelegateParent = _tagDelegateParent;
        context.tagDelegate = _tagDelegate;
    }
    
    [context copyCustomWritableKeysFromContext:self];
    return context;
}

- (instancetype)contextByAddingProtectedObject:(id)object
{
    if (object == nil) {
        return self;
    }
    
    GRMustacheContext *context = [[[[self class] alloc] init] autorelease];
    
    // copy identical stacks
    context.contextParent = _contextParent;
    context.contextObject = _contextObject;
    context.hiddenContextParent = _hiddenContextParent;
    context.hiddenContextObject = _hiddenContextObject;
    context.tagDelegateParent = _tagDelegateParent;
    context.tagDelegate = _tagDelegate;
    context.templateOverrideParent = _templateOverrideParent;
    context.templateOverride = _templateOverride;
    
    // update protected context stack
    if (_protectedContextObject) { context.protectedContextParent = self; }
    context.protectedContextObject = object;
    
    [context copyCustomWritableKeysFromContext:self];
    return context;
}

- (instancetype)contextByAddingHiddenObject:(id)object
{
    if (object == nil) {
        return self;
    }
    
    GRMustacheContext *context = [[[[self class] alloc] init] autorelease];
    
    // copy identical stacks
    context.contextParent = _contextParent;
    context.contextObject = _contextObject;
    context.protectedContextParent = _protectedContextParent;
    context.protectedContextObject = _protectedContextObject;
    context.tagDelegateParent = _tagDelegateParent;
    context.tagDelegate = _tagDelegate;
    context.templateOverrideParent = _templateOverrideParent;
    context.templateOverride = _templateOverride;
    
    // update hidden context stack
    if (_hiddenContextObject) { context.hiddenContextParent = self; }
    context.hiddenContextObject = object;
    
    [context copyCustomWritableKeysFromContext:self];
    return context;
}

- (instancetype)contextByAddingTemplateOverride:(GRMustacheTemplateOverride *)templateOverride
{
    if (templateOverride == nil) {
        return self;
    }
    
    GRMustacheContext *context = [[[[self class] alloc] init] autorelease];
    
    // copy identical stacks
    context.contextParent = _contextParent;
    context.contextObject = _contextObject;
    context.protectedContextParent = _protectedContextParent;
    context.protectedContextObject = _protectedContextObject;
    context.hiddenContextParent = _hiddenContextParent;
    context.hiddenContextObject = _hiddenContextObject;
    context.tagDelegateParent = _tagDelegateParent;
    context.tagDelegate = _tagDelegate;
    
    // update template override stack
    if (_templateOverride) { context.templateOverrideParent = self; }
    context.templateOverride = templateOverride;
    
    [context copyCustomWritableKeysFromContext:self];
    return context;
}

- (void)enumerateTagDelegatesUsingBlock:(void(^)(id<GRMustacheTagDelegate> tagDelegate))block
{
    if (_tagDelegate) {
        for (GRMustacheContext *context = self; context; context = context.tagDelegateParent) {
            block(context.tagDelegate);
        }
    }
}

- (id)currentContextValue
{
    // top of the stack is first object
    return [[_contextObject retain] autorelease];
}

- (id)valueForKey:(NSString *)key
{
    return [self contextValueForKey:key protected:NULL];
}

- (id)contextValueForKey:(NSString *)key protected:(BOOL *)protected
{
    if (_protectedContextObject) {
        for (GRMustacheContext *context = self; context; context = context.protectedContextParent) {
            id value = [GRMustacheContext valueForKey:key inObject:context.protectedContextObject];
            if (value != nil) {
                if (protected != NULL) {
                    *protected = YES;
                }
                return value;
            }
        }
    }
    
    if (_contextObject) {
        for (GRMustacheContext *context = self; context; context = context.contextParent) {
            id contextObject = context.contextObject;
            BOOL hidden = NO;
            if (_hiddenContextObject) {
                for (GRMustacheContext *hiddenContext = self; hiddenContext; hiddenContext = hiddenContext.hiddenContextParent) {
                    if (contextObject == hiddenContext.hiddenContextObject) {
                        hidden = YES;
                        break;
                    }
                }
            }
            if (hidden) { continue; }
            id value = [GRMustacheContext valueForKey:key inObject:contextObject];
            if (value != nil) {
                if (protected != NULL) {
                    *protected = NO;
                }
                return value;
            }
        }
    }

    // Check for custom subclass key
    
    if (![self isMemberOfClass:[GRMustacheContext class]]) {
        id value = [GRMustacheContext valueForKey:key inSuper:&(struct objc_super){ self, [NSObject class] }];
        if (protected != NULL) {
            *protected = NO;
        }
        return value;
    }
    
    return nil;
}

- (id<GRMustacheTemplateComponent>)resolveTemplateComponent:(id<GRMustacheTemplateComponent>)component
{
    if (_templateOverride) {
        for (GRMustacheContext *context = self; context; context = context.templateOverrideParent) {
            component = [context.templateOverride resolveTemplateComponent:component];
        }
    }
    return component;
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
