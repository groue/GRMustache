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

#import "GRMustache_private.h"
#import "GRMustacheTemplateLoader_private.h"
#import "GRMustacheTemplate_private.h"
#import "GRMustacheDirectoryTemplateLoader_private.h"
#import "GRMustacheBundleTemplateLoader_private.h"
#import "GRMustacheTemplateParser_private.h"
#import "GRMustacheTokenizer_private.h"


NSString* const GRMustacheDefaultExtension = @"mustache";


@interface GRMustacheTemplateLoader()
- (GRMustacheTemplate *)parseString:(NSString *)templateString templateId:(id)templateId error:(NSError **)outError;
@end

@implementation GRMustacheTemplateLoader
@synthesize extension;
@synthesize encoding;

+ (id)templateLoaderWithCurrentWorkingDirectory {
	return [self templateLoaderWithBaseURL:[NSURL fileURLWithPath:[[NSFileManager defaultManager] currentDirectoryPath] isDirectory:YES]];
}

+ (id)templateLoaderWithBaseURL:(NSURL *)url {
	return [[[GRMustacheDirectoryTemplateLoader alloc] initWithURL:url extension:nil encoding:NSUTF8StringEncoding] autorelease];
}

+ (id)templateLoaderWithBaseURL:(NSURL *)url extension:(NSString *)ext {
	return [[[GRMustacheDirectoryTemplateLoader alloc] initWithURL:url extension:ext encoding:NSUTF8StringEncoding] autorelease];
}

+ (id)templateLoaderWithBaseURL:(NSURL *)url extension:(NSString *)ext encoding:(NSStringEncoding)encoding {
	return [[[GRMustacheDirectoryTemplateLoader alloc] initWithURL:url extension:ext encoding:encoding] autorelease];
}

+ (id)templateLoaderWithBundle:(NSBundle *)bundle {
	return [[[GRMustacheBundleTemplateLoader alloc] initWithBundle:bundle extension:nil encoding:NSUTF8StringEncoding] autorelease];
}

+ (id)templateLoaderWithBundle:(NSBundle *)bundle extension:(NSString *)ext {
	return [[[GRMustacheBundleTemplateLoader alloc] initWithBundle:bundle extension:ext encoding:NSUTF8StringEncoding] autorelease];
}

+ (id)templateLoaderWithBundle:(NSBundle *)bundle extension:(NSString *)ext encoding:(NSStringEncoding)encoding {
	return [[[GRMustacheBundleTemplateLoader alloc] initWithBundle:bundle extension:ext encoding:encoding] autorelease];
}

- (id)initWithExtension:(NSString *)theExtension encoding:(NSStringEncoding)theEncoding {
	if ((self = [self init])) {
		if (theExtension == nil) {
			theExtension = GRMustacheDefaultExtension;
		}
		extension = [theExtension retain];
		encoding = theEncoding;
		templatesById = [[NSMutableDictionary dictionaryWithCapacity:4] retain];
	}
	return self;
}

- (GRMustacheTemplate *)parseTemplateNamed:(NSString *)name relativeToTemplateId:(id)baseTemplateId error:(NSError **)outError {
	id templateId = [self templateIdForTemplateNamed:name relativeToTemplateId:baseTemplateId];
	if (templateId == nil) {
		if (outError != NULL) {
			*outError = [NSError errorWithDomain:GRMustacheErrorDomain
											code:GRMustacheErrorCodeTemplateNotFound
										userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"No such template: %@", name, nil]
																			 forKey:NSLocalizedDescriptionKey]];
		}
		return nil;
	}
	
	GRMustacheTemplate *template = [templatesById objectForKey:templateId];
	
	if (template == nil) {
		// templateStringForTemplateId is a method that GRMustache users may implement.
		// We have to take extra care of error handling here.
		if (outError != NULL) {
			*outError = nil;
		}
		NSString *templateString = [self templateStringForTemplateId:templateId error:outError];
		if (!templateString) {
			if (outError != NULL) {
				// make sure we return an error
				if (*outError == nil) {
					*outError = [NSError errorWithDomain:GRMustacheErrorDomain
													code:GRMustacheErrorCodeTemplateNotFound
												userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"No such template: %@", name, nil]
																					 forKey:NSLocalizedDescriptionKey]];
				}
			}
			return nil;
		}
		
		// store an empty template before parsing, so that we support recursive partials
		template = [GRMustacheTemplate templateWithElements:nil];
		[self setTemplate:template forTemplateId:templateId];
		
		// parse
		GRMustacheTemplate *parsedTemplate = [self parseString:templateString templateId:templateId error:outError];
		if (parsedTemplate == nil) {
			[self setTemplate:nil forTemplateId:templateId];
			return nil;
		} else {
			template.elems = parsedTemplate.elems;
		}
	}
	
	return template;
}

- (GRMustacheTemplate *)parseTemplateNamed:(NSString *)name error:(NSError **)outError {
	return [self parseTemplateNamed:name relativeToTemplateId:nil error:outError];
}

- (GRMustacheTemplate *)parseString:(NSString *)templateString error:(NSError **)outError {
	return [self parseString:templateString templateId:nil error:outError];
}

- (void)setTemplate:(GRMustacheTemplate *)template forTemplateId:(id)templateId {
	if (template) {
		[templatesById setObject:template forKey:templateId];
	} else {
		[templatesById removeObjectForKey:templateId];
	}
}

- (id)templateIdForTemplateNamed:(NSString *)name relativeToTemplateId:(id)baseTemplateId {
	NSAssert(NO, @"abstract method");
	return nil;
}

- (NSString *)templateStringForTemplateId:(id)templateId error:(NSError **)outError {
	NSAssert(NO, @"abstract method");
	return nil;
}

- (void)dealloc {
	[extension release];
	[templatesById release];
	[super dealloc];
}

#pragma mark Private

- (GRMustacheTemplate *)parseString:(NSString *)templateString templateId:(id)templateId error:(NSError **)outError {
	GRMustacheTemplateParser *parser = [[[GRMustacheTemplateParser alloc] initWithTemplateLoader:self templateId:templateId] autorelease];
	GRMustacheTokenizer *tokenizer = [[[GRMustacheTokenizer alloc] init] autorelease];
	[tokenizer parseTemplateString:templateString forTokenConsumer:parser];
	return [parser templateReturningError:outError];
}

@end



