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
#import "GRMustacheAvailabilityMacros_private.h"
#import "GRMustache_private.h"

@class GRMustacheTemplate;
@class GRMustacheTemplateRepository;
@protocol GRMustacheRenderingElement;

// Documented in GRMustacheTemplateRepository.h
@protocol GRMustacheTemplateRepositoryDataSource <NSObject>

// Documented in GRMustacheTemplateRepository.h
- (id<NSCopying>)templateRepository:(GRMustacheTemplateRepository *)templateRepository templateIDForName:(NSString *)name relativeToTemplateID:(id)baseTemplateID GRMUSTACHE_API_PUBLIC;

// Documented in GRMustacheTemplateRepository.h
- (NSString *)templateRepository:(GRMustacheTemplateRepository *)templateRepository templateStringForTemplateID:(id)templateID error:(NSError **)outError GRMUSTACHE_API_PUBLIC;
@end

// Documented in GRMustacheTemplateRepository.h
@interface GRMustacheTemplateRepository : NSObject {
@private
    id<GRMustacheTemplateRepositoryDataSource> _dataSource;
    NSMutableDictionary *_templateForTemplateID;
    id _currentlyParsedTemplateID;
}

// Documented in GRMustacheTemplateRepository.h
@property (nonatomic, assign) id<GRMustacheTemplateRepositoryDataSource> dataSource GRMUSTACHE_API_PUBLIC;

// Documented in GRMustacheTemplateRepository.h
+ (id)templateRepositoryWithBaseURL:(NSURL *)URL GRMUSTACHE_API_PUBLIC;

// Documented in GRMustacheTemplateRepository.h
+ (id)templateRepositoryWithBaseURL:(NSURL *)URL templateExtension:(NSString *)ext GRMUSTACHE_API_PUBLIC;

// Documented in GRMustacheTemplateRepository.h
+ (id)templateRepositoryWithBaseURL:(NSURL *)URL templateExtension:(NSString *)ext GRMUSTACHE_API_PUBLIC;

// Documented in GRMustacheTemplateRepository.h
+ (id)templateRepositoryWithBaseURL:(NSURL *)URL templateExtension:(NSString *)ext encoding:(NSStringEncoding)encoding GRMUSTACHE_API_PUBLIC;

// Documented in GRMustacheTemplateRepository.h
+ (id)templateRepositoryWithDirectory:(NSString *)path GRMUSTACHE_API_PUBLIC;

// Documented in GRMustacheTemplateRepository.h
+ (id)templateRepositoryWithDirectory:(NSString *)path templateExtension:(NSString *)ext GRMUSTACHE_API_PUBLIC;

// Documented in GRMustacheTemplateRepository.h
+ (id)templateRepositoryWithDirectory:(NSString *)path templateExtension:(NSString *)ext encoding:(NSStringEncoding)encoding GRMUSTACHE_API_PUBLIC;

// Documented in GRMustacheTemplateRepository.h
+ (id)templateRepositoryWithBundle:(NSBundle *)bundle GRMUSTACHE_API_PUBLIC;

// Documented in GRMustacheTemplateRepository.h
+ (id)templateRepositoryWithBundle:(NSBundle *)bundle templateExtension:(NSString *)ext GRMUSTACHE_API_PUBLIC;

// Documented in GRMustacheTemplateRepository.h
+ (id)templateRepositoryWithBundle:(NSBundle *)bundle templateExtension:(NSString *)ext encoding:(NSStringEncoding)encoding GRMUSTACHE_API_PUBLIC;

// Documented in GRMustacheTemplateRepository.h
+ (id)templateRepositoryWithPartialsDictionary:(NSDictionary *)partialsDictionary GRMUSTACHE_API_PUBLIC;

// Documented in GRMustacheTemplateRepository.h
+ (id)templateRepository GRMUSTACHE_API_PUBLIC;

// Documented in GRMustacheTemplateRepository.h
- (GRMustacheTemplate *)templateForName:(NSString *)name error:(NSError **)outError GRMUSTACHE_API_PUBLIC;

// Documented in GRMustacheTemplateRepository.h
- (GRMustacheTemplate *)templateFromString:(NSString *)templateString error:(NSError **)outError GRMUSTACHE_API_PUBLIC;

@end
