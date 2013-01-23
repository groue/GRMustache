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

#import "GRMustacheVariableTag_private.h"
#import "GRMustacheExpression_private.h"
#import "GRMustacheTemplate_private.h"
#import "GRMustacheContext_private.h"
#import "GRMustacheSectionTag_private.h"
#import "GRMustacheImplicitIteratorExpression_private.h"
#import "GRMustacheRendering.h"
#import "GRMustache_private.h"

@interface GRMustacheVariableTag()
- (id)initWithTemplateRepository:(GRMustacheTemplateRepository *)templateRepository expression:(GRMustacheExpression *)expression HTMLSafe:(BOOL)HTMLSafe escapesHTML:(BOOL)escapesHTML;
@end


@implementation GRMustacheVariableTag

+ (id)variableTagWithTemplateRepository:(GRMustacheTemplateRepository *)templateRepository expression:(GRMustacheExpression *)expression HTMLSafe:(BOOL)HTMLSafe escapesHTML:(BOOL)escapesHTML
{
    return [[[self alloc] initWithTemplateRepository:templateRepository expression:expression HTMLSafe:HTMLSafe escapesHTML:escapesHTML] autorelease];
}


#pragma mark - GRMustacheTag

@synthesize escapesHTML=_escapesHTML;

- (GRMustacheTagType)type
{
    return GRMustacheTagTypeVariable;
}


#pragma mark - Private

- (id)initWithTemplateRepository:(GRMustacheTemplateRepository *)templateRepository expression:(GRMustacheExpression *)expression HTMLSafe:(BOOL)HTMLSafe escapesHTML:(BOOL)escapesHTML
{
    self = [super initWithTemplateRepository:templateRepository expression:expression HTMLSafe:HTMLSafe];
    if (self) {
        _escapesHTML = escapesHTML;
    }
    return self;
}

@end
