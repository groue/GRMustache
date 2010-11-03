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

#import "GRMustacheTemplateTest.h"


@implementation GRMustacheTemplateTest

- (void)testPassenger {
	NSDictionary *context = [NSDictionary dictionaryWithObjectsAndKeys:
							 @"example.com", @"server",
							 @"/var/www/example.com", @"deploy_to",
							 @"production", @"stage",
							 nil];
	NSString *result = [self renderObject:context fromResource:@"passenger" withExtension:@"conf"];
	STAssertEqualObjects(result, @"<VirtualHost *>\n  ServerName example.com\n  DocumentRoot /var/www/example.com\n  RailsEnv production\n</VirtualHost>\n", nil);
}

- (void)testComplexView {
	// TODO
}

- (void)testNestedObjects {
	// TODO
}

- (void)testSingleLineSections {
	NSString *templateString = @"<p class=\"flash-notice\" {{# no_flash }}style=\"display: none;\"{{/ no_flash }}>";
	NSDictionary *context = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:@"no_flash"];
	NSString *result = [GRMustacheTemplate renderObject:context fromString:templateString error:nil];
	STAssertEqualObjects(result, @"<p class=\"flash-notice\" style=\"display: none;\">", nil);
}

- (void)testMultiLineSectionsPreserveTrailingNewline {
	NSString *templateString = @"{{#something}}\nyay\n{{/something}}\nHowday.\n";
	NSDictionary *context = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:@"something"];
	NSString *result = [GRMustacheTemplate renderObject:context fromString:templateString error:nil];
	STAssertEqualObjects(result, @"yay\nHowday.\n", nil);
}

- (void)testSingleLineInvertedSections {
	NSString *templateString = @"<p class=\"flash-notice\" {{^ flash }}style=\"display: none;\"{{/ flash }}>";
	NSString *result = [GRMustacheTemplate renderObject:nil fromString:templateString error:nil];
	STAssertEqualObjects(result, @"<p class=\"flash-notice\" style=\"display: none;\">", nil);
}

- (void)testSimple {
	NSInteger value = 10000;
	NSDictionary *context = [NSDictionary dictionaryWithObjectsAndKeys:
							 @"Gwendal", @"name",
							 [NSNumber numberWithInteger:value], @"value",
							 [NSNumber numberWithFloat:value*0.6], @"taxed_value",
							 [NSNumber numberWithBool:YES], @"in_ca",
							 nil];
	NSString *result = [self renderObject:context fromResource:@"simple"];
	// Slight difference with the ruby test here: 6000.0 is rendered as "6000", not "6000.0"
	STAssertEqualObjects(result, @"Hello Gwendal\nYou have just won $10000!\nWell, $6000, after taxes.\n", nil);
}

- (void)testDictionaryAssignment {
	// TODO
}

- (void)testCrazierDictionaryAssignment {
	// TODO
}

- (void)testFilelessTemplates {
	NSString *templateString = @"Hi {{person}}!";
	NSDictionary *context = [NSDictionary dictionaryWithObject:@"Mom" forKey:@"person"];
	NSString *result = [GRMustacheTemplate renderObject:context fromString:templateString error:nil];
	STAssertEqualObjects(result, @"Hi Mom!", nil);
}

- (void)testDelimiters {
	NSDictionary *context = [NSDictionary dictionaryWithObjectsAndKeys:
							 @"It worked the first time.", @"start",
							 [NSArray arrayWithObjects:
							  [NSDictionary dictionaryWithObject:@"And it worked the second time." forKey:@"item"],
							  [NSDictionary dictionaryWithObject:@"As well as the third." forKey:@"item"],
							  nil], @"middle",
							 @"Then, surprisingly, it worked the final time.", @"final",
							 nil];
	NSString *result = [self renderObject:context fromResource:@"delimiters"];
	STAssertEqualObjects(result, @"\n* It worked the first time.\n\n* And it worked the second time.\n* As well as the third.\n\n* Then, surprisingly, it worked the final time.\n", nil);
}

- (void)testDoubleSection {
	NSDictionary *context = [NSDictionary dictionaryWithObjectsAndKeys:
							 [NSNumber numberWithBool:YES], @"t",
							 @"second", @"two",
							 nil];
	NSString *result = [self renderObject:context fromResource:@"double_section"];
	STAssertEqualObjects(result, @"* first\n* second\n* third\n", nil);
}

- (void)testInvertedSection {
	NSDictionary *context = [NSDictionary dictionaryWithObjectsAndKeys:
							 [NSNull null], @"t",
							 @"second", @"two",
							 nil];
	NSString *result = [self renderObject:context fromResource:@"inverted_section"];
	STAssertEqualObjects(result, @"* first\n* second\n* third\n", nil);
}

- (void)testComments {
	NSDictionary *context = [NSDictionary dictionaryWithObject:@"A Comedy of Errors" forKey:@"title"];
	NSString *result = [self renderObject:context fromResource:@"comments"];
	STAssertEqualObjects(result, @"<h1>A Comedy of Errors</h1>\n", nil);
}

- (void)testMultiLineComments {
	NSString *templateString = @"<h1>{{title}}{{! just something interesting... \n#or not... }}</h1>\n";
	NSDictionary *context = [NSDictionary dictionaryWithObject:@"A Comedy of Errors" forKey:@"title"];
	NSString *result = [GRMustacheTemplate renderObject:context fromString:templateString error:nil];
	STAssertEqualObjects(result, @"<h1>A Comedy of Errors</h1>\n", nil);
}

- (void)testEscaped {
	NSDictionary *context = [NSDictionary dictionaryWithObject:@"Bear > Shark" forKey:@"title"];
	NSString *result = [self renderObject:context fromResource:@"escaped"];
	STAssertEqualObjects(result, @"<h1>Bear &gt; Shark</h1>", nil);
}

- (void)testUnescaped {
	NSDictionary *context = [NSDictionary dictionaryWithObject:@"Bear > Shark" forKey:@"title"];
	NSString *result = [self renderObject:context fromResource:@"unescaped"];
	STAssertEqualObjects(result, @"<h1>Bear > Shark</h1>", nil);
}

- (void)testUnescapedAmpersand {
	NSString *templateString = @"<h1>{{& title}}</h1>";
	NSDictionary *context = [NSDictionary dictionaryWithObject:@"Bear > Shark" forKey:@"title"];
	NSString *result = [GRMustacheTemplate renderObject:context fromString:templateString error:nil];
	STAssertEqualObjects(result, @"<h1>Bear > Shark</h1>", nil);
}

- (void)testRenderFromFile {
	NSURL *url = [[self.testBundle resourceURL] URLByAppendingPathComponent:@"passenger.conf"];
	NSDictionary *context = [NSDictionary dictionaryWithObjectsAndKeys:
							 @"example.com", @"server",
							 @"/var/www/example.com", @"deploy_to",
							 @"production", @"stage",
							 nil];
	NSString *result = [GRMustacheTemplate renderObject:context fromContentsOfURL:url error:nil];
	STAssertEqualObjects(result, @"<VirtualHost *>\n  ServerName example.com\n  DocumentRoot /var/www/example.com\n  RailsEnv production\n</VirtualHost>\n", nil);
}

- (void)testDoesntExecuteWhatItDoesntNeedTo {
	__block BOOL dead = NO;
	GRMustacheLambda dieLambda = GRMustacheLambdaMake(^(GRMustacheRenderer renderer, GRMustacheContext *context, NSString *templateString) {
		dead = YES;
		return templateString;
	});
	NSString *templateString = @"{{#show}} <li>{{die}}</li> {{/show}} yay";
	NSDictionary *context = [NSDictionary dictionaryWithObject:dieLambda forKey:@"die"];
	NSString *result = [GRMustacheTemplate renderObject:context fromString:templateString error:nil];
	STAssertEqualObjects(result, @"yay", nil);
	STAssertEquals(dead, NO, nil);
}

- (void)testReportsUnclosedSections {
	NSString *templateString = @"{{#list}} <li>{{item}}</li> {{/gist}}";
	NSError *error;
	GRMustacheTemplate *template = [GRMustacheTemplate parseString:templateString error:&error];
	STAssertNil(template, nil);
	STAssertEquals(error.code, (NSInteger)GRMustacheErrorCodeParseError, nil);
	// TODO: check value of [error.userInfo objectForKey:NSLocalizedDescriptionKey]
}

- (void)testReportsUnclosedSectionsReportsTheLineNumber {
	NSString *templateString = @"hi\nmom\n{{#list}} <li>{{item}}</li> {{/gist}}";
	NSError *error;
	GRMustacheTemplate *template = [GRMustacheTemplate parseString:templateString error:&error];
	STAssertNil(template, nil);
	STAssertEquals(error.code, (NSInteger)GRMustacheErrorCodeParseError, nil);
	STAssertEquals([(NSNumber *)[error.userInfo objectForKey:GRMustacheErrorLine] intValue], 3, nil);
}

- (void)testEnumerableSectionsAcceptADictionaryAsAContext {
	NSString *templateString = @"{{#list}} <li>{{item}}</li> {{/list}}";
	NSDictionary *context = [NSDictionary dictionaryWithObject:[NSDictionary dictionaryWithObject:@"1234"
																						   forKey:@"item"]
														forKey:@"list"];
	NSString *result = [GRMustacheTemplate renderObject:context fromString:templateString error:nil];
	STAssertEqualObjects(result, @"<li>1234</li> ", nil);
}

- (void)testNotFoundInContextRendersEmptyString {
	NSString *templateString = @"{{#list}} <li>{{item}}</li> {{/list}}";
	NSString *result = [GRMustacheTemplate renderObject:nil fromString:templateString error:nil];
	STAssertEqualObjects(result, @"", nil);
}

- (void)testNotFoundInNestedContextRendersEmptyString {
	NSString *templateString = @"{{#list}} <li>{{prefix}}{{item}}</li> {{/list}}";
	NSDictionary *context = [NSDictionary dictionaryWithObject:[NSDictionary dictionaryWithObject:@"1234"
																						   forKey:@"item"]
														forKey:@"list"];
	NSString *result = [GRMustacheTemplate renderObject:context fromString:templateString error:nil];
	STAssertEqualObjects(result, @"<li>1234</li> ", nil);
}

- (void)testSectionsReturningLambdasGetCalledWithText {
	__block int renderedCalls = 0;
	__block NSString *cache = nil;
	
	GRMustacheLambda renderedLambda = GRMustacheLambdaMake(^(GRMustacheRenderer renderer, GRMustacheContext *context, NSString *templateString) {
		if (cache == nil) {
			renderedCalls++;
			cache = renderer(context);
		}
		return cache;
	});
	
	GRMustacheLambda notRenderedLambda = GRMustacheLambdaMake(^(GRMustacheRenderer renderer, GRMustacheContext *context, NSString *templateString) {
		return templateString;
	});
	
	NSDictionary *context = [NSDictionary dictionaryWithObjectsAndKeys:
							 renderedLambda, @"rendered",
							 notRenderedLambda, @"not_rendered",
							 @"Gwendal", @"name",
							 nil];
	
	NSString *result;
	
	result = [self renderObject:context fromResource:@"lambda"];
	STAssertEqualObjects(result, @"Hi Gwendal.\nHi {{name}}.\n", @"");
	STAssertEquals(renderedCalls, 1, @"");
	
	result = [self renderObject:context fromResource:@"lambda"];
	STAssertEqualObjects(result, @"Hi Gwendal.\nHi {{name}}.\n", @"");
	STAssertEquals(renderedCalls, 1, @"");
	
	result = [self renderObject:context fromResource:@"lambda"];
	STAssertEqualObjects(result, @"Hi Gwendal.\nHi {{name}}.\n", @"");
	STAssertEquals(renderedCalls, 1, @"");
}

- (void)testLambdasCanRenderCurrentContextInSpecificTemplate {
	NSString *templateString = @"{{#wrapper}}{{/wrapper}}";
	GRMustacheTemplate *wrapperTemplate = [GRMustacheTemplate parseString:@"<b>{{name}}</b>" error:nil];
	GRMustacheLambda wrapperLambda = GRMustacheLambdaMake(^(GRMustacheRenderer renderer, GRMustacheContext *context, NSString *templateString) {
		return [wrapperTemplate renderObject:context];
	});
	NSDictionary *context = [NSDictionary dictionaryWithObjectsAndKeys:
							 wrapperLambda, @"wrapper",
							 @"Gwendal", @"name",
							 nil];
	NSString *result = [GRMustacheTemplate renderObject:context fromString:templateString error:nil];
	STAssertEqualObjects(result, @"<b>Gwendal</b>", nil);
}

- (void)testLotsOfStaches {
	NSString *templateString = @"{{{{foo}}}}";
	NSError *error;
	GRMustacheTemplate *template = [GRMustacheTemplate parseString:templateString error:&error];
	STAssertNil(template, nil);
	STAssertEquals(error.code, (NSInteger)GRMustacheErrorCodeParseError, nil);
	// TODO: check value of [error.userInfo objectForKey:NSLocalizedDescriptionKey]
}

- (void)testLiberalTagNames {
	NSString *templateString = @"{{first-name}} {{middle_name!}} {{lastName?}}";
	NSDictionary *context = [NSDictionary dictionaryWithObjectsAndKeys:
							 @"Gwendal", @"first-name",
							 @"Gw", @"middle_name!",
							 @"Roué", @"lastName?",
							 nil];
	NSString *result = [GRMustacheTemplate renderObject:context fromString:templateString error:nil];
	STAssertEqualObjects(result, @"Gwendal Gw Roué", nil);
}

- (void)testNestedSectionsSameNames {
	NSString *templateString = @"{{#items}}start{{#items}}{{a}}{{/items}}end{{/items}}";
	NSDictionary *context = [NSDictionary dictionaryWithObject:[NSArray arrayWithObjects:
																[NSDictionary dictionaryWithObject:[NSArray arrayWithObjects:
																									[NSDictionary dictionaryWithObject:@"1" forKey:@"a"],
																									[NSDictionary dictionaryWithObject:@"2" forKey:@"a"],
																									[NSDictionary dictionaryWithObject:@"3" forKey:@"a"],
																									nil]
																							forKey:@"items"],
																[NSDictionary dictionaryWithObject:[NSArray arrayWithObjects:
																									[NSDictionary dictionaryWithObject:@"4" forKey:@"a"],
																									[NSDictionary dictionaryWithObject:@"5" forKey:@"a"],
																									[NSDictionary dictionaryWithObject:@"6" forKey:@"a"],
																									nil]
																							forKey:@"items"],
																[NSDictionary dictionaryWithObject:[NSArray arrayWithObjects:
																									[NSDictionary dictionaryWithObject:@"7" forKey:@"a"],
																									[NSDictionary dictionaryWithObject:@"8" forKey:@"a"],
																									[NSDictionary dictionaryWithObject:@"9" forKey:@"a"],
																									nil]
																							forKey:@"items"],
																nil]
														forKey:@"items"];
	NSString *result = [GRMustacheTemplate renderObject:context fromString:templateString error:nil];
	STAssertEqualObjects(result, @"start123endstart456endstart789end", nil);
}

- (void)testIdWithNestedContent {
	NSString *templateString = @"<div>{{id}}</div>\n<div>{{# has_a? }}{{id}}{{/ has_a? }}</div>\n<div>{{# has_b? }}{{id}}{{/ has_b? }}</div>";
	NSDictionary *context = [NSDictionary dictionaryWithObjectsAndKeys:
							 @"3", @"id",
							 [NSNumber numberWithBool:YES], @"has_a?",
							 [NSNumber numberWithBool:YES], @"has_b?",
							 nil];
	NSString *result = [GRMustacheTemplate renderObject:context fromString:templateString error:nil];
	STAssertEqualObjects(result, @"<div>3</div>\n<div>3</div>\n<div>3</div>", nil);
}

- (void)testUTF8 {
	NSDictionary *context = [NSDictionary dictionaryWithObject:@"中文" forKey:@"test"];
	NSString *result = [self renderObject:context fromResource:@"utf8"];
	STAssertEqualObjects(result, @"<h1>中文 中文</h1>\n\n<h2>中文又来啦</h2>\n", nil);
}

- (void)testIndentation_Obsolete {
	NSString *templateString = @"def {{name}}\n  {{text}}\nend\n";
	NSDictionary *context = [NSDictionary dictionaryWithObjectsAndKeys:
							 @"indent", @"name",
							 @"puts :indented!", @"text",
							 nil];
	NSString *result = [GRMustacheTemplate renderObject:context fromString:templateString error:nil];
	STAssertEqualObjects(result, @"def indent\n  puts :indented!\nend\n", nil);
}

- (void)testIndentation {
	// TODO
}

- (void)testVariableElementDoesntRenderNSNull {
	NSString *templateString = @"name:{{name}}";
	NSDictionary *context = [NSDictionary dictionaryWithObject:[NSNull null] forKey:@"name"];
	NSString *result = [GRMustacheTemplate renderObject:context fromString:templateString error:nil];
	STAssertEqualObjects(result, @"name:", nil);
}

- (void)testVariableElementDoesntRenderGRNo {
	NSString *templateString = @"name:{{name}}";
	NSDictionary *context = [NSDictionary dictionaryWithObject:[GRNo no] forKey:@"name"];
	NSString *result = [GRMustacheTemplate renderObject:context fromString:templateString error:nil];
	STAssertEqualObjects(result, @"name:", nil);
}

- (void)testLambdasGetLeftTrimmedLitteral {
	NSString *templateString = @"{{#wrapper}} \n\tfoo \t\n{{/wrapper}}";
	GRMustacheLambda wrapperLambda = GRMustacheLambdaMake(^(GRMustacheRenderer renderer, GRMustacheContext *context, NSString *templateString) {
		STAssertEqualObjects(templateString, @"foo \t\n", nil);
		return @"";
	});
	NSDictionary *context = [NSDictionary dictionaryWithObject:wrapperLambda forKey:@"wrapper"];
	[GRMustacheTemplate renderObject:context fromString:templateString error:nil];
}

- (void)testLambdasCanReturnNil {
	NSString *templateString = @"foo{{#wrapper}}{{/wrapper}}bar";
	GRMustacheLambda wrapperLambda = GRMustacheLambdaMake(^(GRMustacheRenderer renderer, GRMustacheContext *context, NSString *templateString) {
		return (NSString *)nil;
	});
	NSDictionary *context = [NSDictionary dictionaryWithObject:wrapperLambda forKey:@"wrapper"];
	NSString *result = [GRMustacheTemplate renderObject:context fromString:templateString error:nil];
	STAssertEqualObjects(result, @"foobar", nil);
}

- (void)testNilIsAFalseValue {
	NSString *templateString = @"{{#bool}}YES{{/bool}}{{^bool}}NO{{/bool}}";
	NSDictionary *context = [NSDictionary dictionary];
	STAssertNil([context valueForKey:@"bool"], nil);
	NSString *result = [GRMustacheTemplate renderObject:context fromString:templateString error:nil];
	STAssertEqualObjects(result, @"NO", nil);
}

- (void)testNSNullIsAFalseValue {
	NSString *templateString = @"{{#bool}}YES{{/bool}}{{^bool}}NO{{/bool}}";
	NSDictionary *context = [NSDictionary dictionaryWithObject:[NSNull null] forKey:@"bool"];
	NSString *result = [GRMustacheTemplate renderObject:context fromString:templateString error:nil];
	STAssertEqualObjects(result, @"NO", nil);
}

- (void)testEmptyStringIsAFalseValue {
	NSString *templateString = @"{{#bool}}YES{{/bool}}{{^bool}}NO{{/bool}}";
	NSDictionary *context = [NSDictionary dictionaryWithObject:@"" forKey:@"bool"];
	NSString *result = [GRMustacheTemplate renderObject:context fromString:templateString error:nil];
	STAssertEqualObjects(result, @"NO", nil);
}

@end
