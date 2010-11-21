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


@interface GRMustacheTokenConsumer : NSObject<GRMustacheTokenizerDelegate> {
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

@implementation GRMustacheTokenConsumer
@synthesize error;
@synthesize tokenizerDidFinish;
@dynamic tokenCount;

- (id)init {
	if (self = [super init]) {
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

- (BOOL)templateTokenizer:(GRMustacheTokenizer *)tokenizer didReadToken:(GRMustacheToken *)token {
	[tokenTypes addObject:[NSNumber numberWithInt:token.type]];
	[tokenContents addObject:token.content];
	return YES;
}

- (void)templateTokenizerDidFinish:(GRMustacheTokenizer *)tokenizer withError:(NSError *)theError {
	tokenizerDidFinish = YES;
	error = [theError retain];
}
@end



@implementation GRMustacheTokenizerTest

- (void)setUp {
	consumer = [[GRMustacheTokenConsumer alloc] init];
	tokenizer = [[GRMustacheTokenizer alloc] init];
	tokenizer.delegate = consumer;
}

- (void)tearDown {
	[tokenizer release];
	[consumer release];
}


- (void)testTokenizerParsesSingleTextToken {
	NSString *templateString = @"text";
	[tokenizer parseTemplateString:templateString];
	STAssertTrue(consumer.tokenizerDidFinish, nil);
	STAssertEquals((NSUInteger)1, consumer.tokenCount, nil);
	STAssertEquals(GRMustacheTokenTypeText, [consumer tokenTypeAtIndex:0], nil);
	STAssertEqualObjects(@"text", [consumer tokenContentAtIndex:0], nil);
}

- (void)testTokenizerParsesSingleCommentToken {
	NSString *templateString = @"{{!comment}}";
	[tokenizer parseTemplateString:templateString];
	STAssertTrue(consumer.tokenizerDidFinish, nil);
	STAssertEquals((NSUInteger)1, consumer.tokenCount, nil);
	STAssertEquals(GRMustacheTokenTypeComment, [consumer tokenTypeAtIndex:0], nil);
	STAssertEqualObjects(@"comment", [consumer tokenContentAtIndex:0], nil);
}

- (void)testTokenizerParsesSingleEscapedVariableToken {
	NSString *templateString = @"{{name}}";
	[tokenizer parseTemplateString:templateString];
	STAssertTrue(consumer.tokenizerDidFinish, nil);
	STAssertEquals((NSUInteger)1, consumer.tokenCount, nil);
	STAssertEquals(GRMustacheTokenTypeEscapedVariable, [consumer tokenTypeAtIndex:0], nil);
	STAssertEqualObjects(@"name", [consumer tokenContentAtIndex:0], nil);
}

- (void)testTokenizerTrimsSingleEscapedVariableToken {
	NSString *templateString = @"{{ \n\tname \n\t}}";
	[tokenizer parseTemplateString:templateString];
	STAssertTrue(consumer.tokenizerDidFinish, nil);
	STAssertEquals((NSUInteger)1, consumer.tokenCount, nil);
	STAssertEquals(GRMustacheTokenTypeEscapedVariable, [consumer tokenTypeAtIndex:0], nil);
	STAssertEqualObjects(@"name", [consumer tokenContentAtIndex:0], nil);
}

- (void)testTokenizerParsesSingleUnescapedVariableTokenWithThreeMustache {
	NSString *templateString = @"{{{name}}}";
	[tokenizer parseTemplateString:templateString];
	STAssertTrue(consumer.tokenizerDidFinish, nil);
	STAssertEquals((NSUInteger)1, consumer.tokenCount, nil);
	STAssertEquals(GRMustacheTokenTypeUnescapedVariable, [consumer tokenTypeAtIndex:0], nil);
	STAssertEqualObjects(@"name", [consumer tokenContentAtIndex:0], nil);
}

- (void)testTokenizerTrimsSingleUnescapedVariableTokenWithThreeMustache {
	NSString *templateString = @"{{{ \n\tname \n\t}}}";
	[tokenizer parseTemplateString:templateString];
	STAssertTrue(consumer.tokenizerDidFinish, nil);
	STAssertEquals((NSUInteger)1, consumer.tokenCount, nil);
	STAssertEquals(GRMustacheTokenTypeUnescapedVariable, [consumer tokenTypeAtIndex:0], nil);
	STAssertEqualObjects(@"name", [consumer tokenContentAtIndex:0], nil);
}

- (void)testTokenizerParsesSingleUnescapedVariableTokenWithAmpersand {
	NSString *templateString = @"{{&name}}";
	[tokenizer parseTemplateString:templateString];
	STAssertTrue(consumer.tokenizerDidFinish, nil);
	STAssertEquals((NSUInteger)1, consumer.tokenCount, nil);
	STAssertEquals(GRMustacheTokenTypeUnescapedVariable, [consumer tokenTypeAtIndex:0], nil);
	STAssertEqualObjects(@"name", [consumer tokenContentAtIndex:0], nil);
}

- (void)testTokenizerTrimsSingleUnescapedVariableTokenWithAmpersand {
	NSString *templateString = @"{{& \n\tname \n\t}}";
	[tokenizer parseTemplateString:templateString];
	STAssertTrue(consumer.tokenizerDidFinish, nil);
	STAssertEquals((NSUInteger)1, consumer.tokenCount, nil);
	STAssertEquals(GRMustacheTokenTypeUnescapedVariable, [consumer tokenTypeAtIndex:0], nil);
	STAssertEqualObjects(@"name", [consumer tokenContentAtIndex:0], nil);
}

- (void)testTokenizerParsesSingleSectionOpeningToken {
	NSString *templateString = @"{{#name}}";
	[tokenizer parseTemplateString:templateString];
	STAssertTrue(consumer.tokenizerDidFinish, nil);
	STAssertEquals((NSUInteger)1, consumer.tokenCount, nil);
	STAssertEquals(GRMustacheTokenTypeSectionOpening, [consumer tokenTypeAtIndex:0], nil);
	STAssertEqualObjects(@"name", [consumer tokenContentAtIndex:0], nil);
}

- (void)testTokenizerTrimsSingleSectionOpeningToken {
	NSString *templateString = @"{{# \n\tname \n\t}}";
	[tokenizer parseTemplateString:templateString];
	STAssertTrue(consumer.tokenizerDidFinish, nil);
	STAssertEquals((NSUInteger)1, consumer.tokenCount, nil);
	STAssertEquals(GRMustacheTokenTypeSectionOpening, [consumer tokenTypeAtIndex:0], nil);
	STAssertEqualObjects(@"name", [consumer tokenContentAtIndex:0], nil);
}

- (void)testTokenizerParsesSingleInvertedSectionOpeningToken {
	NSString *templateString = @"{{^name}}";
	[tokenizer parseTemplateString:templateString];
	STAssertTrue(consumer.tokenizerDidFinish, nil);
	STAssertEquals((NSUInteger)1, consumer.tokenCount, nil);
	STAssertEquals(GRMustacheTokenTypeInvertedSectionOpening, [consumer tokenTypeAtIndex:0], nil);
	STAssertEqualObjects(@"name", [consumer tokenContentAtIndex:0], nil);
}

- (void)testTokenizerTrimsSingleInvertedSectionOpeningToken {
	NSString *templateString = @"{{^ \n\tname \n\t}}";
	[tokenizer parseTemplateString:templateString];
	STAssertTrue(consumer.tokenizerDidFinish, nil);
	STAssertEquals((NSUInteger)1, consumer.tokenCount, nil);
	STAssertEquals(GRMustacheTokenTypeInvertedSectionOpening, [consumer tokenTypeAtIndex:0], nil);
	STAssertEqualObjects(@"name", [consumer tokenContentAtIndex:0], nil);
}

- (void)testTokenizerParsesSingleSectionClosingToken {
	NSString *templateString = @"{{/name}}";
	[tokenizer parseTemplateString:templateString];
	STAssertTrue(consumer.tokenizerDidFinish, nil);
	STAssertEquals((NSUInteger)1, consumer.tokenCount, nil);
	STAssertEquals(GRMustacheTokenTypeSectionClosing, [consumer tokenTypeAtIndex:0], nil);
	STAssertEqualObjects(@"name", [consumer tokenContentAtIndex:0], nil);
}

- (void)testTokenizerTrimsSingleSectionClosingToken {
	NSString *templateString = @"{{/ \n\tname \n\t}}";
	[tokenizer parseTemplateString:templateString];
	STAssertTrue(consumer.tokenizerDidFinish, nil);
	STAssertEquals((NSUInteger)1, consumer.tokenCount, nil);
	STAssertEquals(GRMustacheTokenTypeSectionClosing, [consumer tokenTypeAtIndex:0], nil);
	STAssertEqualObjects(@"name", [consumer tokenContentAtIndex:0], nil);
}

- (void)testTokenizerParsesSinglePartialToken {
	NSString *templateString = @"{{>name}}";
	[tokenizer parseTemplateString:templateString];
	STAssertTrue(consumer.tokenizerDidFinish, nil);
	STAssertEquals((NSUInteger)1, consumer.tokenCount, nil);
	STAssertEquals(GRMustacheTokenTypePartial, [consumer tokenTypeAtIndex:0], nil);
	STAssertEqualObjects(@"name", [consumer tokenContentAtIndex:0], nil);
}

- (void)testTokenizerTrimsSinglePartialToken {
	NSString *templateString = @"{{> \n\tname \n\t}}";
	[tokenizer parseTemplateString:templateString];
	STAssertTrue(consumer.tokenizerDidFinish, nil);
	STAssertEquals((NSUInteger)1, consumer.tokenCount, nil);
	STAssertEquals(GRMustacheTokenTypePartial, [consumer tokenTypeAtIndex:0], nil);
	STAssertEqualObjects(@"name", [consumer tokenContentAtIndex:0], nil);
}

- (void)testTokenizerParsesSingleSetDelimiterToken {
	NSString *templateString = @"{{=< >=}}";
	[tokenizer parseTemplateString:templateString];
	STAssertTrue(consumer.tokenizerDidFinish, nil);
	STAssertEquals((NSUInteger)1, consumer.tokenCount, nil);
	STAssertEquals(GRMustacheTokenTypeSetDelimiter, [consumer tokenTypeAtIndex:0], nil);
	STAssertEqualObjects(@"< >", [consumer tokenContentAtIndex:0], nil);
}

- (void)testTokenizerTrimsSingleSetDelimiterToken {
	NSString *templateString = @"{{= \n\t< > \n\t=}}";
	[tokenizer parseTemplateString:templateString];
	STAssertTrue(consumer.tokenizerDidFinish, nil);
	STAssertEquals((NSUInteger)1, consumer.tokenCount, nil);
	STAssertEquals(GRMustacheTokenTypeSetDelimiter, [consumer tokenTypeAtIndex:0], nil);
	STAssertEqualObjects(@"< >", [consumer tokenContentAtIndex:0], nil);
}

- (void)testTokenizerParsesTokenSuite {
	NSString *templateString = @"<{{!comment}}{{escaped_variable}}{{{unescaped_variable_1}}}{{&unescaped_variable_2}}{{#section_opening}}{{^inverted_section_opening}}{{/section_closing}}{{=< >=}}>";
	[tokenizer parseTemplateString:templateString];
	STAssertTrue(consumer.tokenizerDidFinish, nil);
	STAssertEquals((NSUInteger)10, consumer.tokenCount, nil);
	STAssertEquals(GRMustacheTokenTypeText, [consumer tokenTypeAtIndex:0], nil);
	STAssertEqualObjects(@"<", [consumer tokenContentAtIndex:0], nil);
	STAssertEquals(GRMustacheTokenTypeComment, [consumer tokenTypeAtIndex:1], nil);
	STAssertEqualObjects(@"comment", [consumer tokenContentAtIndex:1], nil);
	STAssertEquals(GRMustacheTokenTypeEscapedVariable, [consumer tokenTypeAtIndex:2], nil);
	STAssertEqualObjects(@"escaped_variable", [consumer tokenContentAtIndex:2], nil);
	STAssertEquals(GRMustacheTokenTypeUnescapedVariable, [consumer tokenTypeAtIndex:3], nil);
	STAssertEqualObjects(@"unescaped_variable_1", [consumer tokenContentAtIndex:3], nil);
	STAssertEquals(GRMustacheTokenTypeUnescapedVariable, [consumer tokenTypeAtIndex:4], nil);
	STAssertEqualObjects(@"unescaped_variable_2", [consumer tokenContentAtIndex:4], nil);
	STAssertEquals(GRMustacheTokenTypeSectionOpening, [consumer tokenTypeAtIndex:5], nil);
	STAssertEqualObjects(@"section_opening", [consumer tokenContentAtIndex:5], nil);
	STAssertEquals(GRMustacheTokenTypeInvertedSectionOpening, [consumer tokenTypeAtIndex:6], nil);
	STAssertEqualObjects(@"inverted_section_opening", [consumer tokenContentAtIndex:6], nil);
	STAssertEquals(GRMustacheTokenTypeSectionClosing, [consumer tokenTypeAtIndex:7], nil);
	STAssertEqualObjects(@"section_closing", [consumer tokenContentAtIndex:7], nil);
	STAssertEquals(GRMustacheTokenTypeSetDelimiter, [consumer tokenTypeAtIndex:8], nil);
	STAssertEqualObjects(@"< >", [consumer tokenContentAtIndex:8], nil);
	STAssertEquals(GRMustacheTokenTypeText, [consumer tokenTypeAtIndex:9], nil);
	STAssertEqualObjects(@">", [consumer tokenContentAtIndex:9], nil);
}

- (void)testSetDelimiterTokensChain {
	NSString *templateString = @"<{{=<% %>=}}<% start %><%=| |=%>|# middle || item ||/ middle ||={{ }}=|{{ final }}>";
	[tokenizer parseTemplateString:templateString];
	STAssertTrue(consumer.tokenizerDidFinish, nil);
	STAssertEquals((NSUInteger)10, consumer.tokenCount, nil);
	STAssertEquals(GRMustacheTokenTypeText, [consumer tokenTypeAtIndex:0], nil);
	STAssertEqualObjects(@"<", [consumer tokenContentAtIndex:0], nil);
	STAssertEquals(GRMustacheTokenTypeSetDelimiter, [consumer tokenTypeAtIndex:1], nil);
	STAssertEqualObjects(@"<% %>", [consumer tokenContentAtIndex:1], nil);
	STAssertEquals(GRMustacheTokenTypeEscapedVariable, [consumer tokenTypeAtIndex:2], nil);
	STAssertEqualObjects(@"start", [consumer tokenContentAtIndex:2], nil);
	STAssertEquals(GRMustacheTokenTypeSetDelimiter, [consumer tokenTypeAtIndex:3], nil);
	STAssertEqualObjects(@"| |", [consumer tokenContentAtIndex:3], nil);
	STAssertEquals(GRMustacheTokenTypeSectionOpening, [consumer tokenTypeAtIndex:4], nil);
	STAssertEqualObjects(@"middle", [consumer tokenContentAtIndex:4], nil);
	STAssertEquals(GRMustacheTokenTypeEscapedVariable, [consumer tokenTypeAtIndex:5], nil);
	STAssertEqualObjects(@"item", [consumer tokenContentAtIndex:5], nil);
	STAssertEquals(GRMustacheTokenTypeSectionClosing, [consumer tokenTypeAtIndex:6], nil);
	STAssertEqualObjects(@"middle", [consumer tokenContentAtIndex:6], nil);
	STAssertEquals(GRMustacheTokenTypeSetDelimiter, [consumer tokenTypeAtIndex:7], nil);
	STAssertEqualObjects(@"{{ }}", [consumer tokenContentAtIndex:7], nil);
	STAssertEquals(GRMustacheTokenTypeEscapedVariable, [consumer tokenTypeAtIndex:8], nil);
	STAssertEqualObjects(@"final", [consumer tokenContentAtIndex:8], nil);
	STAssertEquals(GRMustacheTokenTypeText, [consumer tokenTypeAtIndex:9], nil);
	STAssertEqualObjects(@">", [consumer tokenContentAtIndex:9], nil);
}

- (void)testLotsOfStache {
	NSString *templateString = @"{{{{foo}}}}";
	[tokenizer parseTemplateString:templateString];
	STAssertTrue(consumer.tokenizerDidFinish, nil);
	STAssertNotNil(consumer.error, nil);
	STAssertEqualObjects(consumer.error.domain, GRMustacheErrorDomain, nil);
	STAssertEquals(consumer.error.code, (NSInteger)GRMustacheErrorCodeParseError, nil);
}
@end
