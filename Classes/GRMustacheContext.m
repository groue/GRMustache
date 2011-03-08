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
#import "GRMustacheConfiguration.h"
#import "GRMustacheContext_private.h"
#import "GRMustacheLambda_private.h"

#ifdef DEBUG
id silentValueForKey(id object, NSString *key);
#endif

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
		propertyNames = [NSMutableDictionary dictionaryWithCapacity:4];
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
@property (nonatomic, retain) id object;
@property (nonatomic, retain) GRMustacheContext *parent;
- (id)initWithObject:(id)object parent:(GRMustacheContext *)parent;
- (BOOL)shouldConsiderObjectValue:(id)value forKey:(NSString *)key asBoolean:(CFBooleanRef *)outBooleanRef;
- (id)valueForKeyComponent:(NSString *)key;
@end


@implementation GRMustacheContext
@synthesize object;
@synthesize parent;

+ (id)contextWithObject:(id)object {
	if ([object isKindOfClass:[GRMustacheContext class]]) {
		return object;
	}
	return [[[self alloc] initWithObject:object parent:nil] autorelease];
}

+ (id)contextWithObjects:(id)object, ... {
	GRMustacheContext *context = nil;
	id eachObject;
	va_list argumentList;
	if (object) {
		context = [self contextWithObject:object];
		va_start(argumentList, object);
		while ((eachObject = va_arg(argumentList, id))) {
			context = [context contextByAddingObject:eachObject];
		}
		va_end(argumentList);
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

- (id)valueForUndefinedKey:(NSString *)key {
	return nil;
}

- (id)valueForKeyComponent:(NSString *)key {
	// value by selector
	
	SEL renderingSelector = NSSelectorFromString([NSString stringWithFormat:@"%@Section:withContext:", key]);
	if ([object respondsToSelector:renderingSelector]) {
		return [GRMustacheSelectorHelper helperWithObject:object selector:renderingSelector];
	}
	
	// value by KVC
	
	id value = nil;
	
	@try {
#ifdef DEBUG
		value = silentValueForKey(object, key);
#else
		value = [object valueForKey:key];
#endif
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

#ifdef DEBUG

// helper function for silentValueForKey
id silentValueForUndefinedKey(id self, SEL _cmd, NSString *key) {
	return nil;
}

// Generally, this function returns the same result as [object valueForKey:key].
// 
// The rendering of a GRMustache template can lead to many
// NSUndefinedKeyExceptions to be raised.
//
// Those exceptions are nicely handled by GRMustache, and are part
// of the regular rendering of a template.
//
// Unfortunately, when debugging a project, developers usually set their
// debugger to stop on every Objective-C exceptions.
//
// GRMustache rendering can thus become a huge annoyance.
//
// The purpose of this function is to have the same result as
// [object valueForKey:key], but instead of letting [NSObject valueForUndefinedKey:]
// raise an NSUndefinedKeyException, it returns nil instead.
id silentValueForKey(id object, NSString *key) {
	// Don't mess with objects that do not conform to NSObject protocol...
	Class originalClass = [object class];
	Class rootClass = nil;
	for (Class superclass = originalClass; superclass; superclass = class_getSuperclass(superclass)) {
		rootClass = superclass;
	}
	if (!class_conformsToProtocol(rootClass, @protocol(NSObject))) {
		return [object valueForKey:key];
	}
	
	// Don't mess with objects that are not NSObject instances...
	if (![object isKindOfClass:[NSObject class]]) {
		return [object valueForKey:key];
	}
	
	// NSDictionary already has the behavior we aim at.
	// (And it won't let our later magic run, so don't mess with NSDictionary)
	if ([object isKindOfClass:[NSDictionary class]]) {
		return [object valueForKey:key];
	}
	
	// Does object provide the same implementation of valueForUndefinedKey: as NSObject?
	// If it does not, don't mess with it.
	SEL selector = @selector(valueForUndefinedKey:);
	IMP rootIMP = method_getImplementation(class_getInstanceMethod([NSObject class], selector));
	IMP objectIMP = method_getImplementation(class_getInstanceMethod(originalClass, selector));
	if (rootIMP != objectIMP) {
		return [object valueForKey:key];
	}
	
	// Now the magic: let's temporarily switch object's class with a subclass
	// whose implementation for valueForUndefinedKey: just returns nil.
	id value = nil;
	const char *silentClassName = [[NSString stringWithFormat:@"GRMustacheSilent%@", originalClass] UTF8String];
	Class silentClass = objc_lookUpClass(silentClassName);
	if (silentClass == NULL) {
		silentClass = objc_allocateClassPair(originalClass, silentClassName, 0);
		class_addMethod(silentClass, selector, (IMP)silentValueForUndefinedKey, "@@:@");
		objc_registerClassPair(silentClass);
	}
	object->isa = silentClass;
	
	// Silently call valueForKey!!!!
	@try {
		value = [object valueForKey:key];
	}
	@catch (NSException *exception) {
		// shit happens: restore our object's class and reraise
		object->isa = originalClass;
		[exception raise];
	}
	
	// restore our object's class
	object->isa = originalClass;
	return value;
}
#endif

