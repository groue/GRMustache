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

#import "GRMustacheVariableElement_private.h"
#import "GRMustacheExpression_private.h"
#import "GRMustacheTemplate_private.h"
#import "GRMustacheRuntime_private.h"
#import "GRMustacheSection_private.h"
#import "GRMustacheImplicitIteratorExpression_private.h"
#import "GRMustacheRenderingObject_private.h"
#import "GRMustache_private.h"

@interface GRMustacheVariableElement()
- (id)initWithExpression:(GRMustacheExpression *)expression raw:(BOOL)raw;
@end


@implementation GRMustacheVariableElement

+ (id)variableElementWithExpression:(GRMustacheExpression *)expression raw:(BOOL)raw
{
    return [[[self alloc] initWithExpression:expression raw:raw] autorelease];
}

- (void)dealloc
{
    [_expression release];
    [_enumerableSection release];
    [super dealloc];
}


#pragma mark <GRMustacheRenderingElement>

- (void)renderInBuffer:(NSMutableString *)buffer withRuntime:(GRMustacheRuntime *)runtime templateRepository:(GRMustacheTemplateRepository *)templateRepository
{
    id value = [_expression evaluateInRuntime:runtime asFilterValue:NO];
    [runtime delegateValue:value interpretation:GRMustacheVariableTagInterpretation forRenderingToken:_expression.token usingBlock:^(id value) {
        
        id<GRMustacheRenderingObject> renderingObject = [GRMustache renderingObjectForValue:value];
        
        BOOL HTMLEscaped = NO;
        NSString *rendering = [renderingObject renderForSection:nil inRuntime:runtime templateRepository:templateRepository HTMLEscaped:&HTMLEscaped];
        
        if (rendering) {
            if (!_raw && !HTMLEscaped) {
                rendering = [GRMustache htmlEscape:rendering];
            }
            [buffer appendString:rendering];
        }
    }];
}

- (id<GRMustacheRenderingElement>)resolveRenderingElement:(id<GRMustacheRenderingElement>)element
{
    // variable tags can not override any other element
    return element;
}


#pragma mark Private

- (id)initWithExpression:(GRMustacheExpression *)expression raw:(BOOL)raw
{
    self = [self init];
    if (self) {
        _expression = [expression retain];
        _raw = raw;
    }
    return self;
}

@end
