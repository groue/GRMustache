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

#import <objc/runtime.h>
#import "GRMustacheContext_private.h"
#import "GRMustacheTag_private.h"
#import "GRMustacheExpression_private.h"
#import "GRMustacheExpressionParser_private.h"
#import "GRMustacheKeyAccess_private.h"
#import "GRMustacheTagDelegate.h"


// =============================================================================
#pragma mark - Managed Properties Declarations

typedef NS_ENUM(NSInteger, GRMustachePropertyStoragePolicy) {
    GRMustachePropertyStoragePolicyAssign,
    GRMustachePropertyStoragePolicyRetain,
    GRMustachePropertyStoragePolicyCopy,
    GRMustachePropertyStoragePolicyWeak,
};

typedef NS_ENUM(NSInteger, GRMustachePropertyType) {
    GRMustachePropertyTypeNumber, // char, int, etc.
    GRMustachePropertyTypeObject, // id
    GRMustachePropertyTypeClass,  // Class
    GRMustachePropertyTypeScalar, // char*, struct, union, etc.
};

// Low-level managed property function.
//
// Returns YES if the selectorName is a managed property accessor or KVC key.
//
// Given a property named `foo`, the selector names "foo", "isFoo" and "setFoo:"
// can be recognized by this function.
//
// Input:
//
// - `klass`: the queried class
// - `selectorName`: the tested selector
// - `allowKVCAlternateName`: if YES, variants isFoo/foo are tested.
//
// Output: if the result is YES, then:
//
// - `getter` is set to YES if the selector is a getter.
// - `readOnly` is set to YES if the property is read-only.
// - `propertyName` is set to the property name.
// - `objCTypes` is set to the encoding of the property.
// - `type` is set to the type of the property.
//
// Caller must free the returned strings.
BOOL hasManagedPropertyAccessor(Class klass, const char *selectorName, BOOL allowKVCAlternateName, BOOL *getter, BOOL *readOnly, GRMustachePropertyStoragePolicy *storagePolicy, char **propertyName, char **objCTypes, GRMustachePropertyType *type);

// Returns YES if key is a KVC name for a managed property, and sets
// zeroValue to the default unitialized value for this property.
//
// Given an NSInteger property named `foo`, both @"foo" and @"isFoo" are KVC
// names, and zeroValue will be set to [NSNumber numberWithInteger:0].
//
// Given an NSSttring* property named `bar`, both @"bar" and @"isBar" are KVC
// names, and zeroValue will be set to nil.
BOOL isManagedPropertyKVCKey(Class klass, NSString *key, id *zeroValue);

// TODO
NSString *canonicalKeyForKey(Class klass, NSString *key);


// =============================================================================
#pragma mark - GRMustacheContext

@interface GRMustacheContext()

// `depthsForAncestors` returns a dictionary where keys are ancestor context
// objects, and values depth numbers: self has depth 0, parent has depth 1,
// grand-parent has depth 2, etc.
@property (nonatomic, readonly) NSDictionary *depthsForAncestors;

// `ancestors` returns an array of ancestor contexts.
// First context in the array is the root context.
// Last context in the array is self.
@property (nonatomic, readonly) NSArray *ancestors;

@end


@implementation GRMustacheContext

+ (void)initialize
{
    if (self != [GRMustacheContext class]) {
        [self synthesizeManagedPropertiesAccessors];
    }
}

- (id<GRMustacheTemplateComponent>)resolveTemplateComponent:(id<GRMustacheTemplateComponent>)component
{
    if (_partialOverride) {
        for (GRMustacheContext *context = self; context; context = context->_partialOverrideParent) {
            component = [context->_partialOverride resolveTemplateComponent:component];
        }
    }
    return component;
}


// =============================================================================
#pragma mark - Creating Contexts

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
    context->_contextObject = [object retain];
        
    // initialize tag delegate stack
    if ([self objectIsTagDelegate:object]) {
        context->_tagDelegate = [object retain];
    }
    
    return context;
}

+ (instancetype)contextWithProtectedObject:(id)object
{
    GRMustacheContext *context = [[[self alloc] init] autorelease];
    
    // initialize protected context stack
    context->_protectedContextObject = [object retain];
    
    return context;
}

+ (instancetype)contextWithTagDelegate:(id<GRMustacheTagDelegate>)tagDelegate
{
    GRMustacheContext *context = [[[self alloc] init] autorelease];
    
    // initialize tag delegate stack
    context->_tagDelegate = [tagDelegate retain];
    
    return context;
}

// Private designated initializer
//
// This method allows us to derive new contexts without calling the init method of the subclass.
- (id)initPrivate
{
    return [super init];
}

// Public designated initializer
- (id)init
{
    return [self initPrivate];
}

- (void)dealloc
{
    [_contextParent release];
    [_contextObject release];
    [_managedPropertiesStore release];
    [_protectedContextParent release];
    [_protectedContextObject release];
    [_hiddenContextParent release];
    [_hiddenContextObject release];
    [_tagDelegateParent release];
    [_tagDelegate release];
    [_partialOverrideParent release];
    [_partialOverride release];
    [_depthsForAncestors release];
    [super dealloc];
}


// =============================================================================
#pragma mark - Deriving Contexts

+ (instancetype)newContextWithParent:(GRMustacheContext *)parent addedObject:(id)object
{
    if (object == nil) {
        return [parent retain];
    }
    
    GRMustacheContext *context = nil;
    
    if ([object isKindOfClass:[GRMustacheContext class]])
    {
        // Extend parent with a context
        //
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
            
            extendedContext->_contextParent = [context retain];
            extendedContext->_contextObject = [ancestor->_contextObject retain];
            extendedContext->_managedPropertiesStore = [ancestor->_managedPropertiesStore retain];
            extendedContext->_protectedContextParent = [ancestor->_protectedContextParent retain];
            extendedContext->_protectedContextObject = [ancestor->_protectedContextObject retain];
            extendedContext->_hiddenContextParent = [ancestor->_hiddenContextParent retain];
            extendedContext->_hiddenContextObject = [ancestor->_hiddenContextObject retain];
            extendedContext->_tagDelegateParent = [ancestor->_tagDelegateParent retain];
            extendedContext->_tagDelegate = [ancestor->_tagDelegate retain];
            extendedContext->_partialOverrideParent = [ancestor->_partialOverrideParent retain];
            extendedContext->_partialOverride = [ancestor->_partialOverride retain];
            
            context = extendedContext;
        };
        
        [context retain];
    }
    else
    {
        // Extend parent with a regular object
        
        // Don't call init method, because subclasses may alter the context stack (they may set default values for some managed properties).
        context = [[[self class] alloc] initPrivate];
        
        // copy identical stacks
        context->_protectedContextParent = [parent->_protectedContextParent retain];
        context->_protectedContextObject = [parent->_protectedContextObject retain];
        context->_hiddenContextParent = [parent->_hiddenContextParent retain];
        context->_hiddenContextObject = [parent->_hiddenContextObject retain];
        context->_partialOverrideParent = [parent->_partialOverrideParent retain];
        context->_partialOverride = [parent->_partialOverride retain];
        
        // Update context stack
        context->_contextParent = [parent retain];
        context->_contextObject = [object retain];
        
        // update or copy tag delegate stack
        if ([GRMustacheContext objectIsTagDelegate:object]) {
            if (parent->_tagDelegate) { context->_tagDelegateParent = [parent retain]; }
            context->_tagDelegate = [object retain];
        } else {
            context->_tagDelegateParent = [parent->_tagDelegateParent retain];
            context->_tagDelegate = [parent->_tagDelegate retain];
        }
    }
    
    return context;
}

- (instancetype)contextByAddingTagDelegate:(id<GRMustacheTagDelegate>)tagDelegate
{
    if (tagDelegate == nil) {
        return self;
    }
    
    // Don't call init method, because subclasses may alter the context stack (they may set default values for some managed properties).
    GRMustacheContext *context = [[[[self class] alloc] initPrivate] autorelease];
    
    // Update context stack
    context->_contextParent = [self retain];
    
    // copy identical stacks
    context->_protectedContextParent = [_protectedContextParent retain];
    context->_protectedContextObject = [_protectedContextObject retain];
    context->_hiddenContextParent = [_hiddenContextParent retain];
    context->_hiddenContextObject = [_hiddenContextObject retain];
    context->_partialOverrideParent = [_partialOverrideParent retain];
    context->_partialOverride = [_partialOverride retain];
    
    // update tag delegate stack
    if (_tagDelegate) { context->_tagDelegateParent = [self retain]; }
    context->_tagDelegate = [tagDelegate retain];
    
    return context;
}

- (instancetype)contextByAddingObject:(id)object
{
    return [[[self class] newContextWithParent:self addedObject:object] autorelease];
}

- (instancetype)contextByAddingProtectedObject:(id)object
{
    if (object == nil) {
        return self;
    }
    
    // Don't call init method, because subclasses may alter the context stack (they may set default values for some managed properties).
    GRMustacheContext *context = [[[[self class] alloc] initPrivate] autorelease];
    
    // Update context stack
    context->_contextParent = [self retain];
    
    // copy identical stacks
    context->_hiddenContextParent = [_hiddenContextParent retain];
    context->_hiddenContextObject = [_hiddenContextObject retain];
    context->_tagDelegateParent = [_tagDelegateParent retain];
    context->_tagDelegate = [_tagDelegate retain];
    context->_partialOverrideParent = [_partialOverrideParent retain];
    context->_partialOverride = [_partialOverride retain];
    
    // update protected context stack
    if (_protectedContextObject) { context->_protectedContextParent = [self retain]; }
    context->_protectedContextObject = [object retain];
    
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
    context->_contextParent = [self retain];
    
    // copy identical stacks
    context->_protectedContextParent = [_protectedContextParent retain];
    context->_protectedContextObject = [_protectedContextObject retain];
    context->_tagDelegateParent = [_tagDelegateParent retain];
    context->_tagDelegate = [_tagDelegate retain];
    context->_partialOverrideParent = [_partialOverrideParent retain];
    context->_partialOverride = [_partialOverride retain];
    
    // update hidden context stack
    if (_hiddenContextObject) { context->_hiddenContextParent = [self retain]; }
    context->_hiddenContextObject = [object retain];
    
    return context;
}

- (instancetype)contextByAddingPartialOverride:(GRMustachePartialOverride *)partialOverride
{
    if (partialOverride == nil) {
        return self;
    }
    
    // Don't call init method, because subclasses may alter the context stack (they may set default values for some managed properties).
    GRMustacheContext *context = [[[[self class] alloc] initPrivate] autorelease];
    
    // Update context stack
    context->_contextParent = [self retain];
    
    // copy identical stacks
    context->_protectedContextParent = [_protectedContextParent retain];
    context->_protectedContextObject = [_protectedContextObject retain];
    context->_hiddenContextParent = [_hiddenContextParent retain];
    context->_hiddenContextObject = [_hiddenContextObject retain];
    context->_tagDelegateParent = [_tagDelegateParent retain];
    context->_tagDelegate = [_tagDelegate retain];
    
    // update partial override stack
    if (_partialOverride) { context->_partialOverrideParent = [self retain]; }
    context->_partialOverride = [partialOverride retain];
    
    return context;
}

- (NSArray *)ancestors
{
    return [[self depthsForAncestors] keysSortedByValueUsingComparator:^NSComparisonResult(NSNumber *depth1, NSNumber *depth2) {
        return -[depth1 compare:depth2];
    }];
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
        [[_partialOverrideParent depthsForAncestors] enumerateKeysAndObjectsUsingBlock:fill];
        
        _depthsForAncestors = (NSDictionary *)depthsForAncestors;
    }
    
    return [[_depthsForAncestors retain] autorelease];
}


// =============================================================================
#pragma mark - Context Stack

- (id)topMustacheObject
{
    for (GRMustacheContext *context = self; context; context = context->_contextParent) {
        if (context->_contextObject) {
            return [[context->_contextObject retain] autorelease];
        }
    }
    return nil;
}

- (id)valueForUndefinedMustacheKey:(NSString *)key
{
    return nil;
}

- (id)valueForMustacheKey:(NSString *)key
{
    return [self valueForMustacheKey:key protected:NULL];
}

- (id)valueForMustacheKey:(NSString *)key protected:(BOOL *)protected
{
    // First look for in the protected context stack
    
    if (_protectedContextObject) {
        for (GRMustacheContext *context = self; context; context = context->_protectedContextParent) {
            id value = [GRMustacheKeyAccess valueForMustacheKey:key inObject:context->_protectedContextObject];
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
    
    for (GRMustacheContext *context = self; context; context = context->_contextParent) {
        // First check for contextObject:
        //
        // context = [GRMustacheContext contextWithObject:@{key:value}];
        // assert([context valueForKey:key] == value);
        id contextObject = context->_contextObject;
        if (contextObject) {
            BOOL hidden = NO;
            if (_hiddenContextObject) {
                for (GRMustacheContext *hiddenContext = self; hiddenContext; hiddenContext = hiddenContext->_hiddenContextParent) {
                    if (contextObject == hiddenContext->_hiddenContextObject) {
                        hidden = YES;
                        break;
                    }
                }
            }
            if (hidden) { continue; }
            id value = [GRMustacheKeyAccess valueForMustacheKey:key inObject:contextObject];
            if (value != nil) {
                if (protected != NULL) {
                    *protected = NO;
                }
                return value;
            }
        }
        
        if (context->_managedPropertiesStore) {
            
            // We're about to look into managedPropertiesStore.
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
                mutableContextKey = canonicalKeyForKey(object_getClass(self), key);
            }
            
            // Check managedPropertiesStore:
            //
            // context = [GRMustacheContext context];
            // [context setValue:value forKey:key];
            // assert([context valueForKey:key] == value);
            
            id value = [context->_managedPropertiesStore objectForKey:mutableContextKey];
            if (value != nil) {
                if (protected != NULL) {
                    *protected = NO;
                }
                return value;
            }
        }
    }
    
    
    // Support for extra methods and properties is reserved to GRMustacheContext subclasses
    
    Class klass = object_getClass(self);
    if (klass != [GRMustacheContext class]) {
        
        id zeroValue = nil;
        if (isManagedPropertyKVCKey(klass, key, &zeroValue)) {
            
            // Key is an uninitialized managed property.
            // Return the default 0 value.
            
            if (protected != NULL) {
                *protected = NO;
            }
            return zeroValue;
            
        } else {
            
            // Key is not a managed property. But subclass may have defined a
            // method for that key.
            
            id value = [GRMustacheKeyAccess valueForMustacheKey:key inObject:self];
            
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

- (BOOL)hasValue:(id *)value forMustacheExpression:(NSString *)string error:(NSError **)error
{
    GRMustacheExpressionParser *parser = [[[GRMustacheExpressionParser alloc] init] autorelease];
    GRMustacheExpression *expression = [parser parseExpression:string empty:NULL error:error];
    return [expression hasValue:value withContext:self protected:NULL error:error];
}

- (id)valueForMustacheExpression:(NSString *)string error:(NSError **)error
{
    // This deprecated method is flawed: it may return a valid nil result.
    // Let's make sure error is set to nil in this case.
    
    id value = nil;
    if (![self hasValue:&value forMustacheExpression:string error:error]) {
        return nil;
    }
    if (error) { *error = nil; }
    return value;
}


// =============================================================================
#pragma mark - Tag Delegates Stack

- (NSArray *)tagDelegateStack
{
    NSMutableArray *tagDelegateStack = nil;
    
    if (_tagDelegate) {
        tagDelegateStack = [NSMutableArray array];
        for (GRMustacheContext *context = self; context; context = context->_tagDelegateParent) {
            [tagDelegateStack insertObject:context->_tagDelegate atIndex:0];
        }
    }
    
    // If self is a GRMustacheContext subclass and conforms to
    // GRMustacheTagDelegate, self behaves as the first tag delegate in the
    // stack (before all section delegates).
    
    if (object_getClass(self) != [GRMustacheContext class] && [GRMustacheContext objectIsTagDelegate:self]) {
        if (!tagDelegateStack) {
            return [NSArray arrayWithObject:self];
        } else {
            [tagDelegateStack insertObject:self atIndex:0];
        }
    }
    
    return tagDelegateStack;
}

+ (BOOL)objectIsTagDelegate:(id)object
{
    return [object conformsToProtocol:@protocol(GRMustacheTagDelegate)];
}


// =============================================================================
#pragma mark - Key-Value Coding

- (id)valueForKey:(NSString *)key
{
    Class klass = object_getClass(self);
    
    // Support for managed properties is reserved to GRMustacheContext subclasses
    if (klass == [GRMustacheContext class]) {
        return [super valueForKey:key];
    }
    
    // Key must be a getter for managed property.
    //
    // Regular KVC also supports `isFoo` key for the `foo` property: provide YES
    // for the allowKVCAlternateName argument.
    BOOL getter;
    if (!hasManagedPropertyAccessor(klass, [key UTF8String], YES, &getter, NULL, NULL, NULL, NULL, NULL)) {
        return [super valueForKey:key];
    }
    
    if (!getter) {
        return [super valueForKey:key];
    }
    
    return [self valueForMustacheKey:key protected:NULL];
}

- (void)setValue:(id)value forKey:(NSString *)key
{
    Class klass = object_getClass(self);
    
    // Support for managed properties is reserved to GRMustacheContext subclasses
    if (klass == [GRMustacheContext class]) {
        [super setValue:value forKey:key];
        return;
    }
    
    // Key must be a getter for read/write managed property.
    BOOL getter;
    BOOL readOnly;
    GRMustachePropertyStoragePolicy storagePolicy;
    GRMustachePropertyType type;
    if (!hasManagedPropertyAccessor(klass, [key UTF8String], NO, &getter, &readOnly, &storagePolicy, NULL, NULL, &type)) {
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
    
    if (!_managedPropertiesStore) {
        _managedPropertiesStore = [[NSMutableDictionary alloc] init];
    }
    
    [_managedPropertiesStore setValue:value forKey:key];
}


// =============================================================================
#pragma mark - Managed Properties

// Returns an alternate name for a propertyName
// "foo" -> "isFoo"
// "isFoo" -> "foo"
// Caller must free the returned string.
static char *alternateNameForPropertyName(const char *propertyName)
{
    size_t propertyLength = strlen(propertyName);
    
    // Build altName ("foo" or "isFoo")
    char *altName;
    if (propertyLength >= 3 /* isX */ && strstr(propertyName, "is") == propertyName && propertyName[2] >= 'A' && propertyName[2] <= 'Z') {
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
        if (selectorLength >= 5 /* setX: */ && strstr(selectorName, "set") == selectorName && selectorName[3] >= 'A' && selectorName[3] <= 'Z')
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
    char *propertyNameCString;
    hasManagedPropertyAccessor(klass, sel_getName(selector), NO, NULL, NULL, NULL, &propertyNameCString, NULL, NULL);
    NSString *propertyName = [NSString stringWithUTF8String:propertyNameCString];
    free(propertyNameCString);
    return propertyName;
}

NSString *canonicalKeyForKey(Class klass, NSString *key)
{
    // Assume unknown key
    NSString *canonicalKey = key;
    
    BOOL getter;
    char *propertyNameCString;
    if (hasManagedPropertyAccessor(klass, [key UTF8String], YES, &getter, NULL, NULL, &propertyNameCString, NULL, NULL)) {
        if (getter) {
            canonicalKey = [NSString stringWithUTF8String:propertyNameCString];
        }
        free(propertyNameCString);
    }
    
    return canonicalKey;
}

BOOL isManagedPropertyKVCKey(Class klass, NSString *key, id *zeroValue)
{
    BOOL isManagedProperty = NO;
    char *encoding;
    if (hasManagedPropertyAccessor(klass, [key UTF8String], YES, &isManagedProperty, NULL, NULL, NULL, &encoding, NULL)) {
        if (isManagedProperty && zeroValue) {
            switch (encoding[0]) {
                case 'c':
                    *zeroValue = [NSNumber numberWithChar:0];
                    break;
                case 'i':
                    *zeroValue = [NSNumber numberWithInt:0];
                    break;
                case 's':
                    *zeroValue = [NSNumber numberWithShort:0];
                    break;
                case 'l':
                    *zeroValue = [NSNumber numberWithLong:0];
                    break;
                case 'q':
                    *zeroValue = [NSNumber numberWithLongLong:0];
                    break;
                case 'C':
                    *zeroValue = [NSNumber numberWithUnsignedChar:0];
                    break;
                case 'I':
                    *zeroValue = [NSNumber numberWithUnsignedInt:0];
                    break;
                case 'S':
                    *zeroValue = [NSNumber numberWithUnsignedShort:0];
                    break;
                case 'L':
                    *zeroValue = [NSNumber numberWithUnsignedLong:0];
                    break;
                case 'Q':
                    *zeroValue = [NSNumber numberWithUnsignedLongLong:0];
                    break;
                case 'f':
                    *zeroValue = [NSNumber numberWithFloat:0.0f];
                    break;
                case 'd':
                    *zeroValue = [NSNumber numberWithDouble:0.0];
                    break;
                case 'B':
                    *zeroValue = [NSNumber numberWithBool:0];
                    break;
                case '@':
                    *zeroValue = nil;
                    break;
                case '#':
                    *zeroValue = Nil;
                    break;
                default: {
                    NSUInteger valueSize;
                    NSGetSizeAndAlignment(encoding, &valueSize, NULL);
                    void *bytes = malloc(valueSize);
                    memset(bytes, 0, valueSize);
                    *zeroValue = [NSValue valueWithBytes:bytes objCType:encoding];
                    free(bytes);
                } break;
            }
        }
        free(encoding);
    }

    return isManagedProperty;
}

static void GRMustacheContextManagedPropertyCharSetter(GRMustacheContext *self, SEL _cmd, char value)
{
    [self setValue:[NSNumber numberWithChar:value] forKey:managedPropertyNameForSelector(object_getClass(self), _cmd)];
}

static void GRMustacheContextManagedPropertyIntSetter(GRMustacheContext *self, SEL _cmd, int value)
{
    [self setValue:[NSNumber numberWithInt:value] forKey:managedPropertyNameForSelector(object_getClass(self), _cmd)];
}

static void GRMustacheContextManagedPropertyShortSetter(GRMustacheContext *self, SEL _cmd, short value)
{
    [self setValue:[NSNumber numberWithShort:value] forKey:managedPropertyNameForSelector(object_getClass(self), _cmd)];
}

static void GRMustacheContextManagedPropertyLongSetter(GRMustacheContext *self, SEL _cmd, long value)
{
    [self setValue:[NSNumber numberWithLong:value] forKey:managedPropertyNameForSelector(object_getClass(self), _cmd)];
}

static void GRMustacheContextManagedPropertyLongLongSetter(GRMustacheContext *self, SEL _cmd, long long value)
{
    [self setValue:[NSNumber numberWithLongLong:value] forKey:managedPropertyNameForSelector(object_getClass(self), _cmd)];
}

static void GRMustacheContextManagedPropertyUnsignedCharSetter(GRMustacheContext *self, SEL _cmd, unsigned char value)
{
    [self setValue:[NSNumber numberWithUnsignedChar:value] forKey:managedPropertyNameForSelector(object_getClass(self), _cmd)];
}

static void GRMustacheContextManagedPropertyUnsignedIntSetter(GRMustacheContext *self, SEL _cmd, unsigned int value)
{
    [self setValue:[NSNumber numberWithUnsignedInt:value] forKey:managedPropertyNameForSelector(object_getClass(self), _cmd)];
}

static void GRMustacheContextManagedPropertyUnsignedShortSetter(GRMustacheContext *self, SEL _cmd, unsigned short value)
{
    [self setValue:[NSNumber numberWithUnsignedShort:value] forKey:managedPropertyNameForSelector(object_getClass(self), _cmd)];
}

static void GRMustacheContextManagedPropertyUnsignedLongSetter(GRMustacheContext *self, SEL _cmd, unsigned long value)
{
    [self setValue:[NSNumber numberWithUnsignedLong:value] forKey:managedPropertyNameForSelector(object_getClass(self), _cmd)];
}

static void GRMustacheContextManagedPropertyUnsignedLongLongSetter(GRMustacheContext *self, SEL _cmd, unsigned long long value)
{
    [self setValue:[NSNumber numberWithUnsignedLongLong:value] forKey:managedPropertyNameForSelector(object_getClass(self), _cmd)];
}

static void GRMustacheContextManagedPropertyFloatSetter(GRMustacheContext *self, SEL _cmd, float value)
{
    [self setValue:[NSNumber numberWithFloat:value] forKey:managedPropertyNameForSelector(object_getClass(self), _cmd)];
}

static void GRMustacheContextManagedPropertyDoubleSetter(GRMustacheContext *self, SEL _cmd, double value)
{
    [self setValue:[NSNumber numberWithDouble:value] forKey:managedPropertyNameForSelector(object_getClass(self), _cmd)];
}

static void GRMustacheContextManagedPropertyBoolSetter(GRMustacheContext *self, SEL _cmd, _Bool value)
{
    [self setValue:[NSNumber numberWithBool:value] forKey:managedPropertyNameForSelector(object_getClass(self), _cmd)];
}

static void GRMustacheContextManagedPropertyObjectSetter(GRMustacheContext *self, SEL _cmd, id value)
{
    [self setValue:value forKey:managedPropertyNameForSelector(object_getClass(self), _cmd)];
}

static void GRMustacheContextManagedPropertyClassSetter(GRMustacheContext *self, SEL _cmd, Class value)
{
    [self setValue:value forKey:managedPropertyNameForSelector(object_getClass(self), _cmd)];
}

static char GRMustacheContextManagedPropertyCharGetter(GRMustacheContext *self, SEL _cmd)
{
    return [[self valueForMustacheKey:managedPropertyNameForSelector(object_getClass(self), _cmd) protected:NULL] charValue];
}

static int GRMustacheContextManagedPropertyIntGetter(GRMustacheContext *self, SEL _cmd)
{
    return [[self valueForMustacheKey:managedPropertyNameForSelector(object_getClass(self), _cmd) protected:NULL] intValue];
}

static short GRMustacheContextManagedPropertyShortGetter(GRMustacheContext *self, SEL _cmd)
{
    return [[self valueForMustacheKey:managedPropertyNameForSelector(object_getClass(self), _cmd) protected:NULL] shortValue];
}

static long GRMustacheContextManagedPropertyLongGetter(GRMustacheContext *self, SEL _cmd)
{
    return [[self valueForMustacheKey:managedPropertyNameForSelector(object_getClass(self), _cmd) protected:NULL] longValue];
}

static long long GRMustacheContextManagedPropertyLongLongGetter(GRMustacheContext *self, SEL _cmd)
{
    return [[self valueForMustacheKey:managedPropertyNameForSelector(object_getClass(self), _cmd) protected:NULL] longLongValue];
}

static unsigned char GRMustacheContextManagedPropertyUnsignedCharGetter(GRMustacheContext *self, SEL _cmd)
{
    return [[self valueForMustacheKey:managedPropertyNameForSelector(object_getClass(self), _cmd) protected:NULL] unsignedCharValue];
}

static unsigned int GRMustacheContextManagedPropertyUnsignedIntGetter(GRMustacheContext *self, SEL _cmd)
{
    return [[self valueForMustacheKey:managedPropertyNameForSelector(object_getClass(self), _cmd) protected:NULL] unsignedIntValue];
}

static unsigned short GRMustacheContextManagedPropertyUnsignedShortGetter(GRMustacheContext *self, SEL _cmd)
{
    return [[self valueForMustacheKey:managedPropertyNameForSelector(object_getClass(self), _cmd) protected:NULL] unsignedShortValue];
}

static unsigned long GRMustacheContextManagedPropertyUnsignedLongGetter(GRMustacheContext *self, SEL _cmd)
{
    return [[self valueForMustacheKey:managedPropertyNameForSelector(object_getClass(self), _cmd) protected:NULL] unsignedLongValue];
}

static unsigned long long GRMustacheContextManagedPropertyUnsignedLongLongGetter(GRMustacheContext *self, SEL _cmd)
{
    return [[self valueForMustacheKey:managedPropertyNameForSelector(object_getClass(self), _cmd) protected:NULL] unsignedLongLongValue];
}

static float GRMustacheContextManagedPropertyFloatGetter(GRMustacheContext *self, SEL _cmd)
{
    return [[self valueForMustacheKey:managedPropertyNameForSelector(object_getClass(self), _cmd) protected:NULL] floatValue];
}

static double GRMustacheContextManagedPropertyDoubleGetter(GRMustacheContext *self, SEL _cmd)
{
    return [[self valueForMustacheKey:managedPropertyNameForSelector(object_getClass(self), _cmd) protected:NULL] doubleValue];
}

static _Bool GRMustacheContextManagedPropertyBoolGetter(GRMustacheContext *self, SEL _cmd)
{
    return [[self valueForMustacheKey:managedPropertyNameForSelector(object_getClass(self), _cmd) protected:NULL] boolValue];
}

static id GRMustacheContextManagedPropertyObjectGetter(GRMustacheContext *self, SEL _cmd)
{
    return [self valueForMustacheKey:managedPropertyNameForSelector(object_getClass(self), _cmd) protected:NULL];
}

static Class GRMustacheContextManagedPropertyClassGetter(GRMustacheContext *self, SEL _cmd)
{
    return [self valueForMustacheKey:managedPropertyNameForSelector(object_getClass(self), _cmd) protected:NULL];
}

+ (void)synthesizeManagedPropertiesAccessors
{
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
                // We store values in managedPropertiesStore, an NSDictionary that retain its values.
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
                    // We store values in managedPropertiesStore, an NSDictionary that retain its values.
                    // Don't lie: support for non-retained properties is not done yet.
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

+ (BOOL)instancesRespondToSelector:(SEL)selector
{
    // synthesizeManagedPropertiesAccessors could not synthesize accessors for
    // properties containing char*, struct, union, etc.
    //
    // We have to pretend that we have an actual implementation.
    
    if ([super instancesRespondToSelector:selector]) {
        return YES;
    }
    
    // Support for managed properties is reserved to GRMustacheContext subclasses
    if (self == [GRMustacheContext class]) {
        return NO;
    }
    
    const char *selectorName = sel_getName(selector);
    return hasManagedPropertyAccessor(self, selectorName, NO, NULL, NULL, NULL, NULL, NULL, NULL);
}

- (BOOL)respondsToSelector:(SEL)selector
{
    // synthesizeManagedPropertiesAccessors could not synthesize accessors for
    // properties containing char*, struct, union, etc.
    //
    // We have to pretend that we have an actual implementation.
    
    if ([super respondsToSelector:selector]) {
        return YES;
    }
    
    return [object_getClass(self) instancesRespondToSelector:selector];
}

+ (NSMethodSignature *)instanceMethodSignatureForSelector:(SEL)selector
{
    // synthesizeManagedPropertiesAccessors could not synthesize accessors for
    // properties containing char*, struct, union, etc.
    //
    // We have to pretend that we have an actual implementation.
    
    NSMethodSignature *signature = [super instanceMethodSignatureForSelector:selector];
    if (signature) {
        return signature;
    }
    
    // Support for managed properties is reserved to GRMustacheContext subclasses
    if (self == [GRMustacheContext class]) {
        return nil;
    }
    
    // The method is undefined.
    
    const char *selectorName = sel_getName(selector);
    char *propertyName;
    char *encoding;
    BOOL getter;
    if (hasManagedPropertyAccessor(self, selectorName, NO, &getter, NULL, NULL, &propertyName, &encoding, NULL)) {
        
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

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector
{
    // synthesizeManagedPropertiesAccessors could not synthesize accessors for
    // properties containing char*, struct, union, etc.
    //
    // We have to pretend that we have an actual implementation.
    
    NSMethodSignature *signature = [super methodSignatureForSelector:selector];
    if (signature) {
        return signature;
    }
    
    return [object_getClass(self) instanceMethodSignatureForSelector:selector];
}

- (void)forwardInvocation:(NSInvocation *)invocation
{
    // synthesizeManagedPropertiesAccessors could not synthesize accessors for
    // properties containing char*, struct, union, etc.
    //
    // We have to pretend that we have an actual implementation.
    
    Class klass = object_getClass(self);
    
    // Support for managed properties is reserved to GRMustacheContext subclasses
    if (klass == [GRMustacheContext class]) {
        [super forwardInvocation:invocation];
        return;
    }
    
    SEL selector = [invocation selector];

    const char *selectorName = sel_getName(selector);
    char *propertyName;
    char *encoding;
    BOOL getter;
    if (hasManagedPropertyAccessor(klass, selectorName, NO, &getter, NULL, NULL, &propertyName, &encoding, NULL)) {
        
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

@end
