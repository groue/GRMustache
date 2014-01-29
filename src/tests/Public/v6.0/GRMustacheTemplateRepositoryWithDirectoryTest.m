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

@interface GRMustacheTemplateRepositoryWithDirectory_Test : GRMustachePublicAPITest
@end

@implementation GRMustacheTemplateRepositoryWithDirectory_Test

- (void)testTemplateRepositoryWithDirectory
{
    NSString *directoryPath;
    GRMustacheTemplateRepository *repository;
    GRMustacheTemplate *template;
    NSString *result;
    NSError *error;
    
    directoryPath = [self.testBundle pathForResource:@"GRMustacheTemplateRepositoryTest_UTF8" ofType:nil];
    repository = [GRMustacheTemplateRepository templateRepositoryWithDirectory:directoryPath];
    
    template = [repository templateNamed:@"notFound" error:&error];
    STAssertNil(template, @"");
    STAssertNotNil(error, @"");
    
    template = [repository templateNamed:@"file1" error:NULL];
    result = [template renderObject:nil error:NULL];
    STAssertEqualObjects(result, @"é1.mustache\ndir/é1.mustache\ndir/dir/é1.mustache\ndir/dir/é2.mustache\n\n\ndir/é2.mustache\n\n\né2.mustache\n\n", @"");

    template = [repository templateFromString:@"{{>dir/file1}}" error:NULL];
    result = [template renderObject:nil error:NULL];
    STAssertEqualObjects(result, @"dir/é1.mustache\ndir/dir/é1.mustache\ndir/dir/é2.mustache\n\n\ndir/é2.mustache\n\n", @"");
    
    template = [repository templateFromString:@"{{>dir/dir/file1}}" error:NULL];
    result = [template renderObject:nil error:NULL];
    STAssertEqualObjects(result, @"dir/dir/é1.mustache\ndir/dir/é2.mustache\n\n", @"");
}

- (void)testTemplateRepositoryWithDirectory_templateExtension_encoding
{
    NSString *directoryPath;
    GRMustacheTemplateRepository *repository;
    GRMustacheTemplate *template;
    NSString *result;
    
    directoryPath = [self.testBundle pathForResource:@"GRMustacheTemplateRepositoryTest_UTF8" ofType:nil];
    repository = [GRMustacheTemplateRepository templateRepositoryWithDirectory:directoryPath templateExtension:@"mustache" encoding:NSUTF8StringEncoding];
    template = [repository templateNamed:@"file1" error:NULL];
    result = [template renderObject:nil error:NULL];
    STAssertEqualObjects(result, @"é1.mustache\ndir/é1.mustache\ndir/dir/é1.mustache\ndir/dir/é2.mustache\n\n\ndir/é2.mustache\n\n\né2.mustache\n\n", @"");
    
    directoryPath = [self.testBundle pathForResource:@"GRMustacheTemplateRepositoryTest_UTF8" ofType:nil];
    repository = [GRMustacheTemplateRepository templateRepositoryWithDirectory:directoryPath templateExtension:@"txt" encoding:NSUTF8StringEncoding];
    template = [repository templateNamed:@"file1" error:NULL];
    result = [template renderObject:nil error:NULL];
    STAssertEqualObjects(result, @"é1.txt\ndir/é1.txt\ndir/dir/é1.txt\ndir/dir/é2.txt\n\n\ndir/é2.txt\n\n\né2.txt\n\n", @"");
    
    directoryPath = [self.testBundle pathForResource:@"GRMustacheTemplateRepositoryTest_UTF8" ofType:nil];
    repository = [GRMustacheTemplateRepository templateRepositoryWithDirectory:directoryPath templateExtension:@"" encoding:NSUTF8StringEncoding];
    template = [repository templateNamed:@"file1" error:NULL];
    result = [template renderObject:nil error:NULL];
    STAssertEqualObjects(result, @"é1\ndir/é1\ndir/dir/é1\ndir/dir/é2\n\n\ndir/é2\n\n\né2\n\n", @"");
    
    directoryPath = [self.testBundle pathForResource:@"GRMustacheTemplateRepositoryTest_UTF8" ofType:nil];
    repository = [GRMustacheTemplateRepository templateRepositoryWithDirectory:directoryPath templateExtension:nil encoding:NSUTF8StringEncoding];
    template = [repository templateNamed:@"file1" error:NULL];
    result = [template renderObject:nil error:NULL];
    STAssertEqualObjects(result, @"é1\ndir/é1\ndir/dir/é1\ndir/dir/é2\n\n\ndir/é2\n\n\né2\n\n", @"");
    
    directoryPath = [self.testBundle pathForResource:@"GRMustacheTemplateRepositoryTest_ISOLatin1" ofType:nil];
    repository = [GRMustacheTemplateRepository templateRepositoryWithDirectory:directoryPath templateExtension:@"mustache" encoding:NSISOLatin1StringEncoding];
    template = [repository templateNamed:@"file1" error:NULL];
    result = [template renderObject:nil error:NULL];
    STAssertEqualObjects(result, @"é1.mustache\ndir/é1.mustache\ndir/dir/é1.mustache\ndir/dir/é2.mustache\n\n\ndir/é2.mustache\n\n\né2.mustache\n\n", @"");
    
    directoryPath = [self.testBundle pathForResource:@"GRMustacheTemplateRepositoryTest_ISOLatin1" ofType:nil];
    repository = [GRMustacheTemplateRepository templateRepositoryWithDirectory:directoryPath templateExtension:@"txt" encoding:NSISOLatin1StringEncoding];
    template = [repository templateNamed:@"file1" error:NULL];
    result = [template renderObject:nil error:NULL];
    STAssertEqualObjects(result, @"é1.txt\ndir/é1.txt\ndir/dir/é1.txt\ndir/dir/é2.txt\n\n\ndir/é2.txt\n\n\né2.txt\n\n", @"");
    
    directoryPath = [self.testBundle pathForResource:@"GRMustacheTemplateRepositoryTest_ISOLatin1" ofType:nil];
    repository = [GRMustacheTemplateRepository templateRepositoryWithDirectory:directoryPath templateExtension:@"" encoding:NSISOLatin1StringEncoding];
    template = [repository templateNamed:@"file1" error:NULL];
    result = [template renderObject:nil error:NULL];
    STAssertEqualObjects(result, @"é1\ndir/é1\ndir/dir/é1\ndir/dir/é2\n\n\ndir/é2\n\n\né2\n\n", @"");
    
    directoryPath = [self.testBundle pathForResource:@"GRMustacheTemplateRepositoryTest_ISOLatin1" ofType:nil];
    repository = [GRMustacheTemplateRepository templateRepositoryWithDirectory:directoryPath templateExtension:nil encoding:NSISOLatin1StringEncoding];
    template = [repository templateNamed:@"file1" error:NULL];
    result = [template renderObject:nil error:NULL];
    STAssertEqualObjects(result, @"é1\ndir/é1\ndir/dir/é1\ndir/dir/é2\n\n\ndir/é2\n\n\né2\n\n", @"");
}

- (void)testAbsolutePartialName
{
    NSString *directoryPath = [self.testBundle pathForResource:@"GRMustacheTemplateRepositoryTest" ofType:nil];
    GRMustacheTemplateRepository *repository = [GRMustacheTemplateRepository templateRepositoryWithDirectory:directoryPath];
    GRMustacheTemplate *template = [repository templateNamed:@"base" error:NULL];
    NSString *rendering = [template renderObject:nil error:NULL];
    
    STAssertEqualObjects(rendering, @"success", @"");
}

@end
