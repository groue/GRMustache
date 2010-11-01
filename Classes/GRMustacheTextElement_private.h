//
//  GRMustacheTextElement_private.h
//

#import <Foundation/Foundation.h>
#import "GRMustacheElement_private.h"


@interface GRMustacheTextElement : GRMustacheElement {
	NSString *text;
}
+ (id)textElementWithString:(NSString *)string;
@end


