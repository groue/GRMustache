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

#import "GRMustachePrivateAPITest.h"
#import "GRMustacheParser_private.h"
#import "GRMustacheIdentifierExpression_private.h"
#import "GRMustacheScopedExpression_private.h"
#import "GRMustacheFilteredExpression_private.h"
#import "GRMustacheConfiguration_private.h"
#import "GRMustacheError.h"


@class GRMustacheTokenRecorder;

@interface GRMustacheParserTest : GRMustachePrivateAPITest {
	GRMustacheParser *parser;
	GRMustacheTokenRecorder *tokenRecorder;
}
@end

@interface GRMustacheTokenRecorder : NSObject<GRMustacheParserDelegate> {
    NSError *_error;
    GRMustacheToken *_lastToken;
    NSMutableArray *_tokenTypes;
    NSMutableArray *_tokenTexts;
    NSMutableArray *_tokenExpressions;
    NSMutableArray *_tokenPartialNames;
    NSMutableArray *_tokenPragmas;
}
@property (nonatomic, retain, readonly) NSError *error;
@property (nonatomic, retain, readonly) GRMustacheToken *lastToken;
@property (readonly) NSUInteger tokenCount;
- (GRMustacheTokenType)tokenTypeAtIndex:(NSUInteger)index;
- (id)tokenTextAtIndex:(NSUInteger)index;
- (id)tokenExpressionAtIndex:(NSUInteger)index;
- (id)tokenPartialNameAtIndex:(NSUInteger)index;
- (id)tokenPragmaAtIndex:(NSUInteger)index;
@end

@implementation GRMustacheTokenRecorder
@synthesize error=_error;
@synthesize lastToken=_lastToken;
@dynamic tokenCount;

- (id)init
{
    self = [super init];
    if (self) {
        _tokenTypes = [[NSMutableArray array] retain];
        _tokenTexts = [[NSMutableArray array] retain];
        _tokenExpressions = [[NSMutableArray array] retain];
        _tokenPartialNames = [[NSMutableArray array] retain];
        _tokenPragmas = [[NSMutableArray array] retain];
    }
    return self;
}

- (void)dealloc
{
    [_lastToken release];
    [_tokenTypes release];
    [_tokenTexts release];
    [_tokenExpressions release];
    [_tokenPartialNames release];
    [_tokenPragmas release];
    [_error release];
    [super dealloc];
}

- (NSUInteger)tokenCount
{
    return _tokenTypes.count;
}

- (GRMustacheTokenType)tokenTypeAtIndex:(NSUInteger)index
{
    return [(NSNumber *)[_tokenTypes objectAtIndex:index] intValue];
}

- (id)tokenTextAtIndex:(NSUInteger)index;
{
    return [_tokenTexts objectAtIndex:index];
}

- (id)tokenExpressionAtIndex:(NSUInteger)index;
{
    return [_tokenExpressions objectAtIndex:index];
}

- (id)tokenPartialNameAtIndex:(NSUInteger)index;
{
    return [_tokenPartialNames objectAtIndex:index];
}

- (id)tokenPragmaAtIndex:(NSUInteger)index;
{
    return [_tokenPragmas objectAtIndex:index];
}

- (BOOL)parser:(GRMustacheParser *)parser shouldContinueAfterParsingToken:(GRMustacheToken *)token
{
    [_lastToken release];
    _lastToken = [token retain];
    
    [_tokenTypes addObject:[NSNumber numberWithInt:token.type]];
    
    if (token.text) {
        [_tokenTexts addObject:token.text];
    } else {
        [_tokenTexts addObject:[NSNull null]];
    }
    
    if (token.expression) {
        [_tokenExpressions addObject:token.expression];
    } else {
        [_tokenExpressions addObject:[NSNull null]];
    }
    
    if (token.partialName) {
        [_tokenPartialNames addObject:token.partialName];
    } else {
        [_tokenPartialNames addObject:[NSNull null]];
    }
    
    if (token.pragma) {
        [_tokenPragmas addObject:token.pragma];
    } else {
        [_tokenPragmas addObject:[NSNull null]];
    }
    
    return YES;
}

- (void)parser:(GRMustacheParser *)parser didFailWithError:(NSError *)error
{
    _error = [error retain];
}
@end



@implementation GRMustacheParserTest

- (void)setUp
{
    tokenRecorder = [[GRMustacheTokenRecorder alloc] init];
    parser = [[GRMustacheParser alloc] initWithConfiguration:[GRMustacheConfiguration defaultConfiguration]];
    parser.delegate = tokenRecorder;
}

- (void)tearDown
{
    [parser release];
    [tokenRecorder release];
}

- (void)testParserParsesTextToken
{
    NSString *templateString = @"text";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypeText, [tokenRecorder tokenTypeAtIndex:0], nil);
    STAssertEqualObjects(@"text", [tokenRecorder tokenTextAtIndex:0], nil);
}

- (void)testParserParsesCommentToken
{
    NSString *templateString = @"{{!comment}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypeComment, [tokenRecorder tokenTypeAtIndex:0], nil);
    STAssertEqualObjects(@"comment", [tokenRecorder tokenTextAtIndex:0], nil);
}

- (void)testParserParsesEscapedVariableTokenWithSingleKey
{
    NSString *templateString = @"{{name}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypeEscapedVariable, [tokenRecorder tokenTypeAtIndex:0], nil);
    GRMustacheIdentifierExpression *expression = [GRMustacheIdentifierExpression expressionWithIdentifier:@"name"];
    STAssertEqualObjects(expression, [tokenRecorder tokenExpressionAtIndex:0], nil);
}

- (void)testParserParsesEscapedVariableTokenWithCompoundKey
{
    NSString *templateString = @"{{foo.bar}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypeEscapedVariable, [tokenRecorder tokenTypeAtIndex:0], nil);
    GRMustacheScopedExpression *expression = [GRMustacheScopedExpression expressionWithBaseExpression:[GRMustacheIdentifierExpression expressionWithIdentifier:@"foo"] scopeIdentifier:@"bar"];
    STAssertEqualObjects(expression, [tokenRecorder tokenExpressionAtIndex:0], nil);
}

- (void)testParserTrimsEscapedVariableTokenWithSingleKey
{
    NSString *templateString = @"{{ \n\tname \n\t}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypeEscapedVariable, [tokenRecorder tokenTypeAtIndex:0], nil);
    GRMustacheIdentifierExpression *expression = [GRMustacheIdentifierExpression expressionWithIdentifier:@"name"];
    STAssertEqualObjects(expression, [tokenRecorder tokenExpressionAtIndex:0], nil);
}

- (void)testParserTrimsEscapedVariableTokenWithCompoundKey
{
    NSString *templateString = @"{{ \n\tfoo.bar \n\t}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypeEscapedVariable, [tokenRecorder tokenTypeAtIndex:0], nil);
    GRMustacheScopedExpression *expression = [GRMustacheScopedExpression expressionWithBaseExpression:[GRMustacheIdentifierExpression expressionWithIdentifier:@"foo"] scopeIdentifier:@"bar"];
    STAssertEqualObjects(expression, [tokenRecorder tokenExpressionAtIndex:0], nil);
}

- (void)testParserParsesEscapedVariableTokenWithFilter
{
    NSString *templateString = @"{{toto.titi(foo.bar)}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypeEscapedVariable, [tokenRecorder tokenTypeAtIndex:0], nil);
    GRMustacheScopedExpression *argumentExpression = [GRMustacheScopedExpression expressionWithBaseExpression:[GRMustacheIdentifierExpression expressionWithIdentifier:@"foo"] scopeIdentifier:@"bar"];
    GRMustacheScopedExpression *filterExpression = [GRMustacheScopedExpression expressionWithBaseExpression:[GRMustacheIdentifierExpression expressionWithIdentifier:@"toto"] scopeIdentifier:@"titi"];
    GRMustacheFilteredExpression *expression = [GRMustacheFilteredExpression expressionWithFilterExpression:filterExpression argumentExpression:argumentExpression];
    STAssertEqualObjects(expression, [tokenRecorder tokenExpressionAtIndex:0], nil);
}

- (void)testParserTrimsEscapedVariableTokenWithFilter
{
    NSString *templateString = @"{{ \n\ttoto.titi \n\t( \n\tfoo.bar \n\t) \n\t}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypeEscapedVariable, [tokenRecorder tokenTypeAtIndex:0], nil);
    GRMustacheScopedExpression *argumentExpression = [GRMustacheScopedExpression expressionWithBaseExpression:[GRMustacheIdentifierExpression expressionWithIdentifier:@"foo"] scopeIdentifier:@"bar"];
    GRMustacheScopedExpression *filterExpression = [GRMustacheScopedExpression expressionWithBaseExpression:[GRMustacheIdentifierExpression expressionWithIdentifier:@"toto"] scopeIdentifier:@"titi"];
    GRMustacheFilteredExpression *expression = [GRMustacheFilteredExpression expressionWithFilterExpression:filterExpression argumentExpression:argumentExpression];
    STAssertEqualObjects(expression, [tokenRecorder tokenExpressionAtIndex:0], nil);
}

- (void)testParserParsesEscapedVariableTokenWithComplexExpression
{
    NSString *templateString = @"{{ a.b ( c.d ( e.f ) .g.h ).i.j }}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypeEscapedVariable, [tokenRecorder tokenTypeAtIndex:0], nil);
    GRMustacheExpression *expression_e = [GRMustacheIdentifierExpression expressionWithIdentifier:@"e"];
    GRMustacheExpression *expression_ef = [GRMustacheScopedExpression expressionWithBaseExpression:expression_e scopeIdentifier:@"f"];
    GRMustacheExpression *expression_c = [GRMustacheIdentifierExpression expressionWithIdentifier:@"c"];
    GRMustacheExpression *expression_cd = [GRMustacheScopedExpression expressionWithBaseExpression:expression_c scopeIdentifier:@"d"];
    GRMustacheExpression *expression_cdef = [GRMustacheFilteredExpression expressionWithFilterExpression:expression_cd argumentExpression:expression_ef];
    GRMustacheExpression *expression_cdefg = [GRMustacheScopedExpression expressionWithBaseExpression:expression_cdef scopeIdentifier:@"g"];
    GRMustacheExpression *expression_cdefgh = [GRMustacheScopedExpression expressionWithBaseExpression:expression_cdefg scopeIdentifier:@"h"];
    GRMustacheExpression *expression_a = [GRMustacheIdentifierExpression expressionWithIdentifier:@"a"];
    GRMustacheExpression *expression_ab = [GRMustacheScopedExpression expressionWithBaseExpression:expression_a scopeIdentifier:@"b"];
    GRMustacheExpression *expression_abcdefgh = [GRMustacheFilteredExpression expressionWithFilterExpression:expression_ab argumentExpression:expression_cdefgh];
    GRMustacheExpression *expression_abcdefghi = [GRMustacheScopedExpression expressionWithBaseExpression:expression_abcdefgh scopeIdentifier:@"i"];
    GRMustacheExpression *expression_abcdefghij = [GRMustacheScopedExpression expressionWithBaseExpression:expression_abcdefghi scopeIdentifier:@"j"];
    
    STAssertEqualObjects(expression_abcdefghij, [tokenRecorder tokenExpressionAtIndex:0], nil);
}

- (void)testParserParsesUnescapedVariableTokenWithThreeMustacheWithSingleKey
{
    NSString *templateString = @"{{{name}}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypeUnescapedVariable, [tokenRecorder tokenTypeAtIndex:0], nil);
    GRMustacheIdentifierExpression *expression = [GRMustacheIdentifierExpression expressionWithIdentifier:@"name"];
    STAssertEqualObjects(expression, [tokenRecorder tokenExpressionAtIndex:0], nil);
}

- (void)testParserParsesUnescapedVariableTokenWithThreeMustacheWithCompoundKey
{
    NSString *templateString = @"{{{foo.bar}}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypeUnescapedVariable, [tokenRecorder tokenTypeAtIndex:0], nil);
    GRMustacheScopedExpression *expression = [GRMustacheScopedExpression expressionWithBaseExpression:[GRMustacheIdentifierExpression expressionWithIdentifier:@"foo"] scopeIdentifier:@"bar"];
    STAssertEqualObjects(expression, [tokenRecorder tokenExpressionAtIndex:0], nil);
}

- (void)testParserTrimsUnescapedVariableTokenWithThreeMustacheWithSingleKey
{
    NSString *templateString = @"{{{ \n\tname \n\t}}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypeUnescapedVariable, [tokenRecorder tokenTypeAtIndex:0], nil);
    GRMustacheIdentifierExpression *expression = [GRMustacheIdentifierExpression expressionWithIdentifier:@"name"];
    STAssertEqualObjects(expression, [tokenRecorder tokenExpressionAtIndex:0], nil);
}

- (void)testParserTrimsUnescapedVariableTokenWithThreeMustacheWithCompoundKey
{
    NSString *templateString = @"{{{ \n\tfoo.bar \n\t}}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypeUnescapedVariable, [tokenRecorder tokenTypeAtIndex:0], nil);
    GRMustacheScopedExpression *expression = [GRMustacheScopedExpression expressionWithBaseExpression:[GRMustacheIdentifierExpression expressionWithIdentifier:@"foo"] scopeIdentifier:@"bar"];
    STAssertEqualObjects(expression, [tokenRecorder tokenExpressionAtIndex:0], nil);
}

- (void)testParserParsesUnescapedVariableTokenWithThreeMustacheWithFilter
{
    NSString *templateString = @"{{{toto.titi(foo.bar)}}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypeUnescapedVariable, [tokenRecorder tokenTypeAtIndex:0], nil);
    GRMustacheScopedExpression *argumentExpression = [GRMustacheScopedExpression expressionWithBaseExpression:[GRMustacheIdentifierExpression expressionWithIdentifier:@"foo"] scopeIdentifier:@"bar"];
    GRMustacheScopedExpression *filterExpression = [GRMustacheScopedExpression expressionWithBaseExpression:[GRMustacheIdentifierExpression expressionWithIdentifier:@"toto"] scopeIdentifier:@"titi"];
    GRMustacheFilteredExpression *expression = [GRMustacheFilteredExpression expressionWithFilterExpression:filterExpression argumentExpression:argumentExpression];
    STAssertEqualObjects(expression, [tokenRecorder tokenExpressionAtIndex:0], nil);
}

- (void)testParserTrimsUnescapedVariableTokenWithThreeMustacheWithFilter
{
    NSString *templateString = @"{{{ \n\ttoto.titi \n\t( \n\tfoo.bar \n\t) \n\t}}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypeUnescapedVariable, [tokenRecorder tokenTypeAtIndex:0], nil);
    GRMustacheScopedExpression *argumentExpression = [GRMustacheScopedExpression expressionWithBaseExpression:[GRMustacheIdentifierExpression expressionWithIdentifier:@"foo"] scopeIdentifier:@"bar"];
    GRMustacheScopedExpression *filterExpression = [GRMustacheScopedExpression expressionWithBaseExpression:[GRMustacheIdentifierExpression expressionWithIdentifier:@"toto"] scopeIdentifier:@"titi"];
    GRMustacheFilteredExpression *expression = [GRMustacheFilteredExpression expressionWithFilterExpression:filterExpression argumentExpression:argumentExpression];
    STAssertEqualObjects(expression, [tokenRecorder tokenExpressionAtIndex:0], nil);
}

- (void)testParserParsesUnescapedVariableTokenWithAmpersandWithSingleKey
{
    NSString *templateString = @"{{&name}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypeUnescapedVariable, [tokenRecorder tokenTypeAtIndex:0], nil);
    GRMustacheIdentifierExpression *expression = [GRMustacheIdentifierExpression expressionWithIdentifier:@"name"];
    STAssertEqualObjects(expression, [tokenRecorder tokenExpressionAtIndex:0], nil);
}

- (void)testParserParsesUnescapedVariableTokenWithAmpersandWithCompoundKey
{
    NSString *templateString = @"{{&foo.bar}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypeUnescapedVariable, [tokenRecorder tokenTypeAtIndex:0], nil);
    GRMustacheScopedExpression *expression = [GRMustacheScopedExpression expressionWithBaseExpression:[GRMustacheIdentifierExpression expressionWithIdentifier:@"foo"] scopeIdentifier:@"bar"];
    STAssertEqualObjects(expression, [tokenRecorder tokenExpressionAtIndex:0], nil);
}

- (void)testParserTrimsUnescapedVariableTokenWithAmpersandWithSingleKey
{
    NSString *templateString = @"{{& \n\tname \n\t}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypeUnescapedVariable, [tokenRecorder tokenTypeAtIndex:0], nil);
    GRMustacheIdentifierExpression *expression = [GRMustacheIdentifierExpression expressionWithIdentifier:@"name"];
    STAssertEqualObjects(expression, [tokenRecorder tokenExpressionAtIndex:0], nil);
}

- (void)testParserTrimsUnescapedVariableTokenWithAmpersandWithCompoundKey
{
    NSString *templateString = @"{{& \n\tfoo.bar \n\t}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypeUnescapedVariable, [tokenRecorder tokenTypeAtIndex:0], nil);
    GRMustacheScopedExpression *expression = [GRMustacheScopedExpression expressionWithBaseExpression:[GRMustacheIdentifierExpression expressionWithIdentifier:@"foo"] scopeIdentifier:@"bar"];
    STAssertEqualObjects(expression, [tokenRecorder tokenExpressionAtIndex:0], nil);
}

- (void)testParserParsesUnescapedVariableTokenWithAmpersandWithFilter
{
    NSString *templateString = @"{{{toto.titi(foo.bar)}}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypeUnescapedVariable, [tokenRecorder tokenTypeAtIndex:0], nil);
    GRMustacheScopedExpression *argumentExpression = [GRMustacheScopedExpression expressionWithBaseExpression:[GRMustacheIdentifierExpression expressionWithIdentifier:@"foo"] scopeIdentifier:@"bar"];
    GRMustacheScopedExpression *filterExpression = [GRMustacheScopedExpression expressionWithBaseExpression:[GRMustacheIdentifierExpression expressionWithIdentifier:@"toto"] scopeIdentifier:@"titi"];
    GRMustacheFilteredExpression *expression = [GRMustacheFilteredExpression expressionWithFilterExpression:filterExpression argumentExpression:argumentExpression];
    STAssertEqualObjects(expression, [tokenRecorder tokenExpressionAtIndex:0], nil);
}

- (void)testParserTrimsUnescapedVariableTokenWithAmpersandWithFilter
{
    NSString *templateString = @"{{{ \n\ttoto.titi \n\t( \n\tfoo.bar \n\t) \n\t}}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypeUnescapedVariable, [tokenRecorder tokenTypeAtIndex:0], nil);
    GRMustacheScopedExpression *argumentExpression = [GRMustacheScopedExpression expressionWithBaseExpression:[GRMustacheIdentifierExpression expressionWithIdentifier:@"foo"] scopeIdentifier:@"bar"];
    GRMustacheScopedExpression *filterExpression = [GRMustacheScopedExpression expressionWithBaseExpression:[GRMustacheIdentifierExpression expressionWithIdentifier:@"toto"] scopeIdentifier:@"titi"];
    GRMustacheFilteredExpression *expression = [GRMustacheFilteredExpression expressionWithFilterExpression:filterExpression argumentExpression:argumentExpression];
    STAssertEqualObjects(expression, [tokenRecorder tokenExpressionAtIndex:0], nil);
}

- (void)testParserParsesSectionOpeningTokenWithSingleKey
{
    NSString *templateString = @"{{#name}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypeSectionOpening, [tokenRecorder tokenTypeAtIndex:0], nil);
    GRMustacheIdentifierExpression *expression = [GRMustacheIdentifierExpression expressionWithIdentifier:@"name"];
    STAssertEqualObjects(expression, [tokenRecorder tokenExpressionAtIndex:0], nil);
}

- (void)testParserParsesSectionOpeningTokenWithCompoundKey
{
    NSString *templateString = @"{{#foo.bar}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypeSectionOpening, [tokenRecorder tokenTypeAtIndex:0], nil);
    GRMustacheScopedExpression *expression = [GRMustacheScopedExpression expressionWithBaseExpression:[GRMustacheIdentifierExpression expressionWithIdentifier:@"foo"] scopeIdentifier:@"bar"];
    STAssertEqualObjects(expression, [tokenRecorder tokenExpressionAtIndex:0], nil);
}

- (void)testParserTrimsSectionOpeningTokenWithSingleKey
{
    NSString *templateString = @"{{# \n\tname \n\t}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypeSectionOpening, [tokenRecorder tokenTypeAtIndex:0], nil);
    GRMustacheIdentifierExpression *expression = [GRMustacheIdentifierExpression expressionWithIdentifier:@"name"];
    STAssertEqualObjects(expression, [tokenRecorder tokenExpressionAtIndex:0], nil);
}

- (void)testParserTrimsSectionOpeningTokenWithCompoundKey
{
    NSString *templateString = @"{{# \n\tfoo.bar \n\t}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypeSectionOpening, [tokenRecorder tokenTypeAtIndex:0], nil);
    GRMustacheScopedExpression *expression = [GRMustacheScopedExpression expressionWithBaseExpression:[GRMustacheIdentifierExpression expressionWithIdentifier:@"foo"] scopeIdentifier:@"bar"];
    STAssertEqualObjects(expression, [tokenRecorder tokenExpressionAtIndex:0], nil);
}

- (void)testParserParsesSectionOpeningTokenWithFilter
{
    NSString *templateString = @"{{#toto.titi(foo.bar)}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypeSectionOpening, [tokenRecorder tokenTypeAtIndex:0], nil);
    GRMustacheScopedExpression *argumentExpression = [GRMustacheScopedExpression expressionWithBaseExpression:[GRMustacheIdentifierExpression expressionWithIdentifier:@"foo"] scopeIdentifier:@"bar"];
    GRMustacheScopedExpression *filterExpression = [GRMustacheScopedExpression expressionWithBaseExpression:[GRMustacheIdentifierExpression expressionWithIdentifier:@"toto"] scopeIdentifier:@"titi"];
    GRMustacheFilteredExpression *expression = [GRMustacheFilteredExpression expressionWithFilterExpression:filterExpression argumentExpression:argumentExpression];
    STAssertEqualObjects(expression, [tokenRecorder tokenExpressionAtIndex:0], nil);
}

- (void)testParserTrimsSectionOpeningTokenWithFilter
{
    NSString *templateString = @"{{# \n\ttoto.titi \n\t( \n\tfoo.bar \n\t) \n\t}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypeSectionOpening, [tokenRecorder tokenTypeAtIndex:0], nil);
    GRMustacheScopedExpression *argumentExpression = [GRMustacheScopedExpression expressionWithBaseExpression:[GRMustacheIdentifierExpression expressionWithIdentifier:@"foo"] scopeIdentifier:@"bar"];
    GRMustacheScopedExpression *filterExpression = [GRMustacheScopedExpression expressionWithBaseExpression:[GRMustacheIdentifierExpression expressionWithIdentifier:@"toto"] scopeIdentifier:@"titi"];
    GRMustacheFilteredExpression *expression = [GRMustacheFilteredExpression expressionWithFilterExpression:filterExpression argumentExpression:argumentExpression];
    STAssertEqualObjects(expression, [tokenRecorder tokenExpressionAtIndex:0], nil);
}

- (void)testParserParsesInvertedSectionOpeningTokenWithSingleKey
{
    NSString *templateString = @"{{^name}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypeInvertedSectionOpening, [tokenRecorder tokenTypeAtIndex:0], nil);
    GRMustacheIdentifierExpression *expression = [GRMustacheIdentifierExpression expressionWithIdentifier:@"name"];
    STAssertEqualObjects(expression, [tokenRecorder tokenExpressionAtIndex:0], nil);
}

- (void)testParserParsesInvertedSectionOpeningTokenWithCompoundKey
{
    NSString *templateString = @"{{^foo.bar}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypeInvertedSectionOpening, [tokenRecorder tokenTypeAtIndex:0], nil);
    GRMustacheScopedExpression *expression = [GRMustacheScopedExpression expressionWithBaseExpression:[GRMustacheIdentifierExpression expressionWithIdentifier:@"foo"] scopeIdentifier:@"bar"];
    STAssertEqualObjects(expression, [tokenRecorder tokenExpressionAtIndex:0], nil);
}

- (void)testParserTrimsInvertedSectionOpeningTokenWithSingleKey
{
    NSString *templateString = @"{{^ \n\tname \n\t}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypeInvertedSectionOpening, [tokenRecorder tokenTypeAtIndex:0], nil);
    GRMustacheIdentifierExpression *expression = [GRMustacheIdentifierExpression expressionWithIdentifier:@"name"];
    STAssertEqualObjects(expression, [tokenRecorder tokenExpressionAtIndex:0], nil);
}

- (void)testParserTrimsInvertedSectionOpeningTokenWithCompoundKey
{
    NSString *templateString = @"{{^ \n\tfoo.bar \n\t}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypeInvertedSectionOpening, [tokenRecorder tokenTypeAtIndex:0], nil);
    GRMustacheScopedExpression *expression = [GRMustacheScopedExpression expressionWithBaseExpression:[GRMustacheIdentifierExpression expressionWithIdentifier:@"foo"] scopeIdentifier:@"bar"];
    STAssertEqualObjects(expression, [tokenRecorder tokenExpressionAtIndex:0], nil);
}

- (void)testParserParsesInvertedSectionOpeningTokenWithFilter
{
    NSString *templateString = @"{{^toto.titi(foo.bar)}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypeInvertedSectionOpening, [tokenRecorder tokenTypeAtIndex:0], nil);
    GRMustacheScopedExpression *argumentExpression = [GRMustacheScopedExpression expressionWithBaseExpression:[GRMustacheIdentifierExpression expressionWithIdentifier:@"foo"] scopeIdentifier:@"bar"];
    GRMustacheScopedExpression *filterExpression = [GRMustacheScopedExpression expressionWithBaseExpression:[GRMustacheIdentifierExpression expressionWithIdentifier:@"toto"] scopeIdentifier:@"titi"];
    GRMustacheFilteredExpression *expression = [GRMustacheFilteredExpression expressionWithFilterExpression:filterExpression argumentExpression:argumentExpression];
    STAssertEqualObjects(expression, [tokenRecorder tokenExpressionAtIndex:0], nil);
}

- (void)testParserTrimsInvertedSectionOpeningTokenWithFilter
{
    NSString *templateString = @"{{^ \n\ttoto.titi \n\t( \n\tfoo.bar \n\t) \n\t}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypeInvertedSectionOpening, [tokenRecorder tokenTypeAtIndex:0], nil);
    GRMustacheScopedExpression *argumentExpression = [GRMustacheScopedExpression expressionWithBaseExpression:[GRMustacheIdentifierExpression expressionWithIdentifier:@"foo"] scopeIdentifier:@"bar"];
    GRMustacheScopedExpression *filterExpression = [GRMustacheScopedExpression expressionWithBaseExpression:[GRMustacheIdentifierExpression expressionWithIdentifier:@"toto"] scopeIdentifier:@"titi"];
    GRMustacheFilteredExpression *expression = [GRMustacheFilteredExpression expressionWithFilterExpression:filterExpression argumentExpression:argumentExpression];
    STAssertEqualObjects(expression, [tokenRecorder tokenExpressionAtIndex:0], nil);
}

- (void)testParserParsesSectionClosingTokenWithSingleKey
{
    NSString *templateString = @"{{/name}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypeClosing, [tokenRecorder tokenTypeAtIndex:0], nil);
    GRMustacheIdentifierExpression *expression = [GRMustacheIdentifierExpression expressionWithIdentifier:@"name"];
    STAssertEqualObjects(expression, [tokenRecorder tokenExpressionAtIndex:0], nil);
}

- (void)testParserParsesSectionClosingTokenWithCompoundKey
{
    NSString *templateString = @"{{/foo.bar}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypeClosing, [tokenRecorder tokenTypeAtIndex:0], nil);
    GRMustacheScopedExpression *expression = [GRMustacheScopedExpression expressionWithBaseExpression:[GRMustacheIdentifierExpression expressionWithIdentifier:@"foo"] scopeIdentifier:@"bar"];
    STAssertEqualObjects(expression, [tokenRecorder tokenExpressionAtIndex:0], nil);
}

- (void)testParserTrimsSectionClosingTokenWithSingleKey
{
    NSString *templateString = @"{{/ \n\tname \n\t}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypeClosing, [tokenRecorder tokenTypeAtIndex:0], nil);
    GRMustacheIdentifierExpression *expression = [GRMustacheIdentifierExpression expressionWithIdentifier:@"name"];
    STAssertEqualObjects(expression, [tokenRecorder tokenExpressionAtIndex:0], nil);
}

- (void)testParserTrimsSectionClosingTokenWithCompoundKey
{
    NSString *templateString = @"{{/ \n\tfoo.bar \n\t}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypeClosing, [tokenRecorder tokenTypeAtIndex:0], nil);
    GRMustacheScopedExpression *expression = [GRMustacheScopedExpression expressionWithBaseExpression:[GRMustacheIdentifierExpression expressionWithIdentifier:@"foo"] scopeIdentifier:@"bar"];
    STAssertEqualObjects(expression, [tokenRecorder tokenExpressionAtIndex:0], nil);
}

- (void)testParserParsesSectionClosingTokenWithFilter
{
    NSString *templateString = @"{{/toto.titi(foo.bar)}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypeClosing, [tokenRecorder tokenTypeAtIndex:0], nil);
    GRMustacheScopedExpression *argumentExpression = [GRMustacheScopedExpression expressionWithBaseExpression:[GRMustacheIdentifierExpression expressionWithIdentifier:@"foo"] scopeIdentifier:@"bar"];
    GRMustacheScopedExpression *filterExpression = [GRMustacheScopedExpression expressionWithBaseExpression:[GRMustacheIdentifierExpression expressionWithIdentifier:@"toto"] scopeIdentifier:@"titi"];
    GRMustacheFilteredExpression *expression = [GRMustacheFilteredExpression expressionWithFilterExpression:filterExpression argumentExpression:argumentExpression];
    STAssertEqualObjects(expression, [tokenRecorder tokenExpressionAtIndex:0], nil);
}

- (void)testParserTrimsSectionClosingTokenWithFilter
{
    NSString *templateString = @"{{/ \n\ttoto.titi \n\t( \n\tfoo.bar \n\t) \n\t}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypeClosing, [tokenRecorder tokenTypeAtIndex:0], nil);
    GRMustacheScopedExpression *argumentExpression = [GRMustacheScopedExpression expressionWithBaseExpression:[GRMustacheIdentifierExpression expressionWithIdentifier:@"foo"] scopeIdentifier:@"bar"];
    GRMustacheScopedExpression *filterExpression = [GRMustacheScopedExpression expressionWithBaseExpression:[GRMustacheIdentifierExpression expressionWithIdentifier:@"toto"] scopeIdentifier:@"titi"];
    GRMustacheFilteredExpression *expression = [GRMustacheFilteredExpression expressionWithFilterExpression:filterExpression argumentExpression:argumentExpression];
    STAssertEqualObjects(expression, [tokenRecorder tokenExpressionAtIndex:0], nil);
}

- (void)testParserParsesPartialTokenWithoutExtension
{
    NSString *templateString = @"{{>name}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypePartial, [tokenRecorder tokenTypeAtIndex:0], nil);
    STAssertEqualObjects(@"name", [tokenRecorder tokenPartialNameAtIndex:0], nil);
}

- (void)testParserParsesPartialTokenWithExtension
{
    NSString *templateString = @"{{>name.html}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypePartial, [tokenRecorder tokenTypeAtIndex:0], nil);
    STAssertEqualObjects(@"name.html", [tokenRecorder tokenPartialNameAtIndex:0], nil);
}

- (void)testParserTrimsPartialToken
{
    NSString *templateString = @"{{> \n\tname \n\t}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypePartial, [tokenRecorder tokenTypeAtIndex:0], nil);
    STAssertEqualObjects(@"name", [tokenRecorder tokenPartialNameAtIndex:0], nil);
}

- (void)testParserParsesOverridablePartialClosingTokenWithoutExtension
{
    NSString *templateString = @"{{/name}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypeClosing, [tokenRecorder tokenTypeAtIndex:0], nil);
    STAssertEqualObjects(@"name", [tokenRecorder tokenPartialNameAtIndex:0], nil);
}

- (void)testParserParsesOverridablePartialClosingTokenWithExtension
{
    NSString *templateString = @"{{/name.html}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypeClosing, [tokenRecorder tokenTypeAtIndex:0], nil);
    STAssertEqualObjects(@"name.html", [tokenRecorder tokenPartialNameAtIndex:0], nil);
}

- (void)testParserTrimsOverridablePartialClosingToken
{
    NSString *templateString = @"{{/ \n\tname \n\t}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypeClosing, [tokenRecorder tokenTypeAtIndex:0], nil);
    STAssertEqualObjects(@"name", [tokenRecorder tokenPartialNameAtIndex:0], nil);
}

- (void)testParserParsesSetDelimiterToken
{
    NSString *templateString = @"{{=< >=}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypeSetDelimiter, [tokenRecorder tokenTypeAtIndex:0], nil);
}

- (void)testParserParsesPragmaToken
{
    NSString *templateString = @"{{%name}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypePragma, [tokenRecorder tokenTypeAtIndex:0], nil);
    STAssertEqualObjects(@"name", [tokenRecorder tokenPragmaAtIndex:0], nil);
}

- (void)testParserTrimsPragmaToken
{
    NSString *templateString = @"{{% \n\tname \n\t}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypePragma, [tokenRecorder tokenTypeAtIndex:0], nil);
    STAssertEqualObjects(@"name", [tokenRecorder tokenPragmaAtIndex:0], nil);
}

- (void)testParserParsesTokenSuite
{
    NSString *templateString = @"<{{!comment}}{{escaped_variable}}{{{unescaped_variable_1}}}{{&unescaped_variable_2}}{{#section_opening}}{{^inverted_section_opening}}{{/section_closing}}{{%pragma}}{{=< >=}}>";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)11, tokenRecorder.tokenCount, nil);
    
    STAssertEquals(GRMustacheTokenTypeText, [tokenRecorder tokenTypeAtIndex:0], nil);
    STAssertEqualObjects(@"<", [tokenRecorder tokenTextAtIndex:0], nil);
    
    STAssertEquals(GRMustacheTokenTypeComment, [tokenRecorder tokenTypeAtIndex:1], nil);
    STAssertEqualObjects(@"comment", [tokenRecorder tokenTextAtIndex:1], nil);
    
    STAssertEquals(GRMustacheTokenTypeEscapedVariable, [tokenRecorder tokenTypeAtIndex:2], nil);
    STAssertEqualObjects([GRMustacheIdentifierExpression expressionWithIdentifier:@"escaped_variable"], [tokenRecorder tokenExpressionAtIndex:2], nil);
    
    STAssertEquals(GRMustacheTokenTypeUnescapedVariable, [tokenRecorder tokenTypeAtIndex:3], nil);
    STAssertEqualObjects([GRMustacheIdentifierExpression expressionWithIdentifier:@"unescaped_variable_1"], [tokenRecorder tokenExpressionAtIndex:3], nil);
    
    STAssertEquals(GRMustacheTokenTypeUnescapedVariable, [tokenRecorder tokenTypeAtIndex:4], nil);
    STAssertEqualObjects([GRMustacheIdentifierExpression expressionWithIdentifier:@"unescaped_variable_2"], [tokenRecorder tokenExpressionAtIndex:4], nil);
    
    STAssertEquals(GRMustacheTokenTypeSectionOpening, [tokenRecorder tokenTypeAtIndex:5], nil);
    STAssertEqualObjects([GRMustacheIdentifierExpression expressionWithIdentifier:@"section_opening"], [tokenRecorder tokenExpressionAtIndex:5], nil);
    
    STAssertEquals(GRMustacheTokenTypeInvertedSectionOpening, [tokenRecorder tokenTypeAtIndex:6], nil);
    STAssertEqualObjects([GRMustacheIdentifierExpression expressionWithIdentifier:@"inverted_section_opening"], [tokenRecorder tokenExpressionAtIndex:6], nil);
    
    STAssertEquals(GRMustacheTokenTypeClosing, [tokenRecorder tokenTypeAtIndex:7], nil);
    STAssertEqualObjects([GRMustacheIdentifierExpression expressionWithIdentifier:@"section_closing"], [tokenRecorder tokenExpressionAtIndex:7], nil);
    
    STAssertEquals(GRMustacheTokenTypePragma, [tokenRecorder tokenTypeAtIndex:8], nil);
    STAssertEqualObjects(@"pragma", [tokenRecorder tokenPragmaAtIndex:8], nil);
    
    STAssertEquals(GRMustacheTokenTypeSetDelimiter, [tokenRecorder tokenTypeAtIndex:9], nil);

    STAssertEquals(GRMustacheTokenTypeText, [tokenRecorder tokenTypeAtIndex:10], nil);
    STAssertEqualObjects(@">", [tokenRecorder tokenTextAtIndex:10], nil);
}

- (void)testSetDelimiterTokensChain
{
    NSString *templateString = @"<{{= <% %> =}}<% start %><%=| |=%>|# middle || item ||/ middle ||={{ }}=|{{ final }}>";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)10, tokenRecorder.tokenCount, nil);
    
    STAssertEquals(GRMustacheTokenTypeText, [tokenRecorder tokenTypeAtIndex:0], nil);
    STAssertEqualObjects(@"<", [tokenRecorder tokenTextAtIndex:0], nil);
    
    STAssertEquals(GRMustacheTokenTypeSetDelimiter, [tokenRecorder tokenTypeAtIndex:1], nil);
    
    STAssertEquals(GRMustacheTokenTypeEscapedVariable, [tokenRecorder tokenTypeAtIndex:2], nil);
    STAssertEqualObjects([GRMustacheIdentifierExpression expressionWithIdentifier:@"start"], [tokenRecorder tokenExpressionAtIndex:2], nil);
    
    STAssertEquals(GRMustacheTokenTypeSetDelimiter, [tokenRecorder tokenTypeAtIndex:3], nil);
    
    STAssertEquals(GRMustacheTokenTypeSectionOpening, [tokenRecorder tokenTypeAtIndex:4], nil);
    STAssertEqualObjects([GRMustacheIdentifierExpression expressionWithIdentifier:@"middle"], [tokenRecorder tokenExpressionAtIndex:4], nil);
    
    STAssertEquals(GRMustacheTokenTypeEscapedVariable, [tokenRecorder tokenTypeAtIndex:5], nil);
    STAssertEqualObjects([GRMustacheIdentifierExpression expressionWithIdentifier:@"item"], [tokenRecorder tokenExpressionAtIndex:5], nil);
    
    STAssertEquals(GRMustacheTokenTypeClosing, [tokenRecorder tokenTypeAtIndex:6], nil);
    STAssertEqualObjects([GRMustacheIdentifierExpression expressionWithIdentifier:@"middle"], [tokenRecorder tokenExpressionAtIndex:6], nil);
    
    STAssertEquals(GRMustacheTokenTypeSetDelimiter, [tokenRecorder tokenTypeAtIndex:7], nil);
    
    STAssertEquals(GRMustacheTokenTypeEscapedVariable, [tokenRecorder tokenTypeAtIndex:8], nil);
    STAssertEqualObjects([GRMustacheIdentifierExpression expressionWithIdentifier:@"final"], [tokenRecorder tokenExpressionAtIndex:8], nil);
    
    STAssertEquals(GRMustacheTokenTypeText, [tokenRecorder tokenTypeAtIndex:9], nil);
    STAssertEqualObjects(@">", [tokenRecorder tokenTextAtIndex:9], nil);
}

- (void)testLotsOfStache
{
    NSString *templateString = @"{{{{foo}}}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNotNil(tokenRecorder.error, nil);
    STAssertEqualObjects(tokenRecorder.error.domain, GRMustacheErrorDomain, nil);
    STAssertEquals(tokenRecorder.error.code, (NSInteger)GRMustacheErrorCodeParseError, nil);
}


- (void)testIdentifiersCanNotStartWithMustacheTagCharacters
{
    NSArray *mustacheTagCharacters = @[@"{", @"}", @"<", @">", @"&", @"#", @"^", @"$", @"/"];
    
    // Identifiers can't start with a forbidden character
    
    for (NSString *mustacheTagCharacter in mustacheTagCharacters) {
        STAssertNil(([GRMustacheParser parseExpression:[NSString stringWithFormat:@"%@", mustacheTagCharacter] invalid:NULL]), nil);
        STAssertNil(([GRMustacheParser parseExpression:[NSString stringWithFormat:@"%@a", mustacheTagCharacter] invalid:NULL]), nil);
        STAssertNil(([GRMustacheParser parseExpression:[NSString stringWithFormat:@".%@a", mustacheTagCharacter] invalid:NULL]), nil);
        STAssertNil(([GRMustacheParser parseExpression:[NSString stringWithFormat:@"a.%@b", mustacheTagCharacter] invalid:NULL]), nil);
        STAssertNil(([GRMustacheParser parseExpression:[NSString stringWithFormat:@"a(%@b)", mustacheTagCharacter] invalid:NULL]), nil);
    }
}

@end
