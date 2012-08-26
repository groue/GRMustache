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

/**
 * TODO
 *
 * The protocol for "rendering elements".
 * 
 * When parsing a Mustache template, GRMustacheCompiler builds a syntax
 * tree of objects representing raw text and various mustache tags.
 * 
 * This syntax tree is made of objects conforming to the
 * GRMustacheRenderingElement.
 * 
 * Their responsability is to render the data provided by the library user. This
 * data is encapsulated into GRMustacheContext objects, which represent a
 * context stack that grows when entering a Mustache {{#section}}, and shrinks
 * when leaving that same {{/section}}.
 * 
 * For instance, the template string "hello {{name}}!" would give four rendering
 * elements:
 *
 * - a GRMustacheTextElement that renders "hello ".
 * - a GRMustacheVariableElement that renders the `name` key in a context.
 * - a GRMustacheTextElement that renders "!".
 * - a GRMustacheTemplate that would contain the three previous elements, and
 *   render the concatenation of their renderings.
 * 
 * @see GRMustacheCompiler
 * @see GRMustacheContext
 */
@protocol GRMustacheRenderingElement<NSObject>
@required

/**
 * TODO
 * Renders.
 * 
 * @param renderingContext    A rendering context stack.
 * @param filterContext       A filters context stack.
 * @param delegatingTemplate  A template.
 * @param delegates           An array of GRMustacheTemplateDelegate objects
 *                            whose callbacks should be called whenever
 *                            relevant, with _delegatingTemplate_ as a template.
 *
 * @return The rendering.
 */
- (NSString *)renderInRuntime:(GRMustacheRuntime *)runtime GRMUSTACHE_API_INTERNAL;
@end
