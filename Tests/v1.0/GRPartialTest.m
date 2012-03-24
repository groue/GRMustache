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

#import "GRPartialTest.h"


@implementation PPartialTest

- (void)testViewPartial
{
    // TODO, but ruby test is unclear about its intent
}

- (void)testPartialWithSlashes
{
    // TODO
}

- (void)testViewPartialInheritsContext
{
    // TODO
}

- (void)testTemplatePartial
{
    NSDictionary *context = [NSDictionary dictionaryWithObject:@"Welcome" forKey:@"title"];
    NSString *result = [self renderObject:context fromResource:@"template_partial"];
    STAssertEqualObjects(result, @"<h1>Welcome</h1>\nAgain, Welcome!", nil);
}

- (void)testPartialWithCustomExtension
{
    NSDictionary *context = [NSDictionary dictionaryWithObjectsAndKeys:
                             @"Welcome", @"title",
                             @"-------", @"title_bars",
                             nil];
    NSString *result = [self renderObject:context fromResource:@"template_partial" withExtension:@"txt"];
    STAssertEqualObjects(result, @"Welcome\n-------\n\n## Again, Welcome! ##\n\n", nil);
}

- (void)testRecursivePartial
{
    NSDictionary *context = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:@"show"];
    NSString *result = [self renderObject:context fromResource:@"recursive"];
    STAssertEqualObjects(result, @"It works!", @"");
}

- (void)testCrazyRecursivePartial
{
    NSDictionary *context = [NSDictionary dictionaryWithObject:[NSArray arrayWithObjects:
                                                                [NSDictionary dictionaryWithObjectsAndKeys:
                                                                 @"1", @"contents",
                                                                 [NSArray arrayWithObjects:
                                                                  [NSDictionary dictionaryWithObjectsAndKeys:
                                                                   @"2", @"contents",
                                                                   [NSArray arrayWithObjects:
                                                                    [NSDictionary dictionaryWithObjectsAndKeys:
                                                                     @"3", @"contents",
                                                                     [NSArray array], @"children",
                                                                     nil],
                                                                    nil], @"children",
                                                                   nil],
                                                                  [NSDictionary dictionaryWithObjectsAndKeys:
                                                                   @"4", @"contents",
                                                                   [NSArray arrayWithObjects:
                                                                    [NSDictionary dictionaryWithObjectsAndKeys:
                                                                     @"5", @"contents",
                                                                     [NSArray arrayWithObjects:
                                                                      [NSDictionary dictionaryWithObjectsAndKeys:
                                                                       @"6", @"contents",
                                                                       [NSArray array], @"children",
                                                                       nil],
                                                                      nil], @"children",
                                                                     nil],
                                                                    nil], @"children",
                                                                   nil],
                                                                  nil], @"children",
                                                                 nil],
                                                                nil]
                                                        forKey:@"top_nodes"];
    NSString *result = [self renderObject:context fromResource:@"crazy_recursive"];
    STAssertEqualObjects(result, @"<html><body><ul><li>1<ul><li>2<ul><li>3<ul></ul></li></ul></li><li>4<ul><li>5<ul><li>6<ul></ul></li></ul></li></ul></li></ul></li></ul></body></html>", @"");
}

- (void)testDeepPartials
{
    NSURL *URL;
    NSString *result;
    
    URL = [self.testBundle URLForResource:@"file1" withExtension:@"mustache" subdirectory:@"deep_partials"];
    result = [GRMustacheTemplate renderObject:nil fromContentsOfURL:URL error:NULL];
    STAssertEqualObjects(result, @"file1.mustache\ndir/file1.mustache\ndir/dir/file1.mustache\ndir/dir/file2.mustache\n\n\ndir/file2.mustache\n\n\nfile2.mustache\n\n", @"");
    
    URL = [self.testBundle URLForResource:@"file1" withExtension:@"txt" subdirectory:@"deep_partials"];
    result = [GRMustacheTemplate renderObject:nil fromContentsOfURL:URL error:NULL];
    STAssertEqualObjects(result, @"file1.txt\ndir/file1.txt\ndir/dir/file1.txt\ndir/dir/file2.txt\n\n\ndir/file2.txt\n\n\nfile2.txt\n\n", @"");
    
    URL = [self.testBundle URLForResource:@"file1" withExtension:@"" subdirectory:@"deep_partials"];
    result = [GRMustacheTemplate renderObject:nil fromContentsOfURL:URL error:NULL];
    STAssertEqualObjects(result, @"file1\ndir/file1\ndir/dir/file1\ndir/dir/file2\n\n\ndir/file2\n\n\nfile2\n\n", @"");
    
    URL = [self.testBundle URLForResource:@"file1" withExtension:nil subdirectory:@"deep_partials"];
    result = [GRMustacheTemplate renderObject:nil fromContentsOfURL:URL error:NULL];
    STAssertEqualObjects(result, @"file1\ndir/file1\ndir/dir/file1\ndir/dir/file2\n\n\ndir/file2\n\n\nfile2\n\n", @"");
}

- (void)testDeepPartialsContainingUTF8Data
{
    NSURL *URL;
    NSString *result;
    
    URL = [self.testBundle URLForResource:@"file1" withExtension:@"mustache" subdirectory:@"deep_partials_UTF8"];
    result = [GRMustacheTemplate renderObject:nil fromContentsOfURL:URL error:NULL];
    STAssertEqualObjects(result, @"é1.mustache\ndir/é1.mustache\ndir/dir/é1.mustache\ndir/dir/é2.mustache\n\n\ndir/é2.mustache\n\n\né2.mustache\n\n", @"");
    
    URL = [self.testBundle URLForResource:@"file1" withExtension:@"txt" subdirectory:@"deep_partials_UTF8"];
    result = [GRMustacheTemplate renderObject:nil fromContentsOfURL:URL error:NULL];
    STAssertEqualObjects(result, @"é1.txt\ndir/é1.txt\ndir/dir/é1.txt\ndir/dir/é2.txt\n\n\ndir/é2.txt\n\n\né2.txt\n\n", @"");
    
    URL = [self.testBundle URLForResource:@"file1" withExtension:@"" subdirectory:@"deep_partials_UTF8"];
    result = [GRMustacheTemplate renderObject:nil fromContentsOfURL:URL error:NULL];
    STAssertEqualObjects(result, @"é1\ndir/é1\ndir/dir/é1\ndir/dir/é2\n\n\ndir/é2\n\n\né2\n\n", @"");
    
    URL = [self.testBundle URLForResource:@"file1" withExtension:nil subdirectory:@"deep_partials_UTF8"];
    result = [GRMustacheTemplate renderObject:nil fromContentsOfURL:URL error:NULL];
    STAssertEqualObjects(result, @"é1\ndir/é1\ndir/dir/é1\ndir/dir/é2\n\n\ndir/é2\n\n\né2\n\n", @"");
}

- (void)testDeepPartialsContainingISOLatin1Data
{
    NSURL *URL = [self.testBundle URLForResource:@"deep_partials_ISOLatin1" withExtension:nil];
    GRMustacheTemplateLoader *loader;
    GRMustacheTemplate *template;
    NSString *result;
    
    loader = [GRMustacheTemplateLoader templateLoaderWithBaseURL:URL extension:nil encoding:NSISOLatin1StringEncoding];
    template = [loader parseTemplateNamed:@"file1" error:NULL];
    result = [template render];
    STAssertEqualObjects(result, @"é1.mustache\ndir/é1.mustache\ndir/dir/é1.mustache\ndir/dir/é2.mustache\n\n\ndir/é2.mustache\n\n\né2.mustache\n\n", @"");
    
    loader = [GRMustacheTemplateLoader templateLoaderWithBaseURL:URL extension:@"txt" encoding:NSISOLatin1StringEncoding];
    template = [loader parseTemplateNamed:@"file1" error:NULL];
    result = [template render];
    STAssertEqualObjects(result, @"é1.txt\ndir/é1.txt\ndir/dir/é1.txt\ndir/dir/é2.txt\n\n\ndir/é2.txt\n\n\né2.txt\n\n", @"");
    
    loader = [GRMustacheTemplateLoader templateLoaderWithBaseURL:URL extension:@"" encoding:NSISOLatin1StringEncoding];
    template = [loader parseTemplateNamed:@"file1" error:NULL];
    result = [template render];
    STAssertEqualObjects(result, @"é1\ndir/é1\ndir/dir/é1\ndir/dir/é2\n\n\ndir/é2\n\n\né2\n\n", @"");
    
    loader = [GRMustacheTemplateLoader templateLoaderWithBaseURL:URL extension:nil encoding:NSISOLatin1StringEncoding];
    template = [loader parseTemplateNamed:@"file1" error:NULL];
    result = [template render];
    STAssertEqualObjects(result, @"é1.mustache\ndir/é1.mustache\ndir/dir/é1.mustache\ndir/dir/é2.mustache\n\n\ndir/é2.mustache\n\n\né2.mustache\n\n", @"");
}

- (void)testDeepPartialsWithTemplateLoader
{
    NSURL *URL = [self.testBundle URLForResource:@"deep_partials" withExtension:nil];
    GRMustacheTemplateLoader *loader;
    GRMustacheTemplate *template;
    NSString *result;
    
    loader = [GRMustacheTemplateLoader templateLoaderWithBaseURL:URL extension:@"mustache"];
    template = [loader parseTemplateNamed:@"file1" error:NULL];
    result = [template render];
    STAssertEqualObjects(result, @"file1.mustache\ndir/file1.mustache\ndir/dir/file1.mustache\ndir/dir/file2.mustache\n\n\ndir/file2.mustache\n\n\nfile2.mustache\n\n", @"");
    
    loader = [GRMustacheTemplateLoader templateLoaderWithBaseURL:URL extension:@"txt"];
    template = [loader parseTemplateNamed:@"file1" error:NULL];
    result = [template render];
    STAssertEqualObjects(result, @"file1.txt\ndir/file1.txt\ndir/dir/file1.txt\ndir/dir/file2.txt\n\n\ndir/file2.txt\n\n\nfile2.txt\n\n", @"");
    
    loader = [GRMustacheTemplateLoader templateLoaderWithBaseURL:URL extension:@""];
    template = [loader parseTemplateNamed:@"file1" error:NULL];
    result = [template render];
    STAssertEqualObjects(result, @"file1\ndir/file1\ndir/dir/file1\ndir/dir/file2\n\n\ndir/file2\n\n\nfile2\n\n", @"");
    
    loader = [GRMustacheTemplateLoader templateLoaderWithBaseURL:URL extension:nil];
    template = [loader parseTemplateNamed:@"file1" error:NULL];
    result = [template render];
    STAssertEqualObjects(result, @"file1.mustache\ndir/file1.mustache\ndir/dir/file1.mustache\ndir/dir/file2.mustache\n\n\ndir/file2.mustache\n\n\nfile2.mustache\n\n", @"");
}


@end
