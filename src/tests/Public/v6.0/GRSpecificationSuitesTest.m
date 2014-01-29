// The MIT License
// 
// Copyright (c) 2014 Gwendal Roué
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

#define GRMUSTACHE_VERSION_MAX_ALLOWED GRMUSTACHE_VERSION_6_0
#import "GRMustachePublicAPITest.h"

@interface GRSpecificationSuitesTest : GRMustachePublicAPITest
@end

@interface GRSpecificationSuitesTest()
- (void)testSuiteFromContentsOfJSONFile:(NSString *)path;
@end

@implementation GRSpecificationSuitesTest

- (void)testSpecificationSuites
{
    [self testSuiteFromContentsOfJSONFile:[self.testBundle pathForResource:@"comments" ofType:@"json"]];
    [self testSuiteFromContentsOfJSONFile:[self.testBundle pathForResource:@"delimiters" ofType:@"json"]];
    [self testSuiteFromContentsOfJSONFile:[self.testBundle pathForResource:@"interpolation" ofType:@"json"]];
    [self testSuiteFromContentsOfJSONFile:[self.testBundle pathForResource:@"inverted" ofType:@"json"]];
    [self testSuiteFromContentsOfJSONFile:[self.testBundle pathForResource:@"partials" ofType:@"json"]];
    [self testSuiteFromContentsOfJSONFile:[self.testBundle pathForResource:@"sections" ofType:@"json"]];
}

- (void)testSuiteFromContentsOfJSONFile:(NSString *)path
{
    NSError *error;
    NSData *testSuiteData = [NSData dataWithContentsOfFile:path];
    STAssertNotNil(testSuiteData, @"Could not load test suite at %@", path);
    if (!testSuiteData) return;
    
    NSDictionary *testSuite = [self JSONObjectWithData:testSuiteData error:&error];
    STAssertNotNil(testSuite, @"Could not load test suite at %@: %@", path, error);
    if (!testSuite) return;
    
    NSArray *tests = [testSuite objectForKey:@"tests"];
    STAssertTrue((tests.count > 0), @"Empty test suite at %@", path);
    
    for (NSDictionary *test in tests) {
        id data = [test objectForKey:@"data"];
        NSString *templateString = [test objectForKey:@"template"];
        NSDictionary *partialsDictionary = [test objectForKey:@"partials"];
        NSString *expected = [test objectForKey:@"expected"];
        
        GRMustacheTemplateRepository *repository = [GRMustacheTemplateRepository templateRepositoryWithDictionary:partialsDictionary];
        GRMustacheTemplate *template = [repository templateFromString:templateString error:NULL];
        NSString *rendering = [template renderObject:data error:NULL];
        
        // GRMustache3 doesn't care about white space rules of the Mustache specification.
        // Compare rendering and expected rendering, but ignoring white space.
        NSCharacterSet *w = [NSCharacterSet whitespaceAndNewlineCharacterSet];
        rendering = [[rendering componentsSeparatedByCharactersInSet:w] componentsJoinedByString:@""];
        expected = [[expected componentsSeparatedByCharactersInSet:w] componentsJoinedByString:@""];
        STAssertEqualObjects(rendering, expected, @"Failed specification test in suite %@: %@", path, test);
    }
}
     
@end
