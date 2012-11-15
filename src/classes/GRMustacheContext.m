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

@interface GRMustacheContext()
+ (BOOL)objectIsFoundationCollectionWhoseImplementationOfValueForKeyReturnsAnotherCollection:(id)object;

- (id)initWithContextStack:(NSArray *)contextStack protectedContextStack:(NSArray *)protectedContextStack hiddenContextStack:(NSArray *)hiddenContextStack delegateStack:(NSArray *)delegateStack templateOverrideStack:(NSArray *)templateOverrideStack;

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
@synthesize delegateStack=_delegateStack;

- (void)dealloc
{
    [_contextStack release];
    [_protectedContextStack release];
    [_hiddenContextStack release];
    [_delegateStack release];
    [_templateOverrideStack release];
    [super dealloc];
}

+ (void)preventNSUndefinedKeyExceptionAttack
{
    shouldPreventNSUndefinedKeyException = YES;
}

+ (id)context
{
    NSArray *contextStack = [NSArray arrayWithObject:[GRMustacheFilterLibrary filterLibrary]];
    return [[[self alloc] initWithContextStack:contextStack protectedContextStack:nil hiddenContextStack:nil delegateStack:nil templateOverrideStack:nil] autorelease];
}

- (GRMustacheContext *)contextByAddingTagDelegate:(id<GRMustacheTagDelegate>)tagDelegate
{
    if (tagDelegate == nil) {
        return self;
    }
    
    NSArray *delegateStack = _delegateStack ? [_delegateStack arrayByAddingObject:tagDelegate] : [NSArray arrayWithObject:tagDelegate];
    
    return [[[GRMustacheContext alloc] initWithContextStack:_contextStack protectedContextStack:_protectedContextStack hiddenContextStack:_hiddenContextStack delegateStack:delegateStack templateOverrideStack:_templateOverrideStack] autorelease];
}

- (GRMustacheContext *)contextByAddingObject:(id)object
{
    if (object == nil) {
        return self;
    }
    
    NSArray *contextStack = _contextStack ? [_contextStack arrayByAddingObject:object] : [NSArray arrayWithObject:object];
    
    NSArray *delegateStack = _delegateStack;
    if ([object conformsToProtocol:@protocol(GRMustacheTagDelegate)]) {
        delegateStack = _delegateStack ? [_delegateStack arrayByAddingObject:object] : [NSArray arrayWithObject:object];
    }
    
    return [[[GRMustacheContext alloc] initWithContextStack:contextStack protectedContextStack:_protectedContextStack hiddenContextStack:_hiddenContextStack delegateStack:delegateStack templateOverrideStack:_templateOverrideStack] autorelease];
}

- (GRMustacheContext *)contextByAddingProtectedObject:(id)object
{
    if (object == nil) {
        return self;
    }
    
    NSArray *protectedContextStack = _protectedContextStack ? [_protectedContextStack arrayByAddingObject:object] : [NSArray arrayWithObject:object];
    
    return [[[GRMustacheContext alloc] initWithContextStack:_contextStack protectedContextStack:protectedContextStack hiddenContextStack:_hiddenContextStack delegateStack:_delegateStack templateOverrideStack:_templateOverrideStack] autorelease];
}

- (GRMustacheContext *)contextByAddingHiddenObject:(id)object
{
    if (object == nil) {
        return self;
    }
    
    NSArray *hiddenContextStack = _hiddenContextStack ? [_hiddenContextStack arrayByAddingObject:object] : [NSArray arrayWithObject:object];
    
    return [[[GRMustacheContext alloc] initWithContextStack:_contextStack protectedContextStack:_protectedContextStack hiddenContextStack:hiddenContextStack delegateStack:_delegateStack templateOverrideStack:_templateOverrideStack] autorelease];
}

- (GRMustacheContext *)contextByAddingTemplateOverride:(GRMustacheTemplateOverride *)templateOverride
{
    if (templateOverride == nil) {
        return self;
    }
    
    NSArray *templateOverrideStack = _templateOverrideStack ? [_templateOverrideStack arrayByAddingObject:templateOverride] : [NSArray arrayWithObject:templateOverride];
    
    return [[[GRMustacheContext alloc] initWithContextStack:_contextStack protectedContextStack:_protectedContextStack hiddenContextStack:_hiddenContextStack delegateStack:_delegateStack templateOverrideStack:templateOverrideStack] autorelease];
}

- (id)currentContextValue
{
    // top of the stack is first object
    return [_contextStack lastObject];
}

- (id)contextValueForKey:(NSString *)key isProtected:(BOOL *)isProtected
{
    NSUInteger count = [_protectedContextStack count];
    for (NSUInteger index = 0; index < count; ++index) {
        id contextObject = [_protectedContextStack objectAtIndex:count-1-index];
        id value = [GRMustacheContext valueForKey:key inObject:contextObject];
        if (value != nil) {
            if (isProtected) {
                *isProtected = YES;
            }
            return value;
        }
    }
    
    count = [_contextStack count];
    for (NSUInteger index = 0; index < count; ++index) {
        id contextObject = [_contextStack objectAtIndex:count-1-index];
        if ([_hiddenContextStack containsObject:contextObject]) {
            continue;
        }
        id value = [GRMustacheContext valueForKey:key inObject:contextObject];
        if (value != nil) {
            if (isProtected) {
                *isProtected = NO;
            }
            return value;
        }
    }
    return nil;
}

- (id<GRMustacheTemplateComponent>)resolveTemplateComponent:(id<GRMustacheTemplateComponent>)component
{
    // top of the stack is first object
    for (GRMustacheTemplateOverride *templateOverride in [_templateOverrideStack reverseObjectEnumerator]) {
        component = [templateOverride resolveTemplateComponent:component];
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

- (id)initWithContextStack:(NSArray *)contextStack protectedContextStack:(NSArray *)protectedContextStack hiddenContextStack:(NSArray *)hiddenContextStack delegateStack:(NSArray *)delegateStack templateOverrideStack:(NSArray *)templateOverrideStack
{
    self = [super init];
    if (self) {
        _contextStack = [contextStack retain];
        _protectedContextStack = [protectedContextStack retain];
        _hiddenContextStack = [hiddenContextStack retain];
        _delegateStack = [delegateStack retain];
        _templateOverrideStack = [templateOverrideStack retain];
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
