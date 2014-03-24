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

#import "GRMustacheSectionNode_private.h"

@implementation GRMustacheSectionNode
@synthesize expression=_expression;
@synthesize inverted=_inverted;
@synthesize ASTNodes=_ASTNodes;

- (void)dealloc
{
    [_expression release];
    [_templateString release];
    [_ASTNodes release];
    [super dealloc];
}

+ (instancetype)sectionNodeWithExpression:(GRMustacheExpression *)expression inverted:(BOOL)inverted templateString:(NSString *)templateString innerRange:(NSRange)innerRange ASTNodes:(NSArray *)ASTNodes
{
    return [[[self alloc] initWithExpression:expression inverted:inverted templateString:templateString innerRange:innerRange ASTNodes:ASTNodes] autorelease];
}


- (NSString *)innerTemplateString
{
    return [_templateString substringWithRange:_innerRange];
}


#pragma mark - <GRMustacheASTNode>

- (BOOL)acceptVisitor:(id<GRMustacheASTVisitor>)visitor error:(NSError **)error
{
    return [visitor visitSectionNode:self error:error];
}

- (id<GRMustacheASTNode>)resolveASTNode:(id<GRMustacheASTNode>)ASTNode
{
    return ASTNode;
}


#pragma mark - Private

- (instancetype)initWithExpression:(GRMustacheExpression *)expression inverted:(BOOL)inverted templateString:(NSString *)templateString innerRange:(NSRange)innerRange ASTNodes:(NSArray *)ASTNodes
{
    self = [super init];
    if (self) {
        _expression = [expression retain];
        _inverted = inverted;
        _templateString = [templateString retain];
        _innerRange = innerRange;
        _ASTNodes = [ASTNodes retain];
    }
    return self;
}

@end
