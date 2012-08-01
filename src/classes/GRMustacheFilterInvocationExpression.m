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

#import "GRMustacheFilterInvocationExpression_private.h"
#import "GRMustacheInvocation_private.h"
#import "GRMustacheFilter.h"

@interface GRMustacheFilterInvocationExpression()
@property (nonatomic, retain) GRMustacheInvocation *invocation;
@property (nonatomic, retain) id<GRMustacheExpression> filterExpression;
@property (nonatomic, retain) id<GRMustacheExpression> parameterExpression;
- (id)initWithFilterExpression:(id<GRMustacheExpression>)filterExpression parameterExpression:(id<GRMustacheExpression>)parameterExpression;
@end

@implementation GRMustacheFilterInvocationExpression
@synthesize invocation = _invocation;
@synthesize filterExpression = _filterExpression;
@synthesize parameterExpression = _parameterExpression;

+ (id)expressionWithFilterExpression:(id<GRMustacheExpression>)filterExpression parameterExpression:(id<GRMustacheExpression>)parameterExpression
{
    return [[[self alloc] initWithFilterExpression:filterExpression parameterExpression:parameterExpression] autorelease];
}

- (id)initWithFilterExpression:(id<GRMustacheExpression>)filterExpression parameterExpression:(id<GRMustacheExpression>)parameterExpression
{
    self = [super init];
    if (self) {
        _filterExpression = [filterExpression retain];
        _parameterExpression = [parameterExpression retain];
    }
    return self;
}

- (void)dealloc
{
    [_invocation release];
    [_filterExpression release];
    [_parameterExpression release];
    [super dealloc];
}

- (BOOL)isEqual:(id<GRMustacheExpression>)expression
{
    if (![expression isKindOfClass:[GRMustacheFilterInvocationExpression class]]) {
        return NO;
    }
    if (![_filterExpression isEqual:((GRMustacheFilterInvocationExpression *)expression).filterExpression]) {
        return NO;
    }
    return [_parameterExpression isEqual:((GRMustacheFilterInvocationExpression *)expression).parameterExpression];
}


#pragma mark GRMustacheExpression

- (GRMustacheToken *)debuggingToken
{
    return _filterExpression.debuggingToken;
}

- (void)setDebuggingToken:(GRMustacheToken *)debuggingToken
{
    _filterExpression.debuggingToken = debuggingToken;
    _parameterExpression.debuggingToken = debuggingToken;
}

- (void)prepareForContext:(GRMustacheContext *)context filterContext:(GRMustacheContext *)filterContext delegatingTemplate:(GRMustacheTemplate *)delegatingTemplate delegates:(NSArray *)delegates interpretation:(GRMustacheInterpretation)interpretation
{
    [_parameterExpression prepareForContext:context filterContext:filterContext delegatingTemplate:delegatingTemplate delegates:delegates interpretation:interpretation];
    self.invocation = _parameterExpression.invocation;
    
    // There is no delegate callbacks for filters, in order not to have library
    // users change their pre-4.3 delegates that do not check the interpretation
    // before replacing the value.
    [_filterExpression prepareForContext:filterContext filterContext:filterContext delegatingTemplate:nil delegates:nil interpretation:0];
    GRMustacheInvocation *filterInvocation = _filterExpression.invocation;
    id<GRMustacheFilter> filter = filterInvocation.returnValue;
    
    if (filter == nil) {
        [NSException raise:GRMustacheFilterException format:@"Missing filter for key `%@` in tag %@", filterInvocation.key, filterInvocation.description];
    }
    
    if (![filter conformsToProtocol:@protocol(GRMustacheFilter)]) {
        [NSException raise:GRMustacheFilterException format:@"Object for key `%@` in tag %@ does not conform to GRMustacheFilter protocol: %@", filterInvocation.key, filterInvocation.description, filter];
    }
    
    if (filter) {
        _invocation.returnValue = [filter transformedValue:_invocation.returnValue];
    }
}

- (void)finishForContext:(GRMustacheContext *)context filterContext:(GRMustacheContext *)filterContext delegatingTemplate:(GRMustacheTemplate *)delegatingTemplate delegates:(NSArray *)delegates interpretation:(GRMustacheInterpretation)interpretation
{
    // There is no delegate callbacks for filters
    // (see prepareForContext:filterContext:delegatingTemplate:delegates:interpretation:)
    [_filterExpression finishForContext:filterContext filterContext:filterContext delegatingTemplate:nil delegates:nil interpretation:0];  // no delegate callbacks for filters
    
    [_parameterExpression finishForContext:context filterContext:filterContext delegatingTemplate:delegatingTemplate delegates:delegates interpretation:interpretation];
    
    self.invocation = nil;
}


@end
