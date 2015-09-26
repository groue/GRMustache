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

#define GRMUSTACHE_VERSION_MAX_ALLOWED GRMUSTACHE_VERSION_7_0
#import "GRMustachePublicAPITest.h"

@interface GRSpecificationSuitesTest : GRMustachePublicAPITest
@end

@implementation GRSpecificationSuitesTest

- (void)testSpecificationSuites
{
    [self runTestsFromResource:@"comments.json" subdirectory:@"specs"];
    [self runTestsFromResource:@"delimiters.json" subdirectory:@"specs"];
    [self runTestsFromResource:@"interpolation.json" subdirectory:@"specs"];
    [self runTestsFromResource:@"inverted.json" subdirectory:@"specs"];
    [self runTestsFromResource:@"partials.json" subdirectory:@"specs"];
    [self runTestsFromResource:@"sections.json" subdirectory:@"specs"];
}

- (void)runTestsFromResource:(NSString *)name subdirectory:(NSString *)subpath
{
    NSBundle *testBundle = [NSBundle bundleForClass:[self class]];
    NSString *path = [[testBundle pathForResource:subpath ofType:nil] stringByAppendingPathComponent:name];
    
    NSError *error;
    NSData *testSuiteData = [NSData dataWithContentsOfFile:path];
    XCTAssertNotNil(testSuiteData, @"Could not load test suite at %@", path);
    if (!testSuiteData) return;
    
    NSDictionary *testSuite = [NSJSONSerialization JSONObjectWithData:testSuiteData options:0 error:&error];
    XCTAssertNotNil(testSuite, @"Could not load test suite at %@: %@", path, error);
    if (!testSuite) return;
    
    NSArray *tests = [testSuite objectForKey:@"tests"];
    XCTAssertTrue((tests.count > 0), @"Empty test suite at %@", path);
    
    for (NSDictionary *test in tests) {
        id data = [test objectForKey:@"data"];
        NSString *templateString = [test objectForKey:@"template"];
        NSDictionary *partialsDictionary = [test objectForKey:@"partials"];
        NSString *expected = [test objectForKey:@"expected"];
        
        GRMustacheTemplateRepository *repository = [GRMustacheTemplateRepository templateRepositoryWithDictionary:partialsDictionary];
        GRMustacheTemplate *template = [repository templateFromString:templateString error:NULL];
        NSString *rendering = [template renderObject:data error:NULL];
        
        // GRMustache doesn't care about white space rules of the Mustache specification.
        // Compare rendering and expected rendering, but ignoring white space.
        NSCharacterSet *w = [NSCharacterSet whitespaceAndNewlineCharacterSet];
        rendering = [[rendering componentsSeparatedByCharactersInSet:w] componentsJoinedByString:@""];
        expected = [[expected componentsSeparatedByCharactersInSet:w] componentsJoinedByString:@""];
        XCTAssertEqualObjects(rendering, expected, @"Failed specification test in suite %@: %@", path, test);
    }
}
     
@end
