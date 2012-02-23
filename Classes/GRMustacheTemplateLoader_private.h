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
#import "GRMustacheEnvironment.h"
#import "GRMustacheTemplate_private.h"
#import <Foundation/Foundation.h>


@class GRMustacheTemplate;

#pragma mark -

#if !TARGET_OS_IPHONE || GRMUSTACHE_IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
@protocol GRMustacheURLTemplateLoader<NSObject>
- (GRMustacheTemplate *)templateFromContentsOfURL:(NSURL *)templateURL error:(NSError **)outError GRMUSTACHE_API_INTERNAL;
@end
#endif

#pragma mark -

@protocol GRMustachePathTemplateLoader<NSObject>
- (GRMustacheTemplate *)templateFromContentsOfFile:(NSString *)templatePath error:(NSError **)outError GRMUSTACHE_API_INTERNAL;
@end

#pragma mark -

@interface GRMustacheTemplateLoader: NSObject {
@private
    NSString *_extension;
    NSStringEncoding _encoding;
    NSMutableDictionary *_templatesById;
    GRMustacheTemplateOptions _options;
}

@property (nonatomic, readonly, copy) NSString *extension GRMUSTACHE_API_PUBLIC;
@property (nonatomic, readonly) NSStringEncoding encoding GRMUSTACHE_API_PUBLIC;
@property (nonatomic, readonly) GRMustacheTemplateOptions options GRMUSTACHE_API_INTERNAL;

- (id)initWithExtension:(NSString *)ext encoding:(NSStringEncoding)encoding GRMUSTACHE_API_PUBLIC;
- (id)initWithExtension:(NSString *)ext encoding:(NSStringEncoding)encoding options:(GRMustacheTemplateOptions)options GRMUSTACHE_API_PUBLIC;

#pragma mark Directory

+ (id<GRMustachePathTemplateLoader>)templateLoaderWithDirectory:(NSString *)path GRMUSTACHE_API_PUBLIC;
+ (id<GRMustachePathTemplateLoader>)templateLoaderWithDirectory:(NSString *)path options:(GRMustacheTemplateOptions)options GRMUSTACHE_API_PUBLIC;
+ (id<GRMustachePathTemplateLoader>)templateLoaderWithDirectory:(NSString *)path extension:(NSString *)ext GRMUSTACHE_API_PUBLIC;
+ (id<GRMustachePathTemplateLoader>)templateLoaderWithDirectory:(NSString *)path extension:(NSString *)ext options:(GRMustacheTemplateOptions)options GRMUSTACHE_API_PUBLIC;
+ (id<GRMustachePathTemplateLoader>)templateLoaderWithDirectory:(NSString *)path extension:(NSString *)ext encoding:(NSStringEncoding)encoding GRMUSTACHE_API_PUBLIC;
+ (id<GRMustachePathTemplateLoader>)templateLoaderWithDirectory:(NSString *)path extension:(NSString *)ext encoding:(NSStringEncoding)encoding options:(GRMustacheTemplateOptions)options GRMUSTACHE_API_PUBLIC;

+ (id<GRMustachePathTemplateLoader>)templateLoaderWithBasePath:(NSString *)path GRMUSTACHE_API_DEPRECATED_PUBLIC;
+ (id<GRMustachePathTemplateLoader>)templateLoaderWithBasePath:(NSString *)path extension:(NSString *)ext GRMUSTACHE_API_DEPRECATED_PUBLIC;
+ (id<GRMustachePathTemplateLoader>)templateLoaderWithBasePath:(NSString *)path extension:(NSString *)ext encoding:(NSStringEncoding)encoding GRMUSTACHE_API_DEPRECATED_PUBLIC;

#pragma mark Bundle

+ (id)templateLoaderWithBundle:(NSBundle *)bundle GRMUSTACHE_API_PUBLIC;
+ (id)templateLoaderWithBundle:(NSBundle *)bundle options:(GRMustacheTemplateOptions)options GRMUSTACHE_API_PUBLIC;
+ (id)templateLoaderWithBundle:(NSBundle *)bundle extension:(NSString *)ext GRMUSTACHE_API_PUBLIC;
+ (id)templateLoaderWithBundle:(NSBundle *)bundle extension:(NSString *)ext options:(GRMustacheTemplateOptions)options GRMUSTACHE_API_PUBLIC;
+ (id)templateLoaderWithBundle:(NSBundle *)bundle extension:(NSString *)ext encoding:(NSStringEncoding)encoding GRMUSTACHE_API_PUBLIC;
+ (id)templateLoaderWithBundle:(NSBundle *)bundle extension:(NSString *)ext encoding:(NSStringEncoding)encoding options:(GRMustacheTemplateOptions)options GRMUSTACHE_API_PUBLIC;

#pragma mark Base URL

#if !TARGET_OS_IPHONE || GRMUSTACHE_IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
+ (id<GRMustacheURLTemplateLoader>)templateLoaderWithBaseURL:(NSURL *)URL GRMUSTACHE_API_PUBLIC;
+ (id<GRMustacheURLTemplateLoader>)templateLoaderWithBaseURL:(NSURL *)URL options:(GRMustacheTemplateOptions)options GRMUSTACHE_API_PUBLIC;
+ (id<GRMustacheURLTemplateLoader>)templateLoaderWithBaseURL:(NSURL *)URL extension:(NSString *)ext GRMUSTACHE_API_PUBLIC;
+ (id<GRMustacheURLTemplateLoader>)templateLoaderWithBaseURL:(NSURL *)URL extension:(NSString *)ext options:(GRMustacheTemplateOptions)options GRMUSTACHE_API_PUBLIC;
+ (id<GRMustacheURLTemplateLoader>)templateLoaderWithBaseURL:(NSURL *)URL extension:(NSString *)ext encoding:(NSStringEncoding)encoding GRMUSTACHE_API_PUBLIC;
+ (id<GRMustacheURLTemplateLoader>)templateLoaderWithBaseURL:(NSURL *)URL extension:(NSString *)ext encoding:(NSStringEncoding)encoding options:(GRMustacheTemplateOptions)options GRMUSTACHE_API_PUBLIC;
#endif

#pragma mark Template by name

- (GRMustacheTemplate *)parseTemplateNamed:(NSString *)name error:(NSError **)outError GRMUSTACHE_API_DEPRECATED_PUBLIC;
- (GRMustacheTemplate *)templateWithName:(NSString *)name error:(NSError **)outError GRMUSTACHE_API_PUBLIC;
- (GRMustacheTemplate *)templateWithName:(NSString *)name relativeToTemplateId:(id)templateId asPartial:(BOOL)partial error:(NSError **)outError GRMUSTACHE_API_INTERNAL;

#pragma mark Template from string

- (GRMustacheTemplate *)parseString:(NSString *)templateString error:(NSError **)outError GRMUSTACHE_API_DEPRECATED_PUBLIC;
- (GRMustacheTemplate *)templateFromString:(NSString *)templateString error:(NSError **)outError GRMUSTACHE_API_PUBLIC;
- (GRMustacheTemplate *)templateWithElements:(NSArray *)elements GRMUSTACHE_API_INTERNAL;

#pragma mark Template IDs

- (id)templateIdForTemplateNamed:(NSString *)name relativeToTemplateId:(id)baseTemplateId GRMUSTACHE_API_PUBLIC;
- (NSString *)templateStringForTemplateId:(id)templateId error:(NSError **)outError GRMUSTACHE_API_PUBLIC;
- (void)setTemplate:(GRMustacheTemplate *)template forTemplateId:(id)templateId GRMUSTACHE_API_INTERNAL;

@end
