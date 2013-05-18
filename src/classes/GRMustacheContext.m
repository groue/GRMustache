// The MIT License
//
// Copyright (c) 2013 Gwendal Roué
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

#import <objc/message.h>
#import "GRMustacheContext_private.h"
#import "GRMustacheTag_private.h"
#import "GRMustacheExpression_private.h"
#import "GRMustacheTemplate_private.h"
#import "GRMustacheError.h"
#import "GRMustacheTemplateOverride_private.h"
#import "JRSwizzle.h"

// Returns an alternate name for a propertyName
// "foo" -> "isFoo"
// "isFoo" -> "foo"
// Caller must free the returned string.
static char *alternateNameForPropertyName(const char *propertyName)
{
    size_t propertyLength = strlen(propertyName);
    
    // Build altName ("foo" or "isFoo")
    char *altName;
    if (propertyLength >= 3 && strstr(propertyName, "is") == propertyName && propertyName[2] >= 'A' && propertyName[2] <= 'Z') {
        // "isFoo" getter
        // Build altName "foo"
        altName = malloc(propertyLength - 1);       // given "isFoo" of length 5, the room for "foo\0" (4 bytes)
        strcpy(altName, propertyName + 2);          // "Foo\0"
        altName[0] += 'a' - 'A';                    // "foo\0"
    } else {
        // "foo" getter
        // Build altName "isFoo"
        // (tested, OK)
        altName = malloc(propertyLength + 3);       // given "foo" of length 3, the room for "isFoo\0" (6 bytes)
        strcpy(altName+2, propertyName);            // "??foo\0"
        altName[0] = 'i';                           // "i?foo\0"
        altName[1] = 's';                           // "i?foo\0"
        altName[2] += 'A' - 'a';                    // "isFoo\0"
    }
    
    return altName;
}

// Returns YES if the selectorName is a property accessor.
// If allowKVCAlternateName is YES, variants isFoo/foo are tested.
// If the result is YES:
// - `getter` is set to YES if the selector is a getter.
// - `propertyName` is set to the property name
// - `objCTypes` is set to the encoding of the property
// Caller must free the returned strings.
BOOL hasPropertyAccessor(Class klass, const char *selectorName, BOOL allowKVCAlternateName, BOOL *getter, char **propertyName, char **objCTypes)
{
    size_t selectorLength = strlen(selectorName);
    char *colon = strstr(selectorName, ":");
    
    if (colon == NULL)
    {
        // Arity 0: it may be a getter
        // Support KVC variants: foo and isFoo are synonyms
        char *altName = allowKVCAlternateName ? alternateNameForPropertyName(selectorName) : nil;

        // Look for a property named "foo" or "isFoo", or with a custom getter "foo" or "isFoo"
        BOOL found = NO;
        unsigned int count;
        while (!found && klass && klass != [GRMustacheContext class]) {
            objc_property_t *properties = class_copyPropertyList(klass, &count);
            for (unsigned int i=0; i<count; ++i) {
                const char *pName = property_getName(properties[i]);
                const char *attrs = property_getAttributes(properties[i]);
                if (strcmp(selectorName, pName) == 0 || (altName && strcmp(altName, pName) == 0)) {
                    found = YES;
                } else {
                    char *getterStart = strstr(attrs, ",G");            // ",GcustomGetter,..." or NULL if there is no custom getter
                    if (getterStart) {
                        getterStart += 2;                               // "customGetter,..."
                        char *getterEnd = strstr(getterStart, ",");     // ",..." or NULL if customGetter is the last attribute
                        size_t getterLength = (getterEnd ? getterEnd : attrs + strlen(attrs)) - getterStart;
                        if (strncmp(selectorName, getterStart, getterLength) == 0 || (altName && strncmp(altName, getterStart, getterLength) == 0)) {
                            found = YES;
                        }
                    }
                }
                
                if (found) {
                    if (objCTypes) {
                        size_t typeLength = strstr(attrs, ",") - attrs - 1;
                        *objCTypes = malloc(typeLength + 1);
                        strncpy(*objCTypes, attrs+1, typeLength);
                        (*objCTypes)[typeLength] = '\0';
                    }
                    if (propertyName) {
                        *propertyName = malloc(strlen(pName) + 1);
                        strcpy(*propertyName, pName);
                    }
                    if (getter) {
                        *getter = YES;
                    }
                    break;
                }
            }
            
            free(properties);
            klass = class_getSuperclass(klass);
        }
        
        if (altName) {
            free(altName);
        }
        
        return found;
    }
    else if (colon == selectorName + selectorLength - 1)
    {
        // Arity 1: it may be a setter
        
        char *expectedPropertyName = nil;
        if (strstr(selectorName, "set") == selectorName)
        {
            expectedPropertyName = malloc(selectorLength - 3);                 // given "setFoo:" of length 7, the room for "foo\0" (4 bytes)
            strncpy(expectedPropertyName, selectorName+3, selectorLength - 4); // "Foo?z"
            expectedPropertyName[selectorLength - 4] = '\0';                   // "Foo\0"
            if (expectedPropertyName[0] >= 'A' && expectedPropertyName[0] <= 'Z') {
                expectedPropertyName[0] += 'a' - 'A';                          // "foo\0"
            }
        }
        
        // Look for a property of custom setter selectorName, or with name expectedPropertyName
        BOOL found = NO;
        while (!found && klass && klass != [GRMustacheContext class]) {
            unsigned int count;
            objc_property_t *properties = class_copyPropertyList(klass, &count);
            for (unsigned int i=0; i<count; ++i) {
                const char *pName = property_getName(properties[i]);
                const char *attrs = property_getAttributes(properties[i]);
                
                char *setterStart = strstr(attrs, ",S");            // ",ScustomSetter:,..." or NULL if there is no custom setter
                if (setterStart) {
                    setterStart += 2;                               // "customSetter:,..."
                    char *setterEnd = strstr(setterStart, ",");     // ",..." or NULL if customSetter is the last attribute
                    size_t setterLength = (setterEnd ? setterEnd : attrs + strlen(attrs)) - setterStart;
                    if (strncmp(selectorName, setterStart, setterLength) == 0) {
                        found = YES;
                    }
                } else if (expectedPropertyName && strcmp(expectedPropertyName, pName) == 0) {
                    found = YES;
                }

                if (found) {
                    if (objCTypes) {
                        size_t typeLength = strstr(attrs, ",") - attrs - 1;
                        *objCTypes = malloc(typeLength + 1);
                        strncpy(*objCTypes, attrs+1, typeLength);
                        (*objCTypes)[typeLength] = '\0';
                    }
                    if (propertyName) {
                        *propertyName = malloc(strlen(pName) + 1);
                        strcpy(*propertyName, pName);
                    }
                    if (getter) {
                        *getter = NO;
                    }
                    break;
                }
            }
            
            free(properties);
            klass = class_getSuperclass(klass);
        }
        
        if (expectedPropertyName) {
            free(expectedPropertyName);
        }
        
        return found;
    }
    else
    {
        // unknown selector
        return NO;
    }
}

#if !defined(NS_BLOCK_ASSERTIONS)
BOOL GRMustacheContextDidCatchNSUndefinedKeyException;
#endif

static BOOL shouldPreventNSUndefinedKeyException = NO;

@interface GRMustacheContext()

// Context stack:
// If _contextObject is nil, the stack is empty.
// If _contextObject is not nil, the top of the stack is _contextObject, and the rest of the stack is _contextParent.
@property (nonatomic, retain) GRMustacheContext *contextParent;
@property (nonatomic, retain) id contextObject;
@property (nonatomic, retain) NSMutableDictionary *mutableContextObject;

// Protected context stack
// If _protectedContextObject is nil, the stack is empty.
// If _protectedContextObject is not nil, the top of the stack is _protectedContextObject, and the rest of the stack is _protectedContextParent.
@property (nonatomic, retain) GRMustacheContext *protectedContextParent;
@property (nonatomic, retain) id protectedContextObject;

// Hidden context stack
@property (nonatomic, retain) GRMustacheContext *hiddenContextParent;
@property (nonatomic, retain) id hiddenContextObject;

// Tag delegate stack
@property (nonatomic, retain) GRMustacheContext *tagDelegateParent;
@property (nonatomic, retain) id<GRMustacheTagDelegate> tagDelegate;

// Template override stack
@property (nonatomic, retain) GRMustacheContext *templateOverrideParent;
@property (nonatomic, retain) id templateOverride;

+ (BOOL)objectIsFoundationCollectionWhoseImplementationOfValueForKeyReturnsAnotherCollection:(id)object;
+ (void)setupPreventionOfNSUndefinedKeyException;
+ (void)beginPreventionOfNSUndefinedKeyExceptionFromObject:(id)object;
+ (void)endPreventionOfNSUndefinedKeyExceptionFromObject:(id)object;
+ (NSMutableSet *)preventionOfNSUndefinedKeyExceptionObjects;

/**
 * Sends the `valueForKey:` message to super_data->receiver with the provided
 * key, using the implementation of super_data->super_class, and returns the
 * result.
 *
 * Should [GRMustacheContext preventNSUndefinedKeyExceptionAttack] method have
 * been called earlier, temporarily swizzle _object_ so that it does not raise
 * any NSUndefinedKeyException.
 *
 * Should `valueForKey:` raise an NSUndefinedKeyException, returns nil.
 *
 * @param key         The searched key
 * @param super_data  A pointer to a struct objc_super
 *
 * @return The result of the implementation of `valueForKey:` in
 *         super_data->super_class, or nil should an NSUndefinedKeyException be
 *         raised.
 *
 * @see GRMustacheProxy
 */
+ (id)valueForKey:(NSString *)key inSuper:(struct objc_super *)super_data GRMUSTACHE_API_INTERNAL;

@end

@implementation GRMustacheContext
@synthesize contextParent=_contextParent;
@synthesize contextObject=_contextObject;
@synthesize mutableContextObject=_mutableContextObject;
@synthesize protectedContextParent=_protectedContextParent;
@synthesize protectedContextObject=_protectedContextObject;
@synthesize hiddenContextParent=_hiddenContextParent;
@synthesize hiddenContextObject=_hiddenContextObject;
@synthesize tagDelegateParent=_tagDelegateParent;
@synthesize tagDelegate=_tagDelegate;
@synthesize templateOverrideParent=_templateOverrideParent;
@synthesize templateOverride=_templateOverride;

- (void)dealloc
{
    [_contextParent release];
    [_contextObject release];
    [_mutableContextObject release];
    [_protectedContextParent release];
    [_protectedContextObject release];
    [_hiddenContextParent release];
    [_hiddenContextObject release];
    [_tagDelegateParent release];
    [_tagDelegate release];
    [_templateOverrideParent release];
    [_templateOverride release];
    [super dealloc];
}

+ (void)initialize
{
    if (self != [GRMustacheContext class]) {
        // raise exception if we have implementation for custom writable properties
        unsigned int count;
        objc_property_t *properties = class_copyPropertyList(self, &count);
        for (unsigned int i=0; i<count; ++i) {
            const char *attrs = property_getAttributes(properties[i]);
            if (!strstr(attrs, ",R")) {
                // writable property
                
                char *getterStart = strstr(attrs, ",G");            // ",GcustomGetter,..." or NULL if there is no custom getter
                if (getterStart) {
                    getterStart += 2;                               // "customGetter,..."
                    char *getterEnd = strstr(getterStart, ",");     // ",..." or NULL if customGetter is the last attribute
                    size_t getterLength = (getterEnd ? getterEnd : attrs + strlen(attrs)) - getterStart;
                    char *getterName = malloc(getterLength + 1);
                    strncpy(getterName, getterStart, getterLength);
                    getterName[getterLength] = '\0';
                    Method method = class_getInstanceMethod(self, sel_registerName(getterName));
                    free(getterName);
                    if (method) {
                        [NSException raise:NSInternalInconsistencyException format:@"%@: the property `%@` is required to be @dynamic.", self, [NSString stringWithUTF8String:property_getName(properties[i])]];
                    }
                } else {
                    const char *propertyName = property_getName(properties[i]);
                    Method method = class_getInstanceMethod(self, sel_registerName(propertyName));
                    if (method) {
                        [NSException raise:NSInternalInconsistencyException format:@"%@: the property `%@` is required to be @dynamic.", self, [NSString stringWithUTF8String:propertyName]];
                    }
                }
            }
        }
        free(properties);
    }
}

+ (void)preventNSUndefinedKeyExceptionAttack
{
    shouldPreventNSUndefinedKeyException = YES;
}

+ (instancetype)context
{
    return [[[self alloc] init] autorelease];
}

+ (instancetype)contextWithObject:(id)object
{
    GRMustacheContext *context = [[[self alloc] init] autorelease];
    
    // initialize context stack
    context.contextObject = [object retain];
        
    // initialize tag delegate stack
    if ([object conformsToProtocol:@protocol(GRMustacheTagDelegate)]) {
        context.tagDelegate = [object retain];
    }
    
    return context;
}

+ (instancetype)contextWithProtectedObject:(id)object
{
    GRMustacheContext *context = [[[self alloc] init] autorelease];
    
    // initialize protected context stack
    context.protectedContextObject = [object retain];
    
    return context;
}

+ (instancetype)contextWithTagDelegate:(id<GRMustacheTagDelegate>)tagDelegate
{
    GRMustacheContext *context = [[[self alloc] init] autorelease];
    
    // initialize tag delegate stack
    context.tagDelegate = [tagDelegate retain];
    
    return context;
}

- (instancetype)contextByAddingTagDelegate:(id<GRMustacheTagDelegate>)tagDelegate
{
    if (tagDelegate == nil) {
        return self;
    }
    
    GRMustacheContext *context = [[[[self class] alloc] init] autorelease];
    
    // Update context stack
    context.contextParent = self;
    context.contextObject = nil;
    
    // copy identical stacks
    context.protectedContextParent = _protectedContextParent;
    context.protectedContextObject = _protectedContextObject;
    context.hiddenContextParent = _hiddenContextParent;
    context.hiddenContextObject = _hiddenContextObject;
    context.templateOverrideParent = _templateOverrideParent;
    context.templateOverride = _templateOverride;
    
    // update tag delegate stack
    if (_tagDelegate) { context.tagDelegateParent = self; }
    context.tagDelegate = tagDelegate;
    
    return context;
}

- (instancetype)contextByAddingObject:(id)object
{
    if (object == nil) {
        return self;
    }
    
    GRMustacheContext *context = [[[[self class] alloc] init] autorelease];
    
    // copy identical stacks
    context.protectedContextParent = _protectedContextParent;
    context.protectedContextObject = _protectedContextObject;
    context.hiddenContextParent = _hiddenContextParent;
    context.hiddenContextObject = _hiddenContextObject;
    context.templateOverrideParent = _templateOverrideParent;
    context.templateOverride = _templateOverride;
    
    // Update context stack
    context.contextParent = self;
    context.contextObject = object;
    
    // update or copy tag delegate stack
    if ([object conformsToProtocol:@protocol(GRMustacheTagDelegate)]) {
        if (_tagDelegate) { context.tagDelegateParent = self; }
        context.tagDelegate = object;
    } else {
        context.tagDelegateParent = _tagDelegateParent;
        context.tagDelegate = _tagDelegate;
    }
    
    return context;
}

- (instancetype)contextByAddingProtectedObject:(id)object
{
    if (object == nil) {
        return self;
    }
    
    GRMustacheContext *context = [[[[self class] alloc] init] autorelease];
    
    // Update context stack
    context.contextParent = self;
    context.contextObject = nil;
    
    // copy identical stacks
    context.hiddenContextParent = _hiddenContextParent;
    context.hiddenContextObject = _hiddenContextObject;
    context.tagDelegateParent = _tagDelegateParent;
    context.tagDelegate = _tagDelegate;
    context.templateOverrideParent = _templateOverrideParent;
    context.templateOverride = _templateOverride;
    
    // update protected context stack
    if (_protectedContextObject) { context.protectedContextParent = self; }
    context.protectedContextObject = object;
    
    return context;
}

- (instancetype)contextByAddingHiddenObject:(id)object
{
    if (object == nil) {
        return self;
    }
    
    GRMustacheContext *context = [[[[self class] alloc] init] autorelease];
    
    // Update context stack
    context.contextParent = self;
    context.contextObject = nil;
    
    // copy identical stacks
    context.protectedContextParent = _protectedContextParent;
    context.protectedContextObject = _protectedContextObject;
    context.tagDelegateParent = _tagDelegateParent;
    context.tagDelegate = _tagDelegate;
    context.templateOverrideParent = _templateOverrideParent;
    context.templateOverride = _templateOverride;
    
    // update hidden context stack
    if (_hiddenContextObject) { context.hiddenContextParent = self; }
    context.hiddenContextObject = object;
    
    return context;
}

- (instancetype)contextByAddingTemplateOverride:(GRMustacheTemplateOverride *)templateOverride
{
    if (templateOverride == nil) {
        return self;
    }
    
    GRMustacheContext *context = [[[[self class] alloc] init] autorelease];
    
    // Update context stack
    context.contextParent = self;
    context.contextObject = nil;
    
    // copy identical stacks
    context.protectedContextParent = _protectedContextParent;
    context.protectedContextObject = _protectedContextObject;
    context.hiddenContextParent = _hiddenContextParent;
    context.hiddenContextObject = _hiddenContextObject;
    context.tagDelegateParent = _tagDelegateParent;
    context.tagDelegate = _tagDelegate;
    
    // update template override stack
    if (_templateOverride) { context.templateOverrideParent = self; }
    context.templateOverride = templateOverride;
    
    return context;
}

- (void)enumerateTagDelegatesUsingBlock:(void(^)(id<GRMustacheTagDelegate> tagDelegate))block
{
    if (_tagDelegate) {
        for (GRMustacheContext *context = self; context; context = context.tagDelegateParent) {
            block(context.tagDelegate);
        }
    }
}

- (id)currentContextValue
{
    for (GRMustacheContext *context = self; context; context = context.contextParent) {
        id contextObject = context.contextObject;
        if (contextObject) {
            return contextObject;
        }
    }
    return nil;
}

- (id)contextValueForKey:(NSString *)key protected:(BOOL *)protected
{
    if (_protectedContextObject) {
        for (GRMustacheContext *context = self; context; context = context.protectedContextParent) {
            id value = [GRMustacheContext valueForKey:key inObject:context.protectedContextObject];
            if (value != nil) {
                if (protected != NULL) {
                    *protected = YES;
                }
                return value;
            }
        }
    }
    
    // We're about to look into mutableContextObject.
    //
    // This dictionary is filled via setValue:forKey:, and via property setters.
    //
    // Property setters use property names as the key.
    // So we have to translate custom getters to the property name.
    //
    // Regular KVC also supports `isFoo` key for `foo` property: we also have to
    // translate `isFoo` to `foo`.
    //
    // mutableCustomContextKey holds that "canonical" key.
    NSString *mutableCustomContextKey = key;
    if (object_getClass(self) != [GRMustacheContext class]) {
        const char *keyCString = [key UTF8String];
        BOOL getter;
        char *propertyName;
        if (hasPropertyAccessor([self class], keyCString, YES, &getter, &propertyName, NULL)) {
            if (getter) {
                mutableCustomContextKey = [NSString stringWithUTF8String:propertyName];
            }
        }
    }
    
    for (GRMustacheContext *context = self; context; context = context.contextParent) {
        // First check mutableContextObject:
        //
        // [context setValue:value forKey:key];
        // assert([context valueForKey:key] == value);
        id value = [context.mutableContextObject objectForKey:mutableCustomContextKey];
        if (value != nil) {
            if (protected != NULL) {
                *protected = NO;
            }
            return value;
        }
        
        // Then check for contextObject:
        //
        // context = [GRMustacheContext contextWithObject:@{key:value}];
        // assert([context valueForKey:key] == value);
        id contextObject = context.contextObject;
        if (contextObject) {
            BOOL hidden = NO;
            if (_hiddenContextObject) {
                for (GRMustacheContext *hiddenContext = self; hiddenContext; hiddenContext = hiddenContext.hiddenContextParent) {
                    if (contextObject == hiddenContext.hiddenContextObject) {
                        hidden = YES;
                        break;
                    }
                }
            }
            if (hidden) { continue; }
            id value = [GRMustacheContext valueForKey:key inObject:contextObject];
            if (value != nil) {
                if (protected != NULL) {
                    *protected = NO;
                }
                return value;
            }
        }
    }

    // Check for subclass custom key
    
    if (object_getClass(self) != [GRMustacheContext class]) {
        id value = [GRMustacheContext valueForKey:key inSuper:&(struct objc_super){ self, [NSObject class] }];
        if (protected != NULL) {
            *protected = NO;
        }
        return value;
    }
    
    return nil;
}

- (id<GRMustacheTemplateComponent>)resolveTemplateComponent:(id<GRMustacheTemplateComponent>)component
{
    if (_templateOverride) {
        for (GRMustacheContext *context = self; context; context = context.templateOverrideParent) {
            component = [context.templateOverride resolveTemplateComponent:component];
        }
    }
    return component;
}


#pragma mark - NSObject

- (id)valueForKey:(NSString *)key
{
    return [self contextValueForKey:key protected:NULL];
}

- (void)setValue:(id)value forKey:(NSString *)key
{
    if (!_mutableContextObject) {
        _mutableContextObject = [[NSMutableDictionary alloc] init];
    }
    [_mutableContextObject setValue:value forKey:key];
}

- (BOOL)respondsToSelector:(SEL)selector
{
    if ([super respondsToSelector:selector]) {
        return YES;
    }
    
    const char *selectorName = sel_getName(selector);
    return hasPropertyAccessor([self class], selectorName, NO, NULL, NULL, NULL);
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector
{
    NSMethodSignature *signature = [super methodSignatureForSelector:selector];
    if (signature) {
        return signature;
    }
    
    // The method is undefined.
    
    const char *selectorName = sel_getName(selector);
    char *propertyName;
    char *encoding;
    BOOL getter;
    if (hasPropertyAccessor([self class], selectorName, NO, &getter, &propertyName, &encoding)) {

        if (getter) {
            // Getter
            
            size_t encodingLength = strlen(encoding);
            char *objCTypes = malloc(encodingLength+3);
            strcpy(objCTypes, encoding);
            objCTypes[encodingLength] = '@';
            objCTypes[encodingLength + 1] = ':';
            objCTypes[encodingLength + 2] = '\0';
            signature = [NSMethodSignature signatureWithObjCTypes:objCTypes];
            free(objCTypes);
            
        } else {
            // Setter
            
            size_t encodingLength = strlen(encoding);
            char *objCTypes = malloc(encodingLength+4);
            strcpy(objCTypes + 3, encoding);
            objCTypes[0] = 'v';
            objCTypes[1] = '@';
            objCTypes[2] = ':';
            signature = [NSMethodSignature signatureWithObjCTypes:objCTypes];
            free(objCTypes);
        }

        free(propertyName);
        free(encoding);
    }
    
    return signature;
}

- (void)forwardInvocation:(NSInvocation *)invocation
{
    SEL selector = [invocation selector];

    const char *selectorName = sel_getName(selector);
    char *propertyName;
    char *encoding;
    BOOL getter;
    if (hasPropertyAccessor([self class], selectorName, NO, &getter, &propertyName, &encoding)) {
        
        if (getter) {
            // Getter
            //
            // context.age returns the same value as [context valueForKey:@"age"]
            
            NSUInteger valueSize;
            NSGetSizeAndAlignment(encoding, &valueSize, NULL);
            NSMutableData *data = [NSMutableData dataWithLength:valueSize];   // autoreleased so that invocation's return value survives
            void *bytes = [data mutableBytes];
            
            id value = [self valueForKey:[NSString stringWithUTF8String:propertyName]];
            switch (encoding[0]) {
                case 'c':
                    if (![value isKindOfClass:[NSNumber class]]) return;
                    *(char *)bytes = [(NSNumber *)value charValue];
                    break;
                case 'i':
                    if (![value isKindOfClass:[NSNumber class]]) return;
                    *(int *)bytes = [(NSNumber *)value intValue];
                    break;
                case 's':
                    if (![value isKindOfClass:[NSNumber class]]) return;
                    *(short *)bytes = [(NSNumber *)value shortValue];
                    break;
                case 'l':
                    if (![value isKindOfClass:[NSNumber class]]) return;
                    *(long *)bytes = [(NSNumber *)value longValue];
                    break;
                case 'q':
                    if (![value isKindOfClass:[NSNumber class]]) return;
                    *(long long *)bytes = [(NSNumber *)value longLongValue];
                    break;
                case 'C':
                    if (![value isKindOfClass:[NSNumber class]]) return;
                    *(unsigned char *)bytes = [(NSNumber *)value unsignedCharValue];
                    break;
                case 'I':
                    if (![value isKindOfClass:[NSNumber class]]) return;
                    *(unsigned int *)bytes = [(NSNumber *)value unsignedIntValue];
                    break;
                case 'S':
                    if (![value isKindOfClass:[NSNumber class]]) return;
                    *(unsigned short *)bytes = [(NSNumber *)value unsignedShortValue];
                    break;
                case 'L':
                    if (![value isKindOfClass:[NSNumber class]]) return;
                    *(unsigned long *)bytes = [(NSNumber *)value unsignedLongValue];
                    break;
                case 'Q':
                    if (![value isKindOfClass:[NSNumber class]]) return;
                    *(unsigned long long *)bytes = [(NSNumber *)value unsignedLongLongValue];
                    break;
                case 'f':
                    if (![value isKindOfClass:[NSNumber class]]) return;
                    *(float *)bytes = [(NSNumber *)value floatValue];
                    break;
                case 'd':
                    if (![value isKindOfClass:[NSNumber class]]) return;
                    *(double *)bytes = [(NSNumber *)value doubleValue];
                    break;
                case 'B':
                    if (![value isKindOfClass:[NSNumber class]]) return;
                    *(_Bool *)bytes = [(NSNumber *)value boolValue];
                    break;
                case '@':
                    *(id *)bytes = value;
                    break;
                case '#':
                    *(Class *)bytes = value;
                    break;
                default:
                    if (![value isKindOfClass:[NSValue class]]) return;
                    [(NSValue *)value getValue:bytes];
                    break;
            }
            
            [invocation setReturnValue:bytes];
            
        } else {
            // Setter
            //
            // [context setAge:1] performs [context setValue:@1 forKey:@"age"]
            
            NSUInteger valueSize;
            NSGetSizeAndAlignment(encoding, &valueSize, NULL);
            void *bytes = malloc(valueSize);
            [invocation getArgument:bytes atIndex:2];
            
            switch (encoding[0]) {
                case 'c':
                    [self setValue:[NSNumber numberWithChar:*(char *)bytes] forKey:[NSString stringWithUTF8String:propertyName]];
                    break;
                case 'i':
                    [self setValue:[NSNumber numberWithInt:*(int *)bytes] forKey:[NSString stringWithUTF8String:propertyName]];
                    break;
                case 's':
                    [self setValue:[NSNumber numberWithShort:*(short *)bytes] forKey:[NSString stringWithUTF8String:propertyName]];
                    break;
                case 'l':
                    [self setValue:[NSNumber numberWithLong:*(long *)bytes] forKey:[NSString stringWithUTF8String:propertyName]];
                    break;
                case 'q':
                    [self setValue:[NSNumber numberWithLongLong:*(long long *)bytes] forKey:[NSString stringWithUTF8String:propertyName]];
                    break;
                case 'C':
                    [self setValue:[NSNumber numberWithUnsignedChar:*(unsigned char *)bytes] forKey:[NSString stringWithUTF8String:propertyName]];
                    break;
                case 'I':
                    [self setValue:[NSNumber numberWithUnsignedInt:*(unsigned int *)bytes] forKey:[NSString stringWithUTF8String:propertyName]];
                    break;
                case 'S':
                    [self setValue:[NSNumber numberWithUnsignedShort:*(unsigned short *)bytes] forKey:[NSString stringWithUTF8String:propertyName]];
                    break;
                case 'L':
                    [self setValue:[NSNumber numberWithUnsignedLong:*(unsigned long *)bytes] forKey:[NSString stringWithUTF8String:propertyName]];
                    break;
                case 'Q':
                    [self setValue:[NSNumber numberWithUnsignedLongLong:*(unsigned long long *)bytes] forKey:[NSString stringWithUTF8String:propertyName]];
                    break;
                case 'f':
                    [self setValue:[NSNumber numberWithFloat:*(float *)bytes] forKey:[NSString stringWithUTF8String:propertyName]];
                    break;
                case 'd':
                    [self setValue:[NSNumber numberWithDouble:*(double *)bytes] forKey:[NSString stringWithUTF8String:propertyName]];
                    break;
                case 'B':
                    [self setValue:[NSNumber numberWithBool:(BOOL)(*(_Bool *)bytes)] forKey:[NSString stringWithUTF8String:propertyName]];
                    break;
                case '@':
                    [self setValue:*(id *)bytes forKey:[NSString stringWithUTF8String:propertyName]];
                    break;
                case '#':
                    [self setValue:*(Class *)bytes forKey:[NSString stringWithUTF8String:propertyName]];
                    break;
                default:
                    [self setValue:[NSValue valueWithBytes:bytes objCType:encoding ?: "@"] forKey:[NSString stringWithUTF8String:propertyName]];
                    break;
            }
            
            free(bytes);
        }

        free(propertyName);
        free(encoding);
    } else {
        [super forwardInvocation:invocation];
    }
}


#pragma mark - Private

+ (id)valueForKey:(NSString *)key inObject:(id)object
{
    // We don't want to use NSArray, NSSet and NSOrderedSet implementation
    // of valueForKey:, because they return another collection: see issue #21
    // and "anchored key should not extract properties inside an array" test in
    // src/tests/Public/v4.0/GRMustacheSuites/compound_keys.json
    //
    // Still, we do not want to prevent access to [NSArray count]. We thus
    // invoke NSObject's implementation of valueForKey: for those objects, with
    // our valueForKey:inSuper: method.
    
    if ([self objectIsFoundationCollectionWhoseImplementationOfValueForKeyReturnsAnotherCollection:object]) {
        return [self valueForKey:key inSuper:&(struct objc_super){ object, [NSObject class] }];
    }
    
    
    // For other objects, return the result of their own implementation of
    // valueForKey: (but use our valueForKey:inSuper: with nil super_class, so
    // that we can prevent or catch NSUndefinedKeyException).
    
    return [self valueForKey:key inSuper:&(struct objc_super){ object, nil }];
}

+ (id)valueForKey:(NSString *)key inSuper:(struct objc_super *)super_data
{
    if (super_data->receiver == nil) {
        return nil;
    }
    
    @try {
        if (shouldPreventNSUndefinedKeyException) {
            [self beginPreventionOfNSUndefinedKeyExceptionFromObject:super_data->receiver];
        }
        
        // We accept nil super_data->super_class, as a convenience for our
        // implementation of valueForKey:inObject:.
#if !defined(__cplusplus)  &&  !__OBJC2__
        if (super_data->class)  // support for 32bits MacOS (see declaration of struct objc_super in <objc/message.h>)
#else
        if (super_data->super_class)
#endif
        {
            return objc_msgSendSuper(super_data, @selector(valueForKey:), key);
        } else {
            return [super_data->receiver valueForKey:key];
        }
    }
    
    @catch (NSException *exception) {
        
        // Swallow NSUndefinedKeyException only
        
        if (![[exception name] isEqualToString:NSUndefinedKeyException]) {
            [exception raise];
        }
#if !defined(NS_BLOCK_ASSERTIONS)
        else {
            // For testing purpose
            GRMustacheContextDidCatchNSUndefinedKeyException = YES;
        }
#endif
    }
    
    @finally {
        if (shouldPreventNSUndefinedKeyException) {
            [self endPreventionOfNSUndefinedKeyExceptionFromObject:super_data->receiver];
        }
    }
    
    return nil;
}

+ (BOOL)objectIsFoundationCollectionWhoseImplementationOfValueForKeyReturnsAnotherCollection:(id)object
{
    // Returns YES if object is NSArray, NSSet, or NSOrderedSet.
    //
    // [NSObject isKindOfClass:] is slow.
    //
    // Our strategy: provide a fast path for objects whose implementation of
    // valueForKey: is the same as NSObject, NSDictionary and NSManagedObject,
    // by comparing implementations of valueForKey:. The slow path is for other
    // objects, for which we check whether they are NSArray, NSSet, or
    // NSOrderedSet with isKindOfClass:. We can not compare implementations for
    // those classes, because they are class clusters and that we can't be sure
    // they provide a single implementation of valueForKey:
    
    if (object == nil) {
        return NO;
    }
    
    static SEL valueForKeySelector = nil;
    if (valueForKeySelector == nil) {
        valueForKeySelector = @selector(valueForKey:);
    }
    IMP objectIMP = class_getMethodImplementation([object class], valueForKeySelector);
    
    // Fast path: objects using NSObject's implementation of valueForKey: are not collections
    {
        static IMP NSObjectIMP = nil;
        if (NSObjectIMP == nil) {
            NSObjectIMP = class_getMethodImplementation([NSObject class], valueForKeySelector);
        }
        if (objectIMP == NSObjectIMP) {
            return NO;
        }
    }
    
    // Fast path: objects using NSDictionary's implementation of valueForKey: are not collections
    {
        static IMP NSDictionaryIMP = nil;
        if (NSDictionaryIMP == nil) {
            NSDictionaryIMP = class_getMethodImplementation([NSDictionary class], valueForKeySelector);
        }
        if (objectIMP == NSDictionaryIMP) {
            return NO;
        }
    }
    
    // Fast path: objects using NSManagedObject's implementation of valueForKey: are not collections
    {
        // NSManagedObject may not be linked. Don't name it directly.
        static BOOL NSManagedObjectIMPComputed = NO;
        static IMP NSManagedObjectIMP = nil;
        if (NSManagedObjectIMPComputed == NO) {
            Class NSManagedObjectClass = NSClassFromString(@"NSManagedObject");
            if (NSManagedObjectClass) {
                NSManagedObjectIMP = class_getMethodImplementation(NSManagedObjectClass, valueForKeySelector);
            }
            NSManagedObjectIMPComputed = YES;
        }
        if (objectIMP == NSManagedObjectIMP) {
            return NO;
        }
    }
    
    // Slow path: NSArray, NSSet and NSOrderedSet are collections
    {
        // NSOrderedSet is iOS >= 5 or OSX >= 10.7. Don't name it directly.
        static BOOL NSOrderedSetClassComputed = NO;
        static Class NSOrderedSetClass = nil;
        if (NSOrderedSetClassComputed == NO) {
            NSOrderedSetClass = NSClassFromString(@"NSOrderedSet");
            NSOrderedSetClassComputed = YES;
        }
        
        return ([object isKindOfClass:[NSArray class]] ||
                [object isKindOfClass:[NSSet class]] ||
                (NSOrderedSetClass && [object isKindOfClass:NSOrderedSetClass]));
    }
}


#pragma mark - NSUndefinedKeyException prevention

+ (void)setupPreventionOfNSUndefinedKeyException
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        // Swizzle [NSObject valueForUndefinedKey:]
        
        [NSObject jr_swizzleMethod:@selector(valueForUndefinedKey:)
                        withMethod:@selector(GRMustacheContextValueForUndefinedKey_NSObject:)
                             error:nil];
        
        
        // Swizzle [NSManagedObject valueForUndefinedKey:]
        
        Class NSManagedObjectClass = NSClassFromString(@"NSManagedObject");
        if (NSManagedObjectClass) {
            [NSManagedObjectClass jr_swizzleMethod:@selector(valueForUndefinedKey:)
                                        withMethod:@selector(GRMustacheContextValueForUndefinedKey_NSManagedObject:)
                                             error:nil];
        }
    });
}

+ (void)beginPreventionOfNSUndefinedKeyExceptionFromObject:(id)object
{
    [self setupPreventionOfNSUndefinedKeyException];
    [[self preventionOfNSUndefinedKeyExceptionObjects] addObject:object];
}

+ (void)endPreventionOfNSUndefinedKeyExceptionFromObject:(id)object
{
    [[self preventionOfNSUndefinedKeyExceptionObjects] removeObject:object];
}

+ (NSMutableSet *)preventionOfNSUndefinedKeyExceptionObjects
{
    static NSString const * GRMustacheContextPreventionOfNSUndefinedKeyExceptionObjects = @"GRMustacheContextPreventionOfNSUndefinedKeyExceptionObjects";
    NSMutableSet *silentObjects = [[[NSThread currentThread] threadDictionary] objectForKey:GRMustacheContextPreventionOfNSUndefinedKeyExceptionObjects];
    if (silentObjects == nil) {
        silentObjects = [NSMutableSet set];
        [[[NSThread currentThread] threadDictionary] setObject:silentObjects forKey:GRMustacheContextPreventionOfNSUndefinedKeyExceptionObjects];
    }
    return silentObjects;
}

@end

@implementation NSObject(GRMustacheContextPreventionOfNSUndefinedKeyException)

// NSObject
- (id)GRMustacheContextValueForUndefinedKey_NSObject:(NSString *)key
{
    if ([[GRMustacheContext preventionOfNSUndefinedKeyExceptionObjects] containsObject:self]) {
        return nil;
    }
    return [self GRMustacheContextValueForUndefinedKey_NSObject:key];
}

// NSManagedObject
- (id)GRMustacheContextValueForUndefinedKey_NSManagedObject:(NSString *)key
{
    if ([[GRMustacheContext preventionOfNSUndefinedKeyExceptionObjects] containsObject:self]) {
        return nil;
    }
    return [self GRMustacheContextValueForUndefinedKey_NSManagedObject:key];
}

@end
