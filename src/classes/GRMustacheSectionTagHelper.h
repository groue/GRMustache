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
- (NSString *)renderForSectionTagInContext:(GRMustacheSectionTagRenderingContext *)context AVAILABLE_GRMUSTACHE_VERSION_6_0_AND_LATER;
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
+ (id)helperWithBlock:(NSString *(^)(GRMustacheSectionTagRenderingContext* context))block AVAILABLE_GRMUSTACHE_VERSION_6_0_AND_LATER;

@end



// =============================================================================
#pragma mark - GRMustacheSectionTagRenderingContext

/**
 * You will be provided with GRMustacheSectionTagRenderingContext objects when
 * implementing section tag helpers with objects conforming to the
 * GRMustacheSectionTagHelper protocol.
 *
 * **Companion guide:** https://github.com/groue/GRMustache/blob/master/Guides/section_tag_helpers.md
 *
 * @see GRMustacheSectionTagHelper protocol
 *
 * @since v5.3
 */
@interface GRMustacheSectionTagRenderingContext: NSObject {
@private
    id _sectionElement;
    id _runtime;
}



////////////////////////////////////////////////////////////////////////////////
/// @name Accessing the literal inner content
////////////////////////////////////////////////////////////////////////////////

/**
 * The literal inner content of the section, with unprocessed Mustache
 * `{{tags}}`.
 *
 * @since v5.3
 */
@property (nonatomic, readonly) NSString *innerTemplateString AVAILABLE_GRMUSTACHE_VERSION_6_0_AND_LATER;


////////////////////////////////////////////////////////////////////////////////
/// @name Rendering the inner content
////////////////////////////////////////////////////////////////////////////////

/**
 * Renders the inner content of the receiver with the current rendering context.
 *
 * @return A string containing the rendering.
 *
 * @since v5.3
 */
- (NSString *)render AVAILABLE_GRMUSTACHE_VERSION_6_0_AND_LATER;

/**
 * Renders the inner content of the receiver with the current rendering context,
 * augmented by _object_.
 *
 * @param object   An object used for interpreting Mustache tags.
 *
 * @return A string containing the rendering.
 *
 * @since v6.0
 */
- (NSString *)renderObject:(id)object AVAILABLE_GRMUSTACHE_VERSION_6_0_AND_LATER;

/**
 * Renders the inner content of the receiver with the current rendering context,
 * augmented by _object_ and _filters_.
 *
 * @param object   An object used for interpreting Mustache tags.
 * @param filters  An object that provides custom filters.
 *
 * @return A string containing the rendering.
 *
 * @since v6.0
 */
- (NSString *)renderObject:(id)object withFilters:(id)filters AVAILABLE_GRMUSTACHE_VERSION_6_0_AND_LATER;


////////////////////////////////////////////////////////////////////////////////
/// @name Rendering another template string
////////////////////////////////////////////////////////////////////////////////

/**
 * Renders a template string with the current rendering context.
 *
 * @param string    A template string
 * @param outError  If there is an error loading or parsing template and
 *                  partials, upon return contains an NSError object that
 *                  describes the problem.
 *
 * @return A string containing the rendering of the template string.
 *
 * @since v6.0
 */
- (NSString *)renderString:(NSString *)string error:(NSError **)outError AVAILABLE_GRMUSTACHE_VERSION_6_0_AND_LATER;

/**
 * Renders a template string with the current rendering context, augmented by
 * _object_.
 *
 * @param object          An object used for interpreting Mustache tags.
 * @param templateString  A template string
 * @param outError        If there is an error loading or parsing template and
 *                        partials, upon return contains an NSError object that
 *                        describes the problem.
 *
 * @return A string containing the rendering of the template string.
 *
 * @since v6.0
 */
- (NSString *)renderObject:(id)object fromString:(NSString *)templateString error:(NSError **)outError;

/**
 * Renders a template string with the current rendering context, augmented by
 * _object_ and _filters_.
 *
 * @param object          An object used for interpreting Mustache tags.
 * @param filters         An object that provides custom filters.
 * @param templateString  A template string
 * @param outError        If there is an error loading or parsing template and
 *                        partials, upon return contains an NSError object that
 *                        describes the problem.
 *
 * @return A string containing the rendering of the template string.
 *
 * @since v6.0
 */
- (NSString *)renderObject:(id)object withFilters:(id)filters fromString:(NSString *)templateString error:(NSError **)outError;

@end
