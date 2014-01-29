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

@interface GRMustacheLocalizerTest : GRMustachePublicAPITest {
    NSBundle *_localizableBundle;
    GRMustacheLocalizer *_localizer;
}
@property (nonatomic, retain) NSBundle *localizableBundle;
@property (nonatomic, retain) GRMustacheLocalizer *localizer;
@end

@implementation GRMustacheLocalizerTest
@synthesize localizableBundle=_localizableBundle;
@synthesize localizer=_localizer;

- (void)setUp
{
    NSString *path = [[self testBundle] pathForResource:@"GRMustacheLocalizerTestBundle" ofType:nil];
    self.localizableBundle = [NSBundle bundleWithPath:path];
    self.localizer = [[[GRMustacheLocalizer alloc] initWithBundle:self.localizableBundle tableName:nil] autorelease];
}

- (void)tearDown
{
    self.localizableBundle = nil;
    self.localizer = nil;
}

- (void)testLocalizableBundle
{
    NSString *testable = [self.localizableBundle localizedStringForKey:@"testable?" value:@"" table:nil];
    STAssertEqualObjects(testable, @"YES", @"");
}

- (void)testLocalizer
{
    NSString *templateString = @"{{localize(string)}}";
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:templateString error:NULL];
    id data = @{ @"localize": self.localizer, @"string": @"testable?" };
    NSString *rendering = [template renderObject:data error:NULL];
    STAssertEqualObjects(rendering, @"YES", @"");
}

- (void)testLocalizerFromTable
{
    NSString *templateString = @"{{localize(string)}}";
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:templateString error:NULL];
    GRMustacheLocalizer *localizer = [[[GRMustacheLocalizer alloc] initWithBundle:self.localizableBundle tableName:@"Table"] autorelease];
    id data = @{ @"localize": localizer, @"string": @"table_testable?" };
    NSString *rendering = [template renderObject:data error:NULL];
    STAssertEqualObjects(rendering, @"YES", @"");
}

- (void)testDefaultLocalizerAsFilter
{
    NSString *templateString = @"{{localize(foo)}}";
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:templateString error:NULL];
    id data = @{ @"foo": @"bar" };
    NSString *rendering = [template renderObject:data error:NULL];
    STAssertEqualObjects(rendering, @"bar", @"");
}

- (void)testDefaultLocalizerAsRenderingObject
{
    NSString *templateString = @"{{#localize}}...{{/}}";
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:templateString error:NULL];
    NSString *rendering = [template renderObject:nil error:NULL];
    STAssertEqualObjects(rendering, @"...", @"");
}

- (void)testDefaultLocalizerAsRenderingObjectWithArgument
{
    NSString *templateString = @"{{#localize}}..{{foo}}..{{/}}";
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:templateString error:NULL];
    id data = @{ @"foo": @"bar" };
    NSString *rendering = [template renderObject:data error:NULL];
    STAssertEqualObjects(rendering, @"..bar..", @"");
}

- (void)testDefaultLocalizerAsRenderingObjectWithArgumentAndConditions
{
    NSString *templateString = @"{{#localize}}.{{foo}}.{{^false}}{{baz}}{{/}}.{{/}}";
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:templateString error:NULL];
    id data = @{ @"foo": @"bar", @"baz": @"truc" };
    NSString *rendering = [template renderObject:data error:NULL];
    STAssertEqualObjects(rendering, @".bar.truc.", @"");
}

- (void)testLocalizerAsRenderingObjectWithoutArgumentDoesNotNeedPercentEscapedLocalizedString
{
    {
        NSString *templateString = @"{{#localize}}%d{{/}}";
        GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:templateString error:NULL];
        template.baseContext = [template.baseContext contextByAddingObject:@{ @"localize": self.localizer}];
        NSString *rendering = [template renderObject:nil error:NULL];
        
        // test the raw localization
        STAssertEqualObjects([self.localizer.bundle localizedStringForKey:@"%d" value:nil table:nil], @"ha ha percent d %d", @"");
        
        // test the GRMustache localization
        STAssertEqualObjects(rendering, @"ha ha percent d %d", @"");
    }
    {
        NSString *templateString = @"{{#localize}}%@{{/}}";
        GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:templateString error:NULL];
        template.baseContext = [template.baseContext contextByAddingObject:@{ @"localize": self.localizer}];
        NSString *rendering = [template renderObject:nil error:NULL];
        
        // test the raw localization
        STAssertEqualObjects([self.localizer.bundle localizedStringForKey:@"%@" value:nil table:nil], @"ha ha percent @ %@", @"");
        
        // test the GRMustache localization
        STAssertEqualObjects(rendering, @"ha ha percent @ %@", @"");
    }
}

- (void)testLocalizerAsRenderingObjectWithoutArgumentNeedsPercentEscapedLocalizedString
{
    {
        NSString *templateString = @"{{#localize}}%d {{foo}}{{/}}";
        GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:templateString error:NULL];
        template.baseContext = [template.baseContext contextByAddingObject:@{ @"localize": self.localizer}];
        id data = @{ @"foo": @"bar" };
        NSString *rendering = [template renderObject:data error:NULL];
        
        // test the raw localization
        STAssertEqualObjects([self.localizer.bundle localizedStringForKey:@"%%d %@" value:nil table:nil], @"ha ha percent d %%d %@", @"");
        
        // test the GRMustache localization
        STAssertEqualObjects(rendering, @"ha ha percent d %d bar", @"");
    }
    {
        NSString *templateString = @"{{#localize}}%@ {{foo}}{{/}}";
        GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:templateString error:NULL];
        template.baseContext = [template.baseContext contextByAddingObject:@{ @"localize": self.localizer}];
        id data = @{ @"foo": @"bar" };
        NSString *rendering = [template renderObject:data error:NULL];
        
        // test the raw localization
        STAssertEqualObjects([self.localizer.bundle localizedStringForKey:@"%%@ %@" value:nil table:nil], @"ha ha percent @ %%@ %@", @"");
        
        // test the GRMustache localization
        STAssertEqualObjects(rendering, @"ha ha percent @ %@ bar", @"");
    }
}

- (void)testCustomLocalizerAsFilter
{
    NSString *templateString = @"{{localize(foo)}}";
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:templateString error:NULL];
    template.baseContext = [template.baseContext contextByAddingObject:@{ @"localize": self.localizer}];
    id data = @{ @"foo": @"bar" };
    NSString *rendering = [template renderObject:data error:NULL];
    
    // test the raw localization
    STAssertEqualObjects([self.localizer.bundle localizedStringForKey:@"bar" value:nil table:nil], @"translated_bar", @"");

    // test the GRMustache localization
    STAssertEqualObjects(rendering, @"translated_bar", @"");
}

- (void)testCustomLocalizerAsRenderingObject
{
    NSString *templateString = @"{{#localize}}...{{/}}";
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:templateString error:NULL];
    template.baseContext = [template.baseContext contextByAddingObject:@{ @"localize": self.localizer}];
    NSString *rendering = [template renderObject:nil error:NULL];

    // test the raw localization
    STAssertEqualObjects([self.localizer.bundle localizedStringForKey:@"..." value:nil table:nil], @"!!!", @"");
    
    // test the GRMustache localization
    STAssertEqualObjects(rendering, @"!!!", @"");
}

- (void)testCustomLocalizerAsRenderingObjectWithArgument
{
    NSString *templateString = @"{{#localize}}..{{foo}}..{{/}}";
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:templateString error:NULL];
    template.baseContext = [template.baseContext contextByAddingObject:@{ @"localize": self.localizer}];
    id data = @{ @"foo": @"bar" };
    NSString *rendering = [template renderObject:data error:NULL];
    
    // test the raw localization
    STAssertEqualObjects([self.localizer.bundle localizedStringForKey:@"..%@.." value:nil table:nil], @"!!%@!!", @"");
    
    // test the GRMustache localization
    STAssertEqualObjects(rendering, @"!!bar!!", @"");
}

- (void)testCustomLocalizerAsRenderingObjectWithArgumentAndConditions
{
    NSString *templateString = @"{{#localize}}.{{foo}}.{{^false}}{{baz}}{{/}}.{{/}}";
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:templateString error:NULL];
    template.baseContext = [template.baseContext contextByAddingObject:@{ @"localize": self.localizer}];
    id data = @{ @"foo": @"bar", @"baz": @"truc" };
    NSString *rendering = [template renderObject:data error:NULL];
    
    // test the raw localization
    STAssertEqualObjects([self.localizer.bundle localizedStringForKey:@".%@.%@." value:nil table:nil], @"!%@!%@!", @"");
    
    // test the GRMustache localization
    STAssertEqualObjects(rendering, @"!bar!truc!", @"");
}

- (void)testLocalizerRendersHTMLEscapedValuesOfHTMLTemplates
{
    {
        NSString *templateString = @"{{#localize}}..{{foo}}..{{/}}";
        GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:templateString error:NULL];
        id data = @{ @"foo": @"&" };
        NSString *rendering = [template renderObject:data error:NULL];
        STAssertEqualObjects(rendering, @"..&amp;..", @"");
    }
    {
        NSString *templateString = @"{{#localize}}..{{{foo}}}..{{/}}";
        GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:templateString error:NULL];
        id data = @{ @"foo": @"&" };
        NSString *rendering = [template renderObject:data error:NULL];
        STAssertEqualObjects(rendering, @"..&..", @"");
    }
}

- (void)testLocalizerRendersUnescapedValuesOfTextTemplates
{
    {
        NSString *templateString = @"{{% CONTENT_TYPE:TEXT }}{{#localize}}..{{foo}}..{{/}}";
        GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:templateString error:NULL];
        id data = @{ @"foo": @"&" };
        NSString *rendering = [template renderObject:data error:NULL];
        STAssertEqualObjects(rendering, @"..&..", @"");
    }
    {
        NSString *templateString = @"{{% CONTENT_TYPE:TEXT }}{{#localize}}..{{{foo}}}..{{/}}";
        GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:templateString error:NULL];
        id data = @{ @"foo": @"&" };
        NSString *rendering = [template renderObject:data error:NULL];
        STAssertEqualObjects(rendering, @"..&..", @"");
    }
}

@end
