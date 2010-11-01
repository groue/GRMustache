//
//  GRMustacheVariableElement.m
//

#import "GRMustacheVariableElement_private.h"


@interface GRMustacheVariableElement()
@property (nonatomic, retain) NSString *name;
@property (nonatomic) BOOL raw;
- (id)initWithName:(NSString *)name raw:(BOOL)raw;
- (NSString *)htmlEscape:(NSString *)string;
@end


@implementation GRMustacheVariableElement
@synthesize name;
@synthesize raw;

+ (id)variableElementWithName:(NSString *)name raw:(BOOL)raw {
	return [[[self alloc] initWithName:name raw:raw] autorelease];
}

- (id)initWithName:(NSString *)theName raw:(BOOL)theRaw {
	if (self = [self init]) {
		self.name = theName;
		self.raw = theRaw;
	}
	return self;
}

- (NSString *)htmlEscape:(NSString *)string {
    NSString *result = [string stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"];
    result = [result stringByReplacingOccurrencesOfString:@"<" withString:@"&lt;"];
    result = [result stringByReplacingOccurrencesOfString:@">" withString:@"&gt;"];
    result = [result stringByReplacingOccurrencesOfString:@"\"" withString:@"&quot;"];
    result = [result stringByReplacingOccurrencesOfString:@"\'" withString:@"&apos;"];
    return result;
}

- (NSString *)renderContext:(GRMustacheContext *)context {
	id value = [context valueForKey:name];
	if (value != nil && value != [NSNull null]) {
		if (raw) {
			return [value description];
		} else {
			return [self htmlEscape:[value description]];
		}
	}
	return @"";
}

- (void)dealloc {
	[name release];
	[super dealloc];
}

@end

