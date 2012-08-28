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

@interface GRMustacheVariableElement()
@property (nonatomic, retain) id<GRMustacheExpression> expression;
@property (nonatomic) BOOL raw;
- (id)initWithExpression:(id<GRMustacheExpression>)expression raw:(BOOL)raw;
- (NSString *)htmlEscape:(NSString *)string;
@end


@implementation GRMustacheVariableElement
@synthesize expression=_expression;
@synthesize raw=_raw;

+ (id)variableElementWithExpression:(id<GRMustacheExpression>)expression raw:(BOOL)raw
{
    return [[[self alloc] initWithExpression:expression raw:raw] autorelease];
}

- (void)dealloc
{
    [_expression release];
    [super dealloc];
}


#pragma mark <GRMustacheRenderingElement>

- (NSString *)renderInRuntime:(GRMustacheRuntime *)runtime
{
    __block NSString *result = nil;
    
    // evaluate
    
    [_expression evaluateInRuntime:runtime forInterpretation:GRMustacheInterpretationContextValue|GRMustacheInterpretationVariableRendering usingBlock:^(id object) {
        
        // interpret
        
        if (object && (object != [NSNull null])) {
            result = [object description];
            if (!_raw) {
                result = [self htmlEscape:result];
            }
        }
    }];
    
    // finish
    
    if (!result) {
        result = @"";
    }
    return result;
}


#pragma mark Private

- (id)initWithExpression:(id<GRMustacheExpression>)expression raw:(BOOL)raw
{
    self = [self init];
    if (self) {
        self.expression = expression;
        self.raw = raw;
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
