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

#import "GRMustacheFilteredExpression_private.h"
#import "GRMustacheFilter_private.h"
#import "GRMustacheError.h"
#import "GRMustacheTemplate_private.h"
#import "GRMustacheRuntime_private.h"
#import "GRMustacheToken_private.h"

@interface GRMustacheFilteredExpression()
@property (nonatomic, retain) GRMustacheExpression *filterExpression;
@property (nonatomic, retain) GRMustacheExpression *argumentExpression;
- (id)initWithFilterExpression:(GRMustacheExpression *)filterExpression argumentExpression:(GRMustacheExpression *)argumentExpression curry:(BOOL)curry;
@end

@implementation GRMustacheFilteredExpression
@synthesize filterExpression=_filterExpression;
@synthesize argumentExpression=_argumentExpression;

+ (id)expressionWithFilterExpression:(GRMustacheExpression *)filterExpression argumentExpression:(GRMustacheExpression *)argumentExpression
{
    return [[[self alloc] initWithFilterExpression:filterExpression argumentExpression:argumentExpression curry:NO] autorelease];
}

+ (id)expressionWithFilterExpression:(GRMustacheExpression *)filterExpression argumentExpression:(GRMustacheExpression *)argumentExpression curry:(BOOL)curry
{
    return [[[self alloc] initWithFilterExpression:filterExpression argumentExpression:argumentExpression curry:curry] autorelease];
}

- (id)initWithFilterExpression:(GRMustacheExpression *)filterExpression argumentExpression:(GRMustacheExpression *)argumentExpression curry:(BOOL)curry
{
    self = [super init];
    if (self) {
        _filterExpression = [filterExpression retain];
        _argumentExpression = [argumentExpression retain];
        _curry = curry;
    }
    return self;
}

- (void)dealloc
{
    [_filterExpression release];
    [_argumentExpression release];
    [super dealloc];
}

- (void)setToken:(GRMustacheToken *)token
{
    [super setToken:token];
    _filterExpression.token = token;
    _argumentExpression.token = token;
}

- (BOOL)isEqual:(id)expression
{
    if (![expression isKindOfClass:[GRMustacheFilteredExpression class]]) {
        return NO;
    }
    if (![_filterExpression isEqual:((GRMustacheFilteredExpression *)expression).filterExpression]) {
        return NO;
    }
    return [_argumentExpression isEqual:((GRMustacheFilteredExpression *)expression).argumentExpression];
}


#pragma mark GRMustacheExpression

- (BOOL)evaluateInRuntime:(GRMustacheRuntime *)runtime value:(id *)value error:(NSError **)error
{
    id argument;
    id filter;
    
    if (![_argumentExpression evaluateInRuntime:runtime value:&argument error:error]) {
        return NO;
    }
    if (![_filterExpression evaluateInRuntime:runtime value:&filter error:error]) {
        return NO;
    }

    if (filter == nil) {
        if (error) {
            GRMustacheToken *token = self.token;
            NSString *localizedDescription = nil;
            if (token.templateID) {
                localizedDescription = [NSString stringWithFormat:@"Missing filter in tag `%@` at line %lu of template %@", token.templateSubstring, (unsigned long)token.line, token.templateID];
            } else {
                localizedDescription = [NSString stringWithFormat:@"Missing filter in tag `%@` at line %lu", token.templateSubstring, (unsigned long)token.line];
            }
            *error = [NSError errorWithDomain:GRMustacheErrorDomain code:GRMustacheErrorCodeRenderingError userInfo:[NSDictionary dictionaryWithObject:@"Missing filter" forKey:NSLocalizedDescriptionKey]];
        }
        return NO;
    }
    
    if (![filter conformsToProtocol:@protocol(GRMustacheFilter)]) {
        if (error) {
            GRMustacheToken *token = self.token;
            NSString *localizedDescription = nil;
            if (token.templateID) {
                localizedDescription = [NSString stringWithFormat:@"Object does not conform to GRMustacheFilter protocol in tag `%@` at line %lu of template %@: %@", token.templateSubstring, (unsigned long)token.line, token.templateID, filter];
            } else {
                localizedDescription = [NSString stringWithFormat:@"Object does not conform to GRMustacheFilter protocol in tag `%@` at line %lu: %@", token.templateSubstring, (unsigned long)token.line, filter];
            }
            *error = [NSError errorWithDomain:GRMustacheErrorDomain code:GRMustacheErrorCodeRenderingError userInfo:[NSDictionary dictionaryWithObject:@"Missing filter" forKey:NSLocalizedDescriptionKey]];
        }
        return NO;
    }
    
    if (_curry && [filter respondsToSelector:@selector(curryArgument:)]) {
        *value = [(id<GRMustacheFilter>)filter curryArgument:argument];
    } else {
        *value = [(id<GRMustacheFilter>)filter transformedValue:argument];
    }
    
    return YES;
}

@end
