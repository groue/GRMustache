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
#import "GRMustacheTextElement_private.h"
#import "GRMustacheVariableElement_private.h"
#import "GRMustacheSection_private.h"
#import "GRMustacheInvocation_private.h"
#import "GRMustacheError.h"

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

/**
 * Returns a GRMustacheInvocation instance out of a GRMustacheToken.
 * 
 * For instance, the token {{foo.bar}} would yield an invocation that would
 * invoke `foo` then `bar`.
 * 
 * @param token     A GRMustacheToken
 * @param outError  If there is an error building the invocation, such as a
 *                  parsing error, upon return contains an NSError object that
 *                  describes the problem.
 *
 * @returns A GRMustacheInvocation
 */
- (GRMustacheInvocation *)invocationWithToken:(GRMustacheToken *)token error:(NSError **)outError;
@end

@implementation GRMustacheCompiler
@synthesize fatalError=_fatalError;
@synthesize currentSectionOpeningToken=_currentSectionOpeningToken;
@synthesize dataSource=_dataSource;
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
            *outError = [self parseErrorAtToken:_currentSectionOpeningToken description:[NSString stringWithFormat:@"Unclosed `%@` section", _currentSectionOpeningToken.content]];
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
            
            
        case GRMustacheTokenTypeText:
            // Success: append GRMustacheTextElement
            [_currentElements addObject:[GRMustacheTextElement textElementWithString:token.content]];
            break;
            
            
        case GRMustacheTokenTypeEscapedVariable: {
            // Build invocation
            NSError *invocationError;
            GRMustacheInvocation *invocation = [self invocationWithToken:token error:&invocationError];
            if (invocation == nil) {
                [self failWithFatalError:invocationError];
                return NO;
            }
            
            // Success: append GRMustacheVariableElement
            [_currentElements addObject:[GRMustacheVariableElement variableElementWithInvocation:invocation raw:NO]];
        } break;
            
            
        case GRMustacheTokenTypeUnescapedVariable: {
            // Build invocation
            NSError *invocationError;
            GRMustacheInvocation *invocation = [self invocationWithToken:token error:&invocationError];
            if (invocation == nil) {
                [self failWithFatalError:invocationError];
                return NO;
            }
            
            // Success: append GRMustacheVariableElement
            [_currentElements addObject:[GRMustacheVariableElement variableElementWithInvocation:invocation raw:YES]];
        } break;
            
            
        case GRMustacheTokenTypeSectionOpening:
        case GRMustacheTokenTypeInvertedSectionOpening: {
            // Expand stacks
            self.currentSectionOpeningToken = token;
            self.currentElements = [NSMutableArray array];
            [_sectionOpeningTokenStack addObject:token];
            [_elementsStack addObject:_currentElements];
        } break;
            
            
        case GRMustacheTokenTypeSectionClosing: {
            // Validate token: section ending should match section opening
            if (![token.content isEqualToString:_currentSectionOpeningToken.content]) {
                [self failWithFatalError:[self parseErrorAtToken:token description:[NSString stringWithFormat:@"Unexpected `%@` section closing tag", token.content]]];
                return NO;
            }

            // Build invocation
            NSError *invocationError;
            GRMustacheInvocation *invocation = [self invocationWithToken:_currentSectionOpeningToken error:&invocationError];
            if (invocation == nil) {
                [self failWithFatalError:invocationError];
                return NO;
            }
            
            // Nothing prevents tokens to come from different template strings.
            // We, however, do not support this case, because GRMustacheSection
            // builds from a single template string and a single innerRange.
            NSAssert(_currentSectionOpeningToken.templateString == token.templateString, @"not implemented");
            
            // Success: append GRMustacheSection and shrink stacks
            NSRange openingTokenRange = _currentSectionOpeningToken.range;
            NSRange innerRange = NSMakeRange(openingTokenRange.location + openingTokenRange.length, token.range.location - (openingTokenRange.location + openingTokenRange.length));
            GRMustacheSection *section = [GRMustacheSection sectionElementWithInvocation:invocation
                                                                          templateString:token.templateString
                                                                              innerRange:innerRange
                                                                                inverted:(_currentSectionOpeningToken.type == GRMustacheTokenTypeInvertedSectionOpening)
                                                                                elements:_currentElements];
            
            [_sectionOpeningTokenStack removeLastObject];
            [_elementsStack removeLastObject];
            self.currentSectionOpeningToken = [_sectionOpeningTokenStack lastObject];
            self.currentElements = [_elementsStack lastObject];
            [_currentElements addObject:section];
        } break;
            
            
        case GRMustacheTokenTypePartial: {
            // Validate token in order to fullfill the compiler:renderingElementForPartialName:error: contract:
            // Non nil, non empty, white-space stripped partial name.
            // The token content has already been stripped of white spaces, so we just have to test for its length.
            if (token.content.length == 0) {
                [self failWithFatalError:[self parseErrorAtToken:token description:@"Empty partial tag"]];
                return NO;
            }
            
            // Ask dataSource for rendering element
            NSError *partialError;
            id<GRMustacheRenderingElement> partial = [_dataSource compiler:self renderingElementForPartialName:token.content error:&partialError];
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

- (GRMustacheInvocation *)invocationWithToken:(GRMustacheToken *)token error:(NSError **)outError
{
    NSString *content = token.content;
    NSUInteger length = content.length;
    BOOL acceptKey = YES;
    BOOL acceptSeparator = YES;
    NSMutableArray *keys = [NSMutableArray array];
    unichar c;
    NSUInteger keyLocation = 0;
    for (NSUInteger i = 0; i < length; ++i) {
        c = [content characterAtIndex:i];
        switch (c) {
            case '.':
                if (acceptSeparator) {
                    if (i==0) {
                        // leading dot: "." or ".foo…"
                        [keys addObject:@"."];
                    } else {
                        // dot in the middle: "foo.bar…"
                        [keys addObject:[content substringWithRange:NSMakeRange(keyLocation, i - keyLocation)]];
                    }
                    keyLocation = i + 1;
                    acceptKey = YES;
                    acceptSeparator = NO;
                } else {
                    if (outError != NULL) {
                        *outError = [self parseErrorAtToken:token description:[NSString stringWithFormat:@"Invalid key: %@", content]];
                    }
                    return nil;
                }
                break;
                
            default:
                if (acceptKey) {
                    acceptKey = YES;
                    acceptSeparator = YES;
                } else {
                    if (outError != NULL) {
                        *outError = [self parseErrorAtToken:token description:[NSString stringWithFormat:@"Invalid key: %@", content]];
                    }
                    return nil;
                }
        }
    }
    if (acceptSeparator) {
        if (length <= keyLocation) {
            if (outError != NULL) {
                *outError = [self parseErrorAtToken:token description:@"Missing key"];
            }
            return nil;
        }
        [keys addObject:[content substringWithRange:NSMakeRange(keyLocation, length - keyLocation)]];
    } else if (acceptKey && length > 1) {
        // dot at the end: "…foo."
        if (outError != NULL) {
            *outError = [self parseErrorAtToken:token description:[NSString stringWithFormat:@"Invalid key: %@", content]];
        }
        return nil;
    }
    
    return [GRMustacheInvocation invocationWithToken:token keys:keys];
}

@end
