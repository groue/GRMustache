//
//  GRMustacheTemplate_private.h
//

#import "GRMustacheTemplate.h"


@class GRMustacheSectionElement;

@interface GRMustacheTemplate()
@property (nonatomic, retain) NSURL *url;
+ (id)templateWithString:(NSString *)templateString url:(NSURL *)url templateLoader:(GRMustacheTemplateLoader *)templateLoader;
- (BOOL)parseAndReturnError:(NSError **)outError;
@end
