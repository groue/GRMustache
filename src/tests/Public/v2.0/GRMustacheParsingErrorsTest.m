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

#import "GRMustacheParsingErrorsTest.h"

@implementation GRMustacheParsingErrorsTest

- (void)testNullErrorDoesntCrash
{
    [GRMustacheTemplate renderObject:@"" fromString:@"" error:NULL];
    [GRMustacheTemplate renderObject:@"" fromString:@"{{" error:NULL];
}

- (void)testNilInitializedErrorDoesntCrash
{
    NSError *error = nil;
    [GRMustacheTemplate renderObject:@"" fromString:@"" error:&error];
    error = nil;
    NSString *result = [GRMustacheTemplate renderObject:@"" fromString:@"{{" error:&error];
    STAssertNil(result, nil);
    STAssertNotNil(error.domain, nil);
}

- (void)testUninitializedErrorDoesntCrash
{
    NSError *error = (NSError *)0xa;   // some awful value
    [GRMustacheTemplate renderObject:@"" fromString:@"" error:&error];
    error = (NSError *)0xa;   // some awful value
    NSString *result = [GRMustacheTemplate renderObject:@"" fromString:@"{{" error:&error];
    STAssertNil(result, nil);
    STAssertNotNil(error.domain, nil);
}

- (void)testParsingReportsEmptyVariableTag
{
    NSError *error;
    STAssertNil([GRMustacheTemplate templateFromString:@"{{}}" error:&error], nil);
    STAssertEquals(error.code, (NSInteger)GRMustacheErrorCodeParseError, nil);
    STAssertNil([GRMustacheTemplate templateFromString:@"{{ }}" error:&error], nil);
    STAssertEquals(error.code, (NSInteger)GRMustacheErrorCodeParseError, nil);
}

- (void)testParsingReportsBadlyFormattedVariableTag
{
    NSError *error;
    
    // ".a" could mean anchored access to "self.a".
    // But it doesn't mean anything, actually.
    STAssertNil([GRMustacheTemplate templateFromString:@"{{.a}}" error:&error], nil);
    STAssertEquals(error.code, (NSInteger)GRMustacheErrorCodeParseError, nil);
    
    STAssertNil([GRMustacheTemplate templateFromString:@"{{a.}}" error:&error], nil);
    STAssertEquals(error.code, (NSInteger)GRMustacheErrorCodeParseError, nil);
    STAssertNil([GRMustacheTemplate templateFromString:@"{{..}}" error:&error], nil);
    STAssertEquals(error.code, (NSInteger)GRMustacheErrorCodeParseError, nil);
    STAssertNil([GRMustacheTemplate templateFromString:@"{{...}}" error:&error], nil);
    STAssertEquals(error.code, (NSInteger)GRMustacheErrorCodeParseError, nil);
    STAssertNil([GRMustacheTemplate templateFromString:@"{{....}}" error:&error], nil);
    STAssertEquals(error.code, (NSInteger)GRMustacheErrorCodeParseError, nil);
}

- (void)testParsingReportsEmptyUnescapedVariableTag
{
    NSError *error;
    STAssertNil([GRMustacheTemplate templateFromString:@"{{{}}}" error:&error], nil);
    STAssertEquals(error.code, (NSInteger)GRMustacheErrorCodeParseError, nil);
    STAssertNil([GRMustacheTemplate templateFromString:@"{{{ }}}" error:&error], nil);
    STAssertEquals(error.code, (NSInteger)GRMustacheErrorCodeParseError, nil);
    STAssertNil([GRMustacheTemplate templateFromString:@"{{&}}" error:&error], nil);
    STAssertEquals(error.code, (NSInteger)GRMustacheErrorCodeParseError, nil);
    STAssertNil([GRMustacheTemplate templateFromString:@"{{& }}" error:&error], nil);
    STAssertEquals(error.code, (NSInteger)GRMustacheErrorCodeParseError, nil);
}

- (void)testParsingReportsEmptySectionOpeningTag
{
    NSError *error;
    STAssertNil([GRMustacheTemplate templateFromString:@"{{#}}{{/ }}" error:&error], nil);
    STAssertEquals(error.code, (NSInteger)GRMustacheErrorCodeParseError, nil);
    STAssertNil([GRMustacheTemplate templateFromString:@"{{# }}{{/ }}" error:&error], nil);
    STAssertEquals(error.code, (NSInteger)GRMustacheErrorCodeParseError, nil);
}

- (void)testParsingReportsEmptyInvertedSectionOpeningTag
{
    NSError *error;
    STAssertNil([GRMustacheTemplate templateFromString:@"{{^}}{{/ }}" error:&error], nil);
    STAssertEquals(error.code, (NSInteger)GRMustacheErrorCodeParseError, nil);
    STAssertNil([GRMustacheTemplate templateFromString:@"{{^ }}{{/ }}" error:&error], nil);
    STAssertEquals(error.code, (NSInteger)GRMustacheErrorCodeParseError, nil);
}

- (void)testParsingReportsEmptySectionClosingTag
{
    NSError *error;
    STAssertNil([GRMustacheTemplate templateFromString:@"{{#foo}}{{/}}" error:&error], nil);
    STAssertEquals(error.code, (NSInteger)GRMustacheErrorCodeParseError, nil);
    STAssertNil([GRMustacheTemplate templateFromString:@"{{#foo}}{{/ }}" error:&error], nil);
    STAssertEquals(error.code, (NSInteger)GRMustacheErrorCodeParseError, nil);
}

- (void)testParsingReportsEmptyPartialTag
{
    NSError *error;
    STAssertNil([GRMustacheTemplate templateFromString:@"{{>}}" error:&error], nil);
    STAssertEquals(error.code, (NSInteger)GRMustacheErrorCodeParseError, nil);
    STAssertNil([GRMustacheTemplate templateFromString:@"{{> }}" error:&error], nil);
    STAssertEquals(error.code, (NSInteger)GRMustacheErrorCodeParseError, nil);
}

- (void)testParsingReportsUnclosedSections
{
    NSString *templateString = @"{{#list}} <li>{{item}}</li>";
    NSError *error;
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:templateString error:&error];
    STAssertNil(template, nil);
    STAssertEquals(error.code, (NSInteger)GRMustacheErrorCodeParseError, nil);
}

- (void)testRenderingReportsUnclosedSections
{
    NSString *templateString = @"{{#list}} <li>{{item}}</li>";
    NSError *error;
    NSString *result = [GRMustacheTemplate renderObject:nil fromString:templateString error:&error];
    STAssertNil(result, nil);
    STAssertEquals(error.code, (NSInteger)GRMustacheErrorCodeParseError, nil);
}

- (void)testParsingReportsClosingSectionsMismatch
{
    NSString *templateString = @"{{#list}} <li>{{item}}</li> {{/gist}}";
    NSError *error;
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:templateString error:&error];
    STAssertNil(template, nil);
    STAssertEquals(error.code, (NSInteger)GRMustacheErrorCodeParseError, nil);
}

- (void)testRenderingReportsClosingSectionsMismatch
{
    NSString *templateString = @"{{#list}} <li>{{item}}</li> {{/gist}}";
    NSError *error;
    NSString *result = [GRMustacheTemplate renderObject:nil fromString:templateString error:&error];
    STAssertNil(result, nil);
    STAssertEquals(error.code, (NSInteger)GRMustacheErrorCodeParseError, nil);
}

- (void)testParsingReportsClosingSectionsMismatchReportsTheLineNumber
{
    NSString *templateString = @"hi\nmom\n{{#list}} <li>{{item}}</li> {{/gist}}";
    NSError *error;
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:templateString error:&error];
    STAssertNil(template, nil);
    STAssertEquals(error.code, (NSInteger)GRMustacheErrorCodeParseError, nil);
    STAssertEquals([(NSNumber *)[error.userInfo objectForKey:GRMustacheErrorLine] intValue], 3, nil);
}

- (void)testRenderingReportsClosingSectionsMismatchReportsTheLineNumber
{
    NSString *templateString = @"hi\nmom\n{{#list}} <li>{{item}}</li> {{/gist}}";
    NSError *error;
    NSString *result = [GRMustacheTemplate renderObject:nil fromString:templateString error:&error];
    STAssertNil(result, nil);
    STAssertEquals(error.code, (NSInteger)GRMustacheErrorCodeParseError, nil);
    STAssertEquals([(NSNumber *)[error.userInfo objectForKey:GRMustacheErrorLine] intValue], 3, nil);
}

- (void)testParsingReportsLotsOfStaches
{
    NSString *templateString = @"{{{{foo}}}}";
    NSError *error;
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:templateString error:&error];
    STAssertNil(template, nil);
    STAssertEquals(error.code, (NSInteger)GRMustacheErrorCodeParseError, nil);
}

- (void)testRenderingReportsLotsOfStaches
{
    NSString *templateString = @"{{{{foo}}}}";
    NSError *error;
    NSString *result = [GRMustacheTemplate renderObject:nil fromString:templateString error:&error];
    STAssertNil(result, nil);
    STAssertEquals(error.code, (NSInteger)GRMustacheErrorCodeParseError, nil);
}

@end
