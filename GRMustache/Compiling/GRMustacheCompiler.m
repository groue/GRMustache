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

#if !__has_feature(objc_arc)
#error Automatic Reference Counting required: use -fobjc-arc.
#endif

#import "GRMustacheCompiler_private.h"
#import "GRMustachePartialNode_private.h"
#import "GRMustacheTemplateRepository_private.h"
#import "GRMustacheTextNode_private.h"
#import "GRMustacheVariableTag_private.h"
#import "GRMustacheSectionTag_private.h"
#import "GRMustacheBlock_private.h"
#import "GRMustachePartialOverrideNode_private.h"
#import "GRMustacheExpressionParser_private.h"
#import "GRMustacheExpression_private.h"
#import "GRMustacheToken_private.h"
#import "GRMustacheTemplateAST_private.h"
#import "GRMustacheError.h"

@interface GRMustacheCompiler()

/**
 * The fatal error that should be returned by the public method
 * ASTNodesReturningError:.
 *
 * @see currentASTNodes
 */
@property (nonatomic, strong) NSError *fatalError;

/**
 * After an opening token has been found such as {{#A}}, {{^B}}, or {{<C}},
 * contains this token.
 *
 * This object is always identical to
 * [self.openingTokenStack lastObject].
 *
 * @see openingTokenStack
 */
@property (nonatomic, unsafe_unretained) GRMustacheToken *currentOpeningToken;

/**
 * After an opening token has been found such as {{#A}}, {{^B}}, or {{<C}},
 * contains the value of this token (expression or partial name).
 *
 * This object is always identical to
 * [self.tagValueStack lastObject].
 *
 * @see tagValueStack
 */
@property (nonatomic, unsafe_unretained) NSObject *currentTagValue;

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
@property (nonatomic, unsafe_unretained) NSMutableArray *currentASTNodes;

/**
 * The stack of arrays where AST nodes should be appended as tokens are
 * yielded by a parser.
 *
 * This stack grows with section opening tokens, and shrinks with section
 * closing tokens.
 *
 * @see currentASTNodes
 */
@property (nonatomic, strong) NSMutableArray *ASTNodesStack;

/**
 * This stack grows with section opening tokens, and shrinks with section
 * closing tokens.
 *
 * @see currentOpeningToken
 */
@property (nonatomic, strong) NSMutableArray *openingTokenStack;

/**
 * This stack grows with section opening tokens, and shrinks with section
 * closing tokens.
 *
 * @see currentTagValue
 */
@property (nonatomic, strong) NSMutableArray *tagValueStack;

/**
 */
@property (nonatomic) GRMustacheContentType contentType;
@property (nonatomic) BOOL contentTypeLocked;

@end

@implementation GRMustacheCompiler

- (instancetype)initWithContentType:(GRMustacheContentType)contentType
{
    self = [super init];
    if (self) {
        NSMutableArray *currentASTNodes = [[NSMutableArray alloc] initWithCapacity:20];
        self.currentASTNodes = currentASTNodes;
        self.ASTNodesStack = [[NSMutableArray alloc] initWithCapacity:20];
        [self.ASTNodesStack addObject:currentASTNodes];
        self.openingTokenStack = [[NSMutableArray alloc] initWithCapacity:20];
        self.tagValueStack = [[NSMutableArray alloc] initWithCapacity:20];
        self.contentType = contentType;
        self.contentTypeLocked = NO;
    }
    return self;
}

- (GRMustacheTemplateAST *)templateASTReturningError:(NSError **)error
{
    // Has a fatal error occurred?
    if (self.currentASTNodes == nil) {
        NSAssert(self.fatalError, @"We should have an error when _currentASTNodes is nil");
        if (error != NULL) {
            *error = self.fatalError;
        }
        return nil;
    }
    
    // Unclosed section?
    if (self.currentOpeningToken) {
        NSError *parseError = [self parseErrorAtToken:self.currentOpeningToken description:[NSString stringWithFormat:@"Unclosed %@ section", self.currentOpeningToken.templateSubstring]];
        if (error != NULL) {
            *error = parseError;
        }
        return nil;
    }
    
    // Success
    return [GRMustacheTemplateAST templateASTWithASTNodes:self.currentASTNodes contentType:self.contentType];
}


#pragma mark GRMustacheTemplateParserDelegate

- (BOOL)templateParser:(GRMustacheTemplateParser *)parser shouldContinueAfterParsingToken:(GRMustacheToken *)token
{
    // Refuse tokens after a fatal error has occurred.
    if (self.currentASTNodes == nil) {
        return NO;
    }
    
    switch (token.type) {
        case GRMustacheTokenTypeSetDelimiter:
        case GRMustacheTokenTypeComment:
            // ignore
            break;
            
        case GRMustacheTokenTypePragma: {
            NSString *pragma = [parser parsePragma:token.tagInnerContent];
            if ([pragma isEqualToString:@"CONTENT_TYPE:TEXT"]) {
                if (self.contentTypeLocked) {
                    [self failWithFatalError:[self parseErrorAtToken:token description:[NSString stringWithFormat:@"CONTENT_TYPE:TEXT pragma tag must prepend any Mustache variable, section, or partial tag."]]];
                    return NO;
                }
                self.contentType = GRMustacheContentTypeText;
            }
            if ([pragma isEqualToString:@"CONTENT_TYPE:HTML"]) {
                if (self.contentTypeLocked) {
                    [self failWithFatalError:[self parseErrorAtToken:token description:[NSString stringWithFormat:@"CONTENT_TYPE:HTML pragma tag must prepend any Mustache variable, section, or partial tag."]]];
                    return NO;
                }
                self.contentType = GRMustacheContentTypeHTML;
            }
        } break;
            
        case GRMustacheTokenTypeText:
            // Parser validation
            NSAssert(token.templateSubstring.length > 0, @"WTF empty GRMustacheTokenTypeContent");
            
            // Success: append GRMustacheTextASTNode
            [self.currentASTNodes addObject:[GRMustacheTextNode textNodeWithText:token.templateSubstring]];
            break;
            
            
        case GRMustacheTokenTypeEscapedVariable: {
            // Context validation
            if (self.currentOpeningToken && self.currentOpeningToken.type == GRMustacheTokenTypePartialOverride) {
                [self failWithFatalError:[self parseErrorAtToken:token description:@"Illegal tag inside a partial override tag."]];
                return NO;
            }

            // Expression validation
            NSError *error;
            GRMustacheExpressionParser *expressionParser = [[GRMustacheExpressionParser alloc] init];
            GRMustacheExpression *expression = [expressionParser parseExpression:token.tagInnerContent empty:NULL error:&error];
            if (expression == nil) {
                [self failWithFatalError:[self parseErrorAtToken:token description:error.localizedDescription]];
                return NO;
            }
            
            // Success: append GRMustacheVariableTag
            expression.token = token;
            [self.currentASTNodes addObject:[GRMustacheVariableTag variableTagWithExpression:expression escapesHTML:YES contentType:self.contentType tagStartDelimiter:token.tagStartDelimiter tagEndDelimiter:token.tagEndDelimiter]];
            
            // lock contentType
            self.contentTypeLocked = YES;
        } break;
            
            
        case GRMustacheTokenTypeUnescapedVariable: {
            // Context validation
            if (self.currentOpeningToken && self.currentOpeningToken.type == GRMustacheTokenTypePartialOverride) {
                [self failWithFatalError:[self parseErrorAtToken:token description:@"Illegal tag inside a partial override tag."]];
                return NO;
            }
            
            // Expression validation
            NSError *error;
            GRMustacheExpressionParser *expressionParser = [[GRMustacheExpressionParser alloc] init];
            GRMustacheExpression *expression = [expressionParser parseExpression:token.tagInnerContent empty:NULL error:&error];
            if (expression == nil) {
                [self failWithFatalError:[self parseErrorAtToken:token description:error.localizedDescription]];
                return NO;
            }
            
            // Success: append GRMustacheVariableTag
            expression.token = token;
            [self.currentASTNodes addObject:[GRMustacheVariableTag variableTagWithExpression:expression escapesHTML:NO contentType:self.contentType tagStartDelimiter:token.tagStartDelimiter tagEndDelimiter:token.tagEndDelimiter]];
            
            // lock contentType
            self.contentTypeLocked = YES;
        } break;
            
            
        case GRMustacheTokenTypeSectionOpening: {
            // Context validation
            if (self.currentOpeningToken && self.currentOpeningToken.type == GRMustacheTokenTypePartialOverride) {
                [self failWithFatalError:[self parseErrorAtToken:token description:@"Illegal tag inside a partial override tag."]];
                return NO;
            }
            
            // Expression validation
            NSError *error;
            BOOL empty;
            GRMustacheExpressionParser *expressionParser = [[GRMustacheExpressionParser alloc] init];
            GRMustacheExpression *expression = [expressionParser parseExpression:token.tagInnerContent empty:&empty error:&error];
            
            if (self.currentOpeningToken &&
                self.currentOpeningToken.type == GRMustacheTokenTypeInvertedSectionOpening &&
                ((expression == nil && empty) || (expression != nil && [expression isEqual:self.currentTagValue])))
            {
                // We found the "else" close of an inverted section:
                // {{^foo}}...{{#}}...
                // {{^foo}}...{{#foo}}...
                
                // Insert a new inverted section and prepare a regular one
                
                NSRange openingTokenRange = self.currentOpeningToken.range;
                NSRange innerRange = NSMakeRange(openingTokenRange.location + openingTokenRange.length, token.range.location - (openingTokenRange.location + openingTokenRange.length));
                GRMustacheTemplateAST *templateAST = [GRMustacheTemplateAST templateASTWithASTNodes:self.currentASTNodes contentType:self.contentType];
                GRMustacheSectionTag *sectionTag = [GRMustacheSectionTag sectionTagWithExpression:(GRMustacheExpression *)self.currentTagValue
                                                                                         inverted:YES
                                                                                   templateString:token.templateString
                                                                                       innerRange:innerRange
                                                                                 innerTemplateAST:templateAST
                                                                                tagStartDelimiter:self.currentOpeningToken.tagStartDelimiter
                                                                                  tagEndDelimiter:self.currentOpeningToken.tagEndDelimiter];
                
                [self.openingTokenStack removeLastObject];
                [self.openingTokenStack addObject:token];
                self.currentOpeningToken = token;
                
                [self.ASTNodesStack removeLastObject];
                [[self.ASTNodesStack lastObject] addObject:sectionTag];
                
                NSMutableArray *currentASTNodes = [[NSMutableArray alloc] initWithCapacity:20];
                [self.ASTNodesStack addObject:currentASTNodes];
                self.currentASTNodes = currentASTNodes;
                
            } else {
                // This is a new regular section
                
                // Validate expression
                if (expression == nil) {
                    [self failWithFatalError:[self parseErrorAtToken:token description:error.localizedDescription]];
                    return NO;
                }
                
                // Prepare a new section
                
                expression.token = token;
                [self.tagValueStack addObject:expression];
                self.currentTagValue = expression;
                
                [self.openingTokenStack addObject:token];
                self.currentOpeningToken = token;
                
                NSMutableArray *currentASTNodes = [[NSMutableArray alloc] initWithCapacity:20];
                [self.ASTNodesStack addObject:currentASTNodes];
                self.currentASTNodes = currentASTNodes;
                
                // lock contentType
                self.contentTypeLocked = YES;
            }
        } break;
            
            
        case GRMustacheTokenTypeInvertedSectionOpening: {
            // Context validation
            if (self.currentOpeningToken && self.currentOpeningToken.type == GRMustacheTokenTypePartialOverride) {
                [self failWithFatalError:[self parseErrorAtToken:token description:@"Illegal tag inside a partial override tag."]];
                return NO;
            }
            
            // Expression validation
            NSError *error;
            BOOL empty;
            GRMustacheExpressionParser *expressionParser = [[GRMustacheExpressionParser alloc] init];
            GRMustacheExpression *expression = [expressionParser parseExpression:token.tagInnerContent empty:&empty error:&error];
            
            if (self.currentOpeningToken &&
                self.currentOpeningToken.type == GRMustacheTokenTypeSectionOpening &&
                ((expression == nil && empty) || (expression != nil && [expression isEqual:self.currentTagValue])))
            {
                // We found the "else" close of a section:
                // {{#foo}}...{{^}}...{{/foo}}
                // {{#foo}}...{{^foo}}...{{/foo}}
                
                // Insert a new section and prepare an inverted one
                
                NSRange openingTokenRange = self.currentOpeningToken.range;
                NSRange innerRange = NSMakeRange(openingTokenRange.location + openingTokenRange.length, token.range.location - (openingTokenRange.location + openingTokenRange.length));
                GRMustacheTemplateAST *templateAST = [GRMustacheTemplateAST templateASTWithASTNodes:self.currentASTNodes contentType:self.contentType];
                GRMustacheSectionTag *sectionTag = [GRMustacheSectionTag sectionTagWithExpression:(GRMustacheExpression *)self.currentTagValue
                                                                                         inverted:NO
                                                                                   templateString:token.templateString
                                                                                       innerRange:innerRange
                                                                                 innerTemplateAST:templateAST
                                                                                tagStartDelimiter:self.currentOpeningToken.tagStartDelimiter
                                                                                  tagEndDelimiter:self.currentOpeningToken.tagEndDelimiter];
                
                [self.openingTokenStack removeLastObject];
                [self.openingTokenStack addObject:token];
                self.currentOpeningToken = token;
                
                [self.ASTNodesStack removeLastObject];
                [[self.ASTNodesStack lastObject] addObject:sectionTag];
                
                NSMutableArray *currentASTNodes = [[NSMutableArray alloc] initWithCapacity:20];
                [self.ASTNodesStack addObject:currentASTNodes];
                self.currentASTNodes = currentASTNodes;
                
            } else {
                // This is a new inverted section
                
                // Validate expression
                if (expression == nil) {
                    [self failWithFatalError:[self parseErrorAtToken:token description:error.localizedDescription]];
                    return NO;
                }
                
                // Prepare a new section
                
                expression.token = token;
                [self.tagValueStack addObject:expression];
                self.currentTagValue = expression;
                
                [self.openingTokenStack addObject:token];
                self.currentOpeningToken = token;
                
                NSMutableArray *currentASTNodes = [[NSMutableArray alloc] initWithCapacity:20];
                [self.ASTNodesStack addObject:currentASTNodes];
                self.currentASTNodes = currentASTNodes;
                
                // lock contentType
                self.contentTypeLocked = YES;
            }
        } break;
            
            
        case GRMustacheTokenTypeBlockOpening: {
            // Block name validation
            NSError *blockError;
            NSString *name = [parser parseBlockName:token.tagInnerContent empty:NULL error:&blockError];
            if (name == nil) {
                [self failWithFatalError:[self parseErrorAtToken:token description:[NSString stringWithFormat:@"%@ in block", blockError.localizedDescription]]];
                return NO;
            }
            
            // Expand stacks
            [self.tagValueStack addObject:name];
            self.currentTagValue = name;
            
            [self.openingTokenStack addObject:token];
            self.currentOpeningToken = token;
            
            NSMutableArray *currentASTNodes = [[NSMutableArray alloc] initWithCapacity:20];
            [self.ASTNodesStack addObject:currentASTNodes];
            self.currentASTNodes = currentASTNodes;
            
            // lock contentType
            self.contentTypeLocked = YES;
        } break;
            
            
        case GRMustacheTokenTypePartialOverride: {
            // Partial name validation
            NSError *partialError;
            NSString *partialName = [parser parseTemplateName:token.tagInnerContent empty:NULL error:&partialError];
            if (partialName == nil) {
                [self failWithFatalError:[self parseErrorAtToken:token description:[NSString stringWithFormat:@"%@ in partial tag", partialError.localizedDescription]]];
                return NO;
            }
            
            // Expand stacks
            [self.tagValueStack addObject:partialName];
            self.currentTagValue = partialName;
            
            [self.openingTokenStack addObject:token];
            self.currentOpeningToken = token;
            
            NSMutableArray *currentASTNodes = [[NSMutableArray alloc] initWithCapacity:20];
            [self.ASTNodesStack addObject:currentASTNodes];
            self.currentASTNodes = currentASTNodes;
            
            // lock contentType
            self.contentTypeLocked = YES;
        } break;
            
            
        case GRMustacheTokenTypeClosing: {
            if (self.currentOpeningToken == nil) {
                [self failWithFatalError:[self parseErrorAtToken:token description:[NSString stringWithFormat:@"Unexpected %@ closing tag", token.templateSubstring]]];
                return NO;
            }
            
            // What are we closing?
            
            id<GRMustacheTemplateASTNode> wrapperASTNode = nil;
            switch (self.currentOpeningToken.type) {
                case GRMustacheTokenTypeSectionOpening:
                case GRMustacheTokenTypeInvertedSectionOpening: {
                    // Expression validation
                    // We need a valid expression that matches section opening,
                    // or an empty `{{/}}` closing tags.
                    NSError *error;
                    BOOL empty;
                    GRMustacheExpressionParser *expressionParser = [[GRMustacheExpressionParser alloc] init];
                    GRMustacheExpression *expression = [expressionParser parseExpression:token.tagInnerContent empty:&empty error:&error];
                    if (expression == nil && !empty) {
                        [self failWithFatalError:[self parseErrorAtToken:token description:error.localizedDescription]];
                        return NO;
                    }
                    
                    NSParameterAssert(self.currentTagValue);
                    if (expression && ![expression isEqual:self.currentTagValue]) {
                        [self failWithFatalError:[self parseErrorAtToken:token description:[NSString stringWithFormat:@"Unexpected %@ closing tag", token.templateSubstring]]];
                        return NO;
                    }
                    
                    // Nothing prevents tokens to come from different template strings.
                    // We, however, do not support this case, because GRMustacheSectionTag
                    // builds from a single template string and a single innerRange.
                    if (self.currentOpeningToken.templateString != token.templateString) {
                        [NSException raise:NSInternalInconsistencyException format:@"Support for tokens coming from different strings is not implemented."];
                    }
                    
                    // Success: create new GRMustacheSectionTag
                    NSRange openingTokenRange = self.currentOpeningToken.range;
                    NSRange innerRange = NSMakeRange(openingTokenRange.location + openingTokenRange.length, token.range.location - (openingTokenRange.location + openingTokenRange.length));
                    GRMustacheTemplateAST *templateAST = [GRMustacheTemplateAST templateASTWithASTNodes:self.currentASTNodes contentType:self.contentType];
                    wrapperASTNode = [GRMustacheSectionTag sectionTagWithExpression:(GRMustacheExpression *)self.currentTagValue
                                                                           inverted:(self.currentOpeningToken.type == GRMustacheTokenTypeInvertedSectionOpening)
                                                                     templateString:token.templateString
                                                                         innerRange:innerRange
                                                                   innerTemplateAST:templateAST
                                                                  tagStartDelimiter:self.currentOpeningToken.tagStartDelimiter
                                                                    tagEndDelimiter:self.currentOpeningToken.tagEndDelimiter];
                } break;
                    
                case GRMustacheTokenTypeBlockOpening: {
                    // Block name validation
                    // We need a valid name that matches block opening,
                    // or an empty `{{/}}` closing tags.
                    NSError *error;
                    BOOL empty;
                    NSString *name = [parser parseBlockName:token.tagInnerContent empty:&empty error:&error];
                    if (name && ![name isEqual:self.currentTagValue]) {
                        [self failWithFatalError:[self parseErrorAtToken:token description:[NSString stringWithFormat:@"Unexpected %@ closing tag", token.templateSubstring]]];
                        return NO;
                    } else if (!name && !empty) {
                        [self failWithFatalError:[self parseErrorAtToken:token description:[NSString stringWithFormat:@"%@ in partial closing tag", error.localizedDescription]]];
                        return NO;
                    }
                    
                    if (name && ![name isEqual:self.currentTagValue]) {
                        [self failWithFatalError:[self parseErrorAtToken:token description:[NSString stringWithFormat:@"Unexpected %@ closing tag", token.templateSubstring]]];
                        return NO;
                    }
                    
                    // Success: create new GRMustacheBlock
                    GRMustacheTemplateAST *templateAST = [GRMustacheTemplateAST templateASTWithASTNodes:self.currentASTNodes contentType:self.contentType];
                    wrapperASTNode = [GRMustacheBlock blockWithName:(NSString *)self.currentTagValue innerTemplateAST:templateAST];
                } break;
                    
                case GRMustacheTokenTypePartialOverride: {
                    // Validate token: inheritable template ending should be missing, or match inheritable template opening
                    NSError *error;
                    BOOL empty;
                    NSString *partialName = [parser parseTemplateName:token.tagInnerContent empty:&empty error:&error];
                    if (partialName && ![partialName isEqual:self.currentTagValue]) {
                        [self failWithFatalError:[self parseErrorAtToken:token description:[NSString stringWithFormat:@"Unexpected %@ closing tag", token.templateSubstring]]];
                        return NO;
                    } else if (!partialName && !empty) {
                        [self failWithFatalError:[self parseErrorAtToken:token description:[NSString stringWithFormat:@"%@ in partial closing tag", error.localizedDescription]]];
                        return NO;
                    }
                    
                    // Ask templateRepository for inheritable template
                    partialName = (NSString *)self.currentTagValue;
                    GRMustacheTemplateAST *templateAST = [self.templateRepository templateASTNamed:partialName relativeToTemplateID:self.baseTemplateID error:&error];
                    if (templateAST == nil) {
                        [self failWithFatalError:error];
                        return NO;
                    }
                    
                    // Check for consistency of HTML safety
                    //
                    // If templateAST.isPlaceholder, this means that we are actually
                    // compiling it, and that template simply recursively refers to itself.
                    // Consistency of HTML safety is thus guaranteed.
                    //
                    // However, if templateAST.isPlaceholder is false, then we must ensure
                    // content type compatibility: an HTML template can not override a
                    // text one, and vice versa.
                    //
                    // See test "HTML template can not override TEXT template" in GRMustacheSuites/text_rendering.json
                    if (!templateAST.isPlaceholder && templateAST.contentType != self.contentType) {
                        [self failWithFatalError:[self parseErrorAtToken:self.currentOpeningToken description:@"HTML safety mismatch"]];
                        return NO;
                    }
                    
                    // Success: create new GRMustachePartialOverrideNode
                    GRMustachePartialNode *partialNode = [GRMustachePartialNode partialNodeWithTemplateAST:templateAST name:partialName];
                    GRMustacheTemplateAST *overridingTemplateAST = [GRMustacheTemplateAST templateASTWithASTNodes:self.currentASTNodes contentType:self.contentType];
                    wrapperASTNode = [GRMustachePartialOverrideNode partialOverrideNodeWithParentPartialNode:partialNode overridingTemplateAST:overridingTemplateAST];
                } break;
                    
                default:
                    NSAssert(NO, @"Unexpected self.currentOpeningToken.type");
                    break;
            }
            
            NSAssert(wrapperASTNode, @"WTF expected wrapperASTNode");
            
            [self.tagValueStack removeLastObject];
            self.currentTagValue = [self.tagValueStack lastObject];
            
            [self.openingTokenStack removeLastObject];
            self.currentOpeningToken = [self.openingTokenStack lastObject];
            
            [self.ASTNodesStack removeLastObject];
            self.currentASTNodes = [self.ASTNodesStack lastObject];
            
            [self.currentASTNodes addObject:wrapperASTNode];
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
            GRMustacheTemplateAST *templateAST = [self.templateRepository templateASTNamed:partialName relativeToTemplateID:self.baseTemplateID error:&partialError];
            if (templateAST == nil) {
                [self failWithFatalError:partialError];
                return NO;
            }
            
            // Success: append ASTNode
            GRMustachePartialNode *partialNode = [GRMustachePartialNode partialNodeWithTemplateAST:templateAST name:partialName];
            [self.currentASTNodes addObject:partialNode];
            
            // lock contentType
            self.contentTypeLocked = YES;
        } break;
            
    }
    return YES;
}

- (void)templateParser:(GRMustacheTemplateParser *)parser didFailWithError:(NSError *)error
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
