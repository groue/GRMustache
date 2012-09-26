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
#import "GRMustache_private.h"
#import "GRMustacheTemplateDelegate.h"
#import "GRMustacheRenderingElement_private.h"

// Documented in GRMustacheTemplate.h
@interface GRMustacheTemplate: NSObject<GRMustacheRenderingElement> {
@private
    NSArray *_innerElements;
    id<GRMustacheTemplateDelegate> _delegate;
}

#pragma mark Delegate

// Documented in GRMustacheTemplate.h
@property (nonatomic, assign) id<GRMustacheTemplateDelegate> delegate GRMUSTACHE_API_PUBLIC;


#pragma mark Template innerElements

/**
 * The GRMustacheRenderingElement objects that make the template.
 * 
 * @see GRMustacheRenderingElement
 */
@property (nonatomic, retain) NSArray *innerElements GRMUSTACHE_API_INTERNAL;

/**
 * Builds and return a GRMustacheTemplate with an array of
 * GRMustacheRenderingElement objects.
 *
 * The _innerElements_ array may be nil. This is used by
 * GRMustacheTemplateRepository in order to support recursive partials.
 *
 * @param innerElements  An array of GRMustacheRenderingElement objects.
 *
 * @return a template
 *
 * @see GRMustacheRenderingElement
 */
+ (id)templateWithInnerElements:(NSArray *)innerElements GRMUSTACHE_API_INTERNAL;

#pragma mark String template

// Documented in GRMustacheTemplate.h
+ (id)templateFromString:(NSString *)templateString error:(NSError **)outError GRMUSTACHE_API_PUBLIC;

// Documented in GRMustacheTemplate.h
+ (NSString *)renderObject:(id)object fromString:(NSString *)templateString error:(NSError **)outError GRMUSTACHE_API_PUBLIC;

// Documented in GRMustacheTemplate.h
+ (NSString *)renderObject:(id)object withFilters:(id)filters fromString:(NSString *)templateString error:(NSError **)outError GRMUSTACHE_API_PUBLIC;

#pragma mark File template

// Documented in GRMustacheTemplate.h
+ (id)templateFromContentsOfFile:(NSString *)path error:(NSError **)outError GRMUSTACHE_API_PUBLIC;

// Documented in GRMustacheTemplate.h
+ (NSString *)renderObject:(id)object fromContentsOfFile:(NSString *)path error:(NSError **)outError GRMUSTACHE_API_PUBLIC;

// Documented in GRMustacheTemplate.h
+ (NSString *)renderObject:(id)object withFilters:(id)filters fromContentsOfFile:(NSString *)path error:(NSError **)outError GRMUSTACHE_API_PUBLIC;

#pragma mark Resource template

// Documented in GRMustacheTemplate.h
+ (id)templateFromResource:(NSString *)name bundle:(NSBundle *)bundle error:(NSError **)outError GRMUSTACHE_API_PUBLIC;

// Documented in GRMustacheTemplate.h
+ (id)templateFromResource:(NSString *)name withExtension:(NSString *)ext bundle:(NSBundle *)bundle error:(NSError **)outError GRMUSTACHE_API_PUBLIC;

// Documented in GRMustacheTemplate.h
+ (NSString *)renderObject:(id)object fromResource:(NSString *)name bundle:(NSBundle *)bundle error:(NSError **)outError GRMUSTACHE_API_PUBLIC;

// Documented in GRMustacheTemplate.h
+ (NSString *)renderObject:(id)object withFilters:(id)filters fromResource:(NSString *)name bundle:(NSBundle *)bundle error:(NSError **)outError GRMUSTACHE_API_PUBLIC;

// Documented in GRMustacheTemplate.h
+ (NSString *)renderObject:(id)object fromResource:(NSString *)name withExtension:(NSString *)ext bundle:(NSBundle *)bundle error:(NSError **)outError GRMUSTACHE_API_PUBLIC;

// Documented in GRMustacheTemplate.h
+ (NSString *)renderObject:(id)object withFilters:(id)filters fromResource:(NSString *)name withExtension:(NSString *)ext bundle:(NSBundle *)bundle error:(NSError **)outError GRMUSTACHE_API_PUBLIC;

#pragma mark URL template

// Documented in GRMustacheTemplate.h
+ (id)templateFromContentsOfURL:(NSURL *)url error:(NSError **)outError GRMUSTACHE_API_PUBLIC;

// Documented in GRMustacheTemplate.h
+ (NSString *)renderObject:(id)object fromContentsOfURL:(NSURL *)url error:(NSError **)outError GRMUSTACHE_API_PUBLIC;

// Documented in GRMustacheTemplate.h
+ (NSString *)renderObject:(id)object withFilters:(id)filters fromContentsOfURL:(NSURL *)url error:(NSError **)outError GRMUSTACHE_API_PUBLIC;

#pragma mark Rendering

// Documented in GRMustacheTemplate.h
- (NSString *)renderObject:(id)object GRMUSTACHE_API_PUBLIC;

// Documented in GRMustacheTemplate.h
- (NSString *)renderObject:(id)object withFilters:(id)filters GRMUSTACHE_API_PUBLIC;

// Documented in GRMustacheTemplate.h
- (NSString *)renderObjectsInArray:(NSArray *)objects GRMUSTACHE_API_PUBLIC_BUT_DEPRECATED;

// Documented in GRMustacheTemplate.h
- (NSString *)renderObjectsFromArray:(NSArray *)objects GRMUSTACHE_API_PUBLIC;

// Documented in GRMustacheTemplate.h
- (NSString *)renderObjectsInArray:(NSArray *)objects withFilters:(id)filters GRMUSTACHE_API_PUBLIC_BUT_DEPRECATED;

// Documented in GRMustacheTemplate.h
- (NSString *)renderObjectsFromArray:(NSArray *)objects withFilters:(id)filters GRMUSTACHE_API_PUBLIC;

// Documented in GRMustacheTemplate.h
- (NSString *)render GRMUSTACHE_API_PUBLIC;

@end
