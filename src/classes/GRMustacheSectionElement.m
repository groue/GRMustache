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

#import "GRMustacheSectionElement_private.h"
#import "GRMustacheExpression_private.h"
#import "GRMustacheHelper.h"
#import "GRMustacheRenderingElement_private.h"
#import "GRMustacheTemplate_private.h"
#import "GRMustacheSection_private.h"
#import "GRMustacheTemplateDelegate.h"
#import "GRMustacheRuntime_private.h"

@interface GRMustacheSectionElement()

/**
 * @see +[GRMustacheSectionElement sectionElementWithExpression:templateRepository:templateString:innerRange:inverted:elements:]
 */
- (id)initWithExpression:(GRMustacheExpression *)expression templateRepository:(GRMustacheTemplateRepository *)templateRepository templateString:(NSString *)templateString innerRange:(NSRange)innerRange inverted:(BOOL)inverted elements:(NSArray *)elems;
@end


@implementation GRMustacheSectionElement
@synthesize templateRepository=_templateRepository;

+ (id)sectionElementWithExpression:(GRMustacheExpression *)expression templateRepository:(GRMustacheTemplateRepository *)templateRepository templateString:(NSString *)templateString innerRange:(NSRange)innerRange inverted:(BOOL)inverted elements:(NSArray *)elems
{
    return [[[self alloc] initWithExpression:expression templateRepository:templateRepository templateString:templateString innerRange:innerRange inverted:inverted elements:elems] autorelease];
}

- (void)dealloc
{
    [_expression release];
    [_templateRepository release];
    [_templateString release];
    [_elems release];
    [super dealloc];
}

- (NSString *)innerTemplateString
{
    return [_templateString substringWithRange:_innerRange];
}

- (void)renderInnerElementsInBuffer:(NSMutableString *)buffer withRuntime:(GRMustacheRuntime *)runtime
{
    for (id<GRMustacheRenderingElement> elem in _elems) {
        [elem renderInBuffer:buffer withRuntime:runtime];
    }
}

#pragma mark - <GRMustacheRenderingElement>

- (void)renderInBuffer:(NSMutableString *)buffer withRuntime:(GRMustacheRuntime *)runtime
{
    id value = [_expression evaluateInRuntime:runtime asFilterValue:NO];
    [runtime delegateValue:value interpretation:GRMustacheInterpretationSection forRenderingToken:_expression.token usingBlock:^(id value) {
        
        GRMustacheRuntime *sectionRuntime = runtime;
        
        // Values that conform to the GRMustacheTemplateDelegate protocol
        // enter the runtime.
        
        if ([value conformsToProtocol:@protocol(GRMustacheTemplateDelegate)]) {
            sectionRuntime = [runtime runtimeByAddingTemplateDelegate:(id<GRMustacheTemplateDelegate>)value];
        }
        
        
        // Interpret value
        
        if (value == nil ||
            value == [NSNull null] ||
            ([value isKindOfClass:[NSNumber class]] && [((NSNumber*)value) boolValue] == NO) ||
            ([value isKindOfClass:[NSString class]] && [((NSString*)value) length] == 0))
        {
            // False value
            if (_inverted) {
                [self renderInnerElementsInBuffer:buffer withRuntime:sectionRuntime];
                return;
            }
        }
        else if ([value isKindOfClass:[NSDictionary class]])
        {
            // True value
            if (!_inverted) {
                sectionRuntime = [sectionRuntime runtimeByAddingContextObject:value];
                [self renderInnerElementsInBuffer:buffer withRuntime:sectionRuntime];
                return;
            }
        }
        else if ([value conformsToProtocol:@protocol(NSFastEnumeration)])
        {
            // Enumerable
            if (_inverted) {
                BOOL empty = YES;
                for (id item in value) {
                    empty = NO;
                    break;
                }
                if (empty) {
                    [self renderInnerElementsInBuffer:buffer withRuntime:sectionRuntime];
                    return;
                }
            } else {
                for (id item in value) {
                    GRMustacheRuntime *itemRuntime = [sectionRuntime runtimeByAddingContextObject:item];
                    [self renderInnerElementsInBuffer:buffer withRuntime:itemRuntime];
                }
                return;
            }
        }
        else if ([value conformsToProtocol:@protocol(GRMustacheSectionHelper)])
        {
            // Helper
            if (!_inverted) {
                GRMustacheSection *section = [GRMustacheSection sectionWithSectionElement:self runtime:sectionRuntime];
                NSString *rendering = [(id<GRMustacheSectionHelper>)value renderSection:section];
                if (rendering) {
                    [buffer appendString:rendering];
                }
                return;
            }
        }
        else
        {
            // True value
            if (!_inverted) {
                sectionRuntime = [sectionRuntime runtimeByAddingContextObject:value];
                [self renderInnerElementsInBuffer:buffer withRuntime:sectionRuntime];
                return;
            }
        }
    }];
}


#pragma mark - Private

- (id)initWithExpression:(GRMustacheExpression *)expression templateRepository:(GRMustacheTemplateRepository *)templateRepository templateString:(NSString *)templateString innerRange:(NSRange)innerRange inverted:(BOOL)inverted elements:(NSArray *)elems
{
    self = [self init];
    if (self) {
        _expression = [expression retain];
        _templateRepository = [templateRepository retain];  // TODO: check if we have introduced a retain cycle here
        _templateString = [templateString retain];
        _innerRange = innerRange;
        _inverted = inverted;
        _elems = [elems retain];
    }
    return self;
}

@end
