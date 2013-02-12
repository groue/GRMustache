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
#pragma mark - Private declarations

static id<GRMustacheRendering> nilRenderingObject;
static NSObject *standardLibrary = nil;

static NSString *GRMustacheRenderNil(id self, SEL _cmd, GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error);
static NSString *GRMustacheRenderNSNull(NSNull *self, SEL _cmd, GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error);
static NSString *GRMustacheRenderNSNumber(NSNumber *self, SEL _cmd, GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error);
static NSString *GRMustacheRenderNSString(NSString *self, SEL _cmd, GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error);
static NSString *GRMustacheRenderNSObject(NSObject *self, SEL _cmd, GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error);
static NSString *GRMustacheRenderNSFastEnumeration(id<NSFastEnumeration> self, SEL _cmd, GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error);


// =============================================================================
#pragma mark - Private class GRMustacheRenderingWithBlock

@interface GRMustacheRenderingWithBlock:NSObject<GRMustacheRendering> {
@private
    NSString *(^_block)(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error);
}
- (id)initWithBlock:(NSString *(^)(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error))block;
@end


// =============================================================================
#pragma mark - Private class GRMustacheRenderingWithIMP

@interface GRMustacheRenderingWithIMP:NSObject<GRMustacheRendering> {
@private
    id _object;
    IMP _imp;
}
- (id)initWithObject:(id)object implementation:(IMP)imp;
@end


// =============================================================================
#pragma mark - GRMustache

@interface GRMustache()

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
    // Prepare renderingObjectForObject:
    
    nilRenderingObject = [[GRMustacheRenderingWithIMP alloc] initWithObject:nil implementation:(IMP)GRMustacheRenderNil];
    
    [self registerRenderingImplementation:(IMP)GRMustacheRenderNSNull   forClass:[NSNull class]];
    [self registerRenderingImplementation:(IMP)GRMustacheRenderNSNumber forClass:[NSNumber class]];
    [self registerRenderingImplementation:(IMP)GRMustacheRenderNSString forClass:[NSString class]];
    [self registerRenderingImplementation:(IMP)GRMustacheRenderNSObject forClass:[NSDictionary class]];
    
    // Prepare standard library
    
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

+ (NSObject *)standardLibrary
{
    return standardLibrary;
}

+ (id<GRMustacheRendering>)renderingObjectForObject:(id)object
{
    // Easy case: nil
    
    if (object == nil) {
        return nilRenderingObject;
    }
    
    // Easy case: Rendering object
    
    if ([object respondsToSelector:@selector(renderForMustacheTag:context:HTMLSafe:error:)]) {
        return object;
    }
    
    // Now let's look for an IMP...
    
    IMP imp = nil;
    
    if ([object conformsToProtocol:@protocol(NSFastEnumeration)]) {
        imp = (IMP)GRMustacheRenderNSFastEnumeration;
    } else {
        imp = (IMP)GRMustacheRenderNSObject;
    }
    
    // ...and let's register the IMP by extending the class of object, unless
    // it's NSObject, in order to allow unregistered classes that conform to
    // the NSFastEnumeration protocol to be registereed with
    // GRMustacheRenderNSFastEnumeration later.
    
    Class aClass = [object class];
    if (aClass == [NSObject class]) {
        return [[[GRMustacheRenderingWithIMP alloc] initWithObject:object implementation:imp] autorelease];
    } else {
        [self registerRenderingImplementation:imp forClass:aClass];
        return object;
    }
}

+ (id<GRMustacheRendering>)renderingObjectWithBlock:(NSString *(^)(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error))block
{
    return [[[GRMustacheRenderingWithBlock alloc] initWithBlock:block] autorelease];
}

+ (NSString *)escapeHTML:(NSString *)string
{
    NSUInteger length = [string length];
    if (length == 0) {
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

+ (void)registerRenderingImplementation:(IMP)imp forClass:(Class)aClass
{
    // Set the implementation of renderForMustacheTag:context:HTMLSafe:error:
    SEL renderSelector = @selector(renderForMustacheTag:context:HTMLSafe:error:);
    if (!class_addMethod(aClass, renderSelector, imp, "@@:@@^c^@")) {
        Method method = class_getInstanceMethod(aClass, renderSelector);
        method_setImplementation(method, imp);
    }
    
    // Add protocol conformance
    class_addProtocol(aClass, @protocol(GRMustacheRendering));
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

- (id)initWithObject:(id)object implementation:(IMP)imp
{
    self = [super init];
    if (self) {
        _object = [object retain];
        _imp = imp;
    }
    return self;
}

- (NSString *)renderForMustacheTag:(GRMustacheTag *)tag context:(GRMustacheContext *)context HTMLSafe:(BOOL *)HTMLSafe error:(NSError **)error
{
    return _imp(_object, @selector(renderForMustacheTag:context:HTMLSafe:error:), tag, context, HTMLSafe);
}

@end


// =============================================================================
#pragma mark - Rendering implementations

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
