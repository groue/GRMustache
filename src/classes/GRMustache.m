// The MIT License
// 
// Copyright (c) 2012 Gwendal Roué
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
#import "GRMustacheRuntime_private.h"
#import "GRMustacheVersion.h"
#import "GRMustacheRendering.h"
#import "GRMustacheTag.h"
#import "GRMustacheError.h"


static CFMutableDictionaryRef renderingImplementationForProtocol = nil;
static IMP defaultRenderingImplementation;


static NSString *GRMustacheRenderNil(id self, SEL _cmd, GRMustacheTag *tag, GRMustacheRuntime *runtime, GRMustacheTemplateRepository *templateRepository, BOOL *HTMLEscaped, NSError **error);
static NSString *GRMustacheRenderNSNull(NSNull *self, SEL _cmd, GRMustacheTag *tag, GRMustacheRuntime *runtime, GRMustacheTemplateRepository *templateRepository, BOOL *HTMLEscaped, NSError **error);
static NSString *GRMustacheRenderNSNumber(NSNumber *self, SEL _cmd, GRMustacheTag *tag, GRMustacheRuntime *runtime, GRMustacheTemplateRepository *templateRepository, BOOL *HTMLEscaped, NSError **error);
static NSString *GRMustacheRenderNSString(NSString *self, SEL _cmd, GRMustacheTag *tag, GRMustacheRuntime *runtime, GRMustacheTemplateRepository *templateRepository, BOOL *HTMLEscaped, NSError **error);
static NSString *GRMustacheRenderNSObject(NSObject *self, SEL _cmd, GRMustacheTag *tag, GRMustacheRuntime *runtime, GRMustacheTemplateRepository *templateRepository, BOOL *HTMLEscaped, NSError **error);
static NSString *GRMustacheRenderNSFastEnumeration(id<NSFastEnumeration> self, SEL _cmd, GRMustacheTag *tag, GRMustacheRuntime *runtime, GRMustacheTemplateRepository *templateRepository, BOOL *HTMLEscaped, NSError **error);


@interface GRMustacheRenderingNil : NSObject<GRMustacheRendering>
+ (void)setRenderingImplementation:(IMP)imp;
+ (id)instance;
@end


@interface GRMustacheRenderingWithBlock:NSObject<GRMustacheRendering> {
    NSString *(^_block)(GRMustacheTag *tag, GRMustacheRuntime *runtime, GRMustacheTemplateRepository *templateRepository, BOOL *HTMLEscaped, NSError **error);
}
- (id)initWithBlock:(NSString *(^)(GRMustacheTag *tag, GRMustacheRuntime *runtime, GRMustacheTemplateRepository *templateRepository, BOOL *HTMLEscaped, NSError **error))block;
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
@end


@implementation GRMustache

+ (void)preventNSUndefinedKeyExceptionAttack
{
    [GRMustacheRuntime preventNSUndefinedKeyExceptionAttack];
}

+ (GRMustacheVersion)version
{
    return (GRMustacheVersion){
        .major = GRMUSTACHE_MAJOR_VERSION,
        .minor = GRMUSTACHE_MINOR_VERSION,
        .patch = GRMUSTACHE_PATCH_VERSION };
}

+ (id<GRMustacheRendering>)renderingObjectForObject:(id)object
{
    if (object == nil) {
        return [GRMustacheRenderingNil instance];
    }
    
    SEL renderSelector = @selector(renderForTag:inRuntime:templateRepository:HTMLEscaped:error:);
    
    if ([object respondsToSelector:renderSelector]) {
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
                break;  // TODO: look for a more precise protocol
            }
        }
        
        free(protocols);
        free(imps);
    }
    
    if (!implementation) {
        implementation = defaultRenderingImplementation;
    }
    
    Class aClass = [object class];
    if (aClass != [NSObject class]) {
        [self registerClass:aClass renderingImplementation:implementation];
    }
    
    return [self renderingObjectWithObject:object implementation:implementation];
}

+ (id)renderingObjectWithBlock:(NSString *(^)(GRMustacheTag *tag, GRMustacheRuntime *runtime, GRMustacheTemplateRepository *templateRepository, BOOL *HTMLEscaped, NSError **error))block
{
    return [[[GRMustacheRenderingWithBlock alloc] initWithBlock:block] autorelease];
}

+ (id)renderingObjectWithObject:(id)object implementation:(IMP)implementation
{
    return [[[GRMustacheRenderingWithIMP alloc] initWithObject:object implementation:implementation] autorelease];
}

+ (NSString *)htmlEscape:(NSString *)string
{
    NSMutableString *result = [NSMutableString stringWithString:string];
    [result replaceOccurrencesOfString:@"&" withString:@"&amp;" options:NSLiteralSearch range:NSMakeRange(0, result.length)];
    [result replaceOccurrencesOfString:@"<" withString:@"&lt;" options:NSLiteralSearch range:NSMakeRange(0, result.length)];
    [result replaceOccurrencesOfString:@">" withString:@"&gt;" options:NSLiteralSearch range:NSMakeRange(0, result.length)];
    [result replaceOccurrencesOfString:@"\"" withString:@"&quot;" options:NSLiteralSearch range:NSMakeRange(0, result.length)];
    [result replaceOccurrencesOfString:@"'" withString:@"&apos;" options:NSLiteralSearch range:NSMakeRange(0, result.length)];
    return result;
}


#pragma mark Private

+ (void)load
{
    [self registerDefaultRenderingImplementation:(IMP)GRMustacheRenderNSObject];
    [self registerNilRenderingImplementation:(IMP)GRMustacheRenderNil];
    [self registerClass:[NSNull class] renderingImplementation:(IMP)GRMustacheRenderNSNull];
    [self registerClass:[NSNumber class] renderingImplementation:(IMP)GRMustacheRenderNSNumber];
    [self registerClass:[NSString class] renderingImplementation:(IMP)GRMustacheRenderNSString];
    [self registerClass:[NSDictionary class] renderingImplementation:(IMP)GRMustacheRenderNSObject];
    [self registerProtocol:@protocol(NSFastEnumeration) renderingImplementation:(IMP)GRMustacheRenderNSFastEnumeration];
}

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
    SEL renderSelector = @selector(renderForTag:inRuntime:templateRepository:HTMLEscaped:error:);
    if (!class_addMethod(aClass, renderSelector, imp, "@@:@@@^c^@")) {
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

- (NSString *)renderForTag:(GRMustacheTag *)tag inRuntime:(GRMustacheRuntime *)runtime templateRepository:(GRMustacheTemplateRepository *)templateRepository HTMLEscaped:(BOOL *)HTMLEscaped error:(NSError **)error
{
    return nilRenderingImplementation(nil, @selector(renderForTag:inRuntime:templateRepository:HTMLEscaped:error:), tag, runtime, templateRepository, HTMLEscaped);
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

- (id)initWithBlock:(NSString *(^)(GRMustacheTag *tag, GRMustacheRuntime *runtime, GRMustacheTemplateRepository *templateRepository, BOOL *HTMLEscaped, NSError **error))block
{
    self = [super init];
    if (self) {
        _block = [block copy];
    }
    return self;
}

- (NSString *)renderForTag:(GRMustacheTag *)tag inRuntime:(GRMustacheRuntime *)runtime templateRepository:(GRMustacheTemplateRepository *)templateRepository HTMLEscaped:(BOOL *)HTMLEscaped error:(NSError **)error
{
    if (!_block) {
        return nil;
    }
    return _block(tag, runtime, templateRepository, HTMLEscaped, error);
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

- (NSString *)renderForTag:(GRMustacheTag *)tag inRuntime:(GRMustacheRuntime *)runtime templateRepository:(GRMustacheTemplateRepository *)templateRepository HTMLEscaped:(BOOL *)HTMLEscaped error:(NSError **)error
{
    return _implementation(_object, @selector(renderForTag:inRuntime:templateRepository:HTMLEscaped:error:), tag, runtime, templateRepository, HTMLEscaped);
}

@end


// =============================================================================
#pragma mark - nil(GRMustacheRendering)

static NSString *GRMustacheRenderNil(id self, SEL _cmd, GRMustacheTag *tag, GRMustacheRuntime *runtime, GRMustacheTemplateRepository *templateRepository, BOOL *HTMLEscaped, NSError **error)
{
    switch (tag.type) {
        case GRMustacheTagTypeVariable:
        case GRMustacheTagTypeRegularSection:
            // {{ nil }}
            // {{# nil }}...{{/}}
            return nil;
            
        case GRMustacheTagTypeOverridableSection:
        case GRMustacheTagTypeInvertedSection:
            // {{^ nil }}...{{/}}
            // {{$ nil }}...{{/}}
            return [tag renderForTag:tag inRuntime:runtime templateRepository:templateRepository HTMLEscaped:HTMLEscaped error:error];
            
    }
}


// =============================================================================
#pragma mark - NSNull(GRMustacheRendering)

static NSString *GRMustacheRenderNSNull(NSNull *self, SEL _cmd, GRMustacheTag *tag, GRMustacheRuntime *runtime, GRMustacheTemplateRepository *templateRepository, BOOL *HTMLEscaped, NSError **error)
{
    switch (tag.type) {
        case GRMustacheTagTypeVariable:
        case GRMustacheTagTypeRegularSection:
        case GRMustacheTagTypeOverridableSection:
            // {{ null }}
            // {{# null }}...{{/}}
            // {{$ null }}...{{/}}
            return nil;
            
        case GRMustacheTagTypeInvertedSection:
            // {{^ null }}...{{/}}
            return [tag renderForTag:tag inRuntime:runtime templateRepository:templateRepository HTMLEscaped:HTMLEscaped error:error];
            
    }
}


// =============================================================================
#pragma mark - NSNumber(GRMustacheRendering)

static NSString *GRMustacheRenderNSNumber(NSNumber *self, SEL _cmd, GRMustacheTag *tag, GRMustacheRuntime *runtime, GRMustacheTemplateRepository *templateRepository, BOOL *HTMLEscaped, NSError **error)
{
    switch (tag.type) {
        case GRMustacheTagTypeVariable:
            // {{ number }}
            *HTMLEscaped = NO;
            return [self description];
            
        case GRMustacheTagTypeRegularSection:
        case GRMustacheTagTypeOverridableSection:
            // {{# number }}...{{/}}
            // {{$ number }}...{{/}}
            if ([self boolValue]) {
                runtime = [runtime runtimeByAddingContextObject:self];
                return [tag renderForTag:tag inRuntime:runtime templateRepository:templateRepository HTMLEscaped:HTMLEscaped error:error];
            } else {
                return nil;
            }
            
        case GRMustacheTagTypeInvertedSection:
            // {{^ number }}...{{/}}
            if ([self boolValue]) {
                return nil;
            } else {
                return [tag renderForTag:tag inRuntime:runtime templateRepository:templateRepository HTMLEscaped:HTMLEscaped error:error];
            }
    }
}


// =============================================================================
#pragma mark - NSString(GRMustacheRendering)

static NSString *GRMustacheRenderNSString(NSString *self, SEL _cmd, GRMustacheTag *tag, GRMustacheRuntime *runtime, GRMustacheTemplateRepository *templateRepository, BOOL *HTMLEscaped, NSError **error)
{
    switch (tag.type) {
        case GRMustacheTagTypeVariable:
            // {{ string }}
            *HTMLEscaped = NO;
            return self;
            
        case GRMustacheTagTypeRegularSection:
        case GRMustacheTagTypeOverridableSection:
            // {{# string }}...{{/}}
            // {{$ string }}...{{/}}
            if (self.length > 0) {
                runtime = [runtime runtimeByAddingContextObject:self];
                return [tag renderForTag:tag inRuntime:runtime templateRepository:templateRepository HTMLEscaped:HTMLEscaped error:error];
            } else {
                return nil;
            }
            
        case GRMustacheTagTypeInvertedSection:
            // {{^ string }}...{{/}}
            if (self.length > 0) {
                return nil;
            } else {
                return [tag renderForTag:tag inRuntime:runtime templateRepository:templateRepository HTMLEscaped:HTMLEscaped error:error];
            }
    }
}


// =============================================================================
#pragma mark - NSObject(GRMustacheRendering)

static NSString *GRMustacheRenderNSObject(NSObject *self, SEL _cmd, GRMustacheTag *tag, GRMustacheRuntime *runtime, GRMustacheTemplateRepository *templateRepository, BOOL *HTMLEscaped, NSError **error)
{
    switch (tag.type) {
        case GRMustacheTagTypeVariable:
            // {{ object }}
            *HTMLEscaped = NO;
            return [self description];
            
        case GRMustacheTagTypeRegularSection:
        case GRMustacheTagTypeOverridableSection:
            // {{# object }}...{{/}}
            // {{$ object }}...{{/}}
            runtime = [runtime runtimeByAddingContextObject:self];
            return [tag renderForTag:tag inRuntime:runtime templateRepository:templateRepository HTMLEscaped:HTMLEscaped error:error];
            
        case GRMustacheTagTypeInvertedSection:
            // {{^ object }}...{{/}}
            return nil;
    }
}


// =============================================================================
#pragma mark - NSFastEnumeration(GRMustacheRendering)

static NSString *GRMustacheRenderNSFastEnumeration(id<NSFastEnumeration> self, SEL _cmd, GRMustacheTag *tag, GRMustacheRuntime *runtime, GRMustacheTemplateRepository *templateRepository, BOOL *HTMLEscaped, NSError **error)
{
    switch (tag.type) {
        case GRMustacheTagTypeVariable: {
            // {{ list }}
            // Render the concatenation of the rendering of each item
            
            NSMutableString *buffer = [NSMutableString string];
            BOOL oneItemHasRenderedHTMLEscaped = NO;
            BOOL oneItemHasRenderedHTMLUnescaped = NO;
            
            for (id item in self) {
                // item enters the runtime as a context object
                GRMustacheRuntime *itemRuntime = [runtime runtimeByAddingContextObject:item];
                
                // render item
                id<GRMustacheRendering> itemRenderingObject = [GRMustache renderingObjectForObject:item];
                BOOL itemHasRenderedHTMLEscaped = NO;
                NSError *itemRenderingError = nil;
                NSString *rendering = [itemRenderingObject renderForTag:tag inRuntime:itemRuntime templateRepository:templateRepository HTMLEscaped:&itemHasRenderedHTMLEscaped error:&itemRenderingError];
                
                if (rendering)
                {
                    // check consistency of HTML escaping before appending the rendering to the buffer
                    
                    if (itemHasRenderedHTMLEscaped) {
                        oneItemHasRenderedHTMLEscaped = YES;
                        if (oneItemHasRenderedHTMLUnescaped) {
                            [NSException raise:GRMustacheRenderingException format:@"Inconsistant HTML escaping of items in enumeration"];
                        }
                    } else {
                        oneItemHasRenderedHTMLUnescaped = YES;
                        if (oneItemHasRenderedHTMLEscaped) {
                            [NSException raise:GRMustacheRenderingException format:@"Inconsistant HTML escaping of items in enumeration"];
                        }
                    }
                    
                    [buffer appendString:rendering];
                }
                else if (itemRenderingError)
                {
                    // If rendering is nil, but rendering error is not set,
                    // assume lazy coder, and the intention to render nothing:
                    // Fail if and only if renderingError is explicitely set.
                    if (error) {
                        *error = itemRenderingError;
                    }
                    return nil;
                }
            }
            
            *HTMLEscaped = oneItemHasRenderedHTMLEscaped;
            return buffer;
        }
            
        case GRMustacheTagTypeRegularSection:
        case GRMustacheTagTypeOverridableSection: {
            // {{# list }}...{{/}}
            // {{$ list }}...{{/}}
            // Non inverted sections render for each item in the list
            
            NSMutableString *buffer = [NSMutableString string];
            for (id item in self) {
                // item enters the runtime as a context object
                GRMustacheRuntime *itemRuntime = [runtime runtimeByAddingContextObject:item];
                
                NSString *rendering = [tag renderForTag:tag inRuntime:itemRuntime templateRepository:templateRepository HTMLEscaped:HTMLEscaped error:error];
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
                return [tag renderForTag:tag inRuntime:runtime templateRepository:templateRepository HTMLEscaped:HTMLEscaped error:error];
            } else {
                return nil;
            }
        }
    }
}
