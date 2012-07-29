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

#import "GRMustacheExpression_private.h"
#import "GRMustacheInvocation_private.h"
#import "GRMustacheTemplate_private.h"
#import "GRMustacheFilter.h"


// =============================================================================
#pragma mark - GRMustacheKeyPathExpression

@interface GRMustacheKeyPathExpression()
@property (nonatomic, retain) GRMustacheInvocation *invocation;
- (id)initWithKeys:(NSArray *)keys;
@end

@implementation GRMustacheKeyPathExpression
@synthesize invocation = _invocation;

+ (id)expressionWithKeys:(NSArray *)keys 
{
    return [[[self alloc] initWithKeys:keys] autorelease];
}

- (id)initWithKeys:(NSArray *)keys
{
    self = [super init];
    if (self) {
        _invocation = [[GRMustacheInvocation invocationWithKeys:keys] retain];
    }
    return self;
}

- (void)dealloc
{
    [_invocation release];
    [super dealloc];
}

- (BOOL)isEqual:(id<GRMustacheExpression>)expression
{
    if (![expression isKindOfClass:[GRMustacheKeyPathExpression class]]) {
        return NO;
    }
    
    return [_invocation.keys isEqualToArray:((GRMustacheKeyPathExpression *)expression).invocation.keys];
}


#pragma mark GRMustacheExpression

- (GRMustacheToken *)debuggingToken
{
    return _invocation.debuggingToken;
}

- (void)setDebuggingToken:(GRMustacheToken *)debuggingToken
{
    _invocation.debuggingToken = debuggingToken;
}

- (void)prepareForContext:(GRMustacheContext *)context delegatingTemplate:(GRMustacheTemplate *)delegatingTemplate delegates:(NSArray *)delegates interpretation:(GRMustacheInterpretation)interpretation
{
    [_invocation invokeWithContext:context];
    [delegatingTemplate invokeDelegates:delegates willInterpretReturnValueOfInvocation:_invocation as:interpretation];
}

- (void)finishForContext:(GRMustacheContext *)context delegatingTemplate:(GRMustacheTemplate *)delegatingTemplate delegates:(NSArray *)delegates interpretation:(GRMustacheInterpretation)interpretation
{
    [delegatingTemplate invokeDelegates:delegates didInterpretReturnValueOfInvocation:_invocation as:interpretation];
    _invocation.returnValue = nil;
}

@end


// =============================================================================
#pragma mark - GRMustacheFilterChainExpression

@interface GRMustacheFilterChainExpression()
@property (nonatomic, retain) GRMustacheInvocation *invocation;
@property (nonatomic, retain) id<GRMustacheExpression> filteredExpression;
@property (nonatomic, retain) NSArray *filterExpressions;
- (id)initWithFilteredExpression:(id<GRMustacheExpression>)filteredExpression filterExpressions:(NSArray *)filterExpressions;
@end

@implementation GRMustacheFilterChainExpression
@synthesize invocation = _invocation;
@synthesize filteredExpression = _filteredExpression;
@synthesize filterExpressions = _filterExpressions;

+ (id)expressionWithFilteredExpression:(id<GRMustacheExpression>)filteredExpression filterExpressions:(NSArray *)filterExpressions
{
    return [[[self alloc] initWithFilteredExpression:filteredExpression filterExpressions:filterExpressions] autorelease];
}

- (id)initWithFilteredExpression:(id<GRMustacheExpression>)filteredExpression filterExpressions:(NSArray *)filterExpressions
{
    self = [super init];
    if (self) {
        _filteredExpression = [filteredExpression retain];
        _filterExpressions = [filterExpressions retain];
    }
    return self;
}

- (void)dealloc
{
    [_invocation release];
    [_filteredExpression release];
    [_filterExpressions release];
    [super dealloc];
}

- (BOOL)isEqual:(id<GRMustacheExpression>)expression
{
    if (![expression isKindOfClass:[GRMustacheFilterChainExpression class]]) {
        return NO;
    }
    if (![_filteredExpression isEqual:((GRMustacheFilterChainExpression *)expression).filteredExpression]) {
        return NO;
    }
    return [_filterExpressions isEqualToArray:((GRMustacheFilterChainExpression *)expression).filterExpressions];
}


#pragma mark GRMustacheExpression

- (GRMustacheToken *)debuggingToken
{
    return _filteredExpression.debuggingToken;
}

- (void)setDebuggingToken:(GRMustacheToken *)debuggingToken
{
    _filteredExpression.debuggingToken = debuggingToken;
    for (id<GRMustacheExpression> filterExpression in _filterExpressions) {
        filterExpression.debuggingToken = debuggingToken;
    }
}

- (void)prepareForContext:(GRMustacheContext *)context delegatingTemplate:(GRMustacheTemplate *)delegatingTemplate delegates:(NSArray *)delegates interpretation:(GRMustacheInterpretation)interpretation
{
    [_filteredExpression prepareForContext:context delegatingTemplate:delegatingTemplate delegates:delegates interpretation:interpretation];
    self.invocation = _filteredExpression.invocation;
    
    for (id<GRMustacheExpression> filterExpression in _filterExpressions) {
        [filterExpression prepareForContext:context delegatingTemplate:delegatingTemplate delegates:delegates interpretation:GRMustacheInterpretationFilter];
        GRMustacheInvocation *filterInvocation = filterExpression.invocation;
        id<GRMustacheFilter> filter = filterInvocation.returnValue;
        
        if (![filter conformsToProtocol:@protocol(GRMustacheFilter)]) {
            [NSException raise:GRMustacheFilterException format:@"Object for key `%@` in tag %@ does not conform to GRMustacheFilter protocol: %@", filterInvocation.key, filterInvocation.description, filter];
        }
        
        if (filter) {
            _invocation.returnValue = [filter transformedValue:_invocation.returnValue];
        }
    }
}

- (void)finishForContext:(GRMustacheContext *)context delegatingTemplate:(GRMustacheTemplate *)delegatingTemplate delegates:(NSArray *)delegates interpretation:(GRMustacheInterpretation)interpretation
{
    for (id<GRMustacheExpression> filterExpression in _filterExpressions) {
        [filterExpression finishForContext:context delegatingTemplate:delegatingTemplate delegates:delegates interpretation:GRMustacheInterpretationFilter];
    }
    
    [_filteredExpression finishForContext:context delegatingTemplate:delegatingTemplate delegates:delegates interpretation:interpretation];
    
    self.invocation = nil;
}


@end
