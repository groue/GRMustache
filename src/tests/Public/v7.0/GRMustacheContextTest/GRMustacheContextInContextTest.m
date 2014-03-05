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

@interface GRMustacheContextInContextTest : GRMustachePublicAPITest
@end

@implementation GRMustacheContextInContextTest

- (void)testContextInContext
{
    GRMustacheContext *context1 = [GRMustacheContext contextWithObject:@{ @"a":@"a1" }];
    context1 = [context1 contextByAddingObject:@{ @"b": @"b1" }];
    
    GRMustacheContext *context2 = [GRMustacheContext contextWithObject:@{ @"a":@"a2" }];
    context2 = [context2 contextByAddingObject:@{ @"c": @"c2" }];
    
    GRMustacheContext *context = [context1 contextByAddingObject:context2];
    
    STAssertEqualObjects([context valueForMustacheKey:@"a"], @"a2", @"");
    STAssertEqualObjects([context valueForMustacheKey:@"b"], @"b1", @"");
    STAssertEqualObjects([context valueForMustacheKey:@"c"], @"c2", @"");
}

@end
