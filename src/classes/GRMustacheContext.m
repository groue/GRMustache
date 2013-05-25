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
#import "GRMustacheParser_private.h"
#import "GRMustacheExpression_private.h"
#import "JRSwizzle.h"


#if !defined(NS_BLOCK_ASSERTIONS)
BOOL GRMustacheContextDidCatchNSUndefinedKeyException;
#endif

typedef NS_ENUM(NSInteger, GRMustachePropertyStoragePolicy) {
    GRMustachePropertyStoragePolicyAssign,
    GRMustachePropertyStoragePolicyRetain,
    GRMustachePropertyStoragePolicyCopy,
    GRMustachePropertyStoragePolicyWeak,
};

typedef NS_ENUM(NSInteger, GRMustachePropertyType) {
    GRMustachePropertyTypeNumber,
    GRMustachePropertyTypeObject,
    GRMustachePropertyTypeClass,
    GRMustachePropertyTypeScalar,
};

// Returns YES if the selectorName is a property accessor.
// If allowKVCAlternateName is YES, variants isFoo/foo are tested.
// If the result is YES:
// - `getter` is set to YES if the selector is a getter.
// - `readOnly` is set to YES if the property is read-only.
// - `propertyName` is set to the property name
// - `objCTypes` is set to the encoding of the property
// - `storageClass` is set to the only valid storage class
// Caller must free the returned strings.
BOOL hasManagedPropertyAccessor(Class klass, const char *selectorName, BOOL allowKVCAlternateName, BOOL *getter, BOOL *readOnly, GRMustachePropertyStoragePolicy *storagePolicy, char **propertyName, char **objCTypes, GRMustachePropertyType *type);

BOOL isManagedPropertyKVCKey(Class klass, NSString *key, id *zeroScalarValue);
NSString *managedPropertyNameForSelector(Class klass, SEL selector);
NSString *canonicalKeyForKey(Class klass, NSString *key);

static void GRMustacheContextManagedPropertyCharSetter(GRMustacheContext *self, SEL _cmd, char value);
static void GRMustacheContextManagedPropertyIntSetter(GRMustacheContext *self, SEL _cmd, int value);
static void GRMustacheContextManagedPropertyShortSetter(GRMustacheContext *self, SEL _cmd, short value);
static void GRMustacheContextManagedPropertyLongSetter(GRMustacheContext *self, SEL _cmd, long value);
static void GRMustacheContextManagedPropertyLongLongSetter(GRMustacheContext *self, SEL _cmd, long long value);
static void GRMustacheContextManagedPropertyUnsignedCharSetter(GRMustacheContext *self, SEL _cmd, unsigned char value);
static void GRMustacheContextManagedPropertyUnsignedIntSetter(GRMustacheContext *self, SEL _cmd, unsigned int value);
static void GRMustacheContextManagedPropertyUnsignedShortSetter(GRMustacheContext *self, SEL _cmd, unsigned short value);
static void GRMustacheContextManagedPropertyUnsignedLongSetter(GRMustacheContext *self, SEL _cmd, unsigned long value);
static void GRMustacheContextManagedPropertyUnsignedLongLongSetter(GRMustacheContext *self, SEL _cmd, unsigned long long value);
static void GRMustacheContextManagedPropertyFloatSetter(GRMustacheContext *self, SEL _cmd, float value);
static void GRMustacheContextManagedPropertyDoubleSetter(GRMustacheContext *self, SEL _cmd, double value);
static void GRMustacheContextManagedPropertyBoolSetter(GRMustacheContext *self, SEL _cmd, _Bool value);
static void GRMustacheContextManagedPropertyObjectSetter(GRMustacheContext *self, SEL _cmd, id value);
static void GRMustacheContextManagedPropertyClassSetter(GRMustacheContext *self, SEL _cmd, Class value);

static char GRMustacheContextManagedPropertyCharGetter(GRMustacheContext *self, SEL _cmd);
static int GRMustacheContextManagedPropertyIntGetter(GRMustacheContext *self, SEL _cmd);
static short GRMustacheContextManagedPropertyShortGetter(GRMustacheContext *self, SEL _cmd);
static long GRMustacheContextManagedPropertyLongGetter(GRMustacheContext *self, SEL _cmd);
static long long GRMustacheContextManagedPropertyLongLongGetter(GRMustacheContext *self, SEL _cmd);
static unsigned char GRMustacheContextManagedPropertyUnsignedCharGetter(GRMustacheContext *self, SEL _cmd);
static unsigned int GRMustacheContextManagedPropertyUnsignedIntGetter(GRMustacheContext *self, SEL _cmd);
static unsigned short GRMustacheContextManagedPropertyUnsignedShortGetter(GRMustacheContext *self, SEL _cmd);
static unsigned long GRMustacheContextManagedPropertyUnsignedLongGetter(GRMustacheContext *self, SEL _cmd);
static unsigned long long GRMustacheContextManagedPropertyUnsignedLongLongGetter(GRMustacheContext *self, SEL _cmd);
static float GRMustacheContextManagedPropertyFloatGetter(GRMustacheContext *self, SEL _cmd);
static double GRMustacheContextManagedPropertyDoubleGetter(GRMustacheContext *self, SEL _cmd);
static _Bool GRMustacheContextManagedPropertyBoolGetter(GRMustacheContext *self, SEL _cmd);
static id GRMustacheContextManagedPropertyObjectGetter(GRMustacheContext *self, SEL _cmd);
static Class GRMustacheContextManagedPropertyClassGetter(GRMustacheContext *self, SEL _cmd);

@interface GRMustacheContext()

// A dictionary where keys are ancestor context objects, and values depth
// numbers: self has depth 0, parent has depth 1, grand-parent has depth 2, etc.
@property (nonatomic, readonly) NSDictionary *depthsForAncestors;

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
+ (BOOL)classIsTagDelegate:(Class)klass;
+ (void)setupPreventionOfNSUndefinedKeyException;
+ (CFMutableSetRef)preventionOfNSUndefinedKeyExceptionObjects;

// Private dedicated initializer
//
// This method allows us to derive new contexts without calling the init method of the subclass.
- (id)initPrivate;

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

// Return an array of ancestor contexts.
// First context in the array is the root context.
// Last context in the array is self.
- (NSArray *)ancestors;

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

+ (void)load
{
    [self setupPreventionOfNSUndefinedKeyException];
}

+ (void)initialize
{
    if (self != [GRMustacheContext class]) {
        unsigned int count;
        objc_property_t *properties = class_copyPropertyList(self, &count);
        for (unsigned int i=0; i<count; ++i) {
            const char *attrs = property_getAttributes(properties[i]);

            // Synthesize accessors if and only if property is dynamic
            
            if (!strstr(attrs, ",D")) continue;
            
            
            const char *propertyName = property_getName(properties[i]);
            size_t objCTypeLength = strstr(attrs, ",") - attrs - 1;
            
            // Synthesize getter
            
            {
                char *getterName = nil;
                char *getterStart = strstr(attrs, ",G");            // ",ScustomGetter:,..." or NULL if there is no custom getter
                if (getterStart) {
                    getterStart += 2;                               // "customGetter:,..."
                    char *getterEnd = strstr(getterStart, ",");     // ",..." or NULL if customGetter is the last attribute
                    size_t getterLength = (getterEnd ? getterEnd : attrs + strlen(attrs)) - getterStart;
                    getterName = malloc(getterLength + 1);
                    strncpy(getterName, getterStart, getterLength);
                    getterName[getterLength] = '\0';
                }
                
                char *getterObjCTypes = malloc(objCTypeLength+3);
                strncpy(getterObjCTypes, attrs+1, objCTypeLength);
                getterObjCTypes[objCTypeLength] = '@';
                getterObjCTypes[objCTypeLength + 1] = ':';
                getterObjCTypes[objCTypeLength + 2] = '\0';
                
                switch (attrs[1]) {
                    case 'c':
                        class_addMethod(self, sel_registerName(getterName ?: propertyName), (IMP)GRMustacheContextManagedPropertyCharGetter, getterObjCTypes);
                        break;
                    case 'i':
                        class_addMethod(self, sel_registerName(getterName ?: propertyName), (IMP)GRMustacheContextManagedPropertyIntGetter, getterObjCTypes);
                        break;
                    case 's':
                        class_addMethod(self, sel_registerName(getterName ?: propertyName), (IMP)GRMustacheContextManagedPropertyShortGetter, getterObjCTypes);
                        break;
                    case 'l':
                        class_addMethod(self, sel_registerName(getterName ?: propertyName), (IMP)GRMustacheContextManagedPropertyLongGetter, getterObjCTypes);
                        break;
                    case 'q':
                        class_addMethod(self, sel_registerName(getterName ?: propertyName), (IMP)GRMustacheContextManagedPropertyLongLongGetter, getterObjCTypes);
                        break;
                    case 'C':
                        class_addMethod(self, sel_registerName(getterName ?: propertyName), (IMP)GRMustacheContextManagedPropertyUnsignedCharGetter, getterObjCTypes);
                        break;
                    case 'I':
                        class_addMethod(self, sel_registerName(getterName ?: propertyName), (IMP)GRMustacheContextManagedPropertyUnsignedIntGetter, getterObjCTypes);
                        break;
                    case 'S':
                        class_addMethod(self, sel_registerName(getterName ?: propertyName), (IMP)GRMustacheContextManagedPropertyUnsignedShortGetter, getterObjCTypes);
                        break;
                    case 'L':
                        class_addMethod(self, sel_registerName(getterName ?: propertyName), (IMP)GRMustacheContextManagedPropertyUnsignedLongGetter, getterObjCTypes);
                        break;
                    case 'Q':
                        class_addMethod(self, sel_registerName(getterName ?: propertyName), (IMP)GRMustacheContextManagedPropertyUnsignedLongLongGetter, getterObjCTypes);
                        break;
                    case 'f':
                        class_addMethod(self, sel_registerName(getterName ?: propertyName), (IMP)GRMustacheContextManagedPropertyFloatGetter, getterObjCTypes);
                        break;
                    case 'd':
                        class_addMethod(self, sel_registerName(getterName ?: propertyName), (IMP)GRMustacheContextManagedPropertyDoubleGetter, getterObjCTypes);
                        break;
                    case 'B':
                        class_addMethod(self, sel_registerName(getterName ?: propertyName), (IMP)GRMustacheContextManagedPropertyBoolGetter, getterObjCTypes);
                        break;
                    case '@':
                        class_addMethod(self, sel_registerName(getterName ?: propertyName), (IMP)GRMustacheContextManagedPropertyObjectGetter, getterObjCTypes);
                        break;
                    case '#':
                        class_addMethod(self, sel_registerName(getterName ?: propertyName), (IMP)GRMustacheContextManagedPropertyClassGetter, getterObjCTypes);
                        break;
                    default:
                        // I don't know how to write an IMP that returns any kind of argument.
                        // We'll rely of forwardInvocation:
                        break;
                }
                
                free(getterName);
                free(getterObjCTypes);
            }
            
            if (!strstr(attrs, ",R"))
            {
                // Property is read/write
                
                // Check if we can honor storage policy
                
                if (strstr(attrs, ",W"))
                {
                    // Property has `weak` storage.
                    //
                    // We store values in mutableContextObject, an NSDictionary that retain its values.
                    // Don't lie: support for weak properties is not done yet.
                    //
                    // Log and exit, because exceptions raised from initialize method do not stop the program.
                    NSLog(@"[GRMustache] Support for weak property `%s` of class %@ is not implemented.", property_getName(properties[i]), self);
                    exit(1);
                }
                else if (!strstr(attrs, ",&") && !strstr(attrs, ",C"))
                {
                    // Property has `assign` storage.
                    
                    if (strstr(attrs, "T@") == attrs) {
                        // Property has `assign` storage for an id object
                        // We store values in mutableContextObject, an NSDictionary that retain its values.
                        // Don't lie: support for weak properties is not done yet.
                        //
                        // Log and exit, because exceptions raised from initialize method do not stop the program.
                        NSLog(@"[GRMustache] Support for nonretained property `%s` of class %@ is not implemented.", property_getName(properties[i]), self);
                        exit(1);
                    }
                }
                
                // Synthesize setter
                
                {
                    char *setterName = nil;
                    char *setterStart = strstr(attrs, ",S");            // ",ScustomSetter:,..." or NULL if there is no custom setter
                    if (setterStart) {
                        setterStart += 2;                               // "customSetter:,..."
                        char *setterEnd = strstr(setterStart, ",");     // ",..." or NULL if customSetter is the last attribute
                        size_t setterLength = (setterEnd ? setterEnd : attrs + strlen(attrs)) - setterStart;
                        setterName = malloc(setterLength + 1);
                        strncpy(setterName, setterStart, setterLength);
                        setterName[setterLength] = '\0';
                    } else {
                        size_t setterLength = strlen(propertyName) + 4;
                        setterName = malloc(setterLength + 1);  // room for "setFoo:\0"
                        strcpy(setterName+3, propertyName);
                        setterName[0] = 's';
                        setterName[1] = 'e';
                        setterName[2] = 't';
                        setterName[3] += 'A' - 'a';
                        setterName[setterLength - 1] = ':';
                        setterName[setterLength] = '\0';
                    }
                    
                    char *setterObjCTypes = malloc(objCTypeLength+4);
                    strncpy(setterObjCTypes+3, attrs+1, objCTypeLength);
                    setterObjCTypes[0] = 'v';
                    setterObjCTypes[1] = '@';
                    setterObjCTypes[2] = ':';
                    setterObjCTypes[objCTypeLength+3] = '\0';
                    
                    switch (attrs[1]) {
                        case 'c':
                            class_addMethod(self, sel_registerName(setterName), (IMP)GRMustacheContextManagedPropertyCharSetter, setterObjCTypes);
                            break;
                        case 'i':
                            class_addMethod(self, sel_registerName(setterName), (IMP)GRMustacheContextManagedPropertyIntSetter, setterObjCTypes);
                            break;
                        case 's':
                            class_addMethod(self, sel_registerName(setterName), (IMP)GRMustacheContextManagedPropertyShortSetter, setterObjCTypes);
                            break;
                        case 'l':
                            class_addMethod(self, sel_registerName(setterName), (IMP)GRMustacheContextManagedPropertyLongSetter, setterObjCTypes);
                            break;
                        case 'q':
                            class_addMethod(self, sel_registerName(setterName), (IMP)GRMustacheContextManagedPropertyLongLongSetter, setterObjCTypes);
                            break;
                        case 'C':
                            class_addMethod(self, sel_registerName(setterName), (IMP)GRMustacheContextManagedPropertyUnsignedCharSetter, setterObjCTypes);
                            break;
                        case 'I':
                            class_addMethod(self, sel_registerName(setterName), (IMP)GRMustacheContextManagedPropertyUnsignedIntSetter, setterObjCTypes);
                            break;
                        case 'S':
                            class_addMethod(self, sel_registerName(setterName), (IMP)GRMustacheContextManagedPropertyUnsignedShortSetter, setterObjCTypes);
                            break;
                        case 'L':
                            class_addMethod(self, sel_registerName(setterName), (IMP)GRMustacheContextManagedPropertyUnsignedLongSetter, setterObjCTypes);
                            break;
                        case 'Q':
                            class_addMethod(self, sel_registerName(setterName), (IMP)GRMustacheContextManagedPropertyUnsignedLongLongSetter, setterObjCTypes);
                            break;
                        case 'f':
                            class_addMethod(self, sel_registerName(setterName), (IMP)GRMustacheContextManagedPropertyFloatSetter, setterObjCTypes);
                            break;
                        case 'd':
                            class_addMethod(self, sel_registerName(setterName), (IMP)GRMustacheContextManagedPropertyDoubleSetter, setterObjCTypes);
                            break;
                        case 'B':
                            class_addMethod(self, sel_registerName(setterName), (IMP)GRMustacheContextManagedPropertyBoolSetter, setterObjCTypes);
                            break;
                        case '@':
                            class_addMethod(self, sel_registerName(setterName), (IMP)GRMustacheContextManagedPropertyObjectSetter, setterObjCTypes);
                            break;
                        case '#':
                            class_addMethod(self, sel_registerName(setterName), (IMP)GRMustacheContextManagedPropertyClassSetter, setterObjCTypes);
                            break;
                        default:
                            // I don't know how to write an IMP that takes any kind of argument.
                            // We'll rely of forwardInvocation:
                            break;
                    }
                    
                    free(setterName);
                    free(setterObjCTypes);
                }
            }
        }
        free(properties);
    }
}

+ (instancetype)context
{
    return [[[self alloc] init] autorelease];
}

+ (instancetype)contextWithObject:(id)object
{
    if ([object isKindOfClass:[GRMustacheContext class]]) {
        // The rule is: contexts derived from class A should be instances of class A as well.
        if (![object isKindOfClass:self]) {
            [NSException raise:NSInvalidArgumentException format:@"%@ is not a subclass of %@: can not extend context.", [object class], self];
        }
        return object;
    }
    
    GRMustacheContext *context = [[[self alloc] init] autorelease];
    
    // initialize context stack
    context.contextObject = [object retain];
        
    // initialize tag delegate stack
    if ([self classIsTagDelegate:[object class]]) {
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

- (id)initPrivate
{
    return [super init];
}

- (instancetype)contextByAddingTagDelegate:(id<GRMustacheTagDelegate>)tagDelegate
{
    if (tagDelegate == nil) {
        return self;
    }
    
    // Don't call init method, because subclasses may alter the context stack (they may set default values for some managed properties).
    GRMustacheContext *context = [[[[self class] alloc] initPrivate] autorelease];
    
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

+ (instancetype)newContextWithParent:(GRMustacheContext *)parent addedObject:(id)object
{
    if (object == nil) {
        return [parent retain];
    }
    
    GRMustacheContext *context = nil;
    
    if ([object isKindOfClass:[GRMustacheContext class]])
    {
        // Extend self with a context
        // Contexts are immutable stacks: we duplicate all ancestors of context,
        // in order to build a new context stack.
        
        context = parent;
        for (GRMustacheContext *ancestor in ((GRMustacheContext *)object).ancestors) {
            
            // The rule is: contexts derived from class A should be instances of class A as well.
            if (![ancestor isKindOfClass:[context class]]) {
                [NSException raise:NSInvalidArgumentException format:@"%@ is not a subclass of %@: can not extend context.", [ancestor class], [context class]];
            }
            
            // Don't call init method, because subclasses may alter the context stack (they may set default values for some managed properties).
            GRMustacheContext *extendedContext = [[[[ancestor class] alloc] initPrivate] autorelease];
            
            extendedContext.contextParent = context;
            extendedContext.contextObject = ancestor->_contextObject;
            extendedContext.mutableContextObject = [[ancestor->_mutableContextObject mutableCopy] autorelease];
            extendedContext.protectedContextParent = ancestor->_protectedContextParent;
            extendedContext.protectedContextObject = ancestor->_protectedContextObject;
            extendedContext.hiddenContextParent = ancestor->_hiddenContextParent;
            extendedContext.hiddenContextObject = ancestor->_hiddenContextObject;
            extendedContext.tagDelegateParent = ancestor->_tagDelegateParent;
            extendedContext.tagDelegate = ancestor->_tagDelegate;
            extendedContext.templateOverrideParent = ancestor->_templateOverrideParent;
            extendedContext.templateOverride = ancestor->_templateOverride;
            
            context = extendedContext;
        };
        
        [context retain];
    }
    else
    {
        // Extend self with a regular object
        
        // Don't call init method, because subclasses may alter the context stack (they may set default values for some managed properties).
        context = [[[self class] alloc] initPrivate];
        
        // copy identical stacks
        context.protectedContextParent = parent->_protectedContextParent;
        context.protectedContextObject = parent->_protectedContextObject;
        context.hiddenContextParent = parent->_hiddenContextParent;
        context.hiddenContextObject = parent->_hiddenContextObject;
        context.templateOverrideParent = parent->_templateOverrideParent;
        context.templateOverride = parent->_templateOverride;
        
        // Update context stack
        context.contextParent = parent;
        context.contextObject = object;
        
        // update or copy tag delegate stack
        if ([GRMustacheContext classIsTagDelegate:[object class]]) {
            if (parent->_tagDelegate) { context.tagDelegateParent = parent; }
            context.tagDelegate = object;
        } else {
            context.tagDelegateParent = parent->_tagDelegateParent;
            context.tagDelegate = parent->_tagDelegate;
        }
    }
    
    return context;
}

- (instancetype)contextByAddingObject:(id)object
{
    return [[self class] newContextWithParent:self addedObject:object];
}

- (instancetype)contextByAddingProtectedObject:(id)object
{
    if (object == nil) {
        return self;
    }
    
    // Don't call init method, because subclasses may alter the context stack (they may set default values for some managed properties).
    GRMustacheContext *context = [[[[self class] alloc] initPrivate] autorelease];
    
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
    
    // Don't call init method, because subclasses may alter the context stack (they may set default values for some managed properties).
    GRMustacheContext *context = [[[[self class] alloc] initPrivate] autorelease];
    
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
    
    // Don't call init method, because subclasses may alter the context stack (they may set default values for some managed properties).
    GRMustacheContext *context = [[[[self class] alloc] initPrivate] autorelease];
    
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

- (NSArray *)tagDelegates
{
    NSMutableArray *tagDelegates = nil;
    
    if (_tagDelegate) {
        tagDelegates = [NSMutableArray array];
        for (GRMustacheContext *context = self; context; context = context.tagDelegateParent) {
            [tagDelegates addObject:context.tagDelegate];
        }
    }
    
    Class klass = object_getClass(self);
    if (klass != [GRMustacheContext class]) {
        
        // if self conforms to GRMustacheTagDelegate, self behaves as the first tag
        // delegate in the stack (before all section delegates).
        
        if ([GRMustacheContext classIsTagDelegate:klass]) {
            if (!tagDelegates) tagDelegates = [NSMutableArray array];
            [tagDelegates addObject:self];
        }
    }
    
    return tagDelegates;
}

- (id)topMustacheObject
{
    for (GRMustacheContext *context = self; context; context = context.contextParent) {
        id contextObject = context.contextObject;
        if (contextObject) {
            return contextObject;
        }
    }
    return nil;
}

- (id)valueForMustacheKey:(NSString *)key protected:(BOOL *)protected
{
    // First look for in the protected context stack
    
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
    
    
    // Then look for in the regular context stack
    
    NSString *mutableContextKey = nil;
    
    for (GRMustacheContext *context = self; context; context = context.contextParent) {
        // First check for contextObject:
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
        
        if (context.mutableContextObject) {

            // We're about to look into mutableContextObject.
            //
            // This dictionary is filled via setValue:forKey:, and via managed
            // property setters.
            //
            // Managed property setters use property names as the key.
            // So we have to translate custom getters to the property name.
            //
            // Regular KVC also supports `isFoo` key for `foo` property: we also
            // have to translate `isFoo` to `foo`.
            //
            // mutableContextKey holds that "canonical" key.
            
            if (mutableContextKey == nil) {
                // Support for managed properties is reserved to GRMustacheContext subclasses
                if (object_getClass(self) == [GRMustacheContext class]) {
                    mutableContextKey = key;
                } else {
                    mutableContextKey = canonicalKeyForKey([self class], key);
                }
            }

            // Check mutableContextObject:
            //
            // context = [GRMustacheContext context];
            // [context setValue:value forKey:key];
            // assert([context valueForKey:key] == value);
            
            id value = [context.mutableContextObject objectForKey:mutableContextKey];
            if (value != nil) {
                if (protected != NULL) {
                    *protected = NO;
                }
                return value;
            }
        }
    }
    
    
    // Support for extra methods and properties is reserved to GRMustacheContext subclasses
    
    if (object_getClass(self) != [GRMustacheContext class]) {
        
        
        id zeroScalarValue;
        if (isManagedPropertyKVCKey([self class], key, &zeroScalarValue)) {
            
            // Key is a managed property.
            // It the property type is a scalar, provide a default 0 value.
            
            if (protected != NULL) {
                *protected = NO;
            }
            return zeroScalarValue;
            
            
        } else {
            
            // Key is not a managed property. But subclass may have defined a
            // method for that key.
            
            // Invoke NSObject's implementation of valueForKey:
            // _nonManagedKey makes sure we do not enter an infinite loop through valueForUndefinedKey:
            id previousNonManagedKey = _nonManagedKey;
            _nonManagedKey = key;
            id value = [super valueForKey:key];
            _nonManagedKey = previousNonManagedKey;
            
            if (value) {
                if (protected != NULL) {
                    *protected = NO;
                }
                return value;
            }
        }
    }
    
    
    // Then try valueForUndefinedMustacheKey:
    
    id value = [self valueForUndefinedMustacheKey:key];
    if (value) {
        if (protected != NULL) {
            *protected = NO;
        }
        return value;
    }
    
    
    // OK give up now
    
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

- (id)valueForMustacheExpression:(NSString *)string error:(NSError **)error
{
    id value = nil;
    @autoreleasepool {
        GRMustacheExpression *expression = [GRMustacheParser parseExpression:string invalid:NULL];
        if (expression) {
            if ([expression hasValue:&value withContext:self protected:NULL error:error]) {
                [value retain]; // escape autorelease pool
            }
        } else {
            // Invalid or empty expression.
            // Since we can't return any value, return an error.
            if (error != NULL) {
                *error = [NSError errorWithDomain:GRMustacheErrorDomain
                                             code:GRMustacheErrorCodeParseError
                                         userInfo:[NSDictionary dictionaryWithObject:@"Invalid expression" forKey:NSLocalizedDescriptionKey]];
            }
        }
        if (!value && error != NULL) [*error retain];   // escape autorelease pool
    }
    if (!value && error != NULL) [*error autorelease];
    return [value autorelease];
}

- (id)valueForMustacheKey:(NSString *)key
{
    return [self valueForMustacheKey:key protected:NULL];
}

- (id)valueForUndefinedMustacheKey:(NSString *)key
{
    return nil;
}


#pragma mark - NSObject

- (void)dealloc
{
    [_depthsForAncestors release];
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

- (id)init
{
    return [self initPrivate];
}

- (id)valueForUndefinedKey:(NSString *)key
{
    // Support for managed properties is reserved to GRMustacheContext subclasses
    if (object_getClass(self) == [GRMustacheContext class]) {
        return [super valueForUndefinedKey:key];
    }
    
    // _nonManagedKey may have been set in contextValue:forKey:
    if ([_nonManagedKey isEqualToString:key]) {
        return nil;
    }

    // Key must be a getter for managed property.
    // Regular KVC also supports `isFoo` key for the `foo` property.
    BOOL getter;
    if (!hasManagedPropertyAccessor([self class], [key UTF8String], YES, &getter, NULL, NULL, NULL, NULL, NULL)) {
        return [super valueForUndefinedKey:key];
    }

    return [self valueForMustacheKey:key protected:NULL];
}

- (void)setValue:(id)value forKey:(NSString *)key
{
    // Support for managed properties is reserved to GRMustacheContext subclasses
    if (object_getClass(self) == [GRMustacheContext class]) {
        [super setValue:value forKey:key];
        return;
    }
    
    // Key must be a getter for read/write managed property.
    BOOL getter;
    BOOL readOnly;
    GRMustachePropertyStoragePolicy storagePolicy;
    GRMustachePropertyType type;
    if (!hasManagedPropertyAccessor([self class], [key UTF8String], NO, &getter, &readOnly, &storagePolicy, NULL, NULL, &type)) {
        [super setValue:value forKey:key];
        return;
    }
    
    if (!getter || readOnly) {
        [super setValue:value forKey:key];
        return;
    }
    
    // Don't accept invalid values
    switch (type) {
        case GRMustachePropertyTypeNumber:
            if (value) {
                if (![value isKindOfClass:[NSNumber class]]) {
                    return;
                }
            } else {
                [self setNilValueForKey:key];
                return;
            }
            break;
        case GRMustachePropertyTypeObject:
            break;
        case GRMustachePropertyTypeClass:
            break;
        case GRMustachePropertyTypeScalar:
            if (value) {
                if (![value isKindOfClass:[NSValue class]]) {
                    return;
                }
            } else {
                [self setNilValueForKey:key];
                return;
            }
            break;
    }
    
    // Honor storage policy
    if (storagePolicy == GRMustachePropertyStoragePolicyCopy) {
        value = [[value copy] autorelease];
    }
    
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
    
    // Support for managed properties is reserved to GRMustacheContext subclasses
    if (object_getClass(self) == [GRMustacheContext class]) {
        return NO;
    }
    
    const char *selectorName = sel_getName(selector);
    return hasManagedPropertyAccessor([self class], selectorName, NO, NULL, NULL, NULL, NULL, NULL, NULL);
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector
{
    NSMethodSignature *signature = [super methodSignatureForSelector:selector];
    if (signature) {
        return signature;
    }

    // Support for managed properties is reserved to GRMustacheContext subclasses
    if (object_getClass(self) == [GRMustacheContext class]) {
        return nil;
    }

    // The method is undefined.
    
    const char *selectorName = sel_getName(selector);
    char *propertyName;
    char *encoding;
    BOOL getter;
    if (hasManagedPropertyAccessor([self class], selectorName, NO, &getter, NULL, NULL, &propertyName, &encoding, NULL)) {

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
    // Support for managed properties is reserved to GRMustacheContext subclasses
    if (object_getClass(self) == [GRMustacheContext class]) {
        [super forwardInvocation:invocation];
        return;
    }
    
    SEL selector = [invocation selector];

    const char *selectorName = sel_getName(selector);
    char *propertyName;
    char *encoding;
    BOOL getter;
    if (hasManagedPropertyAccessor([self class], selectorName, NO, &getter, NULL, NULL, &propertyName, &encoding, NULL)) {
        
        if (getter) {
            // Getter
            //
            // context.age returns the same value as [context valueForKey:@"age"]
            
            NSUInteger valueSize;
            NSGetSizeAndAlignment(encoding, &valueSize, NULL);
            NSMutableData *data = [NSMutableData dataWithLength:valueSize];   // autoreleased so that invocation's return value survives
            void *bytes = [data mutableBytes];
            
            switch (encoding[0]) {
                case 'c':
                case 'i':
                case 's':
                case 'l':
                case 'q':
                case 'C':
                case 'I':
                case 'S':
                case 'L':
                case 'Q':
                case 'f':
                case 'd':
                case 'B':
                case '@':
                case '#':
                    [NSException raise:NSInternalInconsistencyException format:@"Missing synthesized getter for property %s", propertyName];
                    break;
                default: {
                    id value = [self valueForMustacheKey:[NSString stringWithUTF8String:propertyName] protected:NULL];
                    if (![value isKindOfClass:[NSValue class]]) return;
                    [(NSValue *)value getValue:bytes];
                } break;
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
                case 'i':
                case 's':
                case 'l':
                case 'q':
                case 'C':
                case 'I':
                case 'S':
                case 'L':
                case 'Q':
                case 'f':
                case 'd':
                case 'B':
                case '@':
                case '#':
                    [NSException raise:NSInternalInconsistencyException format:@"Missing synthesized setter for property %s", propertyName];
                    break;
                default:
                    [self setValue:[NSValue valueWithBytes:bytes objCType:encoding] forKey:[NSString stringWithUTF8String:propertyName]];
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
    
    CFMutableSetRef preventionOfNSUndefinedKeyExceptionObjects = [self preventionOfNSUndefinedKeyExceptionObjects];
    
    @try {
        CFSetAddValue(preventionOfNSUndefinedKeyExceptionObjects, super_data->receiver);
        
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
        CFSetRemoveValue(preventionOfNSUndefinedKeyExceptionObjects, super_data->receiver);
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

+ (BOOL)classIsTagDelegate:(Class)klass
{
    static CFMutableDictionaryRef cache;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cache = CFDictionaryCreateMutable(NULL, 0, NULL, NULL);
    });
    int result = (int)CFDictionaryGetValue(cache, klass);
    if (!result) {
        result = ([klass instancesRespondToSelector:@selector(mustacheTag:willRenderObject:)] ||
                  [klass instancesRespondToSelector:@selector(mustacheTag:didRenderObject:as:)] ||
                  [klass instancesRespondToSelector:@selector(mustacheTag:didFailRenderingObject:withError:)]) ? 1 : 2;
        CFDictionarySetValue(cache, klass, (const void *)result);
    }
    return (result == 1);
}

- (NSDictionary *)depthsForAncestors
{
    if (_depthsForAncestors == nil) {
        // Don't use NSMutableDictionary, which has copy semantics on keys.
        // Instead, use CFDictionaryCreateMutable that does not manage keys, but manages values (depth numbers)
        CFMutableDictionaryRef depthsForAncestors = CFDictionaryCreateMutable(NULL, 0, NULL, &kCFTypeDictionaryValueCallBacks);
        
        // self has depth 0
        CFDictionarySetValue(depthsForAncestors, self, [NSNumber numberWithUnsignedInteger:0]);
        
        void (^fill)(id key, id obj, BOOL *stop) = ^(GRMustacheContext *ancestor, NSNumber *depth, BOOL *stop) {
            NSUInteger currentDepth = [(NSNumber *)CFDictionaryGetValue(depthsForAncestors, ancestor) unsignedIntegerValue];
            if (currentDepth < [depth unsignedIntegerValue] + 1) {
                CFDictionarySetValue(depthsForAncestors, ancestor, [NSNumber numberWithUnsignedInteger:[depth unsignedIntegerValue] + 1]);
            }
        };
        [[_contextParent depthsForAncestors] enumerateKeysAndObjectsUsingBlock:fill];
        [[_protectedContextParent depthsForAncestors] enumerateKeysAndObjectsUsingBlock:fill];
        [[_hiddenContextParent depthsForAncestors] enumerateKeysAndObjectsUsingBlock:fill];
        [[_tagDelegateParent depthsForAncestors] enumerateKeysAndObjectsUsingBlock:fill];
        [[_templateOverrideParent depthsForAncestors] enumerateKeysAndObjectsUsingBlock:fill];
        
        _depthsForAncestors = (NSDictionary *)depthsForAncestors;
    }
    
    return [[_depthsForAncestors retain] autorelease];
}

- (NSArray *)ancestors
{
    return [[self depthsForAncestors] keysSortedByValueUsingComparator:^NSComparisonResult(NSNumber *depth1, NSNumber *depth2) {
        return -[depth1 compare:depth2];
    }];
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

+ (CFMutableSetRef)preventionOfNSUndefinedKeyExceptionObjects
{
    if ([NSThread isMainThread]) {
        static CFMutableSetRef mainThreadPreventionOfNSUndefinedKeyExceptionObjects;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            mainThreadPreventionOfNSUndefinedKeyExceptionObjects = CFSetCreateMutable(NULL, 0, NULL);
        });
        return mainThreadPreventionOfNSUndefinedKeyExceptionObjects;
    }
    
    NSThread *thread = [NSThread currentThread];
    static NSString const * GRMustacheContextPreventionOfNSUndefinedKeyExceptionObjects = @"GRMustacheContextPreventionOfNSUndefinedKeyExceptionObjects";
    CFMutableSetRef silentObjects = (CFMutableSetRef)[[thread threadDictionary] objectForKey:GRMustacheContextPreventionOfNSUndefinedKeyExceptionObjects];
    if (silentObjects == nil) {
        silentObjects = CFSetCreateMutable(NULL, 0, NULL);
        [[thread threadDictionary] setObject:(id)silentObjects forKey:GRMustacheContextPreventionOfNSUndefinedKeyExceptionObjects];
    }
    return silentObjects;
}

@end

@implementation NSObject(GRMustacheContextPreventionOfNSUndefinedKeyException)

// NSObject
- (id)GRMustacheContextValueForUndefinedKey_NSObject:(NSString *)key
{
    if (CFSetContainsValue([GRMustacheContext preventionOfNSUndefinedKeyExceptionObjects], self)) {
        return nil;
    }
    return [self GRMustacheContextValueForUndefinedKey_NSObject:key];
}

// NSManagedObject
- (id)GRMustacheContextValueForUndefinedKey_NSManagedObject:(NSString *)key
{
    if (CFSetContainsValue([GRMustacheContext preventionOfNSUndefinedKeyExceptionObjects], self)) {
        return nil;
    }
    return [self GRMustacheContextValueForUndefinedKey_NSManagedObject:key];
}

@end

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

void getManagedPropertyInfo(const char *propertyAttributes, BOOL *readOnly, GRMustachePropertyStoragePolicy *storagePolicy, char **objCTypes, GRMustachePropertyType *type)
{
    if (readOnly) {
        *readOnly = (strstr(propertyAttributes, ",R") != nil);
    }
    if (storagePolicy) {
        if (strstr(propertyAttributes, ",&")) {
            *storagePolicy = GRMustachePropertyStoragePolicyRetain;
        } else if (strstr(propertyAttributes, ",C")) {
            *storagePolicy = GRMustachePropertyStoragePolicyCopy;
        } else if (strstr(propertyAttributes, ",W")) {
            *storagePolicy = GRMustachePropertyStoragePolicyWeak;
        } else {
            *storagePolicy = GRMustachePropertyStoragePolicyAssign;
        }
    }
    if (objCTypes) {
        size_t typeLength = strstr(propertyAttributes, ",") - propertyAttributes - 1;
        *objCTypes = malloc(typeLength + 1);
        strncpy(*objCTypes, propertyAttributes+1, typeLength);
        (*objCTypes)[typeLength] = '\0';
    }
    if (type) {
        switch (propertyAttributes[1]) {
            case 'c':
            case 'i':
            case 's':
            case 'l':
            case 'q':
            case 'C':
            case 'I':
            case 'S':
            case 'L':
            case 'Q':
            case 'f':
            case 'd':
            case 'B':
                *type = GRMustachePropertyTypeNumber;
                break;
            case '@':
                *type = GRMustachePropertyTypeObject;
                break;
            case '#':
                *type = GRMustachePropertyTypeClass;
                break;
            default:
                *type = GRMustachePropertyTypeScalar;
                break;
        }
    }
}

BOOL hasManagedPropertyAccessor(Class klass, const char *selectorName, BOOL allowKVCAlternateName, BOOL *getter, BOOL *readOnly, GRMustachePropertyStoragePolicy *storagePolicy, char **propertyName, char **objCTypes, GRMustachePropertyType *type)
{
    size_t selectorLength = strlen(selectorName);
    char *colon = strstr(selectorName, ":");
    
    if (colon == NULL)
    {
        // Arity 0: it may be a getter
        // Support KVC variants: foo and isFoo are synonyms
        char *altName = allowKVCAlternateName ? alternateNameForPropertyName(selectorName) : nil;
        
        // Look for a dynamic property named "foo" or "isFoo", or with a custom getter "foo" or "isFoo"
        BOOL found = NO;
        
        // ... in all super classes up to GRMustacheContext non included
        while (!found && klass && klass != [GRMustacheContext class]) {
            unsigned int count;
            objc_property_t *properties = class_copyPropertyList(klass, &count);
            
            for (unsigned int i=0; i<count; ++i) {
                const char *attrs = property_getAttributes(properties[i]);
                
                
                // Managed properties are dynamic
                
                if (!strstr(attrs, ",D")) continue;
                
                
                // Compare selector with property name and custom getter
                
                const char *pName = property_getName(properties[i]);
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
                
                if (!found) continue;
                
                
                // Found
                
                if (getter) {
                    *getter = YES;
                }
                if (propertyName) {
                    *propertyName = malloc(strlen(pName) + 1);
                    strcpy(*propertyName, pName);
                }
                getManagedPropertyInfo(attrs, readOnly, storagePolicy, objCTypes, type);
                
                break;
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
        
        // ... in all super classes up to GRMustacheContext non included
        while (!found && klass && klass != [GRMustacheContext class]) {
            unsigned int count;
            objc_property_t *properties = class_copyPropertyList(klass, &count);
            
            for (unsigned int i=0; i<count; ++i) {
                const char *attrs = property_getAttributes(properties[i]);
                
                
                // Managed properties are dynamic
                
                if (!strstr(attrs, ",D")) continue;
                
                
                // Property needs to be read/write for selector to be a setter
                
                if (strstr(attrs, ",R")) continue;
                
                
                // Compare selector with custom setter or property names
                
                const char *pName = property_getName(properties[i]);
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
                
                if (!found) continue;
                
                
                // Found
                
                if (getter) {
                    *getter = NO;
                }
                if (propertyName) {
                    *propertyName = malloc(strlen(pName) + 1);
                    strcpy(*propertyName, pName);
                }
                getManagedPropertyInfo(attrs, readOnly, storagePolicy, objCTypes, type);
                
                break;
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

NSString *managedPropertyNameForSelector(Class klass, SEL selector)
{
    static CFMutableDictionaryRef classCache;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // Don't use NSMutableDictionary, which has copy semantics on keys.
        // Instead, use CFDictionaryCreateMutable that does not manage keys (classes), but manages values (dictionaries)
        classCache = CFDictionaryCreateMutable(NULL, 0, NULL, &kCFTypeDictionaryValueCallBacks);
    });
    
    CFMutableDictionaryRef selectorCache = (CFMutableDictionaryRef)CFDictionaryGetValue(classCache, klass);
    if (selectorCache == nil) {
        // Don't use NSMutableDictionary, which has copy semantics on keys.
        // Instead, use CFDictionaryCreateMutable that does not manage keys (selectors), but manages values (strings)
        selectorCache = CFDictionaryCreateMutable(NULL, 0, NULL, &kCFTypeDictionaryValueCallBacks);
        CFDictionarySetValue(classCache, klass, selectorCache);
    }
    
    NSString *propertyName = CFDictionaryGetValue(selectorCache, selector);
    if (propertyName == nil) {
        char *propertyNameCString;
        hasManagedPropertyAccessor(klass, sel_getName(selector), NO, NULL, NULL, NULL, &propertyNameCString, NULL, NULL);
        propertyName = [NSString stringWithUTF8String:propertyNameCString];
        free(propertyNameCString);
        
        CFDictionarySetValue(selectorCache, selector, propertyName);
    }
    
    return propertyName;
}

NSString *canonicalKeyForKey(Class klass, NSString *key)
{
    static CFMutableDictionaryRef classCache;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // Don't use NSMutableDictionary, which has copy semantics on keys.
        // Instead, use CFDictionaryCreateMutable that does not manage keys, but manages values (depth numbers)
        classCache = CFDictionaryCreateMutable(NULL, 0, NULL, &kCFTypeDictionaryValueCallBacks);
    });
    
    NSMutableDictionary *keyCache = CFDictionaryGetValue(classCache, klass);
    if (keyCache == nil) {
        keyCache = [NSMutableDictionary dictionary];
        CFDictionarySetValue(classCache, klass, keyCache);
    }
    
    NSString *canonicalKey = [keyCache objectForKey:key];
    if (canonicalKey == nil) {
        // Assume unknown key
        canonicalKey = key;
        
        BOOL getter;
        char *propertyNameCString;
        if (hasManagedPropertyAccessor(klass, [key UTF8String], YES, &getter, NULL, NULL, &propertyNameCString, NULL, NULL)) {
            if (getter) {
                canonicalKey = [NSString stringWithUTF8String:propertyNameCString];
            }
            free(propertyNameCString);
        }
        
        [keyCache setValue:canonicalKey forKey:key];
    }
    
    return canonicalKey;
}

BOOL isManagedPropertyKVCKey(Class klass, NSString *key, id *zeroScalarValue)
{
    static CFMutableDictionaryRef isManagedPropertyClassCache;
    static CFMutableDictionaryRef zeroScalarValueClassCache;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // Don't use NSMutableDictionary, which has copy semantics on keys.
        // Instead, use CFDictionaryCreateMutable that does not manage keys (classes), but manages values (dictionaries)
        isManagedPropertyClassCache = CFDictionaryCreateMutable(NULL, 0, NULL, &kCFTypeDictionaryValueCallBacks);
        zeroScalarValueClassCache = CFDictionaryCreateMutable(NULL, 0, NULL, &kCFTypeDictionaryValueCallBacks);
    });
    
    NSMutableDictionary *isManagedPropertyCache = CFDictionaryGetValue(isManagedPropertyClassCache, klass);
    if (isManagedPropertyCache == nil) {
        isManagedPropertyCache = [NSMutableDictionary dictionary];
        CFDictionarySetValue(isManagedPropertyClassCache, klass, isManagedPropertyCache);
    }
    
    NSMutableDictionary *zeroScalarValueCache = CFDictionaryGetValue(zeroScalarValueClassCache, klass);
    if (zeroScalarValueCache == nil) {
        zeroScalarValueCache = [NSMutableDictionary dictionary];
        CFDictionarySetValue(zeroScalarValueClassCache, klass, zeroScalarValueCache);
    }
    
    NSNumber *result = [isManagedPropertyCache objectForKey:key];
    if (result == nil) {
        BOOL isManagedProperty = NO;
        id zeroScalarValue = nil;
        
        BOOL getter;
        char *encoding;
        if (hasManagedPropertyAccessor(klass, [key UTF8String], YES, &getter, NULL, NULL, NULL, &encoding, NULL)) {
            isManagedProperty = getter;

            if (isManagedProperty) {
                // build zero scalar value
                
                switch (encoding[0]) {
                    case 'c':
                        zeroScalarValue = [NSNumber numberWithChar:0];
                        break;
                    case 'i':
                        zeroScalarValue = [NSNumber numberWithInt:0];
                        break;
                    case 's':
                        zeroScalarValue = [NSNumber numberWithShort:0];
                        break;
                    case 'l':
                        zeroScalarValue = [NSNumber numberWithLong:0];
                        break;
                    case 'q':
                        zeroScalarValue = [NSNumber numberWithLongLong:0];
                        break;
                    case 'C':
                        zeroScalarValue = [NSNumber numberWithUnsignedChar:0];
                        break;
                    case 'I':
                        zeroScalarValue = [NSNumber numberWithUnsignedInt:0];
                        break;
                    case 'S':
                        zeroScalarValue = [NSNumber numberWithUnsignedShort:0];
                        break;
                    case 'L':
                        zeroScalarValue = [NSNumber numberWithUnsignedLong:0];
                        break;
                    case 'Q':
                        zeroScalarValue = [NSNumber numberWithUnsignedLongLong:0];
                        break;
                    case 'f':
                        zeroScalarValue = [NSNumber numberWithFloat:0.0f];
                        break;
                    case 'd':
                        zeroScalarValue = [NSNumber numberWithDouble:0.0];
                        break;
                    case 'B':
                        zeroScalarValue = [NSNumber numberWithBool:0];
                        break;
                    case '@':
                        zeroScalarValue = nil;
                        break;
                    case '#':
                        zeroScalarValue = Nil;
                        break;
                    default: {
                        NSUInteger valueSize;
                        NSGetSizeAndAlignment(encoding, &valueSize, NULL);
                        void *bytes = malloc(valueSize);
                        memset(bytes, 0, valueSize);
                        zeroScalarValue = [NSValue valueWithBytes:bytes objCType:encoding];
                        free(bytes);
                    } break;
                }
            }
            
            free(encoding);
        }
        
        result = [NSNumber numberWithBool:isManagedProperty];
        [isManagedPropertyCache setValue:result forKey:key];
        if (zeroScalarValue) {
            [zeroScalarValueCache setValue:zeroScalarValue forKey:key];
        }
    }
    
    if ([result boolValue] && zeroScalarValue != NULL) {
        *zeroScalarValue = [zeroScalarValueCache objectForKey:key];
    }
    return [result boolValue];
}

static void GRMustacheContextManagedPropertyCharSetter(GRMustacheContext *self, SEL _cmd, char value)
{
    [self setValue:[NSNumber numberWithChar:value] forKey:managedPropertyNameForSelector([self class], _cmd)];
}

static void GRMustacheContextManagedPropertyIntSetter(GRMustacheContext *self, SEL _cmd, int value)
{
    [self setValue:[NSNumber numberWithInt:value] forKey:managedPropertyNameForSelector([self class], _cmd)];
}

static void GRMustacheContextManagedPropertyShortSetter(GRMustacheContext *self, SEL _cmd, short value)
{
    [self setValue:[NSNumber numberWithShort:value] forKey:managedPropertyNameForSelector([self class], _cmd)];
}

static void GRMustacheContextManagedPropertyLongSetter(GRMustacheContext *self, SEL _cmd, long value)
{
    [self setValue:[NSNumber numberWithLong:value] forKey:managedPropertyNameForSelector([self class], _cmd)];
}

static void GRMustacheContextManagedPropertyLongLongSetter(GRMustacheContext *self, SEL _cmd, long long value)
{
    [self setValue:[NSNumber numberWithLongLong:value] forKey:managedPropertyNameForSelector([self class], _cmd)];
}

static void GRMustacheContextManagedPropertyUnsignedCharSetter(GRMustacheContext *self, SEL _cmd, unsigned char value)
{
    [self setValue:[NSNumber numberWithUnsignedChar:value] forKey:managedPropertyNameForSelector([self class], _cmd)];
}

static void GRMustacheContextManagedPropertyUnsignedIntSetter(GRMustacheContext *self, SEL _cmd, unsigned int value)
{
    [self setValue:[NSNumber numberWithUnsignedInt:value] forKey:managedPropertyNameForSelector([self class], _cmd)];
}

static void GRMustacheContextManagedPropertyUnsignedShortSetter(GRMustacheContext *self, SEL _cmd, unsigned short value)
{
    [self setValue:[NSNumber numberWithUnsignedShort:value] forKey:managedPropertyNameForSelector([self class], _cmd)];
}

static void GRMustacheContextManagedPropertyUnsignedLongSetter(GRMustacheContext *self, SEL _cmd, unsigned long value)
{
    [self setValue:[NSNumber numberWithUnsignedLong:value] forKey:managedPropertyNameForSelector([self class], _cmd)];
}

static void GRMustacheContextManagedPropertyUnsignedLongLongSetter(GRMustacheContext *self, SEL _cmd, unsigned long long value)
{
    [self setValue:[NSNumber numberWithUnsignedLongLong:value] forKey:managedPropertyNameForSelector([self class], _cmd)];
}

static void GRMustacheContextManagedPropertyFloatSetter(GRMustacheContext *self, SEL _cmd, float value)
{
    [self setValue:[NSNumber numberWithFloat:value] forKey:managedPropertyNameForSelector([self class], _cmd)];
}

static void GRMustacheContextManagedPropertyDoubleSetter(GRMustacheContext *self, SEL _cmd, double value)
{
    [self setValue:[NSNumber numberWithDouble:value] forKey:managedPropertyNameForSelector([self class], _cmd)];
}

static void GRMustacheContextManagedPropertyBoolSetter(GRMustacheContext *self, SEL _cmd, _Bool value)
{
    [self setValue:[NSNumber numberWithBool:value] forKey:managedPropertyNameForSelector([self class], _cmd)];
}

static void GRMustacheContextManagedPropertyObjectSetter(GRMustacheContext *self, SEL _cmd, id value)
{
    [self setValue:value forKey:managedPropertyNameForSelector([self class], _cmd)];
}

static void GRMustacheContextManagedPropertyClassSetter(GRMustacheContext *self, SEL _cmd, Class value)
{
    [self setValue:value forKey:managedPropertyNameForSelector([self class], _cmd)];
}

static char GRMustacheContextManagedPropertyCharGetter(GRMustacheContext *self, SEL _cmd)
{
    return [[self valueForMustacheKey:managedPropertyNameForSelector([self class], _cmd) protected:NULL] charValue];
}

static int GRMustacheContextManagedPropertyIntGetter(GRMustacheContext *self, SEL _cmd)
{
    return [[self valueForMustacheKey:managedPropertyNameForSelector([self class], _cmd) protected:NULL] intValue];
}

static short GRMustacheContextManagedPropertyShortGetter(GRMustacheContext *self, SEL _cmd)
{
    return [[self valueForMustacheKey:managedPropertyNameForSelector([self class], _cmd) protected:NULL] shortValue];
}

static long GRMustacheContextManagedPropertyLongGetter(GRMustacheContext *self, SEL _cmd)
{
    return [[self valueForMustacheKey:managedPropertyNameForSelector([self class], _cmd) protected:NULL] longValue];
}

static long long GRMustacheContextManagedPropertyLongLongGetter(GRMustacheContext *self, SEL _cmd)
{
    return [[self valueForMustacheKey:managedPropertyNameForSelector([self class], _cmd) protected:NULL] longLongValue];
}

static unsigned char GRMustacheContextManagedPropertyUnsignedCharGetter(GRMustacheContext *self, SEL _cmd)
{
    return [[self valueForMustacheKey:managedPropertyNameForSelector([self class], _cmd) protected:NULL] unsignedCharValue];
}

static unsigned int GRMustacheContextManagedPropertyUnsignedIntGetter(GRMustacheContext *self, SEL _cmd)
{
    return [[self valueForMustacheKey:managedPropertyNameForSelector([self class], _cmd) protected:NULL] unsignedIntValue];
}

static unsigned short GRMustacheContextManagedPropertyUnsignedShortGetter(GRMustacheContext *self, SEL _cmd)
{
    return [[self valueForMustacheKey:managedPropertyNameForSelector([self class], _cmd) protected:NULL] unsignedShortValue];
}

static unsigned long GRMustacheContextManagedPropertyUnsignedLongGetter(GRMustacheContext *self, SEL _cmd)
{
    return [[self valueForMustacheKey:managedPropertyNameForSelector([self class], _cmd) protected:NULL] unsignedLongValue];
}

static unsigned long long GRMustacheContextManagedPropertyUnsignedLongLongGetter(GRMustacheContext *self, SEL _cmd)
{
    return [[self valueForMustacheKey:managedPropertyNameForSelector([self class], _cmd) protected:NULL] unsignedLongLongValue];
}

static float GRMustacheContextManagedPropertyFloatGetter(GRMustacheContext *self, SEL _cmd)
{
    return [[self valueForMustacheKey:managedPropertyNameForSelector([self class], _cmd) protected:NULL] floatValue];
}

static double GRMustacheContextManagedPropertyDoubleGetter(GRMustacheContext *self, SEL _cmd)
{
    return [[self valueForMustacheKey:managedPropertyNameForSelector([self class], _cmd) protected:NULL] doubleValue];
}

static _Bool GRMustacheContextManagedPropertyBoolGetter(GRMustacheContext *self, SEL _cmd)
{
    return [[self valueForMustacheKey:managedPropertyNameForSelector([self class], _cmd) protected:NULL] boolValue];
}

static id GRMustacheContextManagedPropertyObjectGetter(GRMustacheContext *self, SEL _cmd)
{
    return [self valueForMustacheKey:managedPropertyNameForSelector([self class], _cmd) protected:NULL];
}

static Class GRMustacheContextManagedPropertyClassGetter(GRMustacheContext *self, SEL _cmd)
{
    return [self valueForMustacheKey:managedPropertyNameForSelector([self class], _cmd) protected:NULL];
}

