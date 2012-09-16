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
 * The GRMustacheInvocation class gives you information about the values that
 * are rendered.
 *
 * You'll be given GRMustacheInvocation instances when providing a
 * GRMustacheTemplateDelegate to your templates.
 *
 * **Companion guide:** https://github.com/groue/GRMustache/blob/master/Guides/delegate.md
 * 
 * @see GRMustacheTemplateDelegate
 *
 * @since v1.12
 */
@interface GRMustacheInvocation : NSObject {
@private
    id _returnValue;
    id _token;
}

/**
 * Returns a string that describes the invocation.
 *
 * It contains the original Mustache tag, the line number, and the path, URL, or
 * name of the template, if any.
 *
 * @return a string that describes the invocation.
 *
 * @since v1.12
 */
- (NSString *)description;

/**
 * The return value of the invocation.
 *
 * For instance, the invocation that you would get for a `{{name}}` tag would
 * have the name in the `returnValue` property.
 *
 * In a template's delegate methods, you can set the returnValue of an
 * invocation, and alter a template rendering.
 *
 * @see GRMustacheTemplateDelegate
 *
 * @since v1.12
 */
@property (nonatomic, retain) id returnValue AVAILABLE_GRMUSTACHE_VERSION_5_0_AND_LATER;
@end
