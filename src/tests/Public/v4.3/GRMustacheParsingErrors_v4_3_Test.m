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

@interface GRMustacheParsingErrors_v4_3_Test : GRMustachePublicAPITest
@end

@implementation GRMustacheParsingErrors_v4_3_Test

- (void)testParsingReportsFilteredClosingSectionsMismatch
{
    NSError *error;
    STAssertNotNil([GRMustacheTemplate templateFromString:@"{{%FILTERS}}{{#a}}{{/a}}" error:&error], nil);
    STAssertNil([GRMustacheTemplate templateFromString:@"{{%FILTERS}}{{#a}}{{/b}}" error:&error], nil);
    STAssertEquals(error.code, (NSInteger)GRMustacheErrorCodeParseError, nil);
    STAssertNil([GRMustacheTemplate templateFromString:@"{{%FILTERS}}{{#a}}{{/a(b)}}" error:&error], nil);
    STAssertEquals(error.code, (NSInteger)GRMustacheErrorCodeParseError, nil);
    STAssertNil([GRMustacheTemplate templateFromString:@"{{%FILTERS}}{{#a}}{{/b(a)}}" error:&error], nil);
    STAssertEquals(error.code, (NSInteger)GRMustacheErrorCodeParseError, nil);
    
    STAssertNotNil([GRMustacheTemplate templateFromString:@"{{%FILTERS}}{{#a(b)}}{{/a(b)}}" error:&error], nil);
    STAssertNil([GRMustacheTemplate templateFromString:@"{{%FILTERS}}{{#a(b)}}{{/a}}" error:&error], nil);
    STAssertEquals(error.code, (NSInteger)GRMustacheErrorCodeParseError, nil);
    STAssertNil([GRMustacheTemplate templateFromString:@"{{%FILTERS}}{{#a(b)}}{{/b}}" error:&error], nil);
    STAssertEquals(error.code, (NSInteger)GRMustacheErrorCodeParseError, nil);
    STAssertNil([GRMustacheTemplate templateFromString:@"{{%FILTERS}}{{#a(b)}}{{/a(b(c))}}" error:&error], nil);
    STAssertEquals(error.code, (NSInteger)GRMustacheErrorCodeParseError, nil);
    STAssertNil([GRMustacheTemplate templateFromString:@"{{%FILTERS}}{{#a(b)}}{{/c(a(b)}}" error:&error], nil);
    STAssertEquals(error.code, (NSInteger)GRMustacheErrorCodeParseError, nil);
    STAssertNil([GRMustacheTemplate templateFromString:@"{{%FILTERS}}{{#a(b)}}{{/b(a)}}" error:&error], nil);
    STAssertEquals(error.code, (NSInteger)GRMustacheErrorCodeParseError, nil);
}

- (void)testParsingErrorReportsImplicitIteratorAsFilter
{
    NSError *error;
    STAssertNil([GRMustacheTemplate templateFromString:@"{{%FILTERS}}{{.(a)}}" error:&error], nil);
    STAssertEquals(error.code, (NSInteger)GRMustacheErrorCodeParseError, nil);
    STAssertNil([GRMustacheTemplate templateFromString:@"{{%FILTERS}}{{.f(a)}}" error:&error], nil);
    STAssertEquals(error.code, (NSInteger)GRMustacheErrorCodeParseError, nil);
}

- (void)testParsingErrorReportsFilteredValueAsFilter
{
    NSError *error;
    STAssertNil([GRMustacheTemplate templateFromString:@"{{%FILTERS}}{{f(a)(b)}}" error:&error], nil);
    STAssertEquals(error.code, (NSInteger)GRMustacheErrorCodeParseError, nil);
}

@end
