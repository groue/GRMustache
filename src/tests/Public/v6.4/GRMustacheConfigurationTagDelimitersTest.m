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

#define GRMUSTACHE_VERSION_MAX_ALLOWED GRMUSTACHE_VERSION_6_4
#import "GRMustachePublicAPITest.h"

@interface GRMustacheConfigurationTagDelimitersTest : GRMustachePublicAPITest
@end

static BOOL defaultConfigurationHasBeenTouched = NO;

@implementation GRMustacheConfigurationTagDelimitersTest

- (void)tearDown
{
    [super tearDown];
    
    // Restore default configuration
    [GRMustacheConfiguration defaultConfiguration].tagStartDelimiter = @"{{";
    [GRMustacheConfiguration defaultConfiguration].tagEndDelimiter = @"}}";
    
    // Help test1DefaultConfigurationHasDoubleBracesTagDelimiters test the *real* default
    // configuration.
    defaultConfigurationHasBeenTouched = YES;
}

// The goal is to have this test run first.
// It looks that alphabetical order is applied: hence the digit 1 in the method name.
- (void)test1DefaultConfigurationHasDoubleBracesTagDelimiters
{
    STAssertFalse(defaultConfigurationHasBeenTouched, @"this test should run first.");
    STAssertNotNil([GRMustacheConfiguration defaultConfiguration], @"");
    STAssertEqualObjects([GRMustacheConfiguration defaultConfiguration].tagStartDelimiter, @"{{", @"");
    STAssertEqualObjects([GRMustacheConfiguration defaultConfiguration].tagEndDelimiter, @"}}", @"");
}

- (void)testFactoryConfigurationHasMustacheTagDelimitersRegardlessOfDefaultConfiguration
{
    [GRMustacheConfiguration defaultConfiguration].tagStartDelimiter = @"<%";
    [GRMustacheConfiguration defaultConfiguration].tagEndDelimiter = @"%>";
    GRMustacheConfiguration *configuration = [GRMustacheConfiguration configuration];
    STAssertNotNil(configuration, @"");
    STAssertEqualObjects(configuration.tagStartDelimiter, @"{{", @"");
    STAssertEqualObjects(configuration.tagEndDelimiter, @"}}", @"");
}

- (void)testDefaultConfigurationMustacheTagDelimiters
{
    [GRMustacheConfiguration defaultConfiguration].tagStartDelimiter = @"<%";
    [GRMustacheConfiguration defaultConfiguration].tagEndDelimiter = @"%>";
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"<%subject%>" error:NULL];
    NSString *rendering = [template renderObject:@{@"subject":@"---"} error:NULL];
    STAssertEqualObjects(rendering, @"---", @"");
}

- (void)testSetDelimitersTagOverridesDefaultConfigurationDelimiters
{
    [GRMustacheConfiguration defaultConfiguration].tagStartDelimiter = @"<%";
    [GRMustacheConfiguration defaultConfiguration].tagEndDelimiter = @"%>";
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"<%=[[ ]]=%>[[subject]]" error:NULL];
    NSString *rendering = [template renderObject:@{@"subject":@"---"} error:NULL];
    STAssertEqualObjects(rendering, @"---", @"");
}

- (void)testDefaultRepositoryConfigurationHasDefaultConfigurationTagDelimiters
{
    [GRMustacheConfiguration defaultConfiguration].tagStartDelimiter = @"<%";
    [GRMustacheConfiguration defaultConfiguration].tagEndDelimiter = @"%>";
    GRMustacheTemplateRepository *repo = [GRMustacheTemplateRepository templateRepository];
    STAssertEqualObjects(repo.configuration.tagStartDelimiter, [GRMustacheConfiguration defaultConfiguration].tagStartDelimiter, @"");
    STAssertEqualObjects(repo.configuration.tagEndDelimiter, [GRMustacheConfiguration defaultConfiguration].tagEndDelimiter, @"");
}

- (void)testRepositoryConfigurationTagDelimiters
{
    {
        // Setting the whole configuration
        GRMustacheConfiguration *configuration = [GRMustacheConfiguration configuration];
        configuration.tagStartDelimiter = @"<%";
        configuration.tagEndDelimiter = @"%>";
        
        GRMustacheTemplateRepository *repo = [GRMustacheTemplateRepository templateRepository];
        repo.configuration = configuration;
        
        GRMustacheTemplate *template = [repo templateFromString:@"<%subject%>" error:NULL];
        NSString *rendering = [template renderObject:@{@"subject":@"---"} error:NULL];
        STAssertEqualObjects(rendering, @"---", @"");
    }
    {
        // Setting configuration property
        GRMustacheTemplateRepository *repo = [GRMustacheTemplateRepository templateRepository];
        repo.configuration.tagStartDelimiter = @"<%";
        repo.configuration.tagEndDelimiter = @"%>";
        
        GRMustacheTemplate *template = [repo templateFromString:@"<%subject%>" error:NULL];
        NSString *rendering = [template renderObject:@{@"subject":@"---"} error:NULL];
        STAssertEqualObjects(rendering, @"---", @"");
    }
}

- (void)testRepositoryConfigurationTagDelimitersOverridesDefaultConfigurationTagDelimiters
{
    {
        // Setting the whole configuration
        [GRMustacheConfiguration defaultConfiguration].tagStartDelimiter = @"<%";
        [GRMustacheConfiguration defaultConfiguration].tagEndDelimiter = @"%>";
        
        GRMustacheConfiguration *configuration = [GRMustacheConfiguration configuration];
        configuration.tagStartDelimiter = @"[[";
        configuration.tagEndDelimiter = @"]]";
        
        GRMustacheTemplateRepository *repo = [GRMustacheTemplateRepository templateRepository];
        repo.configuration = configuration;
        
        GRMustacheTemplate *template = [repo templateFromString:@"[[subject]]" error:NULL];
        NSString *rendering = [template renderObject:@{@"subject":@"---"} error:NULL];
        STAssertEqualObjects(rendering, @"---", @"");
    }
    {
        // Setting configuration property
        [GRMustacheConfiguration defaultConfiguration].tagStartDelimiter = @"<%";
        [GRMustacheConfiguration defaultConfiguration].tagEndDelimiter = @"%>";
        
        GRMustacheTemplateRepository *repo = [GRMustacheTemplateRepository templateRepository];
        repo.configuration.tagStartDelimiter = @"[[";
        repo.configuration.tagEndDelimiter = @"]]";
        
        GRMustacheTemplate *template = [repo templateFromString:@"[[subject]]" error:NULL];
        NSString *rendering = [template renderObject:@{@"subject":@"---"} error:NULL];
        STAssertEqualObjects(rendering, @"---", @"");
    }
}

- (void)testSetDelimitersTagOverridesRepositoryConfigurationTagDelimiters
{
    {
        // Setting the whole configuration
        GRMustacheConfiguration *configuration = [GRMustacheConfiguration configuration];
        configuration.tagStartDelimiter = @"<%";
        configuration.tagEndDelimiter = @"%>";
        
        GRMustacheTemplateRepository *repo = [GRMustacheTemplateRepository templateRepository];
        repo.configuration = configuration;
        
        GRMustacheTemplate *template = [repo templateFromString:@"<%=[[ ]]=%>[[subject]]" error:NULL];
        NSString *rendering = [template renderObject:@{@"subject":@"---"} error:NULL];
        STAssertEqualObjects(rendering, @"---", @"");
    }
    {
        // Setting configuration property
        GRMustacheTemplateRepository *repo = [GRMustacheTemplateRepository templateRepository];
        repo.configuration.tagStartDelimiter = @"<%";
        repo.configuration.tagEndDelimiter = @"%>";
        
        GRMustacheTemplate *template = [repo templateFromString:@"<%=[[ ]]=%>[[subject]]" error:NULL];
        NSString *rendering = [template renderObject:@{@"subject":@"---"} error:NULL];
        STAssertEqualObjects(rendering, @"---", @"");
    }
}

- (void)testRepositoryConfigurationCanBeMutatedBeforeAnyTemplateHasBeenCompiled
{
    GRMustacheTemplateRepository *repo = [GRMustacheTemplateRepository templateRepository];
    STAssertNoThrow([repo.configuration setTagStartDelimiter:@"<%"], @"");
    STAssertNoThrow([repo.configuration setTagStartDelimiter:@"{{"], @"");
    STAssertNoThrow([repo.configuration setTagStartDelimiter:@"[["], @"");
    STAssertNoThrow([repo.configuration setTagEndDelimiter:@"%>"], @"");
    STAssertNoThrow([repo.configuration setTagEndDelimiter:@"}}"], @"");
    STAssertNoThrow([repo.configuration setTagEndDelimiter:@"]]"], @"");
}

- (void)testDefaultConfigurationCanBeMutatedBeforeAnyTemplateHasBeenCompiled
{
    GRMustacheTemplateRepository *repo = [GRMustacheTemplateRepository templateRepository];
    [repo templateFromString:@"" error:NULL];
    
    STAssertNoThrow([[GRMustacheConfiguration defaultConfiguration] setTagStartDelimiter:@"<%"], @"");
    STAssertNoThrow([[GRMustacheConfiguration defaultConfiguration] setTagStartDelimiter:@"{{"], @"");
    STAssertNoThrow([[GRMustacheConfiguration defaultConfiguration] setTagStartDelimiter:@"[["], @"");
    STAssertNoThrow([[GRMustacheConfiguration defaultConfiguration] setTagEndDelimiter:@"%>"], @"");
    STAssertNoThrow([[GRMustacheConfiguration defaultConfiguration] setTagEndDelimiter:@"}}"], @"");
    STAssertNoThrow([[GRMustacheConfiguration defaultConfiguration] setTagEndDelimiter:@"]]"], @"");
}

- (void)testRepositoryConfigurationCanNotBeMutatedAfterATemplateHasBeenCompiled
{
    GRMustacheTemplateRepository *repo = [GRMustacheTemplateRepository templateRepository];
    [repo templateFromString:@"" error:NULL];
    STAssertThrows([repo.configuration setTagStartDelimiter:@"<%"], @"");
    STAssertThrows([repo.configuration setTagStartDelimiter:@"{{"], @"");
    STAssertThrows([repo.configuration setTagEndDelimiter:@"%>"], @"");
    STAssertThrows([repo.configuration setTagEndDelimiter:@"}}"], @"");
    STAssertThrows([repo setConfiguration:[GRMustacheConfiguration configuration]], @"");
}

- (void)testConfigurationTagDelimitersCanNotBeSetToNil
{
    GRMustacheConfiguration *configuration = [GRMustacheConfiguration configuration];
    STAssertThrows([configuration setTagStartDelimiter:nil], @"");
    STAssertThrows([configuration setTagEndDelimiter:nil], @"");
}

- (void)testConfigurationTagDelimitersCanNotBeSetToEmptyString
{
    GRMustacheConfiguration *configuration = [GRMustacheConfiguration configuration];
    STAssertThrows([configuration setTagStartDelimiter:@""], @"");
    STAssertThrows([configuration setTagEndDelimiter:@""], @"");
}

@end
