// The MIT License
//
// Copyright (c) 2014 Gwendal Roué
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

#if __has_feature(objc_arc)
#error Manual Reference Counting required: use -fno-objc-arc.
#endif

#import <objc/message.h>
#import <pthread.h>
#import "GRMustacheKeyAccess_private.h"

#if !defined(NS_BLOCK_ASSERTIONS)
// For testing purpose
BOOL GRMustacheKeyAccessDidCatchNSUndefinedKeyException;
#endif


// =============================================================================
#pragma mark - Safe key access

static pthread_key_t GRSafeKeysForClassKey;
void freeSafeKeysForClass(void *objects) {
    CFRelease((CFMutableDictionaryRef)objects);
}
#define setupSafeKeysForClass() pthread_key_create(&GRSafeKeysForClassKey, freeSafeKeysForClass)
#define getCurrentThreadSafeKeysForClass() (CFMutableDictionaryRef)pthread_getspecific(GRSafeKeysForClassKey)
#define setCurrentThreadSafeKeysForClass(classes) pthread_setspecific(GRSafeKeysForClassKey, classes)


// =============================================================================
#pragma mark - NSUndefinedKeyException prevention declarations

@interface NSObject(GRMustacheKeyAccessPreventionOfNSUndefinedKeyException)
- (id)GRMustacheKeyAccessValueForUndefinedKey_NSObject:(NSString *)key;
- (id)GRMustacheKeyAccessValueForUndefinedKey_NSManagedObject:(NSString *)key;
@end;


// =============================================================================
#pragma mark - GRMustacheKeyAccess

static Class NSManagedObjectClass;

@interface NSObject(GRMustacheCoreDataMethods)
- (NSDictionary *)propertiesByName;
- (id)entity;
@end

@implementation GRMustacheKeyAccess

+ (void)initialize
{
    NSManagedObjectClass = NSClassFromString(@"NSManagedObject");
    setupSafeKeysForClass();
}


// =============================================================================
#pragma mark - Foundation

/**
 * Return the set of methods without arguments, up to NSObject, non including NSObject.
 */
+ (NSMutableSet *)allPublicKeysForClass:(Class)klass
{
    NSMutableSet *keys = [NSMutableSet set];
    Class NSObjectClass = [NSObject class];
    while (klass && klass != NSObjectClass) {
        unsigned int methodCount;
        Method *methods = class_copyMethodList(klass, &methodCount);
        for (unsigned int i = 0; i < methodCount; ++i) {
            SEL selector = method_getName(methods[i]);
            const char *selectorName = sel_getName(selector);
            if (selectorName[0] != '_' && selectorName[strlen(selectorName) - 1] != '_' && strstr(selectorName, ":") == NULL) {
                [keys addObject:NSStringFromSelector(selector)];
            }
        }
        free (methods);
        klass = class_getSuperclass(klass);
    }
    
    return keys;
}


// =============================================================================
#pragma mark - Safe key access

+ (BOOL)isSafeMustacheKey:(NSString *)key forObject:(id)object
{
    NSSet *safeKeys = nil;
    {
        CFMutableDictionaryRef safeKeysForClass = getCurrentThreadSafeKeysForClass();
        if (!safeKeysForClass) {
            safeKeysForClass = CFDictionaryCreateMutable(NULL, 0, NULL, &kCFTypeDictionaryValueCallBacks);
            setCurrentThreadSafeKeysForClass(safeKeysForClass);
        }
        
        Class klass = [object class];
        safeKeys = (NSSet *)CFDictionaryGetValue(safeKeysForClass, klass);
        if (safeKeys == nil) {
            NSMutableSet *keys = [self propertyGettersForClass:klass];
            if (NSManagedObjectClass && [object isKindOfClass:NSManagedObjectClass]) {
                [keys unionSet:[NSSet setWithArray:[[[object entity] propertiesByName] allKeys]]];
            }
            safeKeys = keys;
            CFDictionarySetValue(safeKeysForClass, klass, safeKeys);
        }
    }
    
    return [safeKeys containsObject:key];
}

+ (NSMutableSet *)propertyGettersForClass:(Class)klass
{
    NSMutableSet *safeKeys = [NSMutableSet set];
    while (klass) {
        // Iterate properties
        
        unsigned int count;
        objc_property_t *properties = class_copyPropertyList(klass, &count);
        
        for (unsigned int i=0; i<count; ++i) {
            const char *attrs = property_getAttributes(properties[i]);
            
            // Safe Mustache keys are property name, and custom getter.
            
            const char *propertyNameCString = property_getName(properties[i]);
            NSString *propertyName = [NSString stringWithCString:propertyNameCString encoding:NSUTF8StringEncoding];
            [safeKeys addObject:propertyName];
            
            char *getterStart = strstr(attrs, ",G");            // ",GcustomGetter,..." or NULL if there is no custom getter
            if (getterStart) {
                getterStart += 2;                               // "customGetter,..."
                char *getterEnd = strstr(getterStart, ",");     // ",..." or NULL if customGetter is the last attribute
                size_t getterLength = (getterEnd ? getterEnd : attrs + strlen(attrs)) - getterStart;
                NSString *customGetter = [[[NSString alloc] initWithBytes:getterStart length:getterLength encoding:NSUTF8StringEncoding] autorelease];
                [safeKeys addObject:customGetter];
            }
        }
        
        free(properties);
        klass = class_getSuperclass(klass);
    }
    
    return safeKeys;
}

@end
