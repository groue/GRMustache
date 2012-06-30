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

/**
 The Mustache tag opening delimiter. Initialized with @"{{", it may change with "change delimiter tags" such as `{{=< >=}}`.
 */
@property (nonatomic, copy) NSString *otag;

/**
 The Mustache tag opening delimiter. Initialized with @"}}", it may change with "change delimiter tags" such as `{{=< >=}}`.
 */
@property (nonatomic, copy) NSString *ctag;

/**
 Wrapper around the delegate's `tokenizer:shouldContinueAfterParsingToken:` method.
 */
- (BOOL)shouldContinueAfterParsingToken:(GRMustacheToken *)token;

/**
 Wrapper around the delegate's `tokenizer:didFailWithError:` method.
 
 @param line The line at which the error occurred.
 @param description A human-readable error message
 @param templateID A template ID (see GRMustacheTemplateRepository)
 */
- (void)failWithParseErrorAtLine:(NSInteger)line description:(NSString *)description templateID:(id)templateID;

/**
 String lookup method.
 
 @return The range of needle in haystack. If the location of range is NSNotFound, the needle was not found in the haystack.
 @param needle The string to look for.
 @param haystack The string to look into.
 @param p The index from which the search should begin
 @param outLines A pointer to an integer. Upon return contains the number of '\n' characters between _p_ and the location of the returned range.
 */
- (NSRange)rangeOfString:(NSString *)needle inTemplateString:(NSString *)haystack startingAtIndex:(NSUInteger)p consumedNewLines:(NSUInteger *)outLines;
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
    NSUInteger p = 0;
    NSUInteger line = 1;
    NSUInteger consumedLines = 0;
    NSRange orange;
    NSRange crange;
    NSString *tag;
    unichar character;
    NSCharacterSet *whitespaceCharacterSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *tokenContent;
    GRMustacheTokenType tokenType;
    NSRange tokenRange;
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
        orange = [self rangeOfString:_otag inTemplateString:templateString startingAtIndex:p consumedNewLines:&consumedLines];
        
        // otag was not found
        if (orange.location == NSNotFound) {
            if (p < templateString.length) {
                [self shouldContinueAfterParsingToken:[GRMustacheToken tokenWithType:GRMustacheTokenTypeText
                                                                             content:[templateString substringFromIndex:p]
                                                                      templateString:templateString
                                                                          templateID:templateID
                                                                                line:line
                                                                               range:NSMakeRange(p, templateString.length-p)]];
            }
            return;
        }
        
        if (orange.location > p) {
            NSRange range = NSMakeRange(p, orange.location-p);
            if (![self shouldContinueAfterParsingToken:[GRMustacheToken tokenWithType:GRMustacheTokenTypeText
                                                                              content:[templateString substringWithRange:range]
                                                                       templateString:templateString
                                                                           templateID:templateID
                                                                                 line:line
                                                                                range:range]]) {
                return;
            }
        }
        
        // update our cursors
        p = orange.location + orange.length;
        line += consumedLines;
        
        // look for close tag
        if (p < templateString.length && [templateString characterAtIndex:p] == '{') {
            crange = [self rangeOfString:[@"}" stringByAppendingString:_ctag] inTemplateString:templateString startingAtIndex:p consumedNewLines:&consumedLines];
        } else {
            crange = [self rangeOfString:_ctag inTemplateString:templateString startingAtIndex:p consumedNewLines:&consumedLines];
        }
        
        // ctag was not found
        if (crange.location == NSNotFound) {
            [self failWithParseErrorAtLine:line description:@"Unmatched opening tag" templateID:templateID];
            return;
        }
        
        // extract tag
        tag = [templateString substringWithRange:NSMakeRange(orange.location + orange.length, crange.location - orange.location - orange.length)];
        
        // empty tag is not allowed
        if (tag.length == 0) {
            [self failWithParseErrorAtLine:line description:@"Empty tag" templateID:templateID];
            return;
        }
        
        // tag must not contain otag
        if ([tag rangeOfString:_otag].location != NSNotFound) {
            [self failWithParseErrorAtLine:line description:@"Unmatched opening tag" templateID:templateID];
            return;
        }
        
        // interpret tag
        character = [tag characterAtIndex: 0];
        tokenType = (character < tokenTypeForCharacterLength) ? tokenTypeForCharacter[character] : GRMustacheTokenTypeEscapedVariable;
        tokenRange = NSMakeRange(orange.location, crange.location + crange.length - orange.location);
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
                    [self failWithParseErrorAtLine:line description:@"Invalid set delimiter tag" templateID:templateID];
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
                    [self failWithParseErrorAtLine:line description:@"Invalid set delimiter tag" templateID:templateID];
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
                                                                            range:tokenRange]]) {
            return;
        }

        // update our cursors
        p = crange.location + crange.length;
        line += consumedLines;
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

- (void)failWithParseErrorAtLine:(NSInteger)line description:(NSString *)description templateID:(id)templateID
{
    if ([_delegate respondsToSelector:@selector(tokenizer:didFailWithError:)]) {
        NSString *localizedDescription;
        if (templateID) {
            localizedDescription = [NSString stringWithFormat:@"Parse error at line %lu of template %@: %@", (unsigned long)line, templateID, description];
        } else {
            localizedDescription = [NSString stringWithFormat:@"Parse error at line %lu: %@", (unsigned long)line, description];
        }
        [_delegate tokenizer:self didFailWithError:[NSError errorWithDomain:GRMustacheErrorDomain
                                                                       code:GRMustacheErrorCodeParseError
                                                                   userInfo:[NSDictionary dictionaryWithObject:localizedDescription
                                                                                                        forKey:NSLocalizedDescriptionKey]]];
    }
}

- (NSRange)rangeOfString:(NSString *)needle inTemplateString:(NSString *)haystack startingAtIndex:(NSUInteger)p consumedNewLines:(NSUInteger *)outLines
{
    NSUInteger needleLength = needle.length;
    NSUInteger haystackLength = haystack.length;
    unichar firstNeedleChar = [needle characterAtIndex:0];
    unichar templateChar;
    
    assert(outLines);
    *outLines = 0;
    
    while (p + needleLength <= haystackLength) {
        templateChar = [haystack characterAtIndex:p];
        if (templateChar == '\n') {
            (*outLines)++;
        } else if (templateChar == firstNeedleChar && [[haystack substringWithRange:NSMakeRange(p, needle.length)] isEqualToString:needle]) {
            return NSMakeRange(p, needle.length);
        }
        p++;
    }
    
    return NSMakeRange(NSNotFound, 0);
}

@end
