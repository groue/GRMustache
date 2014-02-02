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

#import "GRMustachePartial_private.h"
#import "GRMustacheAST_private.h"
#import "GRMustacheHTMLEscape_private.h"

@implementation GRMustachePartial
@synthesize AST=_AST;

- (void)dealloc
{
    [_AST release];
    [super dealloc];
}

#pragma mark <GRMustacheTemplateComponent>

- (BOOL)renderContentType:(GRMustacheContentType)requiredContentType inBuffer:(NSMutableString *)buffer withContext:(GRMustacheContext *)context error:(NSError **)error
{
    if (!context) {
        // With a nil context, the method would return NO without setting the
        // error argument.
        [NSException raise:NSInvalidArgumentException format:@"Invalid context:nil"];
        return NO;
    }
    
    GRMustacheContentType partialContentType = _AST.contentType;
    NSMutableString *needsEscapingBuffer = nil;
    NSMutableString *renderingBuffer = nil;
    
    if (requiredContentType == GRMustacheContentTypeHTML && (partialContentType != GRMustacheContentTypeHTML)) {
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
    
    for (id<GRMustacheTemplateComponent> component in _AST.templateComponents) {
        // component may be overriden by a GRMustachePartialOverride: resolve it.
        component = [context resolveTemplateComponent:component];
        
        // render
        if (![component renderContentType:partialContentType inBuffer:renderingBuffer withContext:context error:error]) {
            return NO;
        }
    }
    
    if (needsEscapingBuffer) {
        [buffer appendString:[GRMustacheHTMLEscape escapeHTML:needsEscapingBuffer]];
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
    for (id<GRMustacheTemplateComponent> innerComponent in _AST.templateComponents) {
        component = [innerComponent resolveTemplateComponent:component];
    }
    return component;
}

@end
