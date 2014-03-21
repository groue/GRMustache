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
#import "GRMustacheAvailabilityMacros_private.h"
#import "GRMustacheASTNode_private.h"


/**
 * A GRMustacheInheritableSection is an AST node that represents inheritable
 * sections as `{{$name}}...{{/name}}`.
 */
@interface GRMustacheInheritableSection : NSObject<GRMustacheASTNode> {
@private
    NSString *_identifier;
    NSArray *_ASTNodes;
}

@property (nonatomic, retain, readonly) NSArray *ASTNodes GRMUSTACHE_API_INTERNAL;

/**
 * Returns a new inheritable section.
 *
 * @param identifier  The identifier of the inheritable section
 * @param ASTNodes    Array of GRMustacheASTNode objects
 *
 * @return a new GRMustacheInheritableSection.
 *
 * @see GRMustacheASTNode
 */
+ (instancetype)inheritableSectionWithIdentifier:(NSString *)identifier ASTNodes:(NSArray *)ASTNodes GRMUSTACHE_API_INTERNAL;
@end
