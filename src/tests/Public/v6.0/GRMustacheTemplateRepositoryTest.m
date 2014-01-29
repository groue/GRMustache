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

#define GRMUSTACHE_VERSION_MAX_ALLOWED GRMUSTACHE_VERSION_6_0
#import "GRMustachePublicAPITest.h"

@interface GRMustacheTemplateRepositoryTest : GRMustachePublicAPITest
@end

@implementation GRMustacheTemplateRepositoryTest

- (void)testTemplateInstancesAreNotReused
{
    NSDictionary *templates = @{ @"name": @"value: {{ value }}" };
    GRMustacheTemplateRepository *repository = [GRMustacheTemplateRepository templateRepositoryWithDictionary:templates];
    
    GRMustacheTemplate *template1 = [repository templateNamed:@"name" error:NULL];
    template1.baseContext = [template1.baseContext contextByAddingObject:@{ @"value": @"foo" }];
    
    GRMustacheTemplate *template2 = [repository templateNamed:@"name" error:NULL];
    
    STAssertTrue(template1 != template2, @"");
    STAssertEqualObjects([template1 renderObject:nil error:NULL], @"value: foo", nil);
    STAssertEqualObjects([template2 renderObject:nil error:NULL], @"value: ", nil);
}

@end
