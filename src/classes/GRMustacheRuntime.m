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
@property (nonatomic, retain) GRMustacheTemplate *template;
@property (nonatomic, retain) NSArray *delegates;
@property (nonatomic, retain) GRMustacheContext *renderingContext;
@property (nonatomic, retain) GRMustacheContext *filterContext;
- (id)initWithTemplate:(GRMustacheTemplate *)template delegates:(NSArray *)delegates renderingContext:(GRMustacheContext *)renderingContext filterContext:(GRMustacheContext *)filterContext;
@end

@implementation GRMustacheRuntime
@synthesize template=_template;
@synthesize delegates=_delegates;
@synthesize renderingContext=_renderingContext;
@synthesize filterContext=_filterContext;

+ (id)runtimeWithTemplate:(GRMustacheTemplate *)template renderingContext:(GRMustacheContext *)renderingContext filterContext:(GRMustacheContext *)filterContext
{
    NSArray *delegates = nil;
    if (template.delegate) {
        delegates = [NSArray arrayWithObject:template.delegate];
    }
    return [[[GRMustacheRuntime alloc] initWithTemplate:template delegates:delegates renderingContext:renderingContext filterContext:filterContext] autorelease];
}

- (void)dealloc
{
    [_template release];
    [_delegates release];
    [_renderingContext release];
    [_filterContext release];
    [super dealloc];
}

- (id)initWithTemplate:(GRMustacheTemplate *)template delegates:(NSArray *)delegates renderingContext:(GRMustacheContext *)renderingContext filterContext:(GRMustacheContext *)filterContext
{
    self = [super init];
    if (self) {
        _template = [template retain];
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
    return [[[GRMustacheRuntime alloc] initWithTemplate:_template delegates:delegates renderingContext:_renderingContext filterContext:_filterContext] autorelease];
}

- (GRMustacheRuntime *)runtimeByAddingContextObject:(id)object
{
    GRMustacheContext *renderingContext = [_renderingContext contextByAddingObject:object];
    return [[[GRMustacheRuntime alloc] initWithTemplate:_template delegates:_delegates renderingContext:renderingContext filterContext:_filterContext] autorelease];
}

- (id)contextValueForKey:(NSString *)key
{
    return [_renderingContext valueForKey:key];
}

- (id)filterValueForKey:(NSString *)key
{
    return [_filterContext valueForKey:key];
}

- (id)currentContextValue
{
    return _renderingContext.object;
}

- (NSString *)renderValue:(id)value fromToken:(GRMustacheToken *)token as:(GRMustacheInterpretation)interpretation usingBlock:(NSString *(^)(id value))block
{
    NSString *rendering = nil;
    
    @autoreleasepool {
        if (_delegates.count == 0) {
            rendering = block(value);
        } else {
            rendering = [self delegateRenderValue:value fromToken:token as:interpretation withDelegateAtIndex:0 usingBlock:block];
        }
        [rendering retain];
    }
    
    if (rendering == nil) {
        return @"";
    }
    return [rendering autorelease];
}

#pragma mark - Private

- (NSString *)delegateRenderValue:(id)value fromToken:(GRMustacheToken *)token as:(GRMustacheInterpretation)interpretation withDelegateAtIndex:(NSUInteger)index usingBlock:(NSString *(^)(id value))block
{
    GRMustacheInvocation *invocation = [[[GRMustacheInvocation alloc] init] autorelease];
    invocation.token = token;
    invocation.returnValue = value;
    
    id<GRMustacheTemplateDelegate> delegate = [_delegates objectAtIndex:index];
    
    if ([delegate respondsToSelector:@selector(template:willInterpretReturnValueOfInvocation:as:)]) {
        [delegate template:_template willInterpretReturnValueOfInvocation:invocation as:interpretation];
    }

    NSString *rendering = nil;
    if (index == _delegates.count - 1) {
        rendering = block(invocation.returnValue);
    } else {
        rendering = [self delegateRenderValue:invocation.returnValue fromToken:token as:interpretation withDelegateAtIndex:index+1 usingBlock:block];
    }
    
    if ([delegate respondsToSelector:@selector(template:didInterpretReturnValueOfInvocation:as:)]) {
        [delegate template:_template didInterpretReturnValueOfInvocation:invocation as:interpretation];
    }
    
    return rendering;
}

@end
