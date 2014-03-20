// The MIT License
//
// Copyright (c) 2014 Gwendal Roué
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
#import "GRMustacheRendering_private.h"
#import "GRMustacheASTVisitor_private.h"


@implementation GRMustacheTag
@synthesize type=_type;
@synthesize expression=_expression;
@synthesize contentType=_contentType;

- (void)dealloc
{
    [_expression release];
    [super dealloc];
}

- (id)initWithType:(GRMustacheTagType)type expression:(GRMustacheExpression *)expression contentType:(GRMustacheContentType)contentType
{
    self = [super init];
    if (self) {
        _type = type;
        _expression = [expression retain];
        _contentType = contentType;
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

- (BOOL)escapesHTML
{
    // Default YES.
    // This method is overrided by GRMustacheVariableTag,
    // and sets the difference between {{name}} and {{{name}}} tags.
    return YES;
}

- (NSString *)innerTemplateString
{
    // Default empty string.
    // This method is overrided by GRMustacheSectionTag,
    // which returns the content of the section.
    return @"";
}

- (NSString *)renderContentWithContext:(GRMustacheContext *)context HTMLSafe:(BOOL *)HTMLSafe error:(NSError **)error
{
    // Default empty string.
    // This method is overrided by GRMustacheSectionTag.
    if (HTMLSafe) {
        *HTMLSafe = (_contentType == GRMustacheContentTypeHTML);
    }
    return @"";
}

- (GRMustacheTemplateRepository *)templateRepository
{
    return [GRMustacheRendering currentTemplateRepository];
}


#pragma mark - <GRMustacheASTNode>

- (BOOL)acceptVisitor:(id<GRMustacheASTVisitor>)visitor error:(NSError **)error
{
    return [visitor visitTag:self error:error];
}

- (id<GRMustacheASTNode>)resolveASTNode:(id<GRMustacheASTNode>)ASTNode
{
    return ASTNode;
}

@end
