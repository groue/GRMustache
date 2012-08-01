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

#define GRMUSTACHE_VERSION_MAX_ALLOWED GRMUSTACHE_VERSION_4_3
#import "GRMustachePublicAPITest.h"

@interface GRMustacheTemplateDelegate_v4_3_Test : GRMustachePublicAPITest
@end

@interface GRMustacheTemplateDelegate_v4_3_NaiveDelegate : NSObject<GRMustacheTemplateDelegate>
@end

@implementation GRMustacheTemplateDelegate_v4_3_NaiveDelegate

- (void)template:(GRMustacheTemplate *)template willInterpretReturnValueOfInvocation:(GRMustacheInvocation *)invocation as:(GRMustacheInterpretation)interpretation
{
    invocation.returnValue = @"delegate was here";
}

@end

@implementation GRMustacheTemplateDelegate_v4_3_Test

- (void)testNaiveDelegateDoesNotBreakFiltering
{
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{%FILTERS}}{{uppercase(.)}}" error:NULL];
    template.delegate = [[[GRMustacheTemplateDelegate_v4_3_NaiveDelegate alloc] init] autorelease];
    STAssertNoThrow([template renderObject:@"foo"], nil);
    NSString *rendering = [template renderObject:@"foo"];
    STAssertEqualObjects(rendering, @"DELEGATE WAS HERE", nil);
}

@end
