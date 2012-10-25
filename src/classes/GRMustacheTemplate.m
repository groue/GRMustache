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
#import "GRMustacheRuntime_private.h"
#import "GRMustacheTemplateRepository_private.h"
#import "GRMustacheSection_private.h"

@interface GRMustacheTemplate()
@end

@implementation GRMustacheTemplate
@synthesize innerElements=_innerElements;
@synthesize delegate=_delegate;
@synthesize templateRepository=_templateRepository;

+ (id)templateFromString:(NSString *)templateString error:(NSError **)outError
{
    GRMustacheTemplateRepository *templateRepository = [GRMustacheTemplateRepository templateRepositoryWithBundle:[NSBundle mainBundle]];
    return [templateRepository templateFromString:templateString error:outError];
}

+ (id)templateFromContentsOfURL:(NSURL *)URL error:(NSError **)outError
{
    NSURL *baseURL = [URL URLByDeletingLastPathComponent];
    NSString *templateExtension = [URL pathExtension];
    NSString *templateName = [[URL lastPathComponent] stringByDeletingPathExtension];
    GRMustacheTemplateRepository *templateRepository = [GRMustacheTemplateRepository templateRepositoryWithBaseURL:baseURL templateExtension:templateExtension];
    return [templateRepository templateNamed:templateName error:outError];
}

+ (id)templateFromContentsOfFile:(NSString *)path error:(NSError **)outError
{
    NSString *directoryPath = [path stringByDeletingLastPathComponent];
    NSString *templateExtension = [path pathExtension];
    NSString *templateName = [[path lastPathComponent] stringByDeletingPathExtension];
    GRMustacheTemplateRepository *templateRepository = [GRMustacheTemplateRepository templateRepositoryWithDirectory:directoryPath templateExtension:templateExtension];
    return [templateRepository templateNamed:templateName error:outError];
}

+ (id)templateFromResource:(NSString *)name bundle:(NSBundle *)bundle error:(NSError **)outError
{
    GRMustacheTemplateRepository *templateRepository = [GRMustacheTemplateRepository templateRepositoryWithBundle:bundle];
    return [templateRepository templateNamed:name error:outError];
}

+ (id)templateFromResource:(NSString *)name withExtension:(NSString *)ext bundle:(NSBundle *)bundle error:(NSError **)outError
{
    GRMustacheTemplateRepository *templateRepository = [GRMustacheTemplateRepository templateRepositoryWithBundle:bundle templateExtension:ext];
    return [templateRepository templateNamed:name error:outError];
}

- (void)dealloc
{
    [_innerElements release];
    [super dealloc];
}

+ (NSString *)renderObject:(id)object fromString:(NSString *)templateString error:(NSError **)outError
{
    return [self renderObject:object withFilters:nil fromString:templateString error:outError];
}

+ (NSString *)renderObject:(id)object withFilters:(id)filters fromString:(NSString *)templateString error:(NSError **)outError
{
    NSString *rendering;
    GRMustacheTemplate *template;
    @autoreleasepool {
        template = [GRMustacheTemplate templateFromString:templateString error:outError];
        rendering = [[template renderObject:object withFilters:filters] retain];
        // make sure outError is not released by autoreleasepool
        if (!template && outError != NULL) [*outError retain];
    }
    if (!template && outError != NULL) [*outError autorelease];
    return [rendering autorelease];
}

+ (NSString *)renderObject:(id)object fromContentsOfURL:(NSURL *)URL error:(NSError **)outError
{
    return [self renderObject:object withFilters:nil fromContentsOfURL:URL error:outError];
}

+ (NSString *)renderObject:(id)object withFilters:(id)filters fromContentsOfURL:(NSURL *)URL error:(NSError **)outError
{
    NSString *rendering;
    GRMustacheTemplate *template;
    @autoreleasepool {
        template = [GRMustacheTemplate templateFromContentsOfURL:URL error:outError];
        rendering = [[template renderObject:object withFilters:filters] retain];
        // make sure outError is not released by autoreleasepool
        if (!template && outError != NULL) [*outError retain];
    }
    if (!template && outError != NULL) [*outError autorelease];
    return [rendering autorelease];
}

+ (NSString *)renderObject:(id)object fromContentsOfFile:(NSString *)path error:(NSError **)outError
{
    return [self renderObject:object withFilters:nil fromContentsOfFile:path error:outError];
}

+ (NSString *)renderObject:(id)object withFilters:(id)filters fromContentsOfFile:(NSString *)path error:(NSError **)outError
{
    NSString *rendering;
    GRMustacheTemplate *template;
    @autoreleasepool {
        template = [GRMustacheTemplate templateFromContentsOfFile:path error:outError];
        rendering = [[template renderObject:object withFilters:filters] retain];
        // make sure outError is not released by autoreleasepool
        if (!template && outError != NULL) [*outError retain];
    }
    if (!template && outError != NULL) [*outError autorelease];
    return [rendering autorelease];
}

+ (NSString *)renderObject:(id)object fromResource:(NSString *)name bundle:(NSBundle *)bundle error:(NSError **)outError
{
    return [self renderObject:object withFilters:nil fromResource:name bundle:bundle error:outError];
}

+ (NSString *)renderObject:(id)object withFilters:(id)filters fromResource:(NSString *)name bundle:(NSBundle *)bundle error:(NSError **)outError
{
    NSString *rendering;
    GRMustacheTemplate *template;
    @autoreleasepool {
        template = [GRMustacheTemplate templateFromResource:name bundle:bundle error:outError];
        rendering = [[template renderObject:object withFilters:filters] retain];
        // make sure outError is not released by autoreleasepool
        if (!template && outError != NULL) [*outError retain];
    }
    if (!template && outError != NULL) [*outError autorelease];
    return [rendering autorelease];
}

+ (NSString *)renderObject:(id)object fromResource:(NSString *)name withExtension:(NSString *)ext bundle:(NSBundle *)bundle error:(NSError **)outError
{
    return [self renderObject:object withFilters:nil fromResource:name withExtension:ext bundle:bundle error:outError];
}

+ (NSString *)renderObject:(id)object withFilters:(id)filters fromResource:(NSString *)name withExtension:(NSString *)ext bundle:(NSBundle *)bundle error:(NSError **)outError
{
    NSString *rendering;
    GRMustacheTemplate *template;
    @autoreleasepool {
        template = [GRMustacheTemplate templateFromResource:name withExtension:ext bundle:bundle error:outError];
        rendering = [[template renderObject:object withFilters:filters] retain];
        // make sure outError is not released by autoreleasepool
        if (!template && outError != NULL) [*outError retain];
    }
    if (!template && outError != NULL) [*outError autorelease];
    return [rendering autorelease];
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
    NSMutableString *buffer = [NSMutableString string];
    GRMustacheRuntime *runtime = [GRMustacheRuntime runtimeWithTemplate:self contextStack:(object ? [NSArray arrayWithObject:object] : nil)];
    runtime = [runtime runtimeByAddingFilterObject:filters];
    [self renderInBuffer:buffer withRuntime:runtime templateRepository:_templateRepository];
    return buffer;
}

- (NSString *)renderObjectsFromArray:(NSArray *)objects
{
    return [self renderObjectsFromArray:objects withFilters:nil];
}

- (NSString *)renderObjectsFromArray:(NSArray *)objects withFilters:(id)filters
{
    // GRMustacheRuntime contextStack is in reversed order
    NSMutableArray *contextStack = [NSMutableArray arrayWithCapacity:objects.count];
    for (id object in [objects reverseObjectEnumerator]) {
        [contextStack addObject:object];
    }
    
    NSMutableString *buffer = [NSMutableString string];
    GRMustacheRuntime *runtime = [GRMustacheRuntime runtimeWithTemplate:self contextStack:contextStack];
    runtime = [runtime runtimeByAddingFilterObject:filters];
    [self renderInBuffer:buffer withRuntime:runtime templateRepository:_templateRepository];
    return buffer;
}


#pragma mark <GRMustacheRenderingElement>

- (void)renderInBuffer:(NSMutableString *)buffer withRuntime:(GRMustacheRuntime *)runtime templateRepository:(GRMustacheTemplateRepository *)templateRepository
{
    if ([_delegate respondsToSelector:@selector(templateWillRender:)]) {
        [_delegate templateWillRender:self];
    }
    
    runtime = [runtime runtimeByAddingTemplateDelegate:self.delegate];
    
    for (id<GRMustacheRenderingElement> element in _innerElements) {
        // element may be overriden by a GRMustacheTemplateOverride: resolve it.
        element = [runtime resolveRenderingElement:element];
        
        // render
        [element renderInBuffer:buffer withRuntime:runtime templateRepository:templateRepository];
    }
    
    if ([_delegate respondsToSelector:@selector(templateDidRender:)]) {
        [_delegate templateDidRender:self];
    }
}

- (id<GRMustacheRenderingElement>)resolveRenderingElement:(id<GRMustacheRenderingElement>)element
{
    // look for the last overriding element in inner elements.
    //
    // This allows a partial do define an overriding section:
    //
    //    {
    //        data: { },
    //        expected: "partial1",
    //        name: "Partials in overridable partials can override overridable sections",
    //        template: "{{<partial2}}{{>partial1}}{{/partial2}}"
    //        partials: {
    //            partial1: "{{$overridable}}partial1{{/overridable}}";
    //            partial2: "{{$overridable}}ignored{{/overridable}}";
    //        },
    //    }
    for (id<GRMustacheRenderingElement> innerElement in _innerElements) {
        element = [innerElement resolveRenderingElement:element];
    }
    return element;
}

#pragma mark <GRMustacheRenderingObject>

- (NSString *)renderForSection:(GRMustacheSection *)section inRuntime:(GRMustacheRuntime *)runtime templateRepository:(GRMustacheTemplateRepository *)templateRepository HTMLEscaped:(BOOL *)HTMLEscaped
{
    if (section) {
        // Section tag {{# template }}...{{/}}
        
        // We behave as a true object: the section renders if and only if it is not inverted
        if (section.isInverted)
        {
            return nil;
        }
        else
        {
            runtime = [runtime runtimeByAddingContextObject:self];
            return [section renderForSection:section inRuntime:runtime templateRepository:templateRepository HTMLEscaped:HTMLEscaped];
        }
    }
    else
    {
        // Variable tag {{ template }}
        
        NSMutableString *buffer = [NSMutableString string];
        [self renderInBuffer:buffer withRuntime:runtime templateRepository:templateRepository];
        *HTMLEscaped = YES;
        return buffer;
    }
}

@end
