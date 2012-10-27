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
@class GRMustacheInvocation;
@class GRMustacheTag;

/**
 * The protocol for a GRMustacheTemplate's delegate.
 *
 * The delegate's can observe, and alter, the rendering of a template.
 *
 * **Companion guide:** https://github.com/groue/GRMustache/blob/master/Guides/delegate.md
 * 
 * @since v1.12
 */
@protocol GRMustacheTagDelegate<NSObject>
@optional


////////////////////////////////////////////////////////////////////////////////
/// @name Observing the Rendering of individual Mustache tags
////////////////////////////////////////////////////////////////////////////////

/**
 * Sent right before GRMustache renders an object.
 *
 * @param tag             The mustache tag about to render.
 * @param invocation      The object about to be rendered.
 *
 * @return the object that should be rendered.
 *
 * @since v6.0
 */
- (id)mustacheTag:(GRMustacheTag *)tag willRenderObject:(id)object AVAILABLE_GRMUSTACHE_VERSION_6_0_AND_LATER;

/**
 * Sent right after GRMustache has rendered an object.
 *
 * @param tag             The mustache tag that did render.
 * @param invocation      The rendered object.
 *
 * @since v6.0
 */
- (void)mustacheTag:(GRMustacheTag *)tag didRenderObject:(id)object AVAILABLE_GRMUSTACHE_VERSION_6_0_AND_LATER;

@end
