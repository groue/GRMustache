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

#import "GRMustacheTemplate_private.h"
#import "GRMustacheContext_private.h"
#import "GRMustacheTemplateLoader_private.h"
#import "GRMustacheDirectoryTemplateLoader_private.h"
#import "GRMustacheRendering_private.h"


@interface GRMustacheTemplate()
- (id)initWithElements:(NSArray *)theElems;
@end

@implementation GRMustacheTemplate
@synthesize elems;


+ (NSString *)renderObject:(id)object fromString:(NSString *)templateString error:(NSError **)outError {
	GRMustacheTemplate *template = [GRMustacheTemplate parseString:templateString error:outError];
	if (template == nil) {
		return nil;
	}
	return [template renderObject:object];
}

+ (NSString *)renderObject:(id)object fromContentsOfURL:(NSURL *)url error:(NSError **)outError {
	GRMustacheTemplate *template = [GRMustacheTemplate parseContentsOfURL:url error:outError];
	if (template == nil) {
		return nil;
	}
	return [template renderObject:object];
}

+ (NSString *)renderObject:(id)object fromResource:(NSString *)name bundle:(NSBundle *)bundle error:(NSError **)outError {
	GRMustacheTemplate *template = [GRMustacheTemplate parseResource:name bundle:bundle error:outError];
	if (template == nil) {
		return nil;
	}
	return [template renderObject:object];
}

+ (NSString *)renderObject:(id)object fromResource:(NSString *)name withExtension:(NSString *)ext bundle:(NSBundle *)bundle error:(NSError **)outError {
	GRMustacheTemplate *template = [GRMustacheTemplate parseResource:name withExtension:ext bundle:bundle error:outError];
	if (template == nil) {
		return nil;
	}
	return [template renderObject:object];
}

+ (id)parseString:(NSString *)templateString error:(NSError **)outError {
	return [[GRMustacheTemplateLoader templateLoaderWithBundle:[NSBundle mainBundle]]
			parseString:templateString
			error:outError];
}

+ (id)parseContentsOfURL:(NSURL *)url error:(NSError **)outError {
	id loader = [GRMustacheTemplateLoader templateLoaderWithBaseURL:[url URLByDeletingLastPathComponent] extension:[url pathExtension]];
	NSAssert([loader isKindOfClass:[GRMustacheDirectoryTemplateLoader class]], nil);
	return [(GRMustacheDirectoryTemplateLoader *)loader parseContentsOfURL:url error:outError];
}

+ (id)parseResource:(NSString *)name bundle:(NSBundle *)bundle error:(NSError **)outError {
	return [[GRMustacheTemplateLoader templateLoaderWithBundle:bundle]
			parseTemplateNamed:name
			error:outError];
}

+ (id)parseResource:(NSString *)name withExtension:(NSString *)ext bundle:(NSBundle *)bundle error:(NSError **)outError {
	return [[GRMustacheTemplateLoader templateLoaderWithBundle:bundle extension:ext]
			parseTemplateNamed:name
			error:outError];
}

+ (id)templateWithElements:(NSArray *)elems {
	return [[[self alloc] initWithElements:elems] autorelease];
}

- (id)initWithElements:(NSArray *)theElems {
	if ((self == [self init])) {
		self.elems = theElems;
	}
	return self;
}

- (void)dealloc {
	[elems release];
	[super dealloc];
}

- (NSString *)render {
	return [self renderObject:nil];
}

- (NSString *)renderObject:(id)object {
	return [self renderContext:[GRMustacheContext contextWithObject:object]];
}

@end
