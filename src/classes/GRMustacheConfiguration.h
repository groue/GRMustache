// The MIT License
//
// Copyright (c) 2013 Gwendal Roué
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
 * The content type of strings rendered by templates.
 *
 * @see GRMustacheConfiguration
 * @see GRMustacheTemplateRepository
 *
 * @since v6.2
 */
typedef enum {
    /**
     * The `GRMustacheContentTypeHTML` content type has templates render HTML.
     * HTML template escape the input of variable tags such as `{{name}}`. Use
     * triple mustache tags `{{{content}}}` in order to avoid the HTML-escaping.
     *
     * @since v6.2
     */
    GRMustacheContentTypeHTML AVAILABLE_GRMUSTACHE_VERSION_6_2_AND_LATER,

    /**
     * The `GRMustacheContentTypeText` content type has templates render text.
     * They do not HTML-escape their input: `{{name}}` and `{{{name}}}` have
     * identical renderings.
     *
     * @since v6.2
     */
    GRMustacheContentTypeText AVAILABLE_GRMUSTACHE_VERSION_6_2_AND_LATER,
} GRMustacheContentType;

/**
 * A GRMustacheConfiguration instance configures GRMustache rendering.
 *
 * The default configuration [GRMustacheConfiguration defaultConfiguration]
 * applies to all GRMustache rendering by default:
 *
 *     // GRMustache templates render text by default,
 *     // and do not HTML-escape their input.
 *     [GRMustacheConfiguration defaultConfiguration].contentType = GRMustacheContentTypeText;
 *
 * You can also assign a specific configuration to a template repository: the
 * configuration would then only apply to the templates built by the template
 * repository:
 *
 *     // Create a configuration for text rendering
 *     GRMustacheConfiguration *configuration = [[GRMustacheConfiguration alloc] init];
 *     configuration.contentType = GRMustacheContentTypeText;
 *
 *     // All templates loaded from _repo_ will render text,
 *     // and will not HTML-escape their input.
 *     GRMustacheTemplateRepository *repo = [GRMustacheTemplateRepository templateRepositoryWithBundle:nil];
 *     repo.configuration = configuration;
 *
 * The consequences of altering a configuration after it has been used is
 * *undefined*. In other words:
 *
 * - set up the default configuration early, once and for all.
 * - once a repository has been given its own configuration, don't modify it.
 *
 * The `contentType` option can be specified at the template level, so that your
 * repositories can mix HTML and text templates: see the documentation of this
 * property.
 *
 * @since v6.2
 */
@interface GRMustacheConfiguration : NSObject {
    GRMustacheContentType _contentType;
}


/**
 * The default configuration.
 *
 * All templates and template repositories use the default configuration unless
 * you specify otherwise by setting the configuration of a template repository.
 *
 * @see GRMustacheTemplateRepository
 *
 * @since v6.2
 */
+ (GRMustacheConfiguration *)defaultConfiguration AVAILABLE_GRMUSTACHE_VERSION_6_2_AND_LATER;


/**
 * The content type of strings rendered by templates.
 *
 * This property affects the HTML-escaping of your data, and the inclusion
 * of templates in other templates.
 *
 * The `GRMustacheContentTypeHTML` content type has templates render HTML.
 * This is the default behavior. HTML template escape the input of variable tags
 * such as `{{name}}`. Use triple mustache tags `{{{content}}}` in order to
 * avoid the HTML-escaping.
 *
 * The `GRMustacheContentTypeText` content type has templates render text.
 * They do not HTML-escape their input: `{{name}}` and `{{{name}}}` have
 * identical renderings.
 *
 * GRMustache safely keeps track of the content type of templates: should a HTML
 * template embed a text template, the content of the text template would be
 * HTML-escaped.
 *
 * There is no API to specify the content type of individual templates. However,
 * you can use pragma tags right in the content of your templates:
 *
 * - `{{% CONTENT_TYPE:TEXT }}` turns a template into a text template.
 * - `{{% CONTENT_TYPE:HTML }}` turns a template into a HTML template.
 *
 * Insert those pragma tags early in your templates. For example:
 *
 *     {{! This template renders a bash script. }}
 *     {{% CONTENT_TYPE:TEXT }}
 *     export LANG={{ENV.LANG}}
 *     ...
 *
 * Should two such pragmas be found in a template content, the last one wins.
 *
 * @since v6.2
 */
@property (nonatomic) GRMustacheContentType contentType AVAILABLE_GRMUSTACHE_VERSION_6_2_AND_LATER;

@end
