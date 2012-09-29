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
#import "GRMustacheRenderingElement_private.h"

@class GRMustacheTemplate;

/**
 * A GRMustacheTemplateOverride is a rendering element that renders overridable
 * partials as `{{<name}}...{{/name}}`.
 *
 * It collaborates with runtimes for the resolving of rendering elements in the
 * context of Mustache overridable partials.
 *
 * @see GRMustacheRenderingElement
 * @see GRMustacheRuntime
 */
@interface GRMustacheTemplateOverride : NSObject<GRMustacheRenderingElement> {
    GRMustacheTemplate *_template;
    NSArray *_innerElements;
}

/**
 * The overridable partial template.
 *
 * This property is used by [GRMustacheRuntime assertAcyclicTemplateOverride:].
 *
 * @see GRMustacheRuntime
 */
@property (nonatomic, retain, readonly) GRMustacheTemplate *template GRMUSTACHE_API_INTERNAL;

/**
 * Builds a GRMustacheTemplateOverride.
 *
 * @param template       The partial template that is overriden
 * @param innerElements  The elements that may override elements of the
 *                       overriden partial template.
 *
 * @return A GRMustacheTemplateOverride
 */
+ (id)templateOverrideWithTemplate:(GRMustacheTemplate *)template innerElements:(NSArray *)innerElements GRMUSTACHE_API_INTERNAL;

@end
