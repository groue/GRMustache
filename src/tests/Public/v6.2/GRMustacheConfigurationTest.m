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

#define GRMUSTACHE_VERSION_MAX_ALLOWED GRMUSTACHE_VERSION_6_2
#import "GRMustachePublicAPITest.h"

@interface GRMustacheConfigurationTest : GRMustachePublicAPITest
@end

static BOOL defaultConfigurationHasBeenTouched = NO;

@implementation GRMustacheConfigurationTest

- (void)tearDown
{
    [super tearDown];
    
    // Restore default configuration
    [GRMustacheConfiguration defaultConfiguration].contentType = GRMustacheContentTypeHTML;
    
    // Help test1DefaultConfigurationHasHTMLContentType test the *real* default
    // configuration.
    defaultConfigurationHasBeenTouched = YES;
}

// The goal is to have this test run first.
// It looks that alphabetical order is applied: hence the digit 1 in the method name.
- (void)test1DefaultConfigurationHasHTMLContentType
{
    STAssertFalse(defaultConfigurationHasBeenTouched, @"this test should run first.");
    STAssertNotNil([GRMustacheConfiguration defaultConfiguration], @"");
    STAssertEquals([GRMustacheConfiguration defaultConfiguration].contentType, GRMustacheContentTypeHTML, @"");
}

- (void)testFactoryConfigurationHasHTMLContentTypeRegardlessOfDefaultConfiguration
{
    {
        [GRMustacheConfiguration defaultConfiguration].contentType = GRMustacheContentTypeHTML;
        GRMustacheConfiguration *configuration = [GRMustacheConfiguration configuration];
        STAssertNotNil(configuration, @"");
        STAssertEquals(configuration.contentType, GRMustacheContentTypeHTML, @"");
    }
    {
        [GRMustacheConfiguration defaultConfiguration].contentType = GRMustacheContentTypeText;
        GRMustacheConfiguration *configuration = [GRMustacheConfiguration configuration];
        STAssertNotNil(configuration, @"");
        STAssertEquals(configuration.contentType, GRMustacheContentTypeHTML, @"");
    }
}

- (void)testDefaultConfigurationContentTypeHTMLHasTemplateRenderEscapedInput
{
    [GRMustacheConfiguration defaultConfiguration].contentType = GRMustacheContentTypeHTML;
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{subject}}" error:NULL];
    NSString *rendering = [template renderObject:@{@"subject":@"&"} error:NULL];
    STAssertEqualObjects(rendering, @"&amp;", @"");
}

- (void)testDefaultConfigurationContentTypeTextHasTemplateRenderRawInput
{
    [GRMustacheConfiguration defaultConfiguration].contentType = GRMustacheContentTypeText;
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{subject}}" error:NULL];
    NSString *rendering = [template renderObject:@{@"subject":@"&"} error:NULL];
    STAssertEqualObjects(rendering, @"&", @"");
}

- (void)testDefaultConfigurationContentTypeHTMLHasTemplateRenderHTMLSafeStrings
{
    [GRMustacheConfiguration defaultConfiguration].contentType = GRMustacheContentTypeHTML;
    
    // Templates tell if they render HTML or text via the HTMLSafe output of the
    // -[GRMustacheTemplate renderContentWithContext:HTMLSafe:error:] method.
    //
    // There is no public way to build a context.
    //
    // Thus we'll use a rendering object that will provide us with one:
    
    GRMustacheTemplate *testedTemplate = [GRMustacheTemplate templateFromString:@"" error:NULL];
    __block BOOL testedHTMLSafeDefined = NO;
    __block BOOL testedHTMLSafe = NO;
    id object = [GRMustache renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
        NSString *rendering = [testedTemplate renderContentWithContext:context HTMLSafe:HTMLSafe error:error];
        testedHTMLSafe = *HTMLSafe;
        testedHTMLSafeDefined = YES;
        return rendering;
    }];
    id data = @{@"object": object};
    [GRMustacheTemplate renderObject:data fromString:@"{{object}}" error:NULL];
    STAssertTrue(testedHTMLSafeDefined, @"WTF");
    STAssertTrue(testedHTMLSafe, @"WTF");
}

- (void)testDefaultConfigurationContentTypeTextHasTemplateRenderHTMLUnsafeStrings
{
    [GRMustacheConfiguration defaultConfiguration].contentType = GRMustacheContentTypeText;
    
    // Templates tell if they render HTML or text via the HTMLSafe output of the
    // -[GRMustacheTemplate renderContentWithContext:HTMLSafe:error:] method.
    //
    // There is no public way to build a context.
    //
    // Thus we'll use a rendering object that will provide us with one:
    
    GRMustacheTemplate *testedTemplate = [GRMustacheTemplate templateFromString:@"" error:NULL];
    __block BOOL testedHTMLSafeDefined = NO;
    __block BOOL testedHTMLSafe = NO;
    id object = [GRMustache renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
        NSString *rendering = [testedTemplate renderContentWithContext:context HTMLSafe:HTMLSafe error:error];
        testedHTMLSafe = *HTMLSafe;
        testedHTMLSafeDefined = YES;
        return rendering;
    }];
    id data = @{@"object": object};
    [GRMustacheTemplate renderObject:data fromString:@"{{object}}" error:NULL];
    STAssertTrue(testedHTMLSafeDefined, @"WTF");
    STAssertFalse(testedHTMLSafe, @"WTF");
}

- (void)testDefaultConfigurationContentTypeHTMLHasSectionTagRenderHTMLSafeStrings
{
    [GRMustacheConfiguration defaultConfiguration].contentType = GRMustacheContentTypeHTML;
    
    __block BOOL testedHTMLSafeDefined = NO;
    __block BOOL testedHTMLSafe = NO;
    id object = [GRMustache renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
        NSString *rendering = [tag renderContentWithContext:context HTMLSafe:HTMLSafe error:error];
        testedHTMLSafe = *HTMLSafe;
        testedHTMLSafeDefined = YES;
        return rendering;
    }];
    id data = @{@"object": object};
    [GRMustacheTemplate renderObject:data fromString:@"{{#object}}{{/object}}" error:NULL];
    STAssertTrue(testedHTMLSafeDefined, @"WTF");
    STAssertTrue(testedHTMLSafe, @"WTF");
}

- (void)testDefaultConfigurationContentTypeTextHasSectionTagRenderHTMLUnsafeStrings
{
    [GRMustacheConfiguration defaultConfiguration].contentType = GRMustacheContentTypeText;
    
    __block BOOL testedHTMLSafeDefined = NO;
    __block BOOL testedHTMLSafe = NO;
    id object = [GRMustache renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
        NSString *rendering = [tag renderContentWithContext:context HTMLSafe:HTMLSafe error:error];
        testedHTMLSafe = *HTMLSafe;
        testedHTMLSafeDefined = YES;
        return rendering;
    }];
    id data = @{@"object": object};
    [GRMustacheTemplate renderObject:data fromString:@"{{#object}}{{/object}}" error:NULL];
    STAssertTrue(testedHTMLSafeDefined, @"WTF");
    STAssertFalse(testedHTMLSafe, @"WTF");
}

- (void)testDefaultConfigurationContentTypeHTMLHasVariableTagRenderHTMLSafeStrings
{
    [GRMustacheConfiguration defaultConfiguration].contentType = GRMustacheContentTypeHTML;
    
    __block BOOL testedHTMLSafeDefined = NO;
    __block BOOL testedHTMLSafe = NO;
    id object = [GRMustache renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
        NSString *rendering = [tag renderContentWithContext:context HTMLSafe:HTMLSafe error:error];
        testedHTMLSafe = *HTMLSafe;
        testedHTMLSafeDefined = YES;
        return rendering;
    }];
    id data = @{@"object": object};
    [GRMustacheTemplate renderObject:data fromString:@"{{object}}" error:NULL];
    STAssertTrue(testedHTMLSafeDefined, @"WTF");
    STAssertTrue(testedHTMLSafe, @"WTF");
}

- (void)testDefaultConfigurationContentTypeTextHasVariableTagRenderHTMLUnsafeStrings
{
    [GRMustacheConfiguration defaultConfiguration].contentType = GRMustacheContentTypeText;
    
    __block BOOL testedHTMLSafeDefined = NO;
    __block BOOL testedHTMLSafe = NO;
    id object = [GRMustache renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
        NSString *rendering = [tag renderContentWithContext:context HTMLSafe:HTMLSafe error:error];
        testedHTMLSafe = *HTMLSafe;
        testedHTMLSafeDefined = YES;
        return rendering;
    }];
    id data = @{@"object": object};
    [GRMustacheTemplate renderObject:data fromString:@"{{object}}" error:NULL];
    STAssertTrue(testedHTMLSafeDefined, @"WTF");
    STAssertFalse(testedHTMLSafe, @"WTF");
}

- (void)testCONTENT_TYPE_TEXTPragmaTagOverridesDefaultConfigurationContentTypeHTML
{
    [GRMustacheConfiguration defaultConfiguration].contentType = GRMustacheContentTypeHTML;
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{%CONTENT_TYPE:TEXT}}{{subject}}" error:NULL];
    NSString *rendering = [template renderObject:@{@"subject":@"&"} error:NULL];
    STAssertEqualObjects(rendering, @"&", @"");
}

- (void)testCONTENT_TYPE_HTMLPragmaTagOverridesDefaultConfigurationContentTypeText
{
    [GRMustacheConfiguration defaultConfiguration].contentType = GRMustacheContentTypeText;
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{%CONTENT_TYPE:HTML}}{{subject}}" error:NULL];
    NSString *rendering = [template renderObject:@{@"subject":@"&"} error:NULL];
    STAssertEqualObjects(rendering, @"&amp;", @"");
}

- (void)testDefaultRepositoryConfigurationHasDefaultConfigurationContentType
{
    {
        [GRMustacheConfiguration defaultConfiguration].contentType = GRMustacheContentTypeHTML;
        GRMustacheTemplateRepository *repo = [GRMustacheTemplateRepository templateRepository];
        STAssertEquals(repo.configuration.contentType, [GRMustacheConfiguration defaultConfiguration].contentType, @"");
    }
    {
        [GRMustacheConfiguration defaultConfiguration].contentType = GRMustacheContentTypeText;
        GRMustacheTemplateRepository *repo = [GRMustacheTemplateRepository templateRepository];
        STAssertEquals(repo.configuration.contentType, [GRMustacheConfiguration defaultConfiguration].contentType, @"");
    }
}

- (void)testRepositoryConfigurationContentTypeHTMLHasTemplateRenderEscapedInput
{
    {
        // Setting the whole configuration
        GRMustacheConfiguration *configuration = [GRMustacheConfiguration configuration];
        configuration.contentType = GRMustacheContentTypeHTML;
        
        GRMustacheTemplateRepository *repo = [GRMustacheTemplateRepository templateRepository];
        repo.configuration = configuration;
        
        GRMustacheTemplate *template = [repo templateFromString:@"{{subject}}" error:NULL];
        NSString *rendering = [template renderObject:@{@"subject":@"&"} error:NULL];
        STAssertEqualObjects(rendering, @"&amp;", @"");
    }
    {
        // Setting configuration property
        GRMustacheTemplateRepository *repo = [GRMustacheTemplateRepository templateRepository];
        repo.configuration.contentType = GRMustacheContentTypeHTML;
        
        GRMustacheTemplate *template = [repo templateFromString:@"{{subject}}" error:NULL];
        NSString *rendering = [template renderObject:@{@"subject":@"&"} error:NULL];
        STAssertEqualObjects(rendering, @"&amp;", @"");
    }
}

- (void)testRepositoryConfigurationContentTypeTextHasTemplateRenderRawInput
{
    {
        // Setting the whole configuration
        GRMustacheConfiguration *configuration = [GRMustacheConfiguration configuration];
        configuration.contentType = GRMustacheContentTypeText;
        
        GRMustacheTemplateRepository *repo = [GRMustacheTemplateRepository templateRepository];
        repo.configuration = configuration;
        
        GRMustacheTemplate *template = [repo templateFromString:@"{{subject}}" error:NULL];
        NSString *rendering = [template renderObject:@{@"subject":@"&"} error:NULL];
        STAssertEqualObjects(rendering, @"&", @"");
    }
    {
        // Setting configuration property
        GRMustacheTemplateRepository *repo = [GRMustacheTemplateRepository templateRepository];
        repo.configuration.contentType = GRMustacheContentTypeText;
        
        GRMustacheTemplate *template = [repo templateFromString:@"{{subject}}" error:NULL];
        NSString *rendering = [template renderObject:@{@"subject":@"&"} error:NULL];
        STAssertEqualObjects(rendering, @"&", @"");
    }
}

- (void)testRepositoryConfigurationContentTypeTextOverridesDefaultConfigurationContentTypeHTML
{
    {
        // Setting the whole configuration
        [GRMustacheConfiguration defaultConfiguration].contentType = GRMustacheContentTypeHTML;
        
        GRMustacheConfiguration *configuration = [GRMustacheConfiguration configuration];
        configuration.contentType = GRMustacheContentTypeText;
        
        GRMustacheTemplateRepository *repo = [GRMustacheTemplateRepository templateRepository];
        repo.configuration = configuration;
        
        GRMustacheTemplate *template = [repo templateFromString:@"{{subject}}" error:NULL];
        NSString *rendering = [template renderObject:@{@"subject":@"&"} error:NULL];
        STAssertEqualObjects(rendering, @"&", @"");
    }
    {
        // Setting configuration property
        [GRMustacheConfiguration defaultConfiguration].contentType = GRMustacheContentTypeHTML;
        
        GRMustacheTemplateRepository *repo = [GRMustacheTemplateRepository templateRepository];
        repo.configuration.contentType = GRMustacheContentTypeText;
        
        GRMustacheTemplate *template = [repo templateFromString:@"{{subject}}" error:NULL];
        NSString *rendering = [template renderObject:@{@"subject":@"&"} error:NULL];
        STAssertEqualObjects(rendering, @"&", @"");
    }
}

- (void)testRepositoryConfigurationContentTypeHTMLOverridesDefaultConfigurationContentTypeText
{
    {
        // Setting the whole configuration
        [GRMustacheConfiguration defaultConfiguration].contentType = GRMustacheContentTypeText;
        
        GRMustacheConfiguration *configuration = [GRMustacheConfiguration configuration];
        configuration.contentType = GRMustacheContentTypeHTML;
        
        GRMustacheTemplateRepository *repo = [GRMustacheTemplateRepository templateRepository];
        repo.configuration = configuration;
        
        GRMustacheTemplate *template = [repo templateFromString:@"{{subject}}" error:NULL];
        NSString *rendering = [template renderObject:@{@"subject":@"&"} error:NULL];
        STAssertEqualObjects(rendering, @"&amp;", @"");
    }
    {
        // Setting configuration property
        [GRMustacheConfiguration defaultConfiguration].contentType = GRMustacheContentTypeText;
        
        GRMustacheTemplateRepository *repo = [GRMustacheTemplateRepository templateRepository];
        repo.configuration.contentType = GRMustacheContentTypeHTML;
        
        GRMustacheTemplate *template = [repo templateFromString:@"{{subject}}" error:NULL];
        NSString *rendering = [template renderObject:@{@"subject":@"&"} error:NULL];
        STAssertEqualObjects(rendering, @"&amp;", @"");
    }
}

- (void)testCONTENT_TYPE_TEXTPragmaTagOverridesRepositoryConfigurationContentTypeHTML
{
    {
        // Setting the whole configuration
        GRMustacheConfiguration *configuration = [GRMustacheConfiguration configuration];
        configuration.contentType = GRMustacheContentTypeHTML;
        
        GRMustacheTemplateRepository *repo = [GRMustacheTemplateRepository templateRepository];
        repo.configuration = configuration;
        
        GRMustacheTemplate *template = [repo templateFromString:@"{{%CONTENT_TYPE:TEXT}}{{subject}}" error:NULL];
        NSString *rendering = [template renderObject:@{@"subject":@"&"} error:NULL];
        STAssertEqualObjects(rendering, @"&", @"");
    }
    {
        // Setting configuration property
        GRMustacheTemplateRepository *repo = [GRMustacheTemplateRepository templateRepository];
        repo.configuration.contentType = GRMustacheContentTypeHTML;
        
        GRMustacheTemplate *template = [repo templateFromString:@"{{%CONTENT_TYPE:TEXT}}{{subject}}" error:NULL];
        NSString *rendering = [template renderObject:@{@"subject":@"&"} error:NULL];
        STAssertEqualObjects(rendering, @"&", @"");
    }
}

- (void)testCONTENT_TYPE_HTMLPragmaTagOverridesRepositoryConfigurationContentTypeText
{
    {
        // Setting the whole configuration
        GRMustacheConfiguration *configuration = [GRMustacheConfiguration configuration];
        configuration.contentType = GRMustacheContentTypeText;
        
        GRMustacheTemplateRepository *repo = [GRMustacheTemplateRepository templateRepository];
        repo.configuration = configuration;
        
        GRMustacheTemplate *template = [repo templateFromString:@"{{%CONTENT_TYPE:HTML}}{{subject}}" error:NULL];
        NSString *rendering = [template renderObject:@{@"subject":@"&"} error:NULL];
        STAssertEqualObjects(rendering, @"&amp;", @"");
    }
    {
        // Setting configuration property
        GRMustacheTemplateRepository *repo = [GRMustacheTemplateRepository templateRepository];
        repo.configuration.contentType = GRMustacheContentTypeText;
        
        GRMustacheTemplate *template = [repo templateFromString:@"{{%CONTENT_TYPE:HTML}}{{subject}}" error:NULL];
        NSString *rendering = [template renderObject:@{@"subject":@"&"} error:NULL];
        STAssertEqualObjects(rendering, @"&amp;", @"");
    }
}

- (void)testRepositoryConfigurationCanBeMutatedBeforeAnyTemplateHasBeenCompiled
{
    GRMustacheTemplateRepository *repo = [GRMustacheTemplateRepository templateRepository];
    STAssertNoThrow([repo.configuration setContentType:GRMustacheContentTypeText], @"");
    STAssertNoThrow([repo.configuration setContentType:GRMustacheContentTypeHTML], @"");
    STAssertNoThrow([repo.configuration setContentType:GRMustacheContentTypeText], @"");
}

- (void)testDefaultConfigurationCanBeMutatedBeforeAnyTemplateHasBeenCompiled
{
    GRMustacheTemplateRepository *repo = [GRMustacheTemplateRepository templateRepository];
    [repo templateFromString:@"" error:NULL];
    
    STAssertNoThrow([[GRMustacheConfiguration defaultConfiguration] setContentType:GRMustacheContentTypeText], @"");
    STAssertNoThrow([[GRMustacheConfiguration defaultConfiguration] setContentType:GRMustacheContentTypeHTML], @"");
    STAssertNoThrow([[GRMustacheConfiguration defaultConfiguration] setContentType:GRMustacheContentTypeText], @"");
}

- (void)testRepositoryConfigurationCanNotBeMutatedAfterATemplateHasBeenCompiled
{
    GRMustacheTemplateRepository *repo = [GRMustacheTemplateRepository templateRepository];
    [repo templateFromString:@"" error:NULL];
    STAssertThrows([repo.configuration setContentType:GRMustacheContentTypeText], @"");
    STAssertThrows([repo.configuration setContentType:GRMustacheContentTypeHTML], @"");
    STAssertThrows([repo setConfiguration:[GRMustacheConfiguration configuration]], @"");
}


@end
