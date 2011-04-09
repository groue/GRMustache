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
//=============================================================================
// Embedding https://github.com/rentzsch/jrswizzle/ START
//=============================================================================
//	Copyright (c) 2007-2011 Jonathan 'Wolf' Rentzsch: http://rentzsch.com
//	Some rights reserved: http://opensource.org/licenses/mit-license.php

@interface NSObject (JRSwizzle)

+ (BOOL)jr_swizzleMethod:(SEL)origSel_ withMethod:(SEL)altSel_ error:(NSError**)error_;
+ (BOOL)jr_swizzleClassMethod:(SEL)origSel_ withClassMethod:(SEL)altSel_ error:(NSError**)error_;

@end

#if !TARGET_OS_IPHONE
#import <objc/objc-class.h>
#endif

#define SetNSErrorFor(FUNC, ERROR_VAR, FORMAT,...)	\
    if (ERROR_VAR) {	\
        NSString *errStr = [NSString stringWithFormat:@"%s: " FORMAT,FUNC,##__VA_ARGS__]; \
        *ERROR_VAR = [NSError errorWithDomain:@"NSCocoaErrorDomain" \
                                         code:-1	\
                                     userInfo:[NSDictionary dictionaryWithObject:errStr forKey:NSLocalizedDescriptionKey]]; \
    }
#define SetNSError(ERROR_VAR, FORMAT,...) SetNSErrorFor(__func__, ERROR_VAR, FORMAT, ##__VA_ARGS__)

#if OBJC_API_VERSION >= 2
#define GetClass(obj)	object_getClass(obj)
#else
#define GetClass(obj)	(obj ? obj->isa : Nil)
#endif

@implementation NSObject (JRSwizzle)

+ (BOOL)jr_swizzleMethod:(SEL)origSel_ withMethod:(SEL)altSel_ error:(NSError**)error_ {
#if OBJC_API_VERSION >= 2
	Method origMethod = class_getInstanceMethod(self, origSel_);
	if (!origMethod) {
		SetNSError(error_, @"original method %@ not found for class %@", NSStringFromSelector(origSel_), [self class]);
		return NO;
	}
	
	Method altMethod = class_getInstanceMethod(self, altSel_);
	if (!altMethod) {
		SetNSError(error_, @"alternate method %@ not found for class %@", NSStringFromSelector(altSel_), [self class]);
		return NO;
	}
	
	class_addMethod(self,
					origSel_,
					class_getMethodImplementation(self, origSel_),
					method_getTypeEncoding(origMethod));
	class_addMethod(self,
					altSel_,
					class_getMethodImplementation(self, altSel_),
					method_getTypeEncoding(altMethod));
	
	method_exchangeImplementations(class_getInstanceMethod(self, origSel_), class_getInstanceMethod(self, altSel_));
	return YES;
#else
	//	Scan for non-inherited methods.
	Method directOriginalMethod = NULL, directAlternateMethod = NULL;
	
	void *iterator = NULL;
	struct objc_method_list *mlist = class_nextMethodList(self, &iterator);
	while (mlist) {
		int method_index = 0;
		for (; method_index < mlist->method_count; method_index++) {
			if (mlist->method_list[method_index].method_name == origSel_) {
				assert(!directOriginalMethod);
				directOriginalMethod = &mlist->method_list[method_index];
			}
			if (mlist->method_list[method_index].method_name == altSel_) {
				assert(!directAlternateMethod);
				directAlternateMethod = &mlist->method_list[method_index];
			}
		}
		mlist = class_nextMethodList(self, &iterator);
	}
	
	//	If either method is inherited, copy it up to the target class to make it non-inherited.
	if (!directOriginalMethod || !directAlternateMethod) {
		Method inheritedOriginalMethod = NULL, inheritedAlternateMethod = NULL;
		if (!directOriginalMethod) {
			inheritedOriginalMethod = class_getInstanceMethod(self, origSel_);
			if (!inheritedOriginalMethod) {
				SetNSError(error_, @"original method %@ not found for class %@", NSStringFromSelector(origSel_), [self className]);
				return NO;
			}
		}
		if (!directAlternateMethod) {
			inheritedAlternateMethod = class_getInstanceMethod(self, altSel_);
			if (!inheritedAlternateMethod) {
				SetNSError(error_, @"alternate method %@ not found for class %@", NSStringFromSelector(altSel_), [self className]);
				return NO;
			}
		}
		
		int hoisted_method_count = !directOriginalMethod && !directAlternateMethod ? 2 : 1;
		struct objc_method_list *hoisted_method_list = malloc(sizeof(struct objc_method_list) + (sizeof(struct objc_method)*(hoisted_method_count-1)));
        hoisted_method_list->obsolete = NULL;	// soothe valgrind - apparently ObjC runtime accesses this value and it shows as uninitialized in valgrind
		hoisted_method_list->method_count = hoisted_method_count;
		Method hoisted_method = hoisted_method_list->method_list;
		
		if (!directOriginalMethod) {
			bcopy(inheritedOriginalMethod, hoisted_method, sizeof(struct objc_method));
			directOriginalMethod = hoisted_method++;
		}
		if (!directAlternateMethod) {
			bcopy(inheritedAlternateMethod, hoisted_method, sizeof(struct objc_method));
			directAlternateMethod = hoisted_method;
		}
		class_addMethods(self, hoisted_method_list);
	}
	
	//	Swizzle.
	IMP temp = directOriginalMethod->method_imp;
	directOriginalMethod->method_imp = directAlternateMethod->method_imp;
	directAlternateMethod->method_imp = temp;
	
	return YES;
#endif
}

+ (BOOL)jr_swizzleClassMethod:(SEL)origSel_ withClassMethod:(SEL)altSel_ error:(NSError**)error_ {
	return [GetClass((id)self) jr_swizzleMethod:origSel_ withMethod:altSel_ error:error_];
}

@end
//=============================================================================
// Embedding https://github.com/rentzsch/jrswizzle/ END
//=============================================================================

static const NSString *GRMustacheSilentObjects = @"GRMustacheSilentObjects";

@implementation NSObject(GRMustache)
// implementation for NSObject
- (id)GRMustacheSilentValueForUndefinedKey_NSObject:(NSString *)key {
    NSMutableSet *silentObjects = [[[NSThread currentThread] threadDictionary] objectForKey:GRMustacheSilentObjects];
    if ([silentObjects containsObject:[NSValue valueWithPointer:self]]) {
        return nil;
    }
    return [self GRMustacheSilentValueForUndefinedKey_NSObject:key];
}
// implementation for NSManagedObject
- (id)GRMustacheSilentValueForUndefinedKey_NSManagedObject:(NSString *)key {
    NSMutableSet *silentObjects = [[[NSThread currentThread] threadDictionary] objectForKey:GRMustacheSilentObjects];
    if ([silentObjects containsObject:[NSValue valueWithPointer:self]]) {
        return nil;
    }
    return [self GRMustacheSilentValueForUndefinedKey_NSManagedObject:key];
}
@end
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

#ifdef DEBUG
+ (void)initialize
{
    if (self == [GRMustacheContext class]) {
        [NSObject jr_swizzleMethod:@selector(valueForUndefinedKey:)
                        withMethod:@selector(GRMustacheSilentValueForUndefinedKey_NSObject:)
                             error:nil];
        
        Class NSManagedObjectClass = NSClassFromString(@"NSManagedObject");
        if (NSManagedObjectClass) {
            [NSManagedObjectClass jr_swizzleMethod:@selector(valueForUndefinedKey:)
                                        withMethod:@selector(GRMustacheSilentValueForUndefinedKey_NSManagedObject:)
                                             error:nil];
        }
    }
}
#endif

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
	
	@try {
#ifdef DEBUG
        NSMutableSet *silentObjects = [[[NSThread currentThread] threadDictionary] objectForKey:GRMustacheSilentObjects];
        if (silentObjects == nil) {
            silentObjects = [NSMutableSet set];
            [[[NSThread currentThread] threadDictionary] setObject:silentObjects forKey:GRMustacheSilentObjects];
        }
        NSValue *objectPointer = [NSValue valueWithPointer:object];
        [silentObjects addObject:objectPointer];
#endif
		value = [object valueForKey:key];
#ifdef DEBUG
        [silentObjects removeObject:objectPointer];
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

