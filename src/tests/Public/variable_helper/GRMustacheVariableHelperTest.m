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

// TODO #define GRMUSTACHE_VERSION_MAX_ALLOWED GRMUSTACHE_VERSION_5_0
#import "GRMustachePublicAPITest.h"

@interface GRMustacheVariableHelperTest : GRMustachePublicAPITest
@end

@interface GRMustacheStringVariableHelper : NSObject<GRMustacheVariableHelper> {
    NSString *_string;
}
@property (nonatomic, copy) NSString *string;
@end

@implementation GRMustacheStringVariableHelper
@synthesize string=_string;
- (void)dealloc
{
    self.string = nil;
    [super dealloc];
}
- (NSString *)renderVariable:(GRMustacheVariable *)variable
{
    return self.string;
}
@end

@interface GRMustacheRecorderVariableHelper : NSObject<GRMustacheVariableHelper> {
    NSUInteger _invocationCount;
}
@property (nonatomic) NSUInteger invocationCount;
@end

@implementation GRMustacheRecorderVariableHelper
@synthesize invocationCount=_invocationCount;
- (void)dealloc
{
    [super dealloc];
}
- (NSString *)renderVariable:(GRMustacheVariable *)variable
{
    self.invocationCount += 1;
    return nil;
}
@end

@implementation GRMustacheVariableHelperTest

- (void)testHelperPerformsRendering
{
    {
        // GRMustacheVariableHelper protocol
        GRMustacheStringVariableHelper *helper = [[[GRMustacheStringVariableHelper alloc] init] autorelease];
        helper.string = @"---";
        NSDictionary *context = [NSDictionary dictionaryWithObject:helper forKey:@"helper"];
        NSString *result = [GRMustacheTemplate renderObject:context fromString:@"{{helper}}" error:nil];
        STAssertEqualObjects(result, @"---", @"");
    }
    {
        // [GRMustacheVariableHelper helperWithBlock:]
        id helper = [GRMustacheVariableHelper helperWithBlock:^NSString *(GRMustacheVariable *variable) {
            return @"---";
        }];
        NSDictionary *context = [NSDictionary dictionaryWithObject:helper forKey:@"helper"];
        NSString *result = [GRMustacheTemplate renderObject:context fromString:@"{{helper}}" error:nil];
        STAssertEqualObjects(result, @"---", @"");
    }
}

- (void)testHelperRenderingIsNotProcessed
{
    // This test is against Mustache spec lambda definition, which render a template string that should be processed.
    
    {
        // GRMustacheVariableHelper protocol
        GRMustacheStringVariableHelper *helper = [[[GRMustacheStringVariableHelper alloc] init] autorelease];
        helper.string = @"&<>{{foo}}";
        NSDictionary *context = [NSDictionary dictionaryWithObject:helper forKey:@"helper"];
        NSString *result = [GRMustacheTemplate renderObject:context fromString:@"{{helper}}" error:nil];
        STAssertEqualObjects(result, @"&<>{{foo}}", @"");
    }
    {
        // [GRMustacheVariableHelper helperWithBlock:]
        id helper = [GRMustacheVariableHelper helperWithBlock:^NSString *(GRMustacheVariable *variable) {
            return @"&<>{{foo}}";
        }];
        NSDictionary *context = [NSDictionary dictionaryWithObject:helper forKey:@"helper"];
        NSString *result = [GRMustacheTemplate renderObject:context fromString:@"{{helper}}" error:nil];
        STAssertEqualObjects(result, @"&<>{{foo}}", @"");
    }
}

- (void)testHelperCanRenderNil
{
    {
        // GRMustacheVariableHelper protocol
        GRMustacheStringVariableHelper *helper = [[[GRMustacheStringVariableHelper alloc] init] autorelease];
        helper.string = nil;
        NSDictionary *context = [NSDictionary dictionaryWithObject:helper forKey:@"helper"];
        NSString *result = [GRMustacheTemplate renderObject:context fromString:@"{{helper}}" error:nil];
        STAssertEqualObjects(result, @"", @"");
    }
    {
        // [GRMustacheVariableHelper helperWithBlock:]
        id helper = [GRMustacheVariableHelper helperWithBlock:^NSString *(GRMustacheVariable *variable) {
            return nil;
        }];
        NSDictionary *context = [NSDictionary dictionaryWithObject:helper forKey:@"helper"];
        NSString *result = [GRMustacheTemplate renderObject:context fromString:@"{{helper}}" error:nil];
        STAssertEqualObjects(result, @"", @"");
    }
}

- (void)testHelperIsNotCalledWhenItDoesntNeedTo
{
    {
        // GRMustacheVariableHelper protocol
        {
            GRMustacheRecorderVariableHelper *helper = [[[GRMustacheRecorderVariableHelper alloc] init] autorelease];
            NSDictionary *context = [NSDictionary dictionaryWithObject:helper forKey:@"helper"];
            [GRMustacheTemplate renderObject:context fromString:@"{{helper}}" error:nil];
            STAssertEquals(helper.invocationCount, (NSUInteger)1, @"");
        }
        {
            GRMustacheRecorderVariableHelper *helper = [[[GRMustacheRecorderVariableHelper alloc] init] autorelease];
            NSDictionary *context = [NSDictionary dictionaryWithObject:helper forKey:@"helper"];
            [GRMustacheTemplate renderObject:context fromString:@"{{#helper}}{{/helper}}" error:nil];
            STAssertEquals(helper.invocationCount, (NSUInteger)0, @"");
        }
        {
            GRMustacheRecorderVariableHelper *helper = [[[GRMustacheRecorderVariableHelper alloc] init] autorelease];
            NSDictionary *context = [NSDictionary dictionaryWithObject:helper forKey:@"helper"];
            [GRMustacheTemplate renderObject:context fromString:@"{{^helper}}{{/helper}}" error:nil];
            STAssertEquals(helper.invocationCount, (NSUInteger)0, @"");
        }
        {
            GRMustacheRecorderVariableHelper *helper = [[[GRMustacheRecorderVariableHelper alloc] init] autorelease];
            NSDictionary *context = [NSDictionary dictionaryWithObject:helper forKey:@"helper"];
            [GRMustacheTemplate renderObject:context fromString:@"{{#false}}{{helper}}{{/false}}" error:nil];
            STAssertEquals(helper.invocationCount, (NSUInteger)0, @"");
        }
    }
    {
        // [GRMustacheVariableHelper helperWithBlock:]
        {
            __block NSUInteger invocationCount = 0;
            id helper = [GRMustacheVariableHelper helperWithBlock:^NSString *(GRMustacheVariable *variable) {
                invocationCount++;
                return nil;
            }];
            NSDictionary *context = [NSDictionary dictionaryWithObject:helper forKey:@"helper"];
            [GRMustacheTemplate renderObject:context fromString:@"{{helper}}" error:nil];
            STAssertEquals(invocationCount, (NSUInteger)1, @"");
        }
        {
            __block NSUInteger invocationCount = 0;
            id helper = [GRMustacheVariableHelper helperWithBlock:^NSString *(GRMustacheVariable *variable) {
                invocationCount++;
                return nil;
            }];
            NSDictionary *context = [NSDictionary dictionaryWithObject:helper forKey:@"helper"];
            [GRMustacheTemplate renderObject:context fromString:@"{{#helper}}{{/helper}}" error:nil];
            STAssertEquals(invocationCount, (NSUInteger)0, @"");
        }
        {
            __block NSUInteger invocationCount = 0;
            id helper = [GRMustacheVariableHelper helperWithBlock:^NSString *(GRMustacheVariable *variable) {
                invocationCount++;
                return nil;
            }];
            NSDictionary *context = [NSDictionary dictionaryWithObject:helper forKey:@"helper"];
            [GRMustacheTemplate renderObject:context fromString:@"{{^helper}}{{/helper}}" error:nil];
            STAssertEquals(invocationCount, (NSUInteger)0, @"");
        }
        {
            __block NSUInteger invocationCount = 0;
            id helper = [GRMustacheVariableHelper helperWithBlock:^NSString *(GRMustacheVariable *variable) {
                invocationCount++;
                return nil;
            }];
            NSDictionary *context = [NSDictionary dictionaryWithObject:helper forKey:@"helper"];
            [GRMustacheTemplate renderObject:context fromString:@"{{#false}}{{helper}}{{/false}}" error:nil];
            STAssertEquals(invocationCount, (NSUInteger)0, @"");
        }
    }
}

- (void)testHelperCanRenderCurrentContextInDistinctTemplate
{
    id helper = [GRMustacheVariableHelper helperWithBlock:^NSString *(GRMustacheVariable *variable) {
        return [variable renderTemplateString:@"{{subject}}" error:NULL];
    }];
    NSDictionary *context = [NSDictionary dictionaryWithObjectsAndKeys:
                             helper, @"helper",
                             @"---", @"subject", nil];
    NSString *result = [GRMustacheTemplate renderObject:context fromString:@"{{helper}}" error:nil];
    STAssertEqualObjects(result, @"---", @"");
}

- (void)testHelperCanRenderCurrentContextInDistinctTemplateContainingPartial
{
    id helper = [GRMustacheVariableHelper helperWithBlock:^NSString *(GRMustacheVariable *variable) {
        return [variable renderTemplateString:@"{{>partial}}" error:NULL];
    }];
    NSDictionary *context = @{@"helper": helper};
    NSDictionary *partials = @{@"partial": @"In partial."};
    GRMustacheTemplateRepository *repository = [GRMustacheTemplateRepository templateRepositoryWithPartialsDictionary:partials];
    GRMustacheTemplate *template = [repository templateFromString:@"{{helper}}" error:nil];
    NSString *result = [template renderObject:context];
    STAssertEqualObjects(result, @"In partial.", @"");
}

- (void)testHelperRenderingOfCurrentContextInDistinctTemplateContainingPartialIsNotHTMLEscaped
{
    id helper = [GRMustacheVariableHelper helperWithBlock:^NSString *(GRMustacheVariable *variable) {
        return [variable renderTemplateString:@"{{>partial}}" error:NULL];
    }];
    NSDictionary *context = @{@"helper": helper};
    NSDictionary *partials = @{@"partial": @"&<>{{foo}}"};
    GRMustacheTemplateRepository *repository = [GRMustacheTemplateRepository templateRepositoryWithPartialsDictionary:partials];
    GRMustacheTemplate *template = [repository templateFromString:@"{{helper}}" error:nil];
    NSString *result = [template renderObject:context];
    STAssertEqualObjects(result, @"&<>", @"");
}

- (void)testTemplateDelegateCallbacksAreCalledDuringAlternateTemplateStringRendering
{
    id helper = [GRMustacheVariableHelper helperWithBlock:^NSString *(GRMustacheVariable *variable) {
        return [variable renderTemplateString:@"{{subject}}" error:NULL];
    }];
    
    GRMustacheTestingDelegate *delegate = [[[GRMustacheTestingDelegate alloc] init] autorelease];
    delegate.templateWillInterpretBlock = ^(GRMustacheTemplate *template, GRMustacheInvocation *invocation, GRMustacheInterpretation interpretation) {
        invocation.returnValue = @"delegate";
    };
    
    NSDictionary *context = [NSDictionary dictionaryWithObjectsAndKeys:
                             helper, @"helper",
                             @"---", @"subject", nil];
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{helper}}" error:NULL];
    template.delegate = delegate;
    NSString *result = [template renderObject:context];
    STAssertEqualObjects(result, @"delegate", @"");
}

- (void)testDynamicPartialHelper
{
    id helper = [GRMustacheDynamicPartial dynamicPartialWithName:@"partial"];
    NSDictionary *context = @{@"helper": helper};
    NSDictionary *partials = @{@"partial": @"In partial."};
    GRMustacheTemplateRepository *repository = [GRMustacheTemplateRepository templateRepositoryWithPartialsDictionary:partials];
    GRMustacheTemplate *template = [repository templateFromString:@"{{helper}}" error:nil];
    NSString *result = [template renderObject:context];
    STAssertEqualObjects(result, @"In partial.", @"");
}

- (void)testRenderingOfDynamicPartialHelperIsNotHTMLEscaped
{
    id helper = [GRMustacheDynamicPartial dynamicPartialWithName:@"partial"];
    NSDictionary *context = @{@"helper": helper};
    NSDictionary *partials = @{@"partial": @"&<>{{foo}}"};
    GRMustacheTemplateRepository *repository = [GRMustacheTemplateRepository templateRepositoryWithPartialsDictionary:partials];
    GRMustacheTemplate *template = [repository templateFromString:@"{{helper}}" error:nil];
    NSString *result = [template renderObject:context];
    STAssertEqualObjects(result, @"&<>", @"");
}

@end
