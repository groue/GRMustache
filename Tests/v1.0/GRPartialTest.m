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

#import "GRPartialTest.h"


@implementation PPartialTest

- (void)testViewPartial
{
    // TODO, but ruby test is unclear about its intent
}

- (void)testPartialWithSlashes
{
    // TODO
}

- (void)testViewPartialInheritsContext
{
    // TODO
}

- (void)testTemplatePartial
{
    NSDictionary *context = [NSDictionary dictionaryWithObject:@"Welcome" forKey:@"title"];
    NSString *result = [self renderObject:context fromResource:@"template_partial"];
    STAssertEqualObjects(result, @"<h1>Welcome</h1>\nAgain, Welcome!", nil);
}

- (void)testPartialWithCustomExtension
{
    NSDictionary *context = [NSDictionary dictionaryWithObjectsAndKeys:
                             @"Welcome", @"title",
                             @"-------", @"title_bars",
                             nil];
    NSString *result = [self renderObject:context fromResource:@"template_partial" withExtension:@"txt"];
    STAssertEqualObjects(result, @"Welcome\n-------\n\n## Again, Welcome! ##\n\n", nil);
}

- (void)testRecursivePartial
{
    NSDictionary *context = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:@"show"];
    NSString *result = [self renderObject:context fromResource:@"recursive"];
    STAssertEqualObjects(result, @"It works!", @"");
}

- (void)testCrazyRecursivePartial
{
    NSDictionary *context = [NSDictionary dictionaryWithObject:[NSArray arrayWithObjects:
                                                                [NSDictionary dictionaryWithObjectsAndKeys:
                                                                 @"1", @"contents",
                                                                 [NSArray arrayWithObjects:
                                                                  [NSDictionary dictionaryWithObjectsAndKeys:
                                                                   @"2", @"contents",
                                                                   [NSArray arrayWithObjects:
                                                                    [NSDictionary dictionaryWithObjectsAndKeys:
                                                                     @"3", @"contents",
                                                                     [NSArray array], @"children",
                                                                     nil],
                                                                    nil], @"children",
                                                                   nil],
                                                                  [NSDictionary dictionaryWithObjectsAndKeys:
                                                                   @"4", @"contents",
                                                                   [NSArray arrayWithObjects:
                                                                    [NSDictionary dictionaryWithObjectsAndKeys:
                                                                     @"5", @"contents",
                                                                     [NSArray arrayWithObjects:
                                                                      [NSDictionary dictionaryWithObjectsAndKeys:
                                                                       @"6", @"contents",
                                                                       [NSArray array], @"children",
                                                                       nil],
                                                                      nil], @"children",
                                                                     nil],
                                                                    nil], @"children",
                                                                   nil],
                                                                  nil], @"children",
                                                                 nil],
                                                                nil]
                                                        forKey:@"top_nodes"];
    NSString *result = [self renderObject:context fromResource:@"crazy_recursive"];
    STAssertEqualObjects(result, @"<html><body><ul><li>1<ul><li>2<ul><li>3<ul></ul></li></ul></li><li>4<ul><li>5<ul><li>6<ul></ul></li></ul></li></ul></li></ul></li></ul></body></html>", @"");
}



@end
