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

@interface GRMustacheTemplateRepositoryWithBundleTest : GRMustachePublicAPITest
@end

@implementation GRMustacheTemplateRepositoryWithBundleTest

- (void)testTemplateRepositoryWithBundle
{
    NSError *error;
    GRMustacheTemplateRepository *repository = [GRMustacheTemplateRepository templateRepositoryWithBundle:self.testBundle];
    
    {
        GRMustacheTemplate *template = [repository templateNamed:@"notFound" error:&error];
        STAssertNil(template, @"");
        STAssertNotNil(error, @"");
    }
    {
        GRMustacheTemplate *template = [repository templateNamed:@"GRMustacheTemplateRepositoryWithBundleTest" error:NULL];
        NSString *result = [template renderObject:nil error:NULL];
        STAssertEqualObjects(result, @"GRMustacheTemplateRepositoryWithBundleTest.mustache GRMustacheTemplateRepositoryWithBundleTest_partial.mustache", @"");
    }
    {
        GRMustacheTemplate *template = [repository templateFromString:@"{{>GRMustacheTemplateRepositoryWithBundleTest}}" error:NULL];
        NSString *result = [template renderObject:nil error:NULL];
        STAssertEqualObjects(result, @"GRMustacheTemplateRepositoryWithBundleTest.mustache GRMustacheTemplateRepositoryWithBundleTest_partial.mustache", @"");
    }
}

- (void)testTemplateRepositoryWithBundle_templateExtension_encoding
{
    NSError *error;
    {
        GRMustacheTemplateRepository *repository = [GRMustacheTemplateRepository templateRepositoryWithBundle:self.testBundle
                                                                                            templateExtension:@"text"
                                                                                                     encoding:NSUTF8StringEncoding];
        {
            GRMustacheTemplate *template = [repository templateNamed:@"notFound" error:&error];
            STAssertNil(template, @"");
            STAssertNotNil(error, @"");
        }
        {
            GRMustacheTemplate *template = [repository templateNamed:@"GRMustacheTemplateRepositoryWithBundleTest" error:NULL];
            NSString *result = [template renderObject:nil error:NULL];
            STAssertEqualObjects(result, @"GRMustacheTemplateRepositoryWithBundleTest.text GRMustacheTemplateRepositoryWithBundleTest_partial.text", @"");
        }
        {
            GRMustacheTemplate *template = [repository templateFromString:@"{{>GRMustacheTemplateRepositoryWithBundleTest}}" error:NULL];
            NSString *result = [template renderObject:nil error:NULL];
            STAssertEqualObjects(result, @"GRMustacheTemplateRepositoryWithBundleTest.text GRMustacheTemplateRepositoryWithBundleTest_partial.text", @"");
        }
    }
    {
        GRMustacheTemplateRepository *repository = [GRMustacheTemplateRepository templateRepositoryWithBundle:self.testBundle
                                                                                            templateExtension:@""
                                                                                                     encoding:NSUTF8StringEncoding];
        {
            GRMustacheTemplate *template = [repository templateNamed:@"notFound" error:&error];
            STAssertNil(template, @"");
            STAssertNotNil(error, @"");
        }
        {
            GRMustacheTemplate *template = [repository templateNamed:@"GRMustacheTemplateRepositoryWithBundleTest" error:NULL];
            NSString *result = [template renderObject:nil error:NULL];
            STAssertEqualObjects(result, @"GRMustacheTemplateRepositoryWithBundleTest GRMustacheTemplateRepositoryWithBundleTest_partial", @"");
        }
        {
            GRMustacheTemplate *template = [repository templateFromString:@"{{>GRMustacheTemplateRepositoryWithBundleTest}}" error:NULL];
            NSString *result = [template renderObject:nil error:NULL];
            STAssertEqualObjects(result, @"GRMustacheTemplateRepositoryWithBundleTest GRMustacheTemplateRepositoryWithBundleTest_partial", @"");
        }
    }
    {
        GRMustacheTemplateRepository *repository = [GRMustacheTemplateRepository templateRepositoryWithBundle:self.testBundle
                                                                                            templateExtension:nil
                                                                                                     encoding:NSUTF8StringEncoding];
        {
            GRMustacheTemplate *template = [repository templateNamed:@"notFound" error:&error];
            STAssertNil(template, @"");
            STAssertNotNil(error, @"");
        }
        {
            GRMustacheTemplate *template = [repository templateNamed:@"GRMustacheTemplateRepositoryWithBundleTest" error:NULL];
            NSString *result = [template renderObject:nil error:NULL];
            STAssertEqualObjects(result, @"GRMustacheTemplateRepositoryWithBundleTest GRMustacheTemplateRepositoryWithBundleTest_partial", @"");
        }
        {
            GRMustacheTemplate *template = [repository templateFromString:@"{{>GRMustacheTemplateRepositoryWithBundleTest}}" error:NULL];
            NSString *result = [template renderObject:nil error:NULL];
            STAssertEqualObjects(result, @"GRMustacheTemplateRepositoryWithBundleTest GRMustacheTemplateRepositoryWithBundleTest_partial", @"");
        }
    }
}

@end
