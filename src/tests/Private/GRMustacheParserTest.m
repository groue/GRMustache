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
#import "GRMustacheKeyPathExpression_private.h"
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
    NSMutableArray *_tokenValues;
}
@property (nonatomic, retain, readonly) NSError *error;
@property (readonly) NSUInteger tokenCount;
- (GRMustacheTokenType)tokenTypeAtIndex:(NSUInteger)index;
- (id)tokenValueAtIndex:(NSUInteger)index;
@end

@implementation GRMustacheTokenRecorder
@synthesize error=_error;
@dynamic tokenCount;

- (id)init
{
    self = [super init];
    if (self) {
        _tokenTypes = [[NSMutableArray array] retain];
        _tokenValues = [[NSMutableArray array] retain];
    }
    return self;
}

- (void)dealloc
{
    [_tokenTypes release];
    [_tokenValues release];
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

- (id)tokenValueAtIndex:(NSUInteger)index
{
    return [_tokenValues objectAtIndex:index];
}

- (BOOL)parser:(GRMustacheParser *)parser shouldContinueAfterParsingToken:(GRMustacheToken *)token
{
    [_tokenTypes addObject:[NSNumber numberWithInt:token.type]];
    if (token.value.object) {
        [_tokenValues addObject:token.value.object];
    } else {
        [_tokenValues addObject:[NSNull null]];
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

- (void)testParserParsesSingleTextToken
{
    NSString *templateString = @"text";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypeText, [tokenRecorder tokenTypeAtIndex:0], nil);
    STAssertEqualObjects(@"text", [tokenRecorder tokenValueAtIndex:0], nil);
}

- (void)testParserParsesSingleCommentToken
{
    NSString *templateString = @"{{!comment}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypeComment, [tokenRecorder tokenTypeAtIndex:0], nil);
    STAssertEqualObjects(@"comment", [tokenRecorder tokenValueAtIndex:0], nil);
}

- (void)testParserParsesSingleEscapedVariableTokenWithSingleKey
{
    NSString *templateString = @"{{name}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypeEscapedVariable, [tokenRecorder tokenTypeAtIndex:0], nil);
    GRMustacheKeyPathExpression *expression = [GRMustacheKeyPathExpression expressionWithKeys:[NSArray arrayWithObject:@"name"]];
    STAssertEqualObjects(expression, [tokenRecorder tokenValueAtIndex:0], nil);
}

- (void)testParserParsesSingleEscapedVariableTokenWithCompoundKey
{
    NSString *templateString = @"{{foo.bar}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypeEscapedVariable, [tokenRecorder tokenTypeAtIndex:0], nil);
    GRMustacheKeyPathExpression *expression = [GRMustacheKeyPathExpression expressionWithKeys:[NSArray arrayWithObjects:@"foo", @"bar", nil]];
    STAssertEqualObjects(expression, [tokenRecorder tokenValueAtIndex:0], nil);
}

- (void)testParserTrimsSingleEscapedVariableTokenWithSingleKey
{
    NSString *templateString = @"{{ \n\tname \n\t}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypeEscapedVariable, [tokenRecorder tokenTypeAtIndex:0], nil);
    GRMustacheKeyPathExpression *expression = [GRMustacheKeyPathExpression expressionWithKeys:[NSArray arrayWithObject:@"name"]];
    STAssertEqualObjects(expression, [tokenRecorder tokenValueAtIndex:0], nil);
}

- (void)testParserTrimsSingleEscapedVariableTokenWithCompoundKey
{
    NSString *templateString = @"{{ \n\tfoo.bar \n\t}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypeEscapedVariable, [tokenRecorder tokenTypeAtIndex:0], nil);
    GRMustacheKeyPathExpression *expression = [GRMustacheKeyPathExpression expressionWithKeys:[NSArray arrayWithObjects:@"foo", @"bar", nil]];
    STAssertEqualObjects(expression, [tokenRecorder tokenValueAtIndex:0], nil);
}

- (void)testParserParsesSingleUnescapedVariableTokenWithThreeMustacheWithSingleKey
{
    NSString *templateString = @"{{{name}}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypeUnescapedVariable, [tokenRecorder tokenTypeAtIndex:0], nil);
    GRMustacheKeyPathExpression *expression = [GRMustacheKeyPathExpression expressionWithKeys:[NSArray arrayWithObject:@"name"]];
    STAssertEqualObjects(expression, [tokenRecorder tokenValueAtIndex:0], nil);
}

- (void)testParserParsesSingleUnescapedVariableTokenWithThreeMustacheWithCompoundKey
{
    NSString *templateString = @"{{{foo.bar}}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypeUnescapedVariable, [tokenRecorder tokenTypeAtIndex:0], nil);
    GRMustacheKeyPathExpression *expression = [GRMustacheKeyPathExpression expressionWithKeys:[NSArray arrayWithObjects:@"foo", @"bar", nil]];
    STAssertEqualObjects(expression, [tokenRecorder tokenValueAtIndex:0], nil);
}

- (void)testParserTrimsSingleUnescapedVariableTokenWithThreeMustacheWithSingleKey
{
    NSString *templateString = @"{{{ \n\tname \n\t}}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypeUnescapedVariable, [tokenRecorder tokenTypeAtIndex:0], nil);
    GRMustacheKeyPathExpression *expression = [GRMustacheKeyPathExpression expressionWithKeys:[NSArray arrayWithObject:@"name"]];
    STAssertEqualObjects(expression, [tokenRecorder tokenValueAtIndex:0], nil);
}

- (void)testParserTrimsSingleUnescapedVariableTokenWithThreeMustacheWithCompoundKey
{
    NSString *templateString = @"{{{ \n\tfoo.bar \n\t}}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypeUnescapedVariable, [tokenRecorder tokenTypeAtIndex:0], nil);
    GRMustacheKeyPathExpression *expression = [GRMustacheKeyPathExpression expressionWithKeys:[NSArray arrayWithObjects:@"foo", @"bar", nil]];
    STAssertEqualObjects(expression, [tokenRecorder tokenValueAtIndex:0], nil);
}

- (void)testParserParsesSingleUnescapedVariableTokenWithAmpersandWithSingleKey
{
    NSString *templateString = @"{{&name}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypeUnescapedVariable, [tokenRecorder tokenTypeAtIndex:0], nil);
    GRMustacheKeyPathExpression *expression = [GRMustacheKeyPathExpression expressionWithKeys:[NSArray arrayWithObject:@"name"]];
    STAssertEqualObjects(expression, [tokenRecorder tokenValueAtIndex:0], nil);
}

- (void)testParserParsesSingleUnescapedVariableTokenWithAmpersandWithCompoundKey
{
    NSString *templateString = @"{{&foo.bar}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypeUnescapedVariable, [tokenRecorder tokenTypeAtIndex:0], nil);
    GRMustacheKeyPathExpression *expression = [GRMustacheKeyPathExpression expressionWithKeys:[NSArray arrayWithObjects:@"foo", @"bar", nil]];
    STAssertEqualObjects(expression, [tokenRecorder tokenValueAtIndex:0], nil);
}

- (void)testParserTrimsSingleUnescapedVariableTokenWithAmpersandWithSingleKey
{
    NSString *templateString = @"{{& \n\tname \n\t}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypeUnescapedVariable, [tokenRecorder tokenTypeAtIndex:0], nil);
    GRMustacheKeyPathExpression *expression = [GRMustacheKeyPathExpression expressionWithKeys:[NSArray arrayWithObject:@"name"]];
    STAssertEqualObjects(expression, [tokenRecorder tokenValueAtIndex:0], nil);
}

- (void)testParserTrimsSingleUnescapedVariableTokenWithAmpersandWithCompoundKey
{
    NSString *templateString = @"{{& \n\tfoo.bar \n\t}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypeUnescapedVariable, [tokenRecorder tokenTypeAtIndex:0], nil);
    GRMustacheKeyPathExpression *expression = [GRMustacheKeyPathExpression expressionWithKeys:[NSArray arrayWithObjects:@"foo", @"bar", nil]];
    STAssertEqualObjects(expression, [tokenRecorder tokenValueAtIndex:0], nil);
}

- (void)testParserParsesSingleSectionOpeningTokenWithSingleKey
{
    NSString *templateString = @"{{#name}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypeSectionOpening, [tokenRecorder tokenTypeAtIndex:0], nil);
    GRMustacheKeyPathExpression *expression = [GRMustacheKeyPathExpression expressionWithKeys:[NSArray arrayWithObject:@"name"]];
    STAssertEqualObjects(expression, [tokenRecorder tokenValueAtIndex:0], nil);
}

- (void)testParserParsesSingleSectionOpeningTokenWithCompoundKey
{
    NSString *templateString = @"{{#foo.bar}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypeSectionOpening, [tokenRecorder tokenTypeAtIndex:0], nil);
    GRMustacheKeyPathExpression *expression = [GRMustacheKeyPathExpression expressionWithKeys:[NSArray arrayWithObjects:@"foo", @"bar", nil]];
    STAssertEqualObjects(expression, [tokenRecorder tokenValueAtIndex:0], nil);
}

- (void)testParserTrimsSingleSectionOpeningTokenWithSingleKey
{
    NSString *templateString = @"{{# \n\tname \n\t}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypeSectionOpening, [tokenRecorder tokenTypeAtIndex:0], nil);
    GRMustacheKeyPathExpression *expression = [GRMustacheKeyPathExpression expressionWithKeys:[NSArray arrayWithObject:@"name"]];
    STAssertEqualObjects(expression, [tokenRecorder tokenValueAtIndex:0], nil);
}

- (void)testParserTrimsSingleSectionOpeningTokenWithCompoundKey
{
    NSString *templateString = @"{{# \n\tfoo.bar \n\t}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypeSectionOpening, [tokenRecorder tokenTypeAtIndex:0], nil);
    GRMustacheKeyPathExpression *expression = [GRMustacheKeyPathExpression expressionWithKeys:[NSArray arrayWithObjects:@"foo", @"bar", nil]];
    STAssertEqualObjects(expression, [tokenRecorder tokenValueAtIndex:0], nil);
}

- (void)testParserParsesSingleInvertedSectionOpeningTokenWithSingleKey
{
    NSString *templateString = @"{{^name}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypeInvertedSectionOpening, [tokenRecorder tokenTypeAtIndex:0], nil);
    GRMustacheKeyPathExpression *expression = [GRMustacheKeyPathExpression expressionWithKeys:[NSArray arrayWithObject:@"name"]];
    STAssertEqualObjects(expression, [tokenRecorder tokenValueAtIndex:0], nil);
}

- (void)testParserParsesSingleInvertedSectionOpeningTokenWithCompoundKey
{
    NSString *templateString = @"{{^foo.bar}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypeInvertedSectionOpening, [tokenRecorder tokenTypeAtIndex:0], nil);
    GRMustacheKeyPathExpression *expression = [GRMustacheKeyPathExpression expressionWithKeys:[NSArray arrayWithObjects:@"foo", @"bar", nil]];
    STAssertEqualObjects(expression, [tokenRecorder tokenValueAtIndex:0], nil);
}

- (void)testParserTrimsSingleInvertedSectionOpeningTokenWithSingleKey
{
    NSString *templateString = @"{{^ \n\tname \n\t}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypeInvertedSectionOpening, [tokenRecorder tokenTypeAtIndex:0], nil);
    GRMustacheKeyPathExpression *expression = [GRMustacheKeyPathExpression expressionWithKeys:[NSArray arrayWithObject:@"name"]];
    STAssertEqualObjects(expression, [tokenRecorder tokenValueAtIndex:0], nil);
}

- (void)testParserTrimsSingleInvertedSectionOpeningTokenWithCompoundKey
{
    NSString *templateString = @"{{^ \n\tfoo.bar \n\t}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypeInvertedSectionOpening, [tokenRecorder tokenTypeAtIndex:0], nil);
    GRMustacheKeyPathExpression *expression = [GRMustacheKeyPathExpression expressionWithKeys:[NSArray arrayWithObjects:@"foo", @"bar", nil]];
    STAssertEqualObjects(expression, [tokenRecorder tokenValueAtIndex:0], nil);
}

- (void)testParserParsesSingleSectionClosingTokenWithSingleKey
{
    NSString *templateString = @"{{/name}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypeSectionClosing, [tokenRecorder tokenTypeAtIndex:0], nil);
    GRMustacheKeyPathExpression *expression = [GRMustacheKeyPathExpression expressionWithKeys:[NSArray arrayWithObject:@"name"]];
    STAssertEqualObjects(expression, [tokenRecorder tokenValueAtIndex:0], nil);
}

- (void)testParserParsesSingleSectionClosingTokenWithCompoundKey
{
    NSString *templateString = @"{{/foo.bar}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypeSectionClosing, [tokenRecorder tokenTypeAtIndex:0], nil);
    GRMustacheKeyPathExpression *expression = [GRMustacheKeyPathExpression expressionWithKeys:[NSArray arrayWithObjects:@"foo", @"bar", nil]];
    STAssertEqualObjects(expression, [tokenRecorder tokenValueAtIndex:0], nil);
}

- (void)testParserTrimsSingleSectionClosingTokenWithSingleKey
{
    NSString *templateString = @"{{/ \n\tname \n\t}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypeSectionClosing, [tokenRecorder tokenTypeAtIndex:0], nil);
    GRMustacheKeyPathExpression *expression = [GRMustacheKeyPathExpression expressionWithKeys:[NSArray arrayWithObject:@"name"]];
    STAssertEqualObjects(expression, [tokenRecorder tokenValueAtIndex:0], nil);
}

- (void)testParserTrimsSingleSectionClosingTokenWithCompoundKey
{
    NSString *templateString = @"{{/ \n\tfoo.bar \n\t}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypeSectionClosing, [tokenRecorder tokenTypeAtIndex:0], nil);
    GRMustacheKeyPathExpression *expression = [GRMustacheKeyPathExpression expressionWithKeys:[NSArray arrayWithObjects:@"foo", @"bar", nil]];
    STAssertEqualObjects(expression, [tokenRecorder tokenValueAtIndex:0], nil);
}

- (void)testParserParsesSinglePartialTokenWithoutExtension
{
    NSString *templateString = @"{{>name}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypePartial, [tokenRecorder tokenTypeAtIndex:0], nil);
    STAssertEqualObjects(@"name", [tokenRecorder tokenValueAtIndex:0], nil);
}

- (void)testParserParsesSinglePartialTokenWithExtension
{
    NSString *templateString = @"{{>name.html}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypePartial, [tokenRecorder tokenTypeAtIndex:0], nil);
    STAssertEqualObjects(@"name.html", [tokenRecorder tokenValueAtIndex:0], nil);
}

- (void)testParserTrimsSinglePartialToken
{
    NSString *templateString = @"{{> \n\tname \n\t}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypePartial, [tokenRecorder tokenTypeAtIndex:0], nil);
    STAssertEqualObjects(@"name", [tokenRecorder tokenValueAtIndex:0], nil);
}

- (void)testParserParsesSingleSetDelimiterToken
{
    NSString *templateString = @"{{=< >=}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypeSetDelimiter, [tokenRecorder tokenTypeAtIndex:0], nil);
}

- (void)testParserParsesSinglePragmaToken
{
    NSString *templateString = @"{{%name}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypePragma, [tokenRecorder tokenTypeAtIndex:0], nil);
    STAssertEqualObjects(@"name", [tokenRecorder tokenValueAtIndex:0], nil);
}

- (void)testParserTrimsSinglePragmaToken
{
    NSString *templateString = @"{{% \n\tname \n\t}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypePragma, [tokenRecorder tokenTypeAtIndex:0], nil);
    STAssertEqualObjects(@"name", [tokenRecorder tokenValueAtIndex:0], nil);
}

- (void)testParserParsesTokenSuite
{
    NSString *templateString = @"<{{!comment}}{{escaped_variable}}{{{unescaped_variable_1}}}{{&unescaped_variable_2}}{{#section_opening}}{{^inverted_section_opening}}{{/section_closing}}{{%pragma}}{{=< >=}}>";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)11, tokenRecorder.tokenCount, nil);
    
    STAssertEquals(GRMustacheTokenTypeText, [tokenRecorder tokenTypeAtIndex:0], nil);
    STAssertEqualObjects(@"<", [tokenRecorder tokenValueAtIndex:0], nil);
    
    STAssertEquals(GRMustacheTokenTypeComment, [tokenRecorder tokenTypeAtIndex:1], nil);
    STAssertEqualObjects(@"comment", [tokenRecorder tokenValueAtIndex:1], nil);
    
    STAssertEquals(GRMustacheTokenTypeEscapedVariable, [tokenRecorder tokenTypeAtIndex:2], nil);
    STAssertEqualObjects([GRMustacheKeyPathExpression expressionWithKeys:[NSArray arrayWithObject:@"escaped_variable"]], [tokenRecorder tokenValueAtIndex:2], nil);
    
    STAssertEquals(GRMustacheTokenTypeUnescapedVariable, [tokenRecorder tokenTypeAtIndex:3], nil);
    STAssertEqualObjects([GRMustacheKeyPathExpression expressionWithKeys:[NSArray arrayWithObject:@"unescaped_variable_1"]], [tokenRecorder tokenValueAtIndex:3], nil);
    
    STAssertEquals(GRMustacheTokenTypeUnescapedVariable, [tokenRecorder tokenTypeAtIndex:4], nil);
    STAssertEqualObjects([GRMustacheKeyPathExpression expressionWithKeys:[NSArray arrayWithObject:@"unescaped_variable_2"]], [tokenRecorder tokenValueAtIndex:4], nil);
    
    STAssertEquals(GRMustacheTokenTypeSectionOpening, [tokenRecorder tokenTypeAtIndex:5], nil);
    STAssertEqualObjects([GRMustacheKeyPathExpression expressionWithKeys:[NSArray arrayWithObject:@"section_opening"]], [tokenRecorder tokenValueAtIndex:5], nil);
    
    STAssertEquals(GRMustacheTokenTypeInvertedSectionOpening, [tokenRecorder tokenTypeAtIndex:6], nil);
    STAssertEqualObjects([GRMustacheKeyPathExpression expressionWithKeys:[NSArray arrayWithObject:@"inverted_section_opening"]], [tokenRecorder tokenValueAtIndex:6], nil);
    
    STAssertEquals(GRMustacheTokenTypeSectionClosing, [tokenRecorder tokenTypeAtIndex:7], nil);
    STAssertEqualObjects([GRMustacheKeyPathExpression expressionWithKeys:[NSArray arrayWithObject:@"section_closing"]], [tokenRecorder tokenValueAtIndex:7], nil);
    
    STAssertEquals(GRMustacheTokenTypePragma, [tokenRecorder tokenTypeAtIndex:8], nil);
    STAssertEqualObjects(@"pragma", [tokenRecorder tokenValueAtIndex:8], nil);
    
    STAssertEquals(GRMustacheTokenTypeSetDelimiter, [tokenRecorder tokenTypeAtIndex:9], nil);

    STAssertEquals(GRMustacheTokenTypeText, [tokenRecorder tokenTypeAtIndex:10], nil);
    STAssertEqualObjects(@">", [tokenRecorder tokenValueAtIndex:10], nil);
}

- (void)testSetDelimiterTokensChain
{
    NSString *templateString = @"<{{= <% %> =}}<% start %><%=| |=%>|# middle || item ||/ middle ||={{ }}=|{{ final }}>";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)10, tokenRecorder.tokenCount, nil);
    
    STAssertEquals(GRMustacheTokenTypeText, [tokenRecorder tokenTypeAtIndex:0], nil);
    STAssertEqualObjects(@"<", [tokenRecorder tokenValueAtIndex:0], nil);
    
    STAssertEquals(GRMustacheTokenTypeSetDelimiter, [tokenRecorder tokenTypeAtIndex:1], nil);
    
    STAssertEquals(GRMustacheTokenTypeEscapedVariable, [tokenRecorder tokenTypeAtIndex:2], nil);
    STAssertEqualObjects([GRMustacheKeyPathExpression expressionWithKeys:[NSArray arrayWithObject:@"start"]], [tokenRecorder tokenValueAtIndex:2], nil);
    
    STAssertEquals(GRMustacheTokenTypeSetDelimiter, [tokenRecorder tokenTypeAtIndex:3], nil);
    
    STAssertEquals(GRMustacheTokenTypeSectionOpening, [tokenRecorder tokenTypeAtIndex:4], nil);
    STAssertEqualObjects([GRMustacheKeyPathExpression expressionWithKeys:[NSArray arrayWithObject:@"middle"]], [tokenRecorder tokenValueAtIndex:4], nil);
    
    STAssertEquals(GRMustacheTokenTypeEscapedVariable, [tokenRecorder tokenTypeAtIndex:5], nil);
    STAssertEqualObjects([GRMustacheKeyPathExpression expressionWithKeys:[NSArray arrayWithObject:@"item"]], [tokenRecorder tokenValueAtIndex:5], nil);
    
    STAssertEquals(GRMustacheTokenTypeSectionClosing, [tokenRecorder tokenTypeAtIndex:6], nil);
    STAssertEqualObjects([GRMustacheKeyPathExpression expressionWithKeys:[NSArray arrayWithObject:@"middle"]], [tokenRecorder tokenValueAtIndex:6], nil);
    
    STAssertEquals(GRMustacheTokenTypeSetDelimiter, [tokenRecorder tokenTypeAtIndex:7], nil);
    
    STAssertEquals(GRMustacheTokenTypeEscapedVariable, [tokenRecorder tokenTypeAtIndex:8], nil);
    STAssertEqualObjects([GRMustacheKeyPathExpression expressionWithKeys:[NSArray arrayWithObject:@"final"]], [tokenRecorder tokenValueAtIndex:8], nil);
    
    STAssertEquals(GRMustacheTokenTypeText, [tokenRecorder tokenTypeAtIndex:9], nil);
    STAssertEqualObjects(@">", [tokenRecorder tokenValueAtIndex:9], nil);
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
