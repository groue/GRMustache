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

#import "GRMustacheEnvironment.h"
#import "GRMustacheTemplate_private.h"
#import "GRMustacheContext_private.h"
#import "GRMustacheLambda_private.h"
#import "GRMustacheTemplateLoader_private.h"
#import "GRMustacheDirectoryTemplateLoader_private.h"
#import "GRBoolean_private.h"

@interface GRMustacheTemplate()
@property (nonatomic) GRMustacheTemplateOptions options;
- (id)initWithElements:(NSArray *)elems options:(GRMustacheTemplateOptions)options;
@end

@implementation GRMustacheTemplate
@synthesize elems=_elems;
@synthesize options=_options;

+ (id)parseString:(NSString *)templateString error:(NSError **)outError {
    return [GRMustacheTemplate templateFromString:templateString options:GRMustacheDefaultTemplateOptions error:outError];
}

+ (id)templateFromString:(NSString *)templateString error:(NSError **)outError {
    return [GRMustacheTemplate templateFromString:templateString options:GRMustacheDefaultTemplateOptions error:outError];
}

+ (id)parseString:(NSString *)templateString options:(GRMustacheTemplateOptions)options error:(NSError **)outError
{
    return [self templateFromString:templateString options:options error:outError];
}

+ (id)templateFromString:(NSString *)templateString options:(GRMustacheTemplateOptions)options error:(NSError **)outError
{
    GRMustacheTemplateLoader *loader = [GRMustacheTemplateLoader templateLoaderWithBundle:[NSBundle mainBundle] options:options];
    return [loader templateFromString:templateString error:outError];
}

#if !TARGET_OS_IPHONE || GRMUSTACHE_IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
+ (id)parseContentsOfURL:(NSURL *)URL error:(NSError **)outError {
    return [GRMustacheTemplate templateFromContentsOfURL:URL options:GRMustacheDefaultTemplateOptions error:outError];
}

+ (id)templateFromContentsOfURL:(NSURL *)URL error:(NSError **)outError {
    return [GRMustacheTemplate templateFromContentsOfURL:URL options:GRMustacheDefaultTemplateOptions error:outError];
}

+ (id)parseContentsOfURL:(NSURL *)URL options:(GRMustacheTemplateOptions)options error:(NSError **)outError {
    return [self templateFromContentsOfURL:URL options:options error:outError];
}

+ (id)templateFromContentsOfURL:(NSURL *)URL options:(GRMustacheTemplateOptions)options error:(NSError **)outError {
    id<GRMustacheURLTemplateLoader> loader = [GRMustacheTemplateLoader templateLoaderWithBaseURL:[URL URLByDeletingLastPathComponent] extension:[URL pathExtension] options:options];
    return [loader templateFromContentsOfURL:URL error:outError];
}
#endif

+ (id)parseContentsOfFile:(NSString *)path error:(NSError **)outError {
    return [GRMustacheTemplate templateFromContentsOfFile:path options:GRMustacheDefaultTemplateOptions error:outError];
}

+ (id)templateFromContentsOfFile:(NSString *)path error:(NSError **)outError {
    return [GRMustacheTemplate templateFromContentsOfFile:path options:GRMustacheDefaultTemplateOptions error:outError];
}

+ (id)parseContentsOfFile:(NSString *)path options:(GRMustacheTemplateOptions)options error:(NSError **)outError {
    return [self templateFromContentsOfFile:path options:options error:outError];
}

+ (id)templateFromContentsOfFile:(NSString *)path options:(GRMustacheTemplateOptions)options error:(NSError **)outError {
    id<GRMustachePathTemplateLoader> loader = [GRMustacheTemplateLoader templateLoaderWithDirectory:[path stringByDeletingLastPathComponent] extension:[path pathExtension] options:options];
    return [loader templateFromContentsOfFile:path error:outError];
}

+ (id)parseResource:(NSString *)name bundle:(NSBundle *)bundle error:(NSError **)outError {
    return [GRMustacheTemplate parseResource:name bundle:bundle options:GRMustacheDefaultTemplateOptions error:outError];
}

+ (id)templateFromResource:(NSString *)name bundle:(NSBundle *)bundle error:(NSError **)outError {
    return [GRMustacheTemplate templateFromResource:name bundle:bundle options:GRMustacheDefaultTemplateOptions error:outError];
}

+ (id)parseResource:(NSString *)name bundle:(NSBundle *)bundle options:(GRMustacheTemplateOptions)options error:(NSError **)outError {
    return [self templateFromResource:name bundle:bundle options:options error:outError];
}

+ (id)templateFromResource:(NSString *)name bundle:(NSBundle *)bundle options:(GRMustacheTemplateOptions)options error:(NSError **)outError {
    GRMustacheTemplateLoader *loader = [GRMustacheTemplateLoader templateLoaderWithBundle:bundle options:options];
    return [loader templateWithName:name error:outError];
}

+ (id)parseResource:(NSString *)name withExtension:(NSString *)ext bundle:(NSBundle *)bundle error:(NSError **)outError {
    return [GRMustacheTemplate parseResource:name withExtension:ext bundle:bundle options:GRMustacheDefaultTemplateOptions error:outError];
}

+ (id)templateFromResource:(NSString *)name withExtension:(NSString *)ext bundle:(NSBundle *)bundle error:(NSError **)outError {
    return [GRMustacheTemplate templateFromResource:name withExtension:ext bundle:bundle options:GRMustacheDefaultTemplateOptions error:outError];
}

+ (id)parseResource:(NSString *)name withExtension:(NSString *)ext bundle:(NSBundle *)bundle options:(GRMustacheTemplateOptions)options error:(NSError **)outError {
    return [self templateFromResource:name withExtension:ext bundle:bundle options:options error:outError];
}

+ (id)templateFromResource:(NSString *)name withExtension:(NSString *)ext bundle:(NSBundle *)bundle options:(GRMustacheTemplateOptions)options error:(NSError **)outError {
    GRMustacheTemplateLoader *loader = [GRMustacheTemplateLoader templateLoaderWithBundle:bundle extension:ext options:options];
    return [loader templateWithName:name error:outError];
}

+ (id)templateWithElements:(NSArray *)elems options:(GRMustacheTemplateOptions)options {
    return [[[self alloc] initWithElements:elems options:options] autorelease];
}

- (void)dealloc {
    [_elems release];
    [super dealloc];
}

+ (NSString *)renderObject:(id)object fromString:(NSString *)templateString error:(NSError **)outError {
    return [self renderObject:object fromString:templateString options:GRMustacheDefaultTemplateOptions error:outError];
}

+ (NSString *)renderObject:(id)object fromString:(NSString *)templateString options:(GRMustacheTemplateOptions)options error:(NSError **)outError {
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:templateString options:options error:outError];
    NSString *result = [[template renderObject:object] retain];
    if (!template && outError != NULL) [*outError retain];
    [pool drain];
    if (!template && outError != NULL) [*outError autorelease];
    return [result autorelease];
}

#if !TARGET_OS_IPHONE || GRMUSTACHE_IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
+ (NSString *)renderObject:(id)object fromContentsOfURL:(NSURL *)URL error:(NSError **)outError {
    return [self renderObject:object fromContentsOfURL:URL options:GRMustacheDefaultTemplateOptions error:outError];
}

+ (NSString *)renderObject:(id)object fromContentsOfURL:(NSURL *)URL options:(GRMustacheTemplateOptions)options error:(NSError **)outError {
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromContentsOfURL:URL options:options error:outError];
    NSString *result = [[template renderObject:object] retain];
    if (!template && outError != NULL) [*outError retain];
    [pool drain];
    if (!template && outError != NULL) [*outError autorelease];
    return [result autorelease];
}
#endif

+ (NSString *)renderObject:(id)object fromContentsOfFile:(NSString *)path error:(NSError **)outError {
    return [self renderObject:object fromContentsOfFile:path options:GRMustacheDefaultTemplateOptions error:outError];
}

+ (NSString *)renderObject:(id)object fromContentsOfFile:(NSString *)path options:(GRMustacheTemplateOptions)options error:(NSError **)outError {
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromContentsOfFile:path options:options error:outError];
    NSString *result = [[template renderObject:object] retain];
    if (!template && outError != NULL) [*outError retain];
    [pool drain];
    if (!template && outError != NULL) [*outError autorelease];
    return [result autorelease];
}

+ (NSString *)renderObject:(id)object fromResource:(NSString *)name bundle:(NSBundle *)bundle error:(NSError **)outError {
    return [self renderObject:object fromResource:name bundle:bundle options:GRMustacheDefaultTemplateOptions error:outError];
}

+ (NSString *)renderObject:(id)object fromResource:(NSString *)name bundle:(NSBundle *)bundle options:(GRMustacheTemplateOptions)options error:(NSError **)outError {
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromResource:name bundle:bundle options:options error:outError];
    NSString *result = [[template renderObject:object] retain];
    if (!template && outError != NULL) [*outError retain];
    [pool drain];
    if (!template && outError != NULL) [*outError autorelease];
    return [result autorelease];
}

+ (NSString *)renderObject:(id)object fromResource:(NSString *)name withExtension:(NSString *)ext bundle:(NSBundle *)bundle error:(NSError **)outError {
    return [self renderObject:object fromResource:name withExtension:ext bundle:bundle options:GRMustacheDefaultTemplateOptions error:outError];
}

+ (NSString *)renderObject:(id)object fromResource:(NSString *)name withExtension:(NSString *)ext bundle:(NSBundle *)bundle options:(GRMustacheTemplateOptions)options error:(NSError **)outError {
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromResource:name withExtension:ext bundle:bundle options:options error:outError];
    NSString *result = [[template renderObject:object] retain];
    if (!template && outError != NULL) [*outError retain];
    [pool drain];
    if (!template && outError != NULL) [*outError autorelease];
    return [result autorelease];
}

- (NSString *)render {
    return [self renderObject:nil];
}

- (NSString *)renderObject:(id)object {
    return [self renderContext:[GRMustacheContext contextWithObject:object]];
}

- (NSString *)renderObjects:(id)object, ... {
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    va_list objectList;
    va_start(objectList, object);
    GRMustacheContext *context = [GRMustacheContext contextWithObject:object andObjectList:objectList];
    va_end(objectList);
    NSString *result = [[self renderContext:context] retain];
    [pool drain];
    return [result autorelease];
}

+ (void)object:(id)object kind:(GRMustacheObjectKind *)outKind boolValue:(BOOL *)outBoolValue
{
    if (object == nil ||
        object == [NSNull null] ||
        object == [GRNo no] ||
        (void *)object == (void *)kCFBooleanFalse ||
        ([object isKindOfClass:[NSString class]] && ((NSString*)object).length == 0))
    {
        if (outKind != NULL) {
            *outKind = GRMustacheObjectKindFalseValue;
        }
        if (outBoolValue != NULL) {
            *outBoolValue = NO;
        }
    } else {
        if (outKind != NULL) {
            if ([object conformsToProtocol:@protocol(GRMustacheHelper)]) {
                *outKind = GRMustacheObjectKindLambda;
            } else if ([object isKindOfClass:[NSDictionary class]]) {
                *outKind = GRMustacheObjectKindTrueValue;
            } else if ([object conformsToProtocol:@protocol(NSFastEnumeration)]) {
                *outKind = GRMustacheObjectKindEnumerable;
            } else {
                *outKind = GRMustacheObjectKindTrueValue;
            }
        }
        if (outBoolValue != NULL) {
            *outBoolValue = YES;
        }
    }
}

#pragma mark - GRMustacheRenderingElement

- (NSString *)renderContext:(GRMustacheContext *)context {
    NSMutableString *result = [NSMutableString string];
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    for (id<GRMustacheRenderingElement> elem in _elems) {
        [result appendString:[elem renderContext:context]];
    }
    [pool drain];
    return result;
}


#pragma mark - Private

- (id)initWithElements:(NSArray *)elems options:(GRMustacheTemplateOptions)options {
    if ((self = [self init])) {
        self.elems = elems;
        self.options = options;
    }
    return self;
}

@end
