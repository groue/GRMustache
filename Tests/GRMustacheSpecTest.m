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

#import "GRMustacheSpecTest.h"
#import "YAML.h"


@interface GRMustacheSpecTest()
- (void)testSuiteAtURL:(NSURL *)suiteURL;
- (void)testSuiteTest:(NSDictionary *)suiteTest inSuiteNamed:(NSString *)suiteName;
@end

@implementation GRMustacheSpecTest

- (void)testMustacheSpecSuite {
	NSArray *suiteURLs = [[self testBundle] URLsForResourcesWithExtension:@"yml" subdirectory:@"specs"];
	for (NSURL *suiteURL in suiteURLs) {
		[self testSuiteAtURL:suiteURL];
	}
}

- (void)testSuiteAtURL:(NSURL *)suiteURL {
	NSString *suiteName = [[suiteURL lastPathComponent] stringByDeletingPathExtension];
	
	// TODO: find a way to test lambdas
	if ([suiteName isEqualToString:@"lambdas"]) {
		return;
	}
	
	NSString *yamlString = [NSString stringWithContentsOfURL:suiteURL encoding:NSUTF8StringEncoding error:nil];
	id suite = yaml_parse(yamlString);
	STAssertNotNil(suite, nil);
	STAssertTrue([suite isKindOfClass:[NSDictionary class]], nil);
	NSArray *suiteTests = [(NSDictionary *)suite objectForKey:@"tests"];
	STAssertNotNil(suiteTests, nil);
	for (NSDictionary *suiteTest in suiteTests) {
		[self testSuiteTest:suiteTest inSuiteNamed:suiteName];
	}
}

- (void)testSuiteTest:(NSDictionary *)suiteTest inSuiteNamed:(NSString *)suiteName {
//- name: Inline
//  desc: Comment blocks should be removed from the template.
//  data: { }
//  template: '12345{{! Comment Block! }}67890'
//  expected: '1234567890'
	
	NSString *testName = [suiteTest objectForKey:@"name"];
	NSString *testDescription = [suiteTest objectForKey:@"desc"];
	NSString *context = [suiteTest objectForKey:@"data"];
	NSString *templateString = [suiteTest objectForKey:@"template"];
	NSString *expected = [suiteTest objectForKey:@"expected"];
	
	NSError *error;
	NSString *result = [GRMustacheTemplate renderObject:context fromString:templateString error:&error];
	STAssertNotNil(result, [NSString stringWithFormat:@"%@/%@(%@): %@", suiteName, testName, testDescription, [[error userInfo] objectForKey:NSLocalizedDescriptionKey]]);
	if (result) {
		STAssertEqualObjects(result, expected, [NSString stringWithFormat:@"%@/%@(%@)", suiteName, testName, testDescription]);
	}
}

@end
