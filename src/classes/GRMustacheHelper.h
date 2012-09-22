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
@class GRMustacheVariable;


// =============================================================================
#pragma mark - <GRMustacheSectionHelper>

/**
 * The protocol for implementing Mustache "lambda" sections.
 *
 * The responsability of a GRMustacheSectionHelper is to render a Mustache
 * section such as `{{#bold}}...{{/bold}}`.
 *
 * When the data given to a Mustache section is a GRMustacheSectionHelper,
 * GRMustache invokes the `renderSection:` method of the helper, and inserts the
 * raw return value in the template rendering.
 *
 * **Companion guide:** https://github.com/groue/GRMustache/blob/master/Guides/helpers.md
 *
 * @since v1.9
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
 */
- (NSString *)renderSection:(GRMustacheSection *)section AVAILABLE_GRMUSTACHE_VERSION_5_0_AND_LATER;
@end


// =============================================================================
#pragma mark - GRMustacheSectionHelper

/**
 * The GRMustacheSectionHelper class helps building mustache helpers without
 * writing a custom class that conforms to the GRMustacheSectionHelper protocol.
 *
 * **Companion guide:** https://github.com/groue/GRMustache/blob/master/Guides/helpers.md
 *
 * @see GRMustacheSectionHelper protocol
 *
 * @since v2.0
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
 */
+ (id)helperWithBlock:(NSString *(^)(GRMustacheSection* section))block AVAILABLE_GRMUSTACHE_VERSION_5_0_AND_LATER;

@end


// =============================================================================
#pragma mark - <GRMustacheVariableHelper>

/**
 * The protocol for implementing Mustache "lambda" sections.
 *
 * The responsability of a GRMustacheVariableHelper is to render a Mustache
 * variable tag such as `{{name}}`.
 *
 * When the data given to a Mustache variable tag is a GRMustacheVariableHelper,
 * GRMustache invokes the `renderVariable:` method of the helper, and inserts
 * the raw return value in the template rendering.
 *
 * **Companion guide:** https://github.com/groue/GRMustache/blob/master/Guides/helpers.md
 *
 * @since TODO
 */
@protocol GRMustacheVariableHelper<NSObject>
@required

////////////////////////////////////////////////////////////////////////////////
/// @name Rendering Sections
////////////////////////////////////////////////////////////////////////////////

/**
 * Returns the rendering of a Mustache variable.
 *
 * @param variable   The variable to render
 *
 * @return The rendering of the variable
 *
 * @since TODO
 */
- (NSString *)renderVariable:(GRMustacheVariable *)variable;
@end


// =============================================================================
#pragma mark - GRMustacheVariableHelper

/**
 * The GRMustacheVariableHelper class helps building mustache helpers without
 * writing a custom class that conforms to the GRMustacheVariableHelper
 * protocol.
 *
 * **Companion guide:** https://github.com/groue/GRMustache/blob/master/Guides/helpers.md
 *
 * @see GRMustacheVariableHelper protocol
 *
 * @since TODO
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
 * @since TODO
 */
+ (id)helperWithBlock:(NSString *(^)(GRMustacheVariable* variable))block;

@end


// =============================================================================
#pragma mark - GRMustacheDynamicPartial

/**
 * TODO
 *
 * **Companion guide:** https://github.com/groue/GRMustache/blob/master/Guides/helpers.md
 *
 * @see GRMustacheVariableHelper protocol
 *
 * @since TODO
 */
@interface GRMustacheDynamicPartial: NSObject<GRMustacheVariableHelper> {
    NSString *_name;
}

////////////////////////////////////////////////////////////////////////////////
/// @name Creating Dynamic Partials
////////////////////////////////////////////////////////////////////////////////

/**
 * TODO
 *
 * @since TODO
 */
+ (id)dynamicPartialWithName:(NSString *)name;

@end


// =============================================================================
#pragma mark - Compatibility layer

// TODO: mark as deprecated
@protocol GRMustacheHelper <GRMustacheSectionHelper>
@end

// TODO: mark as deprecated
@interface GRMustacheHelper: GRMustacheSectionHelper
@end
