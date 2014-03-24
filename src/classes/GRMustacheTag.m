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
#import "GRMustacheRendering_private.h"
#import "GRMustacheToken_private.h"
#import "GRMustacheSectionNode_private.h"
#import "GRMustacheVariableNode_private.h"
#import "GRMustacheRenderingASTVisitor_private.h"


@implementation GRMustacheTag
@synthesize ASTNode=_ASTNode;

- (void)dealloc
{
    [_ASTNode release];
    [super dealloc];
}

- (NSString *)description
{
    GRMustacheToken *token = self.ASTNode.expression.token;
    if (token.templateID) {
        return [NSString stringWithFormat:@"<%@ `%@` at line %lu of template %@>", [self class], token.templateSubstring, (unsigned long)token.line, token.templateID];
    } else {
        return [NSString stringWithFormat:@"<%@ `%@` at line %lu>", [self class], token.templateSubstring, (unsigned long)token.line];
    }
}

- (GRMustacheTagType)type
{
    if ([_ASTNode isKindOfClass:[GRMustacheSectionNode class]]) {
        if ([(GRMustacheSectionNode *)_ASTNode isInverted]) {
            return GRMustacheTagTypeInvertedSection;
        }
        return GRMustacheTagTypeSection;
    }
    return GRMustacheTagTypeVariable;
}

- (GRMustacheTemplateRepository *)templateRepository
{
    return [GRMustacheRendering currentTemplateRepository];
}

- (NSString *)innerTemplateString
{
    if ([_ASTNode isKindOfClass:[GRMustacheSectionNode class]]) {
        return [(GRMustacheSectionNode *)_ASTNode innerTemplateString];
    }
    return @"";
}

- (GRMustacheExpression *)expression
{
    return _ASTNode.expression;
}

- (BOOL)escapesHTML
{
    if ([_ASTNode isKindOfClass:[GRMustacheVariableNode class]]) {
        return [(GRMustacheVariableNode *)_ASTNode escapesHTML];
    }
    return YES;
}

- (NSString *)renderContentWithContext:(GRMustacheContext *)context HTMLSafe:(BOOL *)HTMLSafe error:(NSError **)error
{
    if ([_ASTNode isKindOfClass:[GRMustacheSectionNode class]]) {
        GRMustacheRenderingASTVisitor *visitor = [[[GRMustacheRenderingASTVisitor alloc] initWithContentType:[GRMustacheRendering currentContentType] context:context] autorelease];
        return [visitor renderContentOfSectionNode:_ASTNode HTMLSafe:HTMLSafe error:error];
    }
    if (HTMLSafe) {
        *HTMLSafe = ([GRMustacheRendering currentContentType] == GRMustacheContentTypeHTML);
    }
    return @"";
}

@end
