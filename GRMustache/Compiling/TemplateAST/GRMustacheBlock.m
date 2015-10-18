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

#import "GRMustacheBlock_private.h"
#import "GRMustacheTemplateASTVisitor_private.h"

@implementation GRMustacheBlock
@synthesize name=_name;
@synthesize innerTemplateAST=_innerTemplateAST;

+ (instancetype)blockWithName:(NSString *)name innerTemplateAST:(GRMustacheTemplateAST *)innerTemplateAST
{
    return [[[self alloc] initWithName:name innerTemplateAST:innerTemplateAST] autorelease];
}

- (void)dealloc
{
    [_name release];
    [_innerTemplateAST release];
    [super dealloc];
}


#pragma mark - <GRMustacheTemplateASTNode>

- (BOOL)acceptTemplateASTVisitor:(id<GRMustacheTemplateASTVisitor>)visitor error:(NSError **)error
{
    return [visitor visitBlock:self error:error];
}

- (id<GRMustacheTemplateASTNode>)resolveTemplateASTNode:(id<GRMustacheTemplateASTNode>)templateASTNode
{
    // {{$ name }}...{{/ name }}
    //
    // A block is overriden by another block with the same name:
    
    if (![templateASTNode isKindOfClass:[GRMustacheBlock class]]) {
        return templateASTNode;
    }
    
    if (![((GRMustacheBlock *)templateASTNode).name isEqualToString:_name]) {
        return templateASTNode;
    }
    
    return self;
}


#pragma mark - Private

- (instancetype)initWithName:(NSString *)name innerTemplateAST:(GRMustacheTemplateAST *)innerTemplateAST
{
    self = [self init];
    if (self) {
        _name = [name retain];
        _innerTemplateAST = [innerTemplateAST retain];
    }
    return self;
}

@end
