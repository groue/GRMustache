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

#import "GRMustacheAvailabilityMacros_private.h"
#import "GRMustacheRenderingElement_private.h"

@class GRMustacheExpression;
@class GRMustacheTemplateRepository;
@class GRMustacheSection;

/**
 * A GRMustacheVariableElement is a rendering element that renders variable
 * tags such as `{{name}}` and `{{{name}}}`.
 *
 * For instance, the template string "{{name}} is {{age}} years old." would give
 * two GRMustacheVariableElement instances:
 *
 * - a GRMustacheVariableElement that renders the `name` key in a context.
 * - a GRMustacheVariableElement that renders the `age` key in a context.
 *
 * @see GRMustacheRenderingElement
 */
@interface GRMustacheVariableElement: NSObject<GRMustacheRenderingElement> {
@private
    GRMustacheTemplateRepository *_templateRepository;
    GRMustacheExpression *_expression;
    GRMustacheSection *_enumerableSection;
    BOOL _raw;
}

/**
 * Builds and returns a GRMustacheVariableElement.
 *
 * @param expression  The expression that would evaluate against a runtime.
 * @param raw         NO if the value should be rendered HTML-escaped.
 *
 * @return a GRMustacheVariableElement
 *
 * @see GRMustacheExpression
 */
+ (id)variableElementWithExpression:(GRMustacheExpression *)expression templateRepository:(GRMustacheTemplateRepository *)templateRepository raw:(BOOL)raw GRMUSTACHE_API_INTERNAL;

@end
