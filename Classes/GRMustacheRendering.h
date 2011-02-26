// The MIT License
// 
// Copyright (c) 2010 Gwendal Roué
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

#import "GRMustacheTemplate.h"
#import "GRMustacheSection.h"


@interface GRMustacheSection(Rendering)
- (NSString *)renderObject:(id)object;
@end

@interface GRMustacheTemplate(Rendering)

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Rendering
//////////////////////////////////////////////////////////////////////////////////////////

/**
 Renders a context object from a template string
 
 @returns A string containing the rendered template
 @param object A context object used for interpreting Mustache tags
 @param templateString The template string
 @param outError If there is an error loading or parsing template and partials, upon return
 contains an NSError object that describes the problem.
 
 @since v1.0.0
 */
+ (NSString *)renderObject:(id)object fromString:(NSString *)templateString error:(NSError **)outError;

#if !TARGET_OS_IPHONE || __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
/**
 Renders a context object from a file template.
 
 @returns A string containing the rendered template
 @param object A context object used for interpreting Mustache tags
 @param url The URL of the template
 @param outError If there is an error loading or parsing template and partials, upon return
 contains an NSError object that describes the problem.
 
 The template at url must be encoded in UTF8. See the GRMustacheTemplateLoader class for more encoding options.
 
 @since v1.0.0
 */
+ (NSString *)renderObject:(id)object fromContentsOfURL:(NSURL *)url error:(NSError **)outError;
#endif

/**
 Renders a context object from a file template.
 
 @returns A string containing the rendered template
 @param object A context object used for interpreting Mustache tags
 @param path The path of the template
 @param outError If there is an error loading or parsing template and partials, upon return
 contains an NSError object that describes the problem.
 
 The template at path must be encoded in UTF8. See the GRMustacheTemplateLoader class for more encoding options.
 
 @since v1.4.0
 */
+ (NSString *)renderObject:(id)object fromContentsOfFile:(NSString *)path error:(NSError **)outError;

/**
 Renders a context object from a bundle resource template.
 
 @returns A string containing the rendered template
 @param object A context object used for interpreting Mustache tags
 @param name The name of a bundle resource of extension "mustache"
 @param bundle The bundle where to look for the template resource
 @param outError If there is an error loading or parsing template and partials, upon return
 contains an NSError object that describes the problem.
 
 If you provide nil as a bundle, the resource will be looked in the main bundle.
 
 The template resource must be encoded in UTF8. See the GRMustacheTemplateLoader class for more encoding options.
 
 @since v1.0.0
 */
+ (NSString *)renderObject:(id)object fromResource:(NSString *)name bundle:(NSBundle *)bundle error:(NSError **)outError;

/**
 Renders a context object from a bundle resource template.
 
 @returns A string containing the rendered template
 @param object A context object used for interpreting Mustache tags
 @param name The name of a bundle resource
 @param ext The extension of the bundle resource
 @param bundle The bundle where to look for the template resource.
 @param outError If there is an error loading or parsing template and partials, upon return
 contains an NSError object that describes the problem.
 
 If you provide nil as a bundle, the resource will be looked in the main bundle.
 
 The template resource must be encoded in UTF8. See the GRMustacheTemplateLoader class for more encoding options.
 
 @since v1.0.0
 */
+ (NSString *)renderObject:(id)object fromResource:(NSString *)name withExtension:(NSString *)ext bundle:(NSBundle *)bundle error:(NSError **)outError;

/**
 Renders a template with a context object.
 
 @returns A string containing the rendered template
 @param object A context object used for interpreting Mustache tags
 
 @since v1.0.0
 */
- (NSString *)renderObject:(id)object;

/**
 Renders a template without any context object for interpreting Mustache tags.
 
 @returns A string containing the rendered template
 
 @since v1.0.0
 */
- (NSString *)render;

@end
