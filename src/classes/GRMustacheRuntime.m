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

#if (TARGET_OS_IPHONE)
#import <objc/runtime.h>
#import <objc/message.h>
#else
#import <objc/objc-class.h>
#endif

#import "GRMustacheRuntime_private.h"
#import "GRMustacheTemplate_private.h"
#import "GRMustacheInvocation_private.h"
#import "GRMustacheNSUndefinedKeyExceptionGuard_private.h"
#import "GRMustacheFilterLibrary_private.h"
#import "GRMustacheError.h"

#if !defined(NS_BLOCK_ASSERTIONS)
BOOL GRMustacheRuntimeDidCatchNSUndefinedKeyException;
#endif

static BOOL preventingNSUndefinedKeyExceptionAttack = NO;

@interface GRMustacheRuntime()
+ (BOOL)objectIsFoundationCollectionWhoseImplementationOfValueForKeyReturnsAnotherCollection:(id)object;
- (id)initWithTemplate:(GRMustacheTemplate *)template contextObject:(id)contextObject;
- (id)initWithTemplate:(GRMustacheTemplate *)template parent:(GRMustacheRuntime *)parent parentHasContext:(BOOL)parentHasContext parentHasFilter:(BOOL)parentHasFilter parentHasTemplateDelegate:(BOOL)parentHasTemplateDelegate parentHasRenderingOverride:(BOOL)parentHasRenderingOverride templateDelegate:(id<GRMustacheTemplateDelegate>)templateDelegate;
- (id)initWithTemplate:(GRMustacheTemplate *)template parent:(GRMustacheRuntime *)parent parentHasContext:(BOOL)parentHasContext parentHasFilter:(BOOL)parentHasFilter parentHasTemplateDelegate:(BOOL)parentHasTemplateDelegate parentHasRenderingOverride:(BOOL)parentHasRenderingOverride contextObject:(id)contextObject;
- (id)initWithTemplate:(GRMustacheTemplate *)template parent:(GRMustacheRuntime *)parent parentHasContext:(BOOL)parentHasContext parentHasFilter:(BOOL)parentHasFilter parentHasTemplateDelegate:(BOOL)parentHasTemplateDelegate parentHasRenderingOverride:(BOOL)parentHasRenderingOverride filterObject:(id)filterObject;
- (id)initWithTemplate:(GRMustacheTemplate *)template parent:(GRMustacheRuntime *)parent parentHasContext:(BOOL)parentHasContext parentHasFilter:(BOOL)parentHasFilter parentHasTemplateDelegate:(BOOL)parentHasTemplateDelegate parentHasRenderingOverride:(BOOL)parentHasRenderingOverride renderingOverride:(id<GRMustacheRenderingOverride>)renderingOverride;
- (id<GRMustacheRenderingElement>)resolveOverridableRenderingElement:(id<GRMustacheRenderingElement>)element;
- (void)assertAcyclicRenderingOverride:(id<GRMustacheRenderingOverride>)renderingOverride;
@end

@implementation GRMustacheRuntime

+ (void)preventNSUndefinedKeyExceptionAttack
{
    preventingNSUndefinedKeyExceptionAttack = YES;
}

+ (id)runtime
{
    return [[[self alloc] initWithTemplate:nil contextObject:nil] autorelease];
}

+ (id)runtimeWithTemplate:(GRMustacheTemplate *)template contextObject:(id)contextObject
{
    return [[[self alloc] initWithTemplate:template contextObject:contextObject] autorelease];
}

+ (id)runtimeWithTemplate:(GRMustacheTemplate *)template contextObjects:(NSArray *)contextObjects
{
    GRMustacheRuntime *runtime = [[[self alloc] initWithTemplate:template contextObject:nil] autorelease];
    for (id contextObject in contextObjects) {
        runtime = [runtime runtimeByAddingContextObject:contextObject];
    }
    return runtime;
}

- (GRMustacheRuntime *)runtimeByAddingTemplateDelegate:(id<GRMustacheTemplateDelegate>)templateDelegate
{
    if (templateDelegate == nil) {
        return self;
    }
    
    return [[[GRMustacheRuntime alloc] initWithTemplate:_template
                                                 parent:self
                                       parentHasContext:_contextObject || _parentHasContext
                                        parentHasFilter:_filterObject || _parentHasFilter
                              parentHasTemplateDelegate:_templateDelegate || _parentHasTemplateDelegate
                             parentHasRenderingOverride:_renderingOverride || _parentHasRenderingOverride
                                       templateDelegate:templateDelegate] autorelease];
}

- (GRMustacheRuntime *)runtimeByAddingContextObject:(id)contextObject
{
    if (contextObject == nil) {
        return self;
    }
    
    return [[[GRMustacheRuntime alloc] initWithTemplate:_template
                                                 parent:self
                                       parentHasContext:_contextObject || _parentHasContext
                                        parentHasFilter:_filterObject || _parentHasFilter
                              parentHasTemplateDelegate:_templateDelegate || _parentHasTemplateDelegate
                             parentHasRenderingOverride:_renderingOverride || _parentHasRenderingOverride
                                          contextObject:contextObject] autorelease];
}

- (GRMustacheRuntime *)runtimeByAddingFilterObject:(id)filterObject;
{
    if (filterObject == nil) {
        return self;
    }
    
    return [[[GRMustacheRuntime alloc] initWithTemplate:_template
                                                 parent:self
                                       parentHasContext:_contextObject || _parentHasContext
                                        parentHasFilter:_filterObject || _parentHasFilter
                              parentHasTemplateDelegate:_templateDelegate || _parentHasTemplateDelegate
                              parentHasRenderingOverride:_renderingOverride || _parentHasRenderingOverride
                                           filterObject:filterObject] autorelease];
}

- (GRMustacheRuntime *)runtimeByAddingRenderingOverride:(id<GRMustacheRenderingOverride>)renderingOverride
{
    if (renderingOverride == nil) {
        return self;
    }
    
    [self assertAcyclicRenderingOverride:renderingOverride];
    
    return [[[GRMustacheRuntime alloc] initWithTemplate:_template
                                                 parent:self
                                       parentHasContext:_contextObject || _parentHasContext
                                        parentHasFilter:_filterObject || _parentHasFilter
                              parentHasTemplateDelegate:_templateDelegate || _parentHasTemplateDelegate
                             parentHasRenderingOverride:_renderingOverride || _parentHasRenderingOverride
                                      renderingOverride:renderingOverride] autorelease];
}

- (void)dealloc
{
    [_parent release];
    [_template release];
    [_templateDelegate release];
    [_contextObject release];
    [_filterObject release];
    [super dealloc];
}

- (id)currentContextValue
{
    if (_contextObject) {
        return [[_contextObject retain] autorelease];
    }
    if (_parentHasContext) {
        return [_parent currentContextValue];
    }
    return nil;
}

- (id)contextValueForKey:(NSString *)key
{
    if (_contextObject) {
        id value = [GRMustacheRuntime valueForKey:key inObject:_contextObject];
        if (value != nil) { return value; }
    }
    if (_parentHasContext) {
        return [_parent contextValueForKey:key];
    }
    return nil;
}

- (id)filterValueForKey:(NSString *)key
{
    if (_filterObject) {
        id value = [GRMustacheRuntime valueForKey:key inObject:_filterObject];
        if (value != nil) { return value; }
    }
    if (_parentHasFilter) {
        return [_parent filterValueForKey:key];
    }
    return nil;
}

- (void)delegateValue:(id)value interpretation:(GRMustacheInterpretation)interpretation forRenderingToken:(GRMustacheToken *)token usingBlock:(void(^)(id value))block
{
    if (_templateDelegate) {
        NSAssert(_template, @"WTF");
        
        GRMustacheInvocation *invocation = [[[GRMustacheInvocation alloc] init] autorelease];
        invocation.token = token;
        invocation.returnValue = value;
        
        if ([_templateDelegate respondsToSelector:@selector(template:willInterpretReturnValueOfInvocation:as:)]) {
            [_templateDelegate template:_template willInterpretReturnValueOfInvocation:invocation as:interpretation];
        }
        
        if (_parent) {
            [_parent delegateValue:invocation.returnValue interpretation:interpretation forRenderingToken:token usingBlock:block];
        } else {
            block(invocation.returnValue);
        }
        
        if ([_templateDelegate respondsToSelector:@selector(template:didInterpretReturnValueOfInvocation:as:)]) {
            [_templateDelegate template:_template didInterpretReturnValueOfInvocation:invocation as:interpretation];
        }
    } else {
        if (_parentHasTemplateDelegate) {
            [_parent delegateValue:value interpretation:interpretation forRenderingToken:token usingBlock:block];
        } else {
            block(value);
        }
    }
}

- (id<GRMustacheRenderingElement>)resolveRenderingElement:(id<GRMustacheRenderingElement>)element
{
    if (element.isOverridable) {
        id<GRMustacheRenderingElement> overridingElement = [self resolveOverridableRenderingElement:element];
        if (overridingElement) { return overridingElement; }
    }
    return element;
}

#pragma mark - Private

- (id<GRMustacheRenderingElement>)resolveOverridableRenderingElement:(id<GRMustacheRenderingElement>)element
{
    if (_renderingOverride) {
        element = [_renderingOverride resolveOverridableRenderingElement:element];
    }
    if (_parentHasRenderingOverride) {
        element = [_parent resolveOverridableRenderingElement:element];
    }
    return element;
}

- (void)assertAcyclicRenderingOverride:(id<GRMustacheRenderingOverride>)renderingOverride
{
    if (_renderingOverride) {
        if ([_renderingOverride isEqual:renderingOverride]) {
            [NSException raise:GRMustacheRenderingException format:@"Override cycle"];
        }
    }
    if (_parentHasRenderingOverride) {
        [_parent assertAcyclicRenderingOverride:renderingOverride];
    }
}

+ (id)valueForKey:(NSString *)key inObject:(id)object
{
    id value = nil;
    
    if (object)
    {
        if ([self objectIsFoundationCollectionWhoseImplementationOfValueForKeyReturnsAnotherCollection:object]) {
            // Specific case here: we don't want to return another collection.
            // See issue #21 and "anchored key should not extract properties
            // inside an array" test in
            // src/tests/Public/v4.0/GRMustacheSuites/compound_keys.json
            return nil;
        }
        
        @try
        {
            if (preventingNSUndefinedKeyExceptionAttack)
            {
                value = [GRMustacheNSUndefinedKeyExceptionGuard valueForKey:key inObject:object];
            }
            else
            {
                value = [object valueForKey:key];
            }
        }
        @catch (NSException *exception)
        {
            // swallow all NSUndefinedKeyException, reraise other exceptions
            if (![[exception name] isEqualToString:NSUndefinedKeyException])
            {
                [exception raise];
            }
#if !defined(NS_BLOCK_ASSERTIONS)
            else
            {
                // For testing purpose
                GRMustacheRuntimeDidCatchNSUndefinedKeyException = YES;
            }
#endif
        }
    }
    
    return value;
}

- (id)initWithTemplate:(GRMustacheTemplate *)template contextObject:(id)contextObject
{
    self = [super init];
    if (self) {
        _template = [template retain];
        _templateDelegate = [template.delegate retain];
        _filterObject = [[GRMustacheFilterLibrary filterLibrary] retain];
        _contextObject = [contextObject retain];
    }
    return self;
}

- (id)initWithTemplate:(GRMustacheTemplate *)template parent:(GRMustacheRuntime *)parent parentHasContext:(BOOL)parentHasContext parentHasFilter:(BOOL)parentHasFilter parentHasTemplateDelegate:(BOOL)parentHasTemplateDelegate parentHasRenderingOverride:(BOOL)parentHasRenderingOverride templateDelegate:(id<GRMustacheTemplateDelegate>)templateDelegate
{
    self = [super init];
    if (self) {
        _template = [template retain];
        _parent = [parent retain];
        _templateDelegate = [templateDelegate retain];
        _parentHasContext = parentHasContext;
        _parentHasFilter = parentHasFilter;
        _parentHasTemplateDelegate = parentHasTemplateDelegate;
        _parentHasRenderingOverride = parentHasRenderingOverride;
    }
    return self;
}

- (id)initWithTemplate:(GRMustacheTemplate *)template parent:(GRMustacheRuntime *)parent parentHasContext:(BOOL)parentHasContext parentHasFilter:(BOOL)parentHasFilter parentHasTemplateDelegate:(BOOL)parentHasTemplateDelegate parentHasRenderingOverride:(BOOL)parentHasRenderingOverride contextObject:(id)contextObject
{
    self = [super init];
    if (self) {
        _template = [template retain];
        _parent = [parent retain];
        _contextObject = [contextObject retain];
        _parentHasContext = parentHasContext;
        _parentHasFilter = parentHasFilter;
        _parentHasTemplateDelegate = parentHasTemplateDelegate;
        _parentHasRenderingOverride = parentHasRenderingOverride;
    }
    return self;
}

- (id)initWithTemplate:(GRMustacheTemplate *)template parent:(GRMustacheRuntime *)parent parentHasContext:(BOOL)parentHasContext parentHasFilter:(BOOL)parentHasFilter parentHasTemplateDelegate:(BOOL)parentHasTemplateDelegate parentHasRenderingOverride:(BOOL)parentHasRenderingOverride filterObject:(id)filterObject
{
    self = [super init];
    if (self) {
        _template = [template retain];
        _parent = [parent retain];
        _filterObject = [filterObject retain];
        _parentHasContext = parentHasContext;
        _parentHasFilter = parentHasFilter;
        _parentHasTemplateDelegate = parentHasTemplateDelegate;
        _parentHasRenderingOverride = parentHasRenderingOverride;
    }
    return self;
}

- (id)initWithTemplate:(GRMustacheTemplate *)template parent:(GRMustacheRuntime *)parent parentHasContext:(BOOL)parentHasContext parentHasFilter:(BOOL)parentHasFilter parentHasTemplateDelegate:(BOOL)parentHasTemplateDelegate parentHasRenderingOverride:(BOOL)parentHasRenderingOverride renderingOverride:(id<GRMustacheRenderingOverride>)renderingOverride
{
    self = [super init];
    if (self) {
        _template = [template retain];
        _parent = [parent retain];
        _renderingOverride = [renderingOverride retain];
        _parentHasContext = parentHasContext;
        _parentHasFilter = parentHasFilter;
        _parentHasTemplateDelegate = parentHasTemplateDelegate;
        _parentHasRenderingOverride = parentHasRenderingOverride;
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

@end
