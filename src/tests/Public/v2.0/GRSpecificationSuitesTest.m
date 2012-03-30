// The MIT License
// 
// Copyright (c) 2012 Gwendal Roué
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

#import "GRSpecificationSuitesTest.h"
#import "JSONKit.h"

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
    NSDictionary *testSuite = [[NSData dataWithContentsOfFile:path] objectFromJSONData];
    for (NSDictionary *test in [testSuite objectForKey:@"tests"]) {
        id data = [test objectForKey:@"data"];
        NSString *templateString = [test objectForKey:@"template"];
        NSDictionary *partialsDictionary = [test objectForKey:@"partials"];
        NSString *expected = [test objectForKey:@"expected"];
        
        GRMustacheTemplateRepository *repository = [GRMustacheTemplateRepository templateRepositoryWithPartialsDictionary:partialsDictionary];
        GRMustacheTemplate *template = [repository templateFromString:templateString error:NULL];
        NSString *rendering = [template renderObject:data];
        
        // GRMustache2 doesn't care about white space rules of the Mustache specification.
        // Compare rendering and expected rendering, but ignoring white space.
        NSCharacterSet *w = [NSCharacterSet whitespaceAndNewlineCharacterSet];
        rendering = [[rendering componentsSeparatedByCharactersInSet:w] componentsJoinedByString:@""];
        expected = [[expected componentsSeparatedByCharactersInSet:w] componentsJoinedByString:@""];
        STAssertEqualObjects(rendering, expected, @"Failed specification test in suite %@: %@", path, test);
    }
}
     
@end
