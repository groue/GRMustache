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
#import "GRMustacheElement.h"


@class GRMustacheTemplateLoader;

@interface GRMustacheTemplate: GRMustacheElement {
	GRMustacheTemplateLoader *templateLoader;
	NSString *templateId;
	NSString *templateString;
	NSString *otag;
	NSString *ctag;
	NSInteger p;
	NSInteger curline;
	NSMutableArray *elems;
}


// Renders object with the template contained in the templateString argument.
// Partials would be looked from current working directory.
+ (NSString *)renderObject:(id)object
				fromString:(NSString *)templateString
					 error:(NSError **)outError;

// Renders object with the template loaded from url, whose content must be encoded in UTF8.
// Partials would be looked relatively to url.
+ (NSString *)renderObject:(id)object
		 fromContentsOfURL:(NSURL *)url
					 error:(NSError **)outError;

// Renders object with the template loaded from bundle, whose content must be encoded in UTF8.
// Partials would be looked in the bundle.
+ (NSString *)renderObject:(id)object
			  fromResource:(NSString *)name
					bundle:(NSBundle *)bundle
					 error:(NSError **)outError;

// Renders object with the template loaded from bundle, whose content must be encoded in UTF8.
// Partials would be looked in the bundle.
+ (NSString *)renderObject:(id)object
			  fromResource:(NSString *)name
			 withExtension:(NSString *)ext
					bundle:(NSBundle *)bundle
					 error:(NSError **)outError;

// Returns a template with the templateString argument.
// Partials would be looked from current working directory.
+ (id)parseString:(NSString *)templateString
			error:(NSError **)outError;

// Returns a template loaded from url, whose content must be encoded in UTF8.
// Partials would be looked relatively to url.
+ (id)parseContentsOfURL:(NSURL *)url
				   error:(NSError **)outError;

// Returns a template loaded from bundle, whose content must be encoded in UTF8.
// Partials would be looked in the bundle.
+ (id)parseResource:(NSString *)name
			 bundle:(NSBundle *)bundle
			  error:(NSError **)outError;

// Returns a template loaded from bundle, whose content must be encoded in UTF8.
// Partials would be looked in the bundle.
+ (id)parseResource:(NSString *)name
	  withExtension:(NSString *)ext
			 bundle:(NSBundle *)bundle
			  error:(NSError **)outError;


// Renders with a context object
- (NSString *)renderObject:(id)object;

// Renders without context
- (NSString *)render;

@end
