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

@interface GRMustacheProtectedContextTest : GRMustachePublicAPITest
@end

@implementation GRMustacheProtectedContextTest

- (void)testProtectedObjectCanBeAccessed
{
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{safe}}" error:NULL];
    template.baseContext = [template.baseContext contextByAddingProtectedObject:@{ @"safe": @"important" }];
    NSString *rendering = [template renderObject:nil error:NULL];
    STAssertEqualObjects(rendering, @"important", @"");
}

- (void)testMultipleProtectedObjectCanBeAccessed
{
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{safe1}}, {{safe2}}" error:NULL];
    template.baseContext = [template.baseContext contextByAddingProtectedObject:@{ @"safe1": @"important1" }];
    template.baseContext = [template.baseContext contextByAddingProtectedObject:@{ @"safe2": @"important2" }];
    NSString *rendering = [template renderObject:nil error:NULL];
    STAssertEqualObjects(rendering, @"important1, important2", @"");
}

- (void)testProtectedObjectCanNotBeShadowed
{
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{safe}}, {{fragile}}" error:NULL];
    template.baseContext = [template.baseContext contextByAddingProtectedObject:@{ @"safe": @"important" }];
    NSString *rendering = [template renderObject:@{ @"safe": @"error", @"fragile": @"not important" } error:NULL];
    STAssertEqualObjects(rendering, @"important, not important", @"");
}

- (void)testDeepProtectedObjectCanBeAccessedViaFullKeyPath
{
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{safe.name}}" error:NULL];
    template.baseContext = [template.baseContext contextByAddingProtectedObject:@{ @"safe": @{ @"name": @"important" } }];
    NSString *rendering = [template renderObject:nil error:NULL];
    STAssertEqualObjects(rendering, @"important", @"");
}

- (void)testDeepProtectedObjectCanBeAccessedViaScope
{
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{#safe}}{{.name}}{{/safe}}" error:NULL];
    template.baseContext = [template.baseContext contextByAddingProtectedObject:@{ @"safe": @{ @"name": @"important" } }];
    NSString *rendering = [template renderObject:nil error:NULL];
    STAssertEqualObjects(rendering, @"important", @"");
}

- (void)testDeepProtectedObjectCanNotBeAccessedViaIdentifier
{
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{#safe}}{{name}}{{/safe}}" error:NULL];
    template.baseContext = [template.baseContext contextByAddingProtectedObject:@{ @"safe": @{ @"name": @"important" } }];
    NSString *rendering = [template renderObject:nil error:NULL];
    STAssertEqualObjects(rendering, @"", @"");
}

- (void)testUnreachableDeepProtectedObjectCanBeShadowed
{
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{#safe}}{{name}}{{/safe}}" error:NULL];
    template.baseContext = [template.baseContext contextByAddingProtectedObject:@{ @"safe": @{ @"name": @"important" } }];
    NSString *rendering = [template renderObject:@{ @"name": @"not important" } error:NULL];
    STAssertEqualObjects(rendering, @"not important", @"");
}

- (void)testRenderingContextsDoesHonorProtectedObjects
{
    // we expect the rendering to be gold
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{#object}}{{precious}}{{/}}" error:NULL];
    GRMustacheContext *context = [template.baseContext contextByAddingProtectedObject:@{@"precious":@"gold"}];
    context = [context contextByAddingObject:@{@"object":@{@"precious":@"aluminum"}}];
    
    // protected stack does apply
    STAssertEqualObjects([template renderObject:context error:NULL], @"gold", @"");
    
    // protected stack does apply
    template.baseContext = context;
    STAssertEqualObjects([template renderObject:nil error:NULL], @"gold", @"");
}

@end
