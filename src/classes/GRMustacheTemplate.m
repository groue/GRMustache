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
#import "GRMustacheSectionTag_private.h"
#import "GRMustacheRendering.h"

@interface GRMustacheTemplate()<GRMustacheRendering>
@end

@implementation GRMustacheTemplate
@synthesize components=_components;
@synthesize contentType=_contentType;

+ (id)templateFromString:(NSString *)templateString error:(NSError **)error
{
    GRMustacheTemplateRepository *templateRepository = [GRMustacheTemplateRepository templateRepositoryWithBundle:[NSBundle mainBundle]];
    return [templateRepository templateFromString:templateString error:error];
}

+ (id)templateFromResource:(NSString *)name bundle:(NSBundle *)bundle error:(NSError **)error
{
    GRMustacheTemplateRepository *templateRepository = [GRMustacheTemplateRepository templateRepositoryWithBundle:bundle];
    return [templateRepository templateNamed:name error:error];
}

+ (id)templateFromContentsOfFile:(NSString *)path error:(NSError **)error
{
    NSString *directoryPath = [path stringByDeletingLastPathComponent];
    NSString *templateExtension = [path pathExtension];
    NSString *templateName = [[path lastPathComponent] stringByDeletingPathExtension];
    GRMustacheTemplateRepository *templateRepository = [GRMustacheTemplateRepository templateRepositoryWithDirectory:directoryPath templateExtension:templateExtension encoding:NSUTF8StringEncoding];
    return [templateRepository templateNamed:templateName error:error];
}

+ (id)templateFromContentsOfURL:(NSURL *)URL error:(NSError **)error
{
    NSURL *baseURL = [URL URLByDeletingLastPathComponent];
    NSString *templateExtension = [URL pathExtension];
    NSString *templateName = [[URL lastPathComponent] stringByDeletingPathExtension];
    GRMustacheTemplateRepository *templateRepository = [GRMustacheTemplateRepository templateRepositoryWithBaseURL:baseURL templateExtension:templateExtension encoding:NSUTF8StringEncoding];
    return [templateRepository templateNamed:templateName error:error];
}

+ (NSString *)renderObject:(id)object fromString:(NSString *)templateString error:(NSError **)error
{
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:templateString error:error];
    return [template renderObject:object error:error];
}

+ (NSString *)renderObject:(id)object fromResource:(NSString *)name bundle:(NSBundle *)bundle error:(NSError **)error
{
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromResource:name bundle:bundle error:error];
    return [template renderObject:object error:error];
}

- (void)dealloc
{
    [_components release];
    [_baseContext release];
    [super dealloc];
}

- (GRMustacheContext *)baseContext
{
    if (_baseContext == nil) {
        _baseContext = [[GRMustacheContext context] retain];
    }
    return [[_baseContext retain] autorelease];
}

- (void)setBaseContext:(GRMustacheContext *)baseContext
{
    if (_baseContext != baseContext) {
        [_baseContext release];
        _baseContext = [baseContext retain];
    }
}

- (NSString *)renderObject:(id)object error:(NSError **)error
{
    GRMustacheContext *context = [self.baseContext contextByAddingObject:object];
    return [self renderContentWithContext:context HTMLSafe:NULL error:error];
}

- (NSString *)renderObjectsFromArray:(NSArray *)objects error:(NSError **)error
{
    GRMustacheContext *context = self.baseContext;
    for (id object in objects) {
        context = [context contextByAddingObject:object];
    }
    return [self renderContentWithContext:context HTMLSafe:NULL error:error];
}

- (NSString *)renderContentWithContext:(GRMustacheContext *)context HTMLSafe:(BOOL *)HTMLSafe error:(NSError **)error
{
    NSMutableString *buffer = [NSMutableString string];
    if (![self renderContentType:self.contentType inBuffer:buffer withContext:context error:error]) {
        return nil;
    }
    if (HTMLSafe) {
        *HTMLSafe = (self.contentType == GRMustacheContentTypeHTML);
    }
    return buffer;
}


#pragma mark - <GRMustacheTemplateComponent>

- (BOOL)renderContentType:(GRMustacheContentType)requiredContentType inBuffer:(NSMutableString *)buffer withContext:(GRMustacheContext *)context error:(NSError **)error
{
    NSMutableString *needsEscapingBuffer = nil;
    NSMutableString *renderingBuffer = nil;
    
    if (requiredContentType == GRMustacheContentTypeHTML && (self.contentType != GRMustacheContentTypeHTML)) {
        // Self renders text, but is asked for HTML.
        // This happens when self is a text partial embedded in a HTML template.
        //
        // We'll have to HTML escape our rendering.
        needsEscapingBuffer = [NSMutableString string];
        renderingBuffer = needsEscapingBuffer;
    } else {
        // Self renders text and is asked for text,
        // or self renders HTML and is asked for HTML.
        //
        // We won't need any specific processing here.
        renderingBuffer = buffer;
    }
    
    for (id<GRMustacheTemplateComponent> component in _components) {
        // component may be overriden by a GRMustacheTemplateOverride: resolve it.
        component = [context resolveTemplateComponent:component];
        
        // render
        if (![component renderContentType:self.contentType inBuffer:renderingBuffer withContext:context error:error]) {
            return NO;
        }
    }
    
    if (needsEscapingBuffer) {
        [buffer appendString:[GRMustache escapeHTML:needsEscapingBuffer]];
    }
    
    return YES;
}

- (id<GRMustacheTemplateComponent>)resolveTemplateComponent:(id<GRMustacheTemplateComponent>)component
{
    // look for the last overriding component in inner components.
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
    for (id<GRMustacheTemplateComponent> innerComponent in _components) {
        component = [innerComponent resolveTemplateComponent:component];
    }
    return component;
}


#pragma mark - <GRMustacheRendering>

// Allows template to render as "dynamic partials"
- (NSString *)renderForMustacheTag:(GRMustacheTag *)tag context:(GRMustacheContext *)context HTMLSafe:(BOOL *)HTMLSafe error:(NSError **)error
{
    return [self renderContentWithContext:context HTMLSafe:HTMLSafe error:error];
}

@end
