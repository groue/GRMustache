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

#import "GRMustacheTemplateFromMethodsTest.h"

@implementation GRMustacheTemplateFromMethodsTest

- (void)testGRMustacheTemplate_templateFromString_error
{
    GRMustacheTemplate *template;
    NSString *result;
    NSDictionary *object;
    
    template = [GRMustacheTemplate templateFromString:@"{{foo/bar}}"
                                                error:NULL];
    object = [NSDictionary dictionaryWithObject:[NSDictionary dictionaryWithObject:@"baz" forKey:@"bar"] forKey:@"foo"];
    result = [template renderObject:object];
    STAssertEqualObjects(result, @"baz", nil);
}

- (void)testGRMustacheTemplate_templateFromString_options_error
{
    GRMustacheTemplate *template;
    NSString *result;
    NSDictionary *object;
    
    template = [GRMustacheTemplate templateFromString:@"{{foo/bar}}"
                                              options:GRMustacheTemplateOptionNone
                                                error:NULL];
    object = [NSDictionary dictionaryWithObject:[NSDictionary dictionaryWithObject:@"baz" forKey:@"bar"] forKey:@"foo"];
    result = [template renderObject:object];
    STAssertEqualObjects(result, @"baz", nil);
    
    template = [GRMustacheTemplate templateFromString:@"{{foo/bar}}"
                                              options:GRMustacheTemplateOptionMustacheSpecCompatibility
                                                error:NULL];
    object = [NSDictionary dictionaryWithObject:@"baz" forKey:@"foo/bar"];
    result = [template renderObject:object];
    STAssertEqualObjects(result, @"baz", nil);
}

- (void)testGRMustacheTemplate_templateFromContentsOfFile_error
{
    GRMustacheTemplate *template;
    NSString *result;
    NSDictionary *object;
    NSString *path;
    
	path = [[self.testBundle resourcePath] stringByAppendingPathComponent:@"foo_bar.mustache"];
    template = [GRMustacheTemplate templateFromContentsOfFile:path
                                                        error:NULL];
    object = [NSDictionary dictionaryWithObject:[NSDictionary dictionaryWithObject:@"baz" forKey:@"bar"] forKey:@"foo"];
    result = [template renderObject:object];
    STAssertEqualObjects(result, @"baz", nil);
}

- (void)testGRMustacheTemplate_templateFromContentsOfFile_options_error
{
    GRMustacheTemplate *template;
    NSString *result;
    NSDictionary *object;
    NSString *path;
    
	path = [[self.testBundle resourcePath] stringByAppendingPathComponent:@"foo_bar.mustache"];
    template = [GRMustacheTemplate templateFromContentsOfFile:path
                                                      options:GRMustacheTemplateOptionNone
                                                        error:NULL];
    object = [NSDictionary dictionaryWithObject:[NSDictionary dictionaryWithObject:@"baz" forKey:@"bar"] forKey:@"foo"];
    result = [template renderObject:object];
    STAssertEqualObjects(result, @"baz", nil);
    
	path = [[self.testBundle resourcePath] stringByAppendingPathComponent:@"foo_bar.mustache"];
    template = [GRMustacheTemplate templateFromContentsOfFile:path
                                                      options:GRMustacheTemplateOptionMustacheSpecCompatibility
                                                        error:NULL];
    object = [NSDictionary dictionaryWithObject:@"baz" forKey:@"foo/bar"];
    result = [template renderObject:object];
    STAssertEqualObjects(result, @"baz", nil);
}

- (void)testGRMustacheTemplate_templateFromContentsOfURL_error
{
    GRMustacheTemplate *template;
    NSString *result;
    NSDictionary *object;
    NSURL *URL;
    
	URL = [[self.testBundle resourceURL] URLByAppendingPathComponent:@"foo_bar.mustache"];
    template = [GRMustacheTemplate templateFromContentsOfURL:URL
                                                       error:NULL];
    object = [NSDictionary dictionaryWithObject:[NSDictionary dictionaryWithObject:@"baz" forKey:@"bar"] forKey:@"foo"];
    result = [template renderObject:object];
    STAssertEqualObjects(result, @"baz", nil);
}

- (void)testGRMustacheTemplate_templateFromContentsOfURL_options_error
{
    GRMustacheTemplate *template;
    NSString *result;
    NSDictionary *object;
    NSURL *URL;
    
	URL = [[self.testBundle resourceURL] URLByAppendingPathComponent:@"foo_bar.mustache"];
    template = [GRMustacheTemplate templateFromContentsOfURL:URL
                                                     options:GRMustacheTemplateOptionNone
                                                       error:NULL];
    object = [NSDictionary dictionaryWithObject:[NSDictionary dictionaryWithObject:@"baz" forKey:@"bar"] forKey:@"foo"];
    result = [template renderObject:object];
    STAssertEqualObjects(result, @"baz", nil);
    
	URL = [[self.testBundle resourceURL] URLByAppendingPathComponent:@"foo_bar.mustache"];
    template = [GRMustacheTemplate templateFromContentsOfURL:URL
                                                     options:GRMustacheTemplateOptionMustacheSpecCompatibility
                                                       error:NULL];
    object = [NSDictionary dictionaryWithObject:@"baz" forKey:@"foo/bar"];
    result = [template renderObject:object];
    STAssertEqualObjects(result, @"baz", nil);
}

- (void)testGRMustacheTemplate_templateFromResource_bundle_error
{
    GRMustacheTemplate *template;
    NSString *result;
    NSDictionary *object;
    
    template = [GRMustacheTemplate templateFromResource:@"foo_bar"
                                                 bundle:self.testBundle
                                                  error:NULL];
    object = [NSDictionary dictionaryWithObject:[NSDictionary dictionaryWithObject:@"baz" forKey:@"bar"] forKey:@"foo"];
    result = [template renderObject:object];
    STAssertEqualObjects(result, @"baz", nil);
}

- (void)testGRMustacheTemplate_templateFromResource_bundle_options_error
{
    GRMustacheTemplate *template;
    NSString *result;
    NSDictionary *object;
    
    template = [GRMustacheTemplate templateFromResource:@"foo_bar"
                                                 bundle:self.testBundle
                                                options:GRMustacheTemplateOptionNone
                                                  error:NULL];
    object = [NSDictionary dictionaryWithObject:[NSDictionary dictionaryWithObject:@"baz" forKey:@"bar"] forKey:@"foo"];
    result = [template renderObject:object];
    STAssertEqualObjects(result, @"baz", nil);
    
    template = [GRMustacheTemplate templateFromResource:@"foo_bar"
                                                 bundle:self.testBundle
                                                options:GRMustacheTemplateOptionMustacheSpecCompatibility
                                                  error:NULL];
    object = [NSDictionary dictionaryWithObject:@"baz" forKey:@"foo/bar"];
    result = [template renderObject:object];
    STAssertEqualObjects(result, @"baz", nil);
}

- (void)testGRMustacheTemplate_templateFromResource_withExtension_bundle_error
{
    GRMustacheTemplate *template;
    NSString *result;
    NSDictionary *object;
    
    template = [GRMustacheTemplate templateFromResource:@"foo_bar"
                                          withExtension:@"txt"
                                                 bundle:self.testBundle
                                                  error:NULL];
    object = [NSDictionary dictionaryWithObject:[NSDictionary dictionaryWithObject:@"baz" forKey:@"bar"] forKey:@"foo"];
    result = [template renderObject:object];
    STAssertEqualObjects(result, @"baz", nil);
}

- (void)testGRMustacheTemplate_templateFromResource_withExtension_bundle_options_error
{
    GRMustacheTemplate *template;
    NSString *result;
    NSDictionary *object;
    
    template = [GRMustacheTemplate templateFromResource:@"foo_bar"
                                          withExtension:@"txt"
                                                 bundle:self.testBundle
                                                options:GRMustacheTemplateOptionNone
                                                  error:NULL];
    object = [NSDictionary dictionaryWithObject:[NSDictionary dictionaryWithObject:@"baz" forKey:@"bar"] forKey:@"foo"];
    result = [template renderObject:object];
    STAssertEqualObjects(result, @"baz", nil);
    
    template = [GRMustacheTemplate templateFromResource:@"foo_bar"
                                          withExtension:@"txt"
                                                 bundle:self.testBundle
                                                options:GRMustacheTemplateOptionMustacheSpecCompatibility
                                                  error:NULL];
    object = [NSDictionary dictionaryWithObject:@"baz" forKey:@"foo/bar"];
    result = [template renderObject:object];
    STAssertEqualObjects(result, @"baz", nil);
}

- (void)testGRMustacheTemplateLoader_templateFromString_error
{
    GRMustacheTemplateLoader *loader;
    GRMustacheTemplate *template;
    NSString *result;
    NSDictionary *object;
    
    loader = [GRMustacheTemplateLoader templateLoaderWithBundle:self.testBundle];
    template = [loader templateFromString:@"{{>foo_bar}}" error:NULL];
    object = [NSDictionary dictionaryWithObject:[NSDictionary dictionaryWithObject:@"baz" forKey:@"bar"] forKey:@"foo"];
    result = [template renderObject:object];
    STAssertEqualObjects(result, @"baz", nil);
}

- (void)testGRMustacheTemplateLoader_templateWithName
{
    GRMustacheTemplateLoader *loader;
    GRMustacheTemplate *template;
    NSString *result;
    NSDictionary *object;
    
    loader = [GRMustacheTemplateLoader templateLoaderWithBundle:self.testBundle];
    template = [loader templateWithName:@"foo_bar" error:NULL];
    object = [NSDictionary dictionaryWithObject:[NSDictionary dictionaryWithObject:@"baz" forKey:@"bar"] forKey:@"foo"];
    result = [template renderObject:object];
    STAssertEqualObjects(result, @"baz", nil);
}
@end
