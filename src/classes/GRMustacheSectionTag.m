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

#import "GRMustacheSectionTag_private.h"
#import "GRMustacheAccumulatorTag_private.h"

@interface GRMustacheSectionTag()

/**
 * @see +[GRMustacheSectionTag sectionTagWithExpression:templateString:innerRange:inverted:overridable:components:]
 */
- (id)initWithType:(GRMustacheTagType)type templateRepository:(GRMustacheTemplateRepository *)templateRepository expression:(GRMustacheExpression *)expression contentType:(GRMustacheContentType)contentType templateString:(NSString *)templateString innerRange:(NSRange)innerRange components:(NSArray *)components;
@end


@implementation GRMustacheSectionTag

+ (instancetype)sectionTagWithType:(GRMustacheTagType)type templateRepository:(GRMustacheTemplateRepository *)templateRepository expression:(GRMustacheExpression *)expression contentType:(GRMustacheContentType)contentType templateString:(NSString *)templateString innerRange:(NSRange)innerRange components:(NSArray *)components
{
    return [[[self alloc] initWithType:type templateRepository:templateRepository expression:expression contentType:contentType templateString:templateString innerRange:innerRange components:components] autorelease];
}

- (void)dealloc
{
    [_templateString release];
    [_components release];
    [super dealloc];
}


#pragma mark - GRMustacheTag

- (NSString *)renderContentWithContext:(GRMustacheContext *)context HTMLSafe:(BOOL *)HTMLSafe error:(NSError **)error
{
    if (!context) {
        // With a nil context, the method would return nil without setting the
        // error argument.
        [NSException raise:NSInvalidArgumentException format:@"Invalid context:nil"];
        return NO;
    }
    
    NSMutableString *buffer = [NSMutableString string];
    
    for (id<GRMustacheTemplateComponent> component in _components) {
        // component may be overriden by a GRMustachePartialOverride: resolve it.
        component = [context resolveTemplateComponent:component];
        
        // render
        if (![component renderContentType:_contentType inBuffer:buffer withContext:context error:error]) {
            return nil;
        }
    }
    
    if (HTMLSafe) {
        *HTMLSafe = (_contentType == GRMustacheContentTypeHTML);
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

- (id)initWithType:(GRMustacheTagType)type templateRepository:(GRMustacheTemplateRepository *)templateRepository expression:(GRMustacheExpression *)expression contentType:(GRMustacheContentType)contentType templateString:(NSString *)templateString innerRange:(NSRange)innerRange components:(NSArray *)components
{
    self = [super initWithType:type templateRepository:templateRepository expression:expression contentType:contentType];
    if (self) {
        _templateString = [templateString retain];
        _innerRange = innerRange;
        _components = [components retain];
    }
    return self;
}

@end
