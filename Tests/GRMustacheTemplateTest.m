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
	GRMustacheLambda dieLambda = GRMustacheLambdaMake(^(GRMustacheRenderer renderer, id context, NSString *templateString) {
		dead = YES;
		return templateString;
	});
	NSString *templateString = @"{{#show}}<li>{{die}}</li>{{/show}}yay";
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

- (void)testSectionsReturningLambdasGetCalledWithText {
	__block int renderedCalls = 0;
	__block NSString *cache = nil;
	
	GRMustacheLambda renderedLambda = GRMustacheLambdaMake(^(GRMustacheRenderer renderer, id context, NSString *templateString) {
		if (cache == nil) {
			renderedCalls++;
			cache = renderer(context);
		}
		return cache;
	});
	
	GRMustacheLambda notRenderedLambda = GRMustacheLambdaMake(^(GRMustacheRenderer renderer, id context, NSString *templateString) {
		return templateString;
	});
	
	NSDictionary *context = [NSDictionary dictionaryWithObjectsAndKeys:
							 renderedLambda, @"rendered",
							 notRenderedLambda, @"not_rendered",
							 @"Gwendal", @"name",
							 nil];
	
	NSString *result;
	
	result = [self renderObject:context fromResource:@"lambda"];
	STAssertEqualObjects(result, @"|Gwendal|-|{{name}}|", @"");
	STAssertEquals(renderedCalls, 1, @"");
	
	result = [self renderObject:context fromResource:@"lambda"];
	STAssertEqualObjects(result, @"|Gwendal|-|{{name}}|", @"");
	STAssertEquals(renderedCalls, 1, @"");
	
	result = [self renderObject:context fromResource:@"lambda"];
	STAssertEqualObjects(result, @"|Gwendal|-|{{name}}|", @"");
	STAssertEquals(renderedCalls, 1, @"");
}

- (void)testLambdasCanRenderCurrentContextInSpecificTemplate {
	NSString *templateString = @"{{#wrapper}}{{/wrapper}}";
	GRMustacheTemplate *wrapperTemplate = [GRMustacheTemplate parseString:@"<b>{{name}}</b>" error:nil];
	GRMustacheLambda wrapperLambda = GRMustacheLambdaMake(^(GRMustacheRenderer renderer, id context, NSString *templateString) {
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

- (void)testLambdasCanReturnNil {
	NSString *templateString = @"foo{{#wrapper}}{{/wrapper}}bar";
	GRMustacheLambda wrapperLambda = GRMustacheLambdaMake(^(GRMustacheRenderer renderer, id context, NSString *templateString) {
		return (NSString *)nil;
	});
	NSDictionary *context = [NSDictionary dictionaryWithObject:wrapperLambda forKey:@"wrapper"];
	NSString *result = [GRMustacheTemplate renderObject:context fromString:templateString error:nil];
	STAssertEqualObjects(result, @"foobar", nil);
}

- (void)testNSDataIsRenderedAsNSUTF8StringEncoding {
	NSString *templateString = @"{{.}}";
	NSData *data = [@"中文" dataUsingEncoding:NSUTF8StringEncoding];
	NSString *result = [GRMustacheTemplate renderObject:data fromString:templateString error:nil];
	STAssertEqualObjects(result, @"中文", nil);
}

@end
