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

@interface GRMustacheTemplateRepositoryWithDictionaryTest : GRMustachePublicAPITest
@end

@implementation GRMustacheTemplateRepositoryWithDictionaryTest

- (void)testTemplateRepositoryWithDictionary
{
    GRMustacheTemplate *template;
    NSString *result;
    NSError *error;
    
    NSDictionary *partials = [NSDictionary dictionaryWithObjectsAndKeys:
                              @"A{{>b}}", @"a",
                              @"B{{>c}}", @"b",
                              @"C",       @"c",
                              nil];
    GRMustacheTemplateRepository *repository = [GRMustacheTemplateRepository templateRepositoryWithDictionary:partials];
    
    template = [repository templateNamed:@"not found" error:&error];
    STAssertNil(template, @"");
    STAssertEqualObjects(error.domain, GRMustacheErrorDomain, @"");
    STAssertEquals((NSInteger)error.code, (NSInteger)GRMustacheErrorCodeTemplateNotFound, @"");
    
    template = [repository templateFromString:@"{{>not_found}}" error:&error];
    STAssertNil(template, @"");
    STAssertEqualObjects(error.domain, GRMustacheErrorDomain, @"");
    STAssertEquals((NSInteger)error.code, (NSInteger)GRMustacheErrorCodeTemplateNotFound, @"");
    
    template = [repository templateNamed:@"a" error:&error];
    result = [template renderObject:nil error:NULL];
    STAssertEqualObjects(result, @"ABC", @"");
    
    template = [repository templateFromString:@"{{>a}}" error:&error];
    result = [template renderObject:nil error:NULL];
    STAssertEqualObjects(result, @"ABC", @"");
}

- (void)testTemplateRepositoryWithDictionaryIgnoresDictionaryMutation
{
    NSMutableString *mutableTemplateString = [NSMutableString stringWithString:@"foo"];
    NSMutableDictionary *mutablePartials = [NSMutableDictionary dictionaryWithObjectsAndKeys:mutableTemplateString, @"a", nil];
    GRMustacheTemplateRepository *repository = [GRMustacheTemplateRepository templateRepositoryWithDictionary:mutablePartials];
    
    [mutableTemplateString appendString:@"bar"];
    [mutablePartials setObject:@"bar" forKey:@"b"];
    
    {
        GRMustacheTemplate *template = [repository templateNamed:@"a" error:NULL];
        NSString *rendering = [template renderObject:nil error:NULL];
        STAssertEqualObjects(rendering, @"foo", @"");
    }
    
    {
        NSError *error;
        GRMustacheTemplate *template = [repository templateNamed:@"b" error:&error];
        STAssertNil(template, @"");
        STAssertEqualObjects(error.domain, GRMustacheErrorDomain, @"");
        STAssertEquals((NSInteger)error.code, (NSInteger)GRMustacheErrorCodeTemplateNotFound, @"");
    }
}

@end
