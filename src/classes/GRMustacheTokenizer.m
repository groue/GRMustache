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

#import "GRMustacheTokenizer_private.h"
#import "GRMustacheError.h"

@interface GRMustacheTokenizer()
@property (nonatomic, copy) NSString *otag;
@property (nonatomic, copy) NSString *ctag;
- (BOOL)shouldContinueAfterParsingToken:(GRMustacheToken *)token;
- (void)didFinish;
- (void)didFinishWithParseErrorAtLine:(NSInteger)line description:(NSString *)description templateID:(id)templateID;
- (NSRange)rangeOfString:(NSString *)string inTemplateString:(NSString *)templateString startingAtIndex:(NSUInteger)p consumedNewLines:(NSUInteger *)outLines;
@end

@implementation GRMustacheTokenizer
@synthesize delegate=_delegate;
@synthesize otag=_otag;
@synthesize ctag=_ctag;

- (id)init
{
    self = [super init];
    if (self) {
        _otag = [@"{{" retain]; // static strings don't need retain, but static ananlyser may complain :-)
        _ctag = [@"}}" retain];
    }
    return self;
}

- (void)dealloc
{
    [_otag release];
    [_ctag release];
    [super dealloc];
}

- (void)parseTemplateString:(NSString *)templateString templateID:(id)templateID
{
    NSUInteger length = templateString.length;
    if (length == 0) {
        [self didFinish];
        return;
    }
    
    NSRange p = [templateString rangeOfComposedCharacterSequenceAtIndex:0];
    NSUInteger line = 1;
    NSUInteger consumedLines = 0;
    NSRange orange;
    NSRange crange;
    NSString *tag;
    NSCharacterSet *whitespaceCharacterSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *tokenContent;
    GRMustacheTokenType tokenType;
    static const GRMustacheTokenType tokenTypeForCharacter[] = {    // tokenTypeForCharacter[unspecified character] = 0 = GRMustacheTokenTypeEscapedVariable
        ['!'] = GRMustacheTokenTypeComment,
        ['#'] = GRMustacheTokenTypeSectionOpening,
        ['^'] = GRMustacheTokenTypeInvertedSectionOpening,
        ['/'] = GRMustacheTokenTypeSectionClosing,
        ['>'] = GRMustacheTokenTypePartial,
        ['='] = GRMustacheTokenTypeSetDelimiter,
        ['{'] = GRMustacheTokenTypeUnescapedVariable,
        ['&'] = GRMustacheTokenTypeUnescapedVariable,
    };
    static const int tokenTypeForCharacterLength = sizeof(tokenTypeForCharacter) / sizeof(GRMustacheTokenType);
    
    
    while (YES) {
        // look for otag
        orange = [self rangeOfString:_otag inTemplateString:templateString startingAtIndex:p.location consumedNewLines:&consumedLines];
        
        // otag was not found
        if (orange.location == NSNotFound) {
            if (p.location < length) {
                if (![self shouldContinueAfterParsingToken:[GRMustacheToken tokenWithType:GRMustacheTokenTypeText
                                                                                  content:[templateString substringFromIndex:p.location]
                                                                           templateString:templateString
                                                                               templateID:templateID
                                                                                     line:line
                                                                                    range:NSMakeRange(p.location, length - p.location)]]) {
                    return;
                }
            }
            [self didFinish];
            return;
        }
        
        if (orange.location > p.location) {
            NSRange range = NSMakeRange(p.location, orange.location - p.location);
            if (![self shouldContinueAfterParsingToken:[GRMustacheToken tokenWithType:GRMustacheTokenTypeText
                                                                              content:[templateString substringWithRange:range]
                                                                       templateString:templateString
                                                                           templateID:templateID
                                                                                 line:line
                                                                                range:range]]) {
                return;
            }
        }
        
        if (orange.location + orange.length >= length) {
            [self didFinishWithParseErrorAtLine:line description:@"Unmatched opening tag" templateID:templateID];
            return;
        }

        // update our cursors
        p = [templateString rangeOfComposedCharacterSequenceAtIndex:orange.location + orange.length];
        line += consumedLines;
        
        if ([@"{" isEqualToString:[templateString substringWithRange:p]]) {
            crange = [self rangeOfString:[@"}" stringByAppendingString:_ctag] inTemplateString:templateString startingAtIndex:p.location consumedNewLines:&consumedLines];
        } else {
            crange = [self rangeOfString:_ctag inTemplateString:templateString startingAtIndex:p.location consumedNewLines:&consumedLines];
        }
        
        // ctag was not found
        if (crange.location == NSNotFound) {
            [self didFinishWithParseErrorAtLine:line description:@"Unmatched opening tag" templateID:templateID];
            return;
        }
        
        // extract tag
        tag = [templateString substringWithRange:NSMakeRange(orange.location + orange.length, crange.location - orange.location - orange.length)];
        
        // empty tag is not allowed
        if (tag.length == 0) {
            [self didFinishWithParseErrorAtLine:line description:@"Empty tag" templateID:templateID];
            return;
        }
        
        // tag must not contain otag
        if ([tag rangeOfString:_otag].location != NSNotFound) {
            [self didFinishWithParseErrorAtLine:line description:@"Unmatched opening tag" templateID:templateID];
            return;
        }
        
        // interpret tag
        {
            NSRange initialTagGraphemeClusterRange = [tag rangeOfComposedCharacterSequenceAtIndex:0];
            if (initialTagGraphemeClusterRange.length == 1) {   // check for single character grapheme cluster
                unichar initialTagCharacter = [tag characterAtIndex:0];  // safe since we have a single character grapheme cluster at the beginning of the tag.
                tokenType = (initialTagCharacter < tokenTypeForCharacterLength) ? tokenTypeForCharacter[initialTagCharacter] : GRMustacheTokenTypeEscapedVariable;
            } else {
                tokenType = GRMustacheTokenTypeEscapedVariable;
            }
        }
        switch (tokenType) {
            case GRMustacheTokenTypeEscapedVariable:    // default value in tokenTypeForCharacter = 0 = GRMustacheTokenTypeEscapedVariable
                tokenContent = [tag stringByTrimmingCharactersInSet:whitespaceCharacterSet];
                break;
                
            case GRMustacheTokenTypeComment:
            case GRMustacheTokenTypeSectionOpening:
            case GRMustacheTokenTypeInvertedSectionOpening:
            case GRMustacheTokenTypeSectionClosing:
            case GRMustacheTokenTypePartial:
            case GRMustacheTokenTypeUnescapedVariable:
                tokenContent = [[tag substringFromIndex:1] stringByTrimmingCharactersInSet:whitespaceCharacterSet];
                break;
                
            case GRMustacheTokenTypeSetDelimiter:
                if ([tag characterAtIndex:tag.length-1] != '=') {
                    [self didFinishWithParseErrorAtLine:line description:@"Invalid set delimiter tag" templateID:templateID];
                    return;
                }
                tokenContent = [[tag substringWithRange:NSMakeRange(1, tag.length-2)] stringByTrimmingCharactersInSet:whitespaceCharacterSet];
                NSArray *newTags = [tokenContent componentsSeparatedByCharactersInSet:whitespaceCharacterSet];
                NSMutableArray *nonBlankNewTags = [NSMutableArray array];
                for (NSString *newTag in newTags) {
                    if (newTag.length > 0) {
                        [nonBlankNewTags addObject:newTag];
                    }
                }
                if (nonBlankNewTags.count == 2) {
                    self.otag = [nonBlankNewTags objectAtIndex:0];
                    self.ctag = [nonBlankNewTags objectAtIndex:1];
                } else {
                    [self didFinishWithParseErrorAtLine:line description:@"Invalid set delimiter tag" templateID:templateID];
                    return;
                }
                break;
                
            case GRMustacheTokenTypeText:
                NSAssert(NO, @"");
                break;
        }

        if (![self shouldContinueAfterParsingToken:[GRMustacheToken tokenWithType:tokenType
                                                                          content:tokenContent
                                                                   templateString:templateString
                                                                       templateID:templateID
                                                                             line:line
                                                                            range:NSMakeRange(orange.location, crange.location + crange.length - orange.location)]]) {
            return;
        }

        // update our cursors
        if (crange.location + crange.length < length) {
            p = [templateString rangeOfComposedCharacterSequenceAtIndex:crange.location + crange.length];
            line += consumedLines;
        } else {
            [self didFinish];
            return;
        }
    }
}

#pragma mark Private

- (BOOL)shouldContinueAfterParsingToken:(GRMustacheToken *)token
{
    if ([_delegate respondsToSelector:@selector(tokenizer:shouldContinueAfterParsingToken:)]) {
        return [_delegate tokenizer:self shouldContinueAfterParsingToken:token];
    }
    return YES;
}

- (void)didFinish
{
    if ([_delegate respondsToSelector:@selector(tokenizerDidFinish:)]) {
        [_delegate tokenizerDidFinish:self];
    }
}

- (void)didFinishWithParseErrorAtLine:(NSInteger)line description:(NSString *)description templateID:(id)templateID
{
    if ([_delegate respondsToSelector:@selector(tokenizer:didFailWithError:)]) {
        NSString *localizedDescription;
        if (templateID) {
            localizedDescription = [NSString stringWithFormat:@"Parse error at line %d of template %@: %@", line, description, templateID];
        } else {
            localizedDescription = [NSString stringWithFormat:@"Parse error at line %d: %@", line, description];
        }
        [_delegate tokenizer:self didFailWithError:[NSError errorWithDomain:GRMustacheErrorDomain
                                                                       code:GRMustacheErrorCodeParseError
                                                                   userInfo:[NSDictionary dictionaryWithObject:localizedDescription
                                                                                                        forKey:NSLocalizedDescriptionKey]]];
    }
}

- (NSRange)rangeOfString:(NSString *)string inTemplateString:(NSString *)templateString startingAtIndex:(NSUInteger)p consumedNewLines:(NSUInteger *)outLines
{
    NSUInteger stringLength = string.length;
    NSUInteger templateStringLength = templateString.length;
    unichar firstStringChar = [string characterAtIndex:0];
    unichar templateChar;
    
    assert(outLines);
    *outLines = 0;
    
    while (p + stringLength <= templateStringLength) {
        templateChar = [templateString characterAtIndex:p];
        if (templateChar == '\n') {
            (*outLines)++;
        } else if (templateChar == firstStringChar && [[templateString substringWithRange:NSMakeRange(p, string.length)] isEqualToString:string]) {
            return NSMakeRange(p, string.length);
        }
        p++;
    }
    
    return NSMakeRange(NSNotFound, 0);
}

@end
