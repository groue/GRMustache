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

@class GRMustacheSectionElement;
@class GRMustacheRuntime;

// Documented in GRMustacheSection.h
@interface GRMustacheSection: NSObject {
@private
    GRMustacheSectionElement *_sectionElement;
    GRMustacheRuntime *_runtime;
}

// Documented in GRMustacheSection.h
@property (nonatomic, readonly) NSString *innerTemplateString GRMUSTACHE_API_PUBLIC;

// Documented in GRMustacheSection.h
- (NSString *)render GRMUSTACHE_API_PUBLIC;

// Documented in GRMustacheSection.h
- (NSString *)renderTemplateString:(NSString *)string error:(NSError **)outError GRMUSTACHE_API_PUBLIC;

/**
 * Builds and returns a section suitable for GRMustacheSectionHelper.
 *
 * @param sectionElement    The underlying sectionElement.
 * @param runtime           A runtime.
 *
 * @return A section.
 *
 * @see GRMustacheSectionHelper protocol
 * @see GRMustacheSectionElement
 * @see GRMustacheRuntime
 */
+ (id)sectionWithSectionElement:(GRMustacheSectionElement *)sectionElement runtime:(GRMustacheRuntime *)runtime GRMUSTACHE_API_INTERNAL;
@end
