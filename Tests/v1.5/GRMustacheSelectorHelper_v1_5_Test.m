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

#import "GRMustacheSelectorHelper_v1_5_Test.h"


@interface GRMustacheSelectorHelper_v1_5_TestContext: NSObject
@end

@implementation GRMustacheSelectorHelper_v1_5_TestContext

- (NSString*)fooSection:(GRMustacheSection *)section withContext:(id)context {
	NSDictionary *baz = [NSDictionary dictionaryWithObjectsAndKeys:
						  @"foobaz", @"baz",
						  nil];
	return [section renderObjects:context, baz, nil];
}

@end

@implementation GRMustacheSelectorHelper_v1_5_Test

- (void)testMultipleObjectSectionRendering {
	NSString *templateString = @"{{#foo}}{{bar}}{{baz}}{{/foo}}";
	id context = [[[GRMustacheSelectorHelper_v1_5_TestContext alloc] init] autorelease];
	NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
						  @"baz", @"baz",
						  @"bar", @"bar",
						  nil];
	GRMustacheTemplate *template = [GRMustacheTemplate parseString:templateString error:nil];
	NSString *result = [template renderObjects:context, data, nil];
	STAssertEqualObjects(result, @"barfoobaz", nil);
}

- (void)testMultipleObjectsRendering {
    NSString *templateString = @"{{A}}{{B}}{{C}}";
    GRMustacheTemplate *template = [GRMustacheTemplate parseString:templateString error:nil];
    
    NSDictionary *foo = [NSDictionary dictionaryWithObjectsAndKeys:@"fooA", @"A", @"fooB", @"B", nil];
    NSDictionary *bar = [NSDictionary dictionaryWithObjectsAndKeys:@"barB", @"B", @"barC", @"C", nil];
    NSDictionary *baz = [NSDictionary dictionaryWithObjectsAndKeys:@"bazA", @"A", @"bazC", @"C", nil];
    
    STAssertEqualObjects([template renderObject:foo], @"fooAfooB", nil);
    STAssertEqualObjects([template renderObject:bar], @"barBbarC", nil);
    STAssertEqualObjects([template renderObject:baz], @"bazAbazC", nil);

    STAssertEqualObjects(([template renderObjects:foo, nil]), @"fooAfooB", nil);
    STAssertEqualObjects(([template renderObjects:bar, nil]), @"barBbarC", nil);
    STAssertEqualObjects(([template renderObjects:baz, nil]), @"bazAbazC", nil);
    
    STAssertEqualObjects(([template renderObjects:foo, bar, nil]), @"fooAbarBbarC", nil);
    STAssertEqualObjects(([template renderObjects:bar, foo, nil]), @"fooAfooBbarC", nil);
    STAssertEqualObjects(([template renderObjects:foo, baz, nil]), @"bazAfooBbazC", nil);
    STAssertEqualObjects(([template renderObjects:baz, foo, nil]), @"fooAfooBbazC", nil);
    STAssertEqualObjects(([template renderObjects:bar, baz, nil]), @"bazAbarBbazC", nil);
    STAssertEqualObjects(([template renderObjects:baz, bar, nil]), @"bazAbarBbarC", nil);
}

@end
