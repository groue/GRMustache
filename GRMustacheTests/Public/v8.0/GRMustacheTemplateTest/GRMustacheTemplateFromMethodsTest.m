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

#define GRMUSTACHE_VERSION_MAX_ALLOWED GRMUSTACHE_VERSION_8_0
#import "GRMustachePublicAPITest.h"

@interface GRMustacheTemplateFromMethodsTest : GRMustachePublicAPITest
@end

@interface GRMustacheTemplateFromMethodsTestSupport: NSObject {
    NSString *_stringProperty;
}
@property (nonatomic, retain) NSString *stringProperty;
@end

@implementation GRMustacheTemplateFromMethodsTestSupport
@synthesize stringProperty=_stringProperty;
@end

@interface GRMustacheTemplateFromMethodsTest()
@property (nonatomic, readonly) NSString *templateName;
@property (nonatomic, readonly) NSURL *templateURL;
@property (nonatomic, readonly) NSString *templatePath;
@property (nonatomic, readonly) NSString *templateString;

@property (nonatomic, readonly) NSString *parserErrorTemplateName;
@property (nonatomic, readonly) NSURL *parserErrorTemplateURL;
@property (nonatomic, readonly) NSString *parserErrorTemplatePath;
@property (nonatomic, readonly) NSString *parserErrorTemplateString;

@property (nonatomic, readonly) NSString *parserErrorTemplateWrapperName;
@property (nonatomic, readonly) NSURL *parserErrorTemplateWrapperURL;
@property (nonatomic, readonly) NSString *parserErrorTemplateWrapperPath;
@property (nonatomic, readonly) NSString *parserErrorTemplateWrapperString;

@property (nonatomic, readonly) NSString *compilerErrorTemplateName;
@property (nonatomic, readonly) NSURL *compilerErrorTemplateURL;
@property (nonatomic, readonly) NSString *compilerErrorTemplatePath;
@property (nonatomic, readonly) NSString *compilerErrorTemplateString;

@property (nonatomic, readonly) NSString *compilerErrorTemplateWrapperName;
@property (nonatomic, readonly) NSURL *compilerErrorTemplateWrapperURL;
@property (nonatomic, readonly) NSString *compilerErrorTemplateWrapperPath;
@property (nonatomic, readonly) NSString *compilerErrorTemplateWrapperString;
@end

@implementation GRMustacheTemplateFromMethodsTest

- (NSString *)templateName { return @"GRMustacheTemplateFromMethodsTest"; }
- (NSURL *)templateURL { return [[NSBundle bundleForClass:[self class]] URLForResource:self.templateName withExtension:@"mustache"]; }
- (NSString *)templatePath { return [self.templateURL path]; }
- (NSString *)templateString { return [NSString stringWithContentsOfFile:self.templatePath encoding:NSUTF8StringEncoding error:NULL]; }

- (NSString *)parserErrorTemplateName { return @"GRMustacheTemplateFromMethodsTest_parserError"; }
- (NSURL *)parserErrorTemplateURL { return [[NSBundle bundleForClass:[self class]] URLForResource:self.parserErrorTemplateName withExtension:@"mustache"]; }
- (NSString *)parserErrorTemplatePath { return [self.parserErrorTemplateURL path]; }
- (NSString *)parserErrorTemplateString { return [NSString stringWithContentsOfFile:self.parserErrorTemplatePath encoding:NSUTF8StringEncoding error:NULL]; }

- (NSString *)parserErrorTemplateWrapperName { return @"GRMustacheTemplateFromMethodsTest_parserErrorWrapper"; }
- (NSURL *)parserErrorTemplateWrapperURL { return [[NSBundle bundleForClass:[self class]] URLForResource:self.parserErrorTemplateWrapperName withExtension:@"mustache"]; }
- (NSString *)parserErrorTemplateWrapperPath { return [self.parserErrorTemplateWrapperURL path]; }
- (NSString *)parserErrorTemplateWrapperString { return [NSString stringWithContentsOfFile:self.parserErrorTemplateWrapperPath encoding:NSUTF8StringEncoding error:NULL]; }

- (NSString *)compilerErrorTemplateName { return @"GRMustacheTemplateFromMethodsTest_compilerError"; }
- (NSURL *)compilerErrorTemplateURL { return [[NSBundle bundleForClass:[self class]] URLForResource:self.compilerErrorTemplateName withExtension:@"mustache"]; }
- (NSString *)compilerErrorTemplatePath { return [self.compilerErrorTemplateURL path]; }
- (NSString *)compilerErrorTemplateString { return [NSString stringWithContentsOfFile:self.compilerErrorTemplatePath encoding:NSUTF8StringEncoding error:NULL]; }

- (NSString *)compilerErrorTemplateWrapperName { return @"GRMustacheTemplateFromMethodsTest_compilerErrorWrapper"; }
- (NSURL *)compilerErrorTemplateWrapperURL { return [[NSBundle bundleForClass:[self class]] URLForResource:self.compilerErrorTemplateWrapperName withExtension:@"mustache"]; }
- (NSString *)compilerErrorTemplateWrapperPath { return [self.compilerErrorTemplateWrapperURL path]; }
- (NSString *)compilerErrorTemplateWrapperString { return [NSString stringWithContentsOfFile:self.compilerErrorTemplateWrapperPath encoding:NSUTF8StringEncoding error:NULL]; }

- (id)valueForKey:(NSString *)key inRendering:(NSString *)rendering
{
    NSError *error;

    NSData *data = [rendering dataUsingEncoding:NSUTF8StringEncoding];
    id object = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    XCTAssertNotNil(object, @"%@", error);
    return [object valueForKey:key];
}

- (NSString *)valueForStringPropertyInRendering:(NSString *)rendering
{
    return [self valueForKey:@"stringProperty" inRendering:rendering];
}

- (NSString *)extensionOfTemplateFileInRendering:(NSString *)rendering
{
    NSString *fileName = [self valueForKey:@"fileName" inRendering:rendering];
    return [fileName pathExtension];
}

- (void)testGRMustacheTemplateFromNilString
{
    NSError *error;
    XCTAssertNil([GRMustacheTemplate templateFromString:nil error:&error], @"");
    XCTAssertEqualObjects(error.domain, GRMustacheErrorDomain, @"");
    XCTAssertEqual(error.code, GRMustacheErrorCodeTemplateNotFound, @"");
}

- (void)testGRMustacheTemplateFromNilResource
{
    NSError *error;
    XCTAssertNil([GRMustacheTemplate templateFromResource:nil bundle:nil error:&error], @"");
    XCTAssertEqualObjects(error.domain, GRMustacheErrorDomain, @"");
    XCTAssertEqual(error.code, GRMustacheErrorCodeTemplateNotFound, @"");
}

- (void)testGRMustacheTemplateFromNilFile
{
    NSError *error;
    XCTAssertNil([GRMustacheTemplate templateFromContentsOfFile:nil error:&error], @"");
    XCTAssertEqualObjects(error.domain, GRMustacheErrorDomain, @"");
    XCTAssertEqual(error.code, GRMustacheErrorCodeTemplateNotFound, @"");
}

- (void)testGRMustacheTemplateFromNilURL
{
    NSError *error;
    XCTAssertNil([GRMustacheTemplate templateFromContentsOfURL:nil error:&error], @"");
    XCTAssertEqualObjects(error.domain, GRMustacheErrorDomain, @"");
    XCTAssertEqual(error.code, GRMustacheErrorCodeTemplateNotFound, @"");
}


- (void)test_templateFromString_error
{
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:self.templateString
                                                                    error:NULL];
    GRMustacheTemplateFromMethodsTestSupport *context = [[[GRMustacheTemplateFromMethodsTestSupport alloc] init] autorelease];
    context.stringProperty = @"foo";
    NSString *rendering = [template renderObject:context error:NULL];
    XCTAssertEqualObjects(@"foo", [self valueForStringPropertyInRendering:rendering]);
}

- (void)test_templateFromContentsOfFile_error
{
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromContentsOfFile:self.templatePath
                                                                            error:NULL];
    GRMustacheTemplateFromMethodsTestSupport *context = [[[GRMustacheTemplateFromMethodsTestSupport alloc] init] autorelease];
    context.stringProperty = @"foo";
    NSString *rendering = [template renderObject:context error:NULL];
    XCTAssertEqualObjects(@"foo", [self valueForStringPropertyInRendering:rendering]);
}

- (void)test_templateFromContentsOfURL_error
{
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromContentsOfURL:self.templateURL
                                                                           error:NULL];
    GRMustacheTemplateFromMethodsTestSupport *context = [[[GRMustacheTemplateFromMethodsTestSupport alloc] init] autorelease];
    context.stringProperty = @"foo";
    NSString *rendering = [template renderObject:context error:NULL];
    XCTAssertEqualObjects(@"foo", [self valueForStringPropertyInRendering:rendering]);
}

- (void)test_templateFromResource_bundle_error
{
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromResource:self.templateName
                                                                     bundle:[NSBundle bundleForClass:[self class]]
                                                                      error:NULL];
    GRMustacheTemplateFromMethodsTestSupport *context = [[[GRMustacheTemplateFromMethodsTestSupport alloc] init] autorelease];
    context.stringProperty = @"foo";
    NSString *rendering = [template renderObject:context error:NULL];
    XCTAssertEqualObjects(@"foo", [self valueForStringPropertyInRendering:rendering]);
    XCTAssertEqualObjects(@"mustache", [self extensionOfTemplateFileInRendering:rendering]);
}

- (void)testParserError_templateFromString_error
{
    NSError *error;
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:self.parserErrorTemplateString
                                                                    error:&error];
    XCTAssertNil(template, @"");
    XCTAssertNotNil(error, @"");
    XCTAssertEqual((NSInteger)GRMustacheErrorCodeParseError, error.code, @"");
    NSRange range = [error.localizedDescription rangeOfString:@"line 2"];
    XCTAssertTrue(range.location != NSNotFound, @"");
}

- (void)testParserError_templateFromContentsOfFile_error
{
    {
        NSError *error;
        GRMustacheTemplate *template = [GRMustacheTemplate templateFromContentsOfFile:self.parserErrorTemplatePath
                                                                                error:&error];
        XCTAssertNil(template, @"");
        XCTAssertNotNil(error, @"");
        XCTAssertEqual((NSInteger)GRMustacheErrorCodeParseError, error.code, @"");
        {
            NSRange range = [error.localizedDescription rangeOfString:@"line 2"];
            XCTAssertTrue(range.location != NSNotFound, @"");
        }
        {
            NSRange range = [error.localizedDescription rangeOfString:self.parserErrorTemplatePath];
            XCTAssertTrue(range.location != NSNotFound, @"");
        }
    }
    {
        NSError *error;
        GRMustacheTemplate *template = [GRMustacheTemplate templateFromContentsOfFile:self.parserErrorTemplateWrapperPath
                                                                                error:&error];
        XCTAssertNil(template, @"");
        XCTAssertNotNil(error, @"");
        XCTAssertEqual((NSInteger)GRMustacheErrorCodeParseError, error.code, @"");
        {
            NSRange range = [error.localizedDescription rangeOfString:@"line 2"];
            XCTAssertTrue(range.location != NSNotFound, @"");
        }
        {
            NSRange range = [error.localizedDescription rangeOfString:self.parserErrorTemplatePath];
            XCTAssertTrue(range.location != NSNotFound, @"");
        }
    }
}

- (void)testParserError_templateFromContentsOfURL_error
{
    {
        NSError *error;
        GRMustacheTemplate *template = [GRMustacheTemplate templateFromContentsOfURL:self.parserErrorTemplateURL
                                                                               error:&error];
        XCTAssertNil(template, @"");
        XCTAssertNotNil(error, @"");
        XCTAssertEqual((NSInteger)GRMustacheErrorCodeParseError, error.code, @"");
        {
            NSRange range = [error.localizedDescription rangeOfString:@"line 2"];
            XCTAssertTrue(range.location != NSNotFound, @"");
        }
        {
            NSRange range = [error.localizedDescription rangeOfString:self.parserErrorTemplatePath];
            XCTAssertTrue(range.location != NSNotFound, @"");
        }
    }
    {
        NSError *error;
        GRMustacheTemplate *template = [GRMustacheTemplate templateFromContentsOfURL:self.parserErrorTemplateWrapperURL
                                                                               error:&error];
        XCTAssertNil(template, @"");
        XCTAssertNotNil(error, @"");
        XCTAssertEqual((NSInteger)GRMustacheErrorCodeParseError, error.code, @"");
        {
            NSRange range = [error.localizedDescription rangeOfString:@"line 2"];
            XCTAssertTrue(range.location != NSNotFound, @"");
        }
        {
            NSRange range = [error.localizedDescription rangeOfString:self.parserErrorTemplatePath];
            XCTAssertTrue(range.location != NSNotFound, @"");
        }
    }
}

- (void)testParserError_templateFromResource_bundle_error
{
    {
        NSError *error;
        GRMustacheTemplate *template = [GRMustacheTemplate templateFromResource:self.parserErrorTemplateName
                                                                         bundle:[NSBundle bundleForClass:[self class]]
                                                                          error:&error];
        XCTAssertNil(template, @"");
        XCTAssertNotNil(error, @"");
        XCTAssertEqual((NSInteger)GRMustacheErrorCodeParseError, error.code, @"");
        {
            NSRange range = [error.localizedDescription rangeOfString:@"line 2"];
            XCTAssertTrue(range.location != NSNotFound, @"");
        }
        {
            NSRange range = [error.localizedDescription rangeOfString:self.parserErrorTemplatePath];
            XCTAssertTrue(range.location != NSNotFound, @"");
        }
    }
    {
        NSError *error;
        GRMustacheTemplate *template = [GRMustacheTemplate templateFromResource:self.parserErrorTemplateWrapperName
                                                                         bundle:[NSBundle bundleForClass:[self class]]
                                                                          error:&error];
        XCTAssertNil(template, @"");
        XCTAssertNotNil(error, @"");
        XCTAssertEqual((NSInteger)GRMustacheErrorCodeParseError, error.code, @"");
        {
            NSRange range = [error.localizedDescription rangeOfString:@"line 2"];
            XCTAssertTrue(range.location != NSNotFound, @"");
        }
        {
            NSRange range = [error.localizedDescription rangeOfString:self.parserErrorTemplatePath];
            XCTAssertTrue(range.location != NSNotFound, @"");
        }
    }
}

- (void)testCompilerError_templateFromString_error
{
    NSError *error;
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:self.compilerErrorTemplateString
                                                                    error:&error];
    XCTAssertNil(template, @"");
    XCTAssertNotNil(error, @"");
    XCTAssertEqual((NSInteger)GRMustacheErrorCodeParseError, error.code, @"");
    NSRange range = [error.localizedDescription rangeOfString:@"line 2"];
    XCTAssertTrue(range.location != NSNotFound, @"");
}

- (void)testCompilerError_templateFromContentsOfFile_error
{
    {
        NSError *error;
        GRMustacheTemplate *template = [GRMustacheTemplate templateFromContentsOfFile:self.compilerErrorTemplatePath
                                                                                error:&error];
        XCTAssertNil(template, @"");
        XCTAssertNotNil(error, @"");
        XCTAssertEqual((NSInteger)GRMustacheErrorCodeParseError, error.code, @"");
        {
            NSRange range = [error.localizedDescription rangeOfString:@"line 2"];
            XCTAssertTrue(range.location != NSNotFound, @"");
        }
        {
            NSRange range = [error.localizedDescription rangeOfString:self.compilerErrorTemplatePath];
            XCTAssertTrue(range.location != NSNotFound, @"");
        }
    }
    {
        NSError *error;
        GRMustacheTemplate *template = [GRMustacheTemplate templateFromContentsOfFile:self.compilerErrorTemplateWrapperPath
                                                                                error:&error];
        XCTAssertNil(template, @"");
        XCTAssertNotNil(error, @"");
        XCTAssertEqual((NSInteger)GRMustacheErrorCodeParseError, error.code, @"");
        {
            NSRange range = [error.localizedDescription rangeOfString:@"line 2"];
            XCTAssertTrue(range.location != NSNotFound, @"");
        }
        {
            NSRange range = [error.localizedDescription rangeOfString:self.compilerErrorTemplatePath];
            XCTAssertTrue(range.location != NSNotFound, @"");
        }
    }
}

- (void)testCompilerError_templateFromContentsOfURL_error
{
    {
        NSError *error;
        GRMustacheTemplate *template = [GRMustacheTemplate templateFromContentsOfURL:self.compilerErrorTemplateURL
                                                                               error:&error];
        XCTAssertNil(template, @"");
        XCTAssertNotNil(error, @"");
        XCTAssertEqual((NSInteger)GRMustacheErrorCodeParseError, error.code, @"");
        {
            NSRange range = [error.localizedDescription rangeOfString:@"line 2"];
            XCTAssertTrue(range.location != NSNotFound, @"");
        }
        {
            NSRange range = [error.localizedDescription rangeOfString:self.compilerErrorTemplatePath];
            XCTAssertTrue(range.location != NSNotFound, @"");
        }
    }
    {
        NSError *error;
        GRMustacheTemplate *template = [GRMustacheTemplate templateFromContentsOfURL:self.compilerErrorTemplateWrapperURL
                                                                               error:&error];
        XCTAssertNil(template, @"");
        XCTAssertNotNil(error, @"");
        XCTAssertEqual((NSInteger)GRMustacheErrorCodeParseError, error.code, @"");
        {
            NSRange range = [error.localizedDescription rangeOfString:@"line 2"];
            XCTAssertTrue(range.location != NSNotFound, @"");
        }
        {
            NSRange range = [error.localizedDescription rangeOfString:self.compilerErrorTemplatePath];
            XCTAssertTrue(range.location != NSNotFound, @"");
        }
    }
}

- (void)testCompilerError_templateFromResource_bundle_error
{
    {
        NSError *error;
        GRMustacheTemplate *template = [GRMustacheTemplate templateFromResource:self.compilerErrorTemplateName
                                                                         bundle:[NSBundle bundleForClass:[self class]]
                                                                          error:&error];
        XCTAssertNil(template, @"");
        XCTAssertNotNil(error, @"");
        XCTAssertEqual((NSInteger)GRMustacheErrorCodeParseError, error.code, @"");
        {
            NSRange range = [error.localizedDescription rangeOfString:@"line 2"];
            XCTAssertTrue(range.location != NSNotFound, @"");
        }
        {
            NSRange range = [error.localizedDescription rangeOfString:self.compilerErrorTemplatePath];
            XCTAssertTrue(range.location != NSNotFound, @"");
        }
    }
    {
        NSError *error;
        GRMustacheTemplate *template = [GRMustacheTemplate templateFromResource:self.compilerErrorTemplateWrapperName
                                                                         bundle:[NSBundle bundleForClass:[self class]]
                                                                          error:&error];
        XCTAssertNil(template, @"");
        XCTAssertNotNil(error, @"");
        XCTAssertEqual((NSInteger)GRMustacheErrorCodeParseError, error.code, @"");
        {
            NSRange range = [error.localizedDescription rangeOfString:@"line 2"];
            XCTAssertTrue(range.location != NSNotFound, @"");
        }
        {
            NSRange range = [error.localizedDescription rangeOfString:self.compilerErrorTemplatePath];
            XCTAssertTrue(range.location != NSNotFound, @"");
        }
    }
}

@end
