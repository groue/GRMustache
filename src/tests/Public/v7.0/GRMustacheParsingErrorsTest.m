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

#define GRMUSTACHE_VERSION_MAX_ALLOWED GRMUSTACHE_VERSION_7_0
#import "GRMustachePublicAPITest.h"

@interface GRMustacheParsingErrorsTest : GRMustachePublicAPITest
@end

@implementation GRMustacheParsingErrorsTest

- (void)testNullErrorDoesNotCrash
{
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"" error:NULL];
    XCTAssertNotNil(template, @"");
    
    XCTAssertNotNil([template renderObject:@"" error:NULL], @"");
    
    id fail = [GRMustache renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
        return [[tag.templateRepository templateNamed:@"missing" error:error] renderObject:nil error:NULL];
    }];
    XCTAssertNil([[GRMustacheTemplate templateFromString:@"{{.}}" error:NULL] renderObject:fail error:NULL], @"");
    
    XCTAssertNil([GRMustacheTemplate templateFromString:@"{{" error:NULL], @"");
}

- (void)testNilInitializedErrorDoesNotCrash
{
    NSError *error = nil;
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"" error:&error];
    XCTAssertNotNil(template, @"");
    
    error = nil;
    XCTAssertNotNil([template renderObject:@"" error:&error], @"");
    
    error = nil;
    id fail = [GRMustache renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
        return [[tag.templateRepository templateNamed:@"missing" error:error] renderObject:nil error:NULL];
    }];
    XCTAssertNil([[GRMustacheTemplate templateFromString:@"{{.}}" error:NULL] renderObject:fail error:&error], @"");
    XCTAssertNotNil(error.domain);
    
    error = nil;
    XCTAssertNil([GRMustacheTemplate templateFromString:@"{{" error:&error], @"");
    XCTAssertNotNil(error.domain);
}

- (void)testUninitializedErrorDoesNotCrash
{
    NSError *error = (NSError *)0xdeadbeef;
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"" error:&error];
    XCTAssertNotNil(template, @"");
    
    error = (NSError *)0xdeadbeef;
    XCTAssertNotNil([template renderObject:@"" error:&error], @"");
    
    error = (NSError *)0xdeadbeef;
    id fail = [GRMustache renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
        return [[tag.templateRepository templateNamed:@"missing" error:error] renderObject:nil error:NULL];
    }];
    XCTAssertNil([[GRMustacheTemplate templateFromString:@"{{.}}" error:NULL] renderObject:fail error:&error], @"");
    XCTAssertNotNil(error.domain);
    
    error = (NSError *)0xdeadbeef;
    XCTAssertNil([GRMustacheTemplate templateFromString:@"{{" error:&error], @"");
    XCTAssertNotNil(error.domain);
}

- (void)testIdentifiersCanNotStartWithMustacheTagCharacters
{
    NSArray *mustacheTagCharacters = @[@"{", @"}", @"<", @">", @"&", @"#", @"^", @"$", @"/"];
    
    // Identifiers can't start with a forbidden character
    
    NSError *error;
    
    for (NSString *mustacheTagCharacter in mustacheTagCharacters) {
        XCTAssertNil(([GRMustacheTemplate templateFromString:[NSString stringWithFormat:@"{{ %@ }}", mustacheTagCharacter] error:&error]));
        XCTAssertEqual(error.code, (NSInteger)GRMustacheErrorCodeParseError);    // expect template not found, not parse error
        XCTAssertNil(([GRMustacheTemplate templateFromString:[NSString stringWithFormat:@"{{{%@}}}", mustacheTagCharacter] error:&error]));
        XCTAssertEqual(error.code, (NSInteger)GRMustacheErrorCodeParseError);    // expect template not found, not parse error
        XCTAssertNil(([GRMustacheTemplate templateFromString:[NSString stringWithFormat:@"{{&%@}}", mustacheTagCharacter] error:&error]));
        XCTAssertEqual(error.code, (NSInteger)GRMustacheErrorCodeParseError);    // expect template not found, not parse error
        XCTAssertNil(([GRMustacheTemplate templateFromString:[NSString stringWithFormat:@"{{#%@}}{{/%@}}", mustacheTagCharacter, mustacheTagCharacter] error:&error]));
        XCTAssertEqual(error.code, (NSInteger)GRMustacheErrorCodeParseError);    // expect template not found, not parse error
        
        XCTAssertNil(([GRMustacheTemplate templateFromString:[NSString stringWithFormat:@"{{ %@a }}", mustacheTagCharacter] error:&error]));
        XCTAssertEqual(error.code, (NSInteger)GRMustacheErrorCodeParseError);    // expect template not found, not parse error
        XCTAssertNil(([GRMustacheTemplate templateFromString:[NSString stringWithFormat:@"{{{%@a}}}", mustacheTagCharacter] error:&error]));
        XCTAssertEqual(error.code, (NSInteger)GRMustacheErrorCodeParseError);    // expect template not found, not parse error
        XCTAssertNil(([GRMustacheTemplate templateFromString:[NSString stringWithFormat:@"{{&%@a}}", mustacheTagCharacter] error:&error]));
        XCTAssertEqual(error.code, (NSInteger)GRMustacheErrorCodeParseError);    // expect template not found, not parse error
        XCTAssertNil(([GRMustacheTemplate templateFromString:[NSString stringWithFormat:@"{{#%@a}}{{/%@a}}", mustacheTagCharacter, mustacheTagCharacter] error:&error]));
        XCTAssertEqual(error.code, (NSInteger)GRMustacheErrorCodeParseError);    // expect template not found, not parse error
    }
    
    // Identifiers can have forbidden characters *inside*
    
    for (NSString *mustacheTagCharacter in mustacheTagCharacters) {
        XCTAssertNotNil(([GRMustacheTemplate templateFromString:[NSString stringWithFormat:@"{{ a%@ }}", mustacheTagCharacter] error:NULL]));
        XCTAssertNotNil(([GRMustacheTemplate templateFromString:[NSString stringWithFormat:@"{{{a%@}}}", mustacheTagCharacter] error:NULL]));
        XCTAssertNotNil(([GRMustacheTemplate templateFromString:[NSString stringWithFormat:@"{{&a%@}}", mustacheTagCharacter] error:NULL]));
        XCTAssertNotNil(([GRMustacheTemplate templateFromString:[NSString stringWithFormat:@"{{#a%@}}{{/a%@}}", mustacheTagCharacter, mustacheTagCharacter] error:NULL]));
    }
    
    // Partial names can start with a forbidden character
    
    GRMustacheTemplateRepository *repository = [GRMustacheTemplateRepository templateRepositoryWithDictionary:@{ }];
    for (NSString *mustacheTagCharacter in mustacheTagCharacters) {
        XCTAssertNil(([repository templateFromString:[NSString stringWithFormat:@"{{> %@ }}", mustacheTagCharacter] error:&error]));
        XCTAssertEqual(error.code, (NSInteger)GRMustacheErrorCodeTemplateNotFound);    // expect template not found, not parse error
        XCTAssertNil(([repository templateFromString:[NSString stringWithFormat:@"{{< %@ }}{{/ %@ }}", mustacheTagCharacter, mustacheTagCharacter] error:&error]));
        XCTAssertEqual(error.code, (NSInteger)GRMustacheErrorCodeTemplateNotFound);    // expect template not found, not parse error
    }

}

@end
