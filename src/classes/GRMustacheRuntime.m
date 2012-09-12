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

#if !defined(NS_BLOCK_ASSERTIONS)
BOOL GRMustacheRuntimeDidCatchNSUndefinedKeyException;
#endif

static BOOL preventingNSUndefinedKeyExceptionAttack = NO;

@interface GRMustacheRuntime()
+ (BOOL)objectIsFoundationCollectionWhoseImplementationOfValueForKeyReturnsAnotherCollection:(id)object;
- (id)initWithTemplate:(GRMustacheTemplate *)template;
- (id)initWithParent:(GRMustacheRuntime *)parent withContext:(BOOL)withContext withFilter:(BOOL)withFilter withDelegate:(BOOL)withDelegate templateDelegate:(id<GRMustacheTemplateDelegate>)templateDelegate;
- (id)initWithParent:(GRMustacheRuntime *)parent withContext:(BOOL)withContext withFilter:(BOOL)withFilter withDelegate:(BOOL)withDelegate contextObject:(id)contextObject;
- (id)initWithParent:(GRMustacheRuntime *)parent withContext:(BOOL)withContext withFilter:(BOOL)withFilter withDelegate:(BOOL)withDelegate filterObject:(id)filterObject;
@end

@implementation GRMustacheRuntime

+ (void)preventNSUndefinedKeyExceptionAttack
{
    preventingNSUndefinedKeyExceptionAttack = YES;
}

+ (id)runtimeWithTemplate:(GRMustacheTemplate *)template
{
    return [[[self alloc] initWithTemplate:template] autorelease];
}

- (GRMustacheRuntime *)runtimeByAddingTemplateDelegate:(id<GRMustacheTemplateDelegate>)templateDelegate
{
    if (templateDelegate == nil) {
        return self;
    }
    
    return [[[GRMustacheRuntime alloc] initWithParent:self
                                          withContext:_contextObject || _parentHasContext
                                           withFilter:_filterObject || _parentHasFilter
                                         withDelegate:_templateDelegate || _parentHasTemplateDelegate
                                     templateDelegate:templateDelegate] autorelease];
}

- (GRMustacheRuntime *)runtimeByAddingContextObject:(id)contextObject
{
    if (contextObject == nil) {
        return self;
    }
    
    return [[[GRMustacheRuntime alloc] initWithParent:self
                                          withContext:_contextObject || _parentHasContext
                                           withFilter:_filterObject || _parentHasFilter
                                         withDelegate:_templateDelegate || _parentHasTemplateDelegate
                                        contextObject:contextObject] autorelease];
}

- (GRMustacheRuntime *)runtimeByAddingFilterObject:(id)filterObject;
{
    if (filterObject == nil) {
        return self;
    }
    
    return [[[GRMustacheRuntime alloc] initWithParent:self
                                          withContext:_contextObject || _parentHasContext
                                           withFilter:_filterObject || _parentHasFilter
                                         withDelegate:_templateDelegate || _parentHasTemplateDelegate
                                         filterObject:filterObject] autorelease];
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

- (NSString *)renderValue:(id)value fromToken:(GRMustacheToken *)token as:(GRMustacheInterpretation)interpretation usingBlock:(NSString *(^)(id value))block
{
    NSString *rendering = nil;
    
    if (_templateDelegate) {
        GRMustacheInvocation *invocation = [[[GRMustacheInvocation alloc] init] autorelease];
        invocation.token = token;
        invocation.returnValue = value;
        
        if ([_templateDelegate respondsToSelector:@selector(template:willInterpretReturnValueOfInvocation:as:)]) {
            [_templateDelegate template:_template willInterpretReturnValueOfInvocation:invocation as:interpretation];
        }
        
        if (_parent) {
            rendering = [_parent renderValue:invocation.returnValue fromToken:token as:interpretation usingBlock:block];
        } else {
            rendering = block(invocation.returnValue);
        }
        
        if ([_templateDelegate respondsToSelector:@selector(template:didInterpretReturnValueOfInvocation:as:)]) {
            [_templateDelegate template:_template didInterpretReturnValueOfInvocation:invocation as:interpretation];
        }
    } else {
        if (_parentHasTemplateDelegate) {
            rendering = [_parent renderValue:value fromToken:token as:interpretation usingBlock:block];
        } else {
            rendering = block(value);
        }
    }
    
    if (rendering == nil) {
        return @"";
    }
    return rendering;
}

#pragma mark - Private

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

- (id)initWithTemplate:(GRMustacheTemplate *)template
{
    self = [super init];
    if (self) {
        _template = [template retain];
        _templateDelegate = [template.delegate retain];
        _filterObject = [[GRMustacheFilterLibrary filterLibrary] retain];
    }
    return self;
}

- (id)initWithParent:(GRMustacheRuntime *)parent withContext:(BOOL)withContext withFilter:(BOOL)withFilter withDelegate:(BOOL)withDelegate templateDelegate:(id<GRMustacheTemplateDelegate>)templateDelegate
{
    self = [super init];
    if (self) {
        _parent = [parent retain];
        _templateDelegate = [templateDelegate retain];
        _parentHasContext = withContext;
        _parentHasFilter = withFilter;
        _parentHasTemplateDelegate = withDelegate;
    }
    return self;
}

- (id)initWithParent:(GRMustacheRuntime *)parent withContext:(BOOL)withContext withFilter:(BOOL)withFilter withDelegate:(BOOL)withDelegate contextObject:(id)contextObject
{
    self = [super init];
    if (self) {
        _parent = [parent retain];
        _contextObject = [contextObject retain];
        _parentHasContext = withContext;
        _parentHasFilter = withFilter;
        _parentHasTemplateDelegate = withDelegate;
    }
    return self;
}

- (id)initWithParent:(GRMustacheRuntime *)parent withContext:(BOOL)withContext withFilter:(BOOL)withFilter withDelegate:(BOOL)withDelegate filterObject:(id)filterObject
{
    self = [super init];
    if (self) {
        _parent = [parent retain];
        _filterObject = [filterObject retain];
        _parentHasContext = withContext;
        _parentHasFilter = withFilter;
        _parentHasTemplateDelegate = withDelegate;
    }
    return self;
}

+ (BOOL)objectIsFoundationCollectionWhoseImplementationOfValueForKeyReturnsAnotherCollection:(id)object
{
    static SEL selector = nil;
    static IMP NSObjectIMPL = nil;
    static IMP NSDictionaryIMPL = nil;
    static BOOL NSManagedObjectIMPLComputed = NO;
    static IMP NSManagedObjectIMPL = nil;
    static Class NSOrderedSetClass = nil;
    
    if (selector == nil) {
        selector = @selector(valueForKey:);
    }
    
    if (NSObjectIMPL == nil) {
        NSObjectIMPL = class_getMethodImplementation([NSObject class], selector);
    }
    
    if (NSDictionaryIMPL == nil) {
        NSDictionaryIMPL = class_getMethodImplementation([NSDictionary class], selector);
    }
    
    if (NSManagedObjectIMPLComputed == NO) {
        Class NSManagedObjectClass = NSClassFromString(@"NSManagedObject");
        if (NSManagedObjectClass) {
            NSManagedObjectIMPL = class_getMethodImplementation(NSManagedObjectClass, selector);
        }
        NSManagedObjectIMPLComputed = YES;
    }
    
    IMP objectIMPL = class_getMethodImplementation([object class], selector);
    
    if (objectIMPL == NSObjectIMPL) {
        return NO;
    }
    
    if (objectIMPL == NSDictionaryIMPL) {
        return NO;
    }
    
    if (objectIMPL == NSManagedObjectIMPL) {
        return NO;
    }
    
    // NSOrderedSet is iOS >= 5 or OSX >= 10.7. Don't name it directly.
    if (NSOrderedSetClass == nil) {
        NSOrderedSetClass = NSClassFromString(@"NSOrderedSet");
    }
    
    if ([object isKindOfClass:[NSArray class]] || [object isKindOfClass:[NSSet class]] || (NSOrderedSetClass && [object isKindOfClass:NSOrderedSetClass])) {
        return YES;
    }
    
    return NO;
}

@end
