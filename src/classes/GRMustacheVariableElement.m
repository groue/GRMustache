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
#import "GRMustacheVariableTagHelper.h"
#import "GRMustacheVariableTagRenderingContext_private.h"
#import "GRMustacheExpression_private.h"
#import "GRMustacheTemplate_private.h"
#import "GRMustacheRuntime_private.h"
#import "GRMustacheSectionElement_private.h"
#import "GRMustacheImplicitIteratorExpression_private.h"

// Compatibility with deprecated declarations

#import "GRMustacheVariableHelper.h"
#import "GRMustacheVariable_private.h"

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
    [_enumerableSectionElement release];
    [super dealloc];
}


#pragma mark <GRMustacheRenderingElement>

- (void)renderInBuffer:(NSMutableString *)buffer withRuntime:(GRMustacheRuntime *)runtime
{
    id value = [_expression evaluateInRuntime:runtime asFilterValue:NO];
    [runtime delegateValue:value interpretation:GRMustacheVariableTagInterpretation forRenderingToken:_expression.token usingBlock:^(id value) {

        // Interpret value

        if ((value == nil) ||
            (value == [NSNull null]))
        {
            // Missing value
        }
        else if ([value conformsToProtocol:@protocol(NSFastEnumeration)] && ![value isKindOfClass:[NSDictionary class]])
        {
            // Enumerable: render {{items}} just as {{#items}}{{.}}{{/items}}
            
            if (_enumerableSectionElement == nil) {
                // Build {{#items}}{{.}}{{/items}} or {{#items}}{{{.}}}{{/items}}, depending on _raw
                GRMustacheExpression *expression = [GRMustacheImplicitIteratorExpression expression];
                GRMustacheVariableElement *innerElement = [GRMustacheVariableElement variableElementWithExpression:expression templateRepository:_templateRepository raw:_raw];
                _enumerableSectionElement = [GRMustacheSectionElement sectionElementWithExpression:_expression
                                                                                templateRepository:_templateRepository
                                                                                    templateString:_raw ? @"{{{.}}}" : @"{{.}}"
                                                                                        innerRange:_raw ? NSMakeRange(0, 7) : NSMakeRange(0, 5)
                                                                                          inverted:NO
                                                                                       overridable:NO
                                                                                     innerElements:[NSArray arrayWithObject:innerElement]];
                [_enumerableSectionElement retain];
            }
            [_enumerableSectionElement renderInBuffer:buffer withRuntime:runtime];
        }
        else if ([value conformsToProtocol:@protocol(GRMustacheVariableTagHelper)])
        {
            // Helper
            
            GRMustacheRuntime *helperRuntime = [runtime runtimeByAddingContextObject:value];
            GRMustacheVariableTagRenderingContext *context = [GRMustacheVariableTagRenderingContext contextWithTemplateRepository:_templateRepository runtime:helperRuntime];
            NSString *rendering = [(id<GRMustacheVariableTagHelper>)value renderForVariableTagInContext:context];
            if (rendering) {
                // Never HTML escape helpers
                [buffer appendString:rendering];
            }
        }
        else if ([value conformsToProtocol:@protocol(GRMustacheVariableHelper)])
        {
            // Helper
            
            GRMustacheRuntime *helperRuntime = [runtime runtimeByAddingContextObject:value];
            GRMustacheVariable *variable = [GRMustacheVariable variableWithTemplateRepository:_templateRepository runtime:helperRuntime];
            NSString *rendering = [(id<GRMustacheVariableHelper>)value renderVariable:variable];
            if (rendering) {
                // Never HTML escape helpers
                [buffer appendString:rendering];
            }
        }
        else
        {
            // Object
            
            NSString *rendering = [value description];
            if (!_raw) {
                rendering = [self htmlEscape:rendering];
            }
            [buffer appendString:rendering];
        }
    }];
}

- (BOOL)isOverridable
{
    return NO;
}

- (id<GRMustacheRenderingElement>)resolveOverridableRenderingElement:(id<GRMustacheRenderingElement>)element
{
    return element;
}


#pragma mark Private

- (id)initWithExpression:(GRMustacheExpression *)expression templateRepository:(GRMustacheTemplateRepository *)templateRepository raw:(BOOL)raw
{
    self = [self init];
    if (self) {
        _templateRepository = templateRepository; // do not retain, since self is retained by a template, that is retained by the template repository.
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
