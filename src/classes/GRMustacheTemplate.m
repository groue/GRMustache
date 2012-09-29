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

@interface GRMustacheTemplate()
- (id)initWithInnerElements:(NSArray *)innerElements;
@end

@implementation GRMustacheTemplate
@synthesize innerElements=_innerElements;
@synthesize delegate=_delegate;

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
    return [templateRepository templateForName:templateName error:outError];
}

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

+ (id)templateWithInnerElements:(NSArray *)innerElements
{
    return [[[self alloc] initWithInnerElements:innerElements] autorelease];
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
    GRMustacheRuntime *runtime = [GRMustacheRuntime runtimeWithTemplate:self contextObject:object];
    runtime = [runtime runtimeByAddingFilterObject:filters];
    [self renderInBuffer:buffer withRuntime:runtime];
    return buffer;
}

- (NSString *)renderObjectsInArray:(NSArray *)objects
{
    return [self renderObjectsFromArray:objects withFilters:nil];
}

- (NSString *)renderObjectsFromArray:(NSArray *)objects
{
    return [self renderObjectsFromArray:objects withFilters:nil];
}

- (NSString *)renderObjectsInArray:(NSArray *)objects withFilters:(id)filters
{
    return [self renderObjectsFromArray:objects withFilters:filters];
}

- (NSString *)renderObjectsFromArray:(NSArray *)objects withFilters:(id)filters
{
    NSMutableString *buffer = [NSMutableString string];
    GRMustacheRuntime *runtime = [GRMustacheRuntime runtimeWithTemplate:self contextObjects:objects];
    runtime = [runtime runtimeByAddingFilterObject:filters];
    [self renderInBuffer:buffer withRuntime:runtime];
    return buffer;
}


#pragma mark <GRMustacheRenderingElement>

- (void)renderInBuffer:(NSMutableString *)buffer withRuntime:(GRMustacheRuntime *)runtime
{
    if ([_delegate respondsToSelector:@selector(templateWillRender:)]) {
        [_delegate templateWillRender:self];
    }
    
    for (id<GRMustacheRenderingElement> element in _innerElements) {
        element = [runtime resolveRenderingElement:element];
        [element renderInBuffer:buffer withRuntime:runtime];
    }
    
    if ([_delegate respondsToSelector:@selector(templateDidRender:)]) {
        [_delegate templateDidRender:self];
    }
}

- (BOOL)isOverridable
{
    return NO;
}

- (id<GRMustacheRenderingElement>)resolveOverridableRenderingElement:(id<GRMustacheRenderingElement>)element
{
    for (id<GRMustacheRenderingElement> innerElement in _innerElements) {
        element = [innerElement resolveOverridableRenderingElement:element];
    }
    return element;
}

#pragma mark Private

- (id)initWithInnerElements:(NSArray *)innerElements
{
    self = [self init];
    if (self) {
        self.innerElements = innerElements;
    }
    return self;
}

@end
