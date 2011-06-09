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

#import "GRMustache_context.h"
#import "GRMustacheTemplate_v1_0_Test.h"
#import "GRMustacheError.h"
#import "GRBoolean.h"
#import "GRMustacheRendering.h"


@implementation GRMustacheTemplate_v1_0_Test

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

#if !TARGET_OS_IPHONE || GRMUSTACHE_IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
- (void)testRenderFromURL {
	NSURL *url = [[self.testBundle resourceURL] URLByAppendingPathComponent:@"passenger.conf"];
	NSDictionary *context = [NSDictionary dictionaryWithObjectsAndKeys:
							 @"example.com", @"server",
							 @"/var/www/example.com", @"deploy_to",
							 @"production", @"stage",
							 nil];
	NSString *result = [GRMustacheTemplate renderObject:context fromContentsOfURL:url error:nil];
	STAssertEqualObjects(result, @"<VirtualHost *>\n  ServerName example.com\n  DocumentRoot /var/www/example.com\n  RailsEnv production\n</VirtualHost>\n", nil);
}
#endif

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

- (void)testVariableElementDoesntRenderNSNumberWithBoolNO {
	NSString *templateString = @"name:{{name}}";
	NSDictionary *context = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:@"name"];
	NSString *result = [GRMustacheTemplate renderObject:context fromString:templateString error:nil];
	STAssertEqualObjects(result, @"name:", nil);
}

@end
