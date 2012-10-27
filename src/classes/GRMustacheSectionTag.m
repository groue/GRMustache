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
#import "GRMustacheTemplateDelegate.h"
#import "GRMustacheRuntime_private.h"
#import "GRMustacheRendering.h"
#import "GRMustache_private.h"

@interface GRMustacheSectionTag()

/**
 * @see +[GRMustacheSectionTag sectionTagWithExpression:templateString:innerRange:inverted:overridable:components:]
 */
- (id)initWithExpression:(GRMustacheExpression *)expression templateString:(NSString *)templateString innerRange:(NSRange)innerRange type:(GRMustacheTagType)type components:(NSArray *)components;
@end


@implementation GRMustacheSectionTag
@synthesize type=_type;

+ (id)sectionTagWithExpression:(GRMustacheExpression *)expression templateString:(NSString *)templateString innerRange:(NSRange)innerRange type:(GRMustacheTagType)type components:(NSArray *)components
{
    return [[[self alloc] initWithExpression:expression templateString:templateString innerRange:innerRange type:type components:components] autorelease];
}

- (void)dealloc
{
    [_templateString release];
    [_components release];
    [super dealloc];
}

- (NSString *)innerTemplateString
{
    return [_templateString substringWithRange:_innerRange];
}


#pragma mark - <GRMustacheRendering>

- (NSString *)renderForTag:(GRMustacheTag *)tag inRuntime:(GRMustacheRuntime *)runtime templateRepository:(GRMustacheTemplateRepository *)templateRepository HTMLEscaped:(BOOL *)HTMLEscaped
{
    NSMutableString *buffer = [NSMutableString string];
    
    for (id<GRMustacheTemplateComponent> component in _components) {
        // component may be overriden by a GRMustacheTemplateOverride: resolve it.
        component = [runtime resolveTemplateComponent:component];
        
        // render
        [component renderInBuffer:buffer withRuntime:runtime templateRepository:templateRepository];
    }
    
    *HTMLEscaped = YES;
    return buffer;
}


#pragma mark - <GRMustacheTemplateComponent>

- (void)renderInBuffer:(NSMutableString *)buffer withRuntime:(GRMustacheRuntime *)runtime templateRepository:(GRMustacheTemplateRepository *)templateRepository
{
    id value = [_expression evaluateInRuntime:runtime];
    [runtime renderValue:value withTag:self usingBlock:^(id value){
        
        id<GRMustacheRendering> renderingObject = [GRMustache renderingObjectForObject:value];
        
        BOOL HTMLEscaped = NO;
        NSString *rendering = [renderingObject renderForTag:self
                                                  inRuntime:runtime
                                         templateRepository:templateRepository
                                                HTMLEscaped:&HTMLEscaped];
        
        if (rendering) {
            if (!HTMLEscaped) {
                rendering = [GRMustache htmlEscape:rendering];
            }
            [buffer appendString:rendering];
        }
    }];
}

- (id<GRMustacheTemplateComponent>)resolveTemplateComponent:(id<GRMustacheTemplateComponent>)component
{
    // Only {{$...}} section can override components
    if (_type != GRMustacheTagTypeOverridableSection) {
        return component;
    }
    
    // {{$...}} sections can only override other sections
    if (![component isKindOfClass:[GRMustacheSectionTag class]]) {
        return component;
    }
    GRMustacheSectionTag *otherSection = (GRMustacheSectionTag *)component;

    // {{$...}} sections can only override other overridable sections
    if (otherSection.type != GRMustacheTagTypeOverridableSection) {
        return otherSection;
    }

    // {{$...}} sections can only override other sections with the same expression
    if ([otherSection.expression isEqual:_expression]) {
        return self;
    }
    return otherSection;
}


#pragma mark - Private

- (id)initWithExpression:(GRMustacheExpression *)expression templateString:(NSString *)templateString innerRange:(NSRange)innerRange type:(GRMustacheTagType)type components:(NSArray *)components
{
    self = [super initWithExpression:expression];
    if (self) {
        _templateString = [templateString retain];
        _innerRange = innerRange;
        _type = type;
        _components = [components retain];
    }
    return self;
}

@end
