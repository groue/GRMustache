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

#import <Cocoa/Cocoa.h>
#import "GRMustache.h"

/**
 * LocalizingHelper can localize the content of a Mustache section, using
 * NSLocalizedString. It also has a filter facet that localizes your data.
 *
 * Localizing data:
 *
 * `{{ localize(greeting) }}` renders
 * `NSLocalizedString(@"Hello", nil)`, assuming the `greeting`key resolves to
 * the @"Hello" string.
 *
 * Localizing sections:
 *
 * `{{#localize}}Hello{{/localize}}` renders
 * `NSLocalizedString(@"Hello", nil)`.
 *
 * Localizing sections with arguments:
 *
 * `{{#localize}}Hello {{name}}{{/localize}}` builds the format string
 * `NSLocalizedString(@"Hello %@", nil)` and injects the name with
 * `[NSString stringWithFormat:]`.
 *
 * Localize sections with arguments and conditions:
 *
 * `{{#localize}}Good morning {{#title}}{{title}}{{/title}} {{name}}{{/localize}}`
 * build the format string `NSLocalizedString(@"Good morning %@", nil)` or
 * `NSLocalizedString(@"Good morning %@ %@", nil)`, depending on the presence of
 * the `title` key, and injects the name, or both title and name,  with
 * `[NSString stringWithFormat:]`.
 */
@interface LocalizingHelper : NSObject<GRMustacheRendering, GRMustacheFilter>
@end

