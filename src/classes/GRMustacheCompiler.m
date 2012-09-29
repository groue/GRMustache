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
#import "GRMustacheTemplateOverride_private.h"
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
 * After a opening token has been found such as {{#foo}}, {{^bar}}, or {{<baz}},
 * contains this token.
 * 
 * This object is always identical to
 * [self.openingTokenStack lastObject].
 * 
 * @see openingTokenStack
 */
@property (nonatomic, retain) GRMustacheToken *currentOpeningToken;

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
 * @see currentOpeningToken
 */
@property (nonatomic, retain) NSMutableArray *openingTokenStack;

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
@synthesize currentOpeningToken=_currentOpeningToken;
@synthesize templateRepository=_templateRepository;
@synthesize currentElements=_currentElements;
@synthesize elementsStack=_elementsStack;
@synthesize openingTokenStack=_openingTokenStack;

- (id)init
{
    self = [super init];
    if (self) {
        _currentElements = [[NSMutableArray alloc] initWithCapacity:20];
        _elementsStack = [[NSMutableArray alloc] initWithCapacity:20];
        [_elementsStack addObject:_currentElements];
        _openingTokenStack = [[NSMutableArray alloc] initWithCapacity:20];
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
    if (_currentOpeningToken) {
        if (outError != NULL) {
            *outError = [self parseErrorAtToken:_currentOpeningToken description:[NSString stringWithFormat:@"Unclosed %@ section", _currentOpeningToken.templateSubstring]];
        }
        return nil;
    }
    
    // Success
    return [[_currentElements retain] autorelease];
}

- (void)dealloc
{
    [_fatalError release];
    [_currentOpeningToken release];
    [_currentElements release];
    [_elementsStack release];
    [_openingTokenStack release];
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
            NSAssert(token.text.length > 0, @"WTF parser?");
            
            // Success: append GRMustacheTextElement
            [_currentElements addObject:[GRMustacheTextElement textElementWithString:token.text]];
            break;
            
            
        case GRMustacheTokenTypeEscapedVariable: {
            // Expression validation
            if (token.expression == nil) {
                if (token.invalidExpression) {
                    [self failWithFatalError:[self parseErrorAtToken:token description:[NSString stringWithFormat:@"Invalid expression"]]];
                    return NO;
                } else {
                    [self failWithFatalError:[self parseErrorAtToken:token description:[NSString stringWithFormat:@"Missing expression"]]];
                    return NO;
                }
            }
            
            // Success: append GRMustacheVariableElement
            [_currentElements addObject:[GRMustacheVariableElement variableElementWithExpression:token.expression
                                                                              templateRepository:_templateRepository
                                                                                             raw:NO]];
        } break;
            
            
        case GRMustacheTokenTypeUnescapedVariable: {
            // Expression validation
            if (token.expression == nil) {
                if (token.invalidExpression) {
                    [self failWithFatalError:[self parseErrorAtToken:token description:[NSString stringWithFormat:@"Invalid expression"]]];
                    return NO;
                } else {
                    [self failWithFatalError:[self parseErrorAtToken:token description:[NSString stringWithFormat:@"Missing expression"]]];
                    return NO;
                }
            }
            
            // Success: append GRMustacheVariableElement
            [_currentElements addObject:[GRMustacheVariableElement variableElementWithExpression:token.expression
                                                                              templateRepository:_templateRepository
                                                                                             raw:YES]];
        } break;
            
            
        case GRMustacheTokenTypeSectionOpening:
        case GRMustacheTokenTypeInvertedSectionOpening:
        case GRMustacheTokenTypeOverridableSectionOpening: {
            // Expression validation
            if (token.expression == nil) {
                if (token.invalidExpression) {
                    [self failWithFatalError:[self parseErrorAtToken:token description:[NSString stringWithFormat:@"Invalid expression"]]];
                    return NO;
                } else {
                    [self failWithFatalError:[self parseErrorAtToken:token description:[NSString stringWithFormat:@"Missing expression"]]];
                    return NO;
                }
            }
            
            // Expand stacks
            self.currentOpeningToken = token;
            self.currentElements = [[[NSMutableArray alloc] initWithCapacity:20] autorelease];
            [_openingTokenStack addObject:token];
            [_elementsStack addObject:_currentElements];
        } break;
            
            
        case GRMustacheTokenTypeClosing: {
            if (_currentOpeningToken == nil) {
                [self failWithFatalError:[self parseErrorAtToken:token description:[NSString stringWithFormat:@"Unexpected %@ closing tag", token.templateSubstring]]];
                return NO;
            }
            
            // What are we closing?
            
            id<GRMustacheRenderingElement> wrapperElement = nil;
            switch (_currentOpeningToken.type) {
                case GRMustacheTokenTypeSectionOpening:
                case GRMustacheTokenTypeInvertedSectionOpening:
                case GRMustacheTokenTypeOverridableSectionOpening: {
                    // Expression validation
                    // We need a valid expression that matches section opening,
                    // or an empty `{{/}}` closing tags.
                    if (token.expression == nil && token.invalidExpression) {
                        [self failWithFatalError:[self parseErrorAtToken:token description:[NSString stringWithFormat:@"Invalid expression"]]];
                        return NO;
                    }
                    if (token.expression && ![token.expression isEqual:_currentOpeningToken.expression]) {
                        [self failWithFatalError:[self parseErrorAtToken:token description:[NSString stringWithFormat:@"Unexpected %@ section closing tag", token.templateSubstring]]];
                        return NO;
                    }
                    
                    // Nothing prevents tokens to come from different template strings.
                    // We, however, do not support this case, because GRMustacheSectionElement
                    // builds from a single template string and a single innerRange.
                    NSAssert(_currentOpeningToken.templateString == token.templateString, @"not implemented");
                    
                    // Success: append GRMustacheSectionElement and shrink stacks
                    NSRange openingTokenRange = _currentOpeningToken.range;
                    NSRange innerRange = NSMakeRange(openingTokenRange.location + openingTokenRange.length, token.range.location - (openingTokenRange.location + openingTokenRange.length));
                    wrapperElement = [GRMustacheSectionElement sectionElementWithExpression:_currentOpeningToken.expression
                                                                         templateRepository:_templateRepository
                                                                             templateString:token.templateString
                                                                                 innerRange:innerRange
                                                                                   inverted:(_currentOpeningToken.type == GRMustacheTokenTypeInvertedSectionOpening)
                                                                                overridable:(_currentOpeningToken.type == GRMustacheTokenTypeOverridableSectionOpening)
                                                                              innerElements:_currentElements];
                    
                } break;
                    
                case GRMustacheTokenTypeOverridablePartial: {
                    // Validate token: overridable template ending should be missing, or match overridable template opening
                    if (token.partialName && ![token.partialName isEqual:_currentOpeningToken.partialName]) {
                        [self failWithFatalError:[self parseErrorAtToken:token description:[NSString stringWithFormat:@"Unexpected %@ super template closing tag", token.templateSubstring]]];
                        return NO;
                    }
                    
                    // Ask templateRepository for overridable template
                    NSError *templateError;
                    GRMustacheTemplate *template = [_templateRepository templateForName:_currentOpeningToken.partialName error:&templateError];
                    if (template == nil) {
                        [self failWithFatalError:templateError];
                        return NO;
                    }
                    
                    wrapperElement = [GRMustacheTemplateOverride templateOverrideWithTemplate:template innerElements:_currentElements];
                } break;
                    
                default:
                    NSAssert(NO, @"WTF");
                    break;
            }
            
            NSAssert(wrapperElement, @"WTF");
            [_openingTokenStack removeLastObject];
            [_elementsStack removeLastObject];
            self.currentOpeningToken = [_openingTokenStack lastObject];
            self.currentElements = [_elementsStack lastObject];
            [_currentElements addObject:wrapperElement];
        } break;
            
            
        case GRMustacheTokenTypePartial: {
            // Template name validation
            if (token.partialName == nil) {
                [self failWithFatalError:[self parseErrorAtToken:token description:[NSString stringWithFormat:@"Missing partial name"]]];
                return NO;
            }
            
            // Ask templateRepository for partial template
            NSError *templateError;
            GRMustacheTemplate *template = [_templateRepository templateForName:token.partialName error:&templateError];
            if (template == nil) {
                [self failWithFatalError:templateError];
                return NO;
            }
            
            // Success: append template element
            [_currentElements addObject:template];
        } break;
        
        
        case GRMustacheTokenTypeOverridablePartial: {
            // Template name validation
            if (token.partialName == nil) {
                [self failWithFatalError:[self parseErrorAtToken:token description:[NSString stringWithFormat:@"Missing super template name"]]];
                return NO;
            }
            
            // Expand stacks
            self.currentOpeningToken = token;
            self.currentElements = [[[NSMutableArray alloc] initWithCapacity:20] autorelease];
            [_openingTokenStack addObject:token];
            [_elementsStack addObject:_currentElements];
        } break;
            
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
    self.currentOpeningToken = nil;
    self.elementsStack = nil;
    self.openingTokenStack = nil;
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
