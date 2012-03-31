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

#import "GRMustacheBooleanInterpretationTest.h"

@implementation GRMustacheBooleanInterpretationTest

/**
 Here we test boolean interpretation of values that we could not test in GRMustacheSuites/sections.json and GRMustacheSuites/inverted_sections.json
 */

- (NSInteger)booleanInterpretationForObject:(id)object key:(NSString *)key
{
    NSString *templateString = [NSString stringWithFormat:@"{{#%@}}YES{{/%@}}{{^%@}}NO{{/%@}}", key, key, key, key];
    NSString *result = [GRMustacheTemplate renderObject:object fromString:templateString error:nil];
    if ([result isEqualToString:@"YES"]) {
        return YES;
    } else if ([result isEqualToString:@"NO"]) {
        return NO;
    }
    return NSNotFound;
}

- (void)test_Nil_isFalseValue
{
    NSDictionary *context = [NSDictionary dictionary];
    STAssertEquals((NSInteger)[self booleanInterpretationForObject:context key:@"bool"], (NSInteger)NO, nil);
    STAssertEquals((NSInteger)[self booleanInterpretationForObject:nil key:@"."], (NSInteger)NO, nil);
    STAssertEqualObjects([GRMustacheTemplate renderObject:context fromString:@"<{{bool}}>" error:NULL], @"<>", @"");
}

- (void)test_NSNull_isFalseValue
{
    id value = [NSNull null];
    NSDictionary *context = [NSDictionary dictionaryWithObject:value forKey:@"bool"];
    STAssertEquals((NSInteger)[self booleanInterpretationForObject:context key:@"bool"], (NSInteger)NO, nil);
    STAssertEquals((NSInteger)[self booleanInterpretationForObject:value key:@"."], (NSInteger)NO, nil);
    STAssertEqualObjects([GRMustacheTemplate renderObject:context fromString:@"<{{bool}}>" error:NULL], @"<>", @"");
}

- (void)test_NSNumberWithZero_isTrueValue
{
    STAssertEquals((NSInteger)[self booleanInterpretationForObject:[NSNumber numberWithChar:0] key:@"."], (NSInteger)YES, nil);
    STAssertEquals((NSInteger)[self booleanInterpretationForObject:[NSNumber numberWithFloat:0] key:@"."], (NSInteger)YES, nil);
    STAssertEquals((NSInteger)[self booleanInterpretationForObject:[NSNumber numberWithDouble:0] key:@"."], (NSInteger)YES, nil);
    STAssertEquals((NSInteger)[self booleanInterpretationForObject:[NSNumber numberWithInt:0] key:@"."], (NSInteger)YES, nil);
    STAssertEquals((NSInteger)[self booleanInterpretationForObject:[NSNumber numberWithInteger:0] key:@"."], (NSInteger)YES, nil);
    STAssertEquals((NSInteger)[self booleanInterpretationForObject:[NSNumber numberWithLong:0] key:@"."], (NSInteger)YES, nil);
    STAssertEquals((NSInteger)[self booleanInterpretationForObject:[NSNumber numberWithLongLong:0] key:@"."], (NSInteger)YES, nil);
    STAssertEquals((NSInteger)[self booleanInterpretationForObject:[NSNumber numberWithShort:0] key:@"."], (NSInteger)YES, nil);
    STAssertEquals((NSInteger)[self booleanInterpretationForObject:[NSNumber numberWithUnsignedChar:0] key:@"."], (NSInteger)YES, nil);
    STAssertEquals((NSInteger)[self booleanInterpretationForObject:[NSNumber numberWithUnsignedInt:0] key:@"."], (NSInteger)YES, nil);
    STAssertEquals((NSInteger)[self booleanInterpretationForObject:[NSNumber numberWithUnsignedInteger:0] key:@"."], (NSInteger)YES, nil);
    STAssertEquals((NSInteger)[self booleanInterpretationForObject:[NSNumber numberWithUnsignedLong:0] key:@"."], (NSInteger)YES, nil);
    STAssertEquals((NSInteger)[self booleanInterpretationForObject:[NSNumber numberWithUnsignedLongLong:0] key:@"."], (NSInteger)YES, nil);
    STAssertEquals((NSInteger)[self booleanInterpretationForObject:[NSNumber numberWithUnsignedShort:0] key:@"."], (NSInteger)YES, nil);
    STAssertEqualObjects([GRMustacheTemplate renderObject:[NSNumber numberWithChar:0] fromString:@"<{{.}}>" error:NULL], @"<0>", @"");
    STAssertEqualObjects([GRMustacheTemplate renderObject:[NSNumber numberWithFloat:0] fromString:@"<{{.}}>" error:NULL], @"<0>", @"");
    STAssertEqualObjects([GRMustacheTemplate renderObject:[NSNumber numberWithDouble:0] fromString:@"<{{.}}>" error:NULL], @"<0>", @"");
    STAssertEqualObjects([GRMustacheTemplate renderObject:[NSNumber numberWithInt:0] fromString:@"<{{.}}>" error:NULL], @"<0>", @"");
    STAssertEqualObjects([GRMustacheTemplate renderObject:[NSNumber numberWithInteger:0] fromString:@"<{{.}}>" error:NULL], @"<0>", @"");
    STAssertEqualObjects([GRMustacheTemplate renderObject:[NSNumber numberWithLong:0] fromString:@"<{{.}}>" error:NULL], @"<0>", @"");
    STAssertEqualObjects([GRMustacheTemplate renderObject:[NSNumber numberWithLongLong:0] fromString:@"<{{.}}>" error:NULL], @"<0>", @"");
    STAssertEqualObjects([GRMustacheTemplate renderObject:[NSNumber numberWithShort:0] fromString:@"<{{.}}>" error:NULL], @"<0>", @"");
    STAssertEqualObjects([GRMustacheTemplate renderObject:[NSNumber numberWithUnsignedChar:0] fromString:@"<{{.}}>" error:NULL], @"<0>", @"");
    STAssertEqualObjects([GRMustacheTemplate renderObject:[NSNumber numberWithUnsignedInt:0] fromString:@"<{{.}}>" error:NULL], @"<0>", @"");
    STAssertEqualObjects([GRMustacheTemplate renderObject:[NSNumber numberWithUnsignedInteger:0] fromString:@"<{{.}}>" error:NULL], @"<0>", @"");
    STAssertEqualObjects([GRMustacheTemplate renderObject:[NSNumber numberWithUnsignedLong:0] fromString:@"<{{.}}>" error:NULL], @"<0>", @"");
    STAssertEqualObjects([GRMustacheTemplate renderObject:[NSNumber numberWithUnsignedLongLong:0] fromString:@"<{{.}}>" error:NULL], @"<0>", @"");
    STAssertEqualObjects([GRMustacheTemplate renderObject:[NSNumber numberWithUnsignedShort:0] fromString:@"<{{.}}>" error:NULL], @"<0>", @"");
}

@end
