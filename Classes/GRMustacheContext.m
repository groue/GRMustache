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
#import "GRMustacheLambda_private.h"
#import "GRMustacheProperty_private.h"
#import "GRMustacheNSUndefinedKeyExceptionGuard_private.h"

static BOOL preventingNSUndefinedKeyExceptionAttack = NO;

@interface GRMustacheContext()
@property (nonatomic, retain) id object;
@property (nonatomic, retain) GRMustacheContext *parent;
- (id)initWithObject:(id)object parent:(GRMustacheContext *)parent;
- (BOOL)shouldConsiderObjectValue:(id)value forKey:(NSString *)key asBoolean:(CFBooleanRef *)outBooleanRef;
- (id)valueForKeyComponent:(NSString *)key;
@end


@implementation GRMustacheContext
@synthesize object;
@synthesize parent;

+ (void)preventNSUndefinedKeyExceptionAttack {
    preventingNSUndefinedKeyExceptionAttack = YES;
}

+ (id)contextWithObject:(id)object {
	if ([object isKindOfClass:[GRMustacheContext class]]) {
		return object;
	}
	return [[[self alloc] initWithObject:object parent:nil] autorelease];
}

+ (id)contextWithObjects:(id)object, ... {
    va_list objectList;
    va_start(objectList, object);
    GRMustacheContext *result = [self contextWithObject:object andObjectList:objectList];
    va_end(objectList);
    return result;
}

+ (id)contextWithObject:(id)object andObjectList:(va_list)objectList {
    GRMustacheContext *context = nil;
    if (object) {
        context = [GRMustacheContext contextWithObject:object];
        id eachObject;
        va_list objectListCopy;
        va_copy(objectListCopy, objectList);
        while ((eachObject = va_arg(objectListCopy, id))) {
            context = [context contextByAddingObject:eachObject];
        }
        va_end(objectListCopy);
    } else {
        context = [self contextWithObject:nil];
    }
    return context;
}

- (id)initWithObject:(id)theObject parent:(GRMustacheContext *)theParent {
	if ((self = [self init])) {
		object = [theObject retain];
		parent = [theParent retain];
	}
	return self;
}

- (GRMustacheContext *)contextByAddingObject:(id)theObject {
	return [[[GRMustacheContext alloc] initWithObject:theObject parent:self] autorelease];
}

- (id)valueForKey:(NSString *)key {
	NSArray *components = [key componentsSeparatedByString:@"/"];
	
	// fast path for single component
	if (components.count == 1) {
		if ([key isEqualToString:@"."]) {
			return object;
		}
		if ([key isEqualToString:@".."]) {
			if (parent == nil) {
				// went too far
				return nil;
			}
			return parent.object;
		}
		return [self valueForKeyComponent:key];
	}
	
	// slow path for multiple components
	GRMustacheContext *context = self;
	for (NSString *component in components) {
		if (component.length == 0) {
			continue;
		}
		if ([component isEqualToString:@"."]) {
			continue;
		}
		if ([component isEqualToString:@".."]) {
			context = context.parent;
			if (context == nil) {
				// went too far
				return nil;
			}
			continue;
		}
		id value = [context valueForKeyComponent:component];
		if (value == nil) {
			return nil;
		}
		// further contexts are not in the context stack
		context = [GRMustacheContext contextWithObject:value];
	}
	
	return context.object;
}

- (void)dealloc {
	[object release];
	[parent release];
	[super dealloc];
}

- (id)valueForKeyComponent:(NSString *)key {
	// value by selector
	
	SEL renderingSelector = NSSelectorFromString([NSString stringWithFormat:@"%@Section:withContext:", key]);
	if ([object respondsToSelector:renderingSelector]) {
		return [GRMustacheSelectorHelper helperWithObject:object selector:renderingSelector];
	}
	
	// value by KVC
	
	id value = nil;
	
    if (object) {
        @try {
            if (preventingNSUndefinedKeyExceptionAttack) {
                value = [GRMustacheNSUndefinedKeyExceptionGuard valueForKey:key inObject:object];
            } else {
                value = [object valueForKey:key];
            }
        }
        @catch (NSException *exception) {
            if (![[exception name] isEqualToString:NSUndefinedKeyException] ||
                [[exception userInfo] objectForKey:@"NSTargetObjectUserInfoKey"] != object ||
                ![[[exception userInfo] objectForKey:@"NSUnknownUserInfoKey"] isEqualToString:key])
            {
                // that's some exception we are not related to
                [exception raise];
            }
        }
    }
	
	// value interpretation
	
	if (value != nil) {
		CFBooleanRef booleanRef;
		if ([self shouldConsiderObjectValue:value forKey:key asBoolean:&booleanRef]) {
			return (id)booleanRef;
		}
		return value;
	}
	
	// parent value
	
	if (parent == nil) { return nil; }
	return [parent valueForKeyComponent:key];
}

- (BOOL)shouldConsiderObjectValue:(id)value forKey:(NSString *)key asBoolean:(CFBooleanRef *)outBooleanRef {
	if ((CFBooleanRef)value == kCFBooleanTrue ||
		(CFBooleanRef)value == kCFBooleanFalse)
	{
		if (outBooleanRef) {
			*outBooleanRef = (CFBooleanRef)value;
		}
		return YES;
	}
	
	if ([value isKindOfClass:[NSNumber class]] &&
		![GRMustache strictBooleanMode] &&
		[GRMustacheProperty class:[object class] hasBOOLPropertyNamed:key])
	{
		if (outBooleanRef) {
			*outBooleanRef = [(NSNumber *)value boolValue] ? kCFBooleanTrue : kCFBooleanFalse;
		}
		return YES;
	}
	
	return NO;
}

@end

