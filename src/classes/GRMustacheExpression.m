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


// =============================================================================
#pragma mark - GRMustacheKeyPathExpression

@interface GRMustacheKeyPathExpression()
- (id)initWithKeys:(NSArray *)keys;
@end

@implementation GRMustacheKeyPathExpression
@synthesize keys = _keys;

+ (id)expressionWithKeys:(NSArray *)keys
{
    return [[[self alloc] initWithKeys:keys] autorelease];
}

- (id)initWithKeys:(NSArray *)keys
{
    self = [super init];
    if (self) {
        _keys = [keys retain];
    }
    return self;
}

- (void)dealloc
{
    [_keys release];
    [super dealloc];
}

- (BOOL)isEqual:(id<GRMustacheExpression>)expression
{
    if (![expression isKindOfClass:[GRMustacheKeyPathExpression class]]) {
        return NO;
    }
    
    return [_keys isEqualToArray:((GRMustacheKeyPathExpression *)expression).keys];
}

@end


// =============================================================================
#pragma mark - GRMustacheFilterChainExpression

@interface GRMustacheFilterChainExpression()
- (id)initWithFilteredExpression:(id<GRMustacheExpression>)filteredExpression filterExpressions:(NSArray *)filterExpressions;
@end

@implementation GRMustacheFilterChainExpression
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

@end
