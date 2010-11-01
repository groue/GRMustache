//
//  GRMustacheElement_private.h
//

#import "GRMustacheElement.h"


@class GRMustacheContext;

@interface GRMustacheElement()
- (NSString *)renderContext:(GRMustacheContext *)context;
@end
