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

#if __has_feature(objc_arc)
#error Manual Reference Counting required: use -fno-objc-arc.
#endif

#import "GRMustachePartialNode_private.h"
#import "GRMustacheTemplateAST_private.h"
#import "GRMustacheTemplateASTVisitor_private.h"


@implementation GRMustachePartialNode

- (void)dealloc
{
    [_templateAST release];
    [_name release];
    [super dealloc];
}

+ (instancetype)partialNodeWithTemplateAST:(GRMustacheTemplateAST *)templateAST name:(NSString *)name
{
    return [[[self alloc] initWithTemplateAST:templateAST name:name] autorelease];
}

#pragma mark <GRMustacheTemplateASTNode>

- (BOOL)acceptTemplateASTVisitor:(id<GRMustacheTemplateASTVisitor>)visitor error:(NSError **)error
{
    return [visitor visitPartialNode:self error:error];
}

- (id<GRMustacheTemplateASTNode>)resolveTemplateASTNode:(id<GRMustacheTemplateASTNode>)templateASTNode
{
    // {{> partial }}
    //
    // Relevant test:
    //
    // {
    //   "name": "Partials in partial overrides can override blocks",
    //   "data": { },
    //   "template": "{{<partial2}}{{>partial1}}{{/partial2}}",
    //   "partials": {
    //       "partial1": "{{$inheritable}}partial1{{/inheritable}}",
    //       "partial2": "{{$inheritable}}ignored{{/inheritable}}" },
    //   "expected": "partial1"
    // },
    for (id<GRMustacheTemplateASTNode> overridingNode in _templateAST.templateASTNodes) {
        templateASTNode = [overridingNode resolveTemplateASTNode:templateASTNode];
    }
    return templateASTNode;
}

#pragma mark - Private

- (instancetype)initWithTemplateAST:(GRMustacheTemplateAST *)templateAST name:(NSString *)name
{
    self = [self init];
    if (self) {
        _templateAST = [templateAST retain];
        _name = [name retain];
    }
    return self;
}

@end
