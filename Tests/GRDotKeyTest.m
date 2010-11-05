// The MIT License
// 
// Copyright (c) 2010 Gwendal Roué
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

#import "GRDotKeyTest.h"


@implementation GRDotKeyTest

- (void)testDotVariable {
	NSString *templateString = @"{{.}}";
	NSString *result = [GRMustacheTemplate renderObject:@"foobar" fromString:templateString error:nil];
	STAssertEqualObjects(result, @"foobar", nil);
}

- (void)testDotVariableInEnumeration {
	NSString *templateString = @"{{#names}}{{.}}{{/names}}";
	NSDictionary *context = [NSDictionary dictionaryWithObject:[NSArray arrayWithObjects:
																@"foo",
																@"bar",
																nil
																]
														forKey:@"names"];
	NSString *result = [GRMustacheTemplate renderObject:context fromString:templateString error:nil];
	STAssertEqualObjects(result, @"foobar", nil);
}

- (void)testNonGRMustacheContextCanDefineBooleanSection {
	NSString *templateString = @"{{#item}}{{#name}}{{name}},{{/name}}{{/item}}";
	NSDictionary *context = [NSDictionary dictionaryWithObject:[NSArray arrayWithObjects:
																[NSDictionary dictionaryWithObject:@"foo" forKey:@"name"],
																[NSDictionary dictionary],
																[NSDictionary dictionaryWithObject:@"bar" forKey:@"name"],
																nil
																]
														forKey:@"item"];
	NSString *result = [GRMustacheTemplate renderObject:context fromString:templateString error:nil];
	STAssertEqualObjects(result, @"foo,bar,", nil);
}

- (void)testDotVariableInNonGRMustacheContextBooleanSection {
	NSString *templateString = @"{{#item}}{{#name}}{{.}},{{/name}}{{/item}}";
	NSDictionary *context = [NSDictionary dictionaryWithObject:[NSArray arrayWithObjects:
																[NSDictionary dictionaryWithObject:@"foo" forKey:@"name"],
																[NSDictionary dictionary],
																[NSDictionary dictionaryWithObject:@"bar" forKey:@"name"],
																nil
																]
														forKey:@"item"];
	NSString *result = [GRMustacheTemplate renderObject:context fromString:templateString error:nil];
	STAssertEqualObjects(result, @"foo,bar,", nil);
}

@end
