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
#import "GRMustacheEnvironment.h"
#import "GRMustacheAvailabilityMacros.h"
#import "GRMustacheTemplateDelegate.h"
#import "GRMustache.h"

/**
 The GRMustacheTemplate class provides with Mustache template rendering services.
 
 @since v1.0
 */
@interface GRMustacheTemplate: NSObject {
@private
    NSArray *_elems;
    GRMustacheTemplateOptions _options;
    id<GRMustacheTemplateDelegate> _delegate;
}

@property (nonatomic, assign) id<GRMustacheTemplateDelegate> delegate AVAILABLE_GRMUSTACHE_VERSION_1_12_AND_LATER;


//////////////////////////////////////////////////////////////////////////////////////////
/// @name Parsing and Rendering Template Strings
//////////////////////////////////////////////////////////////////////////////////////////

/**
 Parses a template string, and returns a compiled template.
 
 The behavior of the returned template is determined by [GRMustache defaultTemplateOptions].
 
 @return A GRMustacheTemplate instance
 @param templateString The template string
 @param outError If there is an error loading or parsing template and partials, upon return contains an NSError object that describes the problem.
 @see templateFromString:error:
 @since v1.0
 @deprecated v1.11
 */
+ (id)parseString:(NSString *)templateString error:(NSError **)outError AVAILABLE_GRMUSTACHE_VERSION_1_0_AND_LATER_BUT_DEPRECATED_IN_GRMUSTACHE_VERSION_1_11;

/**
 Parses a template string, and returns a compiled template.
 
 The behavior of the returned template is determined by [GRMustache defaultTemplateOptions].
 
 @return A GRMustacheTemplate instance
 @param templateString The template string
 @param outError If there is an error loading or parsing template and partials, upon return contains an NSError object that describes the problem.
 @see templateFromString:options:error:
 @see [GRMustache defaultTemplateOptions]
 @since v1.11
 */
+ (id)templateFromString:(NSString *)templateString error:(NSError **)outError AVAILABLE_GRMUSTACHE_VERSION_1_11_AND_LATER;

/**
 Parses a template string, and returns a compiled template.
 
 The behavior of the returned template is determined by the _options_ parameter, not by [GRMustache defaultTemplateOptions].
 
 For instance, you'll trigger support for the [Mustache Specification 1.1.2](https://github.com/mustache/spec) with:
 
    [GRMustacheTemplate parseString:templateString
                            options:GRMustacheTemplateOptionMustacheSpecCompatibility
                              error:NULL];
 
 @return A GRMustacheTemplate instance
 @param templateString The template string
 @param options A mask of options indicating the behavior of the template.
 @param outError If there is an error loading or parsing template and partials, upon return contains an NSError object that describes the problem.
 @see templateFromString:options:error:
 @since v1.8
 @deprecated v1.11
 */
+ (id)parseString:(NSString *)templateString options:(GRMustacheTemplateOptions)options error:(NSError **)outError AVAILABLE_GRMUSTACHE_VERSION_1_8_AND_LATER_BUT_DEPRECATED_IN_GRMUSTACHE_VERSION_1_11;

/**
 Parses a template string, and returns a compiled template.
 
 The behavior of the returned template is determined by the _options_ parameter, not by [GRMustache defaultTemplateOptions].
 
 For instance, you'll trigger support for the [Mustache Specification 1.1.2](https://github.com/mustache/spec) with:
 
 [GRMustacheTemplate templateFromString:templateString
 options:GRMustacheTemplateOptionMustacheSpecCompatibility
 error:NULL];
 
 @return A GRMustacheTemplate instance
 @param templateString The template string
 @param options A mask of options indicating the behavior of the template.
 @param outError If there is an error loading or parsing template and partials, upon return contains an NSError object that describes the problem.
 @see templateFromString:error:
 @since v1.11
 */
+ (id)templateFromString:(NSString *)templateString options:(GRMustacheTemplateOptions)options error:(NSError **)outError AVAILABLE_GRMUSTACHE_VERSION_1_11_AND_LATER;

/**
 Renders a context object from a template string.
 
 @return A string containing the rendered template
 @param object A context object used for interpreting Mustache tags
 @param templateString The template string
 @param outError If there is an error loading or parsing template and partials, upon return contains an NSError object that describes the problem.
 
 @since v1.0
 */
+ (NSString *)renderObject:(id)object fromString:(NSString *)templateString error:(NSError **)outError AVAILABLE_GRMUSTACHE_VERSION_1_0_AND_LATER;
+ (NSString *)renderObject:(id)object fromString:(NSString *)templateString options:(GRMustacheTemplateOptions)options error:(NSError **)outError AVAILABLE_GRMUSTACHE_VERSION_1_8_AND_LATER;


//////////////////////////////////////////////////////////////////////////////////////////
/// @name Parsing and Rendering Files
//////////////////////////////////////////////////////////////////////////////////////////

/**
 Parses a template file, and returns a compiled template.
 
 @return A GRMustacheTemplate instance
 @param path The path of the template
 @param outError If there is an error loading or parsing template and partials, upon return contains an NSError object that describes the problem.
 
 The template at path must be encoded in UTF8. See the GRMustacheTemplateRepository class for more encoding options.
 
 @since v1.4
 @deprecated v1.11
 */
+ (id)parseContentsOfFile:(NSString *)path error:(NSError **)outError AVAILABLE_GRMUSTACHE_VERSION_1_4_AND_LATER_BUT_DEPRECATED_IN_GRMUSTACHE_VERSION_1_11;
+ (id)parseContentsOfFile:(NSString *)path options:(GRMustacheTemplateOptions)options error:(NSError **)outError AVAILABLE_GRMUSTACHE_VERSION_1_8_AND_LATER_BUT_DEPRECATED_IN_GRMUSTACHE_VERSION_1_11;


/**
 Parses a template file, and returns a compiled template.
 
 @return A GRMustacheTemplate instance
 @param path The path of the template
 @param outError If there is an error loading or parsing template and partials, upon return contains an NSError object that describes the problem.
 
 The template at path must be encoded in UTF8. See the GRMustacheTemplateRepository class for more encoding options.
 
 @since v1.11
 */
+ (id)templateFromContentsOfFile:(NSString *)path error:(NSError **)outError AVAILABLE_GRMUSTACHE_VERSION_1_11_AND_LATER;
+ (id)templateFromContentsOfFile:(NSString *)path options:(GRMustacheTemplateOptions)options error:(NSError **)outError AVAILABLE_GRMUSTACHE_VERSION_1_11_AND_LATER;

#if !TARGET_OS_IPHONE || GRMUSTACHE_IPHONE_OS_VERSION_MAX_ALLOWED >= 40000

/**
 Parses a template file, and returns a compiled template.
 
 @return A GRMustacheTemplate instance
 @param url The URL of the template
 @param outError If there is an error loading or parsing template and partials, upon return contains an NSError object that describes the problem.
 
 The template at url must be encoded in UTF8. See the GRMustacheTemplateRepository class for more encoding options.
 
 @since v1.0
 @deprecated v1.11
 */
+ (id)parseContentsOfURL:(NSURL *)url error:(NSError **)outError AVAILABLE_GRMUSTACHE_VERSION_1_0_AND_LATER_BUT_DEPRECATED_IN_GRMUSTACHE_VERSION_1_11;
+ (id)parseContentsOfURL:(NSURL *)url options:(GRMustacheTemplateOptions)options error:(NSError **)outError AVAILABLE_GRMUSTACHE_VERSION_1_8_AND_LATER_BUT_DEPRECATED_IN_GRMUSTACHE_VERSION_1_11;

/**
 Parses a template file, and returns a compiled template.
 
 @return A GRMustacheTemplate instance
 @param url The URL of the template
 @param outError If there is an error loading or parsing template and partials, upon return contains an NSError object that describes the problem.
 
 The template at url must be encoded in UTF8. See the GRMustacheTemplateRepository class for more encoding options.
 
 @since v1.11
 */
+ (id)templateFromContentsOfURL:(NSURL *)url error:(NSError **)outError AVAILABLE_GRMUSTACHE_VERSION_1_11_AND_LATER;
+ (id)templateFromContentsOfURL:(NSURL *)url options:(GRMustacheTemplateOptions)options error:(NSError **)outError AVAILABLE_GRMUSTACHE_VERSION_1_11_AND_LATER;

#endif /* if GRMUSTACHE_BLOCKS_AVAILABLE */

/**
 Renders a context object from a file template.
 
 @return A string containing the rendered template
 @param object A context object used for interpreting Mustache tags
 @param path The path of the template
 @param outError If there is an error loading or parsing template and partials, upon return contains an NSError object that describes the problem.
 
 The template at path must be encoded in UTF8. See the GRMustacheTemplateRepository class for more encoding options.
 
 @since v1.4
 */
+ (NSString *)renderObject:(id)object fromContentsOfFile:(NSString *)path error:(NSError **)outError AVAILABLE_GRMUSTACHE_VERSION_1_4_AND_LATER;
+ (NSString *)renderObject:(id)object fromContentsOfFile:(NSString *)path options:(GRMustacheTemplateOptions)options error:(NSError **)outError AVAILABLE_GRMUSTACHE_VERSION_1_8_AND_LATER;


#if !TARGET_OS_IPHONE || GRMUSTACHE_IPHONE_OS_VERSION_MAX_ALLOWED >= 40000

/**
 Renders a context object from a file template.
 
 @return A string containing the rendered template
 @param object A context object used for interpreting Mustache tags
 @param url The URL of the template
 @param outError If there is an error loading or parsing template and partials, upon return contains an NSError object that describes the problem.
 
 The template at url must be encoded in UTF8. See the GRMustacheTemplateRepository class for more encoding options.
 
 @since v1.0
 */
+ (NSString *)renderObject:(id)object fromContentsOfURL:(NSURL *)url error:(NSError **)outError AVAILABLE_GRMUSTACHE_VERSION_1_0_AND_LATER;
+ (NSString *)renderObject:(id)object fromContentsOfURL:(NSURL *)url options:(GRMustacheTemplateOptions)options error:(NSError **)outError AVAILABLE_GRMUSTACHE_VERSION_1_8_AND_LATER;

#endif /* if GRMUSTACHE_BLOCKS_AVAILABLE */


//////////////////////////////////////////////////////////////////////////////////////////
/// @name Parsing and Rendering NSBundle Resources
//////////////////////////////////////////////////////////////////////////////////////////

/**
 Parses a bundle resource template, and returns a compiled template.
 
 @return A GRMustacheTemplate instance
 @param name The name of a bundle resource of extension "mustache"
 @param bundle The bundle where to look for the template resource
 @param outError If there is an error loading or parsing template and partials, upon return contains an NSError object that describes the problem.
 
 If you provide nil as a bundle, the resource will be looked in the main bundle.
 
 The template resource must be encoded in UTF8. See the GRMustacheTemplateRepository class for more encoding options.
 
 @since v1.0
 @deprecated v1.11
 */
+ (id)parseResource:(NSString *)name bundle:(NSBundle *)bundle error:(NSError **)outError AVAILABLE_GRMUSTACHE_VERSION_1_0_AND_LATER_BUT_DEPRECATED_IN_GRMUSTACHE_VERSION_1_11;
+ (id)parseResource:(NSString *)name bundle:(NSBundle *)bundle options:(GRMustacheTemplateOptions)options error:(NSError **)outError AVAILABLE_GRMUSTACHE_VERSION_1_8_AND_LATER_BUT_DEPRECATED_IN_GRMUSTACHE_VERSION_1_11;

/**
 Parses a bundle resource template, and returns a compiled template.
 
 @return A GRMustacheTemplate instance
 @param name The name of a bundle resource of extension "mustache"
 @param bundle The bundle where to look for the template resource
 @param outError If there is an error loading or parsing template and partials, upon return contains an NSError object that describes the problem.
 
 If you provide nil as a bundle, the resource will be looked in the main bundle.
 
 The template resource must be encoded in UTF8. See the GRMustacheTemplateRepository class for more encoding options.
 
 @since v1.11
 */
+ (id)templateFromResource:(NSString *)name bundle:(NSBundle *)bundle error:(NSError **)outError AVAILABLE_GRMUSTACHE_VERSION_1_11_AND_LATER;
+ (id)templateFromResource:(NSString *)name bundle:(NSBundle *)bundle options:(GRMustacheTemplateOptions)options error:(NSError **)outError AVAILABLE_GRMUSTACHE_VERSION_1_11_AND_LATER;

/**
 Parses a bundle resource template, and returns a compiled template.
 
 @return A GRMustacheTemplate instance
 @param name The name of a bundle resource
 @param ext The extension of the bundle resource
 @param bundle The bundle where to look for the template resource
 @param outError If there is an error loading or parsing template and partials, upon return contains an NSError object that describes the problem.
 
 If you provide nil as a bundle, the resource will be looked in the main bundle.
 
 The template resource must be encoded in UTF8. See the GRMustacheTemplateRepository class for more encoding options.
 
 @since v1.0
 @deprecated v1.11
 */
+ (id)parseResource:(NSString *)name withExtension:(NSString *)ext bundle:(NSBundle *)bundle error:(NSError **)outError AVAILABLE_GRMUSTACHE_VERSION_1_0_AND_LATER_BUT_DEPRECATED_IN_GRMUSTACHE_VERSION_1_11;
+ (id)parseResource:(NSString *)name withExtension:(NSString *)ext bundle:(NSBundle *)bundle options:(GRMustacheTemplateOptions)options error:(NSError **)outError AVAILABLE_GRMUSTACHE_VERSION_1_8_AND_LATER_BUT_DEPRECATED_IN_GRMUSTACHE_VERSION_1_11;

/**
 Parses a bundle resource template, and returns a compiled template.
 
 @return A GRMustacheTemplate instance
 @param name The name of a bundle resource
 @param ext The extension of the bundle resource
 @param bundle The bundle where to look for the template resource
 @param outError If there is an error loading or parsing template and partials, upon return contains an NSError object that describes the problem.
 
 If you provide nil as a bundle, the resource will be looked in the main bundle.
 
 The template resource must be encoded in UTF8. See the GRMustacheTemplateRepository class for more encoding options.
 
 @since v1.11
 */
+ (id)templateFromResource:(NSString *)name withExtension:(NSString *)ext bundle:(NSBundle *)bundle error:(NSError **)outError AVAILABLE_GRMUSTACHE_VERSION_1_11_AND_LATER;
+ (id)templateFromResource:(NSString *)name withExtension:(NSString *)ext bundle:(NSBundle *)bundle options:(GRMustacheTemplateOptions)options error:(NSError **)outError AVAILABLE_GRMUSTACHE_VERSION_1_11_AND_LATER;


/**
 Renders a context object from a bundle resource template.
 
 @return A string containing the rendered template
 @param object A context object used for interpreting Mustache tags
 @param name The name of a bundle resource of extension "mustache"
 @param bundle The bundle where to look for the template resource
 @param outError If there is an error loading or parsing template and partials, upon return contains an NSError object that describes the problem.
 
 If you provide nil as a bundle, the resource will be looked in the main bundle.
 
 The template resource must be encoded in UTF8. See the GRMustacheTemplateRepository class for more encoding options.
 
 @since v1.0
 */
+ (NSString *)renderObject:(id)object fromResource:(NSString *)name bundle:(NSBundle *)bundle error:(NSError **)outError AVAILABLE_GRMUSTACHE_VERSION_1_0_AND_LATER;
+ (NSString *)renderObject:(id)object fromResource:(NSString *)name bundle:(NSBundle *)bundle options:(GRMustacheTemplateOptions)options error:(NSError **)outError AVAILABLE_GRMUSTACHE_VERSION_1_8_AND_LATER;

/**
 Renders a context object from a bundle resource template.
 
 @return A string containing the rendered template
 @param object A context object used for interpreting Mustache tags
 @param name The name of a bundle resource
 @param ext The extension of the bundle resource
 @param bundle The bundle where to look for the template resource.
 @param outError If there is an error loading or parsing template and partials, upon return contains an NSError object that describes the problem.
 
 If you provide nil as a bundle, the resource will be looked in the main bundle.
 
 The template resource must be encoded in UTF8. See the GRMustacheTemplateRepository class for more encoding options.
 
 @since v1.0
 */
+ (NSString *)renderObject:(id)object fromResource:(NSString *)name withExtension:(NSString *)ext bundle:(NSBundle *)bundle error:(NSError **)outError AVAILABLE_GRMUSTACHE_VERSION_1_0_AND_LATER;
+ (NSString *)renderObject:(id)object fromResource:(NSString *)name withExtension:(NSString *)ext bundle:(NSBundle *)bundle options:(GRMustacheTemplateOptions)options error:(NSError **)outError AVAILABLE_GRMUSTACHE_VERSION_1_8_AND_LATER;


//////////////////////////////////////////////////////////////////////////////////////////
/// @name Rendering a Parsed Template
//////////////////////////////////////////////////////////////////////////////////////////

/**
 Renders a template with a context object.
 
 @return A string containing the rendered template
 @param object A context object used for interpreting Mustache tags
 
 @since v1.0
 */
- (NSString *)renderObject:(id)object AVAILABLE_GRMUSTACHE_VERSION_1_0_AND_LATER;

/**
 Renders a template with context objects.
 
 @return A string containing the rendered template
 @param object, ... A comma-separated list of objects used for interpreting Mustache tags, ending with nil
 
 @since v1.5
 */
- (NSString *)renderObjects:(id)object, ... AVAILABLE_GRMUSTACHE_VERSION_1_5_AND_LATER;

/**
 Renders a template without any context object for interpreting Mustache tags.
 
 @return A string containing the rendered template
 
 @since v1.0
 */
- (NSString *)render AVAILABLE_GRMUSTACHE_VERSION_1_0_AND_LATER;

@end
