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
#import "GRMustacheTokenizer_private.h"
#import "GRMustache_private.h"


@class GRMustacheTemplateParser;
@protocol GRMustacheRenderingElement;


// =============================================================================
#pragma mark - <GRMustacheTemplateParserDataSource>

/**
 The protocol for a GRMustacheTemplateParser's dataSource.
 
 The dataSource's responsability is to provide an object conforming to the
 GRMustacheRenderingElement protocol when the parser meets a partial Mustache tag
 such as {{>name}}.
 
 @see GRMustacheTemplateRepository
 */
@protocol GRMustacheTemplateParserDataSource <NSObject>
@required

/**
 Provided with a partial name, returns an object conforming to the
 GRMustacheRenderingElement protocol.
 
 The implementation can assume that the partial name is not nil, non empty, and non
 blank (not only made of white space characters).
 
 @return A <GRMustacheRenderingElement> instance
 @param templateParser The template parser asking for a rendering element
 @param name The partial name
 @param outError If there is an error loading or parsing the partial, upon return
 contains an NSError object that describes the problem.
 @see [GRMustacheTemplateRepository templateParser:renderingElementForPartialName:error:]
 */
- (id<GRMustacheRenderingElement>)templateParser:(GRMustacheTemplateParser *)templateParser renderingElementForPartialName:(NSString *)name error:(NSError **)outError GRMUSTACHE_API_INTERNAL;
@end


// =============================================================================
#pragma mark - GRMustacheTemplateParser

/**
 The GRMustacheTemplateParser interprets GRMustacheTokens provided by a
 GRMustacheTokenizer, and outputs an array of objects conforming to the
 GRMustacheRenderingElement protocol, the rendering elements of a Mustache
 template.
 */
@interface GRMustacheTemplateParser : NSObject<GRMustacheTokenizerDelegate> {
@private
    NSError *_error;
    NSMutableArray *_elementsStack;
    NSMutableArray *_sectionOpeningTokenStack;
    NSMutableArray *_currentElements;
    GRMustacheToken *_currentSectionOpeningToken;
    id<GRMustacheTemplateParserDataSource> _dataSource;
}

/**
 The parser's dataSource, whose responsability is to provide rendering elements
 for partial tokens such as {{>name}}.
 */
@property (nonatomic, assign) id<GRMustacheTemplateParserDataSource> dataSource GRMUSTACHE_API_INTERNAL;

/**
 Returns an NSArray of objects conforming to the GRMustacheRenderingElement protocol.
 
 The array will contain something if a GRMustacheTokenizer has provided GRMustacheToken
 instances to the parser.
 
 For instance:
 
 @code
 GRMustacheTemplateParser *parser = [[[GRMustacheTemplateParser alloc] init] autorelease];
 GRMustacheTokenizer *tokenizer = [[[GRMustacheTokenizer alloc] init] autorelease];
 tokenizer.delegate = parser;
 [tokenizer parseTemplateString:... templateID:...];
 NSArray *renderingElements = [parser renderingElementsReturningError:NULL];
 @endcode

 @return An NSArray containing <GRMustacheRenderingElement> instances
 @param outError If there is an error building rendering elements, upon return contains
 an NSError object that describes the problem.
*/
- (NSArray *)renderingElementsReturningError:(NSError **)outError GRMUSTACHE_API_INTERNAL;
@end
