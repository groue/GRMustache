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

/**
 * The GRMustacheFilteredExpression is able to apply a filter to a value, and
 * to return the result.
 *
 * @see GRMustacheExpression
 * @see GRMustacheFilter
 */
@interface GRMustacheFilteredExpression : GRMustacheExpression {
@private
    GRMustacheExpression *_filterExpression;
    GRMustacheExpression *_parameterExpression;
}

/**
 * Returns a filtered expression, given an expression that returns a filter, and
 * an expression that return the filter parameter.
 *
 * For instance, the Mustache tag `{{ f(x) }}` contains a filtered expression,
 * whose filterExpression is a GRMustacheIdentifierExpression (for the
 * identifier `f`), and whose parameterExpression is a
 * GRMustacheIdentifierExpression (for the identifier `x`).
 *
 * @param filterExpression     An expression whose value is an object conforming
 *                             to the <GRMustacheFilter> protocol.
 * @param parameterExpression  An expression whose value is the parameter of the
 *                             filter.
 *
 * @return A GRMustacheFilteredExpression.
 */
+ (id)expressionWithFilterExpression:(GRMustacheExpression *)filterExpression parameterExpression:(GRMustacheExpression *)parameterExpression GRMUSTACHE_API_INTERNAL;
@end
