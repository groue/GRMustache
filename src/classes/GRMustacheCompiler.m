// The MIT License
//
// Copyright (c) 2014 Gwendal Roué
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
#import "GRMustachePartial_private.h"
#import "GRMustacheTemplateRepository_private.h"
#import "GRMustacheTextNode_private.h"
#import "GRMustacheVariableNode_private.h"
#import "GRMustacheSectionNode_private.h"
#import "GRMustacheInheritableSection_private.h"
#import "GRMustacheInheritablePartial_private.h"
#import "GRMustacheExpressionParser_private.h"
#import "GRMustacheExpression_private.h"
#import "GRMustacheToken_private.h"
#import "GRMustacheAST_private.h"
#import "GRMustacheError.h"

@interface GRMustacheCompiler()

/**
 * The fatal error that should be returned by the public method
 * ASTNodesReturningError:.
 *
 * @see currentASTNodes
 */
@property (nonatomic, retain) NSError *fatalError;

/**
 * After an opening token has been found such as {{#A}}, {{^B}}, or {{<C}},
 * contains this token.
 *
 * This object is always identical to
 * [self.openingTokenStack lastObject].
 *
 * @see openingTokenStack
 */
@property (nonatomic, assign) GRMustacheToken *currentOpeningToken;

/**
 * After an opening token has been found such as {{#A}}, {{^B}}, or {{<C}},
 * contains the value of this token (expression or partial name).
 *
 * This object is always identical to
 * [self.tagValueStack lastObject].
 *
 * @see tagValueStack
 */
@property (nonatomic, assign) NSObject *currentTagValue;

/**
 * An array where AST nodes are appended as tokens are yielded
 * by a parser.
 *
 * This array is also the one that would be returned by the public method
 * ASTNodesReturningError:.
 *
 * As such, it is nil whenever an error occurs.
 *
 * This object is always identical to [self.ASTNodesStack lastObject].
 *
 * @see ASTNodesStack
 * @see fatalError
 */
@property (nonatomic, assign) NSMutableArray *currentASTNodes;

/**
 * The stack of arrays where AST nodes should be appended as tokens are
 * yielded by a parser.
 *
 * This stack grows with section opening tokens, and shrinks with section
 * closing tokens.
 *
 * @see currentASTNodes
 */
@property (nonatomic, retain) NSMutableArray *ASTNodesStack;

/**
 * This stack grows with section opening tokens, and shrinks with section
 * closing tokens.
 *
 * @see currentOpeningToken
 */
@property (nonatomic, retain) NSMutableArray *openingTokenStack;

/**
 * This stack grows with section opening tokens, and shrinks with section
 * closing tokens.
 *
 * @see currentTagValue
 */
@property (nonatomic, retain) NSMutableArray *tagValueStack;

@end

@implementation GRMustacheCompiler
@synthesize fatalError=_fatalError;
@synthesize templateRepository=_templateRepository;
@synthesize baseTemplateID=_baseTemplateID;
@synthesize currentOpeningToken=_currentOpeningToken;
@synthesize openingTokenStack=_openingTokenStack;
@synthesize currentTagValue=_currentTagValue;
@synthesize tagValueStack=_tagValueStack;
@synthesize currentASTNodes=_currentASTNodes;
@synthesize ASTNodesStack=_ASTNodesStack;

- (instancetype)initWithContentType:(GRMustacheContentType)contentType
{
    self = [super init];
    if (self) {
        _currentASTNodes = [[[NSMutableArray alloc] initWithCapacity:20] autorelease];
        _ASTNodesStack = [[NSMutableArray alloc] initWithCapacity:20];
        [_ASTNodesStack addObject:_currentASTNodes];
        _openingTokenStack = [[NSMutableArray alloc] initWithCapacity:20];
        _tagValueStack = [[NSMutableArray alloc] initWithCapacity:20];
        _contentType = contentType;
        _contentTypeLocked = NO;
    }
    return self;
}

- (GRMustacheAST *)ASTReturningError:(NSError **)error
{
    // Has a fatal error occurred?
    if (_currentASTNodes == nil) {
        NSAssert(_fatalError, @"We should have an error when _currentASTNodes is nil");
        if (error != NULL) {
            *error = [[_fatalError retain] autorelease];
        } else {
            NSLog(@"GRMustache error: %@", _fatalError.localizedDescription);
        }
        return nil;
    }
    
    // Unclosed section?
    if (_currentOpeningToken) {
        NSError *parseError = [self parseErrorAtToken:_currentOpeningToken description:[NSString stringWithFormat:@"Unclosed %@ section", _currentOpeningToken.templateSubstring]];
        if (error != NULL) {
            *error = parseError;
        } else {
            NSLog(@"GRMustache error: %@", parseError.localizedDescription);
        }
        return nil;
    }
    
    // Success
    return [GRMustacheAST ASTWithASTNodes:_currentASTNodes contentType:_contentType];
}

- (void)dealloc
{
    [_fatalError release];
    [_ASTNodesStack release];
    [_tagValueStack release];
    [_openingTokenStack release];
    [_baseTemplateID release];
    [super dealloc];
}


#pragma mark GRMustacheParserDelegate

- (BOOL)parser:(GRMustacheParser *)parser shouldContinueAfterParsingToken:(GRMustacheToken *)token
{
    // Refuse tokens after a fatal error has occurred.
    if (_currentASTNodes == nil) {
        return NO;
    }
    
    GRMustacheExpressionParser *expressionParser = [[[GRMustacheExpressionParser alloc] init] autorelease];
    
    switch (token.type) {
        case GRMustacheTokenTypeSetDelimiter:
        case GRMustacheTokenTypeComment:
            // ignore
            break;
            
        case GRMustacheTokenTypePragma: {
            NSString *pragma = [parser parsePragma:token.tagInnerContent];
            if ([pragma isEqualToString:@"CONTENT_TYPE:TEXT"]) {
                if (_contentTypeLocked) {
                    [self failWithFatalError:[self parseErrorAtToken:token description:[NSString stringWithFormat:@"CONTENT_TYPE:TEXT pragma tag must prepend any Mustache variable, section, or partial tag."]]];
                    return NO;
                }
                _contentType = GRMustacheContentTypeText;
            }
            if ([pragma isEqualToString:@"CONTENT_TYPE:HTML"]) {
                if (_contentTypeLocked) {
                    [self failWithFatalError:[self parseErrorAtToken:token description:[NSString stringWithFormat:@"CONTENT_TYPE:HTML pragma tag must prepend any Mustache variable, section, or partial tag."]]];
                    return NO;
                }
                _contentType = GRMustacheContentTypeHTML;
            }
        } break;
            
        case GRMustacheTokenTypeText:
            // Parser validation
            NSAssert(token.templateSubstring.length > 0, @"WTF empty GRMustacheTokenTypeContent");
            
            // Success: append GRMustacheTextASTNode
            [_currentASTNodes addObject:[GRMustacheTextNode textNodeWithText:token.templateSubstring]];
            break;
            
            
        case GRMustacheTokenTypeEscapedVariable: {
            // Expression validation
            NSError *error;
            GRMustacheExpression *expression = [expressionParser parseExpression:token.tagInnerContent empty:NULL error:&error];
            if (expression == nil) {
                [self failWithFatalError:[self parseErrorAtToken:token description:error.localizedDescription]];
                return NO;
            }
            
            // Success: append GRMustacheVariableTag
            expression.token = token;
            [_currentASTNodes addObject:[GRMustacheVariableNode variableNodeWithExpression:expression escapesHTML:YES]];
            
            // lock _contentType
            _contentTypeLocked = YES;
        } break;
            
            
        case GRMustacheTokenTypeUnescapedVariable: {
            // Expression validation
            NSError *error;
            GRMustacheExpression *expression = [expressionParser parseExpression:token.tagInnerContent empty:NULL error:&error];
            if (expression == nil) {
                [self failWithFatalError:[self parseErrorAtToken:token description:error.localizedDescription]];
                return NO;
            }
            
            // Success: append GRMustacheVariableTag
            expression.token = token;
            [_currentASTNodes addObject:[GRMustacheVariableNode variableNodeWithExpression:expression escapesHTML:NO]];
            
            // lock _contentType
            _contentTypeLocked = YES;
        } break;
            
            
        case GRMustacheTokenTypeSectionOpening: {
            // Expression validation
            NSError *error;
            BOOL empty;
            GRMustacheExpression *expression = [expressionParser parseExpression:token.tagInnerContent empty:&empty error:&error];
            
            if (_currentOpeningToken &&
                _currentOpeningToken.type == GRMustacheTokenTypeInvertedSectionOpening &&
                ((expression == nil && empty) || (expression != nil && [expression isEqual:_currentTagValue])))
            {
                // We found the "else" close of an inverted section:
                // {{^foo}}...{{#}}...
                // {{^foo}}...{{#foo}}...
                
                // Insert a new inverted section and prepare a regular one
                
                NSRange openingTokenRange = _currentOpeningToken.range;
                NSRange innerRange = NSMakeRange(openingTokenRange.location + openingTokenRange.length, token.range.location - (openingTokenRange.location + openingTokenRange.length));
                GRMustacheSectionNode *sectioNode = [GRMustacheSectionNode sectionNodeWithExpression:(GRMustacheExpression *)_currentTagValue
                                                                                            inverted:YES
                                                                                      templateString:token.templateString
                                                                                          innerRange:innerRange
                                                                                            ASTNodes:_currentASTNodes];
                
                [_openingTokenStack removeLastObject];
                self.currentOpeningToken = token;
                [_openingTokenStack addObject:_currentOpeningToken];
                
                [_ASTNodesStack removeLastObject];
                [[_ASTNodesStack lastObject] addObject:sectioNode];
                
                self.currentASTNodes = [[[NSMutableArray alloc] initWithCapacity:20] autorelease];
                [_ASTNodesStack addObject:_currentASTNodes];
                
            } else {
                // This is a new regular section
                
                // Validate expression
                if (expression == nil) {
                    [self failWithFatalError:[self parseErrorAtToken:token description:error.localizedDescription]];
                    return NO;
                }
                
                // Prepare a new section
                
                expression.token = token;
                self.currentTagValue = expression;
                [_tagValueStack addObject:_currentTagValue];
                
                self.currentOpeningToken = token;
                [_openingTokenStack addObject:_currentOpeningToken];
                
                self.currentASTNodes = [[[NSMutableArray alloc] initWithCapacity:20] autorelease];
                [_ASTNodesStack addObject:_currentASTNodes];
                
                // lock _contentType
                _contentTypeLocked = YES;
            }
        } break;
            
            
        case GRMustacheTokenTypeInvertedSectionOpening: {
            // Expression validation
            NSError *error;
            BOOL empty;
            GRMustacheExpression *expression = [expressionParser parseExpression:token.tagInnerContent empty:&empty error:&error];
            
            if (_currentOpeningToken &&
                _currentOpeningToken.type == GRMustacheTokenTypeSectionOpening &&
                ((expression == nil && empty) || (expression != nil && [expression isEqual:_currentTagValue])))
            {
                // We found the "else" close of a regular or inheritable section:
                // {{#foo}}...{{^}}...{{/foo}}
                // {{#foo}}...{{^foo}}...{{/foo}}
                //
                // There is no support for {{$foo}}...{{^foo}}...{{/foo}}.
                
                // Insert a new section and prepare an inverted one
                
                NSRange openingTokenRange = _currentOpeningToken.range;
                NSRange innerRange = NSMakeRange(openingTokenRange.location + openingTokenRange.length, token.range.location - (openingTokenRange.location + openingTokenRange.length));
                GRMustacheSectionNode *sectioNode = [GRMustacheSectionNode sectionNodeWithExpression:(GRMustacheExpression *)_currentTagValue
                                                                                            inverted:NO
                                                                                      templateString:token.templateString
                                                                                          innerRange:innerRange
                                                                                            ASTNodes:_currentASTNodes];
                
                [_openingTokenStack removeLastObject];
                self.currentOpeningToken = token;
                [_openingTokenStack addObject:_currentOpeningToken];
                
                [_ASTNodesStack removeLastObject];
                [[_ASTNodesStack lastObject] addObject:sectioNode];
                
                self.currentASTNodes = [[[NSMutableArray alloc] initWithCapacity:20] autorelease];
                [_ASTNodesStack addObject:_currentASTNodes];
                
            } else {
                // This is a new inverted section
                
                // Validate expression
                if (expression == nil) {
                    [self failWithFatalError:[self parseErrorAtToken:token description:error.localizedDescription]];
                    return NO;
                }
                
                // Prepare a new section
                
                expression.token = token;
                self.currentTagValue = expression;
                [_tagValueStack addObject:_currentTagValue];
                
                self.currentOpeningToken = token;
                [_openingTokenStack addObject:_currentOpeningToken];
                
                self.currentASTNodes = [[[NSMutableArray alloc] initWithCapacity:20] autorelease];
                [_ASTNodesStack addObject:_currentASTNodes];
                
                // lock _contentType
                _contentTypeLocked = YES;
            }
        } break;
            
            
        case GRMustacheTokenTypeInheritableSectionOpening: {
            // Inheritable section identifier validation
            NSError *inheritableSectionError;
            NSString *identifier = [parser parseInheritableSectionIdentifier:token.tagInnerContent empty:NULL error:&inheritableSectionError];
            if (identifier == nil) {
                [self failWithFatalError:[self parseErrorAtToken:token description:[NSString stringWithFormat:@"%@ in inheritable section tag", inheritableSectionError.localizedDescription]]];
                return NO;
            }
            
            // Expand stacks
            self.currentTagValue = identifier;
            [_tagValueStack addObject:_currentTagValue];
            
            self.currentOpeningToken = token;
            [_openingTokenStack addObject:_currentOpeningToken];
            
            self.currentASTNodes = [[[NSMutableArray alloc] initWithCapacity:20] autorelease];
            [_ASTNodesStack addObject:_currentASTNodes];
            
            // lock _contentType
            _contentTypeLocked = YES;
        } break;
            
            
        case GRMustacheTokenTypeInheritablePartial: {
            // Partial name validation
            NSError *partialError;
            NSString *partialName = [parser parseTemplateName:token.tagInnerContent empty:NULL error:&partialError];
            if (partialName == nil) {
                [self failWithFatalError:[self parseErrorAtToken:token description:[NSString stringWithFormat:@"%@ in partial tag", partialError.localizedDescription]]];
                return NO;
            }
            
            // Expand stacks
            self.currentTagValue = partialName;
            [_tagValueStack addObject:_currentTagValue];
            
            self.currentOpeningToken = token;
            [_openingTokenStack addObject:_currentOpeningToken];
            
            self.currentASTNodes = [[[NSMutableArray alloc] initWithCapacity:20] autorelease];
            [_ASTNodesStack addObject:_currentASTNodes];
            
            // lock _contentType
            _contentTypeLocked = YES;
        } break;
            
            
        case GRMustacheTokenTypeClosing: {
            if (_currentOpeningToken == nil) {
                [self failWithFatalError:[self parseErrorAtToken:token description:[NSString stringWithFormat:@"Unexpected %@ closing tag", token.templateSubstring]]];
                return NO;
            }
            
            // What are we closing?
            
            id<GRMustacheASTNode> wrapperASTNode = nil;
            switch (_currentOpeningToken.type) {
                case GRMustacheTokenTypeSectionOpening:
                case GRMustacheTokenTypeInvertedSectionOpening: {
                    // Expression validation
                    // We need a valid expression that matches section opening,
                    // or an empty `{{/}}` closing tags.
                    NSError *error;
                    BOOL empty;
                    GRMustacheExpression *expression = [expressionParser parseExpression:token.tagInnerContent empty:&empty error:&error];
                    if (expression == nil && !empty) {
                        [self failWithFatalError:[self parseErrorAtToken:token description:error.localizedDescription]];
                        return NO;
                    }
                    
                    NSAssert(_currentTagValue, @"WTF expected _currentTagValue");
                    if (expression && ![expression isEqual:_currentTagValue]) {
                        [self failWithFatalError:[self parseErrorAtToken:token description:[NSString stringWithFormat:@"Unexpected %@ closing tag", token.templateSubstring]]];
                        return NO;
                    }
                    
                    // Nothing prevents tokens to come from different template strings.
                    // We, however, do not support this case, because GRMustacheSectionNode
                    // builds from a single template string and a single innerRange.
                    if (_currentOpeningToken.templateString != token.templateString) {
                        [NSException raise:NSInternalInconsistencyException format:@"Support for tokens coming from different strings is not implemented."];
                    }
                    
                    // Success: create new GRMustacheSectionNode
                    NSRange openingTokenRange = _currentOpeningToken.range;
                    NSRange innerRange = NSMakeRange(openingTokenRange.location + openingTokenRange.length, token.range.location - (openingTokenRange.location + openingTokenRange.length));
                    wrapperASTNode = [GRMustacheSectionNode sectionNodeWithExpression:(GRMustacheExpression *)_currentTagValue
                                                                             inverted:(_currentOpeningToken.type == GRMustacheTokenTypeInvertedSectionOpening)
                                                                       templateString:token.templateString
                                                                           innerRange:innerRange
                                                                             ASTNodes:_currentASTNodes];
                } break;
                    
                case GRMustacheTokenTypeInheritableSectionOpening: {
                    // Inheritable section identifier validation
                    // We need a valid identifier that matches section opening,
                    // or an empty `{{/}}` closing tags.
                    NSError *error;
                    BOOL empty;
                    NSString *identifier = [parser parseInheritableSectionIdentifier:token.tagInnerContent empty:&empty error:&error];
                    if (identifier && ![identifier isEqual:_currentTagValue]) {
                        [self failWithFatalError:[self parseErrorAtToken:token description:[NSString stringWithFormat:@"Unexpected %@ closing tag", token.templateSubstring]]];
                        return NO;
                    } else if (!identifier && !empty) {
                        [self failWithFatalError:[self parseErrorAtToken:token description:[NSString stringWithFormat:@"%@ in partial closing tag", error.localizedDescription]]];
                        return NO;
                    }
                    
                    if (identifier && ![identifier isEqual:_currentTagValue]) {
                        [self failWithFatalError:[self parseErrorAtToken:token description:[NSString stringWithFormat:@"Unexpected %@ closing tag", token.templateSubstring]]];
                        return NO;
                    }
                    
                    // Success: create new GRMustacheInheritableSection
                    wrapperASTNode = [GRMustacheInheritableSection inheritableSectionWithIdentifier:(NSString *)_currentTagValue ASTNodes:_currentASTNodes];
                } break;
                    
                case GRMustacheTokenTypeInheritablePartial: {
                    // Validate token: inheritable template ending should be missing, or match inheritable template opening
                    NSError *error;
                    BOOL empty;
                    NSString *partialName = [parser parseTemplateName:token.tagInnerContent empty:&empty error:&error];
                    if (partialName && ![partialName isEqual:_currentTagValue]) {
                        [self failWithFatalError:[self parseErrorAtToken:token description:[NSString stringWithFormat:@"Unexpected %@ closing tag", token.templateSubstring]]];
                        return NO;
                    } else if (!partialName && !empty) {
                        [self failWithFatalError:[self parseErrorAtToken:token description:[NSString stringWithFormat:@"%@ in partial closing tag", error.localizedDescription]]];
                        return NO;
                    }
                    
                    // Ask templateRepository for inheritable template
                    GRMustachePartial *partial = [_templateRepository partialNamed:(NSString *)_currentTagValue relativeToTemplateID:_baseTemplateID error:&error];
                    if (partial == nil) {
                        [self failWithFatalError:error];
                        return NO;
                    }
                    
                    // Check for consistency of HTML safety
                    //
                    // If partial.AST.ASTNodes is nil, this means that we are actually
                    // compiling it, and that template simply recursively refers to itself.
                    // Consistency of HTML safety is thus guaranteed.
                    //
                    // However, if partial.AST.ASTNodes is not nil, then we must
                    // ensure content type compatibility: an HTML template can not override a
                    // text one, and vice versa.
                    //
                    // See test "HTML template can not override TEXT template" in GRMustacheSuites/text_rendering.json
                    if (partial.AST.ASTNodes && partial.AST.contentType != _contentType) {
                        [self failWithFatalError:[self parseErrorAtToken:_currentOpeningToken description:@"HTML safety mismatch"]];
                        return NO;
                    }
                    
                    // Success: create new GRMustacheInheritablePartial
                    wrapperASTNode = [GRMustacheInheritablePartial inheritablePartialWithPartial:partial ASTNodes:_currentASTNodes];
                } break;
                    
                default:
                    NSAssert(NO, @"WTF unexpected _currentOpeningToken.type");
                    break;
            }
            
            NSAssert(wrapperASTNode, @"WTF expected wrapperASTNode");
            
            [_tagValueStack removeLastObject];
            self.currentTagValue = [_tagValueStack lastObject];
            
            [_openingTokenStack removeLastObject];
            self.currentOpeningToken = [_openingTokenStack lastObject];
            
            [_ASTNodesStack removeLastObject];
            self.currentASTNodes = [_ASTNodesStack lastObject];
            
            [_currentASTNodes addObject:wrapperASTNode];
        } break;
            
            
        case GRMustacheTokenTypePartial: {
            // Partial name validation
            NSError *partialError;
            NSString *partialName = [parser parseTemplateName:token.tagInnerContent empty:NULL error:&partialError];
            if (partialName == nil) {
                [self failWithFatalError:[self parseErrorAtToken:token description:[NSString stringWithFormat:@"%@ in partial tag", partialError.localizedDescription]]];
                return NO;
            }
            
            // Ask templateRepository for partial template
            GRMustachePartial *partial = [_templateRepository partialNamed:partialName relativeToTemplateID:_baseTemplateID error:&partialError];
            if (partial == nil) {
                [self failWithFatalError:partialError];
                return NO;
            }
            
            // Success: append ASTNode
            [_currentASTNodes addObject:partial];
            
            // lock _contentType
            _contentTypeLocked = YES;
        } break;
            
    }
    return YES;
}

- (void)parser:(GRMustacheParser *)parser didFailWithError:(NSError *)error
{
    [self failWithFatalError:error];
}

#pragma mark Private

/**
 * This method is called whenever an error has occurred beyond any repair hope.
 *
 * @param fatalError  The fatal error
 */
- (void)failWithFatalError:(NSError *)fatalError
{
    // Make sure ASTNodesReturningError: returns correct results:
    self.fatalError = fatalError;
    self.currentASTNodes = nil;
    
    // All those objects are useless, now
    self.currentOpeningToken = nil;
    self.currentTagValue = nil;
    self.ASTNodesStack = nil;
    self.openingTokenStack = nil;
}

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
