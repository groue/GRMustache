// The MIT License
//
// Copyright (c) 2013 Gwendal Roué
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

#warning missing GRMUSTACHE_VERSION_MAX_ALLOWED
#import "GRMustachePublicAPITest.h"

@interface GRMustacheLocalizeHelperTest : GRMustachePublicAPITest {
    NSBundle *_localizableBundle;
    GRMustacheLocalizeHelper *_localizeHelper;
}
@property (nonatomic, retain) NSBundle *localizableBundle;
@property (nonatomic, retain) GRMustacheLocalizeHelper *localizeHelper;
@end

@implementation GRMustacheLocalizeHelperTest
@synthesize localizableBundle=_localizableBundle;
@synthesize localizeHelper=_localizeHelper;

- (void)setUp
{
    NSString *path = [[self testBundle] pathForResource:@"GRMustacheLocalizeHelperTestBundle" ofType:nil];
    self.localizableBundle = [NSBundle bundleWithPath:path];
    self.localizeHelper = [[[GRMustacheLocalizeHelper alloc] initWithBundle:self.localizableBundle tableName:nil] autorelease];
}

- (void)tearDown
{
    self.localizableBundle = nil;
    self.localizeHelper = nil;
}

- (void)testLocalizableBundle
{
    NSString *testable = [self.localizableBundle localizedStringForKey:@"testable?" value:@"" table:nil];
    STAssertEqualObjects(testable, @"YES", @"");
}

- (void)testLocalizeHelper
{
    NSString *testable = [self.localizeHelper transformedValue:@"testable?"];
    STAssertEqualObjects(testable, @"YES", @"");
}

- (void)testLocalizeHelperFromTable
{
    GRMustacheLocalizeHelper *helper = [[[GRMustacheLocalizeHelper alloc] initWithBundle:self.localizableBundle tableName:@"Table"] autorelease];
    NSString *testable = [helper transformedValue:@"table_testable?"];
    STAssertEqualObjects(testable, @"YES", @"");
}

- (void)testDefaultLocalizeHelperAsFilter
{
    NSString *templateString = @"{{localize(foo)}}";
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:templateString error:NULL];
    id data = @{ @"foo": @"bar" };
    NSString *rendering = [template renderObject:data error:NULL];
    STAssertEqualObjects(rendering, @"bar", @"");
}

- (void)testDefaultLocalizeHelperAsRenderingObject
{
    NSString *templateString = @"{{#localize}}...{{/}}";
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:templateString error:NULL];
    NSString *rendering = [template renderObject:nil error:NULL];
    STAssertEqualObjects(rendering, @"...", @"");
}

- (void)testDefaultLocalizeHelperAsRenderingObjectWithArgument
{
    NSString *templateString = @"{{#localize}}..{{foo}}..{{/}}";
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:templateString error:NULL];
    id data = @{ @"foo": @"bar" };
    NSString *rendering = [template renderObject:data error:NULL];
    STAssertEqualObjects(rendering, @"..bar..", @"");
}

- (void)testDefaultLocalizeHelperAsRenderingObjectWithArgumentAndConditions
{
    NSString *templateString = @"{{#localize}}.{{foo}}.{{^false}}{{baz}}{{/}}.{{/}}";
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:templateString error:NULL];
    id data = @{ @"foo": @"bar", @"baz": @"truc" };
    NSString *rendering = [template renderObject:data error:NULL];
    STAssertEqualObjects(rendering, @".bar.truc.", @"");
}

- (void)testCustomLocalizeHelperAsFilter
{
    NSString *templateString = @"{{localize(foo)}}";
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:templateString error:NULL];
    template.baseContext = [template.baseContext contextByAddingObject:@{ @"localize": self.localizeHelper}];
    id data = @{ @"foo": @"bar" };
    NSString *rendering = [template renderObject:data error:NULL];
    
    // test the raw localization
    STAssertEqualObjects([self.localizeHelper.bundle localizedStringForKey:@"bar" value:nil table:nil], @"translated_bar", @"");

    // test the GRMustache localization
    STAssertEqualObjects(rendering, @"translated_bar", @"");
}

- (void)testCustomLocalizeHelperAsRenderingObject
{
    NSString *templateString = @"{{#localize}}...{{/}}";
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:templateString error:NULL];
    template.baseContext = [template.baseContext contextByAddingObject:@{ @"localize": self.localizeHelper}];
    NSString *rendering = [template renderObject:nil error:NULL];

    // test the raw localization
    STAssertEqualObjects([self.localizeHelper.bundle localizedStringForKey:@"..." value:nil table:nil], @"!!!", @"");
    
    // test the GRMustache localization
    STAssertEqualObjects(rendering, @"!!!", @"");
}

- (void)testCustomLocalizeHelperAsRenderingObjectWithArgument
{
    NSString *templateString = @"{{#localize}}..{{foo}}..{{/}}";
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:templateString error:NULL];
    template.baseContext = [template.baseContext contextByAddingObject:@{ @"localize": self.localizeHelper}];
    id data = @{ @"foo": @"bar" };
    NSString *rendering = [template renderObject:data error:NULL];
    
    // test the raw localization
    STAssertEqualObjects([self.localizeHelper.bundle localizedStringForKey:@"..%@.." value:nil table:nil], @"!!%@!!", @"");
    
    // test the GRMustache localization
    STAssertEqualObjects(rendering, @"!!bar!!", @"");
}

- (void)testCustomLocalizeHelperAsRenderingObjectWithArgumentAndConditions
{
    NSString *templateString = @"{{#localize}}.{{foo}}.{{^false}}{{baz}}{{/}}.{{/}}";
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:templateString error:NULL];
    template.baseContext = [template.baseContext contextByAddingObject:@{ @"localize": self.localizeHelper}];
    id data = @{ @"foo": @"bar", @"baz": @"truc" };
    NSString *rendering = [template renderObject:data error:NULL];
    
    // test the raw localization
    STAssertEqualObjects([self.localizeHelper.bundle localizedStringForKey:@".%@.%@." value:nil table:nil], @"!%@!%@!", @"");
    
    // test the GRMustache localization
    STAssertEqualObjects(rendering, @"!bar!truc!", @"");
}

@end
