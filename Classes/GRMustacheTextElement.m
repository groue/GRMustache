//
//  GRMustacheTextElement.m
//

#import "GRMustacheTextElement_private.h"


@interface GRMustacheTextElement()
@property (nonatomic, retain) NSString *text;
- (id)initWithString:(NSString *)theText;
@end


@implementation GRMustacheTextElement
@synthesize text;

+ (id)textElementWithString:(NSString *)text {
	return [[[self alloc] initWithString:text] autorelease];
}

- (id)initWithString:(NSString *)theText {
	if (self = [self init]) {
		self.text = theText;
	}
	return self;
}

- (NSString *)renderContext:(GRMustacheContext *)context {
	return text;
}

- (void)dealloc {
	[text release];
	[super dealloc];
}
@end


