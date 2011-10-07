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

@interface GRMustacheBenchmarkTest()
- (NSString *)templateString;
- (NSDictionary *)context;
@end

@implementation GRMustacheBenchmarkTest

//- (void)testParsingBenchmark {
//    NSString *templateString = [self templateString];
//    [GRMustacheTemplate parseString:templateString error:nil];
//}
//
//- (void)testRenderingBenchmark {
//    NSString *templateString = [self templateString];
//    NSDictionary *context = [self context];
//    GRMustacheTemplate *template = [GRMustacheTemplate parseString:templateString error:nil];
//    [template renderObject:context];
//}

#pragma mark Private

- (NSString *)templateString {
    int doublingCount = 10; // 2^10=1024 sections
    NSString *baseString = @"{{#items}}item{{item}}{{/items}}";
    NSMutableString *templateString = [NSMutableString stringWithCapacity:baseString.length * (1 << doublingCount)];
    [templateString appendString:baseString];
    for (int i=0; i<doublingCount; i++) { [templateString appendString:templateString]; }
    return templateString;
}

- (NSDictionary *)context {
    int doublingCount = 10; // 2^10=1024 items
    NSMutableArray *items = [[NSMutableArray arrayWithCapacity:(1 << doublingCount)] retain];
    [items addObject:[NSMutableDictionary dictionaryWithObject:@"item" forKey:@"item"]];
    for (int i=0; i<doublingCount; i++) { [items addObjectsFromArray:[NSArray arrayWithArray:items]]; }
    return [NSDictionary dictionaryWithObject:items forKey:@"items"];
}

@end
