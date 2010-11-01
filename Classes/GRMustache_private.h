//
//  GRMustache_private.h
//

#import "GRMustache.h"


typedef enum {
	GRMustacheObjectKindTrueValue,
	GRMustacheObjectKindFalseValue,
	GRMustacheObjectKindContext,
	GRMustacheObjectKindEnumerable,
	GRMustacheObjectKindLambda,
} GRMustacheObjectKind;


@interface GRMustache: NSObject
+ (GRMustacheObjectKind)objectKind:(id)object;
@end

