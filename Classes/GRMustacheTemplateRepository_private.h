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

extern NSString* const GRMustacheDefaultExtension;

@class GRMustacheTemplate;
@class GRMustacheTemplateRepository;

@protocol GRMustacheTemplateRepositoryDataSource <NSObject>
- (id)templateRepository:(GRMustacheTemplateRepository *)templateRepository templateIDForName:(NSString *)name relativeToTemplateID:(id)templateID;
- (NSString *)templateRepository:(GRMustacheTemplateRepository *)templateRepository templateStringForTemplateID:(id)templateID error:(NSError **)outError;
@end

@interface GRMustacheTemplateRepository : NSObject {
@private
    id<GRMustacheTemplateRepositoryDataSource> _dataSource;
    GRMustacheTemplateOptions _options;
    NSMutableDictionary *_templateForTemplateID;
    id _currentlyParsedTemplateID;
}
@property (nonatomic, assign) id<GRMustacheTemplateRepositoryDataSource> dataSource GRMUSTACHE_API_PUBLIC;

#if !TARGET_OS_IPHONE || GRMUSTACHE_IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
+ (id)templateRepositoryWithBaseURL:(NSURL *)URL GRMUSTACHE_API_PUBLIC;
+ (id)templateRepositoryWithBaseURL:(NSURL *)URL options:(GRMustacheTemplateOptions)options GRMUSTACHE_API_PUBLIC;
+ (id)templateRepositoryWithBaseURL:(NSURL *)URL templateExtension:(NSString *)ext GRMUSTACHE_API_PUBLIC;
+ (id)templateRepositoryWithBaseURL:(NSURL *)URL templateExtension:(NSString *)ext options:(GRMustacheTemplateOptions)options GRMUSTACHE_API_PUBLIC;
+ (id)templateRepositoryWithBaseURL:(NSURL *)URL templateExtension:(NSString *)ext GRMUSTACHE_API_PUBLIC;
+ (id)templateRepositoryWithBaseURL:(NSURL *)URL templateExtension:(NSString *)ext encoding:(NSStringEncoding)encoding GRMUSTACHE_API_PUBLIC;
+ (id)templateRepositoryWithBaseURL:(NSURL *)URL templateExtension:(NSString *)ext encoding:(NSStringEncoding)encoding options:(GRMustacheTemplateOptions)options GRMUSTACHE_API_PUBLIC;
#endif /* !TARGET_OS_IPHONE || GRMUSTACHE_IPHONE_OS_VERSION_MAX_ALLOWED >= 40000 */

+ (id)templateRepositoryWithDirectory:(NSString *)path GRMUSTACHE_API_PUBLIC;
+ (id)templateRepositoryWithDirectory:(NSString *)path options:(GRMustacheTemplateOptions)options GRMUSTACHE_API_PUBLIC;
+ (id)templateRepositoryWithDirectory:(NSString *)path templateExtension:(NSString *)ext GRMUSTACHE_API_PUBLIC;
+ (id)templateRepositoryWithDirectory:(NSString *)path templateExtension:(NSString *)ext options:(GRMustacheTemplateOptions)options GRMUSTACHE_API_PUBLIC;
+ (id)templateRepositoryWithDirectory:(NSString *)path templateExtension:(NSString *)ext encoding:(NSStringEncoding)encoding GRMUSTACHE_API_PUBLIC;
+ (id)templateRepositoryWithDirectory:(NSString *)path templateExtension:(NSString *)ext encoding:(NSStringEncoding)encoding options:(GRMustacheTemplateOptions)options GRMUSTACHE_API_PUBLIC;

+ (id)templateRepositoryWithBundle:(NSBundle *)bundle GRMUSTACHE_API_PUBLIC;
+ (id)templateRepositoryWithBundle:(NSBundle *)bundle options:(GRMustacheTemplateOptions)options GRMUSTACHE_API_PUBLIC;
+ (id)templateRepositoryWithBundle:(NSBundle *)bundle templateExtension:(NSString *)ext GRMUSTACHE_API_PUBLIC;
+ (id)templateRepositoryWithBundle:(NSBundle *)bundle templateExtension:(NSString *)ext options:(GRMustacheTemplateOptions)options GRMUSTACHE_API_PUBLIC;
+ (id)templateRepositoryWithBundle:(NSBundle *)bundle templateExtension:(NSString *)ext directory:(NSString *)subpath GRMUSTACHE_API_PUBLIC;
+ (id)templateRepositoryWithBundle:(NSBundle *)bundle templateExtension:(NSString *)ext directory:(NSString *)subpath options:(GRMustacheTemplateOptions)options GRMUSTACHE_API_PUBLIC;
+ (id)templateRepositoryWithBundle:(NSBundle *)bundle templateExtension:(NSString *)ext directory:(NSString *)subpath encoding:(NSStringEncoding)encoding GRMUSTACHE_API_PUBLIC;
+ (id)templateRepositoryWithBundle:(NSBundle *)bundle templateExtension:(NSString *)ext directory:(NSString *)subpath encoding:(NSStringEncoding)encoding options:(GRMustacheTemplateOptions)options GRMUSTACHE_API_PUBLIC;

+ (id)templateRepositoryWithPartialsDictionary:(NSDictionary *)partialsDictionary GRMUSTACHE_API_PUBLIC;
+ (id)templateRepositoryWithPartialsDictionary:(NSDictionary *)partialsDictionary options:(GRMustacheTemplateOptions)options GRMUSTACHE_API_PUBLIC;

+ (id)templateRepository GRMUSTACHE_API_PUBLIC;
+ (id)templateRepositoryWithOptions:(GRMustacheTemplateOptions)options GRMUSTACHE_API_PUBLIC;

- (GRMustacheTemplate *)templateForName:(NSString *)name error:(NSError **)outError GRMUSTACHE_API_PUBLIC;
- (GRMustacheTemplate *)templateFromString:(NSString *)templateString error:(NSError **)outError GRMUSTACHE_API_PUBLIC;
@end
