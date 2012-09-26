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
#import "GRMustacheAvailabilityMacros_private.h"
#import "GRMustacheParser_private.h"
#import "GRMustache_private.h"


@class GRMustacheCompiler;
@class GRMustacheTemplateRepository;
@protocol GRMustacheRenderingElement;


/**
 * The GRMustacheCompiler interprets GRMustacheTokens provided by a
 * GRMustacheParser, and outputs a syntax tree of objects conforming to the
 * GRMustacheRenderingElement protocol, the rendering elements that make a
 * Mustache template.
 * 
 * @see GRMustacheRenderingElement
 * @see GRMustacheToken
 * @see GRMustacheParser
 */
@interface GRMustacheCompiler : NSObject<GRMustacheParserDelegate> {
@private
    NSError *_fatalError;
    NSMutableArray *_elementsStack;
    NSMutableArray *_openingTokenStack;
    NSMutableArray *_currentElements;
    GRMustacheToken *_currentOpeningToken;
    GRMustacheTemplateRepository *_templateRepository;
}

/**
 * The template repository that:
 * - provides partial templates to the compiler.
 * - allows helpers to render alternate template strings that contain partials.
 * 
 * @see GRMustacheTemplateRepository
 * @see GRMustacheSectionTagRenderingContext
 */
@property (nonatomic, assign) GRMustacheTemplateRepository *templateRepository GRMUSTACHE_API_INTERNAL;

/**
 * Returns an NSArray of objects conforming to the GRMustacheRenderingElement
 * protocol.
 * 
 * The array will contain something if a GRMustacheParser has provided
 * GRMustacheToken instances to the compiler.
 * 
 * For instance:
 * 
 *     // Create a Mustache compiler
 *     GRMustacheCompiler *compiler = [[[GRMustacheCompiler alloc] init] autorelease];
 *     
 *     // Some GRMustacheCompilerDataSource tells the compiler where are the
 *     // partials.
 *     compiler.dataSource = ...;
 *     
 *     // Create a Mustache parser
 *     GRMustacheParser *parser = [[[GRMustacheParser alloc] init] autorelease];
 *     
 *     // The parser feeds the compiler
 *     parser.delegate = compiler;
 *     
 *     // Parse some string
 *     [parser parseTemplateString:... templateID:...];
 *     
 *     // Extract rendering elements from the compiler
 *     NSArray *renderingElements = [compiler renderingElementsReturningError:...];
 *
 * @param outError  If there is an error building rendering elements, upon
 *                  return contains an NSError object that describes the
 *                  problem.
 *
 * @return An NSArray containing <GRMustacheRenderingElement> instances
 * 
 * @see GRMustacheRenderingElement
 */
- (NSArray *)renderingElementsReturningError:(NSError **)outError GRMUSTACHE_API_INTERNAL;
@end
