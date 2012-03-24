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

#import "GRMustacheTemplateRepositoryWithBaseURLTest.h"

@implementation GRMustacheTemplateRepositoryWithBaseURLTest

//+ (id)templateRepositoryWithBaseURL:(NSURL *)URL AVAILABLE_GRMUSTACHE_VERSION_1_13_AND_LATER;
//+ (id)templateRepositoryWithBaseURL:(NSURL *)URL options:(GRMustacheTemplateOptions)options AVAILABLE_GRMUSTACHE_VERSION_1_13_AND_LATER;
//+ (id)templateRepositoryWithBaseURL:(NSURL *)URL templateExtension:(NSString *)ext AVAILABLE_GRMUSTACHE_VERSION_1_13_AND_LATER;
//+ (id)templateRepositoryWithBaseURL:(NSURL *)URL templateExtension:(NSString *)ext options:(GRMustacheTemplateOptions)options AVAILABLE_GRMUSTACHE_VERSION_1_13_AND_LATER;
//+ (id)templateRepositoryWithBaseURL:(NSURL *)URL templateExtension:(NSString *)ext AVAILABLE_GRMUSTACHE_VERSION_1_13_AND_LATER;
//+ (id)templateRepositoryWithBaseURL:(NSURL *)URL templateExtension:(NSString *)ext encoding:(NSStringEncoding)encoding AVAILABLE_GRMUSTACHE_VERSION_1_13_AND_LATER;
//+ (id)templateRepositoryWithBaseURL:(NSURL *)URL templateExtension:(NSString *)ext encoding:(NSStringEncoding)encoding options:(GRMustacheTemplateOptions)options AVAILABLE_GRMUSTACHE_VERSION_1_13_AND_LATER;

- (void)testTemplateRepositoryWithBaseURL
{
    NSURL *URL;
    GRMustacheTemplateRepository *repository;
    GRMustacheTemplate *template;
    NSString *result;
    
    URL = [self.testBundle URLForResource:@"deep_partials" withExtension:nil];
    repository = [GRMustacheTemplateRepository templateRepositoryWithBaseURL:URL];
    template = [repository templateForName:@"file1" error:NULL];
    result = [template render];
    STAssertEqualObjects(result, @"file1.mustache\ndir/file1.mustache\ndir/dir/file1.mustache\ndir/dir/file2.mustache\n\n\ndir/file2.mustache\n\n\nfile2.mustache\n\n", @"");
}

- (void)testTemplateRepositoryWithBaseURL_templateExtension
{
    NSURL *URL;
    GRMustacheTemplateRepository *repository;
    GRMustacheTemplate *template;
    NSString *result;
    
    URL = [self.testBundle URLForResource:@"deep_partials" withExtension:nil];
    repository = [GRMustacheTemplateRepository templateRepositoryWithBaseURL:URL templateExtension:@"mustache"];
    template = [repository templateForName:@"file1" error:NULL];
    result = [template render];
    STAssertEqualObjects(result, @"file1.mustache\ndir/file1.mustache\ndir/dir/file1.mustache\ndir/dir/file2.mustache\n\n\ndir/file2.mustache\n\n\nfile2.mustache\n\n", @"");
    
    URL = [self.testBundle URLForResource:@"deep_partials" withExtension:nil];
    repository = [GRMustacheTemplateRepository templateRepositoryWithBaseURL:URL templateExtension:@"txt"];
    template = [repository templateForName:@"file1" error:NULL];
    result = [template render];
    STAssertEqualObjects(result, @"file1.txt\ndir/file1.txt\ndir/dir/file1.txt\ndir/dir/file2.txt\n\n\ndir/file2.txt\n\n\nfile2.txt\n\n", @"");
    
    URL = [self.testBundle URLForResource:@"deep_partials" withExtension:nil];
    repository = [GRMustacheTemplateRepository templateRepositoryWithBaseURL:URL templateExtension:@""];
    template = [repository templateForName:@"file1" error:NULL];
    result = [template render];
    STAssertEqualObjects(result, @"file1\ndir/file1\ndir/dir/file1\ndir/dir/file2\n\n\ndir/file2\n\n\nfile2\n\n", @"");
    
    URL = [self.testBundle URLForResource:@"deep_partials" withExtension:nil];
    repository = [GRMustacheTemplateRepository templateRepositoryWithBaseURL:URL templateExtension:nil];
    template = [repository templateForName:@"file1" error:NULL];
    result = [template render];
    STAssertEqualObjects(result, @"file1\ndir/file1\ndir/dir/file1\ndir/dir/file2\n\n\ndir/file2\n\n\nfile2\n\n", @"");
}

- (void)testTemplateRepositoryWithBaseURL_templateExtension_encoding
{
    NSURL *URL;
    GRMustacheTemplateRepository *repository;
    GRMustacheTemplate *template;
    NSString *result;
    
    URL = [self.testBundle URLForResource:@"deep_partials_UTF8" withExtension:nil];
    repository = [GRMustacheTemplateRepository templateRepositoryWithBaseURL:URL templateExtension:@"mustache" encoding:NSUTF8StringEncoding];
    template = [repository templateForName:@"file1" error:NULL];
    result = [template render];
    STAssertEqualObjects(result, @"é1.mustache\ndir/é1.mustache\ndir/dir/é1.mustache\ndir/dir/é2.mustache\n\n\ndir/é2.mustache\n\n\né2.mustache\n\n", @"");
    
    URL = [self.testBundle URLForResource:@"deep_partials_UTF8" withExtension:nil];
    repository = [GRMustacheTemplateRepository templateRepositoryWithBaseURL:URL templateExtension:@"txt" encoding:NSUTF8StringEncoding];
    template = [repository templateForName:@"file1" error:NULL];
    result = [template render];
    STAssertEqualObjects(result, @"é1.txt\ndir/é1.txt\ndir/dir/é1.txt\ndir/dir/é2.txt\n\n\ndir/é2.txt\n\n\né2.txt\n\n", @"");
    
    URL = [self.testBundle URLForResource:@"deep_partials_UTF8" withExtension:nil];
    repository = [GRMustacheTemplateRepository templateRepositoryWithBaseURL:URL templateExtension:@"" encoding:NSUTF8StringEncoding];
    template = [repository templateForName:@"file1" error:NULL];
    result = [template render];
    STAssertEqualObjects(result, @"é1\ndir/é1\ndir/dir/é1\ndir/dir/é2\n\n\ndir/é2\n\n\né2\n\n", @"");
    
    URL = [self.testBundle URLForResource:@"deep_partials_UTF8" withExtension:nil];
    repository = [GRMustacheTemplateRepository templateRepositoryWithBaseURL:URL templateExtension:nil encoding:NSUTF8StringEncoding];
    template = [repository templateForName:@"file1" error:NULL];
    result = [template render];
    STAssertEqualObjects(result, @"é1\ndir/é1\ndir/dir/é1\ndir/dir/é2\n\n\ndir/é2\n\n\né2\n\n", @"");
    
    URL = [self.testBundle URLForResource:@"deep_partials_ISOLatin1" withExtension:nil];
    repository = [GRMustacheTemplateRepository templateRepositoryWithBaseURL:URL templateExtension:@"mustache" encoding:NSISOLatin1StringEncoding];
    template = [repository templateForName:@"file1" error:NULL];
    result = [template render];
    STAssertEqualObjects(result, @"é1.mustache\ndir/é1.mustache\ndir/dir/é1.mustache\ndir/dir/é2.mustache\n\n\ndir/é2.mustache\n\n\né2.mustache\n\n", @"");
    
    URL = [self.testBundle URLForResource:@"deep_partials_ISOLatin1" withExtension:nil];
    repository = [GRMustacheTemplateRepository templateRepositoryWithBaseURL:URL templateExtension:@"txt" encoding:NSISOLatin1StringEncoding];
    template = [repository templateForName:@"file1" error:NULL];
    result = [template render];
    STAssertEqualObjects(result, @"é1.txt\ndir/é1.txt\ndir/dir/é1.txt\ndir/dir/é2.txt\n\n\ndir/é2.txt\n\n\né2.txt\n\n", @"");
    
    URL = [self.testBundle URLForResource:@"deep_partials_ISOLatin1" withExtension:nil];
    repository = [GRMustacheTemplateRepository templateRepositoryWithBaseURL:URL templateExtension:@"" encoding:NSISOLatin1StringEncoding];
    template = [repository templateForName:@"file1" error:NULL];
    result = [template render];
    STAssertEqualObjects(result, @"é1\ndir/é1\ndir/dir/é1\ndir/dir/é2\n\n\ndir/é2\n\n\né2\n\n", @"");
    
    URL = [self.testBundle URLForResource:@"deep_partials_ISOLatin1" withExtension:nil];
    repository = [GRMustacheTemplateRepository templateRepositoryWithBaseURL:URL templateExtension:nil encoding:NSISOLatin1StringEncoding];
    template = [repository templateForName:@"file1" error:NULL];
    result = [template render];
    STAssertEqualObjects(result, @"é1\ndir/é1\ndir/dir/é1\ndir/dir/é2\n\n\ndir/é2\n\n\né2\n\n", @"");
}

@end
