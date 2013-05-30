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

#import "GRMustacheParser_private.h"
#import "GRMustacheConfiguration_private.h"
#import "GRMustacheError.h"
#import "GRMustacheFilteredExpression_private.h"
#import "GRMustacheIdentifierExpression_private.h"
#import "GRMustacheImplicitIteratorExpression_private.h"
#import "GRMustacheScopedExpression_private.h"

@interface GRMustacheParser()

/**
 * The Mustache tag opening delimiter.
 */
@property (nonatomic, copy) NSString *tagStartDelimiter;

/**
 * The Mustache tag opening delimiter.
 */
@property (nonatomic, copy) NSString *tagEndDelimiter;

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

@end

@implementation GRMustacheParser
@synthesize delegate=_delegate;
@synthesize tagStartDelimiter=_tagStartDelimiter;
@synthesize tagEndDelimiter=_tagEndDelimiter;
@synthesize pragmas=_pragmas;

- (id)initWithConfiguration:(GRMustacheConfiguration *)configuration
{
    self = [super init];
    if (self) {
        self.tagStartDelimiter = configuration.tagStartDelimiter;
        self.tagEndDelimiter = configuration.tagEndDelimiter;
    }
    return self;
}

- (void)dealloc
{
    [_tagStartDelimiter release];
    [_tagEndDelimiter release];
    [_pragmas release];
    [super dealloc];
}

- (void)parseTemplateString:(NSString *)templateString templateID:(id)templateID
{
    // Extract characters
    
    NSUInteger length = [templateString length];
    const UniChar *characters = CFStringGetCharactersPtr((CFStringRef)templateString);
    if (!characters) {
        NSMutableData *data = [NSMutableData dataWithLength:length * sizeof(UniChar)];
        [templateString getCharacters:[data mutableBytes] range:(NSRange){ .location = 0, .length = length }];
        characters = [data bytes];
    }
    
    NSCharacterSet *whitespaceCharacterSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    
    // state machine internal states
    enum {
        stateStart,             // Something is going to happen. We don't know what yet. Next character will tell.
        stateText,              // Currently enumerating other characters
        stateTag,               // Currently enumerating characters of a {{tag}}
        stateUnescapedTag,      // Currently enumerating characters of a {{{tag}}}
        stateSetDelimitersTag,  // Currently enumerating characters of a {{=tag=}}
    } state = stateStart;
    
    // Some cached value for "efficient" lookup of {{ and }}
    NSString *tagStartDelimiter = self.tagStartDelimiter;
    NSString *tagEndDelimiter = self.tagEndDelimiter;
    UniChar tagStartDelimiterInitial = [tagStartDelimiter characterAtIndex:0];
    NSUInteger tagStartDelimiterLength = tagStartDelimiter.length;
    UniChar tagEndDelimiterInitial = [tagEndDelimiter characterAtIndex:0];
    NSUInteger tagEndDelimiterLength = tagEndDelimiter.length;
    
    // Some cached value for "efficient" lookup of {{{ and }}}
    //
    // Mustache spec does not say that what happens to triple mustache tags when
    // delimiters are not {{ and }}. It just says to use the & tag prefix:
    // {{{ a }}} <=> {{& a }}.
    //
    // We interpret this as a complete removal of triple mustache tags when
    // delimiters are not {{ and }}: unescapedTagStartDelimiterInitial will be 0
    // and we will never enter the stateUnescapedTag state.
    BOOL standardDelimiters = [tagStartDelimiter isEqualToString:@"{{"] && [tagEndDelimiter isEqualToString:@"}}"];
    NSString *unescapedTagStartDelimiter = standardDelimiters ? @"{{{" : nil;
    NSString *unescapedTagEndDelimiter = standardDelimiters ? @"}}}" : nil;
    UniChar unescapedTagStartDelimiterInitial = [unescapedTagStartDelimiter characterAtIndex:0];
    NSUInteger unescapedTagStartDelimiterLength = unescapedTagStartDelimiter.length;
    UniChar unescapedTagEndDelimiterInitial = [unescapedTagEndDelimiter characterAtIndex:0];
    NSUInteger unescapedTagEndDelimiterLength = unescapedTagEndDelimiter.length;
    
    // Some cached value for "efficient" lookup of {{= and =}}
    //
    // Set delimiters tags {{=<% %>=}} have a dedicated lookup and state, so that
    // we support setting to the current delimiters: {{={{ }}=}}. We achieve this
    // by exiting the stateSetDelimitersTag state on =}}, not on }}.
    NSString *setDelimitersTagStartDelimiter = [NSString stringWithFormat:@"%@=", tagStartDelimiter];
    NSString *setDelimitersTagEndDelimiter = [NSString stringWithFormat:@"=%@", tagEndDelimiter];
    UniChar setDelimitersTagStartDelimiterInitial = [setDelimitersTagStartDelimiter characterAtIndex:0];
    NSUInteger setDelimitersTagStartDelimiterLength = setDelimitersTagStartDelimiter.length;
    UniChar setDelimitersTagEndDelimiterInitial = [setDelimitersTagEndDelimiter characterAtIndex:0];
    NSUInteger setDelimitersTagEndDelimiterLength = setDelimitersTagEndDelimiter.length;
    
    NSUInteger i = 0;                   // index of current character
    NSUInteger start = 0;               // index of character at the beginning of the current state
    NSUInteger lineNumber = 1;          // 1-based index of the current line
    NSUInteger tagStartLineNumber = 1;  // 1-based index of the beginning of the current tag
    for (; i<length; ++i) {
        UniChar c = characters[i];
        switch (state) {
            
#define CHARACTER_STARTS(x) (c == x ## Initial &&\
                             i+x ## Length <= length &&\
                             [[templateString substringWithRange:NSMakeRange(i, x ## Length)] isEqualToString:x])
            
            case stateStart: {
                if (c == '\n')
                {
                    ++lineNumber;
                    start = i;
                    state = stateText;
                }
                else if (CHARACTER_STARTS(unescapedTagStartDelimiter))
                {
                    tagStartLineNumber = lineNumber;
                    start = i;
                    state = stateUnescapedTag;
                    i += unescapedTagStartDelimiterLength - 1;
                }
                else if (CHARACTER_STARTS(setDelimitersTagStartDelimiter))
                {
                    tagStartLineNumber = lineNumber;
                    start = i;
                    state = stateSetDelimitersTag;
                    i += setDelimitersTagStartDelimiterLength - 1;
                }
                else if (CHARACTER_STARTS(tagStartDelimiter))
                {
                    tagStartLineNumber = lineNumber;
                    start = i;
                    state = stateTag;
                    i += tagStartDelimiterLength - 1;
                }
                else
                {
                    start = i;
                    state = stateText;
                }
            } break;
                
            case stateText: {
                if (c == '\n')
                {
                    ++lineNumber;
                }
                else if (CHARACTER_STARTS(unescapedTagStartDelimiter))
                {
                    if (start != i) {
                        // Content
                        GRMustacheToken *token = [GRMustacheToken tokenWithType:GRMustacheTokenTypeText
                                                                 templateString:templateString
                                                                     templateID:templateID
                                                                           line:lineNumber
                                                                          range:(NSRange){ .location = start, .length = i-start}];
                        if (![self.delegate parser:self shouldContinueAfterParsingToken:token]) return;
                    }
                    tagStartLineNumber = lineNumber;
                    start = i;
                    state = stateUnescapedTag;
                    i += unescapedTagStartDelimiterLength - 1;
                }
                else if (CHARACTER_STARTS(setDelimitersTagStartDelimiter))
                {
                    if (start != i) {
                        // Content
                        GRMustacheToken *token = [GRMustacheToken tokenWithType:GRMustacheTokenTypeText
                                                                 templateString:templateString
                                                                     templateID:templateID
                                                                           line:lineNumber
                                                                          range:(NSRange){ .location = start, .length = i-start}];
                        if (![self.delegate parser:self shouldContinueAfterParsingToken:token]) return;
                    }
                    tagStartLineNumber = lineNumber;
                    start = i;
                    state = stateSetDelimitersTag;
                    i += setDelimitersTagStartDelimiterLength - 1;
                }
                else if (CHARACTER_STARTS(tagStartDelimiter))
                {
                    if (start != i) {
                        // Content
                        GRMustacheToken *token =  [GRMustacheToken tokenWithType:GRMustacheTokenTypeText
                                                                  templateString:templateString
                                                                      templateID:templateID
                                                                            line:lineNumber
                                                                           range:(NSRange){ .location = start, .length = i-start}];
                        if (![self.delegate parser:self shouldContinueAfterParsingToken:token]) return;
                    }
                    tagStartLineNumber = lineNumber;
                    start = i;
                    state = stateTag;
                    i += tagStartDelimiterLength - 1;
                }
            } break;
                
            case stateTag: {
                if (c == '\n')
                {
                    ++lineNumber;
                }
                else if (CHARACTER_STARTS(tagEndDelimiter))
                {
                    // Tag
                    GRMustacheTokenType type = GRMustacheTokenTypeEscapedVariable;
                    UniChar tagInitial = characters[start+tagStartDelimiterLength];
                    NSRange tagInnerRange;
                    switch (tagInitial) {
                        case '!':
                            type = GRMustacheTokenTypeComment;
                            tagInnerRange = (NSRange){ .location = start+tagStartDelimiterLength+1, .length = i-(start+tagStartDelimiterLength+1) };
                            break;
                        case '#':
                            type = GRMustacheTokenTypeSectionOpening;
                            tagInnerRange = (NSRange){ .location = start+tagStartDelimiterLength+1, .length = i-(start+tagStartDelimiterLength+1) };
                            break;
                        case '^':
                            type = GRMustacheTokenTypeInvertedSectionOpening;
                            tagInnerRange = (NSRange){ .location = start+tagStartDelimiterLength+1, .length = i-(start+tagStartDelimiterLength+1) };
                            break;
                        case '$':
                            type = GRMustacheTokenTypeOverridableSectionOpening;
                            tagInnerRange = (NSRange){ .location = start+tagStartDelimiterLength+1, .length = i-(start+tagStartDelimiterLength+1) };
                            break;
                        case '/':
                            type = GRMustacheTokenTypeClosing;
                            tagInnerRange = (NSRange){ .location = start+tagStartDelimiterLength+1, .length = i-(start+tagStartDelimiterLength+1) };
                            break;
                        case '>':
                            type = GRMustacheTokenTypePartial;
                            tagInnerRange = (NSRange){ .location = start+tagStartDelimiterLength+1, .length = i-(start+tagStartDelimiterLength+1) };
                            break;
                        case '<':
                            type = GRMustacheTokenTypeOverridablePartial;
                            tagInnerRange = (NSRange){ .location = start+tagStartDelimiterLength+1, .length = i-(start+tagStartDelimiterLength+1) };
                            break;
                        case '{':
                            type = GRMustacheTokenTypeUnescapedVariable;
                            tagInnerRange = (NSRange){ .location = start+tagStartDelimiterLength+1, .length = i-(start+tagStartDelimiterLength+1) };
                            break;
                        case '&':
                            type = GRMustacheTokenTypeUnescapedVariable;
                            tagInnerRange = (NSRange){ .location = start+tagStartDelimiterLength+1, .length = i-(start+tagStartDelimiterLength+1) };
                            break;
                        case '%':
                            type = GRMustacheTokenTypePragma;
                            tagInnerRange = (NSRange){ .location = start+tagStartDelimiterLength+1, .length = i-(start+tagStartDelimiterLength+1) };
                            break;
                        default:
                            type = GRMustacheTokenTypeEscapedVariable;
                            tagInnerRange = (NSRange){ .location = start+tagStartDelimiterLength, .length = i-(start+tagStartDelimiterLength) };
                            break;
                    }
                    GRMustacheToken *token = [GRMustacheToken tokenWithType:type
                                                             templateString:templateString
                                                                 templateID:templateID
                                                                       line:tagStartLineNumber
                                                                      range:(NSRange){ .location = start, .length = (i+tagEndDelimiterLength)-start}];
                    token.tagInnerRange = tagInnerRange;
                    if (![self.delegate parser:self shouldContinueAfterParsingToken:token]) return;
                    
                    start = i + tagEndDelimiterLength;
                    state = stateStart;
                    i += tagEndDelimiterLength - 1;
                }
            } break;
                
            case stateUnescapedTag: {
                if (c == '\n')
                {
                    ++lineNumber;
                }
                else if (CHARACTER_STARTS(unescapedTagEndDelimiter))
                {
                    // Tag
                    GRMustacheToken *token = [GRMustacheToken tokenWithType:GRMustacheTokenTypeUnescapedVariable
                                                             templateString:templateString
                                                                 templateID:templateID
                                                                       line:tagStartLineNumber
                                                                      range:(NSRange){ .location = start, .length = (i+unescapedTagEndDelimiterLength)-start}];
                    token.tagInnerRange = (NSRange){ .location = start+unescapedTagStartDelimiterLength, .length = i-(start+unescapedTagStartDelimiterLength) };
                    if (![self.delegate parser:self shouldContinueAfterParsingToken:token]) return;
                    
                    start = i + unescapedTagEndDelimiterLength;
                    state = stateStart;
                    i += unescapedTagEndDelimiterLength - 1;
                }
            } break;
                
            case stateSetDelimitersTag: {
                if (c == '\n')
                {
                    ++lineNumber;
                }
                else if (CHARACTER_STARTS(setDelimitersTagEndDelimiter))
                {
                    // Set Delimiters Tag
                    NSString *innerContent = [templateString substringWithRange:(NSRange){ .location = start+setDelimitersTagStartDelimiterLength, .length = i-(start+setDelimitersTagStartDelimiterLength) }];
                    NSArray *newTags = [innerContent componentsSeparatedByCharactersInSet:whitespaceCharacterSet];
                    NSMutableArray *nonBlankNewTags = [NSMutableArray array];
                    for (NSString *newTag in newTags) {
                        if (newTag.length > 0) {
                            [nonBlankNewTags addObject:newTag];
                        }
                    }
                    if (nonBlankNewTags.count != 2) {
                        [self failWithParseErrorAtLine:lineNumber description:@"Invalid set delimiters tag" templateID:templateID];
                        return;
                    }
                    
                    GRMustacheToken *token = [GRMustacheToken tokenWithType:GRMustacheTokenTypeSetDelimiter
                                                             templateString:templateString
                                                                 templateID:templateID
                                                                       line:tagStartLineNumber
                                                                      range:(NSRange){ .location = start, .length = (i+setDelimitersTagEndDelimiterLength)-start}];
                    token.tagInnerRange = (NSRange){ .location = start+setDelimitersTagStartDelimiterLength, .length = i-(start+setDelimitersTagStartDelimiterLength) };
                    if (![self.delegate parser:self shouldContinueAfterParsingToken:token]) return;
                    
                    start = i + setDelimitersTagEndDelimiterLength;
                    state = stateStart;
                    i += setDelimitersTagEndDelimiterLength - 1;
                    
                    // Update tag delimiters, and cached values for "efficient"
                    // lookup of them (see character loop initialization)
                    
                    tagStartDelimiter = [nonBlankNewTags objectAtIndex:0];
                    tagEndDelimiter = [nonBlankNewTags objectAtIndex:1];
                    tagStartDelimiterInitial = [tagStartDelimiter characterAtIndex:0];
                    tagStartDelimiterLength = tagStartDelimiter.length;
                    tagEndDelimiterInitial = [tagEndDelimiter characterAtIndex:0];
                    tagEndDelimiterLength = tagEndDelimiter.length;
                    
                    BOOL standardDelimiters = [tagStartDelimiter isEqualToString:@"{{"] && [tagEndDelimiter isEqualToString:@"}}"];
                    unescapedTagStartDelimiter = standardDelimiters ? @"{{{" : nil;
                    unescapedTagEndDelimiter = standardDelimiters ? @"}}}" : nil;
                    unescapedTagStartDelimiterInitial = [unescapedTagStartDelimiter characterAtIndex:0];
                    unescapedTagStartDelimiterLength = unescapedTagStartDelimiter.length;
                    unescapedTagEndDelimiterInitial = [unescapedTagEndDelimiter characterAtIndex:0];
                    unescapedTagEndDelimiterLength = unescapedTagEndDelimiter.length;
                    
                    setDelimitersTagStartDelimiter = [NSString stringWithFormat:@"%@=", tagStartDelimiter];
                    setDelimitersTagEndDelimiter = [NSString stringWithFormat:@"=%@", tagEndDelimiter];
                    setDelimitersTagStartDelimiterInitial = [setDelimitersTagStartDelimiter characterAtIndex:0];
                    setDelimitersTagStartDelimiterLength = setDelimitersTagStartDelimiter.length;
                    setDelimitersTagEndDelimiterInitial = [setDelimitersTagEndDelimiter characterAtIndex:0];
                    setDelimitersTagEndDelimiterLength = setDelimitersTagEndDelimiter.length;
                }
            } break;
        }
    }
    
    // EOF
    switch (state) {
        case stateStart:
            break;
            
        case stateText: {
            GRMustacheToken *token = [GRMustacheToken tokenWithType:GRMustacheTokenTypeText
                                                     templateString:templateString
                                                         templateID:templateID
                                                               line:lineNumber
                                                              range:(NSRange){ .location = start, .length = i-start}];
            if (![self.delegate parser:self shouldContinueAfterParsingToken:token]) return;
        } break;
            
        case stateTag:
        case stateUnescapedTag:
        case stateSetDelimitersTag: {
            [self failWithParseErrorAtLine:tagStartLineNumber description:@"Unclosed Mustache tag" templateID:templateID];
            return;
        } break;
    }
}

- (GRMustacheExpression *)parseExpression:(NSString *)string invalid:(BOOL *)outInvalid
{
    //    -> ;;sm_parenLevel=0 -> stateInitial
    //    stateInitial -> ' ' -> stateInitial
    //    stateInitial -> '.' -> stateLeadingDot
    //    stateInitial -> 'a' -> stateIdentifier
    //    stateInitial -> sm_parenLevel==0;EOF; -> stateEmpty
    //    stateLeadingDot -> 'a' -> stateIdentifier
    //    stateLeadingDot -> ' ' -> stateIdentifierDone
    //    stateIdentifier -> '(';++sm_parenLevel -> stateInitial
    //    stateLeadingDot -> sm_parenLevel>0;')';--sm_parenLevel -> stateFilterDone
    //    stateLeadingDot -> sm_parenLevel==0;EOF; -> stateValid
    //    stateIdentifier -> 'a' -> stateIdentifier
    //    stateIdentifier -> '.' -> stateWaitingForIdentifier
    //    stateIdentifier -> ' ' -> stateIdentifierDone
    //    stateIdentifier -> '(';++sm_parenLevel -> stateInitial
    //    stateIdentifier -> sm_parenLevel>0;')';--sm_parenLevel -> stateFilterDone
    //    stateIdentifier -> sm_parenLevel==0;EOF; -> stateValid
    //    stateWaitingForIdentifier -> 'a' -> stateIdentifier
    //    stateIdentifierDone -> ' ' -> stateIdentifierDone
    //    stateIdentifierDone -> sm_parenLevel==0;EOF; -> stateValid
    //    stateIdentifierDone -> '(';++sm_parenLevel -> stateInitial
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
                        NSAssert(currentExpression == nil, @"WTF expected nil currentExpression");
                        state = stateLeadingDot;
                        currentExpression = [GRMustacheImplicitIteratorExpression expression];
                        break;
                        
                    case '(':
                        state = stateError;
                        break;
                        
                    case ')':
                        state = stateError;
                        break;
                        
                    case ',':
                        state = stateError;
                        break;
                        
                    case '{':
                    case '}':
                    case '&':
                    case '$':
                    case '#':
                    case '^':
                    case '/':
                    case '<':
                    case '>':
                        // invalid as an identifier start
                        state = stateError;
                        break;
                        
                    default:
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
                        
                    case '(': {
                        NSAssert(currentExpression, @"WTF expected currentExpression");
                        state = stateInitial;
                        [filterExpressionStack addObject:currentExpression];
                        currentExpression = nil;
                    } break;
                        
                    case ')':
                        if (filterExpressionStack.count > 0) {
                            NSAssert(currentExpression, @"WTF expected currentExpression");
                            NSAssert(filterExpressionStack.count > 0, @"WTF expected non empty filterExpressionStack");
                            
                            state = stateFilterDone;
                            GRMustacheExpression *filterExpression = [filterExpressionStack lastObject];
                            [filterExpressionStack removeLastObject];
                            currentExpression = [GRMustacheFilteredExpression expressionWithFilterExpression:filterExpression argumentExpression:currentExpression curry:NO];
                        } else {
                            state = stateError;
                        }
                        break;
                        
                    case ',':
                        if (filterExpressionStack.count > 0) {
                            NSAssert(currentExpression, @"WTF expected currentExpression");
                            NSAssert(filterExpressionStack.count > 0, @"WTF expected non empty filterExpressionStack");
                            
                            state = stateInitial;
                            GRMustacheExpression *filterExpression = [filterExpressionStack lastObject];
                            [filterExpressionStack removeLastObject];
                            [filterExpressionStack addObject:[GRMustacheFilteredExpression expressionWithFilterExpression:filterExpression argumentExpression:currentExpression curry:YES]];
                            currentExpression = nil;
                        } else {
                            state = stateError;
                        }
                        break;
                        
                    case '{':
                    case '}':
                    case '&':
                    case '$':
                    case '#':
                    case '^':
                    case '/':
                    case '<':
                    case '>':
                        // invalid as an identifier start
                        state = stateError;
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
                        
                        NSAssert(currentExpression, @"WTF expected currentExpression");
                        state = stateInitial;
                        [filterExpressionStack addObject:currentExpression];
                        currentExpression = nil;
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
                            NSAssert(currentExpression, @"WTF expected currentExpression");
                            NSAssert(filterExpressionStack.count > 0, @"WTF expected non empty filterExpressionStack");
                            state = stateFilterDone;
                            GRMustacheExpression *filterExpression = [filterExpressionStack lastObject];
                            [filterExpressionStack removeLastObject];
                            currentExpression = [GRMustacheFilteredExpression expressionWithFilterExpression:filterExpression argumentExpression:currentExpression curry:NO];
                        } else {
                            state = stateError;
                        }
                    } break;
                        
                    case ',': {
                        // leave stateIdentifier
                        NSString *identifier = [string substringWithRange:(NSRange){ .location = identifierStart, .length = i - identifierStart }];
                        if (currentExpression) {
                            currentExpression = [GRMustacheScopedExpression expressionWithBaseExpression:currentExpression scopeIdentifier:identifier];
                        } else {
                            currentExpression = [GRMustacheIdentifierExpression expressionWithIdentifier:identifier];
                        }
                        
                        if (filterExpressionStack.count > 0) {
                            NSAssert(currentExpression, @"WTF expected currentExpression");
                            NSAssert(filterExpressionStack.count > 0, @"WTF expected non empty filterExpressionStack");
                            state = stateInitial;
                            GRMustacheExpression *filterExpression = [filterExpressionStack lastObject];
                            [filterExpressionStack removeLastObject];
                            [filterExpressionStack addObject:[GRMustacheFilteredExpression expressionWithFilterExpression:filterExpression argumentExpression:currentExpression curry:YES]];
                            currentExpression = nil;
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
                        
                    case ',':
                        state = stateError;
                        break;
                        
                    case '{':
                    case '}':
                    case '&':
                    case '$':
                    case '#':
                    case '^':
                    case '/':
                    case '<':
                    case '>':
                        // invalid as an identifier start
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
                        NSAssert(currentExpression, @"WTF expected currentExpression");
                        state = stateInitial;
                        [filterExpressionStack addObject:currentExpression];
                        currentExpression = nil;
                        break;
                        
                    case ')':
                        if (filterExpressionStack.count > 0) {
                            NSAssert(currentExpression, @"WTF expected currentExpression");
                            NSAssert(filterExpressionStack.count > 0, @"WTF expected non empty filterExpressionStack");
                            state = stateFilterDone;
                            GRMustacheExpression *filterExpression = [filterExpressionStack lastObject];
                            [filterExpressionStack removeLastObject];
                            currentExpression = [GRMustacheFilteredExpression expressionWithFilterExpression:filterExpression argumentExpression:currentExpression curry:NO];
                        } else {
                            state = stateError;
                        }
                        break;
                        
                    case ',':
                        if (filterExpressionStack.count > 0) {
                            NSAssert(currentExpression, @"WTF expected currentExpression");
                            NSAssert(filterExpressionStack.count > 0, @"WTF expected non empty filterExpressionStack");
                            state = stateInitial;
                            GRMustacheExpression *filterExpression = [filterExpressionStack lastObject];
                            [filterExpressionStack removeLastObject];
                            [filterExpressionStack addObject:[GRMustacheFilteredExpression expressionWithFilterExpression:filterExpression argumentExpression:currentExpression curry:YES]];
                            currentExpression = nil;
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
                        NSAssert(currentExpression, @"WTF expected currentExpression");
                        state = stateInitial;
                        [filterExpressionStack addObject:currentExpression];
                        currentExpression = nil;
                        break;
                        
                    case ')':
                        if (filterExpressionStack.count > 0) {
                            NSAssert(currentExpression, @"WTF expected currentExpression");
                            NSAssert(filterExpressionStack.count > 0, @"WTF expected non empty filterExpressionStack");
                            state = stateFilterDone;
                            GRMustacheExpression *filterExpression = [filterExpressionStack lastObject];
                            [filterExpressionStack removeLastObject];
                            currentExpression = [GRMustacheFilteredExpression expressionWithFilterExpression:filterExpression argumentExpression:currentExpression curry:NO];
                        } else {
                            state = stateError;
                        }
                        break;
                        
                    case ',':
                        if (filterExpressionStack.count > 0) {
                            NSAssert(currentExpression, @"WTF expected currentExpression");
                            NSAssert(filterExpressionStack.count > 0, @"WTF expected non empty filterExpressionStack");
                            state = stateInitial;
                            GRMustacheExpression *filterExpression = [filterExpressionStack lastObject];
                            [filterExpressionStack removeLastObject];
                            [filterExpressionStack addObject:[GRMustacheFilteredExpression expressionWithFilterExpression:filterExpression argumentExpression:currentExpression curry:YES]];
                            currentExpression = nil;
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
                NSAssert(NO, @"WTF unexpected state");
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
                NSAssert(currentExpression, @"WTF expected currentExpression");
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
                NSAssert(currentExpression, @"WTF expected currentExpression");
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
                NSAssert(currentExpression, @"WTF expected currentExpression");
                validExpression = currentExpression;
                state = stateValid;
            } else {
                state = stateError;
            }
            break;
            
        case stateFilterDone:
            if (filterExpressionStack.count == 0) {
                NSAssert(currentExpression, @"WTF expected currentExpression");
                validExpression = currentExpression;
                state = stateValid;
            } else {
                state = stateError;
            }
            break;
            
        case stateError:
            break;
            
        default:
            NSAssert(NO, @"WTF unexpected state");
            break;
    }
    
    
    // End
    
    switch (state) {
        case stateEmpty:
            if (outInvalid) {
                *outInvalid = NO;
            }
            return nil;
            
        case stateError:
            if (outInvalid) {
                *outInvalid = YES;
            }
            return nil;
            
        case stateValid:
            NSAssert(validExpression, @"WTF expected validExpression");
            return validExpression;
            
        default:
            NSAssert(NO, @"WTF unespected state");
            break;
    }
    
    return nil;
}

- (NSString *)parseTemplateName:(NSString *)string empty:(BOOL *)empty error:(NSError **)error
{
    NSCharacterSet *whiteSpace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *templateName = [string stringByTrimmingCharactersInSet:whiteSpace];
    if (templateName.length == 0) {
        if (empty != NULL) {
            *empty = YES;
        }
        if (error != NULL) {
            *error = [NSError errorWithDomain:GRMustacheErrorDomain
                                         code:GRMustacheErrorCodeParseError
                                     userInfo:[NSDictionary dictionaryWithObject:@"Missing template name"
                                                                          forKey:NSLocalizedDescriptionKey]];
        }
        return nil;
    }
    if ([templateName rangeOfCharacterFromSet:whiteSpace].location != NSNotFound) {
        if (empty != NULL) {
            *empty = NO;
        }
        if (error != NULL) {
            *error = [NSError errorWithDomain:GRMustacheErrorDomain
                                         code:GRMustacheErrorCodeParseError
                                     userInfo:[NSDictionary dictionaryWithObject:@"Invalid template name"
                                                                          forKey:NSLocalizedDescriptionKey]];
        }
        return nil;
    }
    return templateName;
}

- (NSString *)parsePragma:(NSString *)string
{
    NSString *pragma = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (pragma.length == 0) {
        return nil;
    }
    return pragma;
}


#pragma mark - Private

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

@end
