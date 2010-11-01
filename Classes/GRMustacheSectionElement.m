//
//  GRMustacheSectionElement.m
//

#import "GRMustache_private.h"
#import "GRMustacheContext_private.h"
#import "GRMustacheTemplate_private.h"
#import "GRMustacheLambda_private.h"
#import "GRMustacheSectionElement_private.h"


@interface GRMustacheSectionElement()
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *templateString;
@property (nonatomic, retain) GRMustacheTemplateLoader *templateLoader;
@property (nonatomic) BOOL inverted;
@property (nonatomic, retain) NSArray *elems;
- (id)initWithName:(NSString *)name string:(NSString *)templateString templateLoader:(GRMustacheTemplateLoader *)templateLoader inverted:(BOOL)inverted elements:(NSArray *)elems;
@end


@implementation GRMustacheSectionElement
@synthesize templateLoader;
@synthesize templateString;
@synthesize name;
@synthesize inverted;
@synthesize elems;

+ (id)sectionElementWithName:(NSString *)name string:(NSString *)templateString templateLoader:(GRMustacheTemplateLoader *)templateLoader inverted:(BOOL)inverted elements:(NSArray *)elems {
	return [[[self alloc] initWithName:name string:templateString templateLoader:templateLoader inverted:inverted elements:elems] autorelease];
}

- (id)initWithName:(NSString *)theName string:(NSString *)theTemplateString templateLoader:(GRMustacheTemplateLoader *)theTemplateLoader inverted:(BOOL)theInverted elements:(NSArray *)theElems {
	if (self = [self init]) {
		self.name = theName;
		self.templateString = theTemplateString;
		self.templateLoader = theTemplateLoader;
		self.inverted = theInverted;
		self.elems = theElems;
	}
	return self;
}

- (NSString *)renderContext:(GRMustacheContext *)context {
	id value = [context valueForKey:name];
	NSMutableString *buffer= [NSMutableString stringWithCapacity:1024];
	
	switch([GRMustache objectKind:value]) {
		case GRMustacheObjectKindFalseValue:
			if (inverted) {
				for (GRMustacheElement *elem in elems) {
					[buffer appendString:[elem renderContext:context]];
				}
			}
			break;
			
		case GRMustacheObjectKindTrueValue:
			if (!inverted) {
				for (GRMustacheElement *elem in elems) {
					[buffer appendString:[elem renderContext:context]];
				}
			}
			break;
			
		case GRMustacheObjectKindContext:
			if (!inverted) {
				[context pushObject:value];
				for (GRMustacheElement *elem in elems) {
					[buffer appendString:[elem renderContext:context]];
				}
				[context pop];
			}
			break;
			
		case GRMustacheObjectKindEnumerable:
			if (inverted) {
				BOOL empty = YES;
				for (id object in value) {
					empty = NO;
					break;
				}
				if (empty) {
					for (GRMustacheElement *elem in elems) {
						[buffer appendString:[elem renderContext:context]];
					}
				}
			} else {
				for (id object in value) {
					[context pushObject:object];
					for (GRMustacheElement *elem in elems) {
						[buffer appendString:[elem renderContext:context]];
					}
					[context pop];
				}
			}
			break;
			
		case GRMustacheObjectKindLambda:
			if (!inverted) {
				GRMustacheRenderer renderer = ^(NSString *rewrittenTemplateString, NSError **outError) {
					NSString *result = nil;
					if (rewrittenTemplateString == templateString) {
						// the lambda didn't alter the templateString: don't recompile
						result = [NSMutableString stringWithCapacity:1024];
						for (GRMustacheElement *elem in elems) {
							[(NSMutableString *)result appendString:[elem renderContext:context]];
						}
					} else {
						// reparse
						GRMustacheTemplate *template = [GRMustacheTemplate templateWithString:rewrittenTemplateString url:nil templateLoader:templateLoader];
						if ([template parseAndReturnError:outError]) {
							result = [template renderContext:context];
						}
					}
					return result;
				};
				[buffer appendString:[(GRMustacheLambdaBlockWrapper *)value renderContext:context
																			  fromString:templateString
																				renderer:renderer]];
			}
			break;
			
		default:
			// should not be here
			NSAssert(NO, @"");
	}
	
	return buffer;
}

- (void)dealloc {
	[name release];
	[templateString release];
	[templateLoader release];
	[elems release];
	[super dealloc];
}


@end
