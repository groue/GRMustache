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

@interface GRMustacheTemplateRepositoryWithBaseURL_Test : GRMustachePublicAPITest
@end

@implementation GRMustacheTemplateRepositoryWithBaseURL_Test

- (void)testTemplateRepositoryWithBaseURL
{
    NSURL *URL;
    GRMustacheTemplateRepository *repository;
    GRMustacheTemplate *template;
    NSString *result;
    NSError *error;
    
    URL = [self.testBundle URLForResource:@"GRMustacheTemplateRepositoryTest_UTF8" withExtension:nil];
    repository = [GRMustacheTemplateRepository templateRepositoryWithBaseURL:URL];
    
    template = [repository templateNamed:@"notFound" error:&error];
    STAssertNil(template, @"");
    STAssertNotNil(error, @"");
    
    template = [repository templateNamed:@"file1" error:NULL];
    result = [template renderObject:nil error:NULL];
    STAssertEqualObjects(result, @"é1.mustache\ndir/é1.mustache\ndir/dir/é1.mustache\ndir/dir/é2.mustache\n\n\ndir/é2.mustache\n\n\né2.mustache\n\n", @"");

    template = [repository templateFromString:@"{{>file1}}" error:NULL];
    result = [template renderObject:nil error:NULL];
    STAssertEqualObjects(result, @"é1.mustache\ndir/é1.mustache\ndir/dir/é1.mustache\ndir/dir/é2.mustache\n\n\ndir/é2.mustache\n\n\né2.mustache\n\n", @"");
    
    template = [repository templateFromString:@"{{>dir/file1}}" error:NULL];
    result = [template renderObject:nil error:NULL];
    STAssertEqualObjects(result, @"dir/é1.mustache\ndir/dir/é1.mustache\ndir/dir/é2.mustache\n\n\ndir/é2.mustache\n\n", @"");
    
    template = [repository templateFromString:@"{{>dir/dir/file1}}" error:NULL];
    result = [template renderObject:nil error:NULL];
    STAssertEqualObjects(result, @"dir/dir/é1.mustache\ndir/dir/é2.mustache\n\n", @"");
}

- (void)testTemplateRepositoryWithBaseURL_templateExtension_encoding
{
    NSURL *URL;
    GRMustacheTemplateRepository *repository;
    GRMustacheTemplate *template;
    NSString *result;
    
    URL = [self.testBundle URLForResource:@"GRMustacheTemplateRepositoryTest_UTF8" withExtension:nil];
    repository = [GRMustacheTemplateRepository templateRepositoryWithBaseURL:URL templateExtension:@"mustache" encoding:NSUTF8StringEncoding];
    template = [repository templateNamed:@"file1" error:NULL];
    result = [template renderObject:nil error:NULL];
    STAssertEqualObjects(result, @"é1.mustache\ndir/é1.mustache\ndir/dir/é1.mustache\ndir/dir/é2.mustache\n\n\ndir/é2.mustache\n\n\né2.mustache\n\n", @"");
    
    URL = [self.testBundle URLForResource:@"GRMustacheTemplateRepositoryTest_UTF8" withExtension:nil];
    repository = [GRMustacheTemplateRepository templateRepositoryWithBaseURL:URL templateExtension:@"txt" encoding:NSUTF8StringEncoding];
    template = [repository templateNamed:@"file1" error:NULL];
    result = [template renderObject:nil error:NULL];
    STAssertEqualObjects(result, @"é1.txt\ndir/é1.txt\ndir/dir/é1.txt\ndir/dir/é2.txt\n\n\ndir/é2.txt\n\n\né2.txt\n\n", @"");
    
    URL = [self.testBundle URLForResource:@"GRMustacheTemplateRepositoryTest_UTF8" withExtension:nil];
    repository = [GRMustacheTemplateRepository templateRepositoryWithBaseURL:URL templateExtension:@"" encoding:NSUTF8StringEncoding];
    template = [repository templateNamed:@"file1" error:NULL];
    result = [template renderObject:nil error:NULL];
    STAssertEqualObjects(result, @"é1\ndir/é1\ndir/dir/é1\ndir/dir/é2\n\n\ndir/é2\n\n\né2\n\n", @"");
    
    URL = [self.testBundle URLForResource:@"GRMustacheTemplateRepositoryTest_UTF8" withExtension:nil];
    repository = [GRMustacheTemplateRepository templateRepositoryWithBaseURL:URL templateExtension:nil encoding:NSUTF8StringEncoding];
    template = [repository templateNamed:@"file1" error:NULL];
    result = [template renderObject:nil error:NULL];
    STAssertEqualObjects(result, @"é1\ndir/é1\ndir/dir/é1\ndir/dir/é2\n\n\ndir/é2\n\n\né2\n\n", @"");
    
    URL = [self.testBundle URLForResource:@"GRMustacheTemplateRepositoryTest_ISOLatin1" withExtension:nil];
    repository = [GRMustacheTemplateRepository templateRepositoryWithBaseURL:URL templateExtension:@"mustache" encoding:NSISOLatin1StringEncoding];
    template = [repository templateNamed:@"file1" error:NULL];
    result = [template renderObject:nil error:NULL];
    STAssertEqualObjects(result, @"é1.mustache\ndir/é1.mustache\ndir/dir/é1.mustache\ndir/dir/é2.mustache\n\n\ndir/é2.mustache\n\n\né2.mustache\n\n", @"");
    
    URL = [self.testBundle URLForResource:@"GRMustacheTemplateRepositoryTest_ISOLatin1" withExtension:nil];
    repository = [GRMustacheTemplateRepository templateRepositoryWithBaseURL:URL templateExtension:@"txt" encoding:NSISOLatin1StringEncoding];
    template = [repository templateNamed:@"file1" error:NULL];
    result = [template renderObject:nil error:NULL];
    STAssertEqualObjects(result, @"é1.txt\ndir/é1.txt\ndir/dir/é1.txt\ndir/dir/é2.txt\n\n\ndir/é2.txt\n\n\né2.txt\n\n", @"");
    
    URL = [self.testBundle URLForResource:@"GRMustacheTemplateRepositoryTest_ISOLatin1" withExtension:nil];
    repository = [GRMustacheTemplateRepository templateRepositoryWithBaseURL:URL templateExtension:@"" encoding:NSISOLatin1StringEncoding];
    template = [repository templateNamed:@"file1" error:NULL];
    result = [template renderObject:nil error:NULL];
    STAssertEqualObjects(result, @"é1\ndir/é1\ndir/dir/é1\ndir/dir/é2\n\n\ndir/é2\n\n\né2\n\n", @"");
    
    URL = [self.testBundle URLForResource:@"GRMustacheTemplateRepositoryTest_ISOLatin1" withExtension:nil];
    repository = [GRMustacheTemplateRepository templateRepositoryWithBaseURL:URL templateExtension:nil encoding:NSISOLatin1StringEncoding];
    template = [repository templateNamed:@"file1" error:NULL];
    result = [template renderObject:nil error:NULL];
    STAssertEqualObjects(result, @"é1\ndir/é1\ndir/dir/é1\ndir/dir/é2\n\n\ndir/é2\n\n\né2\n\n", @"");
}

- (void)testAbsolutePartialName
{
    NSURL *URL = [self.testBundle URLForResource:@"GRMustacheTemplateRepositoryTest" withExtension:nil];
    GRMustacheTemplateRepository *repository = [GRMustacheTemplateRepository templateRepositoryWithBaseURL:URL];
    GRMustacheTemplate *template = [repository templateNamed:@"base" error:NULL];
    NSString *rendering = [template renderObject:nil error:NULL];
    
    STAssertEqualObjects(rendering, @"success", @"");
}

@end
