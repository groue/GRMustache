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

#if (TARGET_OS_IPHONE)
// http://iphonedevelopment.blogspot.com/2008/10/device-vs-simulator.html
#import <objc/runtime.h>
#import <objc/message.h>
#else
#import <objc/objc-runtime.h>
#endif

#import "GRMustache_private.h"
#import "GRMustacheContext_private.h"


static NSInteger BOOLPropertyType = NSNotFound;

@interface GRMustacheProperty: NSObject
@property BOOL BOOLProperty;
+ (BOOL)class:(Class)class hasBOOLPropertyNamed:(NSString *)propertyName;
@end

@implementation GRMustacheProperty
@dynamic BOOLProperty;

+ (NSInteger)typeForPropertyNamed:(NSString *)propertyName ofClass:(Class)class {
	objc_property_t property = class_getProperty(class, [propertyName cStringUsingEncoding:NSUTF8StringEncoding]);
	if (property != NULL) {
		const char *attributesCString = property_getAttributes(property);
		while (attributesCString) {
			if (attributesCString[0] == 'T') {
				return attributesCString[1];
			}
			attributesCString = strchr(attributesCString, ',');
			if (attributesCString) {
				attributesCString++;
			}
		}
	}
	return NSNotFound;
}

+ (BOOL)class:(Class)class hasBOOLPropertyNamed:(NSString *)propertyName {
	static NSMutableDictionary *classes = nil;
	
	if (classes == nil) {
		classes = [[NSMutableDictionary dictionaryWithCapacity:12] retain];
	}
	
	NSMutableDictionary *propertyNames = [classes objectForKey:class];
	if (propertyNames == nil) {
		propertyNames = [[NSMutableDictionary dictionaryWithCapacity:4] retain];
		[classes setObject:propertyNames forKey:class];
	}
	
	NSNumber *boolNumber = [propertyNames objectForKey:propertyName];
	if (boolNumber == nil) {
		if (BOOLPropertyType == NSNotFound) {
			BOOLPropertyType = [self typeForPropertyNamed:@"BOOLProperty" ofClass:self];
		}
		BOOL booleanProperty = ([self typeForPropertyNamed:propertyName ofClass:class] == BOOLPropertyType);
		[propertyNames setObject:[NSNumber numberWithBool:booleanProperty] forKey:propertyName];
		return booleanProperty;
	}
	
	return [boolNumber boolValue];

}

@end


@interface GRMustacheContext()
@property (nonatomic, retain) NSMutableArray *objects;
- (id)initWithObject:(id)object;
- (BOOL)shouldConsiderObject:(id)object value:(id)value forKey:(NSString *)key asBoolean:(BOOL *)outBool;
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
		case GRMustacheObjectKindTrueValue:
			[objects addObject:object];
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
	
	for (id object in [objects reverseObjectEnumerator]) {
		if (object == [NSNull null]) {
			continue;
		}
		
		if (dotKey) {
			return object;
		}
		
		@try {
			value = [object valueForKey:key];
		}
		@catch (NSException *exception) {
			if (![[exception name] isEqualToString:NSUndefinedKeyException] ||
				[[exception userInfo] objectForKey:@"NSTargetObjectUserInfoKey"] != object ||
				![[[exception userInfo] objectForKey:@"NSUnknownUserInfoKey"] isEqualToString:key])
			{
				// that's some exception we are not related to
				@throw;
			}
			continue;
		}
		
		if (value != nil) {
			BOOL boolValue;
			if ([self shouldConsiderObject:object value:value forKey:key asBoolean:&boolValue]) {
				if (boolValue) {
					return [GRYes yes];
				} else {
					return [GRNo no];
				}
			}
			return value;
		}
	}
	
	return nil;
}

- (void)dealloc {
	[objects release];
	[super dealloc];
}

- (BOOL)shouldConsiderObject:(id)object value:(id)value forKey:(NSString *)key asBoolean:(BOOL *)outBool {
	// C99 bool type
	if (CFBooleanGetTypeID() == CFGetTypeID(value)) {
		if (outBool) {
			*outBool = CFBooleanGetValue((CFBooleanRef)value);
		}
		return YES;
	}
	
	if (![GRMustache strictBooleanMode] && [GRMustacheProperty class:[object class] hasBOOLPropertyNamed:key]) {
		if (outBool) {
			*outBool = [(NSNumber *)value boolValue];
		}
		return YES;
	}
	
	return NO;
}

@end
