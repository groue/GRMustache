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

#import <Foundation/Foundation.h>
#import "GRMustacheAvailabilityMacros.h"


@interface GRMustacheSection: NSObject {
@private
	NSString *name;
	NSString *baseTemplateString;
    NSRange range;
	BOOL inverted;
	NSArray *elems;
}
@property (nonatomic, readonly) NSString *templateString AVAILABLE_GRMUSTACHE_VERSION_1_3_AND_LATER;

/**
 Renders a template with a context object.
 
 @returns A string containing the rendered template
 @param object A context object used for interpreting Mustache tags
 
 @since v1.3.0
 */
- (NSString *)renderObject:(id)object AVAILABLE_GRMUSTACHE_VERSION_1_3_AND_LATER;

/**
 Renders a template with context objects.
 
 @returns A string containing the rendered template
 @param object, ... A comma-separated list of objects used for interpreting Mustache tags, ending with nil
 
 @since v1.5.0
 */
- (NSString *)renderObjects:(id)object, ... AVAILABLE_GRMUSTACHE_VERSION_1_5_AND_LATER;

@end
