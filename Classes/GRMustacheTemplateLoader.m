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

#import "GRMustacheEnvironment.h"
#import "GRMustacheTemplateLoader.h"
#import "GRMustacheTemplateLoader_protected.h"
#import "GRMustacheTemplateRepository.h"

static NSString* const GRMustacheDefaultExtension = @"mustache";

@interface GRMustacheTemplateLoader()<GRMustacheTemplateRepositoryDataSource>
@property (nonatomic, retain) GRMustacheTemplateRepository *templateRepository;
+ (id)templateLoaderWithTemplateRepository:(GRMustacheTemplateRepository *)templateRepository;
- (id)initWithTemplateRepository:(GRMustacheTemplateRepository *)templateRepository;
@end

@implementation GRMustacheTemplateLoader
@synthesize templateRepository=_templateRepository;
@synthesize extension=_extension;
@synthesize encoding=_encoding;

#if !TARGET_OS_IPHONE || GRMUSTACHE_IPHONE_OS_VERSION_MAX_ALLOWED >= 40000

+ (id)templateLoaderWithBaseURL:(NSURL *)URL
{
    return [self templateLoaderWithTemplateRepository:[GRMustacheTemplateRepository templateRepositoryWithBaseURL:URL]];
}
+ (id)templateLoaderWithBaseURL:(NSURL *)URL options:(GRMustacheTemplateOptions)options
{
    return [self templateLoaderWithTemplateRepository:[GRMustacheTemplateRepository templateRepositoryWithBaseURL:URL options:options]];
}

#endif /* if GRMUSTACHE_BLOCKS_AVAILABLE */

+ (id)templateLoaderWithBasePath:(NSString *)path
{
    return [self templateLoaderWithTemplateRepository:[GRMustacheTemplateRepository templateRepositoryWithDirectory:path]];
}

+ (id)templateLoaderWithDirectory:(NSString *)path
{
    return [self templateLoaderWithTemplateRepository:[GRMustacheTemplateRepository templateRepositoryWithDirectory:path]];
}

+ (id)templateLoaderWithDirectory:(NSString *)path options:(GRMustacheTemplateOptions)options
{
    return [self templateLoaderWithTemplateRepository:[GRMustacheTemplateRepository templateRepositoryWithDirectory:path options:options]];
}

#if !TARGET_OS_IPHONE || GRMUSTACHE_IPHONE_OS_VERSION_MAX_ALLOWED >= 40000

+ (id)templateLoaderWithBaseURL:(NSURL *)URL extension:(NSString *)ext
{
    if (ext == nil) {
        ext = GRMustacheDefaultExtension;
    }
    return [self templateLoaderWithTemplateRepository:[GRMustacheTemplateRepository templateRepositoryWithBaseURL:URL templateExtension:ext]];
}
+ (id)templateLoaderWithBaseURL:(NSURL *)URL extension:(NSString *)ext options:(GRMustacheTemplateOptions)options
{
    if (ext == nil) {
        ext = GRMustacheDefaultExtension;
    }
    return [self templateLoaderWithTemplateRepository:[GRMustacheTemplateRepository templateRepositoryWithBaseURL:URL templateExtension:ext options:options]];
}

#endif /* if GRMUSTACHE_BLOCKS_AVAILABLE */

+ (id)templateLoaderWithBasePath:(NSString *)path extension:(NSString *)ext
{
    if (ext == nil) {
        ext = GRMustacheDefaultExtension;
    }
    return [self templateLoaderWithTemplateRepository:[GRMustacheTemplateRepository templateRepositoryWithDirectory:path templateExtension:ext]];
}

+ (id)templateLoaderWithDirectory:(NSString *)path extension:(NSString *)ext
{
    if (ext == nil) {
        ext = GRMustacheDefaultExtension;
    }
    return [self templateLoaderWithTemplateRepository:[GRMustacheTemplateRepository templateRepositoryWithDirectory:path templateExtension:ext]];
}

+ (id)templateLoaderWithDirectory:(NSString *)path extension:(NSString *)ext options:(GRMustacheTemplateOptions)options
{
    if (ext == nil) {
        ext = GRMustacheDefaultExtension;
    }
    return [self templateLoaderWithTemplateRepository:[GRMustacheTemplateRepository templateRepositoryWithDirectory:path templateExtension:ext options:options]];
}

#if !TARGET_OS_IPHONE || GRMUSTACHE_IPHONE_OS_VERSION_MAX_ALLOWED >= 40000

+ (id)templateLoaderWithBaseURL:(NSURL *)URL extension:(NSString *)ext encoding:(NSStringEncoding)encoding
{
    if (ext == nil) {
        ext = GRMustacheDefaultExtension;
    }
    return [self templateLoaderWithTemplateRepository:[GRMustacheTemplateRepository templateRepositoryWithBaseURL:URL templateExtension:ext encoding:encoding]];
}

+ (id)templateLoaderWithBaseURL:(NSURL *)URL extension:(NSString *)ext encoding:(NSStringEncoding)encoding options:(GRMustacheTemplateOptions)options
{
    if (ext == nil) {
        ext = GRMustacheDefaultExtension;
    }
    return [self templateLoaderWithTemplateRepository:[GRMustacheTemplateRepository templateRepositoryWithBaseURL:URL templateExtension:ext encoding:encoding options:options]];
}

#endif /* if !TARGET_OS_IPHONE || GRMUSTACHE_IPHONE_OS_VERSION_MAX_ALLOWED >= 40000 */

+ (id)templateLoaderWithBasePath:(NSString *)path extension:(NSString *)ext encoding:(NSStringEncoding)encoding
{
    if (ext == nil) {
        ext = GRMustacheDefaultExtension;
    }
    return [self templateLoaderWithTemplateRepository:[GRMustacheTemplateRepository templateRepositoryWithDirectory:path templateExtension:ext encoding:encoding]];
}

+ (id)templateLoaderWithDirectory:(NSString *)path extension:(NSString *)ext encoding:(NSStringEncoding)encoding
{
    if (ext == nil) {
        ext = GRMustacheDefaultExtension;
    }
    return [self templateLoaderWithTemplateRepository:[GRMustacheTemplateRepository templateRepositoryWithDirectory:path templateExtension:ext encoding:encoding]];
}

+ (id)templateLoaderWithDirectory:(NSString *)path extension:(NSString *)ext encoding:(NSStringEncoding)encoding options:(GRMustacheTemplateOptions)options
{
    if (ext == nil) {
        ext = GRMustacheDefaultExtension;
    }
    return [self templateLoaderWithTemplateRepository:[GRMustacheTemplateRepository templateRepositoryWithDirectory:path templateExtension:ext encoding:encoding options:options]];
}

+ (id)templateLoaderWithBundle:(NSBundle *)bundle
{
    return [self templateLoaderWithTemplateRepository:[GRMustacheTemplateRepository templateRepositoryWithBundle:bundle]];
}

+ (id)templateLoaderWithBundle:(NSBundle *)bundle options:(GRMustacheTemplateOptions)options
{
    return [self templateLoaderWithTemplateRepository:[GRMustacheTemplateRepository templateRepositoryWithBundle:bundle options:options]];
}

+ (id)templateLoaderWithBundle:(NSBundle *)bundle extension:(NSString *)ext
{
    if (ext == nil) {
        ext = GRMustacheDefaultExtension;
    }
    return [self templateLoaderWithTemplateRepository:[GRMustacheTemplateRepository templateRepositoryWithBundle:bundle templateExtension:ext]];
}

+ (id)templateLoaderWithBundle:(NSBundle *)bundle extension:(NSString *)ext options:(GRMustacheTemplateOptions)options
{
    if (ext == nil) {
        ext = GRMustacheDefaultExtension;
    }
    return [self templateLoaderWithTemplateRepository:[GRMustacheTemplateRepository templateRepositoryWithBundle:bundle templateExtension:ext options:options]];
}

+ (id)templateLoaderWithBundle:(NSBundle *)bundle extension:(NSString *)ext encoding:(NSStringEncoding)encoding
{
    if (ext == nil) {
        ext = GRMustacheDefaultExtension;
    }
    return [self templateLoaderWithTemplateRepository:[GRMustacheTemplateRepository templateRepositoryWithBundle:bundle templateExtension:ext encoding:encoding]];
}

+ (id)templateLoaderWithBundle:(NSBundle *)bundle extension:(NSString *)ext encoding:(NSStringEncoding)encoding options:(GRMustacheTemplateOptions)options
{
    if (ext == nil) {
        ext = GRMustacheDefaultExtension;
    }
    return [self templateLoaderWithTemplateRepository:[GRMustacheTemplateRepository templateRepositoryWithBundle:bundle templateExtension:ext encoding:encoding options:options]];
}

- (id)initWithExtension:(NSString *)extension encoding:(NSStringEncoding)encoding options:(GRMustacheTemplateOptions)options
{
    self = [self initWithExtension:extension encoding:encoding];
    if (self) {
        GRMustacheTemplateRepository *templateRepository = [GRMustacheTemplateRepository templateRepositoryWithOptions:options];
        templateRepository.dataSource = self;
        self.templateRepository = templateRepository;
    }
    return self;
}

- (id)initWithExtension:(NSString *)extension encoding:(NSStringEncoding)encoding
{
    self = [self init];
    if (self) {
        if (extension == nil) {
            extension = GRMustacheDefaultExtension;
        }
        _extension = [extension retain];
        _encoding = encoding;
        
        GRMustacheTemplateRepository *templateRepository = [GRMustacheTemplateRepository templateRepositoryWithOptions:[GRMustache defaultTemplateOptions]];
        templateRepository.dataSource = self;
        self.templateRepository = templateRepository;
    }
    return self;
}

- (GRMustacheTemplate *)parseTemplateNamed:(NSString *)name error:(NSError **)outError
{
    return [_templateRepository templateForName:name error:outError];
}

- (GRMustacheTemplate *)templateWithName:(NSString *)name error:(NSError **)outError
{
    return [_templateRepository templateForName:name error:outError];
}

- (GRMustacheTemplate *)parseString:(NSString *)templateString error:(NSError **)outError
{
    return [_templateRepository templateFromString:templateString error:outError];
}

- (GRMustacheTemplate *)templateFromString:(NSString *)templateString error:(NSError **)outError
{
    return [_templateRepository templateFromString:templateString error:outError];
}

- (id)templateIdForTemplateNamed:(NSString *)name relativeToTemplateId:(id)baseTemplateId
{
    NSAssert(NO, @"abstract method");
    return nil;
}

- (NSString *)templateStringForTemplateId:(id)templateId error:(NSError **)outError
{
    NSAssert(NO, @"abstract method");
    return nil;
}

- (void)dealloc
{
    [_extension release];
    [_templateRepository release];
    [super dealloc];
}

#pragma mark GRMustacheTemplateRepositoryDataSource

- (id)templateRepository:(GRMustacheTemplateRepository *)templateRepository templateIDForName:(NSString *)name relativeToTemplateID:(id)templateID
{
    return [self templateIdForTemplateNamed:name relativeToTemplateId:templateID];
}

- (NSString *)templateRepository:(GRMustacheTemplateRepository *)templateRepository templateStringForTemplateID:(id)templateID error:(NSError **)outError
{
    return [self templateStringForTemplateId:templateID error:outError];
}

#pragma mark Private

- (id)initWithTemplateRepository:(GRMustacheTemplateRepository *)templateRepository
{
    self = [self init];
    if (self) {
        self.templateRepository = templateRepository;
    }
    return self;
}

+ (id)templateLoaderWithTemplateRepository:(GRMustacheTemplateRepository *)templateRepository
{
    return [[[GRMustacheTemplateLoader alloc] initWithTemplateRepository:templateRepository] autorelease];
}

@end



