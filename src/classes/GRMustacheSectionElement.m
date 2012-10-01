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
#import "GRMustacheSectionTagHelper.h"
#import "GRMustacheRenderingElement_private.h"
#import "GRMustacheTemplate_private.h"
#import "GRMustacheSectionTagRenderingContext_private.h"
#import "GRMustacheTemplateDelegate.h"
#import "GRMustacheRuntime_private.h"

// Compatibility with deprecated declarations

#import "GRMustacheSectionHelper.h"
#import "GRMustacheSection_private.h"

@interface GRMustacheSectionElement()
@property (nonatomic, retain, readonly) GRMustacheExpression *expression;

/**
 * @see +[GRMustacheSectionElement sectionElementWithExpression:templateRepository:templateString:innerRange:inverted:overridable:innerElements:]
 */
- (id)initWithExpression:(GRMustacheExpression *)expression templateRepository:(GRMustacheTemplateRepository *)templateRepository templateString:(NSString *)templateString innerRange:(NSRange)innerRange inverted:(BOOL)inverted overridable:(BOOL)overridable innerElements:(NSArray *)innerElements;

/**
 * Check object type, and render it as a section tag helper or a plain object.
 */
- (void)renderObject:(id)object inBuffer:(NSMutableString *)buffer withRuntime:(GRMustacheRuntime *)runtime;
@end


@implementation GRMustacheSectionElement
@synthesize templateRepository=_templateRepository;
@synthesize expression=_expression;
@synthesize overridable=_overridable;

+ (id)sectionElementWithExpression:(GRMustacheExpression *)expression templateRepository:(GRMustacheTemplateRepository *)templateRepository templateString:(NSString *)templateString innerRange:(NSRange)innerRange inverted:(BOOL)inverted overridable:(BOOL)overridable innerElements:(NSArray *)innerElements
{
    return [[[self alloc] initWithExpression:expression templateRepository:templateRepository templateString:templateString innerRange:innerRange inverted:inverted overridable:overridable innerElements:innerElements] autorelease];
}

- (void)dealloc
{
    [_expression release];
    [_templateString release];
    [_innerElements release];
    [super dealloc];
}

- (NSString *)innerTemplateString
{
    return [_templateString substringWithRange:_innerRange];
}

- (void)renderInnerElementsInBuffer:(NSMutableString *)buffer withRuntime:(GRMustacheRuntime *)runtime
{
    for (id<GRMustacheRenderingElement> element in _innerElements) {
        element = [runtime resolveRenderingElement:element];      // apply overrides
        [element renderInBuffer:buffer withRuntime:runtime];   // render
    }
}

#pragma mark - <GRMustacheRenderingElement>

- (void)renderInBuffer:(NSMutableString *)buffer withRuntime:(GRMustacheRuntime *)runtime
{
    id value = [_expression evaluateInRuntime:runtime asFilterValue:NO];
    [runtime delegateValue:value interpretation:GRMustacheSectionTagInterpretation forRenderingToken:_expression.token usingBlock:^(id value) {
        
        // Interpret value
        
        if (value == nil)
        {
            // Missing value
            if (_inverted || _overridable) {
                [self renderInnerElementsInBuffer:buffer withRuntime:runtime];
            }
            return;
        }
        else if (value == [NSNull null] ||
                 ([value isKindOfClass:[NSNumber class]] && [((NSNumber*)value) boolValue] == NO) ||
                 ([value isKindOfClass:[NSString class]] && [((NSString*)value) length] == 0))
        {
            // False value
            if (_inverted) {
                [self renderInnerElementsInBuffer:buffer withRuntime:runtime];
            }
            return;
        }
        else if (![value isKindOfClass:[NSDictionary class]] && [value conformsToProtocol:@protocol(NSFastEnumeration)])
        {
            // Enumerable
            if (_inverted) {
                BOOL empty = YES;
                for (id item in value) {
                    empty = NO;
                    break;
                }
                if (empty) {
                    [self renderInnerElementsInBuffer:buffer withRuntime:runtime];
                }
            } else {
                for (id item in value) {
                    [self renderObject:item inBuffer:buffer withRuntime:runtime];
                }
            }
            return;
        }
        else
        {
            // Other values
            if (!_inverted) {
                [self renderObject:value inBuffer:buffer withRuntime:runtime];
            }
        }
    }];
}

- (id<GRMustacheRenderingElement>)resolveOverridableRenderingElement:(id<GRMustacheRenderingElement>)element
{
    if (!_overridable) {
        return element;
    }
    if (![element isKindOfClass:[GRMustacheSectionElement class]]) {
        return element;
    }
    GRMustacheSectionElement *otherSectionElement = (GRMustacheSectionElement *)element;
    if ([otherSectionElement.expression isEqual:_expression]) {
        return self;
    }
    return element;
}


#pragma mark - Private

- (id)initWithExpression:(GRMustacheExpression *)expression templateRepository:(GRMustacheTemplateRepository *)templateRepository templateString:(NSString *)templateString innerRange:(NSRange)innerRange inverted:(BOOL)inverted overridable:(BOOL)overridable innerElements:(NSArray *)innerElements
{
    self = [self init];
    if (self) {
        _expression = [expression retain];
        _templateRepository = templateRepository; // do not retain, since self is retained by a template, that is retained by the template repository.
        _templateString = [templateString retain];
        _innerRange = innerRange;
        _inverted = inverted;
        _overridable = overridable;
        _innerElements = [innerElements retain];
    }
    return self;
}

- (void)renderObject:(id)object inBuffer:(NSMutableString *)buffer withRuntime:(GRMustacheRuntime *)runtime
{
    // Objects that conform to the GRMustacheTemplateDelegate protocol enter the runtime.
    if ([object conformsToProtocol:@protocol(GRMustacheTemplateDelegate)]) {
        runtime = [runtime runtimeByAddingTemplateDelegate:(id<GRMustacheTemplateDelegate>)object];
    }
    
    // Objects enter context stack
    runtime = [runtime runtimeByAddingContextObject:object];
    
    if ([object conformsToProtocol:@protocol(GRMustacheSectionTagHelper)])
    {
        // Helper
        
        GRMustacheSectionTagRenderingContext *context = [GRMustacheSectionTagRenderingContext contextWithSectionElement:self runtime:runtime];
        NSString *rendering = [(id<GRMustacheSectionTagHelper>)object renderForSectionTagInContext:context];
        if (rendering) {
            [buffer appendString:rendering];
        }
    }
    else if ([object conformsToProtocol:@protocol(GRMustacheSectionHelper)])
    {
        // Deprecated Helper
        
        GRMustacheSection *section = [GRMustacheSection sectionWithSectionElement:self runtime:runtime];
        NSString *rendering = [(id<GRMustacheSectionHelper>)object renderSection:section];
        if (rendering) {
            [buffer appendString:rendering];
        }
    }
    else
    {
        // True object
        
        [self renderInnerElementsInBuffer:buffer withRuntime:runtime];
    }
}

@end
