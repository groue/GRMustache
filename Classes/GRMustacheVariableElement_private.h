//
//  GRMustacheVariableElement_private.h
//

#import "GRMustacheElement_private.h"


@interface GRMustacheVariableElement: GRMustacheElement {
	NSString *name;
	BOOL raw;
}
+ (id)variableElementWithName:(NSString *)name raw:(BOOL)raw;
@end
