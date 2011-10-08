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

#import "GRMustacheEnvironment.h"
#import "GRMustacheTemplateLoader_private.h"
#import "GRMustacheTemplate_private.h"
#import "GRMustacheDirectoryTemplateLoader_private.h"
#import "GRMustacheBundleTemplateLoader_private.h"
#import "GRMustacheTemplateParser_private.h"
#import "GRMustacheTokenizer_private.h"
#import "GRMustacheError.h"


NSString* const GRMustacheDefaultExtension = @"mustache";


@interface GRMustacheTemplateLoader()
@property (nonatomic) GRMustacheTemplateOptions templateOptions;
- (GRMustacheTemplate *)parseString:(NSString *)templateString templateId:(id)templateId error:(NSError **)outError;
@end

@implementation GRMustacheTemplateLoader
@synthesize extension;
@synthesize encoding;
@synthesize templateOptions;

#if !TARGET_OS_IPHONE || GRMUSTACHE_IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
+ (id)templateLoaderWithBaseURL:(NSURL *)url {
	return [self templateLoaderWithBaseURL:url options:GRMustacheDefaultTemplateOptions];
}
+ (id)templateLoaderWithBaseURL:(NSURL *)url options:(GRMustacheTemplateOptions)options {
    return [[[GRMustacheDirectoryURLTemplateLoader alloc] initWithURL:url extension:nil encoding:NSUTF8StringEncoding options:options] autorelease];
}
#endif

// deprecated
+ (id)templateLoaderWithBasePath:(NSString *)path {
	return [self templateLoaderWithDirectory:path options:GRMustacheDefaultTemplateOptions];
}

+ (id)templateLoaderWithDirectory:(NSString *)path {
	return [self templateLoaderWithDirectory:path options:GRMustacheDefaultTemplateOptions];
}

+ (id)templateLoaderWithDirectory:(NSString *)path options:(GRMustacheTemplateOptions)options {
	return [[[GRMustacheDirectoryPathTemplateLoader alloc] initWithPath:path extension:nil encoding:NSUTF8StringEncoding options:options] autorelease];
}

#if !TARGET_OS_IPHONE || GRMUSTACHE_IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
+ (id)templateLoaderWithBaseURL:(NSURL *)url extension:(NSString *)ext {
	return [self templateLoaderWithBaseURL:url extension:ext options:GRMustacheDefaultTemplateOptions];
}
+ (id)templateLoaderWithBaseURL:(NSURL *)url extension:(NSString *)ext options:(GRMustacheTemplateOptions)options {
	return [[[GRMustacheDirectoryURLTemplateLoader alloc] initWithURL:url extension:ext encoding:NSUTF8StringEncoding options:options] autorelease];
}
#endif

// deprecated
+ (id)templateLoaderWithBasePath:(NSString *)path extension:(NSString *)ext {
	return [self templateLoaderWithDirectory:path extension:ext options:GRMustacheDefaultTemplateOptions];
}

+ (id)templateLoaderWithDirectory:(NSString *)path extension:(NSString *)ext {
	return [self templateLoaderWithDirectory:path extension:ext options:GRMustacheDefaultTemplateOptions];
}

+ (id)templateLoaderWithDirectory:(NSString *)path extension:(NSString *)ext options:(GRMustacheTemplateOptions)options {
	return [[[GRMustacheDirectoryPathTemplateLoader alloc] initWithPath:path extension:ext encoding:NSUTF8StringEncoding options:options] autorelease];
}

#if !TARGET_OS_IPHONE || GRMUSTACHE_IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
+ (id)templateLoaderWithBaseURL:(NSURL *)url extension:(NSString *)ext encoding:(NSStringEncoding)encoding {
	return [self templateLoaderWithBaseURL:url extension:ext encoding:encoding options:GRMustacheDefaultTemplateOptions];
}

+ (id)templateLoaderWithBaseURL:(NSURL *)url extension:(NSString *)ext encoding:(NSStringEncoding)encoding options:(GRMustacheTemplateOptions)options {
	return [[[GRMustacheDirectoryURLTemplateLoader alloc] initWithURL:url extension:ext encoding:encoding options:options] autorelease];
}
#endif

// deprecated
+ (id)templateLoaderWithBasePath:(NSString *)path extension:(NSString *)ext encoding:(NSStringEncoding)encoding {
	return [self templateLoaderWithDirectory:path extension:ext encoding:encoding options:GRMustacheDefaultTemplateOptions];
}

+ (id)templateLoaderWithDirectory:(NSString *)path extension:(NSString *)ext encoding:(NSStringEncoding)encoding {
	return [self templateLoaderWithDirectory:path extension:ext encoding:encoding options:GRMustacheDefaultTemplateOptions];
}

+ (id)templateLoaderWithDirectory:(NSString *)path extension:(NSString *)ext encoding:(NSStringEncoding)encoding options:(GRMustacheTemplateOptions)options {
	return [[[GRMustacheDirectoryPathTemplateLoader alloc] initWithPath:path extension:ext encoding:encoding options:options] autorelease];
}

+ (id)templateLoaderWithBundle:(NSBundle *)bundle {
	return [self templateLoaderWithBundle:bundle options:GRMustacheDefaultTemplateOptions];
}

+ (id)templateLoaderWithBundle:(NSBundle *)bundle options:(GRMustacheTemplateOptions)options {
	return [[[GRMustacheBundleTemplateLoader alloc] initWithBundle:bundle extension:nil encoding:NSUTF8StringEncoding options:options] autorelease];
}

+ (id)templateLoaderWithBundle:(NSBundle *)bundle extension:(NSString *)ext {
	return [self templateLoaderWithBundle:bundle extension:ext options:GRMustacheDefaultTemplateOptions];
}

+ (id)templateLoaderWithBundle:(NSBundle *)bundle extension:(NSString *)ext options:(GRMustacheTemplateOptions)options {
	return [[[GRMustacheBundleTemplateLoader alloc] initWithBundle:bundle extension:ext encoding:NSUTF8StringEncoding options:options] autorelease];
}

+ (id)templateLoaderWithBundle:(NSBundle *)bundle extension:(NSString *)ext encoding:(NSStringEncoding)encoding {
	return [self templateLoaderWithBundle:bundle extension:ext encoding:encoding options:GRMustacheDefaultTemplateOptions];
}

+ (id)templateLoaderWithBundle:(NSBundle *)bundle extension:(NSString *)ext encoding:(NSStringEncoding)encoding options:(GRMustacheTemplateOptions)options {
	return [[[GRMustacheBundleTemplateLoader alloc] initWithBundle:bundle extension:ext encoding:encoding options:options] autorelease];
}

- (id)initWithExtension:(NSString *)theExtension encoding:(NSStringEncoding)theEncoding options:(GRMustacheTemplateOptions)theOptions
{
    self = [self initWithExtension:theExtension encoding:theEncoding];
    if (self) {
        self.templateOptions = theOptions;
    }
    return self;
}

- (id)initWithExtension:(NSString *)theExtension encoding:(NSStringEncoding)theEncoding {
	if ((self = [self init])) {
		if (theExtension == nil) {
			theExtension = GRMustacheDefaultExtension;
		}
		extension = [theExtension retain];
		encoding = theEncoding;
		templatesById = [[NSMutableDictionary dictionaryWithCapacity:4] retain];
        templateOptions = GRMustacheDefaultTemplateOptions;
	}
	return self;
}

- (GRMustacheTemplate *)parseTemplateNamed:(NSString *)name relativeToTemplateId:(id)baseTemplateId asPartial:(BOOL)partial error:(NSError **)outError {
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
        NSError *templateStringError = nil;
		NSString *templateString = [self templateStringForTemplateId:templateId error:&templateStringError];
		if (!templateString) {
            if (outError != NULL) {
                // make sure we return an error
                if (templateStringError == nil) {
                    templateStringError = [NSError errorWithDomain:GRMustacheErrorDomain
                                                              code:GRMustacheErrorCodeTemplateNotFound
                                                          userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"No such template: %@", name, nil]
                                                                                               forKey:NSLocalizedDescriptionKey]];
                }
                *outError = templateStringError;
            }
            return nil;
		}
		
		// store an empty template before parsing, so that we support recursive partials
		template = [GRMustacheTemplate templateWithElements:nil options:self.templateOptions];
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

- (GRMustacheTemplate *)templateWithElements:(NSArray *)elements
{
    return [GRMustacheTemplate templateWithElements:elements options:self.templateOptions];
}

- (GRMustacheTemplate *)parseTemplateNamed:(NSString *)name error:(NSError **)outError {
	return [self parseTemplateNamed:name relativeToTemplateId:nil asPartial:NO error:outError];
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
	GRMustacheTemplateParser *parser = [[GRMustacheTemplateParser alloc] initWithTemplateLoader:self templateId:templateId];
	GRMustacheTokenizer *tokenizer = [[GRMustacheTokenizer alloc] init];
	tokenizer.delegate = parser;
	[tokenizer parseTemplateString:templateString];
    [tokenizer release];
	GRMustacheTemplate *res = [parser templateReturningError:outError];
    [parser release];
    return res;
}

@end



