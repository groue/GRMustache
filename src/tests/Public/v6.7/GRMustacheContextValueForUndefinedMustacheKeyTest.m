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

#define GRMUSTACHE_VERSION_MAX_ALLOWED GRMUSTACHE_VERSION_6_7
#import "GRMustachePublicAPITest.h"


@interface GRMustacheContextWithValueForUndefinedMustacheKey : GRMustacheContext
@end

@implementation GRMustacheContextWithValueForUndefinedMustacheKey

- (id)valueForUndefinedMustacheKey:(NSString *)key
{
    return [[self valueForMustacheKey:[key lowercaseString]] uppercaseString];
}

@end


@interface GRMustacheContextWithValueForUndefinedKey : GRMustacheContext
@end

@implementation GRMustacheContextWithValueForUndefinedKey

- (id)valueForUndefinedKey:(NSString *)key
{
    return [[self valueForMustacheKey:[key lowercaseString]] uppercaseString];
}

@end


@interface GRMustacheContextValueForUndefinedMustacheKeyTest : GRMustachePublicAPITest
@end

@implementation GRMustacheContextValueForUndefinedMustacheKeyTest

- (void)testValueForUndefinedMustacheKey
{
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{NAME}},{{#a}}{{NAME}}{{/a}}" error:NULL];
    template.baseContext = [GRMustacheContextWithValueForUndefinedMustacheKey context];
    
    id data = @{ @"name": @"foo", @"a": @{ @"name": @"bar" } };
    NSString *rendering = [template renderObject:data error:NULL];
    STAssertEqualObjects(rendering, @"FOO,BAR", @"");
}

- (void)testValueForUndefinedKey
{
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{NAME}},{{#a}}{{NAME}}{{/a}}" error:NULL];
    template.baseContext = [GRMustacheContextWithValueForUndefinedKey context];
    
    id data = @{ @"name": @"foo", @"a": @{ @"name": @"bar" } };
    NSString *rendering = [template renderObject:data error:NULL];
    STAssertEqualObjects(rendering, @"FOO,BAR", @"");
}

@end
