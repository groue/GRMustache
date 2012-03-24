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
#import "GRMustacheEnvironment.h"
#import "GRMustacheAvailabilityMacros_private.h"
#import "GRMustache_private.h"

@class GRMustacheTemplateRepository;
@class GRMustacheTemplate;

@interface GRMustacheTemplateLoader: NSObject {
@private
    GRMustacheTemplateRepository *_templateRepository;
    NSString *_extension;
    NSStringEncoding _encoding;
    GRMustacheTemplateOptions _options;
}

#if !TARGET_OS_IPHONE || GRMUSTACHE_IPHONE_OS_VERSION_MAX_ALLOWED >= 40000

+ (id)templateLoaderWithBaseURL:(NSURL *)URL GRMUSTACHE_API_PUBLIC_BUT_DEPRECATED;
+ (id)templateLoaderWithBaseURL:(NSURL *)URL options:(GRMustacheTemplateOptions)options GRMUSTACHE_API_PUBLIC_BUT_DEPRECATED;
+ (id)templateLoaderWithBaseURL:(NSURL *)URL extension:(NSString *)ext GRMUSTACHE_API_PUBLIC_BUT_DEPRECATED;
+ (id)templateLoaderWithBaseURL:(NSURL *)URL extension:(NSString *)ext options:(GRMustacheTemplateOptions)options GRMUSTACHE_API_PUBLIC_BUT_DEPRECATED;
+ (id)templateLoaderWithBaseURL:(NSURL *)URL extension:(NSString *)ext encoding:(NSStringEncoding)encoding GRMUSTACHE_API_PUBLIC_BUT_DEPRECATED;
+ (id)templateLoaderWithBaseURL:(NSURL *)URL extension:(NSString *)ext encoding:(NSStringEncoding)encoding options:(GRMustacheTemplateOptions)options GRMUSTACHE_API_PUBLIC_BUT_DEPRECATED;

#endif /* if !TARGET_OS_IPHONE || GRMUSTACHE_IPHONE_OS_VERSION_MAX_ALLOWED >= 40000 */

+ (id)templateLoaderWithBasePath:(NSString *)path GRMUSTACHE_API_PUBLIC_BUT_DEPRECATED;
+ (id)templateLoaderWithBasePath:(NSString *)path extension:(NSString *)ext GRMUSTACHE_API_PUBLIC_BUT_DEPRECATED;
+ (id)templateLoaderWithBasePath:(NSString *)path extension:(NSString *)ext encoding:(NSStringEncoding)encoding GRMUSTACHE_API_PUBLIC_BUT_DEPRECATED;

+ (id)templateLoaderWithDirectory:(NSString *)path GRMUSTACHE_API_PUBLIC_BUT_DEPRECATED;
+ (id)templateLoaderWithDirectory:(NSString *)path options:(GRMustacheTemplateOptions)options GRMUSTACHE_API_PUBLIC_BUT_DEPRECATED;
+ (id)templateLoaderWithDirectory:(NSString *)path extension:(NSString *)ext GRMUSTACHE_API_PUBLIC_BUT_DEPRECATED;
+ (id)templateLoaderWithDirectory:(NSString *)path extension:(NSString *)ext options:(GRMustacheTemplateOptions)options GRMUSTACHE_API_PUBLIC_BUT_DEPRECATED;
+ (id)templateLoaderWithDirectory:(NSString *)path extension:(NSString *)ext encoding:(NSStringEncoding)encoding GRMUSTACHE_API_PUBLIC_BUT_DEPRECATED;
+ (id)templateLoaderWithDirectory:(NSString *)path extension:(NSString *)ext encoding:(NSStringEncoding)encoding options:(GRMustacheTemplateOptions)options GRMUSTACHE_API_PUBLIC_BUT_DEPRECATED;

+ (id)templateLoaderWithBundle:(NSBundle *)bundle GRMUSTACHE_API_PUBLIC_BUT_DEPRECATED;
+ (id)templateLoaderWithBundle:(NSBundle *)bundle options:(GRMustacheTemplateOptions)options GRMUSTACHE_API_PUBLIC_BUT_DEPRECATED;
+ (id)templateLoaderWithBundle:(NSBundle *)bundle extension:(NSString *)ext GRMUSTACHE_API_PUBLIC_BUT_DEPRECATED;
+ (id)templateLoaderWithBundle:(NSBundle *)bundle extension:(NSString *)ext options:(GRMustacheTemplateOptions)options GRMUSTACHE_API_PUBLIC_BUT_DEPRECATED;
+ (id)templateLoaderWithBundle:(NSBundle *)bundle extension:(NSString *)ext encoding:(NSStringEncoding)encoding GRMUSTACHE_API_PUBLIC_BUT_DEPRECATED;
+ (id)templateLoaderWithBundle:(NSBundle *)bundle extension:(NSString *)ext encoding:(NSStringEncoding)encoding options:(GRMustacheTemplateOptions)options GRMUSTACHE_API_PUBLIC_BUT_DEPRECATED;

- (GRMustacheTemplate *)parseTemplateNamed:(NSString *)name error:(NSError **)outError GRMUSTACHE_API_PUBLIC_BUT_DEPRECATED;
- (GRMustacheTemplate *)parseString:(NSString *)templateString error:(NSError **)outError GRMUSTACHE_API_PUBLIC_BUT_DEPRECATED;

- (GRMustacheTemplate *)templateWithName:(NSString *)name error:(NSError **)outError GRMUSTACHE_API_PUBLIC_BUT_DEPRECATED;
- (GRMustacheTemplate *)templateFromString:(NSString *)templateString error:(NSError **)outError GRMUSTACHE_API_PUBLIC_BUT_DEPRECATED;
@end
