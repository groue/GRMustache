//
//  GRMustacheContext.m
//

#import "GRMustache_private.h"
#import "GRMustacheContext_private.h"


@interface GRMustacheContext()
- (id)initWithObject:(id)object;
@end


@implementation GRMustacheContext
@synthesize objects;

+ (id)contextWithObject:(id)object {
	return [[[self alloc] initWithObject:object] autorelease];
}

- (id)initWithObject:(id)object {
	if (self = [self init]) {
		objects = [[NSMutableArray arrayWithCapacity:4] retain];
		[self pushObject:object];
	}
	return self;
}

- (void)pushObject:(id)object {
	switch ([GRMustache objectKind:object]) {
		case GRMustacheObjectKindFalseValue:
			[objects addObject:[NSNull null]];
			break;
		case GRMustacheObjectKindContext:
		case GRMustacheObjectKindLambda:
			[objects addObject:object];
			break;
		default:
			NSAssert(NO, @"object is not a NSDictionary, or does not conform to GRMustacheContext protocol, or is not a GRMustacheLambda.");
			break;
	}
}

- (void)pop {
	[objects removeLastObject];
}

- (id)valueForKey:(NSString *)key {
	id value;
	for (id object in [objects reverseObjectEnumerator]) {
		if (object == [NSNull null]) {
			continue;
		}
		value = [object valueForKey:key];
		if (value != nil) {
			return value;
		}
	}
	
	return nil;
}

- (void)dealloc {
	[objects release];
	[super dealloc];
}

@end
