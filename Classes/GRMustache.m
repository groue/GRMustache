//
//  GRMustache.m
//

#import "GRMustache_private.h"
#import "GRMustacheLambda_private.h"


@implementation GRMustache

+ (GRMustacheObjectKind)objectKind:(id)object {
	if (object == nil || object == [NSNull null]) {
		return GRMustacheObjectKindFalseValue;
	}
	if ([object isKindOfClass:[NSDictionary class]]) {
		return GRMustacheObjectKindContext;
	}
	if ([object conformsToProtocol:@protocol(GRMustacheContext)]) {
		return GRMustacheObjectKindContext;
	}
	if ([object conformsToProtocol:@protocol(NSFastEnumeration)]) {
		return GRMustacheObjectKindEnumerable;
	}
	if ([object isKindOfClass:[GRMustacheLambdaBlockWrapper class]]) {
		return GRMustacheObjectKindLambda;
	}
	return GRMustacheObjectKindTrueValue;
}

@end
