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
#import "GRMustacheToken_private.h"


@class GRMustacheTokenizer;


// =============================================================================
#pragma mark - <GRMustacheTokenizerDelegate>

/**
 The protocol for the delegate of a GRMustacheTokenizer.
 
 The delegate's responsability is to consume tokens and handle tokenizer errors.
 
 @see GRMustacheTemplateParser
 */
@protocol GRMustacheTokenizerDelegate<NSObject>
@optional

/**
 Sent after the tokenizer has parsed a token.
 
 @return YES if the tokenizer should continue producing tokens; otherwise, NO.
 @param tokenizer The tokenizer that did find a token.
 @param token The token
 
 @see GRMustacheToken
 */
- (BOOL)tokenizer:(GRMustacheTokenizer *)tokenizer shouldContinueAfterParsingToken:(GRMustacheToken *)token GRMUSTACHE_API_INTERNAL;

/**
 Sent after the token has failed.
 
 @param tokenizer The tokenizer that failed to producing tokens.
 @param error The error that occurred.
 */
- (void)tokenizer:(GRMustacheTokenizer *)tokenizer didFailWithError:(NSError *)error GRMUSTACHE_API_INTERNAL;
@end


// =============================================================================
#pragma mark - GRMustacheTokenizer

/**
 The GRMustacheTokenizer consumes a Mustache template string, and produces tokens.
 
 Those tokens are consumed by the tokenizer's delegate.
 
 @see GRMustacheToken
 @see GRMustacheTokenizerDelegate
 */
@interface GRMustacheTokenizer : NSObject {
@private
    id<GRMustacheTokenizerDelegate> _delegate;
    NSString *_otag;
    NSString *_ctag;
}

/**
 The tokenizer's delegate.
 
 The delegate is sent messages as the tokenizer interprets a Mustache template string.
 
 @see GRMustacheTokenizerDelegate
 */
@property (nonatomic, assign) id<GRMustacheTokenizerDelegate> delegate GRMUSTACHE_API_INTERNAL;

/**
 The tokenizer will invoke its delegate as it builds tokens from the template string.
 
 @param templateString A Mustache template string
 @param templateID A template ID (see GRMustacheTemplateRepository)
 */
- (void)parseTemplateString:(NSString *)templateString templateID:(id)templateID GRMUSTACHE_API_INTERNAL;
@end
