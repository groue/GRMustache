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
#import "GRMustacheTextComponent_private.h"
#import "GRMustacheVariableTag_private.h"
#import "GRMustacheSectionTag_private.h"
#import "GRMustacheTemplateOverride_private.h"
#import "GRMustacheError.h"
#import "GRMustacheExpression_private.h"
#import "GRMustacheToken_private.h"
#import "GRMustacheConfiguration.h"

#pragma mark - GRMustacheAST

@interface GRMustacheAST()
- (id)initWithTemplateComponents:(NSArray *)templateComponents contentType:(GRMustacheContentType)contentType;
@end


#pragma mark - GRMustacheCompiler

@interface GRMustacheCompiler()

/**
 * The fatal error that should be returned by the public method
 * templateComponentsReturningError:.
 * 
 * @see currentComponents
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
 * An array where template components are appended as tokens are yielded
 * by a parser.
 * 
 * This array is also the one that would be returned by the public method
 * templateComponentsReturningError:.
 * 
 * As such, it is nil whenever an error occurs.
 * 
 * This object is always identical to [self.componentsStack lastObject].
 * 
 * @see componentsStack
 * @see fatalError
 */
@property (nonatomic, retain) NSMutableArray *currentComponents;

/**
 * The stack of arrays where template components should be appended as tokens are
 * yielded by a parser.
 * 
 * This stack grows with section opening tokens, and shrinks with section
 * closing tokens.
 * 
 * @see currentComponents
 */
@property (nonatomic, retain) NSMutableArray *componentsStack;

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
@synthesize currentComponents=_currentComponents;
@synthesize componentsStack=_componentsStack;
@synthesize openingTokenStack=_openingTokenStack;

- (id)initWithConfiguration:(GRMustacheConfiguration *)configuration
{
    self = [super init];
    if (self) {
        _currentComponents = [[NSMutableArray alloc] initWithCapacity:20];
        _componentsStack = [[NSMutableArray alloc] initWithCapacity:20];
        [_componentsStack addObject:_currentComponents];
        _openingTokenStack = [[NSMutableArray alloc] initWithCapacity:20];
        _contentType = configuration.contentType;
        _contentTypeLocked = NO;
    }
    return self;
}

- (GRMustacheAST *)ASTReturningError:(NSError **)error
{
    // Has a fatal error occurred?
    if (_currentComponents == nil) {
        NSAssert(_fatalError, @"We should have an error when _currentComponents is nil");
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
    return [[[GRMustacheAST alloc] initWithTemplateComponents:_currentComponents contentType:_contentType] autorelease];
}

- (void)dealloc
{
    [_fatalError release];
    [_currentOpeningToken release];
    [_currentComponents release];
    [_componentsStack release];
    [_openingTokenStack release];
    [super dealloc];
}


#pragma mark GRMustacheParserDelegate

- (BOOL)parser:(GRMustacheParser *)parser shouldContinueAfterParsingToken:(GRMustacheToken *)token
{
    // Refuse tokens after a fatal error has occurred.
    if (_currentComponents == nil) {
        return NO;
    }
    
    switch (token.type) {
        case GRMustacheTokenTypeSetDelimiter:
        case GRMustacheTokenTypeComment:
            // Ignore
            break;
            
        case GRMustacheTokenTypePragma:
            if ([token.pragma isEqualToString:@"CONTENT_TYPE:TEXT"]) {
                if (_contentTypeLocked) {
                    [self failWithFatalError:[self parseErrorAtToken:token description:[NSString stringWithFormat:@"CONTENT_TYPE:TEXT pragma tag must prepend any Mustache variable, section, or partial tag."]]];
                    return NO;
                }
                _contentType = GRMustacheContentTypeText;
            }
            if ([token.pragma isEqualToString:@"CONTENT_TYPE:HTML"]) {
                if (_contentTypeLocked) {
                    [self failWithFatalError:[self parseErrorAtToken:token description:[NSString stringWithFormat:@"CONTENT_TYPE:HTML pragma tag must prepend any Mustache variable, section, or partial tag."]]];
                    return NO;
                }
                _contentType = GRMustacheContentTypeHTML;
            }
            break;
            
        case GRMustacheTokenTypeText:
            // Parser validation
            NSAssert(token.text.length > 0, @"WTF parser?");
            
            // Success: append GRMustacheTextComponent
            [_currentComponents addObject:[GRMustacheTextComponent textComponentWithString:token.text]];
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
            
            // Success: append GRMustacheVariableTag
            [_currentComponents addObject:[GRMustacheVariableTag variableTagWithTemplateRepository:_templateRepository expression:token.expression contentType:_contentType escapesHTML:YES]];
            
            // lock _contentType
            _contentTypeLocked = YES;
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
            
            // Success: append GRMustacheVariableTag
            [_currentComponents addObject:[GRMustacheVariableTag variableTagWithTemplateRepository:_templateRepository expression:token.expression contentType:_contentType escapesHTML:NO]];
            
            // lock _contentType
            _contentTypeLocked = YES;
        } break;
            
            
        case GRMustacheTokenTypeSectionOpening: {
            if (_currentOpeningToken &&
                _currentOpeningToken.type == GRMustacheTokenTypeInvertedSectionOpening &&
                ((token.expression == nil && !token.invalidExpression) || (token.expression != nil && [token.expression isEqual:_currentOpeningToken.expression])))
            {
                // We found the "else" close of an inverted section:
                // {{^foo}}...{{#}}...
                // {{^foo}}...{{#foo}}...
                
                // Insert a new inverted section and prepare a regular one
                
                NSRange openingTokenRange = _currentOpeningToken.range;
                NSRange innerRange = NSMakeRange(openingTokenRange.location + openingTokenRange.length, token.range.location - (openingTokenRange.location + openingTokenRange.length));
                GRMustacheSectionTag *sectionTag = [GRMustacheSectionTag sectionTagWithTemplateRepository:_templateRepository
                                                                                               expression:_currentOpeningToken.expression
                                                                                              contentType:_contentType
                                                                                           templateString:token.templateString
                                                                                               innerRange:innerRange
                                                                                                     type:GRMustacheTagTypeInvertedSection
                                                                                               components:_currentComponents];
                
                [_openingTokenStack removeLastObject];
                [_componentsStack removeLastObject];
                [[_componentsStack lastObject] addObject:sectionTag];
                self.currentOpeningToken = [token tokenWithExpression:_currentOpeningToken.expression]; // copy the expression for the closing tag of `{{^foo}}...{{#}}...{{/}}`
                self.currentComponents = [[[NSMutableArray alloc] initWithCapacity:20] autorelease];
                [_openingTokenStack addObject:_currentOpeningToken];
                [_componentsStack addObject:_currentComponents];
                
            } else {
                // This is a new regular section
                
                // Validate expression
                if (token.expression == nil) {
                    if (token.invalidExpression) {
                        [self failWithFatalError:[self parseErrorAtToken:token description:[NSString stringWithFormat:@"Invalid expression"]]];
                        return NO;
                    } else {
                        [self failWithFatalError:[self parseErrorAtToken:token description:[NSString stringWithFormat:@"Missing expression"]]];
                        return NO;
                    }
                }
                
                // Prepare a new section
                
                self.currentOpeningToken = token;
                self.currentComponents = [[[NSMutableArray alloc] initWithCapacity:20] autorelease];
                [_openingTokenStack addObject:_currentOpeningToken];
                [_componentsStack addObject:_currentComponents];
                
                // lock _contentType
                _contentTypeLocked = YES;
            }
        } break;
            
            
        case GRMustacheTokenTypeOverridableSectionOpening: {
            // There is no support for `{{^foo}}...{{$foo}}...{{/foo}}`:
            // this is a new overridable section.
            
            // Validate expression
            if (token.expression == nil) {
                if (token.invalidExpression) {
                    [self failWithFatalError:[self parseErrorAtToken:token description:[NSString stringWithFormat:@"Invalid expression"]]];
                    return NO;
                } else {
                    [self failWithFatalError:[self parseErrorAtToken:token description:[NSString stringWithFormat:@"Missing expression"]]];
                    return NO;
                }
            }
            
            // Prepare a new section
            
            self.currentOpeningToken = token;
            self.currentComponents = [[[NSMutableArray alloc] initWithCapacity:20] autorelease];
            [_openingTokenStack addObject:_currentOpeningToken];
            [_componentsStack addObject:_currentComponents];
            
            // lock _contentType
            _contentTypeLocked = YES;
        } break;
            
            
        case GRMustacheTokenTypeInvertedSectionOpening: {
            if (_currentOpeningToken &&
                _currentOpeningToken.type == GRMustacheTokenTypeSectionOpening &&
                ((token.expression == nil && !token.invalidExpression) || (token.expression != nil && [token.expression isEqual:_currentOpeningToken.expression])))
            {
                // We found the "else" close of a regular or overridable section:
                // {{#foo}}...{{^}}...{{/foo}}
                // {{#foo}}...{{^foo}}...{{/foo}}
                //
                // There is no support for {{$foo}}...{{^foo}}...{{/foo}}.
                
                // Insert a new section and prepare an inverted one
                
                NSRange openingTokenRange = _currentOpeningToken.range;
                NSRange innerRange = NSMakeRange(openingTokenRange.location + openingTokenRange.length, token.range.location - (openingTokenRange.location + openingTokenRange.length));
                GRMustacheSectionTag *sectionTag = [GRMustacheSectionTag sectionTagWithTemplateRepository:_templateRepository
                                                                                               expression:_currentOpeningToken.expression
                                                                                              contentType:_contentType
                                                                                           templateString:token.templateString
                                                                                               innerRange:innerRange
                                                                                                     type:GRMustacheTagTypeSection
                                                                                               components:_currentComponents];
                
                [_openingTokenStack removeLastObject];
                [_componentsStack removeLastObject];
                [[_componentsStack lastObject] addObject:sectionTag];
                self.currentOpeningToken = [token tokenWithExpression:_currentOpeningToken.expression]; // copy the expression for the closing tag of `{{#foo}}...{{^}}...{{/}}`
                self.currentComponents = [[[NSMutableArray alloc] initWithCapacity:20] autorelease];
                [_openingTokenStack addObject:_currentOpeningToken];
                [_componentsStack addObject:_currentComponents];
                
            } else {
                // This is a new inverted section
                
                // Validate expression
                if (token.expression == nil) {
                    if (token.invalidExpression) {
                        [self failWithFatalError:[self parseErrorAtToken:token description:[NSString stringWithFormat:@"Invalid expression"]]];
                        return NO;
                    } else {
                        [self failWithFatalError:[self parseErrorAtToken:token description:[NSString stringWithFormat:@"Missing expression"]]];
                        return NO;
                    }
                }
                
                // Prepare a new section
                
                self.currentOpeningToken = token;
                self.currentComponents = [[[NSMutableArray alloc] initWithCapacity:20] autorelease];
                [_openingTokenStack addObject:_currentOpeningToken];
                [_componentsStack addObject:_currentComponents];
                
                // lock _contentType
                _contentTypeLocked = YES;
            }
        } break;
            
            
        case GRMustacheTokenTypeClosing: {
            if (_currentOpeningToken == nil) {
                [self failWithFatalError:[self parseErrorAtToken:token description:[NSString stringWithFormat:@"Unexpected %@ closing tag", token.templateSubstring]]];
                return NO;
            }
            
            // What are we closing?
            
            id<GRMustacheTemplateComponent> wrapperComponent = nil;
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
                    
                    if (_currentOpeningToken.expression == nil) {
                        NSAssert(_currentOpeningToken.expression, @"WTF");
                    }
                    if (token.expression && ![token.expression isEqual:_currentOpeningToken.expression]) {
                        [self failWithFatalError:[self parseErrorAtToken:token description:[NSString stringWithFormat:@"Unexpected %@ closing tag", token.templateSubstring]]];
                        return NO;
                    }
                    
                    // Nothing prevents tokens to come from different template strings.
                    // We, however, do not support this case, because GRMustacheSectionTag
                    // builds from a single template string and a single innerRange.
                    NSAssert(_currentOpeningToken.templateString == token.templateString, @"not implemented");
                    
                    // Success: create new GRMustacheSectionTag
                    NSRange openingTokenRange = _currentOpeningToken.range;
                    NSRange innerRange = NSMakeRange(openingTokenRange.location + openingTokenRange.length, token.range.location - (openingTokenRange.location + openingTokenRange.length));
                    GRMustacheTagType type = (_currentOpeningToken.type == GRMustacheTokenTypeInvertedSectionOpening) ? GRMustacheTagTypeInvertedSection : ((_currentOpeningToken.type == GRMustacheTokenTypeOverridableSectionOpening) ? GRMustacheTagTypeOverridableSection : GRMustacheTagTypeSection);
                    wrapperComponent = [GRMustacheSectionTag sectionTagWithTemplateRepository:_templateRepository
                                                                                   expression:_currentOpeningToken.expression
                                                                                  contentType:_contentType
                                                                               templateString:token.templateString
                                                                                   innerRange:innerRange
                                                                                         type:type
                                                                                   components:_currentComponents];
                    
                } break;
                
                case GRMustacheTokenTypeOverridablePartial: {
                    // Validate token: overridable template ending should be missing, or match overridable template opening
                    if (token.partialName && ![token.partialName isEqual:_currentOpeningToken.partialName]) {
                        [self failWithFatalError:[self parseErrorAtToken:token description:[NSString stringWithFormat:@"Unexpected %@ closing tag", token.templateSubstring]]];
                        return NO;
                    }
                    
                    // Ask templateRepository for overridable template
                    NSError *templateError;
                    GRMustacheTemplate *template = [_templateRepository templateNamed:_currentOpeningToken.partialName error:&templateError];
                    if (template == nil) {
                        [self failWithFatalError:templateError];
                        return NO;
                    }
                    
                    // Check for consistency of HTML safety
                    //
                    // If template.components is nil, this means that we are actually
                    // compiling it, and that template simply recursively refers to itself.
                    // Consistency of HTML safety is this guaranteed.
                    if (template.components && template.contentType != _contentType) {
                        [self failWithFatalError:[self parseErrorAtToken:_currentOpeningToken description:@"HTML safety mismatch"]];
                        return NO;
                    }
                    
                    // Success: create new GRMustacheTemplateOverride
                    wrapperComponent = [GRMustacheTemplateOverride templateOverrideWithTemplate:template components:_currentComponents];
                } break;
                    
                default:
                    NSAssert(NO, @"WTF");
                    break;
            }
            
            NSAssert(wrapperComponent, @"WTF");
            [_openingTokenStack removeLastObject];
            [_componentsStack removeLastObject];
            self.currentOpeningToken = [_openingTokenStack lastObject];
            self.currentComponents = [_componentsStack lastObject];
            [_currentComponents addObject:wrapperComponent];
        } break;
            
            
        case GRMustacheTokenTypePartial: {
            // Template name validation
            if (token.partialName == nil) {
                [self failWithFatalError:[self parseErrorAtToken:token description:[NSString stringWithFormat:@"Missing partial name"]]];
                return NO;
            }
            
            // Ask templateRepository for partial template
            NSError *templateError;
            GRMustacheTemplate *template = [_templateRepository templateNamed:token.partialName error:&templateError];
            if (template == nil) {
                [self failWithFatalError:templateError];
                return NO;
            }
            
            // Success: append template component
            [_currentComponents addObject:template];
            
            // lock _contentType
            _contentTypeLocked = YES;
        } break;
        
        
        case GRMustacheTokenTypeOverridablePartial: {
            // Template name validation
            if (token.partialName == nil) {
                [self failWithFatalError:[self parseErrorAtToken:token description:[NSString stringWithFormat:@"Missing partial name"]]];
                return NO;
            }
            
            // Expand stacks
            self.currentOpeningToken = token;
            self.currentComponents = [[[NSMutableArray alloc] initWithCapacity:20] autorelease];
            [_openingTokenStack addObject:_currentOpeningToken];
            [_componentsStack addObject:_currentComponents];
            
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

- (void)failWithFatalError:(NSError *)fatalError
{
    // Make sure templateComponentsReturningError: returns correct results:
    self.fatalError = fatalError;
    self.currentComponents = nil;
    
    // All those objects are useless, now
    self.currentOpeningToken = nil;
    self.componentsStack = nil;
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


#pragma mark - GRMustacheAST

@implementation GRMustacheAST
@synthesize templateComponents=_templateComponents;
@synthesize contentType=_contentType;

- (void)dealloc
{
    [_templateComponents release];
    [super dealloc];
}

- (id)initWithTemplateComponents:(NSArray *)templateComponents contentType:(GRMustacheContentType)contentType
{
    self = [super init];
    if (self) {
        _templateComponents = [templateComponents retain];
        _contentType = contentType;
    }
    return self;
}

@end