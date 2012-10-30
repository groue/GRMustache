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

#import "GRMustacheSectionTag_private.h"
#import "GRMustacheExpression_private.h"
#import "GRMustacheTemplateComponent_private.h"
#import "GRMustacheTemplate_private.h"
#import "GRMustacheAccumulatorTag_private.h"
#import "GRMustacheTagDelegate.h"
#import "GRMustacheContext_private.h"
#import "GRMustacheRendering.h"
#import "GRMustache_private.h"

@interface GRMustacheSectionTag()

/**
 * @see +[GRMustacheSectionTag sectionTagWithExpression:templateString:innerRange:inverted:overridable:components:]
 */
- (id)initWithTemplateRepository:(GRMustacheTemplateRepository *)templateRepository expression:(GRMustacheExpression *)expression templateString:(NSString *)templateString innerRange:(NSRange)innerRange type:(GRMustacheTagType)type components:(NSArray *)components;
@end


@implementation GRMustacheSectionTag

+ (id)sectionTagWithTemplateRepository:(GRMustacheTemplateRepository *)templateRepository expression:(GRMustacheExpression *)expression templateString:(NSString *)templateString innerRange:(NSRange)innerRange type:(GRMustacheTagType)type components:(NSArray *)components
{
    return [[[self alloc] initWithTemplateRepository:templateRepository expression:expression templateString:templateString innerRange:innerRange type:type components:components] autorelease];
}

- (void)dealloc
{
    [_templateString release];
    [_components release];
    [super dealloc];
}


#pragma mark - GRMustacheTag

@synthesize type=_type;

- (NSString *)renderContentWithContext:(GRMustacheContext *)context HTMLSafe:(BOOL *)HTMLSafe error:(NSError **)error
{
    NSMutableString *buffer = [NSMutableString string];
    
    for (id<GRMustacheTemplateComponent> component in _components) {
        // component may be overriden by a GRMustacheTemplateOverride: resolve it.
        component = [context resolveTemplateComponent:component];
        
        // render
        if (![component renderWithContext:context inBuffer:buffer error:error]) {
            return nil;
        }
    }
    
    if (HTMLSafe) {
        *HTMLSafe = YES;
    }
    return buffer;
}

- (NSString *)innerTemplateString
{
    return [_templateString substringWithRange:_innerRange];
}

- (GRMustacheTag *)tagWithOverridingTag:(GRMustacheTag *)overridingTag
{
    // In the following situation, the overriden section (self) is replaced by
    // an accumulator tag initialized with the overriding section:
    //
    // layout.mustache:
    //
    //   {{$head}}overriden{{/head}}            <- overriden section (self)
    //
    // base.mustache:
    //
    //   {{<layout}}
    //     {{>partial1}}
    //     {{>partial2}}
    //   {{/}}
    //
    // partial1.mustache:
    //
    //   {{$head}}head for partial 1{{/head}}   <- overriding section
    //
    // partial2.mustache:
    //
    //   {{$head}}head for partial 2{{/head}}
    //
    // Rendering:
    //
    //   head for partial 1
    //   head for partial 2
    //
    // Later, the accumulatorTag will itself be overriden by the section in
    // partial2. See [GRMustacheAccumulatorTag tagWithOverridingTag:]

    return [GRMustacheAccumulatorTag accumulatorTagWithTag:overridingTag];
}

#pragma mark - Private

- (id)initWithTemplateRepository:(GRMustacheTemplateRepository *)templateRepository expression:(GRMustacheExpression *)expression templateString:(NSString *)templateString innerRange:(NSRange)innerRange type:(GRMustacheTagType)type components:(NSArray *)components
{
    self = [super initWithTemplateRepository:templateRepository expression:expression];
    if (self) {
        _templateString = [templateString retain];
        _innerRange = innerRange;
        _type = type;
        _components = [components retain];
    }
    return self;
}

@end
