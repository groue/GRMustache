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

- (NSString *)renderWithContext:(GRMustacheContext *)context HTMLSafe:(BOOL *)HTMLSafe error:(NSError **)error
{
    NSAssert(NO, @"Subclasses must override");
    return @"";
}

@end
