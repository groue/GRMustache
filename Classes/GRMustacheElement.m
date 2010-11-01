//
//  GRMustacheElement.h
//

#import "GRMustacheElement_private.h"


@implementation GRMustacheElement

- (NSString *)renderContext:(GRMustacheContext *)context {
	// subclasses should override
	return @"";
}

@end
