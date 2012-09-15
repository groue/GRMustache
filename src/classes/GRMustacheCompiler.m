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

#import "GRMustacheCompiler_private.h"
#import "GRMustacheTemplate_private.h"
#import "GRMustacheTemplateRepository_private.h"
#import "GRMustacheTextElement_private.h"
#import "GRMustacheVariableElement_private.h"
#import "GRMustacheSectionElement_private.h"
#import "GRMustacheError.h"
#import "GRMustacheExpression_private.h"
#import "GRMustacheToken_private.h"

@interface GRMustacheCompiler()

/**
 * The fatal error that should be returned by the public method
 * renderingElementsReturningError:.
 * 
 * @see currentElements
 */
@property (nonatomic, retain) NSError *fatalError;

/**
 * After a section opening token has been found, such as {{#foo}} or {{^bar}},
 * contains this token.
 * 
 * This object is always identical to
 * [self.sectionOpeningTokenStack lastObject].
 * 
 * @see sectionOpeningTokenStack
 */
@property (nonatomic, retain) GRMustacheToken *currentSectionOpeningToken;

/**
 * An array where rendering elements are appended as tokens are yielded
 * by a parser.
 * 
 * This array is also the one that would be returned by the public method
 * renderingElementsReturningError:.
 * 
 * As such, it is nil whenever an error occurs.
 * 
 * This object is always identical to [self.elementsStack lastObject].
 * 
 * @see elementsStack
 * @see fatalError
 */
@property (nonatomic, retain) NSMutableArray *currentElements;

/**
 * The stack of arrays where rendering elements should be appended as tokens are
 * yielded by a parser.
 * 
 * This stack grows with section opening tokens, and shrinks with section
 * closing tokens.
 * 
 * @see currentElements
 */
@property (nonatomic, retain) NSMutableArray *elementsStack;

/**
 * This stack grows with section opening tokens, and shrinks with section
 * closing tokens.
 * 
 * @see currentSectionOpeningToken
 */
@property (nonatomic, retain) NSMutableArray *sectionOpeningTokenStack;

/**
 * This method is called whenever an error has occurred beyond any repair hope.
 * 
 * @param fatalError  The fatal error
 */
- (void)failWithFatalError:(NSError *)fatalError;

/**
 * Builds and returns an NSError of domain GRMustacheErrorDomain, code
 * GRMustacheErrorCodeParseError, related to a specific location in a template,
 * represented by the token argument.
 * 
 * @param token         The GRMustacheToken where the parse error has been
 *                      found.
 * @param description   A NSString that fills the NSLocalizedDescriptionKey key
 *                      of the error's userInfo.
 *
 * @return An NSError
 */
- (NSError *)parseErrorAtToken:(GRMustacheToken *)token description:(NSString *)description;

@end

@implementation GRMustacheCompiler
@synthesize fatalError=_fatalError;
@synthesize currentSectionOpeningToken=_currentSectionOpeningToken;
@synthesize templateRepository=_templateRepository;
@synthesize currentElements=_currentElements;
@synthesize elementsStack=_elementsStack;
@synthesize sectionOpeningTokenStack=_sectionOpeningTokenStack;

- (id)init
{
    self = [super init];
    if (self) {
        _currentElements = [[NSMutableArray alloc] initWithCapacity:20];
        _elementsStack = [[NSMutableArray alloc] initWithCapacity:20];
        [_elementsStack addObject:_currentElements];
        _sectionOpeningTokenStack = [[NSMutableArray alloc] initWithCapacity:20];
    }
    return self;
}

- (NSArray *)renderingElementsReturningError:(NSError **)outError
{
    // Has a fatal error occurred?
    if (_currentElements == nil) {
        NSAssert(_fatalError, @"We should have an error when _currentElements is nil");
        if (outError != NULL) {
            *outError = [[_fatalError retain] autorelease];
        }
        return nil;
    }
    
    // Unclosed section?
    if (_currentSectionOpeningToken) {
        if (outError != NULL) {
            *outError = [self parseErrorAtToken:_currentSectionOpeningToken description:[NSString stringWithFormat:@"Unclosed %@ section", _currentSectionOpeningToken.templateSubstring]];
        }
        return nil;
    }
    
    // Success
    return [[_currentElements retain] autorelease];
}

- (void)dealloc
{
    [_fatalError release];
    [_currentSectionOpeningToken release];
    [_currentElements release];
    [_elementsStack release];
    [_sectionOpeningTokenStack release];
    [super dealloc];
}


#pragma mark GRMustacheParserDelegate

- (BOOL)parser:(GRMustacheParser *)parser shouldContinueAfterParsingToken:(GRMustacheToken *)token
{
    // Refuse tokens after a fatal error has occurred.
    if (_currentElements == nil) {
        return NO;
    }
    
    switch (token.type) {
        case GRMustacheTokenTypeSetDelimiter:
        case GRMustacheTokenTypeComment:
            // Ignore
            break;
            
        case GRMustacheTokenTypePragma:
            // Ignore
            break;
            
        case GRMustacheTokenTypeText:
            // Parser validation
            NSAssert([token.value.text isKindOfClass:[NSString class]], @"WTF parser?");
            NSAssert(token.value.text.length > 0, @"WTF parser?");
            
            // Success: append GRMustacheTextElement
            [_currentElements addObject:[GRMustacheTextElement textElementWithString:token.value.text]];
            break;
            
            
        case GRMustacheTokenTypeEscapedVariable: {
            // Expression validation
            if (token.value.expression == nil) {
                [self failWithFatalError:[self parseErrorAtToken:token description:[NSString stringWithFormat:@"Missing expression"]]];
                return NO;
            }
            
            // Parser validation
            NSAssert([token.value.expression isKindOfClass:[GRMustacheExpression class]], @"WTF parser?");
            
            // Success: append GRMustacheVariableElement
            [_currentElements addObject:[GRMustacheVariableElement variableElementWithExpression:token.value.expression raw:NO]];
        } break;
            
            
        case GRMustacheTokenTypeUnescapedVariable: {
            // Expression validation
            if (token.value.expression == nil) {
                [self failWithFatalError:[self parseErrorAtToken:token description:[NSString stringWithFormat:@"Missing expression"]]];
                return NO;
            }
            
            // Parser validation
            NSAssert([token.value.expression isKindOfClass:[GRMustacheExpression class]], @"WTF parser?");
            
            // Success: append GRMustacheVariableElement
            [_currentElements addObject:[GRMustacheVariableElement variableElementWithExpression:token.value.expression raw:YES]];
        } break;
            
            
        case GRMustacheTokenTypeSectionOpening:
        case GRMustacheTokenTypeInvertedSectionOpening: {
            // Expression validation
            if (token.value.expression == nil) {
                [self failWithFatalError:[self parseErrorAtToken:token description:[NSString stringWithFormat:@"Missing expression"]]];
                return NO;
            }
            
            // Parser validation
            NSAssert([token.value.expression isKindOfClass:[GRMustacheExpression class]], @"WTF parser?");
            
            // Expand stacks
            self.currentSectionOpeningToken = token;
            self.currentElements = [[[NSMutableArray alloc] initWithCapacity:20] autorelease];
            [_sectionOpeningTokenStack addObject:token];
            [_elementsStack addObject:_currentElements];
        } break;
            
            
        case GRMustacheTokenTypeSectionClosing: {
            // Expression validation
            // We need an expression, unless parser has the FILTERS pragma, in which case we accept `{{/}}` closing tags.
            if (token.value.expression == nil && ![parser.pragmas containsObject:@"FILTERS"]) {
                [self failWithFatalError:[self parseErrorAtToken:token description:[NSString stringWithFormat:@"Missing expression"]]];
                return NO;
            }
            
            // Parser validation
            if (token.value.expression) {
                NSAssert([token.value.expression isKindOfClass:[GRMustacheExpression class]], @"WTF parser?");
            }
            
            // Validate token: section ending should match section opening
            if (token.value.expression && ![token.value.expression isEqual:_currentSectionOpeningToken.value.expression]) {
                [self failWithFatalError:[self parseErrorAtToken:token description:[NSString stringWithFormat:@"Unexpected %@ section closing tag", token.templateSubstring]]];
                return NO;
            }

            // Nothing prevents tokens to come from different template strings.
            // We, however, do not support this case, because GRMustacheSectionElement
            // builds from a single template string and a single innerRange.
            NSAssert(_currentSectionOpeningToken.templateString == token.templateString, @"not implemented");
            
            // Success: append GRMustacheSectionElement and shrink stacks
            NSRange openingTokenRange = _currentSectionOpeningToken.range;
            NSRange innerRange = NSMakeRange(openingTokenRange.location + openingTokenRange.length, token.range.location - (openingTokenRange.location + openingTokenRange.length));
            GRMustacheSectionElement *sectionElement = [GRMustacheSectionElement sectionElementWithExpression:_currentSectionOpeningToken.value.expression
                                                                                           templateRepository:_templateRepository
                                                                                               templateString:token.templateString
                                                                                                   innerRange:innerRange
                                                                                                     inverted:(_currentSectionOpeningToken.type == GRMustacheTokenTypeInvertedSectionOpening)
                                                                                                     elements:_currentElements];
            
            [_sectionOpeningTokenStack removeLastObject];
            [_elementsStack removeLastObject];
            self.currentSectionOpeningToken = [_sectionOpeningTokenStack lastObject];
            self.currentElements = [_elementsStack lastObject];
            [_currentElements addObject:sectionElement];
        } break;
            
            
        case GRMustacheTokenTypePartial: {
            // Partial name validation
            if (token.value.partialName == nil) {
                [self failWithFatalError:[self parseErrorAtToken:token description:[NSString stringWithFormat:@"Missing partial name"]]];
                return NO;
            }
            
            // Parser validation
            NSAssert([token.value.partialName isKindOfClass:[NSString class]], @"WTF parser?");
            
            // Validate the renderingElementForPartialName:error: contract:
            // Non nil, non empty, white-space stripped partial name.
            NSAssert([token.value.partialName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0, @"WTF parser?");
            
            // Ask templateRepository for rendering element
            NSError *partialError;
            id<GRMustacheRenderingElement> partial = [_templateRepository renderingElementForPartialName:token.value.partialName error:&partialError];
            if (partial == nil) {
                [self failWithFatalError:partialError];
                return NO;
            }
            
            // Success: append partial element
            [_currentElements addObject:partial];
        } break;
            
        default:
            NSAssert(NO, @"");
            break;
            
    }
    return YES;
}

- (void)parser:(GRMustacheParser *)parser didFailWithError:(NSError *)error
{
    [self failWithFatalError:error];
}

#pragma mark Private

- (void)failWithFatalError:(NSError *)fatalError
{
    // Make sure renderingElementsReturningError: returns correct results:
    self.fatalError = fatalError;
    self.currentElements = nil;
    
    // All those objects are useless, now
    self.currentSectionOpeningToken = nil;
    self.elementsStack = nil;
    self.sectionOpeningTokenStack = nil;
}

- (NSError *)parseErrorAtToken:(GRMustacheToken *)token description:(NSString *)description
{
    NSString *localizedDescription;
    if (token.templateID) {
        localizedDescription = [NSString stringWithFormat:@"Parse error at line %lu of template %@: %@", (unsigned long)token.line, token.templateID, description];
    } else {
        localizedDescription = [NSString stringWithFormat:@"Parse error at line %lu: %@", (unsigned long)token.line, description];
    }
    return [NSError errorWithDomain:GRMustacheErrorDomain
                               code:GRMustacheErrorCodeParseError
                           userInfo:[NSDictionary dictionaryWithObject:localizedDescription forKey:NSLocalizedDescriptionKey]];
}

@end
