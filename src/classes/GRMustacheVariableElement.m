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
#import "GRMustacheHelper.h"
#import "GRMustacheVariable_private.h"
#import "GRMustacheExpression_private.h"
#import "GRMustacheTemplate_private.h"
#import "GRMustacheRuntime_private.h"

@interface GRMustacheVariableElement()
- (id)initWithExpression:(GRMustacheExpression *)expression templateRepository:(GRMustacheTemplateRepository *)templateRepository raw:(BOOL)raw;
- (NSString *)htmlEscape:(NSString *)string;
@end


@implementation GRMustacheVariableElement

+ (id)variableElementWithExpression:(GRMustacheExpression *)expression templateRepository:(GRMustacheTemplateRepository *)templateRepository raw:(BOOL)raw
{
    return [[[self alloc] initWithExpression:expression templateRepository:templateRepository raw:raw] autorelease];
}

- (void)dealloc
{
    [_expression release];
    [_templateRepository release];
    [super dealloc];
}


#pragma mark <GRMustacheRenderingElement>

- (void)renderInBuffer:(NSMutableString *)buffer withRuntime:(GRMustacheRuntime *)runtime
{
    id value = [_expression evaluateInRuntime:runtime asFilterValue:NO];
    [runtime delegateValue:value interpretation:GRMustacheInterpretationVariable forRenderingToken:_expression.token usingBlock:^(id value) {

        // Interpret value

        if ((value == nil) ||
            (value == [NSNull null]))
        {
            // Missing value
            return;
        }
        else if ([value conformsToProtocol:@protocol(GRMustacheVariableHelper)])
        {
            // Helper
            GRMustacheVariable *variable = [GRMustacheVariable variableWithTemplateRepository:_templateRepository runtime:runtime];
            NSString *rendering = [(id<GRMustacheVariableHelper>)value renderVariable:variable];
            if (rendering) {
                [buffer appendString:rendering];
            }
            return;
        }
        else
        {
            // Other value
            NSString *rendering = [value description];
            if (!_raw) {
                rendering = [self htmlEscape:rendering];
            }
            [buffer appendString:rendering];
            return;
        }
    }];
}


#pragma mark Private

- (id)initWithExpression:(GRMustacheExpression *)expression templateRepository:(GRMustacheTemplateRepository *)templateRepository raw:(BOOL)raw
{
    self = [self init];
    if (self) {
        _templateRepository = [templateRepository retain];  // TODO: check if we have introduced a retain cycle here
        _expression = [expression retain];
        _raw = raw;
    }
    return self;
}

- (NSString *)htmlEscape:(NSString *)string
{
    NSMutableString *result = [NSMutableString stringWithString:string];
    [result replaceOccurrencesOfString:@"&" withString:@"&amp;" options:NSLiteralSearch range:NSMakeRange(0, result.length)];
    [result replaceOccurrencesOfString:@"<" withString:@"&lt;" options:NSLiteralSearch range:NSMakeRange(0, result.length)];
    [result replaceOccurrencesOfString:@">" withString:@"&gt;" options:NSLiteralSearch range:NSMakeRange(0, result.length)];
    [result replaceOccurrencesOfString:@"\"" withString:@"&quot;" options:NSLiteralSearch range:NSMakeRange(0, result.length)];
    [result replaceOccurrencesOfString:@"'" withString:@"&apos;" options:NSLiteralSearch range:NSMakeRange(0, result.length)];
    return result;
}

@end
