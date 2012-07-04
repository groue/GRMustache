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

#import "GRMustacheParserTest.h"
#import "GRMustacheError.h"


@interface GRMustacheTokenRecorder : NSObject<GRMustacheParserDelegate> {
    NSError *_error;
    NSMutableArray *_tokenTypes;
    NSMutableArray *_tokenContents;
}
@property (nonatomic, retain, readonly) NSError *error;
@property (readonly) NSUInteger tokenCount;
- (GRMustacheTokenType)tokenTypeAtIndex:(NSUInteger)index;
- (NSString *)tokenContentAtIndex:(NSUInteger)index;
@end

@implementation GRMustacheTokenRecorder
@synthesize error=_error;
@dynamic tokenCount;

- (id)init
{
    self = [super init];
    if (self) {
        _tokenTypes = [[NSMutableArray array] retain];
        _tokenContents = [[NSMutableArray array] retain];
    }
    return self;
}

- (void)dealloc
{
    [_tokenTypes release];
    [_tokenContents release];
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

- (NSString *)tokenContentAtIndex:(NSUInteger)index
{
    return [_tokenContents objectAtIndex:index];
}

- (BOOL)parser:(GRMustacheParser *)parser shouldContinueAfterParsingToken:(GRMustacheToken *)token
{
    [_tokenTypes addObject:[NSNumber numberWithInt:token.type]];
    [_tokenContents addObject:token.content];
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
    STAssertEqualObjects(@"text", [tokenRecorder tokenContentAtIndex:0], nil);
}

- (void)testParserParsesSingleCommentToken
{
    NSString *templateString = @"{{!comment}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypeComment, [tokenRecorder tokenTypeAtIndex:0], nil);
    STAssertEqualObjects(@"comment", [tokenRecorder tokenContentAtIndex:0], nil);
}

- (void)testParserParsesSingleEscapedVariableToken
{
    NSString *templateString = @"{{name}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypeEscapedVariable, [tokenRecorder tokenTypeAtIndex:0], nil);
    STAssertEqualObjects(@"name", [tokenRecorder tokenContentAtIndex:0], nil);
}

- (void)testParserTrimsSingleEscapedVariableToken
{
    NSString *templateString = @"{{ \n\tname \n\t}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypeEscapedVariable, [tokenRecorder tokenTypeAtIndex:0], nil);
    STAssertEqualObjects(@"name", [tokenRecorder tokenContentAtIndex:0], nil);
}

- (void)testParserParsesSingleUnescapedVariableTokenWithThreeMustache
{
    NSString *templateString = @"{{{name}}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypeUnescapedVariable, [tokenRecorder tokenTypeAtIndex:0], nil);
    STAssertEqualObjects(@"name", [tokenRecorder tokenContentAtIndex:0], nil);
}

- (void)testParserTrimsSingleUnescapedVariableTokenWithThreeMustache
{
    NSString *templateString = @"{{{ \n\tname \n\t}}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypeUnescapedVariable, [tokenRecorder tokenTypeAtIndex:0], nil);
    STAssertEqualObjects(@"name", [tokenRecorder tokenContentAtIndex:0], nil);
}

- (void)testParserParsesSingleUnescapedVariableTokenWithAmpersand
{
    NSString *templateString = @"{{&name}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypeUnescapedVariable, [tokenRecorder tokenTypeAtIndex:0], nil);
    STAssertEqualObjects(@"name", [tokenRecorder tokenContentAtIndex:0], nil);
}

- (void)testParserTrimsSingleUnescapedVariableTokenWithAmpersand
{
    NSString *templateString = @"{{& \n\tname \n\t}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypeUnescapedVariable, [tokenRecorder tokenTypeAtIndex:0], nil);
    STAssertEqualObjects(@"name", [tokenRecorder tokenContentAtIndex:0], nil);
}

- (void)testParserParsesSingleSectionOpeningToken
{
    NSString *templateString = @"{{#name}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypeSectionOpening, [tokenRecorder tokenTypeAtIndex:0], nil);
    STAssertEqualObjects(@"name", [tokenRecorder tokenContentAtIndex:0], nil);
}

- (void)testParserTrimsSingleSectionOpeningToken
{
    NSString *templateString = @"{{# \n\tname \n\t}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypeSectionOpening, [tokenRecorder tokenTypeAtIndex:0], nil);
    STAssertEqualObjects(@"name", [tokenRecorder tokenContentAtIndex:0], nil);
}

- (void)testParserParsesSingleInvertedSectionOpeningToken
{
    NSString *templateString = @"{{^name}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypeInvertedSectionOpening, [tokenRecorder tokenTypeAtIndex:0], nil);
    STAssertEqualObjects(@"name", [tokenRecorder tokenContentAtIndex:0], nil);
}

- (void)testParserTrimsSingleInvertedSectionOpeningToken
{
    NSString *templateString = @"{{^ \n\tname \n\t}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypeInvertedSectionOpening, [tokenRecorder tokenTypeAtIndex:0], nil);
    STAssertEqualObjects(@"name", [tokenRecorder tokenContentAtIndex:0], nil);
}

- (void)testParserParsesSingleSectionClosingToken
{
    NSString *templateString = @"{{/name}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypeSectionClosing, [tokenRecorder tokenTypeAtIndex:0], nil);
    STAssertEqualObjects(@"name", [tokenRecorder tokenContentAtIndex:0], nil);
}

- (void)testParserTrimsSingleSectionClosingToken
{
    NSString *templateString = @"{{/ \n\tname \n\t}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypeSectionClosing, [tokenRecorder tokenTypeAtIndex:0], nil);
    STAssertEqualObjects(@"name", [tokenRecorder tokenContentAtIndex:0], nil);
}

- (void)testParserParsesSinglePartialToken
{
    NSString *templateString = @"{{>name}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypePartial, [tokenRecorder tokenTypeAtIndex:0], nil);
    STAssertEqualObjects(@"name", [tokenRecorder tokenContentAtIndex:0], nil);
}

- (void)testParserTrimsSinglePartialToken
{
    NSString *templateString = @"{{> \n\tname \n\t}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypePartial, [tokenRecorder tokenTypeAtIndex:0], nil);
    STAssertEqualObjects(@"name", [tokenRecorder tokenContentAtIndex:0], nil);
}

- (void)testParserParsesSingleSetDelimiterToken
{
    NSString *templateString = @"{{=< >=}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypeSetDelimiter, [tokenRecorder tokenTypeAtIndex:0], nil);
    STAssertEqualObjects(@"< >", [tokenRecorder tokenContentAtIndex:0], nil);
}

- (void)testParserTrimsSingleSetDelimiterToken
{
    NSString *templateString = @"{{= \n\t< > \n\t=}}";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypeSetDelimiter, [tokenRecorder tokenTypeAtIndex:0], nil);
    STAssertEqualObjects(@"< >", [tokenRecorder tokenContentAtIndex:0], nil);
}

- (void)testParserParsesTokenSuite
{
    NSString *templateString = @"<{{!comment}}{{escaped_variable}}{{{unescaped_variable_1}}}{{&unescaped_variable_2}}{{#section_opening}}{{^inverted_section_opening}}{{/section_closing}}{{=< >=}}>";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)10, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypeText, [tokenRecorder tokenTypeAtIndex:0], nil);
    STAssertEqualObjects(@"<", [tokenRecorder tokenContentAtIndex:0], nil);
    STAssertEquals(GRMustacheTokenTypeComment, [tokenRecorder tokenTypeAtIndex:1], nil);
    STAssertEqualObjects(@"comment", [tokenRecorder tokenContentAtIndex:1], nil);
    STAssertEquals(GRMustacheTokenTypeEscapedVariable, [tokenRecorder tokenTypeAtIndex:2], nil);
    STAssertEqualObjects(@"escaped_variable", [tokenRecorder tokenContentAtIndex:2], nil);
    STAssertEquals(GRMustacheTokenTypeUnescapedVariable, [tokenRecorder tokenTypeAtIndex:3], nil);
    STAssertEqualObjects(@"unescaped_variable_1", [tokenRecorder tokenContentAtIndex:3], nil);
    STAssertEquals(GRMustacheTokenTypeUnescapedVariable, [tokenRecorder tokenTypeAtIndex:4], nil);
    STAssertEqualObjects(@"unescaped_variable_2", [tokenRecorder tokenContentAtIndex:4], nil);
    STAssertEquals(GRMustacheTokenTypeSectionOpening, [tokenRecorder tokenTypeAtIndex:5], nil);
    STAssertEqualObjects(@"section_opening", [tokenRecorder tokenContentAtIndex:5], nil);
    STAssertEquals(GRMustacheTokenTypeInvertedSectionOpening, [tokenRecorder tokenTypeAtIndex:6], nil);
    STAssertEqualObjects(@"inverted_section_opening", [tokenRecorder tokenContentAtIndex:6], nil);
    STAssertEquals(GRMustacheTokenTypeSectionClosing, [tokenRecorder tokenTypeAtIndex:7], nil);
    STAssertEqualObjects(@"section_closing", [tokenRecorder tokenContentAtIndex:7], nil);
    STAssertEquals(GRMustacheTokenTypeSetDelimiter, [tokenRecorder tokenTypeAtIndex:8], nil);
    STAssertEqualObjects(@"< >", [tokenRecorder tokenContentAtIndex:8], nil);
    STAssertEquals(GRMustacheTokenTypeText, [tokenRecorder tokenTypeAtIndex:9], nil);
    STAssertEqualObjects(@">", [tokenRecorder tokenContentAtIndex:9], nil);
}

- (void)testSetDelimiterTokensChain
{
    NSString *templateString = @"<{{=<% %>=}}<% start %><%=| |=%>|# middle || item ||/ middle ||={{ }}=|{{ final }}>";
    [parser parseTemplateString:templateString templateID:nil];
    STAssertNil(tokenRecorder.error, nil);
    STAssertEquals((NSUInteger)10, tokenRecorder.tokenCount, nil);
    STAssertEquals(GRMustacheTokenTypeText, [tokenRecorder tokenTypeAtIndex:0], nil);
    STAssertEqualObjects(@"<", [tokenRecorder tokenContentAtIndex:0], nil);
    STAssertEquals(GRMustacheTokenTypeSetDelimiter, [tokenRecorder tokenTypeAtIndex:1], nil);
    STAssertEqualObjects(@"<% %>", [tokenRecorder tokenContentAtIndex:1], nil);
    STAssertEquals(GRMustacheTokenTypeEscapedVariable, [tokenRecorder tokenTypeAtIndex:2], nil);
    STAssertEqualObjects(@"start", [tokenRecorder tokenContentAtIndex:2], nil);
    STAssertEquals(GRMustacheTokenTypeSetDelimiter, [tokenRecorder tokenTypeAtIndex:3], nil);
    STAssertEqualObjects(@"| |", [tokenRecorder tokenContentAtIndex:3], nil);
    STAssertEquals(GRMustacheTokenTypeSectionOpening, [tokenRecorder tokenTypeAtIndex:4], nil);
    STAssertEqualObjects(@"middle", [tokenRecorder tokenContentAtIndex:4], nil);
    STAssertEquals(GRMustacheTokenTypeEscapedVariable, [tokenRecorder tokenTypeAtIndex:5], nil);
    STAssertEqualObjects(@"item", [tokenRecorder tokenContentAtIndex:5], nil);
    STAssertEquals(GRMustacheTokenTypeSectionClosing, [tokenRecorder tokenTypeAtIndex:6], nil);
    STAssertEqualObjects(@"middle", [tokenRecorder tokenContentAtIndex:6], nil);
    STAssertEquals(GRMustacheTokenTypeSetDelimiter, [tokenRecorder tokenTypeAtIndex:7], nil);
    STAssertEqualObjects(@"{{ }}", [tokenRecorder tokenContentAtIndex:7], nil);
    STAssertEquals(GRMustacheTokenTypeEscapedVariable, [tokenRecorder tokenTypeAtIndex:8], nil);
    STAssertEqualObjects(@"final", [tokenRecorder tokenContentAtIndex:8], nil);
    STAssertEquals(GRMustacheTokenTypeText, [tokenRecorder tokenTypeAtIndex:9], nil);
    STAssertEqualObjects(@">", [tokenRecorder tokenContentAtIndex:9], nil);
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
