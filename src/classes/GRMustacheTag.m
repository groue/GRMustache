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

- (GRMustacheTagType)type
{
    NSAssert(NO, @"Subclasses must override");
    return 0;
}

- (BOOL)escapesHTML
{
    NSAssert(NO, @"Subclasses must override");
    return YES;
}

- (NSString *)innerTemplateString
{
    return nil;
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

- (NSString *)renderContext:(GRMustacheContext *)context HTMLSafe:(BOOL *)HTMLSafe error:(NSError **)error
{
    NSAssert(NO, @"Subclasses must override");
    return @"";
}


#pragma mark - <GRMustacheTemplateComponent>

- (BOOL)renderContext:(GRMustacheContext *)context inBuffer:(NSMutableString *)buffer error:(NSError **)error
{
    id object;
    if (![_expression evaluateInContext:context value:&object error:error]) {
        return NO;
    }
    
    __block BOOL success = YES;
    [context renderObject:object withTag:self usingBlock:^(id object){
        
        id<GRMustacheRendering> renderingObject = [GRMustache renderingObjectForObject:object];
        
        BOOL HTMLSafe = NO;
        NSError *renderingError = nil;
        NSString *rendering = [renderingObject renderForMustacheTag:self context:context HTMLSafe:&HTMLSafe error:&renderingError];
        
        if (rendering) {
            if (self.escapesHTML && !HTMLSafe) {
                rendering = [self escapeHTML:rendering];
            }
            [buffer appendString:rendering];
        } else if (renderingError) {
            // If rendering is nil, but rendering error is not set,
            // assume lazy coder, and the intention to render nothing:
            // Fail if and only if renderingError is explicitely set.
            if (error) {
                *error = renderingError;
            }
            success = NO;
        }
    }];
    
    return success;
}

- (id<GRMustacheTemplateComponent>)resolveTemplateComponent:(id<GRMustacheTemplateComponent>)component
{
    // default implementation does not override any other component
    return component;
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
