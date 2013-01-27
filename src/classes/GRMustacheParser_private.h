// The MIT License
// 
// Copyright (c) 2013 Gwendal Roué
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
#import "GRMustacheToken_private.h"


@class GRMustacheParser;


// =============================================================================
#pragma mark - <GRMustacheParserDelegate>

/**
 * The protocol for the delegate of a GRMustacheParser.
 * 
 * The delegate's responsability is to consume tokens and handle parser
 * errors.
 * 
 * @see GRMustacheCompiler
 */
@protocol GRMustacheParserDelegate<NSObject>
@optional

/**
 * Sent after the parser has parsed a token.
 * 
 * @param parser   The parser that did find a token.
 * @param token       The token
 *
 * @return YES if the parser should continue producing tokens; otherwise, NO.
 * 
 * @see GRMustacheToken
 */
- (BOOL)parser:(GRMustacheParser *)parser shouldContinueAfterParsingToken:(GRMustacheToken *)token GRMUSTACHE_API_INTERNAL;

/**
 * Sent after the token has failed.
 * 
 * @param parser   The parser that failed to producing tokens.
 * @param error       The error that occurred.
 */
- (void)parser:(GRMustacheParser *)parser didFailWithError:(NSError *)error GRMUSTACHE_API_INTERNAL;
@end


// =============================================================================
#pragma mark - GRMustacheParser

/**
 * The GRMustacheParser consumes a Mustache template string, and produces
 * tokens.
 * 
 * Those tokens are consumed by the parser's delegate.
 * 
 * @see GRMustacheToken
 * @see GRMustacheParserDelegate
 */
@interface GRMustacheParser : NSObject {
@private
    id<GRMustacheParserDelegate> _delegate;
    NSString *_otag;
    NSString *_ctag;
    NSMutableSet *_pragmas;
}

/**
 * The parser's delegate.
 * 
 * The delegate is sent messages as the parser interprets a Mustache template
 * string.
 * 
 * @see GRMustacheParserDelegate
 */
@property (nonatomic, assign) id<GRMustacheParserDelegate> delegate GRMUSTACHE_API_INTERNAL;

/**
 * A set of all pragmas found while parsing. Pragmas are defined via pragma tags
 * such as `{{% FILTERS }}`.
 */
@property (nonatomic, strong, readonly) NSMutableSet *pragmas GRMUSTACHE_API_INTERNAL;

/**
 * The parser will invoke its delegate as it builds tokens from the template
 * string.
 * 
 * @param templateString  A Mustache template string
 * @param templateID      A template ID (see GRMustacheTemplateRepository)
 */
- (void)parseTemplateString:(NSString *)templateString templateID:(id)templateID GRMUSTACHE_API_INTERNAL;

/**
 * Returns an expression from a string.
 *
 * @param string        A string.
 * @param outInvalid    If the string contains an invalid expression, upon
 *                      return contains YES.
 *
 * @return An expression, or nil if the parsing fails or if the expression is
 * empty.
 */
+ (GRMustacheExpression *)parseExpression:(NSString *)string invalid:(BOOL *)outInvalid GRMUSTACHE_API_INTERNAL;

@end
