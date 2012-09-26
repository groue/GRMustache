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

@class GRMustacheVariableTagRenderingContext;


// =============================================================================
#pragma mark - <GRMustacheVariableTagHelper>

/**
 * The protocol for implementing Mustache "lambda" variable tags.
 *
 * The responsability of a GRMustacheVariableTagHelper is to render a Mustache
 * variable tag such as `{{name}}`.
 *
 * When the data given to a Mustache variable tag is a GRMustacheVariableTagHelper,
 * GRMustache invokes the `renderForVariableTagInContext:` method of the helper,
 * and inserts the raw return value in the final rendering.
 *
 * **Companion guide:** https://github.com/groue/GRMustache/blob/master/Guides/variable_tag_helpers.md
 *
 * @since v5.3
 */
@protocol GRMustacheVariableTagHelper<NSObject>
@required

////////////////////////////////////////////////////////////////////////////////
/// @name Rendering Variable tags
////////////////////////////////////////////////////////////////////////////////

/**
 * Returns the rendering of a Mustache variable tag.
 *
 * @param context   A variable tag rendering context
 *
 * @return The rendering of the variable tag
 *
 * @since v5.3
 */
- (NSString *)renderForVariableTagInContext:(GRMustacheVariableTagRenderingContext *)context AVAILABLE_GRMUSTACHE_VERSION_5_3_AND_LATER;
@end


// =============================================================================
#pragma mark - GRMustacheVariableTagHelper

/**
 * The GRMustacheVariableTagHelper class helps building mustache helpers without
 * writing a custom class that conforms to the GRMustacheVariableTagHelper
 * protocol.
 *
 * **Companion guide:** https://github.com/groue/GRMustache/blob/master/Guides/variable_tag_helpers.md
 *
 * @see GRMustacheVariableTagHelper protocol
 *
 * @since v5.3
 */
@interface GRMustacheVariableTagHelper: NSObject<GRMustacheVariableTagHelper>

////////////////////////////////////////////////////////////////////////////////
/// @name Creating Helpers
////////////////////////////////////////////////////////////////////////////////

/**
 * Returns a GRMustacheVariableTagHelper object that executes the provided block
 * when rendering a variable tag.
 *
 * @param block   The block that renders a variable tag.
 *
 * @return a GRMustacheVariableTagHelper object.
 *
 * @since v5.3
 */
+ (id)helperWithBlock:(NSString *(^)(GRMustacheVariableTagRenderingContext* context))block AVAILABLE_GRMUSTACHE_VERSION_5_3_AND_LATER;

@end
