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
#import "GRMustacheJavascriptLibrary_private.h"
#import "GRMustacheHTMLLibrary_private.h"
#import "GRMustacheURLLibrary_private.h"
#import "GRMustacheLocalizer.h"
#import "GRMustacheVersion.h"
#import "GRMustacheRendering.h"
#import "GRMustacheError.h"


// =============================================================================
#pragma mark - Rendering declarations


// GRMustacheNilRendering renders for nil

@interface GRMustacheNilRendering : NSObject<GRMustacheRendering>
@end
static GRMustacheNilRendering *nilRenderingObject;


// GRMustacheNilRendering renders for objects of class NSObject

@interface GRMustacheNSObjectRendering:NSObject<GRMustacheRendering> {
@private
    id _object;
}
- (id)initWithObject:(id)object;
@end


// GRMustacheRenderingWithBlock renders with a block

@interface GRMustacheRenderingWithBlock:NSObject<GRMustacheRendering> {
@private
    NSString *(^_block)(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error);
}
- (id)initWithBlock:(NSString *(^)(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error))block;
@end


// NSNull, NSNumber, NSString, NSObject, NSFastEnumeration rendering

static NSString *GRMustacheRenderNSNull(NSNull *self, SEL _cmd, GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error);
static NSString *GRMustacheRenderNSNumber(NSNumber *self, SEL _cmd, GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error);
static NSString *GRMustacheRenderNSString(NSString *self, SEL _cmd, GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error);
static NSString *GRMustacheRenderNSObject(NSObject *self, SEL _cmd, GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error);
static NSString *GRMustacheRenderNSFastEnumeration(id<NSFastEnumeration> self, SEL _cmd, GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error);


// =============================================================================
#pragma mark - GRMustache

@interface GRMustache()

+ (void)setupRendering;

/**
 * Have the class _aClass_ conform to the GRMustacheRendering protocol by adding
 * the GRMustacheRendering protocol to the list of protocols _aClass_ conforms
 * to, and setting the implementation of
 * renderForMustacheTag:context:HTMLSafe:error: to _imp_.
 *
 * @param imp     an implementation
 * @param aClass  the class to modify
 */
+ (void)registerRenderingImplementation:(IMP)imp forClass:(Class)aClass;

@end


@implementation GRMustache

+ (void)load
{
    [self setupRendering];
}


#pragma mark - Rendering

+ (void)setupRendering
{
    // Once and for all
    nilRenderingObject = [[GRMustacheNilRendering alloc] init];
    
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
    // in the renderingObjectForObject: method.
    [self registerRenderingImplementation:(IMP)GRMustacheRenderNSNull   forClass:[NSNull class]];
    [self registerRenderingImplementation:(IMP)GRMustacheRenderNSNumber forClass:[NSNumber class]];
    [self registerRenderingImplementation:(IMP)GRMustacheRenderNSString forClass:[NSString class]];
    [self registerRenderingImplementation:(IMP)GRMustacheRenderNSObject forClass:[NSDictionary class]];
}

+ (id<GRMustacheRendering>)renderingObjectForObject:(id)object
{
    if (object == nil) {
        return nilRenderingObject;
    }
    
    if ([object respondsToSelector:@selector(renderForMustacheTag:context:HTMLSafe:error:)]) {
        return object;
    }
    
    // Object doesn't know how to render
    
    Class klass = object_getClass(object);
    if ([object conformsToProtocol:@protocol(NSFastEnumeration)])
    {
        // Make it able to render with GRMustacheRenderNSFastEnumeration
        [self registerRenderingImplementation:(IMP)GRMustacheRenderNSFastEnumeration forClass:klass];
        return object;
    }
    else if (klass != [NSObject class])
    {
        // Make it able to render with GRMustacheRenderNSObject
        [self registerRenderingImplementation:(IMP)GRMustacheRenderNSObject forClass:klass];
        return object;
    }
    else
    {
        // Object's class is NSObject.
        // Don't make NSObject able to render: don't provide unregistered
        // classes conforming to NSFastEnumeration with the generic
        // GRMustacheRenderNSObject implementation.
        return [[[GRMustacheNSObjectRendering alloc] initWithObject:object] autorelease];
    }
}

+ (id<GRMustacheRendering>)renderingObjectWithBlock:(NSString *(^)(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error))block
{
    return [[[GRMustacheRenderingWithBlock alloc] initWithBlock:block] autorelease];
}

+ (void)registerRenderingImplementation:(IMP)imp forClass:(Class)klass
{
    // Set the implementation of renderForMustacheTag:context:HTMLSafe:error:
    SEL renderSelector = @selector(renderForMustacheTag:context:HTMLSafe:error:);
    if (!class_addMethod(klass, renderSelector, imp, "@@:@@^c^@")) {
        Method method = class_getInstanceMethod(klass, renderSelector);
        method_setImplementation(method, imp);
    }
    
    // Add protocol conformance
    class_addProtocol(klass, @protocol(GRMustacheRendering));
}


#pragma mark - Global services

+ (void)preventNSUndefinedKeyExceptionAttack
{
    // NOOP since v6.7
}

+ (GRMustacheVersion)version
{
    return (GRMustacheVersion){
        .major = GRMUSTACHE_MAJOR_VERSION,
        .minor = GRMUSTACHE_MINOR_VERSION,
        .patch = GRMUSTACHE_PATCH_VERSION };
}

+ (NSObject *)standardLibrary
{
    static NSObject *standardLibrary = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        standardLibrary = [[NSDictionary dictionaryWithObjectsAndKeys:
                            // {{ capitalized(value) }}
                            [[[GRMustacheCapitalizedFilter alloc] init] autorelease], @"capitalized",
                            
                            // {{ lowercase(value) }}
                            [[[GRMustacheLowercaseFilter alloc] init] autorelease], @"lowercase",
                            
                            // {{ uppercase(value) }}
                            [[[GRMustacheUppercaseFilter alloc] init] autorelease], @"uppercase",
                            
                            // {{# isBlank(value) }}...{{/}}
                            [[[GRMustacheBlankFilter alloc] init] autorelease], @"isBlank",
                            
                            // {{# isEmpty(value) }}...{{/}}
                            [[[GRMustacheEmptyFilter alloc] init] autorelease], @"isEmpty",
                            
                            // {{ localize(value) }}
                            // {{^ localize }}...{{/}}
                            [[[GRMustacheLocalizer alloc] initWithBundle:nil tableName:nil] autorelease], @"localize",
                            
                            [NSDictionary dictionaryWithObjectsAndKeys:
                             
                             // {{ HTML.escape(value) }}
                             // {{# HTML.escape }}...{{/}}
                             [[[GRMustacheHTMLEscapeFilter alloc] init] autorelease], @"escape",
                             nil], @"HTML",
                            
                            [NSDictionary dictionaryWithObjectsAndKeys:
                             
                             // {{ javascript.escape(value) }}
                             // {{# javascript.escape }}...{{/}}
                             [[[GRMustacheJavascriptEscaper alloc] init] autorelease], @"escape",
                             nil], @"javascript",
                            
                            [NSDictionary dictionaryWithObjectsAndKeys:
                             
                             // {{ URL.escape(value) }}
                             // {{# URL.escape }}...{{/}}
                             [[[GRMustacheURLEscapeFilter alloc] init] autorelease], @"escape",
                             nil], @"URL",
                            nil] retain];
    });
    
    return standardLibrary;
}

+ (NSString *)escapeHTML:(NSString *)string
{
    NSUInteger length = [string length];
    if (length == 0) {
        return string;
    }
    
    static const NSString *escapeForCharacter[] = {
        ['&'] = @"&amp;",
        ['<'] = @"&lt;",
        ['>'] = @"&gt;",
        ['"'] = @"&quot;",
        ['\''] = @"&apos;",
    };
    static const int escapeForCharacterLength = sizeof(escapeForCharacter) / sizeof(NSString *);
    
    
    // Assume most strings don't need escaping, and help performances: avoid
    // creating a NSMutableData instance if escaping in uncessary.
    
    BOOL needsEscaping = NO;
    for (NSUInteger i=0; i<length; ++i) {
        unichar character = [string characterAtIndex:i];
        if (character < escapeForCharacterLength && escapeForCharacter[character]) {
            needsEscaping = YES;
            break;
        }
    }
    
    if (!needsEscaping) {
        return string;
    }
    
    
    // Escape
    
    const UniChar *characters = CFStringGetCharactersPtr((CFStringRef)string);
    if (!characters) {
        NSMutableData *data = [NSMutableData dataWithLength:length * sizeof(UniChar)];
        [string getCharacters:[data mutableBytes] range:(NSRange){ .location = 0, .length = length }];
        characters = [data bytes];
    }
    
    NSMutableString *buffer = [NSMutableString stringWithCapacity:length];
    const UniChar *unescapedStart = characters;
    CFIndex unescapedLength = 0;
    for (NSUInteger i=0; i<length; ++i, ++characters) {
        const NSString *escape = (*characters < escapeForCharacterLength) ? escapeForCharacter[*characters] : nil;
        if (escape) {
            CFStringAppendCharacters((CFMutableStringRef)buffer, unescapedStart, unescapedLength);
            CFStringAppend((CFMutableStringRef)buffer, (CFStringRef)escape);
            unescapedStart = characters+1;
            unescapedLength = 0;
        } else {
            ++unescapedLength;
        }
    }
    if (unescapedLength > 0) {
        CFStringAppendCharacters((CFMutableStringRef)buffer, unescapedStart, unescapedLength);
    }
    return buffer;
}

@end


// =============================================================================
#pragma mark - Rendering Implementations

@implementation GRMustacheNilRendering

- (NSString *)renderForMustacheTag:(GRMustacheTag *)tag context:(GRMustacheContext *)context HTMLSafe:(BOOL *)HTMLSafe error:(NSError **)error
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

@end


@implementation GRMustacheNSObjectRendering

- (void)dealloc
{
    [_object release];
    [super dealloc];
}

- (id)initWithObject:(id)object
{
    self = [super init];
    if (self) {
        _object = [object retain];
    }
    return self;
}

- (NSString *)renderForMustacheTag:(GRMustacheTag *)tag context:(GRMustacheContext *)context HTMLSafe:(BOOL *)HTMLSafe error:(NSError **)error
{
    return GRMustacheRenderNSObject(_object, _cmd, tag, context, HTMLSafe, error);
}

@end


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
        case GRMustacheTagTypeOverridableSection:
            // {{# number }}...{{/}}
            // {{$ number }}...{{/}}
            if ([self boolValue]) {
                // janl/mustache.js and defunkt/mustache don't push bools in the
                // context stack. Follow their path, and avoid the creation of a
                // useless context nobody cares about.
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
        case GRMustacheTagTypeOverridableSection:
            // {{# string }}...{{/}}
            // {{$ string }}...{{/}}
            if (self.length > 0) {
                context = [[context class] newContextWithParent:context addedObject:self];
                NSString *rendering = [tag renderContentWithContext:context HTMLSafe:HTMLSafe error:error];
                [context release];
                return rendering;
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
        case GRMustacheTagTypeOverridableSection: {
            // {{# object }}...{{/}}
            // {{$ object }}...{{/}}
            context = [[context class] newContextWithParent:context addedObject:self];
            NSString *rendering = [tag renderContentWithContext:context HTMLSafe:HTMLSafe error:error];
            [context release];
            return rendering;
        }
            
        case GRMustacheTagTypeInvertedSection:
            // {{^ object }}...{{/}}
            return @"";
    }
}


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
                @autoreleasepool {
                    // Render item
                    
                    id<GRMustacheRendering> itemRenderingObject = [GRMustache renderingObjectForObject:item];
                    BOOL itemHasRenderedHTMLSafe = NO;
                    NSError *renderingError = nil;
                    NSString *rendering = [itemRenderingObject renderForMustacheTag:tag context:context HTMLSafe:&itemHasRenderedHTMLSafe error:&renderingError];
                    
                    if (rendering == nil && renderingError == nil)
                    {
                        // Rendering is nil, but rendering error is not set.
                        //
                        // Assume a rendering object coded by a lazy programmer, whose
                        // intention is to render nothing.
                        
                        rendering = @"";
                    }
                    
                    if (rendering)
                    {
                        // Success
                        
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
                    else
                    {
                        // Error
                        
                        if (error != NULL) {
                            *error = [renderingError retain];   // retain error so that it survives the @autoreleasepool block
                        } else {
                            NSLog(@"GRMustache error: %@", renderingError.localizedDescription);
                        }
                        
                        return nil;
                    }
                }
            }
            
            if (HTMLSafe != NULL) {
                *HTMLSafe = !oneItemHasRenderedHTMLUnescaped;   // YES if list is empty
            }
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
                @autoreleasepool {
                    GRMustacheContext *itemContext = [[context class] newContextWithParent:context addedObject:item];
                    NSString *rendering = [tag renderContentWithContext:itemContext HTMLSafe:HTMLSafe error:error];
                    [itemContext release];
                    
                    if (!rendering) {
                        return nil;
                    }
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
