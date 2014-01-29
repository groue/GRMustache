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

#import <Foundation/Foundation.h>
#import "GRMustacheAvailabilityMacros_private.h"
#import "GRMustacheTemplateComponent_private.h"

@class GRMustachePartial;

/**
 * A GRMustachePartialOverride is a template component that renders overridable
 * partials as `{{<name}}...{{/name}}`.
 *
 * It collaborates with rendering contexts for the resolving of template
 * components in the context of Mustache overridable partials.
 *
 * @see GRMustacheTemplateComponent
 * @see GRMustacheContext
 */
@interface GRMustachePartialOverride : NSObject<GRMustacheTemplateComponent> {
@private
    GRMustachePartial *_partial;
    NSArray *_components;
}

/**
 * The overridable partial template.
 *
 * This property is used by [GRMustacheContext assertAcyclicTemplateOverride:].
 *
 * @see GRMustacheContext
 */
@property (nonatomic, retain, readonly) GRMustachePartial *partial GRMUSTACHE_API_INTERNAL;

/**
 * Builds a GRMustachePartialOverride.
 *
 * @param partial     The partial template that is overriden
 * @param components  The components that may override components of the overriden
 *                    partial template.
 *
 * @return A GRMustachePartialOverride
 */
+ (instancetype)partialOverrideWithPartial:(GRMustachePartial *)partial components:(NSArray *)components GRMUSTACHE_API_INTERNAL;

@end
