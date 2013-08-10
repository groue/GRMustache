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

#import "GRMustacheHTMLLibrary_private.h"
#import "GRMustacheTag_private.h"
#import "GRMustacheContext_private.h"
#import "GRMustache_private.h"

// =============================================================================
#pragma mark - GRMustacheHTMLEscapeFilter

@implementation GRMustacheHTMLEscapeFilter

#pragma mark <GRMustacheFilter>

/**
 * Support for {{ html.escape(value) }}
 */
- (id)transformedValue:(id)object
{
    // Our transformation applies to strings, not to objects of type `id`.
    //
    // So let's transform the *rendering* of the object, not the object itself.
    //
    // However, we do not have the rendering yet. So we return a rendering
    // object that will eventually render the object, and transform the
    // rendering.
    
    return [GRMustache renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
        id<GRMustacheRendering> renderingObject = [GRMustache renderingObjectForObject:object];
        NSString *rendering = [renderingObject renderForMustacheTag:tag context:context HTMLSafe:HTMLSafe error:error];
        return [GRMustache escapeHTML:rendering];
    }];
}


#pragma mark - <GRMustacheRendering>

/**
 * Support for {{# html.escape }}...{{ value }}...{{ value }}...{{/ html.escape }}
 */
- (NSString *)renderForMustacheTag:(GRMustacheTag *)tag context:(GRMustacheContext *)context HTMLSafe:(BOOL *)HTMLSafe error:(NSError **)error
{
    switch (tag.type) {
        case GRMustacheTagTypeVariable:
            // {{ html.escape }}
            // Behave as a regular object: render self's description
            if (HTMLSafe != NULL) { *HTMLSafe = NO; }
            return [self description];
            
        case GRMustacheTagTypeInvertedSection:
            // {{^ html.escape }}...{{/ html.escape }}
            // Behave as a truthy object: don't render for inverted sections
            return nil;
            
        default:
            // {{# html.escape }}...{{/ html.escape }}
            // {{$ html.escape }}...{{/ html.escape }}
            
            // Render normally, but listen to all inner tags rendering, so that
            // we can format them. See mustacheTag:willRenderObject: below.
            context = [context contextByAddingTagDelegate:self];
            return [tag renderContentWithContext:context HTMLSafe:HTMLSafe error:error];
    }
}


#pragma mark - <GRMustacheTagDelegate>

/**
 * Support for {{# html.escape }}...{{ value }}...{{ value }}...{{/ html.escape }}
 */
- (id)mustacheTag:(GRMustacheTag *)tag willRenderObject:(id)object
{
    // Process {{ value }}
    if (tag.type == GRMustacheTagTypeVariable) {
        return [self transformedValue:object];
    }
    
    // Don't process {{# value }}, {{^ value }}, {{$ value }}
    return object;
}

@end
