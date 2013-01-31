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

#import "GRMustache_private.h"
#import "GRMustacheContext_private.h"
#import "GRMustacheTag_private.h"
#import "GRMustacheStandardLibrary_private.h"
#import "GRMustacheLocalizeHelper.h"
#import "GRMustacheVersion.h"
#import "GRMustacheRendering.h"
#import "GRMustacheError.h"


static CFMutableDictionaryRef renderingImplementationForProtocol = nil;
static IMP defaultRenderingImplementation;


static NSString *GRMustacheRenderNil(id self, SEL _cmd, GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error);
static NSString *GRMustacheRenderNSNull(NSNull *self, SEL _cmd, GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error);
static NSString *GRMustacheRenderNSNumber(NSNumber *self, SEL _cmd, GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error);
static NSString *GRMustacheRenderNSString(NSString *self, SEL _cmd, GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error);
static NSString *GRMustacheRenderNSObject(NSObject *self, SEL _cmd, GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error);
static NSString *GRMustacheRenderNSFastEnumeration(id<NSFastEnumeration> self, SEL _cmd, GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error);


@interface GRMustacheRenderingNil : NSObject<GRMustacheRendering>
+ (void)setRenderingImplementation:(IMP)imp;
+ (id)instance;
@end


@interface GRMustacheRenderingWithBlock:NSObject<GRMustacheRendering> {
    NSString *(^_block)(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error);
}
- (id)initWithBlock:(NSString *(^)(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error))block;
@end


@interface GRMustacheRenderingWithIMP:NSObject<GRMustacheRendering> {
    id _object;
    IMP _implementation;
}
- (id)initWithObject:(id)object implementation:(IMP)implementation;
@end


@interface GRMustache()
+ (void)registerDefaultRenderingImplementation:(IMP)imp;
+ (void)registerNilRenderingImplementation:(IMP)imp;
+ (void)registerClass:(Class)aClass renderingImplementation:(IMP)imp;
+ (void)registerProtocol:(Protocol *)aProtocol renderingImplementation:(IMP)imp;
+ (id<GRMustacheRendering>)renderingObjectWithObject:(id)object implementation:(IMP)implementation;
@end


@implementation GRMustache

+ (void)load
{
    // At the beginning of the program, register Mustache rendering
    // implementations for common classes:
    
    [self registerClass:[NSNull class] renderingImplementation:(IMP)GRMustacheRenderNSNull];
    [self registerClass:[NSNumber class] renderingImplementation:(IMP)GRMustacheRenderNSNumber];
    [self registerClass:[NSString class] renderingImplementation:(IMP)GRMustacheRenderNSString];
    [self registerClass:[NSDictionary class] renderingImplementation:(IMP)GRMustacheRenderNSObject];
    [self registerProtocol:@protocol(NSFastEnumeration) renderingImplementation:(IMP)GRMustacheRenderNSFastEnumeration];
    [self registerNilRenderingImplementation:(IMP)GRMustacheRenderNil];
    [self registerDefaultRenderingImplementation:(IMP)GRMustacheRenderNSObject];
}

+ (void)preventNSUndefinedKeyExceptionAttack
{
    [GRMustacheContext preventNSUndefinedKeyExceptionAttack];
}

+ (GRMustacheVersion)version
{
    return (GRMustacheVersion){
        .major = GRMUSTACHE_MAJOR_VERSION,
        .minor = GRMUSTACHE_MINOR_VERSION,
        .patch = GRMUSTACHE_PATCH_VERSION };
}

+ (id)standardLibrary
{
    static id standardLibrary = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        standardLibrary = [[NSDictionary dictionaryWithObjectsAndKeys:
                            [[[GRMustacheCapitalizedFilter alloc] init] autorelease], @"capitalized",
                            [[[GRMustacheLowercaseFilter alloc] init] autorelease], @"lowercase",
                            [[[GRMustacheUppercaseFilter alloc] init] autorelease], @"uppercase",
                            [[[GRMustacheBlankFilter alloc] init] autorelease], @"isBlank",
                            [[[GRMustacheEmptyFilter alloc] init] autorelease], @"isEmpty",
                            [[[GRMustacheLocalizeHelper alloc] initWithBundle:nil tableName:nil] autorelease], @"localize",
                            nil] retain];
    });
    return standardLibrary;
}

+ (id<GRMustacheRendering>)renderingObjectForObject:(id)object
{
    if (object == nil) {
        return [GRMustacheRenderingNil instance];
    }
    
    if ([object respondsToSelector:@selector(renderForMustacheTag:context:HTMLSafe:error:)]) {
        return object;
    }

    // look by protocol
    
    IMP implementation = nil;
    if (renderingImplementationForProtocol) {
        
        CFIndex count = CFDictionaryGetCount(renderingImplementationForProtocol);
        const void **protocols = malloc(count * sizeof(void *));
        const void **imps = malloc(count * sizeof(void *));
        
        CFDictionaryGetKeysAndValues(renderingImplementationForProtocol, protocols, imps);
        for (CFIndex i=0; i<count; ++i) {
            Protocol *protocol = protocols[i];
            if ([object conformsToProtocol:protocol]) {
                implementation = (IMP)imps[i];
                break;
            }
        }
        
        free(protocols);
        free(imps);
    }
    
    if (!implementation) {
        implementation = defaultRenderingImplementation;
    }
    
    Class aClass = [object class];
    if (aClass == [NSObject class]) {
        return [self renderingObjectWithObject:object implementation:implementation];
    }
    
    [self registerClass:aClass renderingImplementation:implementation];
    return object;
}

+ (id)renderingObjectWithBlock:(NSString *(^)(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error))block
{
    return [[[GRMustacheRenderingWithBlock alloc] initWithBlock:block] autorelease];
}

+ (id)renderingObjectWithObject:(id)object implementation:(IMP)implementation
{
    return [[[GRMustacheRenderingWithIMP alloc] initWithObject:object implementation:implementation] autorelease];
}

+ (NSString *)escapeHTML:(NSString *)string
{
    NSUInteger length = [string length];
    if (!length) {
        return string;
    }
    
    const UniChar *characters = CFStringGetCharactersPtr((CFStringRef)string);
    if (!characters) {
        NSMutableData *data = [NSMutableData dataWithLength:length * sizeof(UniChar)];
        [string getCharacters:[data mutableBytes] range:(NSRange){ .location = 0, .length = length }];
        characters = [data bytes];
    }
    
    static const NSString *escapeForCharacter[] = {
        ['&'] = @"&amp;",
        ['<'] = @"&lt;",
        ['>'] = @"&gt;",
        ['"'] = @"&quot;",
        ['\''] = @"&apos;",
    };
    static const int escapeForCharacterLength = sizeof(escapeForCharacter) / sizeof(NSString *);
    
    NSMutableString *buffer = nil;
    const UniChar *unescapedStart = characters;
    CFIndex unescapedLength = 0;
    for (NSUInteger i=0; i<length; ++i, ++characters) {
        const NSString *escape = (*characters < escapeForCharacterLength) ? escapeForCharacter[*characters] : nil;
        if (escape) {
            if (!buffer) {
                buffer = [NSMutableString stringWithCapacity:length];
            }
            CFStringAppendCharacters((CFMutableStringRef)buffer, unescapedStart, unescapedLength);
            CFStringAppend((CFMutableStringRef)buffer, (CFStringRef)escape);
            unescapedStart = characters+1;
            unescapedLength = 0;
        } else {
            ++unescapedLength;
        }
    }
    if (!buffer) {
        return string;
    }
    if (unescapedLength > 0) {
        CFStringAppendCharacters((CFMutableStringRef)buffer, unescapedStart, unescapedLength);
    }
    return buffer;
}


#pragma mark Private

+ (void)registerDefaultRenderingImplementation:(IMP)imp
{
    defaultRenderingImplementation = imp;
}

+ (void)registerNilRenderingImplementation:(IMP)imp
{
    [GRMustacheRenderingNil setRenderingImplementation:imp];
}

+ (void)registerClass:(Class)aClass renderingImplementation:(IMP)imp
{
    SEL renderSelector = @selector(renderForMustacheTag:context:HTMLSafe:error:);
    if (!class_addMethod(aClass, renderSelector, imp, "@@:@@^c^@")) {
        Method method = class_getInstanceMethod(aClass, renderSelector);
        method_setImplementation(method, imp);
    }
}

+ (void)registerProtocol:(Protocol *)aProtocol renderingImplementation:(IMP)imp
{
    if (renderingImplementationForProtocol == nil) {
        renderingImplementationForProtocol = CFDictionaryCreateMutable(NULL, 0, NULL, NULL);
    }
    
    CFDictionaryAddValue(renderingImplementationForProtocol, aProtocol, imp);
}

@end


// =============================================================================
#pragma mark - GRMustacheRenderingNil

static IMP nilRenderingImplementation;

@implementation GRMustacheRenderingNil

+ (void)setRenderingImplementation:(IMP)imp
{
    nilRenderingImplementation = imp;
}

+ (id)instance
{
    static GRMustacheRenderingNil *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (NSString *)renderForMustacheTag:(GRMustacheTag *)tag context:(GRMustacheContext *)context HTMLSafe:(BOOL *)HTMLSafe error:(NSError **)error
{
    return nilRenderingImplementation(nil, @selector(renderForMustacheTag:context:HTMLSafe:error:), tag, context, HTMLSafe);
}

@end


// =============================================================================
#pragma mark - GRMustacheRenderingWithBlock

@implementation GRMustacheRenderingWithBlock

- (void)dealloc
{
    [_block release];
    [super dealloc];
}

- (id)initWithBlock:(NSString *(^)(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error))block
{
    self = [super init];
    if (self) {
        _block = [block copy];
    }
    return self;
}

- (NSString *)renderForMustacheTag:(GRMustacheTag *)tag context:(GRMustacheContext *)context HTMLSafe:(BOOL *)HTMLSafe error:(NSError **)error
{
    if (!_block) {
        return @"";
    }
    return _block(tag, context, HTMLSafe, error);
}

@end


// =============================================================================
#pragma mark - GRMustacheRenderingWithIMP

@implementation GRMustacheRenderingWithIMP

- (void)dealloc
{
    [_object release];
    [super dealloc];
}

- (id)initWithObject:(id)object implementation:(IMP)implementation
{
    self = [super init];
    if (self) {
        _object = [object retain];
        _implementation = implementation;
    }
    return self;
}

- (NSString *)renderForMustacheTag:(GRMustacheTag *)tag context:(GRMustacheContext *)context HTMLSafe:(BOOL *)HTMLSafe error:(NSError **)error
{
    return _implementation(_object, @selector(renderForMustacheTag:context:HTMLSafe:error:), tag, context, HTMLSafe);
}

@end


// =============================================================================
#pragma mark - nil(GRMustacheRendering)

static NSString *GRMustacheRenderNil(id self, SEL _cmd, GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error)
{
    switch (tag.type) {
        case GRMustacheTagTypeVariable:
        case GRMustacheTagTypeSection:
            // {{ nil }}
            // {{# nil }}...{{/}}
            return @"";
            
        case GRMustacheTagTypeOverridableSection:
        case GRMustacheTagTypeInvertedSection:
            // {{$ nil }}...{{/}}
            // {{^ nil }}...{{/}}
            return [tag renderContentWithContext:context HTMLSafe:HTMLSafe error:error];
            
    }
}


// =============================================================================
#pragma mark - NSNull(GRMustacheRendering)

static NSString *GRMustacheRenderNSNull(NSNull *self, SEL _cmd, GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error)
{
    switch (tag.type) {
        case GRMustacheTagTypeVariable:
        case GRMustacheTagTypeSection:
        case GRMustacheTagTypeOverridableSection:
            // {{ null }}
            // {{# null }}...{{/}}
            // {{$ null }}...{{/}}
            return @"";
            
        case GRMustacheTagTypeInvertedSection:
            // {{^ null }}...{{/}}
            return [tag renderContentWithContext:context HTMLSafe:HTMLSafe error:error];
            
    }
}


// =============================================================================
#pragma mark - NSNumber(GRMustacheRendering)

static NSString *GRMustacheRenderNSNumber(NSNumber *self, SEL _cmd, GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error)
{
    switch (tag.type) {
        case GRMustacheTagTypeVariable:
            // {{ number }}
            *HTMLSafe = NO;
            return [self description];
            
        case GRMustacheTagTypeSection:
        case GRMustacheTagTypeOverridableSection:
            // {{# number }}...{{/}}
            // {{$ number }}...{{/}}
            if ([self boolValue]) {
                context = [context contextByAddingObject:self];
                return [tag renderContentWithContext:context HTMLSafe:HTMLSafe error:error];
            } else {
                return @"";
            }
            
        case GRMustacheTagTypeInvertedSection:
            // {{^ number }}...{{/}}
            if ([self boolValue]) {
                return @"";
            } else {
                return [tag renderContentWithContext:context HTMLSafe:HTMLSafe error:error];
            }
    }
}


// =============================================================================
#pragma mark - NSString(GRMustacheRendering)

static NSString *GRMustacheRenderNSString(NSString *self, SEL _cmd, GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error)
{
    switch (tag.type) {
        case GRMustacheTagTypeVariable:
            // {{ string }}
            *HTMLSafe = NO;
            return self;
            
        case GRMustacheTagTypeSection:
        case GRMustacheTagTypeOverridableSection:
            // {{# string }}...{{/}}
            // {{$ string }}...{{/}}
            if (self.length > 0) {
                context = [context contextByAddingObject:self];
                return [tag renderContentWithContext:context HTMLSafe:HTMLSafe error:error];
            } else {
                return @"";
            }
            
        case GRMustacheTagTypeInvertedSection:
            // {{^ string }}...{{/}}
            if (self.length > 0) {
                return @"";
            } else {
                return [tag renderContentWithContext:context HTMLSafe:HTMLSafe error:error];
            }
    }
}


// =============================================================================
#pragma mark - NSObject(GRMustacheRendering)

static NSString *GRMustacheRenderNSObject(NSObject *self, SEL _cmd, GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error)
{
    switch (tag.type) {
        case GRMustacheTagTypeVariable:
            // {{ object }}
            *HTMLSafe = NO;
            return [self description];
            
        case GRMustacheTagTypeSection:
        case GRMustacheTagTypeOverridableSection:
            // {{# object }}...{{/}}
            // {{$ object }}...{{/}}
            context = [context contextByAddingObject:self];
            return [tag renderContentWithContext:context HTMLSafe:HTMLSafe error:error];
            
        case GRMustacheTagTypeInvertedSection:
            // {{^ object }}...{{/}}
            return @"";
    }
}


// =============================================================================
#pragma mark - NSFastEnumeration(GRMustacheRendering)

static NSString *GRMustacheRenderNSFastEnumeration(id<NSFastEnumeration> self, SEL _cmd, GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error)
{
    switch (tag.type) {
        case GRMustacheTagTypeVariable: {
            // {{ list }}
            // Render the concatenation of the rendering of each item
            
            NSMutableString *buffer = [NSMutableString string];
            BOOL oneItemHasRenderedHTMLSafe = NO;
            BOOL oneItemHasRenderedHTMLUnescaped = NO;
            
            for (id item in self) {
                
                // render item
                id<GRMustacheRendering> itemRenderingObject = [GRMustache renderingObjectForObject:item];
                BOOL itemHasRenderedHTMLSafe = NO;
                NSError *itemRenderingError = nil;
                NSString *rendering = [itemRenderingObject renderForMustacheTag:tag context:context HTMLSafe:&itemHasRenderedHTMLSafe error:&itemRenderingError];
                
                if (rendering)
                {
                    if (rendering.length > 0)
                    {
                        // check consistency of HTML escaping before appending the rendering to the buffer
                        
                        if (itemHasRenderedHTMLSafe) {
                            oneItemHasRenderedHTMLSafe = YES;
                            if (oneItemHasRenderedHTMLUnescaped) {
                                [NSException raise:GRMustacheRenderingException format:@"Inconsistant HTML escaping of items in enumeration"];
                            }
                        } else {
                            oneItemHasRenderedHTMLUnescaped = YES;
                            if (oneItemHasRenderedHTMLSafe) {
                                [NSException raise:GRMustacheRenderingException format:@"Inconsistant HTML escaping of items in enumeration"];
                            }
                        }
                        
                        [buffer appendString:rendering];
                    }
                }
                else if (itemRenderingError)
                {
                    // If rendering is nil, but rendering error is not set,
                    // assume lazy coder, and the intention to render nothing:
                    // Fail if and only if renderingError is explicitely set.
                    if (error != NULL) {
                        *error = itemRenderingError;
                    } else {
                        NSLog(@"GRMustache error: %@", itemRenderingError.localizedDescription);
                    }
                    return @"";
                }
            }
            
            *HTMLSafe = oneItemHasRenderedHTMLSafe;
            return buffer;
        }
            
        case GRMustacheTagTypeSection:
        case GRMustacheTagTypeOverridableSection: {
            // {{# list }}...{{/}}
            // {{$ list }}...{{/}}
            // Non inverted sections render for each item in the list
            
            NSMutableString *buffer = [NSMutableString string];
            for (id item in self) {
                // item enters the context as a context object
                GRMustacheContext *itemContext = [context contextByAddingObject:item];
                
                NSString *rendering = [tag renderContentWithContext:itemContext HTMLSafe:HTMLSafe error:error];
                if (rendering) {
                    [buffer appendString:rendering];
                }
            }
            return buffer;
        }
            
        case GRMustacheTagTypeInvertedSection: {
            // {{^ list }}...{{/}}
            // Inverted section render if and only if self is empty.
            
            BOOL empty = YES;
            for (id item in self) {
                empty = NO;
                break;
            }
            
            if (empty) {
                return [tag renderContentWithContext:context HTMLSafe:HTMLSafe error:error];
            } else {
                return @"";
            }
        }
    }
}
