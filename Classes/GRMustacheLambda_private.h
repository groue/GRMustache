//
//  GRMustacheLambda_private.h
//

#import "GRMustacheLambda.h"


@interface GRMustacheLambdaBlockWrapper: NSObject {
	GRMustacheLambdaBlock block;
}
- (NSString *)renderContext:(GRMustacheContext *)context fromString:(NSString *)templateString renderer:(GRMustacheRenderer)renderer;
@end
