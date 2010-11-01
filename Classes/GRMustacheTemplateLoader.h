//
//  GRMustacheTemplateLoader.h
//

#import <Foundation/Foundation.h>


@class GRMustacheTemplate;

@interface GRMustacheTemplateLoader: NSObject {
	NSString *extension;
	NSMutableDictionary *templatesByURL;
}
+ (id)templateLoaderWithURL:(NSURL *)url;
+ (id)templateLoaderWithURL:(NSURL *)url extension:(NSString *)ext;
+ (id)templateLoaderWithBundle:(NSBundle *)bundle;
+ (id)templateLoaderWithBundle:(NSBundle *)bundle extension:(NSString *)ext;
- (GRMustacheTemplate *)parseTemplateNamed:(NSString *)name error:(NSError **)outError;
@end
