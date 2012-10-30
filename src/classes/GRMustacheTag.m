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

#import <Foundation/Foundation.h>
#import "GRMustacheTag_private.h"
#import "GRMustacheExpression_private.h"
#import "GRMustacheToken_private.h"
#import "GRMustacheContext_private.h"
#import "GRMustache_private.h"
#import "GRMustacheRendering.h"

@interface GRMustacheTag()
- (NSString *)escapeHTML:(NSString *)string;
@end

@implementation GRMustacheTag
@synthesize expression=_expression;
@synthesize templateRepository=_templateRepository;

- (void)dealloc
{
    [_expression release];
    [super dealloc];
}

- (id)initWithTemplateRepository:(GRMustacheTemplateRepository *)templateRepository expression:(GRMustacheExpression *)expression
{
    self = [super init];
    if (self) {
        _templateRepository = templateRepository;   // do not retain, since templateRepository retains the template that retains self.
        _expression = [expression retain];
    }
    return self;
}

- (NSString *)description
{
    GRMustacheToken *token = _expression.token;
    if (token.templateID) {
        return [NSString stringWithFormat:@"<%@ `%@` at line %lu of template %@>", [self class], token.templateSubstring, (unsigned long)token.line, token.templateID];
    } else {
        return [NSString stringWithFormat:@"<%@ `%@` at line %lu>", [self class], token.templateSubstring, (unsigned long)token.line];
    }
}

- (GRMustacheTagType)type
{
    NSAssert(NO, @"Subclasses must override");
    return 0;
}

- (BOOL)escapesHTML
{
    // default
    return YES;
}

- (NSString *)innerTemplateString
{
    // default
    return @"";
}

- (NSString *)renderContentWithContext:(GRMustacheContext *)context HTMLSafe:(BOOL *)HTMLSafe error:(NSError **)error
{
    // default
    if (HTMLSafe) {
        *HTMLSafe = YES;
    }
    return @"";
}


#pragma mark - <GRMustacheTemplateComponent>

- (BOOL)renderWithContext:(GRMustacheContext *)context inBuffer:(NSMutableString *)buffer error:(NSError **)error
{
    BOOL success = YES;
    
    @autoreleasepool {
        
        // 1. Evaluate expression
        
        id object;
        if (![_expression evaluateInContext:context value:&object error:error]) {
            return NO;
        }
        
        
        // 2. Let tagDelegates observe and alter the object
        
        for (id<GRMustacheTagDelegate> delegate in [context.delegateStack reverseObjectEnumerator]) {
            if ([delegate respondsToSelector:@selector(mustacheTag:willRenderObject:)]) {
                object = [delegate mustacheTag:self willRenderObject:object];
            }
        }
        
        
        // 3. Render
    
        id<GRMustacheRendering> renderingObject = [GRMustache renderingObjectForObject:object];
        BOOL HTMLSafe = NO;
        NSError *renderingError = nil;
        NSString *rendering = [renderingObject renderForMustacheTag:self context:context HTMLSafe:&HTMLSafe error:&renderingError];
        
        if (rendering) {
            if (rendering.length > 0) {
                if (self.escapesHTML && !HTMLSafe) {
                    rendering = [self escapeHTML:rendering];
                }
                [buffer appendString:rendering];
            }
        } else if (renderingError) {
            // If rendering is nil, but rendering error is not set,
            // assume lazy coder, and the intention to render nothing:
            // Fail if and only if renderingError is explicitely set.
            if (error) {
                *error = [renderingError retain];   // retain error so that it survives the @autoreleasepool block
            }
            success = NO;
        }
        
        
        // 4. tagDelegates clean up
        
        if (success) {
            for (id<GRMustacheTagDelegate> delegate in [context.delegateStack reverseObjectEnumerator]) {
                if ([delegate respondsToSelector:@selector(mustacheTag:didRenderObject:as:)]) {
                    [delegate mustacheTag:self didRenderObject:object as:rendering];
                }
            }
        } else {
            for (id<GRMustacheTagDelegate> delegate in [context.delegateStack reverseObjectEnumerator]) {
                if ([delegate respondsToSelector:@selector(mustacheTag:didFailRenderingObject:withError:)]) {
                    [delegate mustacheTag:self didFailRenderingObject:object withError:renderingError];
                }
            }
        }
    }
    
    if (!success && error) [*error autorelease];    // the error has been retained inside the @autoreleasepool block
    return success;
}

- (id<GRMustacheTemplateComponent>)resolveTemplateComponent:(id<GRMustacheTemplateComponent>)component
{
    // Only overridable tags can override components
    if (self.type != GRMustacheTagTypeOverridableSection) {
        return component;
    }
    
    // Overridable tags can only override other tags
    if (![component isKindOfClass:[GRMustacheTag class]]) {
        return component;
    }
    GRMustacheTag *otherTag = (GRMustacheTag *)component;
    
    // Overridable tags can only override other overridable tags
    if (otherTag.type != GRMustacheTagTypeOverridableSection) {
        return otherTag;
    }
    
    // Overridable tags can only override other sections with the same expression
    if (![otherTag.expression isEqual:_expression]) {
        return otherTag;
    }
    
    // OK, override otherTag with self
    return [otherTag tagWithOverridingTag:self];
}

- (GRMustacheTag *)tagWithOverridingTag:(GRMustacheTag *)overridingTag
{
    // default: overridingTag replaces self
    return overridingTag;
}


#pragma mark - Private

- (NSString *)escapeHTML:(NSString *)string
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
