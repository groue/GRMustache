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

#import "GRMustacheTemplate_private.h"
#import "GRMustacheContext_private.h"
#import "GRMustacheTemplateRepository_private.h"

@interface GRMustacheTemplate()
- (id)initWithElements:(NSArray *)elems;
@end

@implementation GRMustacheTemplate
@synthesize elems=_elems;
@synthesize delegate=_delegate;

+ (id)templateFromString:(NSString *)templateString error:(NSError **)outError
{
    GRMustacheTemplateRepository *templateRepository = [GRMustacheTemplateRepository templateRepositoryWithBundle:[NSBundle mainBundle]];
    return [templateRepository templateFromString:templateString error:outError];
}

#if !TARGET_OS_IPHONE || __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000

+ (id)templateFromContentsOfURL:(NSURL *)URL error:(NSError **)outError
{
    NSURL *baseURL = [URL URLByDeletingLastPathComponent];
    NSString *templateExtension = [URL pathExtension];
    NSString *templateName = [[URL lastPathComponent] stringByDeletingPathExtension];
    GRMustacheTemplateRepository *templateRepository = [GRMustacheTemplateRepository templateRepositoryWithBaseURL:baseURL templateExtension:templateExtension];
    return [templateRepository templateForName:templateName error:outError];
}

#endif /* if !TARGET_OS_IPHONE || __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000 */

+ (id)templateFromContentsOfFile:(NSString *)path error:(NSError **)outError
{
    NSString *directoryPath = [path stringByDeletingLastPathComponent];
    NSString *templateExtension = [path pathExtension];
    NSString *templateName = [[path lastPathComponent] stringByDeletingPathExtension];
    GRMustacheTemplateRepository *templateRepository = [GRMustacheTemplateRepository templateRepositoryWithDirectory:directoryPath templateExtension:templateExtension];
    return [templateRepository templateForName:templateName error:outError];
}

+ (id)templateFromResource:(NSString *)name bundle:(NSBundle *)bundle error:(NSError **)outError
{
    GRMustacheTemplateRepository *templateRepository = [GRMustacheTemplateRepository templateRepositoryWithBundle:bundle];
    return [templateRepository templateForName:name error:outError];
}

+ (id)templateFromResource:(NSString *)name withExtension:(NSString *)ext bundle:(NSBundle *)bundle error:(NSError **)outError
{
    GRMustacheTemplateRepository *templateRepository = [GRMustacheTemplateRepository templateRepositoryWithBundle:bundle templateExtension:ext];
    return [templateRepository templateForName:name error:outError];
}

+ (id)templateWithElements:(NSArray *)elems
{
    return [[[self alloc] initWithElements:elems] autorelease];
}

- (void)dealloc
{
    [_elems release];
    [super dealloc];
}

+ (NSString *)renderObject:(id)object fromString:(NSString *)templateString error:(NSError **)outError
{
    return [self renderObject:object withFilters:nil fromString:templateString error:outError];
}

+ (NSString *)renderObject:(id)object withFilters:(id)filters fromString:(NSString *)templateString error:(NSError **)outError
{
    NSString *result;
    GRMustacheTemplate *template;
    @autoreleasepool {
        template = [GRMustacheTemplate templateFromString:templateString error:outError];
        result = [[template renderObject:object withFilters:filters] retain];
        // make sure outError is not released by autoreleasepool
        if (!template && outError != NULL) [*outError retain];
    }
    if (!template && outError != NULL) [*outError autorelease];
    return [result autorelease];
}

#if !TARGET_OS_IPHONE || __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000

+ (NSString *)renderObject:(id)object fromContentsOfURL:(NSURL *)URL error:(NSError **)outError
{
    return [self renderObject:object withFilters:nil fromContentsOfURL:URL error:outError];
}

+ (NSString *)renderObject:(id)object withFilters:(id)filters fromContentsOfURL:(NSURL *)URL error:(NSError **)outError
{
    NSString *result;
    GRMustacheTemplate *template;
    @autoreleasepool {
        template = [GRMustacheTemplate templateFromContentsOfURL:URL error:outError];
        result = [[template renderObject:object withFilters:filters] retain];
        // make sure outError is not released by autoreleasepool
        if (!template && outError != NULL) [*outError retain];
    }
    if (!template && outError != NULL) [*outError autorelease];
    return [result autorelease];
}

#endif /* if !TARGET_OS_IPHONE || __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000 */

+ (NSString *)renderObject:(id)object fromContentsOfFile:(NSString *)path error:(NSError **)outError
{
    return [self renderObject:object withFilters:nil fromContentsOfFile:path error:outError];
}

+ (NSString *)renderObject:(id)object withFilters:(id)filters fromContentsOfFile:(NSString *)path error:(NSError **)outError
{
    NSString *result;
    GRMustacheTemplate *template;
    @autoreleasepool {
        template = [GRMustacheTemplate templateFromContentsOfFile:path error:outError];
        result = [[template renderObject:object withFilters:filters] retain];
        // make sure outError is not released by autoreleasepool
        if (!template && outError != NULL) [*outError retain];
    }
    if (!template && outError != NULL) [*outError autorelease];
    return [result autorelease];
}

+ (NSString *)renderObject:(id)object fromResource:(NSString *)name bundle:(NSBundle *)bundle error:(NSError **)outError
{
    return [self renderObject:object withFilters:nil fromResource:name bundle:bundle error:outError];
}

+ (NSString *)renderObject:(id)object withFilters:(id)filters fromResource:(NSString *)name bundle:(NSBundle *)bundle error:(NSError **)outError
{
    NSString *result;
    GRMustacheTemplate *template;
    @autoreleasepool {
        template = [GRMustacheTemplate templateFromResource:name bundle:bundle error:outError];
        result = [[template renderObject:object withFilters:filters] retain];
        // make sure outError is not released by autoreleasepool
        if (!template && outError != NULL) [*outError retain];
    }
    if (!template && outError != NULL) [*outError autorelease];
    return [result autorelease];
}

+ (NSString *)renderObject:(id)object fromResource:(NSString *)name withExtension:(NSString *)ext bundle:(NSBundle *)bundle error:(NSError **)outError
{
    return [self renderObject:object withFilters:nil fromResource:name withExtension:ext bundle:bundle error:outError];
}

+ (NSString *)renderObject:(id)object withFilters:(id)filters fromResource:(NSString *)name withExtension:(NSString *)ext bundle:(NSBundle *)bundle error:(NSError **)outError
{
    NSString *result;
    GRMustacheTemplate *template;
    @autoreleasepool {
        template = [GRMustacheTemplate templateFromResource:name withExtension:ext bundle:bundle error:outError];
        result = [[template renderObject:object withFilters:filters] retain];
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
    return [self renderObject:object withFilters:nil];
}

- (NSString *)renderObject:(id)object withFilters:(id)filters
{
    NSString *result;
    @autoreleasepool {
        NSArray *delegates = _delegate ? [NSArray arrayWithObject:_delegate] : nil;
        GRMustacheContext *renderingContext = [GRMustacheContext contextWithObject:object];
        GRMustacheContext *filterContext = [GRMustacheContext contextWithObject:filters];
        result = [[self renderRenderingContext:renderingContext filterContext:filterContext delegatingTemplate:self delegates:delegates] retain];
    }
    return [result autorelease];
}

- (NSString *)renderObjectsInArray:(NSArray *)objects
{
    return [self renderObjectsInArray:objects withFilters:nil];
}

- (NSString *)renderObjectsInArray:(NSArray *)objects withFilters:(id)filters
{
    NSString *result;
    @autoreleasepool {
        GRMustacheContext *renderingContext = nil;
        for (id object in objects) {
            renderingContext = renderingContext ? [renderingContext contextByAddingObject:object] : [GRMustacheContext contextWithObject:object];
        }
        GRMustacheContext *filterContext = [GRMustacheContext contextWithObject:filters];
        NSArray *delegates = _delegate ? [NSArray arrayWithObject:_delegate] : nil;
        result = [[self renderRenderingContext:renderingContext filterContext:filterContext delegatingTemplate:self delegates:delegates] retain];
    }
    return [result autorelease];
}

- (NSString *)renderObjects:(id)object, ...
{
    NSString *result;
    @autoreleasepool {
        va_list objectList;
        va_start(objectList, object);
        GRMustacheContext *renderingContext = [GRMustacheContext contextWithObject:object andObjectList:objectList];
        va_end(objectList);
        NSArray *delegates = _delegate ? [NSArray arrayWithObject:_delegate] : nil;
        result = [[self renderRenderingContext:renderingContext filterContext:nil delegatingTemplate:self delegates:delegates] retain];
    }
    return [result autorelease];
}

- (void)invokeDelegates:(NSArray *)delegates willInterpretReturnValueOfInvocation:(GRMustacheInvocation *)invocation as:(GRMustacheInterpretation)interpretation
{
    for (id<GRMustacheTemplateDelegate> delegate in delegates) {
        if ([delegate respondsToSelector:@selector(template:willInterpretReturnValueOfInvocation:as:)]) {
            // 4.1 API
            [delegate template:self willInterpretReturnValueOfInvocation:invocation as:interpretation];
        } else if ([delegate respondsToSelector:@selector(template:willRenderReturnValueOfInvocation:)]) {
            // 4.0 API
            [delegate template:self willRenderReturnValueOfInvocation:invocation];
        }
    }
}

- (void)invokeDelegates:(NSArray *)delegates didInterpretReturnValueOfInvocation:(GRMustacheInvocation *)invocation as:(GRMustacheInterpretation)interpretation
{
    for (id<GRMustacheTemplateDelegate> delegate in delegates) {
        if ([delegate respondsToSelector:@selector(template:didInterpretReturnValueOfInvocation:as:)]) {
            // 4.1 API
            [delegate template:self didInterpretReturnValueOfInvocation:invocation as:interpretation];
        } else if ([delegate respondsToSelector:@selector(template:didRenderReturnValueOfInvocation:)]) {
            // 4.0 API
            [delegate template:self didRenderReturnValueOfInvocation:invocation];
        }
    }
}


#pragma mark <GRMustacheRenderingElement>

- (NSString *)renderRenderingContext:(GRMustacheContext *)renderingContext filterContext:(GRMustacheContext *)filterContext delegatingTemplate:(GRMustacheTemplate *)delegatingTemplate delegates:(NSArray *)delegates
{
    NSMutableString *result = [NSMutableString stringWithCapacity:1024];    // allocate 1Kb
    @autoreleasepool {
        if ([_delegate respondsToSelector:@selector(templateWillRender:)]) {
            [_delegate templateWillRender:self];
        }
        
        for (id<GRMustacheRenderingElement> elem in _elems) {
            [result appendString:[elem renderRenderingContext:renderingContext filterContext:filterContext delegatingTemplate:delegatingTemplate delegates:delegates]];
        }
        
        if ([_delegate respondsToSelector:@selector(templateDidRender:)]) {
            [_delegate templateDidRender:self];
        }
    }
    return result;
}


#pragma mark Private

- (id)initWithElements:(NSArray *)elems
{
    self = [self init];
    if (self) {
        self.elems = elems;
    }
    return self;
}

@end
