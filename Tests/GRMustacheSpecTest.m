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
#import "GRMustacheTemplateLoader_protected.h"


@interface GRMustacheSpecTemplateLoader : GRMustacheTemplateLoader {
	NSDictionary *partialsByName;
}
+ (id)loaderWithDictionary:(NSDictionary *)partialsByName;
- (id)initWithDictionary:(NSDictionary *)partialsByName;
@end

@implementation GRMustacheSpecTemplateLoader

+ (id)loaderWithDictionary:(NSDictionary *)partialsByName {
	return [[[self alloc] initWithDictionary:partialsByName] autorelease];
}

- (id)initWithDictionary:(NSDictionary *)thePartialsByName {
	if (self == [self initWithExtension:nil encoding:NSUTF8StringEncoding]) {
		if (thePartialsByName == nil) {
			thePartialsByName = [NSDictionary dictionary];
		}
		NSAssert([thePartialsByName isKindOfClass:[NSDictionary class]], nil);
		partialsByName = [thePartialsByName retain];
	}
	return self;
}

- (void)dealloc {
	[partialsByName release];
	[super dealloc];
}

- (id)templateIdForTemplateNamed:(NSString *)name relativeToTemplateId:(id)baseTemplateId {
	return name;
}

- (NSString *)templateStringForTemplateId:(id)templateId error:(NSError **)outError {
	return [partialsByName objectForKey:templateId];
}

@end



@interface GRMustacheSpecTest()
- (void)testSubsetNamed:(NSString *)subsetName;
- (void)testSuiteAtURL:(NSURL *)suiteURL inSubsetNamed:(NSString *)subsetName;
- (void)testSuiteTest:(NSDictionary *)suiteTest inSuiteNamed:(NSString *)suiteName inSubsetNamed:(NSString *)subsetName;
@end

@implementation GRMustacheSpecTest

- (void)testMustacheSpec {
	[self testSubsetNamed:@"core"];
	[self testSubsetNamed:@"dot_key"];
	[self testSubsetNamed:@"extended_path"];
}

- (void)testSubsetNamed:(NSString *)subsetName {
	NSArray *suiteURLs = [[self testBundle] URLsForResourcesWithExtension:@"yml" subdirectory:subsetName];
	for (NSURL *suiteURL in suiteURLs) {
		[self testSuiteAtURL:suiteURL inSubsetNamed:subsetName];
	}
}

- (void)testSuiteAtURL:(NSURL *)suiteURL inSubsetNamed:(NSString *)subsetName {
	NSString *suiteName = [[suiteURL lastPathComponent] stringByDeletingPathExtension];
	if ([suiteName isEqualToString:@"lambda_sections"]) {
		return;
	}
	if ([suiteName isEqualToString:@"lambda_variables"]) {
		return;
	}
	NSString *yamlString = [NSString stringWithContentsOfURL:suiteURL encoding:NSUTF8StringEncoding error:nil];
	id suite = yaml_parse(yamlString);
	STAssertNotNil(suite, nil);
	STAssertTrue([suite isKindOfClass:[NSDictionary class]], nil);
	NSArray *suiteTests = [(NSDictionary *)suite objectForKey:@"tests"];
	STAssertNotNil(suiteTests, nil);
	for (NSDictionary *suiteTest in suiteTests) {
		[self testSuiteTest:suiteTest inSuiteNamed:suiteName inSubsetNamed:subsetName];
	}
}

- (void)testSuiteTest:(NSDictionary *)suiteTest inSuiteNamed:(NSString *)suiteName inSubsetNamed:(NSString *)subsetName {
	NSString *testName = [suiteTest objectForKey:@"name"];
	id context = [suiteTest objectForKey:@"data"];
	NSString *templateString = [suiteTest objectForKey:@"template"];
	NSString *expected = [suiteTest objectForKey:@"expected"];
	NSDictionary *partials = [suiteTest objectForKey:@"partials"];
	GRMustacheTemplateLoader *loader = [GRMustacheSpecTemplateLoader loaderWithDictionary:partials];

	NSError *error;
	GRMustacheTemplate *template = [loader parseString:templateString error:&error];
	STAssertNotNil(template, [NSString stringWithFormat:@"%@/%@ - %@: %@", subsetName, suiteName, testName, [[error userInfo] objectForKey:NSLocalizedDescriptionKey]]);
	if (template) {
		NSString *result = [template renderObject:context];
		if (![result isEqual:expected]) {
			// render again and debug
			template = [loader parseString:templateString error:&error];
			[template renderObject:context];
		}
		STAssertEqualObjects(result, expected, [NSString stringWithFormat:@"%@/%@ - %@", subsetName, suiteName, testName]);
	}
}

@end
