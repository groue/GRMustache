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
#import "GRMustacheAvailabilityMacros.h"
#import "GRMustache.h"

@class GRMustacheTemplate;
@class GRMustacheTemplateRepository;

/**
 The protocol for a GRMustacheTemplateRepository's dataSource.
 
 The dataSource's responsability is to provide template strings, and to encapsulate
 a logic for accessing partials.
 */
@protocol GRMustacheTemplateRepositoryDataSource <NSObject>
@required

/**
 Returns a template ID, an object that uniquely identifies a template or a template partial.
 
 The class of this ID is opaque: the GRMustacheTemplateRepositoryDataSource
 defines, for itself, what should identity a template or a partial.
 
 For instance, a file-based data source may use NSString objects containing paths to the templates.
 
 Template and partial hierarchies are supported via the _baseTemplateID_ parameter: it contains
 nil for "root" templates name, and the template ID of the enclosing template for partial names.
 Not all data sources have to implement hierarchies: they can simply ignore this parameter.
 
 The returned value can be nil: the library user would then eventually get an NSError of domain
 GRMustacheErrorDomain and code GRMustacheErrorCodeTemplateNotFound.
 
 @return a template ID
 @param templateRepository The GRMustacheTemplateRepository asking for a template ID.
 @param name The name of the template or template partial.
 @param templateID When name is the name of a template partial, this is the template ID of the enclosing template.
 */
- (id)templateRepository:(GRMustacheTemplateRepository *)templateRepository templateIDForName:(NSString *)name relativeToTemplateID:(id)baseTemplateID AVAILABLE_GRMUSTACHE_VERSION_4_0_AND_LATER;

/**
 Provided with a template ID that comes from templateRepository:templateIDForName:relativeToTemplateID:,
 returns a template string.

 For instance, a file-based data source may interpret the template ID as a NSString object
 containing paths to the template, and return the file content.
 
 Should this method return nil, the _outError_ parameter should be point to an NSError, or nil.
 If set to an NSError, this error would eventually reach the library user. If set to nil, GRMustache
 would generate an NSError of domain GRMustacheErrorDomain and code GRMustacheErrorCodeTemplateNotFound.
 If your implementation does not touch the _outError_ parameter, it would point to nil upon return.

 @return a template string
 @param templateRepository The GRMustacheTemplateRepository asking for a template string.
 @param templateID The template ID of the template
 @param outError If there is an error returning a template string, upon return contains nil, or an NSError object that describes the problem.
 */
- (NSString *)templateRepository:(GRMustacheTemplateRepository *)templateRepository templateStringForTemplateID:(id)templateID error:(NSError **)outError AVAILABLE_GRMUSTACHE_VERSION_4_0_AND_LATER;
@end

@interface GRMustacheTemplateRepository : NSObject {
@private
    id<GRMustacheTemplateRepositoryDataSource> _dataSource;
    NSMutableDictionary *_templateForTemplateID;
    id _currentlyParsedTemplateID;
}
@property (nonatomic, assign) id<GRMustacheTemplateRepositoryDataSource> dataSource AVAILABLE_GRMUSTACHE_VERSION_4_0_AND_LATER;

#if !TARGET_OS_IPHONE || __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
+ (id)templateRepositoryWithBaseURL:(NSURL *)URL AVAILABLE_GRMUSTACHE_VERSION_4_0_AND_LATER;
+ (id)templateRepositoryWithBaseURL:(NSURL *)URL templateExtension:(NSString *)ext AVAILABLE_GRMUSTACHE_VERSION_4_0_AND_LATER;
+ (id)templateRepositoryWithBaseURL:(NSURL *)URL templateExtension:(NSString *)ext encoding:(NSStringEncoding)encoding AVAILABLE_GRMUSTACHE_VERSION_4_0_AND_LATER;
#endif /* if !TARGET_OS_IPHONE || __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000 */

+ (id)templateRepositoryWithDirectory:(NSString *)path AVAILABLE_GRMUSTACHE_VERSION_4_0_AND_LATER;
+ (id)templateRepositoryWithDirectory:(NSString *)path templateExtension:(NSString *)ext AVAILABLE_GRMUSTACHE_VERSION_4_0_AND_LATER;
+ (id)templateRepositoryWithDirectory:(NSString *)path templateExtension:(NSString *)ext encoding:(NSStringEncoding)encoding AVAILABLE_GRMUSTACHE_VERSION_4_0_AND_LATER;

+ (id)templateRepositoryWithBundle:(NSBundle *)bundle AVAILABLE_GRMUSTACHE_VERSION_4_0_AND_LATER;
+ (id)templateRepositoryWithBundle:(NSBundle *)bundle templateExtension:(NSString *)ext AVAILABLE_GRMUSTACHE_VERSION_4_0_AND_LATER;
+ (id)templateRepositoryWithBundle:(NSBundle *)bundle templateExtension:(NSString *)ext encoding:(NSStringEncoding)encoding AVAILABLE_GRMUSTACHE_VERSION_4_0_AND_LATER;

+ (id)templateRepositoryWithPartialsDictionary:(NSDictionary *)partialsDictionary AVAILABLE_GRMUSTACHE_VERSION_4_0_AND_LATER;

+ (id)templateRepository AVAILABLE_GRMUSTACHE_VERSION_4_0_AND_LATER;

- (GRMustacheTemplate *)templateForName:(NSString *)name error:(NSError **)outError AVAILABLE_GRMUSTACHE_VERSION_4_0_AND_LATER;
- (GRMustacheTemplate *)templateFromString:(NSString *)templateString error:(NSError **)outError AVAILABLE_GRMUSTACHE_VERSION_4_0_AND_LATER;
@end
