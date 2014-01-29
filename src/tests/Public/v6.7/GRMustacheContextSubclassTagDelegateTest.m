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

#define GRMUSTACHE_VERSION_MAX_ALLOWED GRMUSTACHE_VERSION_6_7
#import "GRMustachePublicAPITest.h"


@interface GRMustacheContextSubclassTagDelegate : GRMustacheContext<GRMustacheTagDelegate>
@property (nonatomic) int didRenderObjectCount;
@end

@implementation GRMustacheContextSubclassTagDelegate
@dynamic didRenderObjectCount;

- (id)mustacheTag:(GRMustacheTag *)tag willRenderObject:(id)object
{
    if (object) {
        return object;
    }
    return [self valueForMustacheKey:@"default"];
}

- (void)mustacheTag:(GRMustacheTag *)tag didRenderObject:(id)object as:(NSString *)rendering
{
    self.didRenderObjectCount += 1;
}

@end


@interface GRMustacheContextSubclassTagDelegateTest : GRMustachePublicAPITest
@end

@implementation GRMustacheContextSubclassTagDelegateTest

- (void)testMustacheTagWillRenderObject
{
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{name}},{{#a}}{{name}}{{/a}}" error:NULL];
    template.baseContext = [GRMustacheContextSubclassTagDelegate context];
    
    id data = @{ @"default": @"foo", @"a": @{ @"default": @"bar" } };
    NSString *rendering = [template renderObject:data error:NULL];
    STAssertEqualObjects(rendering, @"foo,bar", @"");
}

- (void)testMustacheTagDidRenderObject
{
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{didRenderObjectCount}},{{didRenderObjectCount}}" error:NULL];
    GRMustacheContextSubclassTagDelegate *context = [GRMustacheContextSubclassTagDelegate context];
    
    NSString *rendering = [template renderObject:context error:NULL];
    STAssertEqualObjects(rendering, @"0,1", @"");
}

@end
