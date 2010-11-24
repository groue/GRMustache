// The MIT License
// 
// Copyright (c) 2010 Gwendal Roué
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

#import "GRMustacheTokenizerTest.h"


@interface GRMustacheTokenRecorder : NSObject<GRMustacheTokenizerDelegate> {
	NSError *error;
	BOOL tokenizerDidFinish;
	NSMutableArray *tokenTypes;
	NSMutableArray *tokenContents;
}
@property (nonatomic, retain, readonly) NSError *error;
@property (readonly) BOOL tokenizerDidFinish;
@property (readonly) NSUInteger tokenCount;
- (GRMustacheTokenType)tokenTypeAtIndex:(NSUInteger)index;
- (NSString *)tokenContentAtIndex:(NSUInteger)index;
@end

@implementation GRMustacheTokenRecorder
@synthesize error;
@synthesize tokenizerDidFinish;
@dynamic tokenCount;

- (id)init {
	if ((self = [super init])) {
		tokenTypes = [[NSMutableArray array] retain];
		tokenContents = [[NSMutableArray array] retain];
	}
	return self;
}

- (void)dealloc {
	[tokenTypes release];
	[tokenContents release];
	[error release];
	[super dealloc];
}

- (NSUInteger)tokenCount {
	return tokenTypes.count;
}

- (GRMustacheTokenType)tokenTypeAtIndex:(NSUInteger)index {
	return [(NSNumber *)[tokenTypes objectAtIndex:index] intValue];
}

- (NSString *)tokenContentAtIndex:(NSUInteger)index {
	return [tokenContents objectAtIndex:index];
}

- (BOOL)tokenizer:(GRMustacheTokenizer *)tokenizer shouldContinueAfterParsingToken:(GRMustacheToken *)token {
	[tokenTypes addObject:[NSNumber numberWithInt:token.type]];
	[tokenContents addObject:token.content];
	return YES;
}

- (void)tokenizerDidFinish:(GRMustacheTokenizer *)tokenizer withError:(NSError *)theError {
	tokenizerDidFinish = YES;
	error = [theError retain];
}
@end



@implementation GRMustacheTokenizerTest

- (void)setUp {
	tokenRecorder = [[GRMustacheTokenRecorder alloc] init];
	tokenizer = [[GRMustacheTokenizer alloc] init];
	tokenizer.delegate = tokenRecorder;
}

- (void)tearDown {
	[tokenizer release];
	[tokenRecorder release];
}

- (void)testTokenizerParsesSingleTextToken {
	NSString *templateString = @"text";
	[tokenizer parseTemplateString:templateString];
	STAssertTrue(tokenRecorder.tokenizerDidFinish, nil);
	STAssertNil(tokenRecorder.error, nil);
	STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
	STAssertEquals(GRMustacheTokenTypeText, [tokenRecorder tokenTypeAtIndex:0], nil);
	STAssertEqualObjects(@"text", [tokenRecorder tokenContentAtIndex:0], nil);
}

- (void)testTokenizerParsesSingleCommentToken {
	NSString *templateString = @"{{!comment}}";
	[tokenizer parseTemplateString:templateString];
	STAssertTrue(tokenRecorder.tokenizerDidFinish, nil);
	STAssertNil(tokenRecorder.error, nil);
	STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
	STAssertEquals(GRMustacheTokenTypeComment, [tokenRecorder tokenTypeAtIndex:0], nil);
	STAssertEqualObjects(@"comment", [tokenRecorder tokenContentAtIndex:0], nil);
}

- (void)testTokenizerParsesSingleEscapedVariableToken {
	NSString *templateString = @"{{name}}";
	[tokenizer parseTemplateString:templateString];
	STAssertTrue(tokenRecorder.tokenizerDidFinish, nil);
	STAssertNil(tokenRecorder.error, nil);
	STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
	STAssertEquals(GRMustacheTokenTypeEscapedVariable, [tokenRecorder tokenTypeAtIndex:0], nil);
	STAssertEqualObjects(@"name", [tokenRecorder tokenContentAtIndex:0], nil);
}

- (void)testTokenizerTrimsSingleEscapedVariableToken {
	NSString *templateString = @"{{ \n\tname \n\t}}";
	[tokenizer parseTemplateString:templateString];
	STAssertTrue(tokenRecorder.tokenizerDidFinish, nil);
	STAssertNil(tokenRecorder.error, nil);
	STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
	STAssertEquals(GRMustacheTokenTypeEscapedVariable, [tokenRecorder tokenTypeAtIndex:0], nil);
	STAssertEqualObjects(@"name", [tokenRecorder tokenContentAtIndex:0], nil);
}

- (void)testTokenizerParsesSingleUnescapedVariableTokenWithThreeMustache {
	NSString *templateString = @"{{{name}}}";
	[tokenizer parseTemplateString:templateString];
	STAssertTrue(tokenRecorder.tokenizerDidFinish, nil);
	STAssertNil(tokenRecorder.error, nil);
	STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
	STAssertEquals(GRMustacheTokenTypeUnescapedVariable, [tokenRecorder tokenTypeAtIndex:0], nil);
	STAssertEqualObjects(@"name", [tokenRecorder tokenContentAtIndex:0], nil);
}

- (void)testTokenizerTrimsSingleUnescapedVariableTokenWithThreeMustache {
	NSString *templateString = @"{{{ \n\tname \n\t}}}";
	[tokenizer parseTemplateString:templateString];
	STAssertTrue(tokenRecorder.tokenizerDidFinish, nil);
	STAssertNil(tokenRecorder.error, nil);
	STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
	STAssertEquals(GRMustacheTokenTypeUnescapedVariable, [tokenRecorder tokenTypeAtIndex:0], nil);
	STAssertEqualObjects(@"name", [tokenRecorder tokenContentAtIndex:0], nil);
}

- (void)testTokenizerParsesSingleUnescapedVariableTokenWithAmpersand {
	NSString *templateString = @"{{&name}}";
	[tokenizer parseTemplateString:templateString];
	STAssertTrue(tokenRecorder.tokenizerDidFinish, nil);
	STAssertNil(tokenRecorder.error, nil);
	STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
	STAssertEquals(GRMustacheTokenTypeUnescapedVariable, [tokenRecorder tokenTypeAtIndex:0], nil);
	STAssertEqualObjects(@"name", [tokenRecorder tokenContentAtIndex:0], nil);
}

- (void)testTokenizerTrimsSingleUnescapedVariableTokenWithAmpersand {
	NSString *templateString = @"{{& \n\tname \n\t}}";
	[tokenizer parseTemplateString:templateString];
	STAssertTrue(tokenRecorder.tokenizerDidFinish, nil);
	STAssertNil(tokenRecorder.error, nil);
	STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
	STAssertEquals(GRMustacheTokenTypeUnescapedVariable, [tokenRecorder tokenTypeAtIndex:0], nil);
	STAssertEqualObjects(@"name", [tokenRecorder tokenContentAtIndex:0], nil);
}

- (void)testTokenizerParsesSingleSectionOpeningToken {
	NSString *templateString = @"{{#name}}";
	[tokenizer parseTemplateString:templateString];
	STAssertTrue(tokenRecorder.tokenizerDidFinish, nil);
	STAssertNil(tokenRecorder.error, nil);
	STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
	STAssertEquals(GRMustacheTokenTypeSectionOpening, [tokenRecorder tokenTypeAtIndex:0], nil);
	STAssertEqualObjects(@"name", [tokenRecorder tokenContentAtIndex:0], nil);
}

- (void)testTokenizerTrimsSingleSectionOpeningToken {
	NSString *templateString = @"{{# \n\tname \n\t}}";
	[tokenizer parseTemplateString:templateString];
	STAssertTrue(tokenRecorder.tokenizerDidFinish, nil);
	STAssertNil(tokenRecorder.error, nil);
	STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
	STAssertEquals(GRMustacheTokenTypeSectionOpening, [tokenRecorder tokenTypeAtIndex:0], nil);
	STAssertEqualObjects(@"name", [tokenRecorder tokenContentAtIndex:0], nil);
}

- (void)testTokenizerParsesSingleInvertedSectionOpeningToken {
	NSString *templateString = @"{{^name}}";
	[tokenizer parseTemplateString:templateString];
	STAssertTrue(tokenRecorder.tokenizerDidFinish, nil);
	STAssertNil(tokenRecorder.error, nil);
	STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
	STAssertEquals(GRMustacheTokenTypeInvertedSectionOpening, [tokenRecorder tokenTypeAtIndex:0], nil);
	STAssertEqualObjects(@"name", [tokenRecorder tokenContentAtIndex:0], nil);
}

- (void)testTokenizerTrimsSingleInvertedSectionOpeningToken {
	NSString *templateString = @"{{^ \n\tname \n\t}}";
	[tokenizer parseTemplateString:templateString];
	STAssertTrue(tokenRecorder.tokenizerDidFinish, nil);
	STAssertNil(tokenRecorder.error, nil);
	STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
	STAssertEquals(GRMustacheTokenTypeInvertedSectionOpening, [tokenRecorder tokenTypeAtIndex:0], nil);
	STAssertEqualObjects(@"name", [tokenRecorder tokenContentAtIndex:0], nil);
}

- (void)testTokenizerParsesSingleSectionClosingToken {
	NSString *templateString = @"{{/name}}";
	[tokenizer parseTemplateString:templateString];
	STAssertTrue(tokenRecorder.tokenizerDidFinish, nil);
	STAssertNil(tokenRecorder.error, nil);
	STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
	STAssertEquals(GRMustacheTokenTypeSectionClosing, [tokenRecorder tokenTypeAtIndex:0], nil);
	STAssertEqualObjects(@"name", [tokenRecorder tokenContentAtIndex:0], nil);
}

- (void)testTokenizerTrimsSingleSectionClosingToken {
	NSString *templateString = @"{{/ \n\tname \n\t}}";
	[tokenizer parseTemplateString:templateString];
	STAssertTrue(tokenRecorder.tokenizerDidFinish, nil);
	STAssertNil(tokenRecorder.error, nil);
	STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
	STAssertEquals(GRMustacheTokenTypeSectionClosing, [tokenRecorder tokenTypeAtIndex:0], nil);
	STAssertEqualObjects(@"name", [tokenRecorder tokenContentAtIndex:0], nil);
}

- (void)testTokenizerParsesSinglePartialToken {
	NSString *templateString = @"{{>name}}";
	[tokenizer parseTemplateString:templateString];
	STAssertTrue(tokenRecorder.tokenizerDidFinish, nil);
	STAssertNil(tokenRecorder.error, nil);
	STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
	STAssertEquals(GRMustacheTokenTypePartial, [tokenRecorder tokenTypeAtIndex:0], nil);
	STAssertEqualObjects(@"name", [tokenRecorder tokenContentAtIndex:0], nil);
}

- (void)testTokenizerTrimsSinglePartialToken {
	NSString *templateString = @"{{> \n\tname \n\t}}";
	[tokenizer parseTemplateString:templateString];
	STAssertTrue(tokenRecorder.tokenizerDidFinish, nil);
	STAssertNil(tokenRecorder.error, nil);
	STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
	STAssertEquals(GRMustacheTokenTypePartial, [tokenRecorder tokenTypeAtIndex:0], nil);
	STAssertEqualObjects(@"name", [tokenRecorder tokenContentAtIndex:0], nil);
}

- (void)testTokenizerParsesSingleSetDelimiterToken {
	NSString *templateString = @"{{=< >=}}";
	[tokenizer parseTemplateString:templateString];
	STAssertTrue(tokenRecorder.tokenizerDidFinish, nil);
	STAssertNil(tokenRecorder.error, nil);
	STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
	STAssertEquals(GRMustacheTokenTypeSetDelimiter, [tokenRecorder tokenTypeAtIndex:0], nil);
	STAssertEqualObjects(@"< >", [tokenRecorder tokenContentAtIndex:0], nil);
}

- (void)testTokenizerTrimsSingleSetDelimiterToken {
	NSString *templateString = @"{{= \n\t< > \n\t=}}";
	[tokenizer parseTemplateString:templateString];
	STAssertTrue(tokenRecorder.tokenizerDidFinish, nil);
	STAssertNil(tokenRecorder.error, nil);
	STAssertEquals((NSUInteger)1, tokenRecorder.tokenCount, nil);
	STAssertEquals(GRMustacheTokenTypeSetDelimiter, [tokenRecorder tokenTypeAtIndex:0], nil);
	STAssertEqualObjects(@"< >", [tokenRecorder tokenContentAtIndex:0], nil);
}

- (void)testTokenizerParsesTokenSuite {
	NSString *templateString = @"<{{!comment}}{{escaped_variable}}{{{unescaped_variable_1}}}{{&unescaped_variable_2}}{{#section_opening}}{{^inverted_section_opening}}{{/section_closing}}{{=< >=}}>";
	[tokenizer parseTemplateString:templateString];
	STAssertTrue(tokenRecorder.tokenizerDidFinish, nil);
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

- (void)testSetDelimiterTokensChain {
	NSString *templateString = @"<{{=<% %>=}}<% start %><%=| |=%>|# middle || item ||/ middle ||={{ }}=|{{ final }}>";
	[tokenizer parseTemplateString:templateString];
	STAssertTrue(tokenRecorder.tokenizerDidFinish, nil);
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

- (void)testLotsOfStache {
	NSString *templateString = @"{{{{foo}}}}";
	[tokenizer parseTemplateString:templateString];
	STAssertTrue(tokenRecorder.tokenizerDidFinish, nil);
	STAssertNotNil(tokenRecorder.error, nil);
	STAssertEqualObjects(tokenRecorder.error.domain, GRMustacheErrorDomain, nil);
	STAssertEquals(tokenRecorder.error.code, (NSInteger)GRMustacheErrorCodeParseError, nil);
}
@end
