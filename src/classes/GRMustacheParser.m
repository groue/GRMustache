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

#import "GRMustacheParser_private.h"
#import "GRMustacheError.h"
#import "GRMustacheFilteredExpression_private.h"
#import "GRMustacheIdentifierExpression_private.h"
#import "GRMustacheImplicitIteratorExpression_private.h"
#import "GRMustacheScopedExpression_private.h"

@interface GRMustacheParser()

/**
 * The Mustache tag opening delimiter. Initialized with @"{{", it may change
 * with "change delimiter" tags such as `{{=< >=}}`.
 */
@property (nonatomic, copy) NSString *otag;

/**
 * The Mustache tag opening delimiter. Initialized with @"}}", it may change
 * with "change delimiter" tags such as `{{=< >=}}`.
 */
@property (nonatomic, copy) NSString *ctag;

// Documented in GRMustacheParser_private.h
@property (nonatomic, strong) NSMutableSet *pragmas;

/**
 * Wrapper around the delegate's `parser:shouldContinueAfterParsingToken:`
 * method.
 */
- (BOOL)shouldContinueAfterParsingToken:(GRMustacheToken *)token;

/**
 * Wrapper around the delegate's `parser:didFailWithError:` method.
 * 
 * @param line          The line at which the error occurred.
 * @param description   A human-readable error message
 * @param templateID    A template ID (see GRMustacheTemplateRepository)
 */
- (void)failWithParseErrorAtLine:(NSInteger)line description:(NSString *)description templateID:(id)templateID;

/**
 * String lookup method.
 * 
 * @param needle    The string to look for.
 * @param haystack  The string to look into.
 * @param p         The index from which the search should begin
 * @param outLines  A pointer to an integer. Upon return contains the number of
 *                  '\n' characters between _p_ and the location of the returned
 *                  range.
 *
 * @return  The range of needle in haystack. If the location of range is
 *          NSNotFound, the needle was not found in the haystack.
 */
- (NSRange)rangeOfString:(NSString *)needle inTemplateString:(NSString *)haystack startingAtIndex:(NSUInteger)p consumedNewLines:(NSUInteger *)outLines;

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
- (GRMustacheExpression *)parseExpression:(NSString *)string invalid:(BOOL *)outInvalid;

/**
 * Returns a template name from the inner string of a tag.
 *
 * @param innerTagString  the inner string of a tag.
 *
 * @return a template name, or nil if the string is not a partial name.
 */
- (NSString *)parseTemplateName:(NSString *)innerTagString;

/**
 * Returns a pragma from the inner string of a tag.
 *
 * @param innerTagString  the inner string of a tag.
 *
 * @return a pragma, or nil if the string is not a pragma.
 */
- (NSString *)parsePragma:(NSString *)innerTagString;
@end

@implementation GRMustacheParser
@synthesize delegate=_delegate;
@synthesize otag=_otag;
@synthesize ctag=_ctag;
@synthesize pragmas=_pragmas;

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
    [_pragmas release];
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
    GRMustacheTokenType tokenType;
    NSRange tokenRange;
    static const GRMustacheTokenType tokenTypeForCharacter[] = {    // tokenTypeForCharacter[unspecified character] = 0 = GRMustacheTokenTypeEscapedVariable
        ['!'] = GRMustacheTokenTypeComment,
        ['#'] = GRMustacheTokenTypeSectionOpening,
        ['^'] = GRMustacheTokenTypeInvertedSectionOpening,
        ['$'] = GRMustacheTokenTypeOverridableSectionOpening,
        ['/'] = GRMustacheTokenTypeClosing,
        ['>'] = GRMustacheTokenTypePartial,
        ['<'] = GRMustacheTokenTypeOverridablePartial,
        ['='] = GRMustacheTokenTypeSetDelimiter,
        ['{'] = GRMustacheTokenTypeUnescapedVariable,
        ['&'] = GRMustacheTokenTypeUnescapedVariable,
        ['%'] = GRMustacheTokenTypePragma,
    };
    static const int tokenTypeForCharacterLength = sizeof(tokenTypeForCharacter) / sizeof(GRMustacheTokenType);
    
    
    while (YES) {
        // look for otag
        orange = [self rangeOfString:_otag inTemplateString:templateString startingAtIndex:p consumedNewLines:&consumedLines];
        
        // otag was not found
        if (orange.location == NSNotFound) {
            if (p < templateString.length) {
                [self shouldContinueAfterParsingToken:[GRMustacheToken tokenWithType:GRMustacheTokenTypeText
                                                                      templateString:templateString
                                                                          templateID:templateID
                                                                                line:line
                                                                               range:NSMakeRange(p, templateString.length-p)
                                                                                text:[templateString substringFromIndex:p]
                                                                          expression:nil
                                                                   invalidExpression:NO
                                                                         partialName:nil
                                                                              pragma:nil]];
            }
            return;
        }
        
        if (orange.location > p) {
            NSRange range = NSMakeRange(p, orange.location-p);
            if (![self shouldContinueAfterParsingToken:[GRMustacheToken tokenWithType:GRMustacheTokenTypeText
                                                                       templateString:templateString
                                                                           templateID:templateID
                                                                                 line:line
                                                                                range:range
                                                                                 text:[templateString substringWithRange:range]
                                                                           expression:nil
                                                                    invalidExpression:NO
                                                                          partialName:nil
                                                                               pragma:nil]]) {
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
        GRMustacheToken *token = nil;
        switch (tokenType) {
            case GRMustacheTokenTypeComment:
                token = [GRMustacheToken tokenWithType:GRMustacheTokenTypeComment
                                        templateString:templateString
                                            templateID:templateID
                                                  line:line
                                                 range:tokenRange
                                                  text:[tag substringFromIndex:1]   // strip initial '!'
                                            expression:nil
                                     invalidExpression:NO
                                           partialName:nil
                                                pragma:nil];
                break;
                
            case GRMustacheTokenTypeEscapedVariable: {    // default value in tokenTypeForCharacter = 0 = GRMustacheTokenTypeEscapedVariable
                BOOL invalid;
                GRMustacheExpression * expression = [self parseExpression:tag invalid:&invalid];
                token = [GRMustacheToken tokenWithType:GRMustacheTokenTypeEscapedVariable
                                        templateString:templateString
                                            templateID:templateID
                                                  line:line
                                                 range:tokenRange
                                                  text:nil
                                            expression:expression
                                     invalidExpression:invalid
                                           partialName:nil
                                                pragma:nil];
                expression.token = token;
            } break;
                
            case GRMustacheTokenTypeSectionOpening:
            case GRMustacheTokenTypeInvertedSectionOpening:
            case GRMustacheTokenTypeOverridableSectionOpening:
            case GRMustacheTokenTypeUnescapedVariable: {
                BOOL invalid;
                GRMustacheExpression * expression = [self parseExpression:[tag substringFromIndex:1] invalid:&invalid];   // strip initial '#', '^' etc.
                token = [GRMustacheToken tokenWithType:tokenType
                                        templateString:templateString
                                            templateID:templateID
                                                  line:line
                                                 range:tokenRange
                                                  text:nil
                                            expression:expression
                                     invalidExpression:invalid
                                           partialName:nil
                                                pragma:nil];
                expression.token = token;
            } break;
                
            case GRMustacheTokenTypeClosing: {
                // Closing tags close sections and super template tags, so we
                // parse both expression and templateName.
                BOOL invalid;
                GRMustacheExpression * expression = [self parseExpression:[tag substringFromIndex:1] invalid:&invalid];   // strip initial '/' etc.
                NSString *templateName = [self parseTemplateName:[tag substringFromIndex:1]];   // strip initial '/'
                
                token = [GRMustacheToken tokenWithType:tokenType
                                        templateString:templateString
                                            templateID:templateID
                                                  line:line
                                                 range:tokenRange
                                                  text:nil
                                            expression:expression
                                     invalidExpression:invalid
                                           partialName:templateName
                                                pragma:nil];
                expression.token = token;
            } break;
                
            case GRMustacheTokenTypePartial:
            case GRMustacheTokenTypeOverridablePartial: {
                NSString *templateName = [self parseTemplateName:[tag substringFromIndex:1]];   // strip initial '>'
                token = [GRMustacheToken tokenWithType:tokenType
                                        templateString:templateString
                                            templateID:templateID
                                                  line:line
                                                 range:tokenRange
                                                  text:nil
                                            expression:nil
                                     invalidExpression:NO
                                           partialName:templateName
                                                pragma:nil];
            } break;
                
            case GRMustacheTokenTypeSetDelimiter: {
                if ([tag characterAtIndex:tag.length-1] != '=') {
                    [self failWithParseErrorAtLine:line description:@"Invalid set delimiter tag" templateID:templateID];
                    return;
                }
                NSString *tokenContent = [[tag substringWithRange:NSMakeRange(1, tag.length-2)] stringByTrimmingCharactersInSet:whitespaceCharacterSet];
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
                token = [GRMustacheToken tokenWithType:GRMustacheTokenTypeSetDelimiter
                                        templateString:templateString
                                            templateID:templateID
                                                  line:line
                                                 range:tokenRange
                                                  text:nil
                                            expression:nil
                                     invalidExpression:NO
                                           partialName:nil
                                                pragma:nil];
            } break;
                
            case GRMustacheTokenTypePragma: {
                NSString *pragma = [self parsePragma:[tag substringFromIndex:1]];   // strip initial '>'
                if (pragma == nil) {
                    [self failWithParseErrorAtLine:line description:@"Invalid pragma" templateID:templateID];
                    return;
                }
                if (_pragmas == nil) {
                    self.pragmas = [NSMutableSet set];
                }
                [self.pragmas addObject:pragma];
                token = [GRMustacheToken tokenWithType:GRMustacheTokenTypePragma
                                        templateString:templateString
                                            templateID:templateID
                                                  line:line
                                                 range:tokenRange
                                                  text:nil
                                            expression:nil
                                     invalidExpression:NO
                                           partialName:nil
                                                pragma:pragma];
            } break;
                
            case GRMustacheTokenTypeText:
                NSAssert(NO, @"");
                break;
        }

        NSAssert(token, @"WTF");
        if (![self shouldContinueAfterParsingToken:token]) {
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
    if ([_delegate respondsToSelector:@selector(parser:shouldContinueAfterParsingToken:)]) {
        return [_delegate parser:self shouldContinueAfterParsingToken:token];
    }
    return YES;
}

- (void)failWithParseErrorAtLine:(NSInteger)line description:(NSString *)description templateID:(id)templateID
{
    if ([_delegate respondsToSelector:@selector(parser:didFailWithError:)]) {
        NSString *localizedDescription;
        if (templateID) {
            localizedDescription = [NSString stringWithFormat:@"Parse error at line %lu of template %@: %@", (unsigned long)line, templateID, description];
        } else {
            localizedDescription = [NSString stringWithFormat:@"Parse error at line %lu: %@", (unsigned long)line, description];
        }
        [_delegate parser:self didFailWithError:[NSError errorWithDomain:GRMustacheErrorDomain
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

- (GRMustacheExpression *)parseExpression:(NSString *)string invalid:(BOOL *)outInvalid
{
    //    -> ;;sm_parenLevel=0, canFilter=YES -> stateInitial
    //    stateInitial -> ' ' -> stateInitial
    //    stateInitial -> ;'.';canFilter=NO -> stateLeadingDot
    //    stateInitial -> ;'a';canFilter=YES -> stateIdentifier
    //    stateInitial -> sm_parenLevel==0;EOF; -> stateEmpty
    //    stateLeadingDot -> 'a' -> stateIdentifier
    //    stateLeadingDot -> ' ' -> stateIdentifierDone
    //    stateLeadingDot -> sm_parenLevel>0;')';--sm_parenLevel -> stateFilterDone
    //    stateLeadingDot -> sm_parenLevel==0;EOF; -> stateValid
    //    stateIdentifier -> 'a' -> stateIdentifier
    //    stateIdentifier -> '.' -> stateWaitingForIdentifier
    //    stateIdentifier -> ' ' -> stateIdentifierDone
    //    stateIdentifier -> canFilter;'(';++sm_parenLevel -> stateInitial
    //    stateIdentifier -> sm_parenLevel>0;')';--sm_parenLevel -> stateFilterDone
    //    stateIdentifier -> sm_parenLevel==0;EOF; -> stateValid
    //    stateWaitingForIdentifier -> 'a' -> stateIdentifier
    //    stateIdentifierDone -> ' ' -> stateIdentifierDone
    //    stateIdentifierDone -> sm_parenLevel==0;EOF; -> stateValid
    //    stateIdentifierDone -> canFilter;'(';++sm_parenLevel -> stateInitial
    //    stateFilterDone -> ' ' -> stateFilterDone
    //    stateFilterDone -> '.' -> stateWaitingForIdentifier
    //    stateFilterDone -> '(';++sm_parenLevel -> stateInitial
    //    stateFilterDone -> sm_parenLevel==0;EOF; -> stateValid
    //    stateFilterDone -> sm_parenLevel>0;')';--sm_parenLevel -> stateFilterDone
    
    // state machine internal states
    enum {
        stateInitial,
        stateLeadingDot,
        stateIdentifier,
        stateWaitingForIdentifier,
        stateIdentifierDone,
        stateFilterDone,
        stateEmpty,
        stateError,
        stateValid
    } state = stateInitial;
    BOOL canFilter = NO;
    NSUInteger identifierStart = NSNotFound;
    NSMutableArray *filterExpressionStack = [NSMutableArray array];
    GRMustacheExpression *currentExpression=nil;
    GRMustacheExpression *validExpression=nil;
    
    NSUInteger length = string.length;
    for (NSUInteger i = 0; i < length; ++i) {
        
        // shortcut
        if (state == stateError) {
            break;
        }
        
        unichar c = [string characterAtIndex:i];
        switch (state) {
            case stateInitial:
                switch (c) {
                    case ' ':
                    case '\r':
                    case '\n':
                    case '\t':
                        break;
                        
                    case '.':
                        NSAssert(currentExpression == nil, @"WTF");
                        canFilter = NO;
                        state = stateLeadingDot;
                        currentExpression = [GRMustacheImplicitIteratorExpression expression];
                        break;
                    
                    case '(':
                        state = stateError;
                        break;
                        
                    case ')':
                        state = stateError;
                        break;
                        
                    default:
                        canFilter = YES;
                        state = stateIdentifier;
                        
                        // enter stateIdentifier
                        identifierStart = i;
                        break;
                }
                break;
                
            case stateLeadingDot:
                switch (c) {
                    case ' ':
                    case '\r':
                    case '\n':
                    case '\t':
                        state = stateIdentifierDone;
                        break;
                        
                    case '.':
                        state = stateError;
                        break;
                        
                    case '(':
                        state = stateError;
                        break;
                        
                    case ')':
                        if (filterExpressionStack.count > 0) {
                            NSAssert(currentExpression, @"WTF");
                            NSAssert(filterExpressionStack.count > 0, @"WTF");
                            
                            state = stateFilterDone;
                            GRMustacheExpression *filterExpression = [filterExpressionStack lastObject];
                            [filterExpressionStack removeLastObject];
                            currentExpression = [GRMustacheFilteredExpression expressionWithFilterExpression:filterExpression parameterExpression:currentExpression];
                        } else {
                            state = stateError;
                        }
                        break;
                        
                    default:
                        state = stateIdentifier;
                        
                        // enter stateIdentifier
                        identifierStart = i;
                        break;
                }
                break;
                
            case stateIdentifier:
                switch (c) {
                    case ' ':
                    case '\r':
                    case '\n':
                    case '\t': {
                        // leave stateIdentifier
                        NSString *identifier = [string substringWithRange:(NSRange){ .location = identifierStart, .length = i - identifierStart }];
                        if (currentExpression) {
                            currentExpression = [GRMustacheScopedExpression expressionWithBaseExpression:currentExpression scopeIdentifier:identifier];
                        } else {
                            currentExpression = [GRMustacheIdentifierExpression expressionWithIdentifier:identifier];
                        }
                        
                        state = stateIdentifierDone;
                    } break;
                        
                    case '.': {
                        // leave stateIdentifier
                        NSString *identifier = [string substringWithRange:(NSRange){ .location = identifierStart, .length = i - identifierStart }];
                        if (currentExpression) {
                            currentExpression = [GRMustacheScopedExpression expressionWithBaseExpression:currentExpression scopeIdentifier:identifier];
                        } else {
                            currentExpression = [GRMustacheIdentifierExpression expressionWithIdentifier:identifier];
                        }
                        
                        state = stateWaitingForIdentifier;
                    } break;
                        
                    case '(': {
                        // leave stateIdentifier
                        NSString *identifier = [string substringWithRange:(NSRange){ .location = identifierStart, .length = i - identifierStart }];
                        if (currentExpression) {
                            currentExpression = [GRMustacheScopedExpression expressionWithBaseExpression:currentExpression scopeIdentifier:identifier];
                        } else {
                            currentExpression = [GRMustacheIdentifierExpression expressionWithIdentifier:identifier];
                        }
                        
                        if (canFilter) {
                            NSAssert(currentExpression, @"WTF");
                            state = stateInitial;
                            [filterExpressionStack addObject:currentExpression];
                            currentExpression = nil;
                        } else {
                            state = stateError;
                        }
                    } break;
                        
                    case ')': {
                        // leave stateIdentifier
                        NSString *identifier = [string substringWithRange:(NSRange){ .location = identifierStart, .length = i - identifierStart }];
                        if (currentExpression) {
                            currentExpression = [GRMustacheScopedExpression expressionWithBaseExpression:currentExpression scopeIdentifier:identifier];
                        } else {
                            currentExpression = [GRMustacheIdentifierExpression expressionWithIdentifier:identifier];
                        }
                        
                        if (filterExpressionStack.count > 0) {
                            NSAssert(currentExpression, @"WTF");
                            NSAssert(filterExpressionStack.count > 0, @"WTF");
                            state = stateFilterDone;
                            GRMustacheExpression *filterExpression = [filterExpressionStack lastObject];
                            [filterExpressionStack removeLastObject];
                            currentExpression = [GRMustacheFilteredExpression expressionWithFilterExpression:filterExpression parameterExpression:currentExpression];
                        } else {
                            state = stateError;
                        }
                    } break;
                        
                    default:
                        break;
                }
                break;
                
            case stateWaitingForIdentifier:
                switch (c) {
                    case ' ':
                    case '\r':
                    case '\n':
                    case '\t':
                        state = stateError;
                        break;
                        
                    case '.':
                        state = stateError;
                        break;
                        
                    case '(':
                        state = stateError;
                        break;
                        
                    case ')':
                        state = stateError;
                        break;
                        
                    default:
                        state = stateIdentifier;
                        
                        // enter stateIdentifier
                        identifierStart = i;
                        break;
                }
                break;
                
            case stateIdentifierDone:
                switch (c) {
                    case ' ':
                    case '\r':
                    case '\n':
                    case '\t':
                        break;
                        
                    case '.':
                        state = stateError;
                        break;
                        
                    case '(':
                        if (canFilter) {
                            NSAssert(currentExpression, @"WTF");
                            state = stateInitial;
                            [filterExpressionStack addObject:currentExpression];
                            currentExpression = nil;
                        } else {
                            state = stateError;
                        }
                        break;
                        
                    case ')':
                        if (filterExpressionStack.count > 0) {
                            NSAssert(currentExpression, @"WTF");
                            NSAssert(filterExpressionStack.count > 0, @"WTF");
                            state = stateFilterDone;
                            GRMustacheExpression *filterExpression = [filterExpressionStack lastObject];
                            [filterExpressionStack removeLastObject];
                            currentExpression = [GRMustacheFilteredExpression expressionWithFilterExpression:filterExpression parameterExpression:currentExpression];
                        } else {
                            state = stateError;
                        }
                        break;
                        
                    default:
                        state = stateError;
                        break;
                }
                break;
            
            case stateFilterDone:
                switch (c) {
                    case ' ':
                    case '\r':
                    case '\n':
                    case '\t':
                        break;
                        
                    case '.':
                        state = stateWaitingForIdentifier;
                        break;
                        
                    case '(':
                        NSAssert(currentExpression, @"WTF");
                        state = stateInitial;
                        [filterExpressionStack addObject:currentExpression];
                        currentExpression = nil;
                        break;
                        
                    case ')':
                        if (filterExpressionStack.count > 0) {
                            NSAssert(currentExpression, @"WTF");
                            NSAssert(filterExpressionStack.count > 0, @"WTF");
                            state = stateFilterDone;
                            GRMustacheExpression *filterExpression = [filterExpressionStack lastObject];
                            [filterExpressionStack removeLastObject];
                            currentExpression = [GRMustacheFilteredExpression expressionWithFilterExpression:filterExpression parameterExpression:currentExpression];
                        } else {
                            state = stateError;
                        }
                        break;
                        
                    default:
                        state = stateError;
                        break;
                }
                break;
            default:
                NSAssert(NO, @"WTF");
                break;
        }
    }
    
    
    // EOF
    
    switch (state) {
        case stateInitial:
            if (filterExpressionStack.count == 0) {
                state = stateEmpty;
            } else {
                state = stateError;
            }
            break;
            
        case stateLeadingDot:
            if (filterExpressionStack.count == 0) {
                NSAssert(currentExpression, @"WTF");
                validExpression = currentExpression;
                state = stateValid;
            } else {
                state = stateError;
            }
            break;
            
        case stateIdentifier: {
            // leave stateIdentifier
            NSString *identifier = [string substringFromIndex:identifierStart];
            if (currentExpression) {
                currentExpression = [GRMustacheScopedExpression expressionWithBaseExpression:currentExpression scopeIdentifier:identifier];
            } else {
                currentExpression = [GRMustacheIdentifierExpression expressionWithIdentifier:identifier];
            }
            
            if (filterExpressionStack.count == 0) {
                NSAssert(currentExpression, @"WTF");
                validExpression = currentExpression;
                state = stateValid;
            } else {
                state = stateError;
            }
        } break;
            
        case stateWaitingForIdentifier:
            state = stateError;
            break;
        
        case stateIdentifierDone:
            if (filterExpressionStack.count == 0) {
                NSAssert(currentExpression, @"WTF");
                validExpression = currentExpression;
                state = stateValid;
            } else {
                state = stateError;
            }
            break;
            
        case stateFilterDone:
            if (filterExpressionStack.count == 0) {
                NSAssert(currentExpression, @"WTF");
                validExpression = currentExpression;
                state = stateValid;
            } else {
                state = stateError;
            }
            break;
            
        case stateError:
            break;
            
        default:
            NSAssert(NO, @"WTF");
            break;
    }
    
    
    // End
    
    switch (state) {
        case stateEmpty:
            *outInvalid = NO;
            return nil;
            
        case stateError:
            *outInvalid = YES;
            return nil;
            
        case stateValid:
            NSAssert(validExpression, @"WTF");
            return validExpression;
            
        default:
            NSAssert(NO, @"WTF");
            break;
    }
    
    return nil;
}

- (NSString *)parseTemplateName:(NSString *)innerTagString
{
    NSString *templateName = [innerTagString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (templateName.length == 0) {
        return nil;
    }
    return templateName;
}

- (NSString *)parsePragma:(NSString *)innerTagString
{
    NSString *pragma = [innerTagString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (pragma.length == 0) {
        return nil;
    }
    return pragma;
}

@end
