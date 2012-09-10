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

#import "GRMustacheRuntime_private.h"
#import "GRMustacheContext_private.h"
#import "GRMustacheTemplate_private.h"
#import "GRMustacheInvocation_private.h"

@interface GRMustacheRuntime()
@property (nonatomic, retain) GRMustacheTemplate *delegatingTemplate;
@property (nonatomic, retain) NSArray *delegates;
@property (nonatomic, retain) GRMustacheContext *renderingContext;
@property (nonatomic, retain) GRMustacheContext *filterContext;
- (id)initWithDelegatingTemplate:(GRMustacheTemplate *)delegatingTemplate delegates:(NSArray *)delegates renderingContext:(GRMustacheContext *)renderingContext filterContext:(GRMustacheContext *)filterContext;
@end

@implementation GRMustacheRuntime
@synthesize delegatingTemplate=_delegatingTemplate;
@synthesize delegates=_delegates;
@synthesize renderingContext=_renderingContext;
@synthesize filterContext=_filterContext;

+ (id)runtimeWithDelegatingTemplate:(GRMustacheTemplate *)delegatingTemplate renderingContext:(GRMustacheContext *)renderingContext filterContext:(GRMustacheContext *)filterContext
{
    NSArray *delegates = nil;
    if (delegatingTemplate.delegate) {
        delegates = [[NSArray arrayWithObject:delegatingTemplate.delegate] retain];
    }
    return [[[GRMustacheRuntime alloc] initWithDelegatingTemplate:delegatingTemplate delegates:delegates renderingContext:renderingContext filterContext:filterContext] autorelease];
}

- (void)dealloc
{
    [_delegatingTemplate release];
    [_delegates release];
    [_filterContext release];
    [super dealloc];
}

- (id)initWithDelegatingTemplate:(GRMustacheTemplate *)delegatingTemplate delegates:(NSArray *)delegates renderingContext:(GRMustacheContext *)renderingContext filterContext:(GRMustacheContext *)filterContext
{
    self = [super init];
    if (self) {
        _delegatingTemplate = [delegatingTemplate retain];
        _delegates = [delegates retain];
        _renderingContext = [renderingContext retain];
        _filterContext = [filterContext retain];
    }
    return self;
}

- (GRMustacheRuntime *)runtimeByAddingTemplateDelegate:(id<GRMustacheTemplateDelegate>)delegate
{
    NSArray *delegates = [NSArray arrayWithObject:delegate];
    if (_delegates) {
        delegates = [delegates arrayByAddingObjectsFromArray:_delegates];
    }
    return [[[GRMustacheRuntime alloc] initWithDelegatingTemplate:_delegatingTemplate delegates:delegates renderingContext:_renderingContext filterContext:_filterContext] autorelease];
}

- (GRMustacheRuntime *)runtimeByAddingContextObject:(id)object
{
    GRMustacheContext *renderingContext = [_renderingContext contextByAddingObject:object];
    return [[[GRMustacheRuntime alloc] initWithDelegatingTemplate:_delegatingTemplate delegates:_delegates renderingContext:renderingContext filterContext:_filterContext] autorelease];
}

- (id)contextValueForKey:(NSString *)key
{
    return [_renderingContext valueForKey:key];
}

- (id)filterValueForKey:(NSString *)key
{
    return [_filterContext valueForKey:key];
}

- (id)contextValue
{
    return _renderingContext.object;
}

- (void)interpretExpression:(GRMustacheExpression *)expression as:(GRMustacheInterpretation)interpretation usingBlock:(void(^)(id))block
{
    id value = [expression evaluateInRuntime:self asFilterValue:NO];
    
    if (_delegatingTemplate == nil || _delegates.count == 0) {
        block(value);
    } else {
        [self delegateInterpretValue:value fromExpression:expression as:interpretation withDelegateAtIndex:0 usingBlock:block];
    }
}

#pragma mark - Private

- (void)delegateInterpretValue:(id)value fromExpression:(GRMustacheExpression *)expression as:(GRMustacheInterpretation)interpretation withDelegateAtIndex:(NSUInteger)index usingBlock:(void(^)(id))block
{
    GRMustacheInvocation *invocation = [[[GRMustacheInvocation alloc] init] autorelease];
    invocation.debuggingToken = expression.debuggingToken;
    invocation.returnValue = value;
    
    id<GRMustacheTemplateDelegate> delegate = [_delegates objectAtIndex:index];
    
    if ([delegate respondsToSelector:@selector(template:willInterpretReturnValueOfInvocation:as:)]) {
        [delegate template:_delegatingTemplate willInterpretReturnValueOfInvocation:invocation as:interpretation];
    }

    if (index == _delegates.count - 1) {
        block(invocation.returnValue);
    } else {
        [self delegateInterpretValue:invocation.returnValue fromExpression:expression as:interpretation withDelegateAtIndex:index+1 usingBlock:block];
    }
    
    if ([delegate respondsToSelector:@selector(template:didInterpretReturnValueOfInvocation:as:)]) {
        [delegate template:_delegatingTemplate didInterpretReturnValueOfInvocation:invocation as:interpretation];
    }
}

@end
