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

@interface GRMustachePriorityContextTest : GRMustachePublicAPITest
@end

@implementation GRMustachePriorityContextTest

- (void)testPriorityObjectCanBeAccessed
{
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{safe}}" error:NULL];
    template.baseContext = [template.baseContext contextByAddingPriorityObject:@{ @"safe": @"important" }];
    NSString *rendering = [template renderObject:nil error:NULL];
    STAssertEqualObjects(rendering, @"important", @"");
}

- (void)testMultiplePriorityObjectCanBeAccessed
{
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{safe1}}, {{safe2}}" error:NULL];
    template.baseContext = [template.baseContext contextByAddingPriorityObject:@{ @"safe1": @"important1" }];
    template.baseContext = [template.baseContext contextByAddingPriorityObject:@{ @"safe2": @"important2" }];
    NSString *rendering = [template renderObject:nil error:NULL];
    STAssertEqualObjects(rendering, @"important1, important2", @"");
}

- (void)testPriorityObjectCanNotBeShadowed
{
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{safe}}, {{fragile}}" error:NULL];
    template.baseContext = [template.baseContext contextByAddingPriorityObject:@{ @"safe": @"important" }];
    NSString *rendering = [template renderObject:@{ @"safe": @"error", @"fragile": @"not important" } error:NULL];
    STAssertEqualObjects(rendering, @"important, not important", @"");
}

- (void)testDeepPriorityObjectCanBeAccessedViaFullKeyPath
{
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{safe.name}}" error:NULL];
    template.baseContext = [template.baseContext contextByAddingPriorityObject:@{ @"safe": @{ @"name": @"important" } }];
    NSString *rendering = [template renderObject:nil error:NULL];
    STAssertEqualObjects(rendering, @"important", @"");
}

- (void)testDeepPriorityObjectCanBeAccessedViaScope
{
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{#safe}}{{.name}}{{/safe}}" error:NULL];
    template.baseContext = [template.baseContext contextByAddingPriorityObject:@{ @"safe": @{ @"name": @"important" } }];
    NSString *rendering = [template renderObject:nil error:NULL];
    STAssertEqualObjects(rendering, @"important", @"");
}

- (void)testDeepPriorityObjectCanNotBeAccessedViaIdentifier
{
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{#safe}}{{name}}{{/safe}}" error:NULL];
    template.baseContext = [template.baseContext contextByAddingPriorityObject:@{ @"safe": @{ @"name": @"important" } }];
    NSString *rendering = [template renderObject:nil error:NULL];
    STAssertEqualObjects(rendering, @"", @"");
}

- (void)testUnreachableDeepPriorityObjectCanBeShadowed
{
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{#safe}}{{name}}{{/safe}}" error:NULL];
    template.baseContext = [template.baseContext contextByAddingPriorityObject:@{ @"safe": @{ @"name": @"important" } }];
    NSString *rendering = [template renderObject:@{ @"name": @"not important" } error:NULL];
    STAssertEqualObjects(rendering, @"not important", @"");
}

@end
