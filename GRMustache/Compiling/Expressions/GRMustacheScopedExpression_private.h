// The MIT License
// 
// Copyright (c) 2014 Gwendal Roué
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

/**
 * The GRMustacheScopedExpression represents expressions such as
 * `<expression>.identifier`.
 */
@interface GRMustacheScopedExpression : GRMustacheExpression
@property (nonatomic, retain, readonly) GRMustacheExpression *baseExpression GRMUSTACHE_API_INTERNAL;
@property (nonatomic, retain, readonly) NSString *identifier GRMUSTACHE_API_INTERNAL;

/**
 * Returns a scoped expression, given an expression that returns a value, and
 * an identifier.
 *
 * For example, the Mustache tag `{{ person.name }}` contains a scoped
 * expression, whose baseExpression is a GRMustacheIdentifierExpression (for the
 * identifier `person`), and whose identifier is `name`.
 *
 * @param baseExpression   An expression.
 * @param identifier       An identifier.
 *
 * @return A GRMustacheScopedExpression.
 */
+ (instancetype)expressionWithBaseExpression:(GRMustacheExpression *)baseExpression identifier:(NSString *)identifier GRMUSTACHE_API_INTERNAL;
@end
