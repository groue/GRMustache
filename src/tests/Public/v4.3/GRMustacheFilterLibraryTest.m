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

#define GRMUSTACHE_VERSION_MAX_ALLOWED GRMUSTACHE_VERSION_4_3
#import "GRMustachePublicAPITest.h"

@interface GRMustacheFilterLibraryTest : GRMustachePublicAPITest
@end

@implementation GRMustacheFilterLibraryTest

- (void)testCapitalizeFilter
{
    id data = @"name";
    NSString *rendering = [GRMustacheTemplate renderObject:data fromString:@"{{%FILTERS}}{{.|capitalized}}" error:NULL];
    STAssertEqualObjects(rendering, @"Name", nil);
}

- (void)testLowercaseFilter
{
    id data = @"NAME";
    NSString *rendering = [GRMustacheTemplate renderObject:data fromString:@"{{%FILTERS}}{{.|lowercase}}" error:NULL];
    STAssertEqualObjects(rendering, @"name", nil);
}
- (void)testUppercaseFilter
{
    id data = @"name";
    NSString *rendering = [GRMustacheTemplate renderObject:data fromString:@"{{%FILTERS}}{{.|uppercase}}" error:NULL];
    STAssertEqualObjects(rendering, @"NAME", nil);
}

- (void)testFirstFilter
{
    id data = [NSArray arrayWithObjects:@"1", @"2", nil];
    NSString *rendering = [GRMustacheTemplate renderObject:data fromString:@"{{%FILTERS}}{{.|first}}" error:NULL];
    STAssertEqualObjects(rendering, @"1", nil);
}

- (void)testLastFilter
{
    id data = [NSArray arrayWithObjects:@"1", @"2", nil];
    NSString *rendering = [GRMustacheTemplate renderObject:data fromString:@"{{%FILTERS}}{{.|last}}" error:NULL];
    STAssertEqualObjects(rendering, @"2", nil);
}

- (void)testBlankFilter
{
    NSString *templateString = @"{{%FILTERS}}{{#.|blank?}}YES{{/.|blank?}}{{^.|blank?}}NO{{/.|blank?}}";
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:templateString error:NULL];
    
    {
        NSString *rendering = [template renderObject:nil];
        STAssertEqualObjects(rendering, @"YES", nil);
    }
    
    {
        NSString *rendering = [template renderObject:@""];
        STAssertEqualObjects(rendering, @"YES", nil);
    }
    
    {
        NSString *rendering = [template renderObject:@" \t\n"];
        STAssertEqualObjects(rendering, @"YES", nil);
    }
    
    {
        NSString *rendering = [template renderObject:@"hello"];
        STAssertEqualObjects(rendering, @"NO", nil);
    }
    
    {
        NSString *rendering = [template renderObject:[NSArray array]];
        STAssertEqualObjects(rendering, @"YES", nil);
    }
    
    {
        NSString *rendering = [template renderObject:[NSArray arrayWithObject:@""]];
        STAssertEqualObjects(rendering, @"NO", nil);
    }
    
    {
        NSString *rendering = [template renderObject:[NSDictionary dictionary]];
        STAssertEqualObjects(rendering, @"YES", nil);
    }
    
    {
        NSString *rendering = [template renderObject:[NSDictionary dictionaryWithObject:@"" forKey:@""]];
        STAssertEqualObjects(rendering, @"NO", nil);
    }
    
    {
        NSString *rendering = [template renderObject:[NSSet set]];
        STAssertEqualObjects(rendering, @"YES", nil);
    }
    
    {
        NSString *rendering = [template renderObject:[NSSet setWithObject:@""]];
        STAssertEqualObjects(rendering, @"NO", nil);
    }
    
    {
        NSString *rendering = [template renderObject:[[[NSObject alloc] init] autorelease]];
        STAssertEqualObjects(rendering, @"NO", nil);
    }
}

- (void)testEmptyFilter
{
    NSString *templateString = @"{{%FILTERS}}{{#.|empty?}}YES{{/.|empty?}}{{^.|empty?}}NO{{/.|empty?}}";
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:templateString error:NULL];
    
    {
        NSString *rendering = [template renderObject:nil];
        STAssertEqualObjects(rendering, @"YES", nil);
    }
    
    {
        NSString *rendering = [template renderObject:@""];
        STAssertEqualObjects(rendering, @"YES", nil);
    }
    
    {
        NSString *rendering = [template renderObject:@" \t\n"];
        STAssertEqualObjects(rendering, @"NO", nil);
    }
    
    {
        NSString *rendering = [template renderObject:@"hello"];
        STAssertEqualObjects(rendering, @"NO", nil);
    }
    
    {
        NSString *rendering = [template renderObject:[NSArray array]];
        STAssertEqualObjects(rendering, @"YES", nil);
    }
    
    {
        NSString *rendering = [template renderObject:[NSArray arrayWithObject:@""]];
        STAssertEqualObjects(rendering, @"NO", nil);
    }
    
    {
        NSString *rendering = [template renderObject:[NSDictionary dictionary]];
        STAssertEqualObjects(rendering, @"YES", nil);
    }
    
    {
        NSString *rendering = [template renderObject:[NSDictionary dictionaryWithObject:@"" forKey:@""]];
        STAssertEqualObjects(rendering, @"NO", nil);
    }
    
    {
        NSString *rendering = [template renderObject:[NSSet set]];
        STAssertEqualObjects(rendering, @"YES", nil);
    }
    
    {
        NSString *rendering = [template renderObject:[NSSet setWithObject:@""]];
        STAssertEqualObjects(rendering, @"NO", nil);
    }
    
    {
        NSString *rendering = [template renderObject:[[[NSObject alloc] init] autorelease]];
        STAssertEqualObjects(rendering, @"NO", nil);
    }
}

@end
