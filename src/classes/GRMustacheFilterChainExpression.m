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

#import "GRMustacheFilterChainExpression_private.h"
#import "GRMustacheInvocation_private.h"
#import "GRMustacheFilter.h"

@interface GRMustacheFilterChainExpression()
@property (nonatomic, retain) GRMustacheInvocation *invocation;
@property (nonatomic, retain) NSArray *expressions;
- (id)initWithExpressions:(NSArray *)expressions;
@end

@implementation GRMustacheFilterChainExpression
@synthesize invocation = _invocation;
@synthesize expressions = _expressions;

+ (id)expressionWithExpressions:(NSArray *)expressions
{
    return [[[self alloc] initWithExpressions:expressions] autorelease];
}

- (id)initWithExpressions:(NSArray *)expressions
{
    self = [super init];
    if (self) {
        _expressions = [expressions retain];
    }
    return self;
}

- (void)dealloc
{
    [_invocation release];
    [_expressions release];
    [super dealloc];
}

- (BOOL)isEqual:(id<GRMustacheExpression>)expression
{
    if (![expression isKindOfClass:[GRMustacheFilterChainExpression class]]) {
        return NO;
    }
    return [_expressions isEqualToArray:((GRMustacheFilterChainExpression *)expression).expressions];
}


#pragma mark GRMustacheExpression

- (GRMustacheToken *)debuggingToken
{
    return ((id<GRMustacheExpression>)[_expressions objectAtIndex:0]).debuggingToken;
}

- (void)setDebuggingToken:(GRMustacheToken *)debuggingToken
{
    for (id<GRMustacheExpression> expression in _expressions) {
        expression.debuggingToken = debuggingToken;
    }
}

- (void)prepareForContext:(GRMustacheContext *)context filterContext:(GRMustacheContext *)filterContext delegatingTemplate:(GRMustacheTemplate *)delegatingTemplate delegates:(NSArray *)delegates interpretation:(GRMustacheInterpretation)interpretation
{
    id<GRMustacheExpression> filteredExpression = [_expressions lastObject];
    [filteredExpression prepareForContext:context filterContext:filterContext delegatingTemplate:delegatingTemplate delegates:delegates interpretation:interpretation];
    self.invocation = filteredExpression.invocation;
    
    NSUInteger count = _expressions.count;
    if (count > 1) {
        for (NSUInteger i = count - 2;; --i) {
            id<GRMustacheExpression> filterExpression = [_expressions objectAtIndex:i];
            [filterExpression prepareForContext:filterContext filterContext:filterContext delegatingTemplate:delegatingTemplate delegates:delegates interpretation:GRMustacheInterpretationFilter];
            GRMustacheInvocation *filterInvocation = filterExpression.invocation;
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
            
            if (i == 0) {
                break;
            }
        }
    }
}

- (void)finishForContext:(GRMustacheContext *)context filterContext:(GRMustacheContext *)filterContext delegatingTemplate:(GRMustacheTemplate *)delegatingTemplate delegates:(NSArray *)delegates interpretation:(GRMustacheInterpretation)interpretation
{
    NSUInteger count = _expressions.count;
    if (count > 1) {
        for (NSUInteger i = count - 2;; --i) {
            id<GRMustacheExpression> filterExpression = [_expressions objectAtIndex:i];
            [filterExpression finishForContext:filterContext filterContext:filterContext delegatingTemplate:delegatingTemplate delegates:delegates interpretation:GRMustacheInterpretationFilter];
            if (i == 0) {
                break;
            }
        }
    }
    
    id<GRMustacheExpression> filteredExpression = [_expressions lastObject];
    [filteredExpression finishForContext:context filterContext:filterContext delegatingTemplate:delegatingTemplate delegates:delegates interpretation:interpretation];
    
    self.invocation = nil;
}


@end
