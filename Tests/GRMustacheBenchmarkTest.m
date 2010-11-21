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

#import "GRMustacheBenchmarkTest.h"


@implementation GRMustacheBenchmarkTest

- (void)testParsingBenchmark {
	for (int i=0; i < 50000; i++) {
		[self parseResource:@"complex_view"];
	}
}

- (void)testRenderingBenchmark {
	GRMustacheTemplate *template = [self parseResource:@"complex_view"];
	NSDictionary *context = [NSDictionary dictionaryWithObjectsAndKeys:
							 [NSArray arrayWithObjects:
							  [NSDictionary dictionaryWithObject:[NSDictionary dictionaryWithObjectsAndKeys:
																  @"name1", @"name",
																  [GRYes yes], @"current",
																  [NSDictionary dictionaryWithObject:@"http://item1" forKey:@"url"], @"link",
																  nil]
														  forKey:@"item"],
							  [NSDictionary dictionaryWithObject:[NSDictionary dictionaryWithObjectsAndKeys:
																  @"name2", @"name",
																  [GRNo no], @"current",
																  [NSDictionary dictionaryWithObject:@"http://item2" forKey:@"url"], @"link",
																  nil]
														  forKey:@"item"],
							  nil],
							 @"list",
							 nil];
	for (int i=0; i < 50000; i++) {
		[template renderObject:context];
	}
}

@end
