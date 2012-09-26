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

#import <Foundation/Foundation.h>
#import "GRMustacheAvailabilityMacros_private.h"

@class GRMustacheRuntime;
@class GRMustacheToken;

/**
 * The GRMustacheExpression is the base class for objects that can provide
 * values out of a Mustache runtime.
 *
 * GRMustacheExpression instances are built by GRMustacheParser. For instance,
 * the `{{ name }}` tag would yield a GRMustacheIdentifierExpression.
 *
 * @see GRMustacheFilteredExpression
 * @see GRMustacheIdentifierExpression
 * @see GRMustacheImplicitIteratorExpression
 * @see GRMustacheScopedExpression
 */
@interface GRMustacheExpression : NSObject {
@private
    GRMustacheToken *_token;
}

/**
 * This property stores a token whose sole purpose is to help the library user
 * debugging his templates, using the token's ability to output its location
 * (`{{ foo }}` at line 23 of /path/to/template).
 *
 * @see GRMustacheInvocation
 */
@property (nonatomic, retain) GRMustacheToken *token GRMUSTACHE_API_INTERNAL;

/**
 * Evaluates an expression against a runtime, and return the value.
 *
 * @param runtime       A Mustache runtime object
 * @param filterValue   The expression evaluates in the runtime's context stack,
 *                      or filter stack, depending on this boolean.
 *
 * @return The value of the expression.
 */
- (id)evaluateInRuntime:(GRMustacheRuntime *)runtime asFilterValue:(BOOL)filterValue GRMUSTACHE_API_INTERNAL;

/**
 * Returns a Boolean value that indicates whether the receiver and a given
 * object are equal.
 *
 * Expressions are equal if and only if the result of their
 * `evaluateInRuntime:asFilterValue:` implementation would return the same value
 * for all runtimes.
 *
 * Default implementation is NSObject's one: subclasses must override.
 *
 * @param anObject  The object to be compared to the receiver.
 *
 * @return YES if the receiver and anObject are equal, otherwise NO.
 */
- (BOOL)isEqual:(id)anObject; // no availability macro for Foundation method declaration
@end
