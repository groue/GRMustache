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

@interface GRMustacheSuitesTest : GRMustachePublicAPISuiteTest
@end

@implementation GRMustacheSuitesTest

- (void)testGRMustacheSuites
{
    // General
    [self runTestsFromResource:@"comments.json" subdirectory:@"Tests/general"];
    [self runTestsFromResource:@"delimiters.json" subdirectory:@"Tests/general"];
    [self runTestsFromResource:@"general.json" subdirectory:@"Tests/general"];
    [self runTestsFromResource:@"partials.json" subdirectory:@"Tests/general"];
    [self runTestsFromResource:@"pragmas.json" subdirectory:@"Tests/general"];
    [self runTestsFromResource:@"sections.json" subdirectory:@"Tests/general"];
    [self runTestsFromResource:@"inverted_sections.json" subdirectory:@"Tests/general"];
    [self runTestsFromResource:@"text_rendering.json" subdirectory:@"Tests/general"];
    [self runTestsFromResource:@"variables.json" subdirectory:@"Tests/general"];
    
    // Errors
    [self runTestsFromResource:@"expression_parsing_errors.json" subdirectory:@"Tests/errors"];
    [self runTestsFromResource:@"tag_parsing_errors.json" subdirectory:@"Tests/errors"];
    
    // Expressions
    [self runTestsFromResource:@"compound_keys.json" subdirectory:@"Tests/expressions"];
    [self runTestsFromResource:@"filters.json" subdirectory:@"Tests/expressions"];
    [self runTestsFromResource:@"implicit_iterator.json" subdirectory:@"Tests/expressions"];
    
    // Inheritance
    [self runTestsFromResource:@"blocks.json" subdirectory:@"Tests/inheritance"];
    [self runTestsFromResource:@"partial_overrides.json" subdirectory:@"Tests/inheritance"];
    
    // Standard library
    [self runTestsFromResource:@"each.json" subdirectory:@"Tests/standard_library"];
    [self runTestsFromResource:@"HTMLEscape.json" subdirectory:@"Tests/standard_library"];
    [self runTestsFromResource:@"javascriptEscape.json" subdirectory:@"Tests/standard_library"];
    [self runTestsFromResource:@"URLEscape.json" subdirectory:@"Tests/standard_library"];
    [self runTestsFromResource:@"zip.json" subdirectory:@"Tests/standard_library"];
    
    // Values
    [self runTestsFromResource:@"array.json" subdirectory:@"Tests/values"];
    [self runTestsFromResource:@"bool.json" subdirectory:@"Tests/values"];
    [self runTestsFromResource:@"dictionary.json" subdirectory:@"Tests/values"];
    [self runTestsFromResource:@"missing_value.json" subdirectory:@"Tests/values"];
    [self runTestsFromResource:@"null.json" subdirectory:@"Tests/values"];
    [self runTestsFromResource:@"number.json" subdirectory:@"Tests/values"];
    [self runTestsFromResource:@"string.json" subdirectory:@"Tests/values"];
}

@end
