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
#import "GRMustacheAvailabilityMacros.h"

//! Project version number for GRMustache.
FOUNDATION_EXPORT double GRMustacheVersionNumber;

//! Project version string for GRMustache.
FOUNDATION_EXPORT const unsigned char GRMustacheVersionString[];


/**
 * The GRMustache class provides with global-level information and configuration
 * of the GRMustache library.
 *
 * @since v1.0
 */
@interface GRMustache: NSObject


////////////////////////////////////////////////////////////////////////////////
/// @name Standard Library
////////////////////////////////////////////////////////////////////////////////

/**
 * @return The GRMustache standard `each`.
 *
 * **Companion guide:** https://github.com/groue/GRMustache/blob/master/Guides/standard_library.md
 *
 * @since v8.0
 */
+ (id)standardEach AVAILABLE_GRMUSTACHE_VERSION_8_0_AND_LATER;

/**
 * @return The GRMustache standard `HTMLEscape`.
 *
 * **Companion guide:** https://github.com/groue/GRMustache/blob/master/Guides/standard_library.md
 *
 * @since v8.0
 */
+ (id)standardHTMLEscape AVAILABLE_GRMUSTACHE_VERSION_8_0_AND_LATER;

/**
 * @return The GRMustache standard `URLEscape`.
 *
 * **Companion guide:** https://github.com/groue/GRMustache/blob/master/Guides/standard_library.md
 *
 * @since v8.0
 */
+ (id)standardURLEscape AVAILABLE_GRMUSTACHE_VERSION_8_0_AND_LATER;

/**
 * @return The GRMustache standard `javascriptEscape`.
 *
 * **Companion guide:** https://github.com/groue/GRMustache/blob/master/Guides/standard_library.md
 *
 * @since v8.0
 */
+ (id)standardJavascriptEscape AVAILABLE_GRMUSTACHE_VERSION_8_0_AND_LATER;

/**
 * @return The GRMustache standard `zip`.
 *
 * **Companion guide:** https://github.com/groue/GRMustache/blob/master/Guides/standard_library.md
 *
 * @since v8.0
 */
+ (id)standardZip AVAILABLE_GRMUSTACHE_VERSION_8_0_AND_LATER;

@end

#import "GRMustacheTemplate.h"
#import "GRMustacheTagDelegate.h"
#import "GRMustacheTemplateRepository.h"
#import "GRMustacheFilter.h"
#import "GRMustacheError.h"
#import "GRMustacheContentType.h"
#import "GRMustacheContext.h"
#import "GRMustacheRendering.h"
#import "GRMustacheTag.h"
#import "GRMustacheConfiguration.h"
#import "GRMustacheLocalizer.h"
#import "GRMustacheKeyValueCoding.h"
#import "NSValueTransformer+GRMustache.h"
#import "NSFormatter+GRMustache.h"
