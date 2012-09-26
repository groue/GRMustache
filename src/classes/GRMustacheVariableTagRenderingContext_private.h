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
#import "GRMustacheAvailabilityMacros_private.h"

@class GRMustacheTemplateRepository;
@class GRMustacheRuntime;

// Documented in GRMustacheVariableTagRenderingContext.h
@interface GRMustacheVariableTagRenderingContext : NSObject {
@private
    GRMustacheTemplateRepository *_templateRepository;
    GRMustacheRuntime *_runtime;
}

// Documented in GRMustacheVariableTagRenderingContext.h
- (NSString *)renderTemplateString:(NSString *)string error:(NSError **)outError GRMUSTACHE_API_PUBLIC;

// Documented in GRMustacheVariableTagRenderingContext.h
- (NSString *)renderTemplateNamed:(NSString *)name error:(NSError **)outError GRMUSTACHE_API_PUBLIC;

/**
 * Builds and returns a context suitable for GRMustacheVariableTagHelper.
 *
 * @param templateRepository  A Template repository that allows helpers to
 *                            render template strings through
 *                            renderTemplateString:error: and
 *                            renderTemplateNamed:error: methods.
 * @param runtime             A runtime.
 *
 * @return A variable tag rendering context.
 *
 * @see GRMustacheVariableTagHelper protocol
 * @see GRMustacheRuntime
 */
+ (id)contextWithTemplateRepository:(GRMustacheTemplateRepository *)templateRepository runtime:(GRMustacheRuntime *)runtime GRMUSTACHE_API_INTERNAL;
@end
