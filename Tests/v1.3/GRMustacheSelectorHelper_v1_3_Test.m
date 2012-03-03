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

#import "GRMustacheSelectorHelper_v1_3_Test.h"


@interface GRMustacheSelectorHelper_v1_3_TestContext: NSObject
@end

@implementation GRMustacheSelectorHelper_v1_3_TestContext

- (NSString*)linkSection:(GRMustacheSection *)section withContext:(GRMustacheContext *)context
{
    return [NSString stringWithFormat:
            @"<a href=\"/people/%@\">%@</a>",
            [context valueForKey:@"id"],
            [section renderObject:context]];
}

- (NSString *)id
{
    return @"1";
}

- (NSString *)name
{
    return @"foo";
}

+ (NSString*)linkSection:(GRMustacheSection *)section withContext:(GRMustacheContext *)context
{
    return [NSString stringWithFormat:
            @"<a href=\"/people\">%@</a>",
            [section renderObject:context]];
}

@end

@implementation GRMustacheSelectorHelper_v1_3_Test

- (void)testHelperInstanceMethod
{
    NSString *templateString = @"{{#link}}{{name}}{{/link}}";
    id context = [[[GRMustacheSelectorHelper_v1_3_TestContext alloc] init] autorelease];
    NSString *result = [GRMustacheTemplate renderObject:context fromString:templateString error:nil];
    STAssertEqualObjects(result, @"<a href=\"/people/1\">foo</a>", nil);
}

- (void)testHelperClassMethod
{
    NSString *templateString = @"{{#link}}{{name}}{{/link}}";
    GRMustacheTemplate *template = [GRMustacheTemplate parseString:templateString error:nil];;
    NSString *result = [template renderObject:[GRMustacheSelectorHelper_v1_3_TestContext class]];
    STAssertEqualObjects(result, @"<a href=\"/people\"></a>", nil);
}

@end
