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

- (void)testStandardCapitalizeFilter
{
    id data = @"name";
    NSString *rendering = [GRMustacheTemplate renderObject:data fromString:@"{{%FILTERS}}{{.|capitalize}}" error:NULL];
    STAssertEqualObjects(rendering, @"Name", nil);
}

- (void)testStandardLowercaseFilter
{
    id data = @"NAME";
    NSString *rendering = [GRMustacheTemplate renderObject:data fromString:@"{{%FILTERS}}{{.|lowercase}}" error:NULL];
    STAssertEqualObjects(rendering, @"name", nil);
}
- (void)testStandardUppercaseFilter
{
    id data = @"name";
    NSString *rendering = [GRMustacheTemplate renderObject:data fromString:@"{{%FILTERS}}{{.|uppercase}}" error:NULL];
    STAssertEqualObjects(rendering, @"NAME", nil);
}

- (void)testStandardFirstFilter
{
    id data = [NSArray arrayWithObjects:@"1", @"2", nil];
    NSString *rendering = [GRMustacheTemplate renderObject:data fromString:@"{{%FILTERS}}{{.|first}}" error:NULL];
    STAssertEqualObjects(rendering, @"1", nil);
}

- (void)testStandardLastFilter
{
    id data = [NSArray arrayWithObjects:@"1", @"2", nil];
    NSString *rendering = [GRMustacheTemplate renderObject:data fromString:@"{{%FILTERS}}{{.|last}}" error:NULL];
    STAssertEqualObjects(rendering, @"2", nil);
}


@end
