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

#import "GRMustacheTemplateRepositoryWithDirectoryTest.h"

@implementation GRMustacheTemplateRepositoryWithDirectoryTest

- (void)testTemplateRepositoryWithDirectory
{
    NSString *directoryPath;
    GRMustacheTemplateRepository *repository;
    GRMustacheTemplate *template;
    NSString *result;
    
    directoryPath = [self.testBundle pathForResource:@"deep_partials" ofType:nil];
    repository = [GRMustacheTemplateRepository templateRepositoryWithDirectory:directoryPath];
    template = [repository templateForName:@"file1" error:NULL];
    result = [template render];
    STAssertEqualObjects(result, @"file1.mustache\ndir/file1.mustache\ndir/dir/file1.mustache\ndir/dir/file2.mustache\n\n\ndir/file2.mustache\n\n\nfile2.mustache\n\n", @"");
}

- (void)testTemplateRepositoryWithDirectory_templateExtension
{
    NSString *directoryPath;
    GRMustacheTemplateRepository *repository;
    GRMustacheTemplate *template;
    NSString *result;
    
    directoryPath = [self.testBundle pathForResource:@"deep_partials" ofType:nil];
    repository = [GRMustacheTemplateRepository templateRepositoryWithDirectory:directoryPath templateExtension:@"mustache"];
    template = [repository templateForName:@"file1" error:NULL];
    result = [template render];
    STAssertEqualObjects(result, @"file1.mustache\ndir/file1.mustache\ndir/dir/file1.mustache\ndir/dir/file2.mustache\n\n\ndir/file2.mustache\n\n\nfile2.mustache\n\n", @"");
    
    directoryPath = [self.testBundle pathForResource:@"deep_partials" ofType:nil];
    repository = [GRMustacheTemplateRepository templateRepositoryWithDirectory:directoryPath templateExtension:@"txt"];
    template = [repository templateForName:@"file1" error:NULL];
    result = [template render];
    STAssertEqualObjects(result, @"file1.txt\ndir/file1.txt\ndir/dir/file1.txt\ndir/dir/file2.txt\n\n\ndir/file2.txt\n\n\nfile2.txt\n\n", @"");
    
    directoryPath = [self.testBundle pathForResource:@"deep_partials" ofType:nil];
    repository = [GRMustacheTemplateRepository templateRepositoryWithDirectory:directoryPath templateExtension:@""];
    template = [repository templateForName:@"file1" error:NULL];
    result = [template render];
    STAssertEqualObjects(result, @"file1\ndir/file1\ndir/dir/file1\ndir/dir/file2\n\n\ndir/file2\n\n\nfile2\n\n", @"");
    
    directoryPath = [self.testBundle pathForResource:@"deep_partials" ofType:nil];
    repository = [GRMustacheTemplateRepository templateRepositoryWithDirectory:directoryPath templateExtension:nil];
    template = [repository templateForName:@"file1" error:NULL];
    result = [template render];
    STAssertEqualObjects(result, @"file1\ndir/file1\ndir/dir/file1\ndir/dir/file2\n\n\ndir/file2\n\n\nfile2\n\n", @"");
}

- (void)testTemplateRepositoryWithDirectory_templateExtension_encoding
{
    NSString *directoryPath;
    GRMustacheTemplateRepository *repository;
    GRMustacheTemplate *template;
    NSString *result;
    
    directoryPath = [self.testBundle pathForResource:@"deep_partials_UTF8" ofType:nil];
    repository = [GRMustacheTemplateRepository templateRepositoryWithDirectory:directoryPath templateExtension:@"mustache" encoding:NSUTF8StringEncoding];
    template = [repository templateForName:@"file1" error:NULL];
    result = [template render];
    STAssertEqualObjects(result, @"é1.mustache\ndir/é1.mustache\ndir/dir/é1.mustache\ndir/dir/é2.mustache\n\n\ndir/é2.mustache\n\n\né2.mustache\n\n", @"");
    
    directoryPath = [self.testBundle pathForResource:@"deep_partials_UTF8" ofType:nil];
    repository = [GRMustacheTemplateRepository templateRepositoryWithDirectory:directoryPath templateExtension:@"txt" encoding:NSUTF8StringEncoding];
    template = [repository templateForName:@"file1" error:NULL];
    result = [template render];
    STAssertEqualObjects(result, @"é1.txt\ndir/é1.txt\ndir/dir/é1.txt\ndir/dir/é2.txt\n\n\ndir/é2.txt\n\n\né2.txt\n\n", @"");
    
    directoryPath = [self.testBundle pathForResource:@"deep_partials_UTF8" ofType:nil];
    repository = [GRMustacheTemplateRepository templateRepositoryWithDirectory:directoryPath templateExtension:@"" encoding:NSUTF8StringEncoding];
    template = [repository templateForName:@"file1" error:NULL];
    result = [template render];
    STAssertEqualObjects(result, @"é1\ndir/é1\ndir/dir/é1\ndir/dir/é2\n\n\ndir/é2\n\n\né2\n\n", @"");
    
    directoryPath = [self.testBundle pathForResource:@"deep_partials_UTF8" ofType:nil];
    repository = [GRMustacheTemplateRepository templateRepositoryWithDirectory:directoryPath templateExtension:nil encoding:NSUTF8StringEncoding];
    template = [repository templateForName:@"file1" error:NULL];
    result = [template render];
    STAssertEqualObjects(result, @"é1\ndir/é1\ndir/dir/é1\ndir/dir/é2\n\n\ndir/é2\n\n\né2\n\n", @"");
    
    directoryPath = [self.testBundle pathForResource:@"deep_partials_ISOLatin1" ofType:nil];
    repository = [GRMustacheTemplateRepository templateRepositoryWithDirectory:directoryPath templateExtension:@"mustache" encoding:NSISOLatin1StringEncoding];
    template = [repository templateForName:@"file1" error:NULL];
    result = [template render];
    STAssertEqualObjects(result, @"é1.mustache\ndir/é1.mustache\ndir/dir/é1.mustache\ndir/dir/é2.mustache\n\n\ndir/é2.mustache\n\n\né2.mustache\n\n", @"");
    
    directoryPath = [self.testBundle pathForResource:@"deep_partials_ISOLatin1" ofType:nil];
    repository = [GRMustacheTemplateRepository templateRepositoryWithDirectory:directoryPath templateExtension:@"txt" encoding:NSISOLatin1StringEncoding];
    template = [repository templateForName:@"file1" error:NULL];
    result = [template render];
    STAssertEqualObjects(result, @"é1.txt\ndir/é1.txt\ndir/dir/é1.txt\ndir/dir/é2.txt\n\n\ndir/é2.txt\n\n\né2.txt\n\n", @"");
    
    directoryPath = [self.testBundle pathForResource:@"deep_partials_ISOLatin1" ofType:nil];
    repository = [GRMustacheTemplateRepository templateRepositoryWithDirectory:directoryPath templateExtension:@"" encoding:NSISOLatin1StringEncoding];
    template = [repository templateForName:@"file1" error:NULL];
    result = [template render];
    STAssertEqualObjects(result, @"é1\ndir/é1\ndir/dir/é1\ndir/dir/é2\n\n\ndir/é2\n\n\né2\n\n", @"");
    
    directoryPath = [self.testBundle pathForResource:@"deep_partials_ISOLatin1" ofType:nil];
    repository = [GRMustacheTemplateRepository templateRepositoryWithDirectory:directoryPath templateExtension:nil encoding:NSISOLatin1StringEncoding];
    template = [repository templateForName:@"file1" error:NULL];
    result = [template render];
    STAssertEqualObjects(result, @"é1\ndir/é1\ndir/dir/é1\ndir/dir/é2\n\n\ndir/é2\n\n\né2\n\n", @"");
}

@end
