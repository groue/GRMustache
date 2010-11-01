//
//  GRMustacheContext_private.h
//

#import "GRMustacheContext.h"


@interface GRMustacheContext()
@property (nonatomic, retain) NSMutableArray *objects;
+ (id)contextWithObject:(id)object;
- (void)pushObject:(id)object;
- (void)pop;
@end
