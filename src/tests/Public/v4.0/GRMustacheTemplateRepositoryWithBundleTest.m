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

#define GRMUSTACHE_VERSION_MAX_ALLOWED GRMUSTACHE_VERSION_4_0
#import "GRMustachePublicAPITest.h"

@interface GRMustacheTemplateRepositoryWithBundleTest : GRMustachePublicAPITest
@end

@implementation GRMustacheTemplateRepositoryWithBundleTest

- (void)testTemplateRepositoryWithBundle
{
    NSError *error;
    GRMustacheTemplateRepository *repository = [GRMustacheTemplateRepository templateRepositoryWithBundle:self.testBundle];
    
    {
        GRMustacheTemplate *template = [repository templateForName:@"notFound" error:&error];
        STAssertNil(template, @"");
        STAssertNotNil(error, @"");
    }
    {
        GRMustacheTemplate *template = [repository templateForName:@"GRMustacheTemplateRepositoryWithBundleTest" error:NULL];
        NSString *result = [template render];
        STAssertEqualObjects(result, @"GRMustacheTemplateRepositoryWithBundleTest.mustache GRMustacheTemplateRepositoryWithBundleTest_partial.mustache", @"");
    }
    {
        GRMustacheTemplate *template = [repository templateFromString:@"{{>GRMustacheTemplateRepositoryWithBundleTest}}" error:NULL];
        NSString *result = [template render];
        STAssertEqualObjects(result, @"GRMustacheTemplateRepositoryWithBundleTest.mustache GRMustacheTemplateRepositoryWithBundleTest_partial.mustache", @"");
    }
}

- (void)testTemplateRepositoryWithBundle_templateExtension
{
    NSError *error;
    {
        GRMustacheTemplateRepository *repository = [GRMustacheTemplateRepository templateRepositoryWithBundle:self.testBundle
                                                                                            templateExtension:@"text"];
        {
            GRMustacheTemplate *template = [repository templateForName:@"notFound" error:&error];
            STAssertNil(template, @"");
            STAssertNotNil(error, @"");
        }
        {
            GRMustacheTemplate *template = [repository templateForName:@"GRMustacheTemplateRepositoryWithBundleTest" error:NULL];
            NSString *result = [template render];
            STAssertEqualObjects(result, @"GRMustacheTemplateRepositoryWithBundleTest.text GRMustacheTemplateRepositoryWithBundleTest_partial.text", @"");
        }
        {
            GRMustacheTemplate *template = [repository templateFromString:@"{{>GRMustacheTemplateRepositoryWithBundleTest}}" error:NULL];
            NSString *result = [template render];
            STAssertEqualObjects(result, @"GRMustacheTemplateRepositoryWithBundleTest.text GRMustacheTemplateRepositoryWithBundleTest_partial.text", @"");
        }
    }
    {
        GRMustacheTemplateRepository *repository = [GRMustacheTemplateRepository templateRepositoryWithBundle:self.testBundle
                                                                                            templateExtension:@""];
        {
            GRMustacheTemplate *template = [repository templateForName:@"notFound" error:&error];
            STAssertNil(template, @"");
            STAssertNotNil(error, @"");
        }
        {
            GRMustacheTemplate *template = [repository templateForName:@"GRMustacheTemplateRepositoryWithBundleTest" error:NULL];
            NSString *result = [template render];
            STAssertEqualObjects(result, @"GRMustacheTemplateRepositoryWithBundleTest GRMustacheTemplateRepositoryWithBundleTest_partial", @"");
        }
        {
            GRMustacheTemplate *template = [repository templateFromString:@"{{>GRMustacheTemplateRepositoryWithBundleTest}}" error:NULL];
            NSString *result = [template render];
            STAssertEqualObjects(result, @"GRMustacheTemplateRepositoryWithBundleTest GRMustacheTemplateRepositoryWithBundleTest_partial", @"");
        }
    }
    {
        GRMustacheTemplateRepository *repository = [GRMustacheTemplateRepository templateRepositoryWithBundle:self.testBundle
                                                                                            templateExtension:nil];
        {
            GRMustacheTemplate *template = [repository templateForName:@"notFound" error:&error];
            STAssertNil(template, @"");
            STAssertNotNil(error, @"");
        }
        {
            GRMustacheTemplate *template = [repository templateForName:@"GRMustacheTemplateRepositoryWithBundleTest" error:NULL];
            NSString *result = [template render];
            STAssertEqualObjects(result, @"GRMustacheTemplateRepositoryWithBundleTest GRMustacheTemplateRepositoryWithBundleTest_partial", @"");
        }
        {
            GRMustacheTemplate *template = [repository templateFromString:@"{{>GRMustacheTemplateRepositoryWithBundleTest}}" error:NULL];
            NSString *result = [template render];
            STAssertEqualObjects(result, @"GRMustacheTemplateRepositoryWithBundleTest GRMustacheTemplateRepositoryWithBundleTest_partial", @"");
        }
    }
}

@end
