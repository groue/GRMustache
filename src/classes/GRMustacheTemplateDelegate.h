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
#import "GRMustacheAvailabilityMacros.h"

@class GRMustacheTemplate;

enum {
    GRMustacheInterpretationFilterValue = 1 << 0,
    GRMustacheInterpretationContextValue = 1 << 1,
    GRMustacheInterpretationVariableRendering = 1 << 2,
    GRMustacheInterpretationSectionRendering = 1 << 3,
};

typedef NSUInteger GRMustacheInterpretation;

/**
 * The protocol for a GRMustacheTemplate's delegate.
 *
 * The delegate's can observe, and alter, the rendering of a template.
 *
 * **Companion guide:** https://github.com/groue/GRMustache/blob/master/Guides/delegate.md
 * 
 * @since v1.12
 */
@protocol GRMustacheTemplateDelegate<NSObject>
@optional

////////////////////////////////////////////////////////////////////////////////
/// @name Observing the Full Template Rendering
////////////////////////////////////////////////////////////////////////////////

/**
 * Sent right before a template starts rendering.
 *
 * @param template  The template that is about to render.
 *
 * @since v1.12
 */
- (void)templateWillRender:(GRMustacheTemplate *)template AVAILABLE_GRMUSTACHE_VERSION_4_0_AND_LATER;

/**
 * Sent right after a template has finished rendering.
 *
 * @param template  The template that did render.
 *
 * @since v1.12
 */
- (void)templateDidRender:(GRMustacheTemplate *)template AVAILABLE_GRMUSTACHE_VERSION_4_0_AND_LATER;


////////////////////////////////////////////////////////////////////////////////
/// @name Observing the Rendering of individual Mustache tags
////////////////////////////////////////////////////////////////////////////////

- (id)template:(GRMustacheTemplate *)template value:(id)value as:(GRMustacheInterpretation)interpretation;
- (void)template:(GRMustacheTemplate *)template willInterpretValue:(id)value as:(GRMustacheInterpretation)interpretation;
- (void)template:(GRMustacheTemplate *)template didInterpretValue:(id)value as:(GRMustacheInterpretation)interpretation;
@end
