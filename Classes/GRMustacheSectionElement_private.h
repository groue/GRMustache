//
//  GRMustacheSectionElement_private.h
//

#import <Foundation/Foundation.h>
#import "GRMustacheElement_private.h"


@class GRMustacheTemplateLoader;

@interface GRMustacheSectionElement: GRMustacheElement {
	NSString *name;
	NSString *templateString;
	GRMustacheTemplateLoader *templateLoader;
	BOOL inverted;
	NSArray *elems;
}
+ (id)sectionElementWithName:(NSString *)name string:(NSString *)templateString templateLoader:(GRMustacheTemplateLoader *)templateLoader inverted:(BOOL)inverted elements:(NSArray *)elems;
@end
