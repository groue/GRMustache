// The MIT License
// 
// Copyright (c) 2010 Gwendal Roué
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "GRMustache_private.h"
#import "GRMustacheContext_private.h"


@interface GRMustacheValueWrapper: NSObject<GRMustacheContext> {
	id value;
}
@property (nonatomic, retain) id value;
+ (id)wrapperWithValue:(id)value;
- (id)initWithValue:(id)value;
@end

@implementation GRMustacheValueWrapper
@synthesize value;

+ (id)wrapperWithValue:(id)value {
	return [[[self alloc] initWithValue:value] autorelease];
}

- (id)initWithValue:(id)theValue {
	if (self = [self init]) {
		value = [theValue retain];
	}
	return self;
}

- (NSString *)description {
	return [value description];
}

- (id)valueForKey:(NSString *)key {
	return nil;
}

- (void)dealloc {
	[value release];
	[super dealloc];
}

@end



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
			[objects addObject:object];
			break;
		case GRMustacheObjectKindTrueValue:
			[objects addObject:[GRMustacheValueWrapper wrapperWithValue:object]];
			break;
		default:
			NSAssert(NO, ([NSString stringWithFormat:@"Invalid context object: %@", object]));
			break;
	}
}

- (void)pop {
	[objects removeLastObject];
}

- (id)valueForKey:(NSString *)key {
	id value;
	BOOL dotKey = [key isEqualToString:@"."];
	NSException *firstCatchedException = nil;
	BOOL valueForKeyDidSucceedAtLeastOnce = NO;
	
	for (id object in [objects reverseObjectEnumerator]) {
		if (object == [NSNull null]) {
			continue;
		}
		
		if (dotKey) {
			return object;
		}
		
		@try {
			value = [object valueForKey:key];
			valueForKeyDidSucceedAtLeastOnce = YES;
		}
		@catch (NSException *exception) {
			if (![[exception name] isEqualToString:NSUndefinedKeyException] ||
				[[exception userInfo] objectForKey:@"NSTargetObjectUserInfoKey"] != object ||
				![[[exception userInfo] objectForKey:@"NSUnknownUserInfoKey"] isEqualToString:key])
			{
				// that's some exception we are not related to
				@throw;
			}
			if (firstCatchedException == nil) {
				firstCatchedException = exception;
			}
			continue;
		}
		
		if (value != nil) {
			return value;
		}
	}
	
	if (valueForKeyDidSucceedAtLeastOnce == NO && firstCatchedException != nil) {
		@throw firstCatchedException;
	}
	
	return nil;
}

- (void)dealloc {
	[objects release];
	[super dealloc];
}

@end
