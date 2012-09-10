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
 * The rendering of Mustache sections depend on the object they are attached to,
 * whether they are truthy, falsey, enumerable, or helpers. The object is
 * fetched by applying this expression to a rendering context.
 */
@property (nonatomic, retain) GRMustacheExpression *expression;

/**
 * The template string containing the inner template string of the section.
 */
@property (nonatomic, retain) NSString *templateString;

/**
 * The range of the inner template string of the section in `templateString`.
 */
@property (nonatomic) NSRange innerRange;

/**
 * YES if the section is {{^inverted}}; otherwise, NO.
 */
@property (nonatomic) BOOL inverted;

/**
 * The GRMustacheRenderingElement objects that make the section.
 * 
 * @see GRMustacheRenderingElement
 */
@property (nonatomic, retain) NSArray *elems;

/**
 * @see +[GRMustacheSectionElement sectionElementWithExpression:templateString:innerRange:inverted:elements:]
 */
- (id)initWithExpression:(GRMustacheExpression *)expression templateString:(NSString *)templateString innerRange:(NSRange)innerRange inverted:(BOOL)inverted elements:(NSArray *)elems;
@end


@implementation GRMustacheSectionElement
@synthesize templateString=_templateString;
@synthesize innerRange=_innerRange;
@synthesize expression=_expression;
@synthesize inverted=_inverted;
@synthesize elems=_elems;

+ (id)sectionElementWithExpression:(GRMustacheExpression *)expression templateString:(NSString *)templateString innerRange:(NSRange)innerRange inverted:(BOOL)inverted elements:(NSArray *)elems
{
    return [[[self alloc] initWithExpression:expression templateString:templateString innerRange:innerRange inverted:inverted elements:elems] autorelease];
}

- (void)dealloc
{
    [_expression release];
    [_templateString release];
    [_elems release];
    [super dealloc];
}

- (NSString *)innerTemplateString
{
    return [_templateString substringWithRange:_innerRange];
}

- (NSString *)renderElementsInRuntime:(GRMustacheRuntime *)runtime
{
    NSMutableString *result = [NSMutableString string];
    @autoreleasepool {
        for (id<GRMustacheRenderingElement> elem in _elems) {
            [result appendString:[elem renderInRuntime:runtime]];
        }
    }
    return result;
}

#pragma mark <GRMustacheRenderingElement>

- (NSString *)renderInRuntime:(GRMustacheRuntime *)runtime
{
    __block NSString *result = nil;
    @autoreleasepool {
        
        [runtime interpretExpression:_expression as:GRMustacheInterpretationSection usingBlock:^(id value) {
            
            GRMustacheRuntime *sectionRuntime = runtime;
            
            // Values that conform to the GRMustacheTemplateDelegate protocol
            // enter the section runtime.
            
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
                    result = [[self renderElementsInRuntime:sectionRuntime] retain];
                }
            }
            else if ([value isKindOfClass:[NSDictionary class]])
            {
                // True value
                if (!_inverted) {
                    sectionRuntime = [sectionRuntime runtimeByAddingContextObject:value];
                    result = [[self renderElementsInRuntime:sectionRuntime] retain];
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
                        result = [[self renderElementsInRuntime:sectionRuntime] retain];
                    }
                } else {
                    result = [[NSMutableString string] retain];
                    for (id item in value) {
                        GRMustacheRuntime *itemRuntime = [sectionRuntime runtimeByAddingContextObject:item];
                        NSString *itemRendering = [self renderElementsInRuntime:itemRuntime];
                        [(NSMutableString *)result appendString:itemRendering];
                    }
                }
            }
            else if ([value conformsToProtocol:@protocol(GRMustacheHelper)])
            {
                // Helper
                if (!_inverted) {
                    GRMustacheSection *section = [GRMustacheSection sectionWithSectionElement:self runtime:sectionRuntime];
                    result = [[(id<GRMustacheHelper>)value renderSection:section] retain];
                }
            }
            else
            {
                // True value
                if (!_inverted) {
                    sectionRuntime = [sectionRuntime runtimeByAddingContextObject:value];
                    result = [[self renderElementsInRuntime:sectionRuntime] retain];
                }
            }
        }];
    }
    if (!result) {
        return @"";
    }
    return [result autorelease];
}


#pragma mark Private

- (id)initWithExpression:(GRMustacheExpression *)expression templateString:(NSString *)templateString innerRange:(NSRange)innerRange inverted:(BOOL)inverted elements:(NSArray *)elems
{
    self = [self init];
    if (self) {
        self.expression = expression;
        self.templateString = templateString;
        self.innerRange = innerRange;
        self.inverted = inverted;
        self.elems = elems;
    }
    return self;
}

@end
