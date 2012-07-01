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

#import "GRMustacheSection_private.h"
#import "GRMustacheContext_private.h"
#import "GRMustacheInvocation_private.h"
#import "GRMustacheHelper_private.h"
#import "GRMustacheRenderingElement_private.h"
#import "GRMustacheTemplate_private.h"

@interface GRMustacheSection()

/**
 * The rendering of Mustache sections depend on the value they are attached to,
 * whether they are truthy, falsey, enumerable, or helpers. The value is fetched
 * by applying this invocation to a rendering context.
 */
@property (nonatomic, retain) GRMustacheInvocation *invocation;

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
 */
@property (nonatomic, retain) NSArray *elems;

/**
 * @see +[GRMustacheSection sectionElementWithInvocation:templateString:innerRange:inverted:elements:]
 */
- (id)initWithInvocation:(GRMustacheInvocation *)invocation templateString:(NSString *)templateString innerRange:(NSRange)innerRange inverted:(BOOL)inverted elements:(NSArray *)elems;
@end


@implementation GRMustacheSection
@synthesize templateString=_templateString;
@synthesize innerRange=_innerRange;
@synthesize invocation=_invocation;
@synthesize inverted=_inverted;
@synthesize elems=_elems;

+ (id)sectionElementWithInvocation:(GRMustacheInvocation *)invocation templateString:(NSString *)templateString innerRange:(NSRange)innerRange inverted:(BOOL)inverted elements:(NSArray *)elems
{
    return [[[self alloc] initWithInvocation:invocation templateString:templateString innerRange:innerRange inverted:inverted elements:elems] autorelease];
}

- (void)dealloc
{
    [_invocation release];
    [_templateString release];
    [_elems release];
    [super dealloc];
}

- (NSString *)innerTemplateString
{
    return [_templateString substringWithRange:_innerRange];
}

- (id)renderingContext
{
    return [[_renderingContext retain] autorelease];
}

- (NSString *)render
{
    NSMutableString *result = [NSMutableString string];
    @autoreleasepool {
        for (id<GRMustacheRenderingElement> elem in _elems) {
            [result appendString:[elem renderContext:_renderingContext inRootTemplate:_rootTemplate]];
        }
    }
    return result;
}

#pragma mark <GRMustacheRenderingElement>

- (NSString *)renderContext:(GRMustacheContext *)context inRootTemplate:(GRMustacheTemplate *)rootTemplate
{
    NSString *result = nil;
    @autoreleasepool {
        
        // invoke
        
        [_invocation invokeWithContext:context];
        if ([rootTemplate.delegate respondsToSelector:@selector(template:willInterpretReturnValueOfInvocation:as:)]) {
            // 4.1 API
            [rootTemplate.delegate template:rootTemplate willInterpretReturnValueOfInvocation:_invocation as:GRMustacheInterpretationSection];
        } else if ([rootTemplate.delegate respondsToSelector:@selector(template:willRenderReturnValueOfInvocation:)]) {
            // 4.0 API
            [rootTemplate.delegate template:rootTemplate willRenderReturnValueOfInvocation:_invocation];
        }
        id value = _invocation.returnValue;
        
        
        // interpret
        
        if (value == nil ||
            value == [NSNull null] ||
            ([value isKindOfClass:[NSNumber class]] && [((NSNumber*)value) boolValue] == NO) ||
            ([value isKindOfClass:[NSString class]] && [((NSString*)value) length] == 0))
        {
            // False value
            if (_inverted) {
                result = [[NSMutableString string] retain];
                for (id<GRMustacheRenderingElement> elem in _elems) {
                    [(NSMutableString *)result appendString:[elem renderContext:context inRootTemplate:rootTemplate]];
                }
            }
        }
        else if ([value isKindOfClass:[NSDictionary class]])
        {
            // True object value
            if (!_inverted) {
                GRMustacheContext *innerContext = [context contextByAddingObject:value];
                result = [[NSMutableString string] retain];
                for (id<GRMustacheRenderingElement> elem in _elems) {
                    [(NSMutableString *)result appendString:[elem renderContext:innerContext inRootTemplate:rootTemplate]];
                }
            }
        }
        else if ([value conformsToProtocol:@protocol(NSFastEnumeration)])
        {
            // Enumerable
            if (_inverted) {
                BOOL empty = YES;
                for (id object in value) {
                    empty = NO;
                    break;
                }
                if (empty) {
                    result = [[NSMutableString string] retain];
                    for (id<GRMustacheRenderingElement> elem in _elems) {
                        [(NSMutableString *)result appendString:[elem renderContext:context inRootTemplate:rootTemplate]];
                    }
                }
            } else {
                result = [[NSMutableString string] retain];
                for (id object in value) {
                    GRMustacheContext *innerContext = [context contextByAddingObject:object];
                    for (id<GRMustacheRenderingElement> elem in _elems) {
                        [(NSMutableString *)result appendString:[elem renderContext:innerContext inRootTemplate:rootTemplate]];
                    }
                }
            }
        }
        else if ([value conformsToProtocol:@protocol(GRMustacheHelper)])
        {
            // Helper
            if (!_inverted) {
                _rootTemplate = rootTemplate;
                _renderingContext = context;
                result = [[(id<GRMustacheHelper>)value renderSection:self] retain];
                _renderingContext = nil;
                _rootTemplate = nil;
            }
        }
        else
        {
            // True object value
            if (!_inverted) {
                GRMustacheContext *innerContext = [context contextByAddingObject:value];
                result = [[NSMutableString string] retain];
                for (id<GRMustacheRenderingElement> elem in _elems) {
                    [(NSMutableString *)result appendString:[elem renderContext:innerContext inRootTemplate:rootTemplate]];
                }
            }
        }
        
        
        // finish
        
        if ([rootTemplate.delegate respondsToSelector:@selector(template:didInterpretReturnValueOfInvocation:as:)]) {
            // 4.1 API
            [rootTemplate.delegate template:rootTemplate didInterpretReturnValueOfInvocation:_invocation as:GRMustacheInterpretationSection];
        } else if ([rootTemplate.delegate respondsToSelector:@selector(template:didRenderReturnValueOfInvocation:)]) {
            // 4.0 API
            [rootTemplate.delegate template:rootTemplate didRenderReturnValueOfInvocation:_invocation];
        }
    }
    if (!result) {
        return @"";
    }
    return [result autorelease];
}


#pragma mark Private

- (id)initWithInvocation:(GRMustacheInvocation *)invocation templateString:(NSString *)templateString innerRange:(NSRange)innerRange inverted:(BOOL)inverted elements:(NSArray *)elems
{
    self = [self init];
    if (self) {
        self.invocation = invocation;
        self.templateString = templateString;
        self.innerRange = innerRange;
        self.inverted = inverted;
        self.elems = elems;
    }
    return self;
}

@end
