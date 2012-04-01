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

#import "GRMustacheTemplateParser_private.h"
#import "GRMustacheTemplate_private.h"
#import "GRMustacheTextElement_private.h"
#import "GRMustacheVariableElement_private.h"
#import "GRMustacheSection_private.h"
#import "GRMustacheInvocation_private.h"
#import "GRMustacheError.h"

@interface GRMustacheTemplateParser()
@property (nonatomic, retain) NSError *error;
@property (nonatomic, retain) GRMustacheToken *currentSectionOpeningToken;
@property (nonatomic, retain) NSMutableArray *currentElements;
@property (nonatomic, retain) NSMutableArray *elementsStack;
@property (nonatomic, retain) NSMutableArray *sectionOpeningTokenStack;
- (id)initWithOptions:(GRMustacheTemplateOptions)options;
- (void)finish;
- (void)finishWithError:(NSError *)error;
- (NSError *)parseErrorAtToken:(GRMustacheToken *)token description:(NSString *)description;
- (GRMustacheInvocation *)invocationWithToken:(GRMustacheToken *)token error:(NSError **)outError;
@end

@implementation GRMustacheTemplateParser
@synthesize error=_error;
@synthesize currentSectionOpeningToken=_currentSectionOpeningToken;
@synthesize dataSource=_dataSource;
@synthesize currentElements=_currentElements;
@synthesize elementsStack=_elementsStack;
@synthesize sectionOpeningTokenStack=_sectionOpeningTokenStack;

+ (id)templateParserWithOptions:(GRMustacheTemplateOptions)options
{
    return [[[self alloc] initWithOptions:options] autorelease];
}

- (NSArray *)renderingElementsReturningError:(NSError **)outError
{
    [self finish];
    
    if (_error) {
        if (outError != NULL) {
            *outError = [[_error retain] autorelease];
        }
        return nil;
    }
    
    return [[_currentElements retain] autorelease];
}

- (void)dealloc
{
    [_error release];
    [_currentSectionOpeningToken release];
    [_currentElements release];
    [_elementsStack release];
    [_sectionOpeningTokenStack release];
    [super dealloc];
}

#pragma mark GRMustacheTokenizerDelegate

- (BOOL)tokenizer:(GRMustacheTokenizer *)tokenizer shouldContinueAfterParsingToken:(GRMustacheToken *)token
{
    if (!_elementsStack) return NO;
    
    switch (token.type) {
        case GRMustacheTokenTypeText:
            [_currentElements addObject:[GRMustacheTextElement textElementWithString:token.content]];
            break;
            
        case GRMustacheTokenTypeComment:
            break;
            
        case GRMustacheTokenTypeEscapedVariable: {
            if (token.content.length == 0) {
                [self finishWithError:[self parseErrorAtToken:token description:@"Empty variable tag"]];
                return NO;
            }
            NSError *invocationError;
            GRMustacheInvocation *invocation = [self invocationWithToken:token error:&invocationError];
            if (invocation) {
                [_currentElements addObject:[GRMustacheVariableElement variableElementWithInvocation:invocation raw:NO]];
            } else {
                [self finishWithError:invocationError];
                return NO;
            }
        } break;
            
        case GRMustacheTokenTypeUnescapedVariable: {
            if (token.content.length == 0) {
                [self finishWithError:[self parseErrorAtToken:token description:@"Empty unescaped variable tag"]];
                return NO;
            }
            NSError *invocationError;
            GRMustacheInvocation *invocation = [self invocationWithToken:token error:&invocationError];
            if (invocation) {
                [_currentElements addObject:[GRMustacheVariableElement variableElementWithInvocation:invocation raw:YES]];
            } else {
                [self finishWithError:invocationError];
                return NO;
            }
        } break;
            
        case GRMustacheTokenTypeSectionOpening:
        case GRMustacheTokenTypeInvertedSectionOpening: {
            if (token.content.length == 0) {
                [self finishWithError:[self parseErrorAtToken:token description:@"Empty section opening tag"]];
                return NO;
            }
            
            self.currentSectionOpeningToken = token;
            [_sectionOpeningTokenStack addObject:token];
            
            self.currentElements = [NSMutableArray array];
            [_elementsStack addObject:_currentElements];
        } break;
            
        case GRMustacheTokenTypeSectionClosing:
            if ([token.content isEqualToString:_currentSectionOpeningToken.content]) {
                NSError *invocationError;
                GRMustacheInvocation *invocation = [self invocationWithToken:_currentSectionOpeningToken error:&invocationError];
                if (invocation) {
                    NSRange currentSectionOpeningTokenRange = _currentSectionOpeningToken.range;
                    NSAssert(_currentSectionOpeningToken.templateString == token.templateString, @"not implemented");
                    NSRange range = NSMakeRange(currentSectionOpeningTokenRange.location + currentSectionOpeningTokenRange.length, token.range.location - currentSectionOpeningTokenRange.location - currentSectionOpeningTokenRange.length);
                    GRMustacheSection *section = [GRMustacheSection sectionElementWithInvocation:invocation
                                                                                  templateString:token.templateString
                                                                                           range:range
                                                                                        inverted:(_currentSectionOpeningToken.type == GRMustacheTokenTypeInvertedSectionOpening)
                                                                                        elements:_currentElements];
                    [_sectionOpeningTokenStack removeLastObject];
                    self.currentSectionOpeningToken = [_sectionOpeningTokenStack lastObject];
                    
                    [_elementsStack removeLastObject];
                    self.currentElements = [_elementsStack lastObject];
                    
                    [_currentElements addObject:section];
                } else {
                    [self finishWithError:invocationError];
                    return NO;
                }
            } else {
                [self finishWithError:[self parseErrorAtToken:token description:[NSString stringWithFormat:@"Unexpected `%@` section closing tag", token.content]]];
                return NO;
            }
            break;
            
        case GRMustacheTokenTypePartial: {
            if (token.content.length == 0) {
                [self finishWithError:[self parseErrorAtToken:token description:@"Empty partial tag"]];
                return NO;
            }
            NSError *partialError;
            id<GRMustacheRenderingElement> partial = [_dataSource templateParser:self renderingElementForPartialName:token.content error:&partialError];
            if (partial == nil) {
                [self finishWithError:partialError];
                return NO;
            } else {
                [_currentElements addObject:partial];
            }
        } break;
            
        case GRMustacheTokenTypeSetDelimiter:
            // ignore
            break;
            
        default:
            NSAssert(NO, @"");
            break;
            
    }
    return YES;
}

- (void)tokenizer:(GRMustacheTokenizer *)tokenizer didFailWithError:(NSError *)error
{
    [self finishWithError:error];
}

#pragma mark Private

- (id)initWithOptions:(GRMustacheTemplateOptions)options
{
    self = [self init];
    if (self) {
        _options = options;
        _currentElements = [[NSMutableArray alloc] initWithCapacity:20];
        _elementsStack = [[NSMutableArray alloc] initWithCapacity:20];
        [_elementsStack addObject:_currentElements];
        _sectionOpeningTokenStack = [[NSMutableArray alloc] initWithCapacity:20];
    }
    return self;
}

- (void)finishWithError:(NSError *)error
{
    self.error = error;
    [self finish];
}

- (void)finish
{
    if (_error == nil && _currentSectionOpeningToken) {
        self.error = [self parseErrorAtToken:_currentSectionOpeningToken description:[NSString stringWithFormat:@"Unclosed `%@` section", _currentSectionOpeningToken.content]];
    }
    if (_error) {
        self.currentElements = nil;
    }
    self.currentSectionOpeningToken = nil;
    self.elementsStack = nil;
    self.sectionOpeningTokenStack = nil;
}

- (NSError *)parseErrorAtToken:(GRMustacheToken *)token description:(NSString *)description
{
    NSString *localizedDescription;
    if (token.templateID) {
        localizedDescription = [NSString stringWithFormat:@"Parse error at line %d of template %@: %@", token.line, description, token.templateID];
    } else {
        localizedDescription = [NSString stringWithFormat:@"Parse error at line %d: %@", token.line, description];
    }
    return [NSError errorWithDomain:GRMustacheErrorDomain
                               code:GRMustacheErrorCodeParseError
                           userInfo:[NSDictionary dictionaryWithObject:localizedDescription forKey:NSLocalizedDescriptionKey]];
}

- (GRMustacheInvocation *)invocationWithToken:(GRMustacheToken *)token error:(NSError **)outError
{
    NSString *content = token.content;
    NSUInteger length = content.length;
    BOOL acceptDotIdentifier = YES;
    BOOL acceptIdentifier = YES;
    BOOL acceptSeparator = NO;
    NSMutableArray *keys = [NSMutableArray array];
    unichar c;
    NSUInteger identifierStart = 0;
    for (NSUInteger i = 0; i < length; ++i) {
        c = [content characterAtIndex:i];
        switch (c) {
            case '.':
                if (acceptDotIdentifier) {
                    [keys addObject:[content substringWithRange:NSMakeRange(identifierStart, i+1-identifierStart)]];
                    acceptDotIdentifier = NO;
                    acceptIdentifier = NO;
                    acceptSeparator = NO;
                } else if (acceptSeparator) {
                    [keys addObject:[content substringWithRange:NSMakeRange(identifierStart, i-identifierStart)]];
                    identifierStart = i + 1;
                    acceptDotIdentifier = NO;
                    acceptIdentifier = YES;
                    acceptSeparator = NO;
                } else {
                    if (outError != NULL) {
                        *outError = [self parseErrorAtToken:token description:[NSString stringWithFormat:@"Invalid identifier: %@", content]];
                    }
                    return nil;
                }
                break;
                
            default:
                if (acceptIdentifier) {
                    acceptDotIdentifier = NO;
                    acceptIdentifier = YES;
                    acceptSeparator = YES;
                } else {
                    if (outError != NULL) {
                        *outError = [self parseErrorAtToken:token description:[NSString stringWithFormat:@"Invalid identifier: %@", content]];
                    }
                    return nil;
                }
                
        }
    }
    if (acceptSeparator) {
        [keys addObject:[content substringWithRange:NSMakeRange(identifierStart, length - identifierStart)]];
    } else if (acceptIdentifier) {
        if (outError != NULL) {
            *outError = [self parseErrorAtToken:token description:[NSString stringWithFormat:@"Invalid identifier: %@", content]];
        }
        return nil;
    }
    
    return [GRMustacheInvocation invocationWithToken:token keys:keys options:_options];
}

@end
