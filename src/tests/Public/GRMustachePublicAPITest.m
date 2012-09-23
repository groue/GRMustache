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

#import "GRMustachePublicAPITest.h"
#import "JSONKit.h"


@implementation GRMustachePublicAPITest

- (void)enumerateTestsFromResource:(NSString *)name subdirectory:(NSString *)subpath usingBlock:(void(^)(NSDictionary *test, NSString *path))block
{
    NSString *path = [[self.testBundle pathForResource:subpath ofType:nil] stringByAppendingPathComponent:name];
    
    NSError *error;
    NSData *testSuiteData = [NSData dataWithContentsOfFile:path];
    STAssertNotNil(testSuiteData, @"Could not load test suite at %@", path);
    if (!testSuiteData) return;
    
    NSDictionary *testSuite = [testSuiteData objectFromJSONDataWithParseOptions:JKParseOptionComments error:&error];
    STAssertNotNil(testSuite, @"Could not load test suite at %@: %@", path, error);
    if (!testSuite) return;
    
    NSArray *tests = [testSuite objectForKey:@"tests"];
    STAssertTrue((tests.count > 0), @"Empty test suite at %@", path);
    
    for (NSDictionary *test in tests) {
        block(test, path);
    }
}

@end
