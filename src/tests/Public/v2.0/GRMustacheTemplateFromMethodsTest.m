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
@end

@implementation GRMustacheTemplateFromMethodsTest

- (NSURL *)templateURL
{
    return [self.testBundle URLForResource:self.templateName withExtension:@"mustache"];
}

- (NSString *)templatePath
{
    return [self.templateURL path];
}

- (NSString *)templateString
{
    return [NSString stringWithContentsOfFile:self.templatePath encoding:NSUTF8StringEncoding error:NULL];
}

- (NSString *)templateName
{
    return @"GRMustacheTemplateFromMethodsTest";
}

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

- (void)testGRMustacheTemplate_templateFromString_error
{
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:self.templateString
                                                                    error:NULL];
    GRMustacheTemplateFromMethodsTestSupport *context = [[[GRMustacheTemplateFromMethodsTestSupport alloc] init] autorelease];
    context.stringProperty = @"foo";
    NSString *rendering = [template renderObject:context];
    STAssertEqualObjects(@"foo", [self valueForStringPropertyInRendering:rendering], nil);
}

- (void)testGRMustacheTemplate_templateFromString_options_error
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

- (void)testGRMustacheTemplate_templateFromContentsOfFile_error
{
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromContentsOfFile:self.templatePath
                                                                            error:NULL];
    GRMustacheTemplateFromMethodsTestSupport *context = [[[GRMustacheTemplateFromMethodsTestSupport alloc] init] autorelease];
    context.stringProperty = @"foo";
    NSString *rendering = [template renderObject:context];
    STAssertEqualObjects(@"foo", [self valueForStringPropertyInRendering:rendering], nil);
}

- (void)testGRMustacheTemplate_templateFromContentsOfFile_options_error
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

- (void)testGRMustacheTemplate_templateFromContentsOfURL_error
{
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromContentsOfURL:self.templateURL
                                                                           error:NULL];
    GRMustacheTemplateFromMethodsTestSupport *context = [[[GRMustacheTemplateFromMethodsTestSupport alloc] init] autorelease];
    context.stringProperty = @"foo";
    NSString *rendering = [template renderObject:context];
    STAssertEqualObjects(@"foo", [self valueForStringPropertyInRendering:rendering], nil);
}

- (void)testGRMustacheTemplate_templateFromContentsOfURL_options_error
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

- (void)testGRMustacheTemplate_templateFromResource_bundle_error
{
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromResource:self.templateName
                                                                     bundle:self.testBundle
                                                                      error:NULL];
    GRMustacheTemplateFromMethodsTestSupport *context = [[[GRMustacheTemplateFromMethodsTestSupport alloc] init] autorelease];
    context.stringProperty = @"foo";
    NSString *rendering = [template renderObject:context];
    STAssertEqualObjects(@"foo", [self valueForStringPropertyInRendering:rendering], nil);
}

- (void)testGRMustacheTemplate_templateFromResource_bundle_options_error
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
    }
}

- (void)testGRMustacheTemplate_templateFromResource_withExtension_bundle_error
{
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromResource:self.templateName
                                                              withExtension:@"json"
                                                                     bundle:self.testBundle
                                                                      error:NULL];
    GRMustacheTemplateFromMethodsTestSupport *context = [[[GRMustacheTemplateFromMethodsTestSupport alloc] init] autorelease];
    context.stringProperty = @"foo";
    NSString *rendering = [template renderObject:context];
    STAssertEqualObjects(@"foo", [self valueForStringPropertyInRendering:rendering], nil);
}

- (void)testGRMustacheTemplate_templateFromResource_withExtension_bundle_options_error
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
    }
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
    }
}

@end
