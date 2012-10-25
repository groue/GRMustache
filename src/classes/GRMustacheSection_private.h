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
#import "GRMustacheRenderingObject_private.h"

@class GRMustacheExpression;

/**
 * A GRMustacheSection is a rendering element that renders sections
 * such as `{{#name}}...{{/name}}`.
 *
 * @see GRMustacheRenderingElement
 */
@interface GRMustacheSection: NSObject<GRMustacheRenderingElement, GRMustacheRenderingObject> {
@private
    GRMustacheExpression *_expression;
    NSString *_templateString;
    NSRange _innerRange;
    BOOL _overridable;
    BOOL _inverted;
    NSArray *_innerElements;
}

// Documented in GRMustacheSection.h
@property (nonatomic, readonly, getter = isInverted) BOOL inverted GRMUSTACHE_API_PUBLIC;

// Documented in GRMustacheSection.h
@property (nonatomic, readonly, getter = isOverridable) BOOL overridable GRMUSTACHE_API_PUBLIC;

/**
 * The literal inner content of the section, with unprocessed Mustache
 * `{{tags}}`.
 */
@property (nonatomic, readonly) NSString *innerTemplateString GRMUSTACHE_API_INTERNAL;


/**
 * Builds a GRMustacheSection.
 * 
 * The rendering of Mustache sections depend on the value they are attached to,
 * whether they are truthy, falsey, enumerable, or helpers. The value is fetched
 * by evaluating the _expression_ parameter against a runtime.
 *
 * The _innerElements_ array contains the GRMustacheRenderingElement objects
 * that make the section (texts, variables, other sections, etc.)
 * 
 * @param expression          The expression that would evaluate against a
 *                            runtime.
 * @param templateString      A Mustache template string
 * @param innerRange          The range of the inner template string of the
 *                            section in _templateString_, that allows helpers
 *                            to get the section's inner template string through
 *                            GRMustacheSectionTagRenderingContext objects.
 * @param inverted            YES if the section is {{^inverted}}.
 *                            Otherwise, NO.
 * @param overridable         YES if the section can override another section,
 *                            or be overriden, in the context of overridable
 *                            partials.
 * @param innerElements       An array of GRMustacheRenderingElement that make
 *                            the section.
 *
 * @return A GRMustacheSection
 * 
 * @see GRMustacheExpression
 * @see GRMustacheRuntime
 * @see GRMustacheSectionTagRenderingContext
 * @see GRMustacheRuntime
 * @see GRMustacheSectionTagHelper protocol
 */
+ (id)sectionWithExpression:(GRMustacheExpression *)expression templateString:(NSString *)templateString innerRange:(NSRange)innerRange inverted:(BOOL)inverted overridable:(BOOL)overridable innerElements:(NSArray *)innerElements GRMUSTACHE_API_INTERNAL;

@end
