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

#import "GRMustacheAvailabilityMacros_private.h"
#import "GRMustacheRenderingElement_private.h"

@class GRMustacheInvocation;
@class GRMustacheTemplate;

// Documented in GRMustacheSection.h
@interface GRMustacheSection: NSObject<GRMustacheRenderingElement> {
@private
    GRMustacheInvocation *_invocation;
    GRMustacheTemplate *_rootTemplate;
    NSString *_templateString;
    NSRange _innerRange;
    BOOL _inverted;
    NSArray *_elems;
    id _renderingContext;
}

// Documented in GRMustacheSection.h
@property (nonatomic, readonly) id renderingContext GRMUSTACHE_API_PUBLIC;

// Documented in GRMustacheSection.h
@property (nonatomic, readonly) NSString *innerTemplateString GRMUSTACHE_API_PUBLIC;

/**
 Builds a GRMustacheSection.

 The rendering of Mustache sections depend on the value they are attached to, whether they
 are truthy, falsey, enumerable, or helpers. The value is fetched by applying the _invocation_
 parameter to a rendering context.
 
 Boolean values are interpreted in their relation to the _inverted_ parameter.
 
 Helpers (GRMustacheHelper) may call the `innerTemplateString` template string method. This
 inner template string is built from the _templateString_ and _innerRange_ parameters.
 
 The _elems_ array contains the GRMustacheRenderingElement objects that make the section (texts, variables, other sections, etc.)

 @return a GRMustacheSection
 @param invocation The invocation that should be applied to a rendering context in order to fetch the data to render
 @param templateString A Mustache template string
 @param innerRange The range of the inner template string of the section in _templateString_.
 @param inverted YES if the section is {{^inverted}}; otherwise, NO.
 @param elems An array of GRMustacheRenderingElement that make the section.
 
 @see GRMustacheInvocation
 @see GRMustacheContext
 @see GRMustacheHelper
 */
+ (id)sectionElementWithInvocation:(GRMustacheInvocation *)invocation templateString:(NSString *)templateString innerRange:(NSRange)innerRange inverted:(BOOL)inverted elements:(NSArray *)elems GRMUSTACHE_API_INTERNAL;

// Documented in GRMustacheSection.h
- (NSString *)render GRMUSTACHE_API_PUBLIC;

@end
