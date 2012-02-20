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
#import "GRMustacheTemplate_private.h"
#import <Foundation/Foundation.h>


@class GRMustacheTemplate;

#if !TARGET_OS_IPHONE || GRMUSTACHE_IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
@protocol GRMustacheURLTemplateLoader<NSObject>
- (GRMustacheTemplate *)parseContentsOfURL:(NSURL *)templateURL error:(NSError **)outError;
@end
#endif

@protocol GRMustachePathTemplateLoader<NSObject>
- (GRMustacheTemplate *)parseContentsOfFile:(NSString *)templatePath error:(NSError **)outError;
@end


@interface GRMustacheTemplateLoader: NSObject {
@private
    NSString *_extension;
    NSStringEncoding _encoding;
    NSMutableDictionary *_templatesById;
    GRMustacheTemplateOptions _options;
}
@property (nonatomic, readonly, copy) NSString *extension;
@property (nonatomic, readonly) NSStringEncoding encoding;
@property (nonatomic, readonly) GRMustacheTemplateOptions options;

#if !TARGET_OS_IPHONE || GRMUSTACHE_IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
+ (id<GRMustacheURLTemplateLoader>)templateLoaderWithBaseURL:(NSURL *)URL;
+ (id<GRMustacheURLTemplateLoader>)templateLoaderWithBaseURL:(NSURL *)URL options:(GRMustacheTemplateOptions)options;
#endif

+ (id<GRMustachePathTemplateLoader>)templateLoaderWithBasePath:(NSString *)path __attribute__((deprecated));

+ (id<GRMustachePathTemplateLoader>)templateLoaderWithDirectory:(NSString *)path;
+ (id<GRMustachePathTemplateLoader>)templateLoaderWithDirectory:(NSString *)path options:(GRMustacheTemplateOptions)options;

#if !TARGET_OS_IPHONE || GRMUSTACHE_IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
+ (id<GRMustacheURLTemplateLoader>)templateLoaderWithBaseURL:(NSURL *)URL extension:(NSString *)ext;
+ (id<GRMustacheURLTemplateLoader>)templateLoaderWithBaseURL:(NSURL *)URL extension:(NSString *)ext options:(GRMustacheTemplateOptions)options;
#endif

+ (id<GRMustachePathTemplateLoader>)templateLoaderWithBasePath:(NSString *)path extension:(NSString *)ext __attribute__((deprecated));

+ (id<GRMustachePathTemplateLoader>)templateLoaderWithDirectory:(NSString *)path extension:(NSString *)ext;
+ (id<GRMustachePathTemplateLoader>)templateLoaderWithDirectory:(NSString *)path extension:(NSString *)ext options:(GRMustacheTemplateOptions)options;

#if !TARGET_OS_IPHONE || GRMUSTACHE_IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
+ (id<GRMustacheURLTemplateLoader>)templateLoaderWithBaseURL:(NSURL *)URL extension:(NSString *)ext encoding:(NSStringEncoding)encoding;
+ (id<GRMustacheURLTemplateLoader>)templateLoaderWithBaseURL:(NSURL *)URL extension:(NSString *)ext encoding:(NSStringEncoding)encoding options:(GRMustacheTemplateOptions)options;
#endif

+ (id<GRMustachePathTemplateLoader>)templateLoaderWithBasePath:(NSString *)path extension:(NSString *)ext encoding:(NSStringEncoding)encoding __attribute__((deprecated));

+ (id<GRMustachePathTemplateLoader>)templateLoaderWithDirectory:(NSString *)path extension:(NSString *)ext encoding:(NSStringEncoding)encoding;
+ (id<GRMustachePathTemplateLoader>)templateLoaderWithDirectory:(NSString *)path extension:(NSString *)ext encoding:(NSStringEncoding)encoding options:(GRMustacheTemplateOptions)options;

+ (id)templateLoaderWithBundle:(NSBundle *)bundle;
+ (id)templateLoaderWithBundle:(NSBundle *)bundle options:(GRMustacheTemplateOptions)options;

+ (id)templateLoaderWithBundle:(NSBundle *)bundle extension:(NSString *)ext;
+ (id)templateLoaderWithBundle:(NSBundle *)bundle extension:(NSString *)ext options:(GRMustacheTemplateOptions)options;

+ (id)templateLoaderWithBundle:(NSBundle *)bundle extension:(NSString *)ext encoding:(NSStringEncoding)encoding;
+ (id)templateLoaderWithBundle:(NSBundle *)bundle extension:(NSString *)ext encoding:(NSStringEncoding)encoding options:(GRMustacheTemplateOptions)options;

- (id)initWithExtension:(NSString *)ext encoding:(NSStringEncoding)encoding;
- (id)initWithExtension:(NSString *)ext encoding:(NSStringEncoding)encoding options:(GRMustacheTemplateOptions)options;

- (GRMustacheTemplate *)parseTemplateNamed:(NSString *)name error:(NSError **)outError;

- (GRMustacheTemplate *)parseString:(NSString *)templateString error:(NSError **)outError;

- (GRMustacheTemplate *)parseTemplateNamed:(NSString *)name relativeToTemplateId:(id)templateId asPartial:(BOOL)partial error:(NSError **)outError;

- (GRMustacheTemplate *)templateWithElements:(NSArray *)elements;

- (id)templateIdForTemplateNamed:(NSString *)name relativeToTemplateId:(id)baseTemplateId;

- (NSString *)templateStringForTemplateId:(id)templateId error:(NSError **)outError;

- (void)setTemplate:(GRMustacheTemplate *)template forTemplateId:(id)templateId;
@end
