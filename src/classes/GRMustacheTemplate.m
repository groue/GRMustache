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
@synthesize components=_components;
@synthesize delegate=_delegate;
@synthesize templateRepository=_templateRepository;

+ (id)templateFromString:(NSString *)templateString error:(NSError **)outError
{
    GRMustacheTemplateRepository *templateRepository = [GRMustacheTemplateRepository templateRepositoryWithBundle:[NSBundle mainBundle]];
    return [templateRepository templateFromString:templateString error:outError];
}

+ (id)templateFromResource:(NSString *)name bundle:(NSBundle *)bundle error:(NSError **)outError
{
    GRMustacheTemplateRepository *templateRepository = [GRMustacheTemplateRepository templateRepositoryWithBundle:bundle];
    return [templateRepository templateNamed:name error:outError];
}

+ (id)templateFromContentsOfFile:(NSString *)path error:(NSError **)outError
{
    NSString *directoryPath = [path stringByDeletingLastPathComponent];
    NSString *templateExtension = [path pathExtension];
    NSString *templateName = [[path lastPathComponent] stringByDeletingPathExtension];
    GRMustacheTemplateRepository *templateRepository = [GRMustacheTemplateRepository templateRepositoryWithDirectory:directoryPath templateExtension:templateExtension];
    return [templateRepository templateNamed:templateName error:outError];
}

+ (id)templateFromContentsOfURL:(NSURL *)URL error:(NSError **)outError
{
    NSURL *baseURL = [URL URLByDeletingLastPathComponent];
    NSString *templateExtension = [URL pathExtension];
    NSString *templateName = [[URL lastPathComponent] stringByDeletingPathExtension];
    GRMustacheTemplateRepository *templateRepository = [GRMustacheTemplateRepository templateRepositoryWithBaseURL:baseURL templateExtension:templateExtension];
    return [templateRepository templateNamed:templateName error:outError];
}

- (void)dealloc
{
    [_components release];
    [super dealloc];
}

- (NSString *)render
{
    return [self renderObject:nil];
}

- (NSString *)renderObject:(id)object
{
    GRMustacheRuntime *runtime = [GRMustacheRuntime runtime];
    runtime = [runtime runtimeByAddingContextObject:object];
    
    BOOL HTMLEscaped = NO;
    return [self renderForSection:nil inRuntime:runtime templateRepository:_templateRepository HTMLEscaped:&HTMLEscaped];
}

- (NSString *)renderObjectsFromArray:(NSArray *)objects
{
    GRMustacheRuntime *runtime = [GRMustacheRuntime runtime];
    for (id object in objects) {
        runtime = [runtime runtimeByAddingContextObject:object];
    }
    
    BOOL HTMLEscaped = NO;
    return [self renderForSection:nil inRuntime:runtime templateRepository:_templateRepository HTMLEscaped:&HTMLEscaped];
}


#pragma mark <GRMustacheTemplateComponent>

- (void)renderInBuffer:(NSMutableString *)buffer withRuntime:(GRMustacheRuntime *)runtime templateRepository:(GRMustacheTemplateRepository *)templateRepository
{
    runtime = [runtime runtimeWithDelegatingTemplate:self];
    runtime = [runtime runtimeByAddingTemplateDelegate:self.delegate];
    
    for (id<GRMustacheTemplateComponent> component in _components) {
        // component may be overriden by a GRMustacheTemplateOverride: resolve it.
        component = [runtime resolveTemplateComponent:component];
        
        // render
        [component renderInBuffer:buffer withRuntime:runtime templateRepository:templateRepository];
    }
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

#pragma mark <GRMustacheRendering>

- (NSString *)renderForSection:(GRMustacheSection *)section inRuntime:(GRMustacheRuntime *)runtime templateRepository:(GRMustacheTemplateRepository *)templateRepository HTMLEscaped:(BOOL *)HTMLEscaped
{
    NSMutableString *buffer = [NSMutableString string];
    [self renderInBuffer:buffer withRuntime:runtime templateRepository:templateRepository];
    *HTMLEscaped = YES;
    return buffer;
}

@end
