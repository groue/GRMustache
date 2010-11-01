//
//  GRMustacheLambda.m
//

#import "GRMustacheLambda_private.h"


@interface GRMustacheLambdaBlockWrapper()
+ (id)lambdaWithBlock:(GRMustacheLambdaBlock)block;
- (id)initWithBlock:(GRMustacheLambdaBlock)block;
@end


@implementation GRMustacheLambdaBlockWrapper

+ (id)lambdaWithBlock:(GRMustacheLambdaBlock)block {
	return [[[self alloc] initWithBlock:block] autorelease];
}

- (id)initWithBlock:(GRMustacheLambdaBlock)theBlock {
	if (self = [self init]) {
		block = [theBlock copy];
	}
	return self;
}

- (NSString *)renderContext:(GRMustacheContext *)context fromString:(NSString *)templateString renderer:(GRMustacheRenderer)renderer {
	return block(context, templateString, renderer);
}

- (void)dealloc {
	[block release];
	[super dealloc];
}

@end


GRMustacheLambda GRMustacheLambdaMake(GRMustacheLambdaBlock block) {
	return [GRMustacheLambdaBlockWrapper lambdaWithBlock:block];
}
