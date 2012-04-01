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
#import "JSONKit.h"

@interface GRMustacheTemplateFromMethodsTestSupport: NSObject
@property (nonatomic, retain) NSString *stringProperty;
@property (nonatomic) BOOL BOOLProperty;
@property (nonatomic) bool boolProperty;
@end

@implementation GRMustacheTemplateFromMethodsTestSupport
@synthesize stringProperty;
@synthesize BOOLProperty;
@synthesize boolProperty;
@end

@interface GRMustacheTemplateFromMethodsTest()
@property (nonatomic, readonly) NSString *templateName;
@property (nonatomic, readonly) NSURL *templateURL;
@property (nonatomic, readonly) NSString *templatePath;
@property (nonatomic, readonly) NSString *templateString;

@property (nonatomic, readonly) NSString *tokenizerErrorTemplateName;
@property (nonatomic, readonly) NSURL *tokenizerErrorTemplateURL;
@property (nonatomic, readonly) NSString *tokenizerErrorTemplatePath;
@property (nonatomic, readonly) NSString *tokenizerErrorTemplateString;

@property (nonatomic, readonly) NSString *tokenizerErrorTemplateWrapperName;
@property (nonatomic, readonly) NSURL *tokenizerErrorTemplateWrapperURL;
@property (nonatomic, readonly) NSString *tokenizerErrorTemplateWrapperPath;
@property (nonatomic, readonly) NSString *tokenizerErrorTemplateWrapperString;

@property (nonatomic, readonly) NSString *parserErrorTemplateName;
@property (nonatomic, readonly) NSURL *parserErrorTemplateURL;
@property (nonatomic, readonly) NSString *parserErrorTemplatePath;
@property (nonatomic, readonly) NSString *parserErrorTemplateString;

@property (nonatomic, readonly) NSString *parserErrorTemplateWrapperName;
@property (nonatomic, readonly) NSURL *parserErrorTemplateWrapperURL;
@property (nonatomic, readonly) NSString *parserErrorTemplateWrapperPath;
@property (nonatomic, readonly) NSString *parserErrorTemplateWrapperString;
@end

@implementation GRMustacheTemplateFromMethodsTest

- (NSString *)templateName { return @"GRMustacheTemplateFromMethodsTest"; }
- (NSURL *)templateURL { return [self.testBundle URLForResource:self.templateName withExtension:@"mustache"]; }
- (NSString *)templatePath { return [self.templateURL path]; }
- (NSString *)templateString { return [NSString stringWithContentsOfFile:self.templatePath encoding:NSUTF8StringEncoding error:NULL]; }

- (NSString *)tokenizerErrorTemplateName { return @"GRMustacheTemplateFromMethodsTest_tokenizerError"; }
- (NSURL *)tokenizerErrorTemplateURL { return [self.testBundle URLForResource:self.tokenizerErrorTemplateName withExtension:@"mustache"]; }
- (NSString *)tokenizerErrorTemplatePath { return [self.tokenizerErrorTemplateURL path]; }
- (NSString *)tokenizerErrorTemplateString { return [NSString stringWithContentsOfFile:self.tokenizerErrorTemplatePath encoding:NSUTF8StringEncoding error:NULL]; }

- (NSString *)tokenizerErrorTemplateWrapperName { return @"GRMustacheTemplateFromMethodsTest_tokenizerErrorWrapper"; }
- (NSURL *)tokenizerErrorTemplateWrapperURL { return [self.testBundle URLForResource:self.tokenizerErrorTemplateWrapperName withExtension:@"mustache"]; }
- (NSString *)tokenizerErrorTemplateWrapperPath { return [self.tokenizerErrorTemplateWrapperURL path]; }
- (NSString *)tokenizerErrorTemplateWrapperString { return [NSString stringWithContentsOfFile:self.tokenizerErrorTemplateWrapperPath encoding:NSUTF8StringEncoding error:NULL]; }

- (NSString *)parserErrorTemplateName { return @"GRMustacheTemplateFromMethodsTest_parserError"; }
- (NSURL *)parserErrorTemplateURL { return [self.testBundle URLForResource:self.parserErrorTemplateName withExtension:@"mustache"]; }
- (NSString *)parserErrorTemplatePath { return [self.parserErrorTemplateURL path]; }
- (NSString *)parserErrorTemplateString { return [NSString stringWithContentsOfFile:self.parserErrorTemplatePath encoding:NSUTF8StringEncoding error:NULL]; }

- (NSString *)parserErrorTemplateWrapperName { return @"GRMustacheTemplateFromMethodsTest_parserErrorWrapper"; }
- (NSURL *)parserErrorTemplateWrapperURL { return [self.testBundle URLForResource:self.parserErrorTemplateWrapperName withExtension:@"mustache"]; }
- (NSString *)parserErrorTemplateWrapperPath { return [self.parserErrorTemplateWrapperURL path]; }
- (NSString *)parserErrorTemplateWrapperString { return [NSString stringWithContentsOfFile:self.parserErrorTemplateWrapperPath encoding:NSUTF8StringEncoding error:NULL]; }

- (id)valueForKey:(NSString *)key inRendering:(NSString *)rendering
{
    NSError *error;
    id object = [rendering objectFromJSONStringWithParseOptions:JKParseOptionNone error:&error];
    STAssertNotNil(object, @"%@", error);
    return [object valueForKey:key];
}

- (BOOL)valueForBOOLPropertyInRendering:(NSString *)rendering
{
    id value = [self valueForKey:@"BOOLProperty" inRendering:rendering];
    STAssertNotNil(value, @"nil BOOLProperty");
    return [(NSNumber *)value boolValue];
}

- (BOOL)valueForboolPropertyInRendering:(NSString *)rendering
{
    id value = [self valueForKey:@"boolProperty" inRendering:rendering];
    STAssertNotNil(value, @"nil boolProperty");
    return [(NSNumber *)value boolValue];
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

- (void)test_templateFromString_error
{
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:self.templateString
                                                                    error:NULL];
    GRMustacheTemplateFromMethodsTestSupport *context = [[[GRMustacheTemplateFromMethodsTestSupport alloc] init] autorelease];
    context.stringProperty = @"foo";
    NSString *rendering = [template renderObject:context];
    STAssertEqualObjects(@"foo", [self valueForStringPropertyInRendering:rendering], nil);
}

- (void)test_templateFromString_options_error
{
    {
        GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:self.templateString
                                                                      options:GRMustacheTemplateOptionNone
                                                                        error:NULL];
        GRMustacheTemplateFromMethodsTestSupport *context = [[[GRMustacheTemplateFromMethodsTestSupport alloc] init] autorelease];
        context.BOOLProperty = NO;
        context.boolProperty = NO;
        NSString *rendering = [template renderObject:context];
        STAssertEquals(NO, [self valueForBOOLPropertyInRendering:rendering], nil);
        STAssertEquals(NO, [self valueForboolPropertyInRendering:rendering], nil);
    }
    {
        GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:self.templateString
                                                                      options:GRMustacheTemplateOptionStrictBoolean
                                                                        error:NULL];
        GRMustacheTemplateFromMethodsTestSupport *context = [[[GRMustacheTemplateFromMethodsTestSupport alloc] init] autorelease];
        context.BOOLProperty = NO;
        context.boolProperty = NO;
        NSString *rendering = [template renderObject:context];
        STAssertEquals(YES, [self valueForBOOLPropertyInRendering:rendering], nil);
        STAssertEquals(NO, [self valueForboolPropertyInRendering:rendering], nil);
    }
}

- (void)test_templateFromContentsOfFile_error
{
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromContentsOfFile:self.templatePath
                                                                            error:NULL];
    GRMustacheTemplateFromMethodsTestSupport *context = [[[GRMustacheTemplateFromMethodsTestSupport alloc] init] autorelease];
    context.stringProperty = @"foo";
    NSString *rendering = [template renderObject:context];
    STAssertEqualObjects(@"foo", [self valueForStringPropertyInRendering:rendering], nil);
}

- (void)test_templateFromContentsOfFile_options_error
{
    {
        GRMustacheTemplate *template = [GRMustacheTemplate templateFromContentsOfFile:self.templatePath
                                                                              options:GRMustacheTemplateOptionNone
                                                                                error:NULL];
        GRMustacheTemplateFromMethodsTestSupport *context = [[[GRMustacheTemplateFromMethodsTestSupport alloc] init] autorelease];
        context.BOOLProperty = NO;
        context.boolProperty = NO;
        NSString *rendering = [template renderObject:context];
        STAssertEquals(NO, [self valueForBOOLPropertyInRendering:rendering], nil);
        STAssertEquals(NO, [self valueForboolPropertyInRendering:rendering], nil);
    }
    {
        GRMustacheTemplate *template = [GRMustacheTemplate templateFromContentsOfFile:self.templatePath
                                                                              options:GRMustacheTemplateOptionStrictBoolean
                                                                                error:NULL];
        GRMustacheTemplateFromMethodsTestSupport *context = [[[GRMustacheTemplateFromMethodsTestSupport alloc] init] autorelease];
        context.BOOLProperty = NO;
        context.boolProperty = NO;
        NSString *rendering = [template renderObject:context];
        STAssertEquals(YES, [self valueForBOOLPropertyInRendering:rendering], nil);
        STAssertEquals(NO, [self valueForboolPropertyInRendering:rendering], nil);
    }
}

- (void)test_templateFromContentsOfURL_error
{
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromContentsOfURL:self.templateURL
                                                                           error:NULL];
    GRMustacheTemplateFromMethodsTestSupport *context = [[[GRMustacheTemplateFromMethodsTestSupport alloc] init] autorelease];
    context.stringProperty = @"foo";
    NSString *rendering = [template renderObject:context];
    STAssertEqualObjects(@"foo", [self valueForStringPropertyInRendering:rendering], nil);
}

- (void)test_templateFromContentsOfURL_options_error
{
    {
        GRMustacheTemplate *template = [GRMustacheTemplate templateFromContentsOfURL:self.templateURL
                                                                             options:GRMustacheTemplateOptionNone
                                                                               error:NULL];
        GRMustacheTemplateFromMethodsTestSupport *context = [[[GRMustacheTemplateFromMethodsTestSupport alloc] init] autorelease];
        context.BOOLProperty = NO;
        context.boolProperty = NO;
        NSString *rendering = [template renderObject:context];
        STAssertEquals(NO, [self valueForBOOLPropertyInRendering:rendering], nil);
        STAssertEquals(NO, [self valueForboolPropertyInRendering:rendering], nil);
    }
    {
        GRMustacheTemplate *template = [GRMustacheTemplate templateFromContentsOfURL:self.templateURL
                                                                             options:GRMustacheTemplateOptionStrictBoolean
                                                                               error:NULL];
        GRMustacheTemplateFromMethodsTestSupport *context = [[[GRMustacheTemplateFromMethodsTestSupport alloc] init] autorelease];
        context.BOOLProperty = NO;
        context.boolProperty = NO;
        NSString *rendering = [template renderObject:context];
        STAssertEquals(YES, [self valueForBOOLPropertyInRendering:rendering], nil);
        STAssertEquals(NO, [self valueForboolPropertyInRendering:rendering], nil);
    }
}

- (void)test_templateFromResource_bundle_error
{
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromResource:self.templateName
                                                                     bundle:self.testBundle
                                                                      error:NULL];
    GRMustacheTemplateFromMethodsTestSupport *context = [[[GRMustacheTemplateFromMethodsTestSupport alloc] init] autorelease];
    context.stringProperty = @"foo";
    NSString *rendering = [template renderObject:context];
    STAssertEqualObjects(@"foo", [self valueForStringPropertyInRendering:rendering], nil);
    STAssertEqualObjects(@"mustache", [self extensionOfTemplateFileInRendering:rendering], nil);
}

- (void)test_templateFromResource_bundle_options_error
{
    {
        GRMustacheTemplate *template = [GRMustacheTemplate templateFromResource:self.templateName
                                                                         bundle:self.testBundle
                                                                        options:GRMustacheTemplateOptionNone
                                                                          error:NULL];
        GRMustacheTemplateFromMethodsTestSupport *context = [[[GRMustacheTemplateFromMethodsTestSupport alloc] init] autorelease];
        context.BOOLProperty = NO;
        context.boolProperty = NO;
        NSString *rendering = [template renderObject:context];
        STAssertEquals(NO, [self valueForBOOLPropertyInRendering:rendering], nil);
        STAssertEquals(NO, [self valueForboolPropertyInRendering:rendering], nil);
        STAssertEqualObjects(@"mustache", [self extensionOfTemplateFileInRendering:rendering], nil);
    }
    {
        GRMustacheTemplate *template = [GRMustacheTemplate templateFromResource:self.templateName
                                                                         bundle:self.testBundle
                                                                        options:GRMustacheTemplateOptionStrictBoolean
                                                                          error:NULL];
        GRMustacheTemplateFromMethodsTestSupport *context = [[[GRMustacheTemplateFromMethodsTestSupport alloc] init] autorelease];
        context.BOOLProperty = NO;
        context.boolProperty = NO;
        NSString *rendering = [template renderObject:context];
        STAssertEquals(YES, [self valueForBOOLPropertyInRendering:rendering], nil);
        STAssertEquals(NO, [self valueForboolPropertyInRendering:rendering], nil);
        STAssertEqualObjects(@"mustache", [self extensionOfTemplateFileInRendering:rendering], nil);
    }
}

- (void)test_templateFromResource_withExtension_bundle_error
{
    {
        GRMustacheTemplate *template = [GRMustacheTemplate templateFromResource:self.templateName
                                                                  withExtension:@"json"
                                                                         bundle:self.testBundle
                                                                          error:NULL];
        GRMustacheTemplateFromMethodsTestSupport *context = [[[GRMustacheTemplateFromMethodsTestSupport alloc] init] autorelease];
        context.stringProperty = @"foo";
        NSString *rendering = [template renderObject:context];
        STAssertEqualObjects(@"foo", [self valueForStringPropertyInRendering:rendering], nil);
        STAssertEqualObjects(@"json", [self extensionOfTemplateFileInRendering:rendering], nil);
    }
    {
        GRMustacheTemplate *template = [GRMustacheTemplate templateFromResource:self.templateName
                                                                  withExtension:@""
                                                                         bundle:self.testBundle
                                                                          error:NULL];
        GRMustacheTemplateFromMethodsTestSupport *context = [[[GRMustacheTemplateFromMethodsTestSupport alloc] init] autorelease];
        context.stringProperty = @"foo";
        NSString *rendering = [template renderObject:context];
        STAssertEqualObjects(@"foo", [self valueForStringPropertyInRendering:rendering], nil);
        STAssertEqualObjects(@"", [self extensionOfTemplateFileInRendering:rendering], nil);
    }
    {
        GRMustacheTemplate *template = [GRMustacheTemplate templateFromResource:self.templateName
                                                                  withExtension:nil
                                                                         bundle:self.testBundle
                                                                          error:NULL];
        GRMustacheTemplateFromMethodsTestSupport *context = [[[GRMustacheTemplateFromMethodsTestSupport alloc] init] autorelease];
        context.stringProperty = @"foo";
        NSString *rendering = [template renderObject:context];
        STAssertEqualObjects(@"foo", [self valueForStringPropertyInRendering:rendering], nil);
        STAssertEqualObjects(@"", [self extensionOfTemplateFileInRendering:rendering], nil);
    }
}

- (void)test_templateFromResource_withExtension_bundle_options_error
{
    {
        {
            GRMustacheTemplate *template = [GRMustacheTemplate templateFromResource:self.templateName
                                                                      withExtension:@"json"
                                                                             bundle:self.testBundle
                                                                            options:GRMustacheTemplateOptionNone
                                                                              error:NULL];
            GRMustacheTemplateFromMethodsTestSupport *context = [[[GRMustacheTemplateFromMethodsTestSupport alloc] init] autorelease];
            context.BOOLProperty = NO;
            context.boolProperty = NO;
            NSString *rendering = [template renderObject:context];
            STAssertEquals(NO, [self valueForBOOLPropertyInRendering:rendering], nil);
            STAssertEquals(NO, [self valueForboolPropertyInRendering:rendering], nil);
            STAssertEqualObjects(@"json", [self extensionOfTemplateFileInRendering:rendering], nil);
        }
        {
            GRMustacheTemplate *template = [GRMustacheTemplate templateFromResource:self.templateName
                                                                      withExtension:@""
                                                                             bundle:self.testBundle
                                                                            options:GRMustacheTemplateOptionNone
                                                                              error:NULL];
            GRMustacheTemplateFromMethodsTestSupport *context = [[[GRMustacheTemplateFromMethodsTestSupport alloc] init] autorelease];
            context.BOOLProperty = NO;
            context.boolProperty = NO;
            NSString *rendering = [template renderObject:context];
            STAssertEquals(NO, [self valueForBOOLPropertyInRendering:rendering], nil);
            STAssertEquals(NO, [self valueForboolPropertyInRendering:rendering], nil);
            STAssertEqualObjects(@"", [self extensionOfTemplateFileInRendering:rendering], nil);
        }
        {
            GRMustacheTemplate *template = [GRMustacheTemplate templateFromResource:self.templateName
                                                                      withExtension:nil
                                                                             bundle:self.testBundle
                                                                            options:GRMustacheTemplateOptionNone
                                                                              error:NULL];
            GRMustacheTemplateFromMethodsTestSupport *context = [[[GRMustacheTemplateFromMethodsTestSupport alloc] init] autorelease];
            context.BOOLProperty = NO;
            context.boolProperty = NO;
            NSString *rendering = [template renderObject:context];
            STAssertEquals(NO, [self valueForBOOLPropertyInRendering:rendering], nil);
            STAssertEquals(NO, [self valueForboolPropertyInRendering:rendering], nil);
            STAssertEqualObjects(@"", [self extensionOfTemplateFileInRendering:rendering], nil);
        }
    }
    {
        {
            GRMustacheTemplate *template = [GRMustacheTemplate templateFromResource:self.templateName
                                                                      withExtension:@"json"
                                                                             bundle:self.testBundle
                                                                            options:GRMustacheTemplateOptionStrictBoolean
                                                                              error:NULL];
            GRMustacheTemplateFromMethodsTestSupport *context = [[[GRMustacheTemplateFromMethodsTestSupport alloc] init] autorelease];
            context.BOOLProperty = NO;
            context.boolProperty = NO;
            NSString *rendering = [template renderObject:context];
            STAssertEquals(YES, [self valueForBOOLPropertyInRendering:rendering], nil);
            STAssertEquals(NO, [self valueForboolPropertyInRendering:rendering], nil);
            STAssertEqualObjects(@"json", [self extensionOfTemplateFileInRendering:rendering], nil);
        }
        {
            GRMustacheTemplate *template = [GRMustacheTemplate templateFromResource:self.templateName
                                                                      withExtension:@""
                                                                             bundle:self.testBundle
                                                                            options:GRMustacheTemplateOptionStrictBoolean
                                                                              error:NULL];
            GRMustacheTemplateFromMethodsTestSupport *context = [[[GRMustacheTemplateFromMethodsTestSupport alloc] init] autorelease];
            context.BOOLProperty = NO;
            context.boolProperty = NO;
            NSString *rendering = [template renderObject:context];
            STAssertEquals(YES, [self valueForBOOLPropertyInRendering:rendering], nil);
            STAssertEquals(NO, [self valueForboolPropertyInRendering:rendering], nil);
            STAssertEqualObjects(@"", [self extensionOfTemplateFileInRendering:rendering], nil);
        }
        {
            GRMustacheTemplate *template = [GRMustacheTemplate templateFromResource:self.templateName
                                                                      withExtension:nil
                                                                             bundle:self.testBundle
                                                                            options:GRMustacheTemplateOptionStrictBoolean
                                                                              error:NULL];
            GRMustacheTemplateFromMethodsTestSupport *context = [[[GRMustacheTemplateFromMethodsTestSupport alloc] init] autorelease];
            context.BOOLProperty = NO;
            context.boolProperty = NO;
            NSString *rendering = [template renderObject:context];
            STAssertEquals(YES, [self valueForBOOLPropertyInRendering:rendering], nil);
            STAssertEquals(NO, [self valueForboolPropertyInRendering:rendering], nil);
            STAssertEqualObjects(@"", [self extensionOfTemplateFileInRendering:rendering], nil);
        }
    }
}

- (void)testTokenizerError_templateFromString_error
{
    NSError *error;
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:self.tokenizerErrorTemplateString
                                                                    error:&error];
    STAssertNil(template, @"");
    STAssertNotNil(error, @"");
    STAssertEquals((NSInteger)GRMustacheErrorCodeParseError, error.code, @"");
    NSRange range = [error.localizedDescription rangeOfString:@"line 2"];
    STAssertTrue(range.location != NSNotFound, @"");
}

- (void)testTokenizerError_templateFromContentsOfFile_error
{
    {
        NSError *error;
        GRMustacheTemplate *template = [GRMustacheTemplate templateFromContentsOfFile:self.tokenizerErrorTemplatePath
                                                                                error:&error];
        STAssertNil(template, @"");
        STAssertNotNil(error, @"");
        STAssertEquals((NSInteger)GRMustacheErrorCodeParseError, error.code, @"");
        {
            NSRange range = [error.localizedDescription rangeOfString:@"line 2"];
            STAssertTrue(range.location != NSNotFound, @"");
        }
        {
            NSRange range = [error.localizedDescription rangeOfString:self.tokenizerErrorTemplatePath];
            STAssertTrue(range.location != NSNotFound, @"");
        }
    }
    {
        NSError *error;
        GRMustacheTemplate *template = [GRMustacheTemplate templateFromContentsOfFile:self.tokenizerErrorTemplateWrapperPath
                                                                                error:&error];
        STAssertNil(template, @"");
        STAssertNotNil(error, @"");
        STAssertEquals((NSInteger)GRMustacheErrorCodeParseError, error.code, @"");
        {
            NSRange range = [error.localizedDescription rangeOfString:@"line 2"];
            STAssertTrue(range.location != NSNotFound, @"");
        }
        {
            NSRange range = [error.localizedDescription rangeOfString:self.tokenizerErrorTemplatePath];
            STAssertTrue(range.location != NSNotFound, @"");
        }
    }
}

- (void)testTokenizerError_templateFromContentsOfURL_error
{
    {
        NSError *error;
        GRMustacheTemplate *template = [GRMustacheTemplate templateFromContentsOfURL:self.tokenizerErrorTemplateURL
                                                                               error:&error];
        STAssertNil(template, @"");
        STAssertNotNil(error, @"");
        STAssertEquals((NSInteger)GRMustacheErrorCodeParseError, error.code, @"");
        {
            NSRange range = [error.localizedDescription rangeOfString:@"line 2"];
            STAssertTrue(range.location != NSNotFound, @"");
        }
        {
            NSRange range = [error.localizedDescription rangeOfString:self.tokenizerErrorTemplatePath];
            STAssertTrue(range.location != NSNotFound, @"");
        }
    }
    {
        NSError *error;
        GRMustacheTemplate *template = [GRMustacheTemplate templateFromContentsOfURL:self.tokenizerErrorTemplateWrapperURL
                                                                               error:&error];
        STAssertNil(template, @"");
        STAssertNotNil(error, @"");
        STAssertEquals((NSInteger)GRMustacheErrorCodeParseError, error.code, @"");
        {
            NSRange range = [error.localizedDescription rangeOfString:@"line 2"];
            STAssertTrue(range.location != NSNotFound, @"");
        }
        {
            NSRange range = [error.localizedDescription rangeOfString:self.tokenizerErrorTemplatePath];
            STAssertTrue(range.location != NSNotFound, @"");
        }
    }
}

- (void)testTokenizerError_templateFromResource_bundle_error
{
    {
        NSError *error;
        GRMustacheTemplate *template = [GRMustacheTemplate templateFromResource:self.tokenizerErrorTemplateName
                                                                         bundle:self.testBundle
                                                                          error:&error];
        STAssertNil(template, @"");
        STAssertNotNil(error, @"");
        STAssertEquals((NSInteger)GRMustacheErrorCodeParseError, error.code, @"");
        {
            NSRange range = [error.localizedDescription rangeOfString:@"line 2"];
            STAssertTrue(range.location != NSNotFound, @"");
        }
        {
            NSRange range = [error.localizedDescription rangeOfString:self.tokenizerErrorTemplatePath];
            STAssertTrue(range.location != NSNotFound, @"");
        }
    }
    {
        NSError *error;
        GRMustacheTemplate *template = [GRMustacheTemplate templateFromResource:self.tokenizerErrorTemplateWrapperName
                                                                         bundle:self.testBundle
                                                                          error:&error];
        STAssertNil(template, @"");
        STAssertNotNil(error, @"");
        STAssertEquals((NSInteger)GRMustacheErrorCodeParseError, error.code, @"");
        {
            NSRange range = [error.localizedDescription rangeOfString:@"line 2"];
            STAssertTrue(range.location != NSNotFound, @"");
        }
        {
            NSRange range = [error.localizedDescription rangeOfString:self.tokenizerErrorTemplatePath];
            STAssertTrue(range.location != NSNotFound, @"");
        }
    }
}

- (void)testParserError_templateFromString_error
{
    NSError *error;
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:self.parserErrorTemplateString
                                                                    error:&error];
    STAssertNil(template, @"");
    STAssertNotNil(error, @"");
    STAssertEquals((NSInteger)GRMustacheErrorCodeParseError, error.code, @"");
    NSRange range = [error.localizedDescription rangeOfString:@"line 2"];
    STAssertTrue(range.location != NSNotFound, @"");
}

- (void)testParserError_templateFromContentsOfFile_error
{
    {
        NSError *error;
        GRMustacheTemplate *template = [GRMustacheTemplate templateFromContentsOfFile:self.parserErrorTemplatePath
                                                                                error:&error];
        STAssertNil(template, @"");
        STAssertNotNil(error, @"");
        STAssertEquals((NSInteger)GRMustacheErrorCodeParseError, error.code, @"");
        {
            NSRange range = [error.localizedDescription rangeOfString:@"line 2"];
            STAssertTrue(range.location != NSNotFound, @"");
        }
        {
            NSRange range = [error.localizedDescription rangeOfString:self.parserErrorTemplatePath];
            STAssertTrue(range.location != NSNotFound, @"");
        }
    }
    {
        NSError *error;
        GRMustacheTemplate *template = [GRMustacheTemplate templateFromContentsOfFile:self.parserErrorTemplateWrapperPath
                                                                                error:&error];
        STAssertNil(template, @"");
        STAssertNotNil(error, @"");
        STAssertEquals((NSInteger)GRMustacheErrorCodeParseError, error.code, @"");
        {
            NSRange range = [error.localizedDescription rangeOfString:@"line 2"];
            STAssertTrue(range.location != NSNotFound, @"");
        }
        {
            NSRange range = [error.localizedDescription rangeOfString:self.parserErrorTemplatePath];
            STAssertTrue(range.location != NSNotFound, @"");
        }
    }
}

- (void)testParserError_templateFromContentsOfURL_error
{
    {
        NSError *error;
        GRMustacheTemplate *template = [GRMustacheTemplate templateFromContentsOfURL:self.parserErrorTemplateURL
                                                                               error:&error];
        STAssertNil(template, @"");
        STAssertNotNil(error, @"");
        STAssertEquals((NSInteger)GRMustacheErrorCodeParseError, error.code, @"");
        {
            NSRange range = [error.localizedDescription rangeOfString:@"line 2"];
            STAssertTrue(range.location != NSNotFound, @"");
        }
        {
            NSRange range = [error.localizedDescription rangeOfString:self.parserErrorTemplatePath];
            STAssertTrue(range.location != NSNotFound, @"");
        }
    }
    {
        NSError *error;
        GRMustacheTemplate *template = [GRMustacheTemplate templateFromContentsOfURL:self.parserErrorTemplateWrapperURL
                                                                               error:&error];
        STAssertNil(template, @"");
        STAssertNotNil(error, @"");
        STAssertEquals((NSInteger)GRMustacheErrorCodeParseError, error.code, @"");
        {
            NSRange range = [error.localizedDescription rangeOfString:@"line 2"];
            STAssertTrue(range.location != NSNotFound, @"");
        }
        {
            NSRange range = [error.localizedDescription rangeOfString:self.parserErrorTemplatePath];
            STAssertTrue(range.location != NSNotFound, @"");
        }
    }
}

- (void)testParserError_templateFromResource_bundle_error
{
    {
        NSError *error;
        GRMustacheTemplate *template = [GRMustacheTemplate templateFromResource:self.parserErrorTemplateName
                                                                         bundle:self.testBundle
                                                                          error:&error];
        STAssertNil(template, @"");
        STAssertNotNil(error, @"");
        STAssertEquals((NSInteger)GRMustacheErrorCodeParseError, error.code, @"");
        {
            NSRange range = [error.localizedDescription rangeOfString:@"line 2"];
            STAssertTrue(range.location != NSNotFound, @"");
        }
        {
            NSRange range = [error.localizedDescription rangeOfString:self.parserErrorTemplatePath];
            STAssertTrue(range.location != NSNotFound, @"");
        }
    }
    {
        NSError *error;
        GRMustacheTemplate *template = [GRMustacheTemplate templateFromResource:self.parserErrorTemplateWrapperName
                                                                         bundle:self.testBundle
                                                                          error:&error];
        STAssertNil(template, @"");
        STAssertNotNil(error, @"");
        STAssertEquals((NSInteger)GRMustacheErrorCodeParseError, error.code, @"");
        {
            NSRange range = [error.localizedDescription rangeOfString:@"line 2"];
            STAssertTrue(range.location != NSNotFound, @"");
        }
        {
            NSRange range = [error.localizedDescription rangeOfString:self.parserErrorTemplatePath];
            STAssertTrue(range.location != NSNotFound, @"");
        }
    }
}

@end
