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


// =============================================================================
#pragma mark - GRMustacheSectionTag

@interface GRMustacheSectionTag : GRMustacheTag {
@private
    GRMustacheSectionNode *_ASTNode;
}
- (instancetype)initWithSectionNode:(GRMustacheSectionNode *)ASTNode;
@end

// =============================================================================
#pragma mark - GRMustacheVariableTag

@interface GRMustacheVariableTag : GRMustacheTag {
@private
    GRMustacheVariableNode *_ASTNode;
}
- (instancetype)initWithVariableNode:(GRMustacheVariableNode *)ASTNode;
@end

// =============================================================================
#pragma mark - GRMustacheTag

@implementation GRMustacheTag

+ (instancetype)tagWithSectionNode:(GRMustacheSectionNode *)ASTNode
{
    return [[[GRMustacheSectionTag alloc] initWithSectionNode:ASTNode] autorelease];
}

+ (instancetype)tagWithVariableNode:(GRMustacheVariableNode *)ASTNode
{
    return [[[GRMustacheVariableTag alloc] initWithVariableNode:ASTNode] autorelease];
}

- (GRMustacheTagType)type
{
    [self doesNotRecognizeSelector:_cmd];
    return 0;
}

- (GRMustacheTemplateRepository *)templateRepository
{
    return [GRMustacheRendering currentTemplateRepository];
}

- (NSString *)innerTemplateString
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (NSString *)renderContentWithContext:(GRMustacheContext *)context HTMLSafe:(BOOL *)HTMLSafe error:(NSError **)error
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

@end

// =============================================================================
#pragma mark - GRMustacheSectionTag

@implementation GRMustacheSectionTag

- (void)dealloc
{
    [_ASTNode release];
    [super dealloc];
}

- (instancetype)initWithSectionNode:(GRMustacheSectionNode *)ASTNode
{
    self = [super init];
    if (self) {
        _ASTNode = [ASTNode retain];
    }
    return self;
}

- (NSString *)description
{
    GRMustacheToken *token = _ASTNode.expression.token;
    if (token.templateID) {
        return [NSString stringWithFormat:@"<%@ `%@` at line %lu of template %@>", [self class], token.templateSubstring, (unsigned long)token.line, token.templateID];
    } else {
        return [NSString stringWithFormat:@"<%@ `%@` at line %lu>", [self class], token.templateSubstring, (unsigned long)token.line];
    }
}

- (GRMustacheTagType)type
{
    if (_ASTNode.isInverted) {
        return GRMustacheTagTypeInvertedSection;
    }
    return GRMustacheTagTypeSection;
}

- (NSString *)innerTemplateString
{
    return [_ASTNode innerTemplateString];
}

- (NSString *)renderContentWithContext:(GRMustacheContext *)context HTMLSafe:(BOOL *)HTMLSafe error:(NSError **)error
{
    GRMustacheRenderingASTVisitor *visitor = [[[GRMustacheRenderingASTVisitor alloc] initWithContentType:[GRMustacheRendering currentContentType] context:context] autorelease];
    if (![visitor visitContentOfSectionNode:_ASTNode error:error]) {
        return nil;
    }
    return [visitor renderingWithHTMLSafe:HTMLSafe error:error];
}

@end

// =============================================================================
#pragma mark - GRMustacheVariableTag

@implementation GRMustacheVariableTag

- (void)dealloc
{
    [_ASTNode release];
    [super dealloc];
}

- (instancetype)initWithVariableNode:(GRMustacheVariableNode *)ASTNode
{
    self = [super init];
    if (self) {
        _ASTNode = [ASTNode retain];
    }
    return self;
}

- (NSString *)description
{
    GRMustacheToken *token = _ASTNode.expression.token;
    if (token.templateID) {
        return [NSString stringWithFormat:@"<%@ `%@` at line %lu of template %@>", [self class], token.templateSubstring, (unsigned long)token.line, token.templateID];
    } else {
        return [NSString stringWithFormat:@"<%@ `%@` at line %lu>", [self class], token.templateSubstring, (unsigned long)token.line];
    }
}

- (GRMustacheTagType)type
{
    return GRMustacheTagTypeVariable;
}

- (NSString *)innerTemplateString
{
    return @"";
}

- (NSString *)renderContentWithContext:(GRMustacheContext *)context HTMLSafe:(BOOL *)HTMLSafe error:(NSError **)error
{
    if (HTMLSafe) {
        *HTMLSafe = ([GRMustacheRendering currentContentType] == GRMustacheContentTypeHTML);
    }
    return @"";
}

@end

