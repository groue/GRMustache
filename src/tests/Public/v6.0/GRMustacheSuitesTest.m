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

@interface GRMustacheSuitesTest : GRMustachePublicAPISuiteTest
@end

@implementation GRMustacheSuitesTest

- (void)testGRMustacheSuites
{
    [self runTestsFromResource:@"comments.json" subdirectory:@"GRMustacheSuites"];
    [self runTestsFromResource:@"compound_keys.json" subdirectory:@"GRMustacheSuites"];
    [self runTestsFromResource:@"delimiters.json" subdirectory:@"GRMustacheSuites"];
    [self runTestsFromResource:@"filters.json" subdirectory:@"GRMustacheSuites"];
    [self runTestsFromResource:@"standard_library.json" subdirectory:@"GRMustacheSuites"];
    [self runTestsFromResource:@"general.json" subdirectory:@"GRMustacheSuites"];
    [self runTestsFromResource:@"implicit_iterator.json" subdirectory:@"GRMustacheSuites"];
    [self runTestsFromResource:@"inverted_sections.json" subdirectory:@"GRMustacheSuites"];
    [self runTestsFromResource:@"overridable_partials.json" subdirectory:@"GRMustacheSuites"];
    [self runTestsFromResource:@"overridable_sections.json" subdirectory:@"GRMustacheSuites"];
    [self runTestsFromResource:@"partials.json" subdirectory:@"GRMustacheSuites"];
    [self runTestsFromResource:@"sections.json" subdirectory:@"GRMustacheSuites"];
    [self runTestsFromResource:@"variables.json" subdirectory:@"GRMustacheSuites"];
    [self runTestsFromResource:@"pragmas.json" subdirectory:@"GRMustacheSuites"];
    [self runTestsFromResource:@"text_rendering.json" subdirectory:@"GRMustacheSuites"];
    [self runTestsFromResource:@"tag_parsing_errors.json" subdirectory:@"GRMustacheSuites"];
    [self runTestsFromResource:@"expression_parsing_errors.json" subdirectory:@"GRMustacheSuites"];
}

@end
