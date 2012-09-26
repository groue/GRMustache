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

@class GRMustacheVariable;


// =============================================================================
#pragma mark - <GRMustacheVariableHelper>

/**
 * Deprecated protocol. Use GRMustacheVariableTagHelper protocol instead.
 *
 * The deprecated protocol for implementing Mustache "lambda" variable tags.
 *
 * The responsability of a GRMustacheVariableHelper is to render a Mustache
 * variable tag such as `{{name}}`.
 *
 * When the data given to a Mustache variable tag is a GRMustacheVariableHelper,
 * GRMustache invokes the `renderVariable:` method of the helper, and inserts
 * the raw return value in the template rendering.
 *
 * **Companion guide:** https://github.com/groue/GRMustache/blob/master/Guides/variable_tag_helpers.md
 *
 * @since v5.1
 * @deprecated v5.3
 *
 * @see GRMustacheVariableTagHelper
 */
@protocol GRMustacheVariableHelper<NSObject>
@required

////////////////////////////////////////////////////////////////////////////////
/// @name Rendering Variable tags
////////////////////////////////////////////////////////////////////////////////

/**
 * Returns the rendering of a Mustache variable.
 *
 * @param variable   The variable to render
 *
 * @return The rendering of the variable
 *
 * @since v5.1
 * @deprecated v5.3
 */
- (NSString *)renderVariable:(GRMustacheVariable *)variable AVAILABLE_GRMUSTACHE_VERSION_5_1_AND_LATER_BUT_DEPRECATED_IN_GRMUSTACHE_VERSION_5_3;
@end


// =============================================================================
#pragma mark - GRMustacheVariableHelper

/**
 * Deprecated class. Use GRMustacheVariableTagHelper class instead.
 *
 * The GRMustacheVariableHelper class helps building mustache helpers without
 * writing a custom class that conforms to the GRMustacheVariableHelper
 * protocol.
 *
 * **Companion guide:** https://github.com/groue/GRMustache/blob/master/Guides/variable_tag_helpers.md
 *
 * @see GRMustacheVariableTagHelper class
 *
 * @since v5.1
 * @deprecated v5.3
 */
@interface GRMustacheVariableHelper: NSObject<GRMustacheVariableHelper>

////////////////////////////////////////////////////////////////////////////////
/// @name Creating Helpers
////////////////////////////////////////////////////////////////////////////////

/**
 * Returns a GRMustacheVariableHelper object that executes the provided block
 * when rendering a variable tag.
 *
 * @param block   The block that renders a variable.
 *
 * @return a GRMustacheVariableHelper object.
 *
 * @since v5.1
 */
+ (id)helperWithBlock:(NSString *(^)(GRMustacheVariable* variable))block AVAILABLE_GRMUSTACHE_VERSION_5_1_AND_LATER_BUT_DEPRECATED_IN_GRMUSTACHE_VERSION_5_3;

@end

