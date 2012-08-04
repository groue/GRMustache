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

@class GRMustacheContext;
@class GRMustacheTemplate;
@class GRMustacheInvocation;
@class GRMustacheToken;

/**
 * The GRMustacheExpression is the protocol for objects that can provide values
 * out of the data provided by the library user.
 *
 * GRMustacheExpression instances are built by GRMustacheParser. For instance,
 * the `{{ name }}` tag would yield a GRMustacheIdentifierExpression.
 *
 * @see GRMustacheFilteredExpression
 * @see GRMustacheIdentifierExpression
 * @see GRMustacheImplicitIteratorExpression
 * @see GRMustacheScopedExpression
 */
@protocol GRMustacheExpression <NSObject>
@required

/**
 * This property stores a token whose sole purpose is to help the library user
 * debugging his templates, using the tokens' ability to output their location
 * (`{{ foo }} at line 23 of /path/to/template`).
 *
 * @see GRMustacheTemplateDelegate
 * @see [GRMustacheInvocation description]
 * @see [GRMustacheToken description]
 */
@property (nonatomic, retain) GRMustacheToken *debuggingToken;

/**
 * This method performs three jobs in the same time:
 *
 * 1. Returns the value of the expression, given a context and a filterContext.
 * 2. Invokes delegates' callbacks when appropriate for the actual expression's
 *    class.
 * 3. Processes _ioInvocation_ so that on return it contains, or not, a
 *    GRMustacheInvocation object that would provide a template's delegate
 *    with the information it needs, depending on the actual expression's
 *    class.
 *
 * @param context             A context where to look for identifiers.
 * @param filterContext       A context where to look for filters.
 * @param delegatingTemplate  A template to be used for
 *                            GRMustacheTemplateDelegate callbacks, or nil.
 * @param delegates           An array of GRMustacheTemplateDelegate instances
 *                            whose callbacks should be invoked when
 *                            appropriate, or nil.
 * @param ioInvocation        Contains a pointer to a GRMustacheInvocation, or
 *                            nil. Upon return, contains a GRMustacheInvocation,
 *                            or nil, depending on the expression.
 */
- (id)valueForContext:(GRMustacheContext *)context
        filterContext:(GRMustacheContext *)filterContext
   delegatingTemplate:(GRMustacheTemplate *)delegatingTemplate
            delegates:(NSArray *)delegates
           invocation:(GRMustacheInvocation **)ioInvocation;

@end
