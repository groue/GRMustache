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

#import "GRMustacheSpec_v1_4_Test.h"
#import "YAML.h"
#import "GRMustacheTemplateLoader_protected.h"


@interface GRMustacheSpecTemplateLoader_v1_4 : GRMustacheTemplateLoader {
	NSDictionary *partialsByName;
}
+ (id)loaderWithDictionary:(NSDictionary *)partialsByName;
- (id)initWithDictionary:(NSDictionary *)partialsByName;
@end

@implementation GRMustacheSpecTemplateLoader_v1_4

+ (id)loaderWithDictionary:(NSDictionary *)partialsByName {
	return [[[self alloc] initWithDictionary:partialsByName] autorelease];
}

- (id)initWithDictionary:(NSDictionary *)thePartialsByName {
	if ((self = [self initWithExtension:nil encoding:NSUTF8StringEncoding])) {
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


@interface GRMustacheSpec_v1_4_Test()
- (void)testModuleNamed:(NSString *)moduleName;
- (void)testSuiteAtURL:(NSURL *)suiteURL inModuleNamed:(NSString *)moduleName;
- (void)testSuiteTest:(NSDictionary *)suiteTest inSuiteNamed:(NSString *)suiteName inModuleNamed:(NSString *)moduleName;
@end

@implementation GRMustacheSpec_v1_4_Test

- (void)testMustacheSpec {
	[self testModuleNamed:@"core"];
	[self testModuleNamed:@"dot_key"];
	[self testModuleNamed:@"extended_path"];
	[self testModuleNamed:@"file_system"];
}

- (void)testModuleNamed:(NSString *)moduleName {
	NSArray *suiteURLs = [[self testBundle] URLsForResourcesWithExtension:@"yml" subdirectory:moduleName];
	for (NSURL *suiteURL in suiteURLs) {
		[self testSuiteAtURL:suiteURL inModuleNamed:moduleName];
	}
}

- (void)testSuiteAtURL:(NSURL *)suiteURL inModuleNamed:(NSString *)moduleName {
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
		[self testSuiteTest:suiteTest inSuiteNamed:suiteName inModuleNamed:moduleName];
	}
}

- (void)testSuiteTest:(NSDictionary *)suiteTest inSuiteNamed:(NSString *)suiteName inModuleNamed:(NSString *)moduleName {
	NSFileManager *fm = [NSFileManager defaultManager];
	NSString *templatesDirectoryPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"GRMustacheTest"];
	NSString *testName = [suiteTest objectForKey:@"name"];
	id context = [suiteTest objectForKey:@"data"];
	NSString *templateString = [suiteTest objectForKey:@"template"];
	NSString *expected = [suiteTest objectForKey:@"expected"];
	NSString *baseTemplatePath = [suiteTest objectForKey:@"template_path"];
	NSMutableDictionary *partials = [[[suiteTest objectForKey:@"partials"] mutableCopy] autorelease];

	NSError *error;
	GRMustacheTemplateLoader *loader;
	GRMustacheTemplate *template;
	
	if (baseTemplatePath.length > 0) {
		[fm removeItemAtPath:templatesDirectoryPath error:nil];
		[fm createDirectoryAtPath:templatesDirectoryPath withIntermediateDirectories:YES attributes:nil error:&error];
		[partials setObject:templateString forKey:baseTemplatePath];
		for (NSString *templateName in partials) {
			templateString = [partials objectForKey:templateName];
			NSString *templatePath = [templatesDirectoryPath stringByAppendingPathComponent:templateName];
			[fm createDirectoryAtPath:[templatePath stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:&error];
			[fm createFileAtPath:templatePath contents:[templateString dataUsingEncoding:NSUTF8StringEncoding] attributes:nil];
		}
		loader = [GRMustacheTemplateLoader templateLoaderWithBasePath:templatesDirectoryPath extension:[baseTemplatePath pathExtension]];
		template = [loader parseTemplateNamed:[baseTemplatePath stringByDeletingPathExtension] error:&error];
	} else {
		loader = [GRMustacheSpecTemplateLoader_v1_4 loaderWithDictionary:partials];
		template = [loader parseString:templateString error:&error];
	}

	STAssertNotNil(template, [NSString stringWithFormat:@"%@/%@ - %@: %@", moduleName, suiteName, testName, [[error userInfo] objectForKey:NSLocalizedDescriptionKey]]);
	if (template) {
		NSString *result = [template renderObject:context];
		if (![result isEqual:expected]) {
			// render again and debug
			template = [loader parseString:templateString error:&error];
			[template renderObject:context];
		}
		STAssertEqualObjects(result, expected, [NSString stringWithFormat:@"%@/%@ - %@", moduleName, suiteName, testName]);
	}

	if (baseTemplatePath.length > 0) {
		[fm removeItemAtPath:templatesDirectoryPath error:&error];
	}
}

@end
