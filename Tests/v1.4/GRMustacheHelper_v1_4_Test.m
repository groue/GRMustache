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

#import "GRMustacheHelper_v1_4_Test.h"
#import "GRMustacheContext.h"


@interface GRMustacheHelper_v1_4_TestContext: NSObject
@end

@implementation GRMustacheHelper_v1_4_TestContext

- (NSString*)fooSection:(GRMustacheSection *)section withContext:(GRMustacheContext *)context {
	NSDictionary *baz = [NSDictionary dictionaryWithObjectsAndKeys:
						  @"foobaz", @"baz",
						  nil];
	return [section renderObjects:context, baz, nil];
}

@end

@implementation GRMustacheHelper_v1_4_Test

- (void)testMultipleObjectSectionRendering {
	NSString *templateString = @"{{#foo}}{{bar}}{{baz}}{{/foo}}";
	id context = [[[GRMustacheHelper_v1_4_TestContext alloc] init] autorelease];
	NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
						  @"baz", @"baz",
						  @"bar", @"bar",
						  nil];
	GRMustacheTemplate *template = [GRMustacheTemplate parseString:templateString error:nil];
	NSString *result = [template renderObjects:context, data, nil];
	STAssertEqualObjects(result, @"barfoobaz", nil);
}

@end
