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
#import "GRMustacheHelper_private.h"
#import "GRMustacheTemplateRepository_private.h"

@interface GRMustacheTemplate()
@property (nonatomic) GRMustacheTemplateOptions options;
- (id)initWithElements:(NSArray *)elems options:(GRMustacheTemplateOptions)options;
@end

@implementation GRMustacheTemplate
@synthesize elems=_elems;
@synthesize options=_options;
@synthesize delegate=_delegate;

+ (id)templateFromString:(NSString *)templateString error:(NSError **)outError
{
    return [GRMustacheTemplate templateFromString:templateString options:GRMustacheDefaultTemplateOptions error:outError];
}

+ (id)templateFromString:(NSString *)templateString options:(GRMustacheTemplateOptions)options error:(NSError **)outError
{
    GRMustacheTemplateRepository *templateRepository = [GRMustacheTemplateRepository templateRepositoryWithBundle:[NSBundle mainBundle] options:options];
    return [templateRepository templateFromString:templateString error:outError];
}

#if !TARGET_OS_IPHONE || GRMUSTACHE_IPHONE_OS_VERSION_MAX_ALLOWED >= 40000

+ (id)templateFromContentsOfURL:(NSURL *)URL error:(NSError **)outError
{
    return [GRMustacheTemplate templateFromContentsOfURL:URL options:GRMustacheDefaultTemplateOptions error:outError];
}

+ (id)templateFromContentsOfURL:(NSURL *)URL options:(GRMustacheTemplateOptions)options error:(NSError **)outError
{
    NSURL *baseURL = [URL URLByDeletingLastPathComponent];
    NSString *templateExtension = [URL pathExtension];
    NSString *templateName = [[URL lastPathComponent] stringByDeletingPathExtension];
    GRMustacheTemplateRepository *templateRepository = [GRMustacheTemplateRepository templateRepositoryWithBaseURL:baseURL templateExtension:templateExtension options:options];
    return [templateRepository templateForName:templateName error:outError];
}

#endif /* if !TARGET_OS_IPHONE || GRMUSTACHE_IPHONE_OS_VERSION_MAX_ALLOWED >= 40000 */

+ (id)templateFromContentsOfFile:(NSString *)path error:(NSError **)outError
{
    return [GRMustacheTemplate templateFromContentsOfFile:path options:GRMustacheDefaultTemplateOptions error:outError];
}

+ (id)templateFromContentsOfFile:(NSString *)path options:(GRMustacheTemplateOptions)options error:(NSError **)outError
{
    NSString *directoryPath = [path stringByDeletingLastPathComponent];
    NSString *templateExtension = [path pathExtension];
    NSString *templateName = [[path lastPathComponent] stringByDeletingPathExtension];
    GRMustacheTemplateRepository *templateRepository = [GRMustacheTemplateRepository templateRepositoryWithDirectory:directoryPath templateExtension:templateExtension options:options];
    return [templateRepository templateForName:templateName error:outError];
}

+ (id)templateFromResource:(NSString *)name bundle:(NSBundle *)bundle error:(NSError **)outError
{
    return [GRMustacheTemplate templateFromResource:name bundle:bundle options:GRMustacheDefaultTemplateOptions error:outError];
}

+ (id)templateFromResource:(NSString *)name bundle:(NSBundle *)bundle options:(GRMustacheTemplateOptions)options error:(NSError **)outError
{
    GRMustacheTemplateRepository *templateRepository = [GRMustacheTemplateRepository templateRepositoryWithBundle:bundle options:options];
    return [templateRepository templateForName:name error:outError];
}

+ (id)templateFromResource:(NSString *)name withExtension:(NSString *)ext bundle:(NSBundle *)bundle error:(NSError **)outError
{
    return [GRMustacheTemplate templateFromResource:name withExtension:ext bundle:bundle options:GRMustacheDefaultTemplateOptions error:outError];
}

+ (id)templateFromResource:(NSString *)name withExtension:(NSString *)ext bundle:(NSBundle *)bundle options:(GRMustacheTemplateOptions)options error:(NSError **)outError
{
    GRMustacheTemplateRepository *templateRepository = [GRMustacheTemplateRepository templateRepositoryWithBundle:bundle templateExtension:ext options:options];
    return [templateRepository templateForName:name error:outError];
}

+ (id)templateWithElements:(NSArray *)elems options:(GRMustacheTemplateOptions)options
{
    return [[[self alloc] initWithElements:elems options:options] autorelease];
}

- (void)dealloc
{
    [_elems release];
    [super dealloc];
}

+ (NSString *)renderObject:(id)object fromString:(NSString *)templateString error:(NSError **)outError
{
    return [self renderObject:object fromString:templateString options:GRMustacheDefaultTemplateOptions error:outError];
}

+ (NSString *)renderObject:(id)object fromString:(NSString *)templateString options:(GRMustacheTemplateOptions)options error:(NSError **)outError
{
    NSString *result;
    GRMustacheTemplate *template;
    @autoreleasepool {
        template = [GRMustacheTemplate templateFromString:templateString options:options error:outError];
        result = [[template renderObject:object] retain];
        // make sure outError is not released by autoreleasepool
        if (!template && outError != NULL) [*outError retain];
    }
    if (!template && outError != NULL) [*outError autorelease];
    return [result autorelease];
}

#if !TARGET_OS_IPHONE || GRMUSTACHE_IPHONE_OS_VERSION_MAX_ALLOWED >= 40000

+ (NSString *)renderObject:(id)object fromContentsOfURL:(NSURL *)URL error:(NSError **)outError
{
    return [self renderObject:object fromContentsOfURL:URL options:GRMustacheDefaultTemplateOptions error:outError];
}

+ (NSString *)renderObject:(id)object fromContentsOfURL:(NSURL *)URL options:(GRMustacheTemplateOptions)options error:(NSError **)outError
{
    NSString *result;
    GRMustacheTemplate *template;
    @autoreleasepool {
        template = [GRMustacheTemplate templateFromContentsOfURL:URL options:options error:outError];
        result = [[template renderObject:object] retain];
        // make sure outError is not released by autoreleasepool
        if (!template && outError != NULL) [*outError retain];
    }
    if (!template && outError != NULL) [*outError autorelease];
    return [result autorelease];
}

#endif /* if !TARGET_OS_IPHONE || GRMUSTACHE_IPHONE_OS_VERSION_MAX_ALLOWED >= 40000 */

+ (NSString *)renderObject:(id)object fromContentsOfFile:(NSString *)path error:(NSError **)outError
{
    return [self renderObject:object fromContentsOfFile:path options:GRMustacheDefaultTemplateOptions error:outError];
}

+ (NSString *)renderObject:(id)object fromContentsOfFile:(NSString *)path options:(GRMustacheTemplateOptions)options error:(NSError **)outError
{
    NSString *result;
    GRMustacheTemplate *template;
    @autoreleasepool {
        template = [GRMustacheTemplate templateFromContentsOfFile:path options:options error:outError];
        result = [[template renderObject:object] retain];
        // make sure outError is not released by autoreleasepool
        if (!template && outError != NULL) [*outError retain];
    }
    if (!template && outError != NULL) [*outError autorelease];
    return [result autorelease];
}

+ (NSString *)renderObject:(id)object fromResource:(NSString *)name bundle:(NSBundle *)bundle error:(NSError **)outError
{
    return [self renderObject:object fromResource:name bundle:bundle options:GRMustacheDefaultTemplateOptions error:outError];
}

+ (NSString *)renderObject:(id)object fromResource:(NSString *)name bundle:(NSBundle *)bundle options:(GRMustacheTemplateOptions)options error:(NSError **)outError
{
    NSString *result;
    GRMustacheTemplate *template;
    @autoreleasepool {
        template = [GRMustacheTemplate templateFromResource:name bundle:bundle options:options error:outError];
        result = [[template renderObject:object] retain];
        // make sure outError is not released by autoreleasepool
        if (!template && outError != NULL) [*outError retain];
    }
    if (!template && outError != NULL) [*outError autorelease];
    return [result autorelease];
}

+ (NSString *)renderObject:(id)object fromResource:(NSString *)name withExtension:(NSString *)ext bundle:(NSBundle *)bundle error:(NSError **)outError
{
    return [self renderObject:object fromResource:name withExtension:ext bundle:bundle options:GRMustacheDefaultTemplateOptions error:outError];
}

+ (NSString *)renderObject:(id)object fromResource:(NSString *)name withExtension:(NSString *)ext bundle:(NSBundle *)bundle options:(GRMustacheTemplateOptions)options error:(NSError **)outError
{
    NSString *result;
    GRMustacheTemplate *template;
    @autoreleasepool {
        template = [GRMustacheTemplate templateFromResource:name withExtension:ext bundle:bundle options:options error:outError];
        result = [[template renderObject:object] retain];
        // make sure outError is not released by autoreleasepool
        if (!template && outError != NULL) [*outError retain];
    }
    if (!template && outError != NULL) [*outError autorelease];
    return [result autorelease];
}

- (NSString *)render
{
    return [self renderObject:nil];
}

- (NSString *)renderObject:(id)object
{
    return [self renderContext:[GRMustacheContext contextWithObject:object] inRootTemplate:self];
}

- (NSString *)renderObjects:(id)object, ...
{
    NSString *result;
    @autoreleasepool {
        va_list objectList;
        va_start(objectList, object);
        GRMustacheContext *context = [GRMustacheContext contextWithObject:object andObjectList:objectList];
        va_end(objectList);
        result = [[self renderContext:context inRootTemplate:self] retain];
    }
    return [result autorelease];
}

+ (void)object:(id)object kind:(GRMustacheObjectKind *)outKind boolValue:(BOOL *)outBoolValue
{
    if (object == nil ||
        object == [NSNull null] ||
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

#pragma mark <GRMustacheRenderingElement>

- (NSString *)renderContext:(GRMustacheContext *)context inRootTemplate:(GRMustacheTemplate *)rootTemplate
{
    NSMutableString *result = [NSMutableString string];
    @autoreleasepool {
        if ([_delegate respondsToSelector:@selector(templateWillRender:)]) {
            [_delegate templateWillRender:self];
        }
        for (id<GRMustacheRenderingElement> elem in _elems) {
            [result appendString:[elem renderContext:context inRootTemplate:rootTemplate]];
        }
        if ([_delegate respondsToSelector:@selector(templateDidRender:)]) {
            [_delegate templateDidRender:self];
        }
    }
    return result;
}


#pragma mark Private

- (id)initWithElements:(NSArray *)elems options:(GRMustacheTemplateOptions)options
{
    self = [self init];
    if (self) {
        self.elems = elems;
        self.options = options;
    }
    return self;
}

@end
