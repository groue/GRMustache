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

#define GRMUSTACHE_VERSION_MAX_ALLOWED GRMUSTACHE_VERSION_6_3
#import "GRMustachePublicAPITest.h"

@interface GRMustacheFilter6_3Test : GRMustachePublicAPITest
@end

@implementation GRMustacheFilter6_3Test

- (void)testMissingFilterError
{
    id data = @{
        @"name": @"Name",
        @"replace": [GRMustacheFilter filterWithBlock:^id(id value) {
            return @"replace";
        }],
    };
    
    {
        GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"<{{missing(missing)}}>" error:NULL];
        STAssertNotNil(template, @"");
        NSError *error;
        NSString *rendering = [template renderObject:data error:&error];
        STAssertNil(rendering, @"WTF");
        STAssertEqualObjects(error.domain, GRMustacheErrorDomain, @"");
        STAssertEquals(error.code, GRMustacheErrorCodeRenderingError, @"");
    }
    {
        GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"<{{missing(name)}}>" error:NULL];
        STAssertNotNil(template, @"");
        NSError *error;
        NSString *rendering = [template renderObject:data error:&error];
        STAssertNil(rendering, @"WTF");
        STAssertEqualObjects(error.domain, GRMustacheErrorDomain, @"");
        STAssertEquals(error.code, GRMustacheErrorCodeRenderingError, @"");
    }
    {
        GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"<{{replace(missing(name))}}>" error:NULL];
        STAssertNotNil(template, @"");
        NSError *error;
        NSString *rendering = [template renderObject:data error:&error];
        STAssertNil(rendering, @"WTF");
        STAssertEqualObjects(error.domain, GRMustacheErrorDomain, @"");
        STAssertEquals(error.code, GRMustacheErrorCodeRenderingError, @"");
    }
    {
        GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"<{{missing(replace(name))}}>" error:NULL];
        STAssertNotNil(template, @"");
        NSError *error;
        NSString *rendering = [template renderObject:data error:&error];
        STAssertNil(rendering, @"WTF");
        STAssertEqualObjects(error.domain, GRMustacheErrorDomain, @"");
        STAssertEquals(error.code, GRMustacheErrorCodeRenderingError, @"");
    }
}

- (void)testNotAFilterError
{
    id data = @{
        @"name": @"Name",
        @"filter": @"filter",
    };
    
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"<{{filter(name)}}>" error:NULL];
    STAssertNotNil(template, @"");
    NSError *error;
    NSString *rendering = [template renderObject:data error:&error];
    STAssertNil(rendering, @"WTF");
    STAssertEqualObjects(error.domain, GRMustacheErrorDomain, @"");
    STAssertEquals(error.code, GRMustacheErrorCodeRenderingError, @"");
}

@end
