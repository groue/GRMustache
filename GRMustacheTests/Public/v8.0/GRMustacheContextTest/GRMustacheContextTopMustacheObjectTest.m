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

#define GRMUSTACHE_VERSION_MAX_ALLOWED GRMUSTACHE_VERSION_8_0
#import "GRMustachePublicAPITest.h"
#import "GRMustacheTestingDelegate.h"

@interface GRMustacheContextTopMustacheObjectTest : GRMustachePublicAPITest
@end

@implementation GRMustacheContextTopMustacheObjectTest

- (void)testTopMustacheObject
{
    GRMustacheContext *context = [GRMustacheContext context];
    XCTAssertNil([context topMustacheObject], @"");
    
    id object = @"object";
    context = [context contextByAddingObject:object];
    XCTAssertEqual([context topMustacheObject], object, @"");
    
    id protectedObject = @"protectedObject";
    context = [context contextByAddingProtectedObject:protectedObject];
    XCTAssertEqual([context topMustacheObject], object, @"");
    
    id tagDelegate = [[[GRMustacheTestingDelegate alloc] init] autorelease];
    context = [context contextByAddingTagDelegate:tagDelegate];
    XCTAssertEqual([context topMustacheObject], object, @"");

    id object2 = @"object2";
    context = [context contextByAddingObject:object2];
    XCTAssertEqual([context topMustacheObject], object2, @"");
}

@end
