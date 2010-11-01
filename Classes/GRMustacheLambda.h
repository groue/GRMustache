//
//  GRMustacheLambda.h
//

#import <Foundation/Foundation.h>
#import "GRMustacheContext.h"


typedef NSString *(^GRMustacheRenderer)(NSString *, NSError **);
typedef NSString *(^GRMustacheLambdaBlock)(GRMustacheContext *, NSString *, GRMustacheRenderer);
typedef id GRMustacheLambda;

GRMustacheLambda GRMustacheLambdaMake(GRMustacheLambdaBlock block);
