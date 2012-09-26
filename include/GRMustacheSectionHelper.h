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

@class GRMustacheSection;


// =============================================================================
#pragma mark - <GRMustacheSectionHelper>

/**
 * Deprecated protocol. Use GRMustacheSectionTagHelper protocol instead.
 *
 * The deprecated protocol for implementing Mustache "lambda" sections.
 *
 * The responsability of a GRMustacheSectionHelper is to render a Mustache
 * section such as `{{#bold}}...{{/bold}}`.
 *
 * When the data given to a Mustache section is a GRMustacheSectionHelper,
 * GRMustache invokes the `renderSection:` method of the helper, and inserts the
 * raw return value in the template rendering.
 *
 * **Companion guide:** https://github.com/groue/GRMustache/blob/master/Guides/section_tag_helpers.md
 *
 * @since v1.9
 * @deprecated v5.3
 *
 * @see GRMustacheSectionTagHelper
 */
@protocol GRMustacheSectionHelper<NSObject>
@required

////////////////////////////////////////////////////////////////////////////////
/// @name Rendering Sections
////////////////////////////////////////////////////////////////////////////////

/**
 * Returns the rendering of a Mustache section.
 *
 * @param section   The section to render
 *
 * @return The rendering of the section
 *
 * @since v2.0
 * @deprecated v5.3
 */
- (NSString *)renderSection:(GRMustacheSection *)section AVAILABLE_GRMUSTACHE_VERSION_5_1_AND_LATER_BUT_DEPRECATED_IN_GRMUSTACHE_VERSION_5_3;
@end


// =============================================================================
#pragma mark - GRMustacheSectionHelper

/**
 * Deprecated class. Use GRMustacheSectionTagHelper class instead.
 *
 * The GRMustacheSectionHelper class helps building mustache helpers without
 * writing a custom class that conforms to the GRMustacheSectionHelper protocol.
 *
 * **Companion guide:** https://github.com/groue/GRMustache/blob/master/Guides/section_tag_helpers.md
 *
 * @see GRMustacheSectionTagHelper protocol
 *
 * @since v2.0
 * @deprecated v5.3
 */
@interface GRMustacheSectionHelper: NSObject<GRMustacheSectionHelper>

////////////////////////////////////////////////////////////////////////////////
/// @name Creating Helpers
////////////////////////////////////////////////////////////////////////////////

/**
 * Returns a GRMustacheSectionHelper object that executes the provided block
 * when rendering a section tag.
 *
 * @param block   The block that renders a section.
 *
 * @return a GRMustacheSectionHelper object.
 *
 * @since v2.0
 * @deprecated v5.3
 */
+ (id)helperWithBlock:(NSString *(^)(GRMustacheSection* section))block AVAILABLE_GRMUSTACHE_VERSION_5_1_AND_LATER_BUT_DEPRECATED_IN_GRMUSTACHE_VERSION_5_3;

@end


// =============================================================================
#pragma mark - Compatibility with deprecated declarations

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
/**
 * Deprecated. Use GRMustacheSectionHelper instead.
 *
 * @since v1.9
 * @deprecated v5.1
 */
AVAILABLE_GRMUSTACHE_VERSION_5_0_AND_LATER_BUT_DEPRECATED_IN_GRMUSTACHE_VERSION_5_1
@protocol GRMustacheHelper <GRMustacheSectionHelper>
@end
#pragma clang diagnostic pop

/**
 * Deprecated. Use GRMustacheSectionHelper instead.
 *
 * @since v2.0
 * @deprecated v5.1
 */
AVAILABLE_GRMUSTACHE_VERSION_5_0_AND_LATER_BUT_DEPRECATED_IN_GRMUSTACHE_VERSION_5_1
@interface GRMustacheHelper: GRMustacheSectionHelper
+ (id)helperWithBlock:(NSString *(^)(GRMustacheSection* section))block;
@end
