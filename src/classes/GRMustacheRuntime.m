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
#import "GRMustacheRuntime_private.h"
#import "GRMustacheTemplate_private.h"
#import "GRMustacheInvocation_private.h"
#import "GRMustacheFilterLibrary_private.h"
#import "GRMustacheError.h"
#import "GRMustacheTemplateOverride_private.h"
#import "JRSwizzle.h"

#if !defined(NS_BLOCK_ASSERTIONS)
BOOL GRMustacheRuntimeDidCatchNSUndefinedKeyException;
#endif

static BOOL shouldPreventNSUndefinedKeyException = NO;

@interface GRMustacheRuntime()
+ (BOOL)objectIsFoundationCollectionWhoseImplementationOfValueForKeyReturnsAnotherCollection:(id)object;
- (id)initWithTemplate:(GRMustacheTemplate *)template contextStack:(NSArray *)contextStack filterStack:(NSArray *)filterStack delegateStack:(NSArray *)delegateStack templateOverrideStack:(NSArray *)templateOverrideStack;
- (void)assertAcyclicTemplateOverride:(GRMustacheTemplateOverride *)templateOverride;

+ (void)setupPreventionOfNSUndefinedKeyException;
+ (void)beginPreventionOfNSUndefinedKeyExceptionFromObject:(id)object;
+ (void)endPreventionOfNSUndefinedKeyExceptionFromObject:(id)object;
+ (NSMutableSet *)preventionOfNSUndefinedKeyExceptionObjects;
@end

@implementation GRMustacheRuntime

+ (void)preventNSUndefinedKeyExceptionAttack
{
    shouldPreventNSUndefinedKeyException = YES;
}

+ (id)runtime
{
    return [self runtimeWithTemplate:nil contextStack:nil];
}

+ (id)runtimeWithTemplate:(GRMustacheTemplate *)template contextStack:(NSArray *)contextStack
{
    NSArray *filterStack = [NSArray arrayWithObject:[GRMustacheFilterLibrary filterLibrary]];
    return [[[self alloc] initWithTemplate:template contextStack:contextStack filterStack:filterStack delegateStack:nil templateOverrideStack:nil] autorelease];
}

- (GRMustacheRuntime *)runtimeByAddingTemplateDelegate:(id<GRMustacheTemplateDelegate>)templateDelegate
{
    if (templateDelegate == nil) {
        return self;
    }
    
    // top of the stack is first object
    NSArray *delegateStack = [NSArray arrayWithObject:templateDelegate];
    if (_delegateStack) { delegateStack = [delegateStack arrayByAddingObjectsFromArray:_delegateStack]; }
    
    return [[[GRMustacheRuntime alloc] initWithTemplate:_template contextStack:_contextStack filterStack:_filterStack delegateStack:delegateStack templateOverrideStack:_templateOverrideStack] autorelease];
}

- (GRMustacheRuntime *)runtimeByAddingContextObject:(id)contextObject
{
    if (contextObject == nil) {
        return self;
    }
    
    // top of the stack is first object
    NSArray *contextStack = [NSArray arrayWithObject:contextObject];
    if (_contextStack) { contextStack = [contextStack arrayByAddingObjectsFromArray:_contextStack]; }
    
    NSArray *delegateStack = _delegateStack;
    if ([contextObject conformsToProtocol:@protocol(GRMustacheTemplateDelegate)]) {
        // top of the stack is first object
        delegateStack = [NSArray arrayWithObject:contextObject];
        if (_delegateStack) { delegateStack = [delegateStack arrayByAddingObjectsFromArray:_delegateStack]; }
    }
    
    return [[[GRMustacheRuntime alloc] initWithTemplate:_template contextStack:contextStack filterStack:_filterStack delegateStack:delegateStack templateOverrideStack:_templateOverrideStack] autorelease];
}

- (GRMustacheRuntime *)runtimeByAddingFilterObject:(id)filterObject;
{
    if (filterObject == nil) {
        return self;
    }
    
    // top of the stack is first object
    NSArray *filterStack = [NSArray arrayWithObject:filterObject];
    if (_filterStack) { filterStack = [filterStack arrayByAddingObjectsFromArray:_filterStack]; }
    
    return [[[GRMustacheRuntime alloc] initWithTemplate:_template contextStack:_contextStack filterStack:filterStack delegateStack:_delegateStack templateOverrideStack:_templateOverrideStack] autorelease];
}

- (GRMustacheRuntime *)runtimeByAddingTemplateOverride:(GRMustacheTemplateOverride *)templateOverride
{
    if (templateOverride == nil) {
        return self;
    }
    
    [self assertAcyclicTemplateOverride:templateOverride];
    
    // top of the stack is first object
    NSArray *templateOverrideStack = [NSArray arrayWithObject:templateOverride];
    if (_templateOverrideStack) { templateOverrideStack = [templateOverrideStack arrayByAddingObjectsFromArray:_templateOverrideStack]; }
    
    return [[[GRMustacheRuntime alloc] initWithTemplate:_template contextStack:_contextStack filterStack:_filterStack delegateStack:_delegateStack templateOverrideStack:templateOverrideStack] autorelease];
}

- (void)dealloc
{
    [_template release];
    [_contextStack release];
    [_filterStack release];
    [_delegateStack release];
    [_templateOverrideStack release];
    [super dealloc];
}

- (id)currentContextValue
{
    // top of the stack is first object
    return [_contextStack objectAtIndex:0];
}

- (id)contextValueForKey:(NSString *)key
{
    // top of the stack is first object
    for (id contextObject in _contextStack) {
        id value = [GRMustacheRuntime valueForKey:key inObject:contextObject];
        if (value != nil) { return value; }
    }
    return nil;
}

- (id)filterValueForKey:(NSString *)key
{
    // top of the stack is first object
    for (id filterObject in _filterStack) {
        id value = [GRMustacheRuntime valueForKey:key inObject:filterObject];
        if (value != nil) { return value; }
    }
    return nil;
}

- (void)delegateValue:(id)value interpretation:(GRMustacheInterpretation)interpretation forRenderingToken:(GRMustacheToken *)token usingBlock:(void(^)(id value))block
{
    NSAssert(_template, @"WTF");
    
    // fast path
    if (_delegateStack == nil) {
        block(value);
        return;
    }
    
    GRMustacheInvocation *invocation = [[[GRMustacheInvocation alloc] init] autorelease];
    invocation.token = token;
    invocation.returnValue = value;
    
    // top of the stack is first object
    for (id<GRMustacheTemplateDelegate> delegate in _delegateStack) {
        if ([delegate respondsToSelector:@selector(template:willInterpretReturnValueOfInvocation:as:)]) {
            [delegate template:_template willInterpretReturnValueOfInvocation:invocation as:interpretation];
        }
    }

    block(invocation.returnValue);

    for (id<GRMustacheTemplateDelegate> delegate in [_delegateStack reverseObjectEnumerator]) {
        if ([delegate respondsToSelector:@selector(template:didInterpretReturnValueOfInvocation:as:)]) {
            [delegate template:_template didInterpretReturnValueOfInvocation:invocation as:interpretation];
        }
    }
}

- (id<GRMustacheRenderingElement>)resolveRenderingElement:(id<GRMustacheRenderingElement>)element
{
    // top of the stack is first object
    for (GRMustacheTemplateOverride *templateOverride in _templateOverrideStack) {
        element = [templateOverride resolveRenderingElement:element];
    }
    return element;
}

#pragma mark - Private

- (void)assertAcyclicTemplateOverride:(GRMustacheTemplateOverride *)otherTemplateOverride
{
    for (GRMustacheTemplateOverride *templateOverride in _templateOverrideStack) {
        if (templateOverride.template == otherTemplateOverride.template) {
            [NSException raise:GRMustacheRenderingException format:@"Override cycle"];
        }
    }
}

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
            GRMustacheRuntimeDidCatchNSUndefinedKeyException = YES;
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

- (id)initWithTemplate:(GRMustacheTemplate *)template contextStack:(NSArray *)contextStack filterStack:(NSArray *)filterStack delegateStack:(NSArray *)delegateStack templateOverrideStack:(NSArray *)templateOverrideStack
{
    self = [super init];
    if (self) {
        _template = [template retain];
        _contextStack = [contextStack retain];
        _filterStack = [filterStack retain];
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
                        withMethod:@selector(GRMustacheRuntimeValueForUndefinedKey_NSObject:)
                             error:nil];
        
        
        // Swizzle [NSManagedObject valueForUndefinedKey:]
        
        Class NSManagedObjectClass = NSClassFromString(@"NSManagedObject");
        if (NSManagedObjectClass) {
            [NSManagedObjectClass jr_swizzleMethod:@selector(valueForUndefinedKey:)
                                        withMethod:@selector(GRMustacheRuntimeValueForUndefinedKey_NSManagedObject:)
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
    static NSString const * GRMustacheRuntimePreventionOfNSUndefinedKeyExceptionObjects = @"GRMustacheRuntimePreventionOfNSUndefinedKeyExceptionObjects";
    NSMutableSet *silentObjects = [[[NSThread currentThread] threadDictionary] objectForKey:GRMustacheRuntimePreventionOfNSUndefinedKeyExceptionObjects];
    if (silentObjects == nil) {
        silentObjects = [NSMutableSet set];
        [[[NSThread currentThread] threadDictionary] setObject:silentObjects forKey:GRMustacheRuntimePreventionOfNSUndefinedKeyExceptionObjects];
    }
    return silentObjects;
}

@end

@implementation NSObject(GRMustacheRuntimePreventionOfNSUndefinedKeyException)

// NSObject
- (id)GRMustacheRuntimeValueForUndefinedKey_NSObject:(NSString *)key
{
    if ([[GRMustacheRuntime preventionOfNSUndefinedKeyExceptionObjects] containsObject:self]) {
        return nil;
    }
    return [self GRMustacheRuntimeValueForUndefinedKey_NSObject:key];
}

// NSManagedObject
- (id)GRMustacheRuntimeValueForUndefinedKey_NSManagedObject:(NSString *)key
{
    if ([[GRMustacheRuntime preventionOfNSUndefinedKeyExceptionObjects] containsObject:self]) {
        return nil;
    }
    return [self GRMustacheRuntimeValueForUndefinedKey_NSManagedObject:key];
}

@end
