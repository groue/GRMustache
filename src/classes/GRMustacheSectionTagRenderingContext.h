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
@property (nonatomic, readonly) NSString *innerTemplateString AVAILABLE_GRMUSTACHE_VERSION_5_3_AND_LATER;


////////////////////////////////////////////////////////////////////////////////
/// @name Rendering the inner content
////////////////////////////////////////////////////////////////////////////////

/**
 * Renders the inner content of the receiver with the current rendering context.
 * 
 * @return A string containing the rendered inner content.
 *
 * @since v5.3
 */
- (NSString *)render AVAILABLE_GRMUSTACHE_VERSION_5_3_AND_LATER;


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
 * @since v5.3
 */
- (NSString *)renderTemplateString:(NSString *)string error:(NSError **)outError AVAILABLE_GRMUSTACHE_VERSION_5_3_AND_LATER;

@end
