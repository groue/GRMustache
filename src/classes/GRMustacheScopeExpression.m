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

#import "GRMustacheScopeExpression_private.h"
#import "GRMustacheContext_private.h"

@interface GRMustacheScopeExpression()
@property (nonatomic, retain) id<GRMustacheExpression> scopedExpression;
@property (nonatomic, copy) NSString *identifier;

- (id)initWithScopedExpression:(id<GRMustacheExpression>)scopedExpression identifier:(NSString *)identifier;
@end

@implementation GRMustacheScopeExpression
@synthesize scopedExpression=_scopedExpression;
@synthesize identifier=_identifier;

+ (id)expressionWithScopedExpression:(id<GRMustacheExpression>)scopedExpression identifier:(NSString *)identifier
{
    return [[[self alloc] initWithScopedExpression:scopedExpression identifier:identifier] autorelease];
}

- (id)initWithScopedExpression:(id<GRMustacheExpression>)scopedExpression identifier:(NSString *)identifier
{
    self = [super init];
    if (self) {
        self.scopedExpression = scopedExpression;
        self.identifier = identifier;
    }
    return self;
}

- (void)dealloc
{
    [_scopedExpression release];
    [_identifier release];
    [super dealloc];
}

- (BOOL)isEqual:(id<GRMustacheExpression>)expression
{
    if (![expression isKindOfClass:[GRMustacheScopeExpression class]]) {
        return NO;
    }
    if (![_scopedExpression isEqual:((GRMustacheScopeExpression *)expression).scopedExpression]) {
        return NO;
    }
    return [_identifier isEqual:((GRMustacheScopeExpression *)expression).identifier];
}


#pragma mark - GRMustacheExpression

- (id)valueForContext:(GRMustacheContext *)context filterContext:(GRMustacheContext *)filterContext
{
    id value = [_scopedExpression valueForContext:context filterContext:filterContext];
    return [GRMustacheContext valueForKey:_identifier inObject:value];
}

@end
