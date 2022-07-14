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

#import "GRMustachePrivateAPITest.h"
#import "GRMustacheExpressionParser_private.h"
#import "GRMustacheIdentifierExpression_private.h"
#import "GRMustacheScopedExpression_private.h"
#import "GRMustacheFilteredExpression_private.h"
#import "GRMustacheError.h"


@interface GRMustacheExpressionParserTest : GRMustachePrivateAPITest {
	GRMustacheExpressionParser *parser;
}
@end

@implementation GRMustacheExpressionParserTest

- (void)setUp
{
    parser = [[GRMustacheExpressionParser alloc] init];
}

- (void)tearDown
{
}

- (void)testParserParsesEscapedVariableTokenWithSingleKey
{
    GRMustacheExpression *parsedExpression = [parser parseExpression:@"name" empty:NULL error:NULL];

    GRMustacheIdentifierExpression *expression = [GRMustacheIdentifierExpression expressionWithIdentifier:@"name"];
    
    XCTAssertEqualObjects(expression, parsedExpression);
}

- (void)testParserParsesEscapedVariableTokenWithCompoundKey
{
    GRMustacheExpression *parsedExpression = [parser parseExpression:@"foo.bar" empty:NULL error:NULL];
    
    GRMustacheScopedExpression *expression = [GRMustacheScopedExpression expressionWithBaseExpression:[GRMustacheIdentifierExpression expressionWithIdentifier:@"foo"] identifier:@"bar"];
    
    XCTAssertEqualObjects(expression, parsedExpression);
}

- (void)testParserParsesEscapedVariableTokenWithFilter
{
    GRMustacheExpression *parsedExpression = [parser parseExpression:@"toto.titi(foo.bar)" empty:NULL error:NULL];

    GRMustacheScopedExpression *argumentExpression = [GRMustacheScopedExpression expressionWithBaseExpression:[GRMustacheIdentifierExpression expressionWithIdentifier:@"foo"] identifier:@"bar"];
    GRMustacheScopedExpression *filterExpression = [GRMustacheScopedExpression expressionWithBaseExpression:[GRMustacheIdentifierExpression expressionWithIdentifier:@"toto"] identifier:@"titi"];
    GRMustacheFilteredExpression *expression = [GRMustacheFilteredExpression expressionWithFilterExpression:filterExpression argumentExpression:argumentExpression curried:NO];
    
    XCTAssertEqualObjects(expression, parsedExpression);
}

- (void)testParserParsesEscapedVariableTokenWithComplexExpression
{
    GRMustacheExpression *parsedExpression = [parser parseExpression:@"a.b ( c.d ( e.f ) .g.h ).i.j" empty:NULL error:NULL];
    
    GRMustacheExpression *expression_e = [GRMustacheIdentifierExpression expressionWithIdentifier:@"e"];
    GRMustacheExpression *expression_ef = [GRMustacheScopedExpression expressionWithBaseExpression:expression_e identifier:@"f"];
    GRMustacheExpression *expression_c = [GRMustacheIdentifierExpression expressionWithIdentifier:@"c"];
    GRMustacheExpression *expression_cd = [GRMustacheScopedExpression expressionWithBaseExpression:expression_c identifier:@"d"];
    GRMustacheExpression *expression_cdef = [GRMustacheFilteredExpression expressionWithFilterExpression:expression_cd argumentExpression:expression_ef curried:NO];
    GRMustacheExpression *expression_cdefg = [GRMustacheScopedExpression expressionWithBaseExpression:expression_cdef identifier:@"g"];
    GRMustacheExpression *expression_cdefgh = [GRMustacheScopedExpression expressionWithBaseExpression:expression_cdefg identifier:@"h"];
    GRMustacheExpression *expression_a = [GRMustacheIdentifierExpression expressionWithIdentifier:@"a"];
    GRMustacheExpression *expression_ab = [GRMustacheScopedExpression expressionWithBaseExpression:expression_a identifier:@"b"];
    GRMustacheExpression *expression_abcdefgh = [GRMustacheFilteredExpression expressionWithFilterExpression:expression_ab argumentExpression:expression_cdefgh curried:NO];
    GRMustacheExpression *expression_abcdefghi = [GRMustacheScopedExpression expressionWithBaseExpression:expression_abcdefgh identifier:@"i"];
    GRMustacheExpression *expression_abcdefghij = [GRMustacheScopedExpression expressionWithBaseExpression:expression_abcdefghi identifier:@"j"];
    
    XCTAssertEqualObjects(expression_abcdefghij, parsedExpression);
}

@end
