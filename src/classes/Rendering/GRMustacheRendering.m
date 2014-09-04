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
#import <pthread.h>
#import "GRMustacheRendering_private.h"
#import "GRMustacheTag_private.h"
#import "GRMustacheConfiguration_private.h"
#import "GRMustacheContext_private.h"
#import "GRMustacheError.h"
#import "GRMustacheTemplateRepository_private.h"
#import "GRMustacheBuffer_private.h"


// =============================================================================
#pragma mark - Rendering declarations


// GRMustacheNilRendering renders for nil

@interface GRMustacheNilRendering : NSObject<GRMustacheRendering>
@end
static GRMustacheNilRendering *nilRendering;


// GRMustacheBlockRendering renders with a block

@interface GRMustacheBlockRendering : NSObject<GRMustacheRendering> {
@private
    NSString *(^_renderingBlock)(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error);
}
- (instancetype)initWithRenderingBlock:(NSString *(^)(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error))renderingBlock;
@end


// NSNull, NSNumber, NSString, NSObject, NSFastEnumeration rendering

typedef NSString *(*GRMustacheRenderIMP)(id self, SEL _cmd, GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error);
static NSString *GRMustacheRenderGeneric(id self, SEL _cmd, GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error);
static NSString *GRMustacheRenderNSNull(NSNull *self, SEL _cmd, GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error);
static NSString *GRMustacheRenderNSNumber(NSNumber *self, SEL _cmd, GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error);
static NSString *GRMustacheRenderNSString(NSString *self, SEL _cmd, GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error);
static NSString *GRMustacheRenderNSObject(NSObject *self, SEL _cmd, GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error);
static NSString *GRMustacheRenderNSFastEnumeration(id<NSFastEnumeration> self, SEL _cmd, GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error);

typedef BOOL (*GRMustacheBoolValueIMP)(id self, SEL _cmd);
static BOOL GRMustacheBoolValueGeneric(id self, SEL _cmd);
static BOOL GRMustacheBoolValueNSNull(NSNull *self, SEL _cmd);
static BOOL GRMustacheBoolValueNSNumber(NSNumber *self, SEL _cmd);
static BOOL GRMustacheBoolValueNSString(NSString *self, SEL _cmd);
static BOOL GRMustacheBoolValueNSObject(NSObject *self, SEL _cmd);
static BOOL GRMustacheBoolValueNSFastEnumeration(id<NSFastEnumeration> self, SEL _cmd);


// =============================================================================
#pragma mark - Current Template Repository

static pthread_key_t GRCurrentTemplateRepositoryStackKey;
void freeCurrentTemplateRepositoryStack(void *objects) {
    [(NSMutableArray *)objects release];
}
#define setupCurrentTemplateRepositoryStack() pthread_key_create(&GRCurrentTemplateRepositoryStackKey, freeCurrentTemplateRepositoryStack)
#define getCurrentThreadCurrentTemplateRepositoryStack() (NSMutableArray *)pthread_getspecific(GRCurrentTemplateRepositoryStackKey)
#define setCurrentThreadCurrentTemplateRepositoryStack(classes) pthread_setspecific(GRCurrentTemplateRepositoryStackKey, classes)


// =============================================================================
#pragma mark - Current Content Type

static pthread_key_t GRCurrentContentTypeStackKey;
void freeCurrentContentTypeStack(void *objects) {
    [(NSMutableArray *)objects release];
}
#define setupCurrentContentTypeStack() pthread_key_create(&GRCurrentContentTypeStackKey, freeCurrentContentTypeStack)
#define getCurrentThreadCurrentContentTypeStack() (NSMutableArray *)pthread_getspecific(GRCurrentContentTypeStackKey)
#define setCurrentThreadCurrentContentTypeStack(classes) pthread_setspecific(GRCurrentContentTypeStackKey, classes)


// =============================================================================
#pragma mark - GRMustacheRendering

@implementation GRMustacheRendering

+ (void)initialize
{
    setupCurrentTemplateRepositoryStack();
    setupCurrentContentTypeStack();
    
    nilRendering = [[GRMustacheNilRendering alloc] init];
    
    // We could have declared categories on NSNull, NSNumber, NSString and
    // NSDictionary.
    //
    // We do not, because many GRMustache users use the static library, and
    // we don't want to force them adding the `-ObjC` option to their
    // target's "Other Linker Flags" (which is required for code declared by
    // categories to be loaded).
    //
    // Instead, dynamically alter the classes whose rendering implementation
    // is already known.
    //
    // Other classes will be dynamically attached their rendering implementation
    // in the GRMustacheRenderGeneric implementation attached to NSObject.
    [self registerRenderIMP:GRMustacheRenderNSNull   boolValueIMP:GRMustacheBoolValueNSNull   forClass:[NSNull class]];
    [self registerRenderIMP:GRMustacheRenderNSNumber boolValueIMP:GRMustacheBoolValueNSNumber forClass:[NSNumber class]];
    [self registerRenderIMP:GRMustacheRenderNSString boolValueIMP:GRMustacheBoolValueNSString forClass:[NSString class]];
    [self registerRenderIMP:GRMustacheRenderNSObject boolValueIMP:GRMustacheBoolValueNSObject forClass:[NSDictionary class]];
    [self registerRenderIMP:GRMustacheRenderGeneric  boolValueIMP:GRMustacheBoolValueGeneric  forClass:[NSObject class]];
}

+ (id<GRMustacheRendering>)renderingObjectForObject:(id)object
{
    // All objects but nil know how to render (see setupRendering).
    return object ?: nilRendering;
}

+ (id<GRMustacheRendering>)renderingObjectWithBlock:(NSString *(^)(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error))renderingBlock
{
    return [[[GRMustacheBlockRendering alloc] initWithRenderingBlock:renderingBlock] autorelease];
}


#pragma mark - <GRMustacheRendering>

- (NSString *)renderForMustacheTag:(GRMustacheTag *)tag context:(GRMustacheContext *)context HTMLSafe:(BOOL *)HTMLSafe error:(NSError **)error
{
    return @"";
}


#pragma mark - Current Template Repository

+ (void)pushCurrentTemplateRepository:(GRMustacheTemplateRepository *)templateRepository
{
    NSMutableArray *stack = getCurrentThreadCurrentTemplateRepositoryStack();
    if (!stack) {
        stack = [[NSMutableArray alloc] init];
        setCurrentThreadCurrentTemplateRepositoryStack(stack);
    }
    [stack addObject:templateRepository];
}

+ (void)popCurrentTemplateRepository
{
    NSMutableArray *stack = getCurrentThreadCurrentTemplateRepositoryStack();
    NSAssert(stack, @"Missing currentTemplateRepositoryStack");
    NSAssert(stack.count > 0, @"Empty currentTemplateRepositoryStack");
    [stack removeLastObject];
}

+ (GRMustacheTemplateRepository *)currentTemplateRepository
{
    NSMutableArray *stack = getCurrentThreadCurrentTemplateRepositoryStack();
    return [stack lastObject];
}


#pragma mark - Current Content Type

+ (void)pushCurrentContentType:(GRMustacheContentType)contentType
{
    NSMutableArray *stack = getCurrentThreadCurrentContentTypeStack();
    if (!stack) {
        stack = [[NSMutableArray alloc] init];
        setCurrentThreadCurrentContentTypeStack(stack);
    }
    [stack addObject:[NSNumber numberWithUnsignedInteger:contentType]];
}

+ (void)popCurrentContentType
{
    NSMutableArray *stack = getCurrentThreadCurrentContentTypeStack();
    NSAssert(stack, @"Missing currentContentTypeStack");
    NSAssert(stack.count > 0, @"Empty currentContentTypeStack");
    [stack removeLastObject];
}

+ (GRMustacheContentType)currentContentType
{
    NSMutableArray *stack = getCurrentThreadCurrentContentTypeStack();
    if (stack.count > 0) {
        return [(NSNumber *)[stack lastObject] unsignedIntegerValue];
    }
    return ([self currentTemplateRepository].configuration ?: [GRMustacheConfiguration defaultConfiguration]).contentType;
}


#pragma mark - Private

/**
 * Have the class _aClass_ conform to the GRMustacheRendering protocol by adding
 * the GRMustacheRendering protocol to the list of protocols _aClass_ conforms
 * to, and setting the implementation of
 * renderForMustacheTag:context:HTMLSafe:error: to _imp_.
 *
 * @param imp     an implementation
 * @param aClass  the class to modify
 */
+ (void)registerRenderIMP:(GRMustacheRenderIMP)renderIMP boolValueIMP:(GRMustacheBoolValueIMP)boolValueIMP forClass:(Class)klass
{
    SEL renderSelector = @selector(renderForMustacheTag:context:HTMLSafe:error:);
    SEL boolValueSelector = @selector(mustacheBoolValue);
    Protocol *protocol = @protocol(GRMustacheRendering);
    
    // Add method implementations
    
    if (renderIMP) {
        struct objc_method_description methodDescription = protocol_getMethodDescription(protocol, renderSelector, YES, YES);
        class_addMethod(klass, renderSelector, (IMP)renderIMP, methodDescription.types);
    }
    
    if (boolValueIMP) {
        struct objc_method_description methodDescription = protocol_getMethodDescription(protocol, boolValueSelector, YES, YES);
        class_addMethod(klass, boolValueSelector, (IMP)boolValueIMP, methodDescription.types);
    }

    // Add protocol conformance
    class_addProtocol(klass, protocol);
}



@end


// =============================================================================
#pragma mark - Rendering Implementations

@implementation GRMustacheNilRendering

- (BOOL)mustacheBoolValue
{
    return NO;
}

- (NSString *)renderForMustacheTag:(GRMustacheTag *)tag context:(GRMustacheContext *)context HTMLSafe:(BOOL *)HTMLSafe error:(NSError **)error
{
    switch (tag.type) {
        case GRMustacheTagTypeVariable:
            // {{ nil }}
            return @"";
            
        case GRMustacheTagTypeSection:
            // {{# nil }}...{{/}}
            // {{^ nil }}...{{/}}
            return [tag renderContentWithContext:context HTMLSafe:HTMLSafe error:error];
    }
}

@end


@implementation GRMustacheBlockRendering

- (void)dealloc
{
    [_renderingBlock release];
    [super dealloc];
}

- (instancetype)initWithRenderingBlock:(NSString *(^)(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error))renderingBlock
{
    if (renderingBlock == nil) {
        [NSException raise:NSInvalidArgumentException format:@"Can't build a rendering object with a nil rendering block."];
    }
    
    self = [super init];
    if (self) {
        _renderingBlock = [renderingBlock copy];
    }
    return self;
}

- (BOOL)mustacheBoolValue
{
    return YES;
}

- (NSString *)renderForMustacheTag:(GRMustacheTag *)tag context:(GRMustacheContext *)context HTMLSafe:(BOOL *)HTMLSafe error:(NSError **)error
{
    return _renderingBlock(tag, context, HTMLSafe, error);
}

@end


static BOOL GRMustacheBoolValueGeneric(id self, SEL _cmd)
{
    // Self doesn't know (yet) its mustache boolean value
    
    Class klass = object_getClass(self);
    if ([self respondsToSelector:@selector(countByEnumeratingWithState:objects:count:)])
    {
        // Future invocations will use GRMustacheBoolValueNSFastEnumeration
        [GRMustacheRendering registerRenderIMP:GRMustacheRenderNSFastEnumeration boolValueIMP:GRMustacheBoolValueNSFastEnumeration forClass:klass];
        return GRMustacheBoolValueNSFastEnumeration(self, _cmd);
    }
    
    if (klass != [NSObject class])
    {
        // Future invocations will use GRMustacheRenderNSObject
        [GRMustacheRendering registerRenderIMP:GRMustacheRenderNSObject boolValueIMP:GRMustacheBoolValueNSObject forClass:klass];
    }
    
    return GRMustacheBoolValueNSObject(self, _cmd);
}

static NSString *GRMustacheRenderGeneric(id self, SEL _cmd, GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error)
{
    // Self doesn't know (yet) how to render
    
    Class klass = object_getClass(self);
    if ([self respondsToSelector:@selector(countByEnumeratingWithState:objects:count:)])
    {
        // Future invocations will use GRMustacheRenderNSFastEnumeration
        [GRMustacheRendering registerRenderIMP:GRMustacheRenderNSFastEnumeration boolValueIMP:GRMustacheBoolValueNSFastEnumeration forClass:klass];
        return GRMustacheRenderNSFastEnumeration(self, _cmd, tag, context, HTMLSafe, error);
    }
    
    if (klass != [NSObject class])
    {
        // Future invocations will use GRMustacheRenderNSObject
        [GRMustacheRendering registerRenderIMP:GRMustacheRenderNSObject boolValueIMP:GRMustacheBoolValueNSObject forClass:klass];
    }
    
    return GRMustacheRenderNSObject(self, _cmd, tag, context, HTMLSafe, error);
}

static BOOL GRMustacheBoolValueNSNull(NSNull *self, SEL _cmd)
{
    return NO;
}

static NSString *GRMustacheRenderNSNull(NSNull *self, SEL _cmd, GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error)
{
    switch (tag.type) {
        case GRMustacheTagTypeVariable:
            // {{ null }}
            return @"";
            
        case GRMustacheTagTypeSection:
            // {{# null }}...{{/}}
            // {{^ null }}...{{/}}
            context = [context newContextByAddingObject:self];
            NSString *rendering = [tag renderContentWithContext:context HTMLSafe:HTMLSafe error:error];
            [context release];
            return rendering;
    }
}

static BOOL GRMustacheBoolValueNSNumber(NSNumber *self, SEL _cmd)
{
    return [self boolValue];
}

static NSString *GRMustacheRenderNSNumber(NSNumber *self, SEL _cmd, GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error)
{
    switch (tag.type) {
        case GRMustacheTagTypeVariable:
            // {{ number }}
            if (HTMLSafe != NULL) {
                *HTMLSafe = NO;
            }
            return [self description];
            
        case GRMustacheTagTypeSection:
            // {{# number }}...{{/}}
            // {{^ number }}...{{/}}
            context = [context newContextByAddingObject:self];
            NSString *rendering = [tag renderContentWithContext:context HTMLSafe:HTMLSafe error:error];
            [context release];
            return rendering;
    }
}

static BOOL GRMustacheBoolValueNSString(NSString *self, SEL _cmd)
{
    return (self.length > 0);
}

static NSString *GRMustacheRenderNSString(NSString *self, SEL _cmd, GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error)
{
    switch (tag.type) {
        case GRMustacheTagTypeVariable:
            // {{ string }}
            if (HTMLSafe != NULL) {
                *HTMLSafe = NO;
            }
            return self;
            
        case GRMustacheTagTypeSection:
            // {{# string }}...{{/}}
            // {{^ string }}...{{/}}
            context = [context newContextByAddingObject:self];
            NSString *rendering = [tag renderContentWithContext:context HTMLSafe:HTMLSafe error:error];
            [context release];
            return rendering;
    }
}

static BOOL GRMustacheBoolValueNSObject(NSObject *self, SEL _cmd)
{
    return YES;
}

static NSString *GRMustacheRenderNSObject(NSObject *self, SEL _cmd, GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error)
{
    switch (tag.type) {
        case GRMustacheTagTypeVariable:
            // {{ object }}
            if (HTMLSafe != NULL) {
                *HTMLSafe = NO;
            }
            return [self description];
            
        case GRMustacheTagTypeSection:
            // {{# object }}...{{/}}
            // {{^ object }}...{{/}}
            context = [context newContextByAddingObject:self];
            NSString *rendering = [tag renderContentWithContext:context HTMLSafe:HTMLSafe error:error];
            [context release];
            return rendering;
    }
}

static BOOL GRMustacheBoolValueNSFastEnumeration(id<NSFastEnumeration> self, SEL _cmd)
{
    for (id _ __attribute__((unused)) in self) {
        return YES;
    }
    return NO;
}

static NSString *GRMustacheRenderNSFastEnumeration(id<NSFastEnumeration> self, SEL _cmd, GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error)
{
    // {{ list }}
    // {{# list }}...{{/}}
    // {{^ list }}...{{/}}
    
    BOOL success = YES;
    BOOL bufferCreated = NO;
    GRMustacheBuffer buffer;
    BOOL anyItemHTMLSafe = NO;
    BOOL anyItemHTMLUnsafe = NO;
    
    for (id item in self) {
        if (!bufferCreated) {
            buffer = GRMustacheBufferCreate(1024);
            bufferCreated = YES;
        }
        @autoreleasepool {
            // Render item
            //
            // 1. If item is a collection, render the tag with item as the new
            //    top-level context object.
            //
            // 2. Otherwize, let the rendering object for item render the tag as
            //    it wants.
            //
            // Why is that?
            //
            // If we would only let the rendering object for item render the tag
            // as it wants, the "List made of lists should render each of them
            // independently." test would fail.
            //
            // This is because rendering all object in the same way, including
            // collections, leads to collection flattening.
            //
            // If we would always render the tag with item as the new top-level
            // context object, then the rendering objects returned by `each` and
            // `zip` filters could not apply. Those filters should then return a
            // unique rendering object instead of a collection of rendering
            // objects, and the "`each` and `zip` filters can chain." test would
            // fail.
            //
            // However, the "`each` filter should not alter the rendering of a
            // list made of lists." test fails. :-(
            
            BOOL itemHTMLSafe = NO; // always assume unsafe rendering
            NSError *renderingError = nil;
            NSString *rendering = nil;
            if ([item respondsToSelector:@selector(countByEnumeratingWithState:objects:count:)] && ![item isKindOfClass:[NSDictionary class]]) {
                rendering = [tag renderContentWithContext:[context contextByAddingObject:item] HTMLSafe:&itemHTMLSafe error:&renderingError];
            } else {
                rendering = [[GRMustacheRendering renderingObjectForObject:item] renderForMustacheTag:tag context:context HTMLSafe:&itemHTMLSafe error:&renderingError];
            }
            
            if (!rendering) {
                if (!renderingError) {
                    // Rendering is nil, but rendering error is not set.
                    //
                    // Assume a rendering object coded by a lazy programmer,
                    // whose intention is to render nothing.
                    
                    rendering = @"";
                } else {
                    if (error != NULL) {
                        // make sure error is not released by autoreleasepool
                        *error = renderingError;
                        [*error retain];
                    }
                    success = NO;
                    break;
                }
            }
            
            // check consistency of HTML escaping
            
            if (itemHTMLSafe) {
                anyItemHTMLSafe = YES;
                if (anyItemHTMLUnsafe) {
                    [NSException raise:GRMustacheRenderingException format:@"Inconsistant HTML escaping of items in enumeration"];
                }
            } else {
                anyItemHTMLUnsafe = YES;
                if (anyItemHTMLSafe) {
                    [NSException raise:GRMustacheRenderingException format:@"Inconsistant HTML escaping of items in enumeration"];
                }
            }
            
            // appending the rendering to the buffer
            
            GRMustacheBufferAppendString(&buffer, rendering);
        }
    }
    
    if (!success) {
        if (error != NULL) [*error autorelease];
        GRMustacheBufferRelease(&buffer);
        return nil;
    }
    
    if (bufferCreated) {
        // Non-empty list
        
        if (HTMLSafe != NULL) {
            *HTMLSafe = !anyItemHTMLUnsafe;
        }
        return GRMustacheBufferGetStringAndRelease(&buffer);
    } else {
        // Empty list
        
        switch (tag.type) {
            case GRMustacheTagTypeVariable:
                // {{ emptyList }}
                return @"";
                
            case GRMustacheTagTypeSection:
                // {{^ emptyList }}...{{/}}
                return [tag renderContentWithContext:context HTMLSafe:HTMLSafe error:error];
        }
    }
}
