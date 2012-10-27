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
#import "GRMustacheTagDelegate.h"

@class GRMustacheContext;

/**
 * The GRMustacheTemplate class provides with Mustache template rendering
 * services.
 * 
 * **Companion guide:** https://github.com/groue/GRMustache/blob/master/Guides/templates.md
 * 
 * @since v1.0
 */
@interface GRMustacheTemplate: NSObject {
@private
    NSArray *_components;
    id<GRMustacheTagDelegate> _tagDelegate;
}

////////////////////////////////////////////////////////////////////////////////
/// @name Setting the Tag Delegate
////////////////////////////////////////////////////////////////////////////////

/**
 * The template's default tag delegate.
 *
 * **Companion guide:** https://github.com/groue/GRMustache/blob/master/Guides/delegate.md
 *
 * @see GRMustacheTagDelegate
 * 
 * @since v1.12
 */
 
@property (nonatomic, assign) id<GRMustacheTagDelegate> tagDelegate AVAILABLE_GRMUSTACHE_VERSION_6_0_AND_LATER;


////////////////////////////////////////////////////////////////////////////////
/// @name Template Strings
////////////////////////////////////////////////////////////////////////////////

/**
 * Parses a template string, and returns a compiled template.
 * 
 * @param templateString  The template string.
 * @param error           If there is an error loading or parsing template and
 *                        partials, upon return contains an NSError object that
 *                        describes the problem.
 *
 * @return A GRMustacheTemplate instance.
 *
 * @since v1.11
 */
+ (id)templateFromString:(NSString *)templateString error:(NSError **)error AVAILABLE_GRMUSTACHE_VERSION_6_0_AND_LATER;


////////////////////////////////////////////////////////////////////////////////
/// @name Template Files
////////////////////////////////////////////////////////////////////////////////

/**
 * Parses a template file, and returns a compiled template.
 *
 * The template at path must be encoded in UTF8. See the
 * GRMustacheTemplateRepository class for more encoding options.
 *
 * @param path      The path of the template.
 * @param error     If there is an error loading or parsing template and
 *                  partials, upon return contains an NSError object that
 *                  describes the problem.
 *
 * @return A GRMustacheTemplate instance.
 *
 * @see GRMustacheTemplateRepository
 *
 * @since v1.11
 */
+ (id)templateFromContentsOfFile:(NSString *)path error:(NSError **)error AVAILABLE_GRMUSTACHE_VERSION_6_0_AND_LATER;

/**
 * Parses a template file, and returns a compiled template.
 *
 * The template at url must be encoded in UTF8. See the
 * GRMustacheTemplateRepository class for more encoding options.
 *
 * @param url       The URL of the template.
 * @param error     If there is an error loading or parsing template and
 *                  partials, upon return contains an NSError object that
 *                  describes the problem.
 *
 * @return A GRMustacheTemplate instance.
 *
 * @see GRMustacheTemplateRepository
 *
 * @since v1.11
 */
+ (id)templateFromContentsOfURL:(NSURL *)url error:(NSError **)error AVAILABLE_GRMUSTACHE_VERSION_6_0_AND_LATER;


////////////////////////////////////////////////////////////////////////////////
/// @name Template Resources
////////////////////////////////////////////////////////////////////////////////

/**
 * Parses a bundle resource template, and returns a compiled template.
 * 
 * If you provide nil as a bundle, the resource will be looked in the main
 * bundle.
 * 
 * The template resource must be encoded in UTF8. See the
 * GRMustacheTemplateRepository class for more encoding options.
 * 
 * @param name      The name of a bundle resource of extension "mustache".
 * @param bundle    The bundle where to look for the template resource.
 * @param error     If there is an error loading or parsing template and
 *                  partials, upon return contains an NSError object that
 *                  describes the problem.
 *
 * @return A GRMustacheTemplate instance.
 *
 * @see GRMustacheTemplateRepository
 *
 * @since v1.11
 */
+ (id)templateFromResource:(NSString *)name bundle:(NSBundle *)bundle error:(NSError **)error AVAILABLE_GRMUSTACHE_VERSION_6_0_AND_LATER;


////////////////////////////////////////////////////////////////////////////////
/// @name Rendering a Template
////////////////////////////////////////////////////////////////////////////////

/**
 * Renders a template without any context object for interpreting Mustache tags.
 *
 * @return A string containing the rendered template.
 * @param error   TODO
 *
 * @since v1.0
 */
- (NSString *)renderAndReturnError:(NSError **)error AVAILABLE_GRMUSTACHE_VERSION_6_0_AND_LATER;

/**
 * Renders a template with a context stack initialized with a single object.
 * 
 * @param object  An object used for interpreting Mustache tags.
 * @param error   TODO
 *
 * @return A string containing the rendered template.
 *
 * @since v1.0
 */
- (NSString *)renderObject:(id)object error:(NSError **)error AVAILABLE_GRMUSTACHE_VERSION_6_0_AND_LATER;

/**
 * Renders a template with a context stack initialized with an array of objects.
 *
 * @param objects  An array of context objects for interpreting Mustache tags.
 * @param error   TODO
 *
 * @return A string containing the rendered template.
 *
 * @since v5.3
 */
- (NSString *)renderObjectsFromArray:(NSArray *)objects error:(NSError **)error AVAILABLE_GRMUSTACHE_VERSION_6_0_AND_LATER;

/**
 * TODO
 */
- (NSString *)renderWithContext:(GRMustacheContext *)context  HTMLSafe:(BOOL *)HTMLSafe error:(NSError **)error AVAILABLE_GRMUSTACHE_VERSION_6_0_AND_LATER;

@end
