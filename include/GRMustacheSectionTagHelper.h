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

@class GRMustacheSectionTagRenderingContext;


// =============================================================================
#pragma mark - <GRMustacheSectionTagHelper>

/**
 * The protocol for implementing Section tag helpers.
 *
 * The responsability of a GRMustacheSectionTagHelper is to render a Mustache
 * section such as `{{#bold}}...{{/bold}}`.
 *
 * When the data given to a Mustache section is a GRMustacheSectionTagHelper,
 * GRMustache invokes the `renderForSectionTagInContext:` method of the helper,
 * and inserts the raw return value in the final rendering.
 *
 * **Companion guide:** https://github.com/groue/GRMustache/blob/master/Guides/section_tag_helpers.md
 *
 * @since v5.3
 */
@protocol GRMustacheSectionTagHelper<NSObject>
@required

////////////////////////////////////////////////////////////////////////////////
/// @name Rendering Sections
////////////////////////////////////////////////////////////////////////////////

/**
 * Returns the rendering of a Mustache section.
 *
 * @param context   A section tag rendering context
 *
 * @return The rendering of the section
 *
 * @since v5.3
 */
- (NSString *)renderForSectionTagInContext:(GRMustacheSectionTagRenderingContext *)context AVAILABLE_GRMUSTACHE_VERSION_5_3_AND_LATER;
@end


// =============================================================================
#pragma mark - GRMustacheSectionTagHelper

/**
 * The GRMustacheSectionTagHelper class helps building mustache helpers without
 * writing a custom class that conforms to the GRMustacheSectionTagHelper protocol.
 *
 * **Companion guide:** https://github.com/groue/GRMustache/blob/master/Guides/section_tag_helpers.md
 *
 * @see GRMustacheSectionTagHelper protocol
 *
 * @since v5.3
 */ 
@interface GRMustacheSectionTagHelper: NSObject<GRMustacheSectionTagHelper>

////////////////////////////////////////////////////////////////////////////////
/// @name Creating Helpers
////////////////////////////////////////////////////////////////////////////////

/**
 * Returns a GRMustacheSectionTagHelper object that executes the provided block
 * when rendering a Mustache section.
 *
 * @param block   The block that renders a section.
 *
 * @return a GRMustacheSectionTagHelper object.
 *
 * @since v5.3
 */
+ (id)helperWithBlock:(NSString *(^)(GRMustacheSectionTagRenderingContext* context))block AVAILABLE_GRMUSTACHE_VERSION_5_3_AND_LATER;

@end

