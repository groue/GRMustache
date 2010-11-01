//
//  GRMustacheTemplateLoader_private.h
//

#import <Foundation/Foundation.h>
#import "GRMustacheTemplateLoader.h"


@interface GRMustacheTemplateLoader()
- (GRMustacheTemplate *)parseTemplateNamed:(NSString *)name relativeToTemplate:(GRMustacheTemplate *)template error:(NSError **)outError;
- (GRMustacheTemplate *)parseContentsOfURL:(NSURL *)url error:(NSError **)outError;
@end
