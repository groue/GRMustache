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

#import "GRMustachePrivateAPITest.h"
#import "GRMustacheParser_private.h"
#import "GRMustacheIdentifierExpression_private.h"
#import "GRMustacheScopedExpression_private.h"
#import "GRMustacheFilteredExpression_private.h"
#import "GRMustacheError.h"


@class GRMustacheTokenRecorder;

@interface GRMustacheParserTest : GRMustachePrivateAPITest {
	GRMustacheParser *parser;
	GRMustacheTokenRecorder *tokenRecorder;
}
@end

@interface GRMustacheTokenRecorder : NSObject<GRMustacheParserDelegate> {
    NSError *_error;
    NSMutableArray *_tokenTypes;
    NSMutableArray *_tokenTextValues;
    NSMutableArray *_tokenExpressionValues;
    NSMutableArray *_tokenTemplateNameValues;
    NSMutableArray *_tokenPragmaValues;
}
@property (nonatomic, retain, readonly) NSError *error;
@property (readonly) NSUInteger tokenCount;
- (GRMustacheTokenType)tokenTypeAtIndex:(NSUInteger)index;
- (id)tokenTextValueAtIndex:(NSUInteger)index;
- (id)tokenExpressionValueAtIndex:(NSUInteger)index;
- (id)tokenTemplateNameValueAtIndex:(NSUInteger)index;
- (id)tokenPragmaValueAtIndex:(NSUInteger)index;
@end

@implementation GRMustacheTokenRecorder
@synthesize error=_error;
@dynamic tokenCount;

- (id)init
{
    self = [super init];
    if (self) {
        _tokenTypes = [[NSMutableArray array] retain];
        _tokenTextValues = [[NSMutableArray array] retain];
        _tokenExpressionValues = [[NSMutableArray array] retain];
        _tokenTemplateNameValues = [[NSMutableArray array] retain];
        _tokenPragmaValues = [[NSMutableArray array] retain];
    }
    return self;
}

- (void)dealloc
{
    [_tokenTypes release];
    [_tokenTextValues release];
    [_tokenExpressionValues release];
    [_tokenTemplateNameValues release];
    [_tokenPragmaValues release];
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

- (id)tokenTextValueAtIndex:(NSUInteger)index;
{
    return [_tokenTextValues objectAtIndex:index];
}

- (id)tokenExpressionValueAtIndex:(NSUInteger)index;
{
    return [_tokenExpressionValues objectAtIndex:index];
}

- (id)tokenTemplateNameValueAtIndex:(NSUInteger)index;
{
    return [_tokenTemplateNameValues objectAtIndex:index];
}

- (id)tokenPragmaValueAtIndex:(NSUInteger)index;
{
    return [_tokenPragmaValues objectAtIndex:index];
}

- (BOOL)parser:(GRMustacheParser *)parser shouldContinueAfterParsingToken:(GRMustacheToken *)token
{
    [_tokenTypes addObject:[NSNumber numberWithInt:token.type]];
    
    if (token.textValue) {
        [_tokenTextValues addObject:token.textValue];
    } else {
        [_tokenTextValues addObject:[NSNull null]];
    }
    
    if (token.expressionValue) {
        [_tokenExpressionValues addObject:token.expressionValue];
    } else {
        [_tokenExpressionValues addObject:[NSNull null]];
    }
    
    if (token.templateNameValue) {
        [_tokenTemplateNameValues addObject:token.templateNameValue];
    } else {
        [_tokenTemplateNameValues addObject:[NSNull null]];
    }
    
    if (token.pragmaValue) {
        [_tokenPragmaValues addObject:token.pragmaValue];
    } else {
        [_tokenPragmaValues addObject:[NSNull null]];
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
    parser = [[GRMustacheParser alloc] init];
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
    STAssertEqualObjects(@"text", [tokenRecorder tokenTextValueAtIndex:0], nil);
}

- (void)testParserParsesCommentToken
{
    NSString *templateString = @"{{!comment}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypeComment, [tokenRecorder tokenTypeAtIndex:0], nil);
    STAssertEqualObjects(@"comment", [tokenRecorder tokenTextValueAtIndex:0], nil);
}

- (void)testParserParsesEscapedVariableTokenWithSingleKey
{
    NSString *templateString = @"{{name}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypeEscapedVariable, [tokenRecorder tokenTypeAtIndex:0], nil);
    GRMustacheIdentifierExpression *expression = [GRMustacheIdentifierExpression expressionWithIdentifier:@"name"];
    STAssertEqualObjects(expression, [tokenRecorder tokenExpressionValueAtIndex:0], nil);
}

- (void)testParserParsesEscapedVariableTokenWithCompoundKey
{
    NSString *templateString = @"{{foo.bar}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypeEscapedVariable, [tokenRecorder tokenTypeAtIndex:0], nil);
    GRMustacheScopedExpression *expression = [GRMustacheScopedExpression expressionWithBaseExpression:[GRMustacheIdentifierExpression expressionWithIdentifier:@"foo"] scopeIdentifier:@"bar"];
    STAssertEqualObjects(expression, [tokenRecorder tokenExpressionValueAtIndex:0], nil);
}

- (void)testParserTrimsEscapedVariableTokenWithSingleKey
{
    NSString *templateString = @"{{ \n\tname \n\t}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypeEscapedVariable, [tokenRecorder tokenTypeAtIndex:0], nil);
    GRMustacheIdentifierExpression *expression = [GRMustacheIdentifierExpression expressionWithIdentifier:@"name"];
    STAssertEqualObjects(expression, [tokenRecorder tokenExpressionValueAtIndex:0], nil);
}

- (void)testParserTrimsEscapedVariableTokenWithCompoundKey
{
    NSString *templateString = @"{{ \n\tfoo.bar \n\t}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypeEscapedVariable, [tokenRecorder tokenTypeAtIndex:0], nil);
    GRMustacheScopedExpression *expression = [GRMustacheScopedExpression expressionWithBaseExpression:[GRMustacheIdentifierExpression expressionWithIdentifier:@"foo"] scopeIdentifier:@"bar"];
    STAssertEqualObjects(expression, [tokenRecorder tokenExpressionValueAtIndex:0], nil);
}

- (void)testParserParsesEscapedVariableTokenWithFilter
{
    NSString *templateString = @"{{%FILTERS}}{{toto.titi(foo.bar)}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)2, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypeEscapedVariable, [tokenRecorder tokenTypeAtIndex:1], nil);
    GRMustacheScopedExpression *parameterExpression = [GRMustacheScopedExpression expressionWithBaseExpression:[GRMustacheIdentifierExpression expressionWithIdentifier:@"foo"] scopeIdentifier:@"bar"];
    GRMustacheScopedExpression *filterExpression = [GRMustacheScopedExpression expressionWithBaseExpression:[GRMustacheIdentifierExpression expressionWithIdentifier:@"toto"] scopeIdentifier:@"titi"];
    GRMustacheFilteredExpression *expression = [GRMustacheFilteredExpression expressionWithFilterExpression:filterExpression parameterExpression:parameterExpression];
    STAssertEqualObjects(expression, [tokenRecorder tokenExpressionValueAtIndex:1], nil);
}

- (void)testParserTrimsEscapedVariableTokenWithFilter
{
    NSString *templateString = @"{{%FILTERS}}{{ \n\ttoto.titi \n\t( \n\tfoo.bar \n\t) \n\t}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)2, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypeEscapedVariable, [tokenRecorder tokenTypeAtIndex:1], nil);
    GRMustacheScopedExpression *parameterExpression = [GRMustacheScopedExpression expressionWithBaseExpression:[GRMustacheIdentifierExpression expressionWithIdentifier:@"foo"] scopeIdentifier:@"bar"];
    GRMustacheScopedExpression *filterExpression = [GRMustacheScopedExpression expressionWithBaseExpression:[GRMustacheIdentifierExpression expressionWithIdentifier:@"toto"] scopeIdentifier:@"titi"];
    GRMustacheFilteredExpression *expression = [GRMustacheFilteredExpression expressionWithFilterExpression:filterExpression parameterExpression:parameterExpression];
    STAssertEqualObjects(expression, [tokenRecorder tokenExpressionValueAtIndex:1], nil);
}

- (void)testParserParsesEscapedVariableTokenWithComplexExpression
{
    NSString *templateString = @"{{%FILTERS}}{{ a.b ( c.d ( e.f ) .g.h ).i.j }}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)2, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypeEscapedVariable, [tokenRecorder tokenTypeAtIndex:1], nil);
    GRMustacheExpression *expression_e = [GRMustacheIdentifierExpression expressionWithIdentifier:@"e"];
    GRMustacheExpression *expression_ef = [GRMustacheScopedExpression expressionWithBaseExpression:expression_e scopeIdentifier:@"f"];
    GRMustacheExpression *expression_c = [GRMustacheIdentifierExpression expressionWithIdentifier:@"c"];
    GRMustacheExpression *expression_cd = [GRMustacheScopedExpression expressionWithBaseExpression:expression_c scopeIdentifier:@"d"];
    GRMustacheExpression *expression_cdef = [GRMustacheFilteredExpression expressionWithFilterExpression:expression_cd parameterExpression:expression_ef];
    GRMustacheExpression *expression_cdefg = [GRMustacheScopedExpression expressionWithBaseExpression:expression_cdef scopeIdentifier:@"g"];
    GRMustacheExpression *expression_cdefgh = [GRMustacheScopedExpression expressionWithBaseExpression:expression_cdefg scopeIdentifier:@"h"];
    GRMustacheExpression *expression_a = [GRMustacheIdentifierExpression expressionWithIdentifier:@"a"];
    GRMustacheExpression *expression_ab = [GRMustacheScopedExpression expressionWithBaseExpression:expression_a scopeIdentifier:@"b"];
    GRMustacheExpression *expression_abcdefgh = [GRMustacheFilteredExpression expressionWithFilterExpression:expression_ab parameterExpression:expression_cdefgh];
    GRMustacheExpression *expression_abcdefghi = [GRMustacheScopedExpression expressionWithBaseExpression:expression_abcdefgh scopeIdentifier:@"i"];
    GRMustacheExpression *expression_abcdefghij = [GRMustacheScopedExpression expressionWithBaseExpression:expression_abcdefghi scopeIdentifier:@"j"];
    
    STAssertEqualObjects(expression_abcdefghij, [tokenRecorder tokenExpressionValueAtIndex:1], nil);
}

- (void)testParserParsesUnescapedVariableTokenWithThreeMustacheWithSingleKey
{
    NSString *templateString = @"{{{name}}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypeUnescapedVariable, [tokenRecorder tokenTypeAtIndex:0], nil);
    GRMustacheIdentifierExpression *expression = [GRMustacheIdentifierExpression expressionWithIdentifier:@"name"];
    STAssertEqualObjects(expression, [tokenRecorder tokenExpressionValueAtIndex:0], nil);
}

- (void)testParserParsesUnescapedVariableTokenWithThreeMustacheWithCompoundKey
{
    NSString *templateString = @"{{{foo.bar}}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypeUnescapedVariable, [tokenRecorder tokenTypeAtIndex:0], nil);
    GRMustacheScopedExpression *expression = [GRMustacheScopedExpression expressionWithBaseExpression:[GRMustacheIdentifierExpression expressionWithIdentifier:@"foo"] scopeIdentifier:@"bar"];
    STAssertEqualObjects(expression, [tokenRecorder tokenExpressionValueAtIndex:0], nil);
}

- (void)testParserTrimsUnescapedVariableTokenWithThreeMustacheWithSingleKey
{
    NSString *templateString = @"{{{ \n\tname \n\t}}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypeUnescapedVariable, [tokenRecorder tokenTypeAtIndex:0], nil);
    GRMustacheIdentifierExpression *expression = [GRMustacheIdentifierExpression expressionWithIdentifier:@"name"];
    STAssertEqualObjects(expression, [tokenRecorder tokenExpressionValueAtIndex:0], nil);
}

- (void)testParserTrimsUnescapedVariableTokenWithThreeMustacheWithCompoundKey
{
    NSString *templateString = @"{{{ \n\tfoo.bar \n\t}}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypeUnescapedVariable, [tokenRecorder tokenTypeAtIndex:0], nil);
    GRMustacheScopedExpression *expression = [GRMustacheScopedExpression expressionWithBaseExpression:[GRMustacheIdentifierExpression expressionWithIdentifier:@"foo"] scopeIdentifier:@"bar"];
    STAssertEqualObjects(expression, [tokenRecorder tokenExpressionValueAtIndex:0], nil);
}

- (void)testParserParsesUnescapedVariableTokenWithThreeMustacheWithFilter
{
    NSString *templateString = @"{{%FILTERS}}{{{toto.titi(foo.bar)}}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)2, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypeUnescapedVariable, [tokenRecorder tokenTypeAtIndex:1], nil);
    GRMustacheScopedExpression *parameterExpression = [GRMustacheScopedExpression expressionWithBaseExpression:[GRMustacheIdentifierExpression expressionWithIdentifier:@"foo"] scopeIdentifier:@"bar"];
    GRMustacheScopedExpression *filterExpression = [GRMustacheScopedExpression expressionWithBaseExpression:[GRMustacheIdentifierExpression expressionWithIdentifier:@"toto"] scopeIdentifier:@"titi"];
    GRMustacheFilteredExpression *expression = [GRMustacheFilteredExpression expressionWithFilterExpression:filterExpression parameterExpression:parameterExpression];
    STAssertEqualObjects(expression, [tokenRecorder tokenExpressionValueAtIndex:1], nil);
}

- (void)testParserTrimsUnescapedVariableTokenWithThreeMustacheWithFilter
{
    NSString *templateString = @"{{%FILTERS}}{{{ \n\ttoto.titi \n\t( \n\tfoo.bar \n\t) \n\t}}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)2, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypeUnescapedVariable, [tokenRecorder tokenTypeAtIndex:1], nil);
    GRMustacheScopedExpression *parameterExpression = [GRMustacheScopedExpression expressionWithBaseExpression:[GRMustacheIdentifierExpression expressionWithIdentifier:@"foo"] scopeIdentifier:@"bar"];
    GRMustacheScopedExpression *filterExpression = [GRMustacheScopedExpression expressionWithBaseExpression:[GRMustacheIdentifierExpression expressionWithIdentifier:@"toto"] scopeIdentifier:@"titi"];
    GRMustacheFilteredExpression *expression = [GRMustacheFilteredExpression expressionWithFilterExpression:filterExpression parameterExpression:parameterExpression];
    STAssertEqualObjects(expression, [tokenRecorder tokenExpressionValueAtIndex:1], nil);
}

- (void)testParserParsesUnescapedVariableTokenWithAmpersandWithSingleKey
{
    NSString *templateString = @"{{&name}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypeUnescapedVariable, [tokenRecorder tokenTypeAtIndex:0], nil);
    GRMustacheIdentifierExpression *expression = [GRMustacheIdentifierExpression expressionWithIdentifier:@"name"];
    STAssertEqualObjects(expression, [tokenRecorder tokenExpressionValueAtIndex:0], nil);
}

- (void)testParserParsesUnescapedVariableTokenWithAmpersandWithCompoundKey
{
    NSString *templateString = @"{{&foo.bar}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypeUnescapedVariable, [tokenRecorder tokenTypeAtIndex:0], nil);
    GRMustacheScopedExpression *expression = [GRMustacheScopedExpression expressionWithBaseExpression:[GRMustacheIdentifierExpression expressionWithIdentifier:@"foo"] scopeIdentifier:@"bar"];
    STAssertEqualObjects(expression, [tokenRecorder tokenExpressionValueAtIndex:0], nil);
}

- (void)testParserTrimsUnescapedVariableTokenWithAmpersandWithSingleKey
{
    NSString *templateString = @"{{& \n\tname \n\t}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypeUnescapedVariable, [tokenRecorder tokenTypeAtIndex:0], nil);
    GRMustacheIdentifierExpression *expression = [GRMustacheIdentifierExpression expressionWithIdentifier:@"name"];
    STAssertEqualObjects(expression, [tokenRecorder tokenExpressionValueAtIndex:0], nil);
}

- (void)testParserTrimsUnescapedVariableTokenWithAmpersandWithCompoundKey
{
    NSString *templateString = @"{{& \n\tfoo.bar \n\t}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypeUnescapedVariable, [tokenRecorder tokenTypeAtIndex:0], nil);
    GRMustacheScopedExpression *expression = [GRMustacheScopedExpression expressionWithBaseExpression:[GRMustacheIdentifierExpression expressionWithIdentifier:@"foo"] scopeIdentifier:@"bar"];
    STAssertEqualObjects(expression, [tokenRecorder tokenExpressionValueAtIndex:0], nil);
}

- (void)testParserParsesUnescapedVariableTokenWithAmpersandWithFilter
{
    NSString *templateString = @"{{%FILTERS}}{{{toto.titi(foo.bar)}}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)2, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypeUnescapedVariable, [tokenRecorder tokenTypeAtIndex:1], nil);
    GRMustacheScopedExpression *parameterExpression = [GRMustacheScopedExpression expressionWithBaseExpression:[GRMustacheIdentifierExpression expressionWithIdentifier:@"foo"] scopeIdentifier:@"bar"];
    GRMustacheScopedExpression *filterExpression = [GRMustacheScopedExpression expressionWithBaseExpression:[GRMustacheIdentifierExpression expressionWithIdentifier:@"toto"] scopeIdentifier:@"titi"];
    GRMustacheFilteredExpression *expression = [GRMustacheFilteredExpression expressionWithFilterExpression:filterExpression parameterExpression:parameterExpression];
    STAssertEqualObjects(expression, [tokenRecorder tokenExpressionValueAtIndex:1], nil);
}

- (void)testParserTrimsUnescapedVariableTokenWithAmpersandWithFilter
{
    NSString *templateString = @"{{%FILTERS}}{{{ \n\ttoto.titi \n\t( \n\tfoo.bar \n\t) \n\t}}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)2, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypeUnescapedVariable, [tokenRecorder tokenTypeAtIndex:1], nil);
    GRMustacheScopedExpression *parameterExpression = [GRMustacheScopedExpression expressionWithBaseExpression:[GRMustacheIdentifierExpression expressionWithIdentifier:@"foo"] scopeIdentifier:@"bar"];
    GRMustacheScopedExpression *filterExpression = [GRMustacheScopedExpression expressionWithBaseExpression:[GRMustacheIdentifierExpression expressionWithIdentifier:@"toto"] scopeIdentifier:@"titi"];
    GRMustacheFilteredExpression *expression = [GRMustacheFilteredExpression expressionWithFilterExpression:filterExpression parameterExpression:parameterExpression];
    STAssertEqualObjects(expression, [tokenRecorder tokenExpressionValueAtIndex:1], nil);
}

- (void)testParserParsesSectionOpeningTokenWithSingleKey
{
    NSString *templateString = @"{{#name}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypeSectionOpening, [tokenRecorder tokenTypeAtIndex:0], nil);
    GRMustacheIdentifierExpression *expression = [GRMustacheIdentifierExpression expressionWithIdentifier:@"name"];
    STAssertEqualObjects(expression, [tokenRecorder tokenExpressionValueAtIndex:0], nil);
}

- (void)testParserParsesSectionOpeningTokenWithCompoundKey
{
    NSString *templateString = @"{{#foo.bar}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypeSectionOpening, [tokenRecorder tokenTypeAtIndex:0], nil);
    GRMustacheScopedExpression *expression = [GRMustacheScopedExpression expressionWithBaseExpression:[GRMustacheIdentifierExpression expressionWithIdentifier:@"foo"] scopeIdentifier:@"bar"];
    STAssertEqualObjects(expression, [tokenRecorder tokenExpressionValueAtIndex:0], nil);
}

- (void)testParserTrimsSectionOpeningTokenWithSingleKey
{
    NSString *templateString = @"{{# \n\tname \n\t}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypeSectionOpening, [tokenRecorder tokenTypeAtIndex:0], nil);
    GRMustacheIdentifierExpression *expression = [GRMustacheIdentifierExpression expressionWithIdentifier:@"name"];
    STAssertEqualObjects(expression, [tokenRecorder tokenExpressionValueAtIndex:0], nil);
}

- (void)testParserTrimsSectionOpeningTokenWithCompoundKey
{
    NSString *templateString = @"{{# \n\tfoo.bar \n\t}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypeSectionOpening, [tokenRecorder tokenTypeAtIndex:0], nil);
    GRMustacheScopedExpression *expression = [GRMustacheScopedExpression expressionWithBaseExpression:[GRMustacheIdentifierExpression expressionWithIdentifier:@"foo"] scopeIdentifier:@"bar"];
    STAssertEqualObjects(expression, [tokenRecorder tokenExpressionValueAtIndex:0], nil);
}

- (void)testParserParsesSectionOpeningTokenWithFilter
{
    NSString *templateString = @"{{%FILTERS}}{{#toto.titi(foo.bar)}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)2, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypeSectionOpening, [tokenRecorder tokenTypeAtIndex:1], nil);
    GRMustacheScopedExpression *parameterExpression = [GRMustacheScopedExpression expressionWithBaseExpression:[GRMustacheIdentifierExpression expressionWithIdentifier:@"foo"] scopeIdentifier:@"bar"];
    GRMustacheScopedExpression *filterExpression = [GRMustacheScopedExpression expressionWithBaseExpression:[GRMustacheIdentifierExpression expressionWithIdentifier:@"toto"] scopeIdentifier:@"titi"];
    GRMustacheFilteredExpression *expression = [GRMustacheFilteredExpression expressionWithFilterExpression:filterExpression parameterExpression:parameterExpression];
    STAssertEqualObjects(expression, [tokenRecorder tokenExpressionValueAtIndex:1], nil);
}

- (void)testParserTrimsSectionOpeningTokenWithFilter
{
    NSString *templateString = @"{{%FILTERS}}{{# \n\ttoto.titi \n\t( \n\tfoo.bar \n\t) \n\t}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)2, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypeSectionOpening, [tokenRecorder tokenTypeAtIndex:1], nil);
    GRMustacheScopedExpression *parameterExpression = [GRMustacheScopedExpression expressionWithBaseExpression:[GRMustacheIdentifierExpression expressionWithIdentifier:@"foo"] scopeIdentifier:@"bar"];
    GRMustacheScopedExpression *filterExpression = [GRMustacheScopedExpression expressionWithBaseExpression:[GRMustacheIdentifierExpression expressionWithIdentifier:@"toto"] scopeIdentifier:@"titi"];
    GRMustacheFilteredExpression *expression = [GRMustacheFilteredExpression expressionWithFilterExpression:filterExpression parameterExpression:parameterExpression];
    STAssertEqualObjects(expression, [tokenRecorder tokenExpressionValueAtIndex:1], nil);
}

- (void)testParserParsesInvertedSectionOpeningTokenWithSingleKey
{
    NSString *templateString = @"{{^name}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypeInvertedSectionOpening, [tokenRecorder tokenTypeAtIndex:0], nil);
    GRMustacheIdentifierExpression *expression = [GRMustacheIdentifierExpression expressionWithIdentifier:@"name"];
    STAssertEqualObjects(expression, [tokenRecorder tokenExpressionValueAtIndex:0], nil);
}

- (void)testParserParsesInvertedSectionOpeningTokenWithCompoundKey
{
    NSString *templateString = @"{{^foo.bar}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypeInvertedSectionOpening, [tokenRecorder tokenTypeAtIndex:0], nil);
    GRMustacheScopedExpression *expression = [GRMustacheScopedExpression expressionWithBaseExpression:[GRMustacheIdentifierExpression expressionWithIdentifier:@"foo"] scopeIdentifier:@"bar"];
    STAssertEqualObjects(expression, [tokenRecorder tokenExpressionValueAtIndex:0], nil);
}

- (void)testParserTrimsInvertedSectionOpeningTokenWithSingleKey
{
    NSString *templateString = @"{{^ \n\tname \n\t}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypeInvertedSectionOpening, [tokenRecorder tokenTypeAtIndex:0], nil);
    GRMustacheIdentifierExpression *expression = [GRMustacheIdentifierExpression expressionWithIdentifier:@"name"];
    STAssertEqualObjects(expression, [tokenRecorder tokenExpressionValueAtIndex:0], nil);
}

- (void)testParserTrimsInvertedSectionOpeningTokenWithCompoundKey
{
    NSString *templateString = @"{{^ \n\tfoo.bar \n\t}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypeInvertedSectionOpening, [tokenRecorder tokenTypeAtIndex:0], nil);
    GRMustacheScopedExpression *expression = [GRMustacheScopedExpression expressionWithBaseExpression:[GRMustacheIdentifierExpression expressionWithIdentifier:@"foo"] scopeIdentifier:@"bar"];
    STAssertEqualObjects(expression, [tokenRecorder tokenExpressionValueAtIndex:0], nil);
}

- (void)testParserParsesInvertedSectionOpeningTokenWithFilter
{
    NSString *templateString = @"{{%FILTERS}}{{^toto.titi(foo.bar)}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)2, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypeInvertedSectionOpening, [tokenRecorder tokenTypeAtIndex:1], nil);
    GRMustacheScopedExpression *parameterExpression = [GRMustacheScopedExpression expressionWithBaseExpression:[GRMustacheIdentifierExpression expressionWithIdentifier:@"foo"] scopeIdentifier:@"bar"];
    GRMustacheScopedExpression *filterExpression = [GRMustacheScopedExpression expressionWithBaseExpression:[GRMustacheIdentifierExpression expressionWithIdentifier:@"toto"] scopeIdentifier:@"titi"];
    GRMustacheFilteredExpression *expression = [GRMustacheFilteredExpression expressionWithFilterExpression:filterExpression parameterExpression:parameterExpression];
    STAssertEqualObjects(expression, [tokenRecorder tokenExpressionValueAtIndex:1], nil);
}

- (void)testParserTrimsInvertedSectionOpeningTokenWithFilter
{
    NSString *templateString = @"{{%FILTERS}}{{^ \n\ttoto.titi \n\t( \n\tfoo.bar \n\t) \n\t}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)2, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypeInvertedSectionOpening, [tokenRecorder tokenTypeAtIndex:1], nil);
    GRMustacheScopedExpression *parameterExpression = [GRMustacheScopedExpression expressionWithBaseExpression:[GRMustacheIdentifierExpression expressionWithIdentifier:@"foo"] scopeIdentifier:@"bar"];
    GRMustacheScopedExpression *filterExpression = [GRMustacheScopedExpression expressionWithBaseExpression:[GRMustacheIdentifierExpression expressionWithIdentifier:@"toto"] scopeIdentifier:@"titi"];
    GRMustacheFilteredExpression *expression = [GRMustacheFilteredExpression expressionWithFilterExpression:filterExpression parameterExpression:parameterExpression];
    STAssertEqualObjects(expression, [tokenRecorder tokenExpressionValueAtIndex:1], nil);
}

- (void)testParserParsesSectionClosingTokenWithSingleKey
{
    NSString *templateString = @"{{/name}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypeClosing, [tokenRecorder tokenTypeAtIndex:0], nil);
    GRMustacheIdentifierExpression *expression = [GRMustacheIdentifierExpression expressionWithIdentifier:@"name"];
    STAssertEqualObjects(expression, [tokenRecorder tokenExpressionValueAtIndex:0], nil);
}

- (void)testParserParsesSectionClosingTokenWithCompoundKey
{
    NSString *templateString = @"{{/foo.bar}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypeClosing, [tokenRecorder tokenTypeAtIndex:0], nil);
    GRMustacheScopedExpression *expression = [GRMustacheScopedExpression expressionWithBaseExpression:[GRMustacheIdentifierExpression expressionWithIdentifier:@"foo"] scopeIdentifier:@"bar"];
    STAssertEqualObjects(expression, [tokenRecorder tokenExpressionValueAtIndex:0], nil);
}

- (void)testParserTrimsSectionClosingTokenWithSingleKey
{
    NSString *templateString = @"{{/ \n\tname \n\t}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypeClosing, [tokenRecorder tokenTypeAtIndex:0], nil);
    GRMustacheIdentifierExpression *expression = [GRMustacheIdentifierExpression expressionWithIdentifier:@"name"];
    STAssertEqualObjects(expression, [tokenRecorder tokenExpressionValueAtIndex:0], nil);
}

- (void)testParserTrimsSectionClosingTokenWithCompoundKey
{
    NSString *templateString = @"{{/ \n\tfoo.bar \n\t}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypeClosing, [tokenRecorder tokenTypeAtIndex:0], nil);
    GRMustacheScopedExpression *expression = [GRMustacheScopedExpression expressionWithBaseExpression:[GRMustacheIdentifierExpression expressionWithIdentifier:@"foo"] scopeIdentifier:@"bar"];
    STAssertEqualObjects(expression, [tokenRecorder tokenExpressionValueAtIndex:0], nil);
}

- (void)testParserParsesSectionClosingTokenWithFilter
{
    NSString *templateString = @"{{%FILTERS}}{{/toto.titi(foo.bar)}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)2, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypeClosing, [tokenRecorder tokenTypeAtIndex:1], nil);
    GRMustacheScopedExpression *parameterExpression = [GRMustacheScopedExpression expressionWithBaseExpression:[GRMustacheIdentifierExpression expressionWithIdentifier:@"foo"] scopeIdentifier:@"bar"];
    GRMustacheScopedExpression *filterExpression = [GRMustacheScopedExpression expressionWithBaseExpression:[GRMustacheIdentifierExpression expressionWithIdentifier:@"toto"] scopeIdentifier:@"titi"];
    GRMustacheFilteredExpression *expression = [GRMustacheFilteredExpression expressionWithFilterExpression:filterExpression parameterExpression:parameterExpression];
    STAssertEqualObjects(expression, [tokenRecorder tokenExpressionValueAtIndex:1], nil);
}

- (void)testParserTrimsSectionClosingTokenWithFilter
{
    NSString *templateString = @"{{%FILTERS}}{{/ \n\ttoto.titi \n\t( \n\tfoo.bar \n\t) \n\t}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)2, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypeClosing, [tokenRecorder tokenTypeAtIndex:1], nil);
    GRMustacheScopedExpression *parameterExpression = [GRMustacheScopedExpression expressionWithBaseExpression:[GRMustacheIdentifierExpression expressionWithIdentifier:@"foo"] scopeIdentifier:@"bar"];
    GRMustacheScopedExpression *filterExpression = [GRMustacheScopedExpression expressionWithBaseExpression:[GRMustacheIdentifierExpression expressionWithIdentifier:@"toto"] scopeIdentifier:@"titi"];
    GRMustacheFilteredExpression *expression = [GRMustacheFilteredExpression expressionWithFilterExpression:filterExpression parameterExpression:parameterExpression];
    STAssertEqualObjects(expression, [tokenRecorder tokenExpressionValueAtIndex:1], nil);
}

- (void)testParserParsesPartialTokenWithoutExtension
{
    NSString *templateString = @"{{>name}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypePartial, [tokenRecorder tokenTypeAtIndex:0], nil);
    STAssertEqualObjects(@"name", [tokenRecorder tokenTemplateNameValueAtIndex:0], nil);
}

- (void)testParserParsesPartialTokenWithExtension
{
    NSString *templateString = @"{{>name.html}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypePartial, [tokenRecorder tokenTypeAtIndex:0], nil);
    STAssertEqualObjects(@"name.html", [tokenRecorder tokenTemplateNameValueAtIndex:0], nil);
}

- (void)testParserTrimsPartialToken
{
    NSString *templateString = @"{{> \n\tname \n\t}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypePartial, [tokenRecorder tokenTypeAtIndex:0], nil);
    STAssertEqualObjects(@"name", [tokenRecorder tokenTemplateNameValueAtIndex:0], nil);
}

- (void)testParserParsesSuperTemplateClosingTokenWithoutExtension
{
    NSString *templateString = @"{{/name}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypeClosing, [tokenRecorder tokenTypeAtIndex:0], nil);
    STAssertEqualObjects(@"name", [tokenRecorder tokenTemplateNameValueAtIndex:0], nil);
}

- (void)testParserParsesSuperTemplateClosingTokenWithExtension
{
    NSString *templateString = @"{{/name.html}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypeClosing, [tokenRecorder tokenTypeAtIndex:0], nil);
    STAssertEqualObjects(@"name.html", [tokenRecorder tokenTemplateNameValueAtIndex:0], nil);
}

- (void)testParserTrimsSuperTemplateClosingToken
{
    NSString *templateString = @"{{/ \n\tname \n\t}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypeClosing, [tokenRecorder tokenTypeAtIndex:0], nil);
    STAssertEqualObjects(@"name", [tokenRecorder tokenTemplateNameValueAtIndex:0], nil);
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
    STAssertEqualObjects(@"name", [tokenRecorder tokenPragmaValueAtIndex:0], nil);
}

- (void)testParserTrimsPragmaToken
{
    NSString *templateString = @"{{% \n\tname \n\t}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypePragma, [tokenRecorder tokenTypeAtIndex:0], nil);
    STAssertEqualObjects(@"name", [tokenRecorder tokenPragmaValueAtIndex:0], nil);
}

- (void)testParserParsesTokenSuite
{
    NSString *templateString = @"<{{!comment}}{{escaped_variable}}{{{unescaped_variable_1}}}{{&unescaped_variable_2}}{{#section_opening}}{{^inverted_section_opening}}{{/section_closing}}{{%pragma}}{{=< >=}}>";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)11, tokenRecorder.tokenCount, nil);
    
    STAssertEquals(GRMustacheTokenTypeText, [tokenRecorder tokenTypeAtIndex:0], nil);
    STAssertEqualObjects(@"<", [tokenRecorder tokenTextValueAtIndex:0], nil);
    
    STAssertEquals(GRMustacheTokenTypeComment, [tokenRecorder tokenTypeAtIndex:1], nil);
    STAssertEqualObjects(@"comment", [tokenRecorder tokenTextValueAtIndex:1], nil);
    
    STAssertEquals(GRMustacheTokenTypeEscapedVariable, [tokenRecorder tokenTypeAtIndex:2], nil);
    STAssertEqualObjects([GRMustacheIdentifierExpression expressionWithIdentifier:@"escaped_variable"], [tokenRecorder tokenExpressionValueAtIndex:2], nil);
    
    STAssertEquals(GRMustacheTokenTypeUnescapedVariable, [tokenRecorder tokenTypeAtIndex:3], nil);
    STAssertEqualObjects([GRMustacheIdentifierExpression expressionWithIdentifier:@"unescaped_variable_1"], [tokenRecorder tokenExpressionValueAtIndex:3], nil);
    
    STAssertEquals(GRMustacheTokenTypeUnescapedVariable, [tokenRecorder tokenTypeAtIndex:4], nil);
    STAssertEqualObjects([GRMustacheIdentifierExpression expressionWithIdentifier:@"unescaped_variable_2"], [tokenRecorder tokenExpressionValueAtIndex:4], nil);
    
    STAssertEquals(GRMustacheTokenTypeSectionOpening, [tokenRecorder tokenTypeAtIndex:5], nil);
    STAssertEqualObjects([GRMustacheIdentifierExpression expressionWithIdentifier:@"section_opening"], [tokenRecorder tokenExpressionValueAtIndex:5], nil);
    
    STAssertEquals(GRMustacheTokenTypeInvertedSectionOpening, [tokenRecorder tokenTypeAtIndex:6], nil);
    STAssertEqualObjects([GRMustacheIdentifierExpression expressionWithIdentifier:@"inverted_section_opening"], [tokenRecorder tokenExpressionValueAtIndex:6], nil);
    
    STAssertEquals(GRMustacheTokenTypeClosing, [tokenRecorder tokenTypeAtIndex:7], nil);
    STAssertEqualObjects([GRMustacheIdentifierExpression expressionWithIdentifier:@"section_closing"], [tokenRecorder tokenExpressionValueAtIndex:7], nil);
    
    STAssertEquals(GRMustacheTokenTypePragma, [tokenRecorder tokenTypeAtIndex:8], nil);
    STAssertEqualObjects(@"pragma", [tokenRecorder tokenPragmaValueAtIndex:8], nil);
    
    STAssertEquals(GRMustacheTokenTypeSetDelimiter, [tokenRecorder tokenTypeAtIndex:9], nil);

    STAssertEquals(GRMustacheTokenTypeText, [tokenRecorder tokenTypeAtIndex:10], nil);
    STAssertEqualObjects(@">", [tokenRecorder tokenTextValueAtIndex:10], nil);
}

- (void)testSetDelimiterTokensChain
{
    NSString *templateString = @"<{{= <% %> =}}<% start %><%=| |=%>|# middle || item ||/ middle ||={{ }}=|{{ final }}>";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)10, tokenRecorder.tokenCount, nil);
    
    STAssertEquals(GRMustacheTokenTypeText, [tokenRecorder tokenTypeAtIndex:0], nil);
    STAssertEqualObjects(@"<", [tokenRecorder tokenTextValueAtIndex:0], nil);
    
    STAssertEquals(GRMustacheTokenTypeSetDelimiter, [tokenRecorder tokenTypeAtIndex:1], nil);
    
    STAssertEquals(GRMustacheTokenTypeEscapedVariable, [tokenRecorder tokenTypeAtIndex:2], nil);
    STAssertEqualObjects([GRMustacheIdentifierExpression expressionWithIdentifier:@"start"], [tokenRecorder tokenExpressionValueAtIndex:2], nil);
    
    STAssertEquals(GRMustacheTokenTypeSetDelimiter, [tokenRecorder tokenTypeAtIndex:3], nil);
    
    STAssertEquals(GRMustacheTokenTypeSectionOpening, [tokenRecorder tokenTypeAtIndex:4], nil);
    STAssertEqualObjects([GRMustacheIdentifierExpression expressionWithIdentifier:@"middle"], [tokenRecorder tokenExpressionValueAtIndex:4], nil);
    
    STAssertEquals(GRMustacheTokenTypeEscapedVariable, [tokenRecorder tokenTypeAtIndex:5], nil);
    STAssertEqualObjects([GRMustacheIdentifierExpression expressionWithIdentifier:@"item"], [tokenRecorder tokenExpressionValueAtIndex:5], nil);
    
    STAssertEquals(GRMustacheTokenTypeClosing, [tokenRecorder tokenTypeAtIndex:6], nil);
    STAssertEqualObjects([GRMustacheIdentifierExpression expressionWithIdentifier:@"middle"], [tokenRecorder tokenExpressionValueAtIndex:6], nil);
    
    STAssertEquals(GRMustacheTokenTypeSetDelimiter, [tokenRecorder tokenTypeAtIndex:7], nil);
    
    STAssertEquals(GRMustacheTokenTypeEscapedVariable, [tokenRecorder tokenTypeAtIndex:8], nil);
    STAssertEqualObjects([GRMustacheIdentifierExpression expressionWithIdentifier:@"final"], [tokenRecorder tokenExpressionValueAtIndex:8], nil);
    
    STAssertEquals(GRMustacheTokenTypeText, [tokenRecorder tokenTypeAtIndex:9], nil);
    STAssertEqualObjects(@">", [tokenRecorder tokenTextValueAtIndex:9], nil);
}

- (void)testLotsOfStache
{
    NSString *templateString = @"{{{{foo}}}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNotNil(tokenRecorder.error, nil);
    STAssertEqualObjects(tokenRecorder.error.domain, GRMustacheErrorDomain, nil);
    STAssertEquals(tokenRecorder.error.code, (NSInteger)GRMustacheErrorCodeParseError, nil);
}
@end
