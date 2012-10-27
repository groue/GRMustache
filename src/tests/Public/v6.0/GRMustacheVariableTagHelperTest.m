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

#define GRMUSTACHE_VERSION_MAX_ALLOWED GRMUSTACHE_VERSION_6_0
#import "GRMustachePublicAPITest.h"


@interface GRMustacheVariableTagHelperTest : GRMustachePublicAPITest
@end

//@interface GRMustacheStringVariableTagHelper : NSObject<GRMustacheVariableTagHelper> {
//    NSString *_rendering;
//}
//@property (nonatomic, copy) NSString *rendering;
//@end
//
//@implementation GRMustacheStringVariableTagHelper
//@synthesize rendering=_rendering;
//- (void)dealloc
//{
//    self.rendering = nil;
//    [super dealloc];
//}
//- (NSString *)renderForVariableTagInContext:(GRMustacheVariableTagRenderingContext *)context
//{
//    return self.rendering;
//}
//@end
//
//@interface GRMustacheVariableTagHelperDelegate: NSObject<GRMustacheVariableTagHelper, GRMustacheTemplateDelegate> {
//    NSString *_returnValue;
//}
//@property (nonatomic, retain) NSString *returnValue;
//@end
//
//@implementation GRMustacheVariableTagHelperDelegate
//@synthesize returnValue=_returnValue;
//
//- (void)dealloc
//{
//    self.returnValue = nil;
//    [super dealloc];
//}
//
//- (NSString *)foo
//{
//    return @"foo";
//}
//
//- (NSString *)renderForVariableTagInContext:(GRMustacheVariableTagRenderingContext *)context
//{
//    return [context renderString:@"<{{foo}}>" error:NULL];
//}
//
//- (void)template:(GRMustacheTemplate *)template willInterpretReturnValueOfInvocation:(GRMustacheInvocation *)invocation as:(GRMustacheInterpretation)interpretation
//{
//    self.returnValue = invocation.returnValue;
//}
//
//@end
//
//@interface GRMustacheSelfRenderingWithTemplateStringVariableTagHelper : NSObject<GRMustacheVariableTagHelper> {
//    NSString *_name;
//    NSString *_templateString;
//}
//@property (nonatomic, copy) NSString *name;
//@property (nonatomic, copy) NSString *templateString;
//@end
//
//@implementation GRMustacheSelfRenderingWithTemplateStringVariableTagHelper
//@synthesize name=_name;
//@synthesize templateString=_templateString;
//- (void)dealloc
//{
//    self.name = nil;
//    self.templateString = nil;
//    [super dealloc];
//}
//- (NSString *)renderForVariableTagInContext:(GRMustacheVariableTagRenderingContext *)context
//{
//    return [context renderString:self.templateString error:NULL];
//}
//@end
//
//@interface GRMustacheSelfRenderingWithPartialVariableTagHelper : NSObject<GRMustacheVariableTagHelper> {
//    NSString *_name;
//    NSString *_partialName;
//}
//@property (nonatomic, copy) NSString *name;
//@property (nonatomic, copy) NSString *partialName;
//@end
//
//@implementation GRMustacheSelfRenderingWithPartialVariableTagHelper
//@synthesize name=_name;
//@synthesize partialName=_partialName;
//- (void)dealloc
//{
//    self.name = nil;
//    self.partialName = nil;
//    [super dealloc];
//}
//- (NSString *)renderForVariableTagInContext:(GRMustacheVariableTagRenderingContext *)context
//{
//    return [context renderTemplateNamed:self.partialName error:NULL];
//}
//@end
//
//@interface GRMustacheRecorderVariableTagHelper : NSObject<GRMustacheVariableTagHelper> {
//    NSUInteger _invocationCount;
//}
//@property (nonatomic) NSUInteger invocationCount;
//@end
//
//@implementation GRMustacheRecorderVariableTagHelper
//@synthesize invocationCount=_invocationCount;
//- (void)dealloc
//{
//    [super dealloc];
//}
//- (NSString *)renderForVariableTagInContext:(GRMustacheVariableTagRenderingContext *)context
//{
//    self.invocationCount += 1;
//    return nil;
//}
//@end

@implementation GRMustacheVariableTagHelperTest

- (void)testHelperPerformsRendering
{
    // [GRMustacheVariableTagHelper helperWithBlock:]
    id helper = [GRMustache renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheRuntime *runtime, GRMustacheTemplateRepository *templateRepository, BOOL *HTMLEscaped) {
        return @"---";
    }];
    NSDictionary *context = [NSDictionary dictionaryWithObject:helper forKey:@"helper"];
    NSString *result = [[GRMustacheTemplate templateFromString:@"{{helper}}" error:nil] renderObject:context];
    STAssertEqualObjects(result, @"---", @"");
}

- (void)testHelperRenderingIsHTMLEscaped
{
    {
        id helper = [GRMustache renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheRuntime *runtime, GRMustacheTemplateRepository *templateRepository, BOOL *HTMLEscaped) {
            *HTMLEscaped = NO;
            return @"&<>{{foo}}";
        }];
        NSDictionary *context = [NSDictionary dictionaryWithObject:helper forKey:@"helper"];
        NSString *result = [[GRMustacheTemplate templateFromString:@"{{helper}}" error:nil] renderObject:context];
        STAssertEqualObjects(result, @"&amp;&lt;&gt;{{foo}}", @"");
    }
    {
        id helper = [GRMustache renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheRuntime *runtime, GRMustacheTemplateRepository *templateRepository, BOOL *HTMLEscaped) {
            *HTMLEscaped = NO;
            return @"&<>{{foo}}";
        }];
        NSDictionary *context = [NSDictionary dictionaryWithObject:helper forKey:@"helper"];
        NSString *result = [[GRMustacheTemplate templateFromString:@"{{{helper}}}" error:nil] renderObject:context];
        STAssertEqualObjects(result, @"&<>{{foo}}", @"");
    }
    {
        id helper = [GRMustache renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheRuntime *runtime, GRMustacheTemplateRepository *templateRepository, BOOL *HTMLEscaped) {
            *HTMLEscaped = YES;
            return @"&<>{{foo}}";
        }];
        NSDictionary *context = [NSDictionary dictionaryWithObject:helper forKey:@"helper"];
        NSString *result = [[GRMustacheTemplate templateFromString:@"{{helper}}" error:nil] renderObject:context];
        STAssertEqualObjects(result, @"&<>{{foo}}", @"");
    }
    {
        id helper = [GRMustache renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheRuntime *runtime, GRMustacheTemplateRepository *templateRepository, BOOL *HTMLEscaped) {
            *HTMLEscaped = YES;
            return @"&<>{{foo}}";
        }];
        NSDictionary *context = [NSDictionary dictionaryWithObject:helper forKey:@"helper"];
        NSString *result = [[GRMustacheTemplate templateFromString:@"{{{helper}}}" error:nil] renderObject:context];
        STAssertEqualObjects(result, @"&<>{{foo}}", @"");
    }
}

- (void)testHelperRenderingIsHTMLEscapedByDefault
{
    id helper = [GRMustache renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheRuntime *runtime, GRMustacheTemplateRepository *templateRepository, BOOL *HTMLEscaped) {
        return @"&<>{{foo}}";
    }];
    NSDictionary *context = [NSDictionary dictionaryWithObject:helper forKey:@"helper"];
    NSString *result = [[GRMustacheTemplate templateFromString:@"{{helper}}" error:nil] renderObject:context];
    STAssertEqualObjects(result, @"&amp;&lt;&gt;{{foo}}", @"");
}

- (void)testHelperCanRenderNil
{
    // [GRMustacheVariableTagHelper helperWithBlock:]
    id helper = [GRMustache renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheRuntime *runtime, GRMustacheTemplateRepository *templateRepository, BOOL *HTMLEscaped) {
        return nil;
    }];
    NSDictionary *context = [NSDictionary dictionaryWithObject:helper forKey:@"helper"];
    NSString *result = [[GRMustacheTemplate templateFromString:@"{{helper}}" error:nil] renderObject:context];
    STAssertEqualObjects(result, @"", @"");
}

- (void)testHelperIsNotCalledWhenItDoesntNeedTo
{
    // [GRMustacheVariableTagHelper helperWithBlock:]
    {
        __block NSUInteger invocationCount = 0;
        id helper = [GRMustache renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheRuntime *runtime, GRMustacheTemplateRepository *templateRepository, BOOL *HTMLEscaped) {
            if (tag.type == GRMustacheTagTypeVariable) {
                invocationCount++;
            }
            return nil;
        }];
        NSDictionary *context = [NSDictionary dictionaryWithObject:helper forKey:@"helper"];
        [[GRMustacheTemplate templateFromString:@"{{helper}}" error:nil] renderObject:context];
        STAssertEquals(invocationCount, (NSUInteger)1, @"");
    }
    {
        __block NSUInteger invocationCount = 0;
        id helper = [GRMustache renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheRuntime *runtime, GRMustacheTemplateRepository *templateRepository, BOOL *HTMLEscaped) {
            if (tag.type == GRMustacheTagTypeVariable) {
                invocationCount++;
            }
            return nil;
        }];
        NSDictionary *context = [NSDictionary dictionaryWithObject:helper forKey:@"helper"];
        [[GRMustacheTemplate templateFromString:@"{{#helper}}{{/helper}}" error:nil] renderObject:context];
        STAssertEquals(invocationCount, (NSUInteger)0, @"");
    }
    {
        __block NSUInteger invocationCount = 0;
        id helper = [GRMustache renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheRuntime *runtime, GRMustacheTemplateRepository *templateRepository, BOOL *HTMLEscaped) {
            if (tag.type == GRMustacheTagTypeVariable) {
                invocationCount++;
            }
            return nil;
        }];
        NSDictionary *context = [NSDictionary dictionaryWithObject:helper forKey:@"helper"];
        [[GRMustacheTemplate templateFromString:@"{{^helper}}{{/helper}}" error:nil] renderObject:context];
        STAssertEquals(invocationCount, (NSUInteger)0, @"");
    }
    {
        __block NSUInteger invocationCount = 0;
        id helper = [GRMustache renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheRuntime *runtime, GRMustacheTemplateRepository *templateRepository, BOOL *HTMLEscaped) {
            if (tag.type == GRMustacheTagTypeVariable) {
                invocationCount++;
            }
            return nil;
        }];
        NSDictionary *context = [NSDictionary dictionaryWithObject:helper forKey:@"helper"];
        [[GRMustacheTemplate templateFromString:@"{{#false}}{{helper}}{{/false}}" error:nil] renderObject:context];
        STAssertEquals(invocationCount, (NSUInteger)0, @"");
    }
}

//- (void)testHelperCanRenderCurrentContextInDistinctTemplate
//{
//    id helper = [GRMustache renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheRuntime *runtime, GRMustacheTemplateRepository *templateRepository, BOOL *HTMLEscaped) {
//        return [context renderString:@"{{subject}}" error:NULL];
//    }];
//    NSDictionary *context = [NSDictionary dictionaryWithObjectsAndKeys:
//                             helper, @"helper",
//                             @"---", @"subject", nil];
//    NSString *result = [[GRMustacheTemplate templateFromString:@"{{helper}}" error:nil] renderObject:context];
//    STAssertEqualObjects(result, @"---", @"");
//}
//
//- (void)testHelperCanRenderCurrentContextInDistinctTemplateContainingPartial
//{
//    id helper = [GRMustache renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheRuntime *runtime, GRMustacheTemplateRepository *templateRepository, BOOL *HTMLEscaped) {
//        return [context renderString:@"{{>partial}}" error:NULL];
//    }];
//    NSDictionary *context = @{@"helper": helper};
//    NSDictionary *partials = @{@"partial": @"In partial."};
//    GRMustacheTemplateRepository *repository = [GRMustacheTemplateRepository templateRepositoryWithPartialsDictionary:partials];
//    GRMustacheTemplate *template = [repository templateFromString:@"{{helper}}" error:nil];
//    NSString *result = [template renderObject:context];
//    STAssertEqualObjects(result, @"In partial.", @"");
//}
//
//- (void)testHelperRenderingOfCurrentContextInDistinctTemplateContainingPartialIsNotHTMLEscaped
//{
//    id helper = [GRMustache renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheRuntime *runtime, GRMustacheTemplateRepository *templateRepository, BOOL *HTMLEscaped) {
//        return [context renderString:@"{{>partial}}" error:NULL];
//    }];
//    NSDictionary *context = @{@"helper": helper};
//    NSDictionary *partials = @{@"partial": @"&<>{{foo}}"};
//    GRMustacheTemplateRepository *repository = [GRMustacheTemplateRepository templateRepositoryWithPartialsDictionary:partials];
//    GRMustacheTemplate *template = [repository templateFromString:@"{{helper}}" error:nil];
//    NSString *result = [template renderObject:context];
//    STAssertEqualObjects(result, @"&<>", @"");
//}
//
//- (void)testTemplateDelegateCallbacksAreCalledDuringAlternateTemplateStringRendering
//{
//    id helper = [GRMustache renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheRuntime *runtime, GRMustacheTemplateRepository *templateRepository, BOOL *HTMLEscaped) {
//        return [context renderString:@"{{subject}}" error:NULL];
//    }];
//    
//    GRMustacheTestingDelegate *delegate = [[[GRMustacheTestingDelegate alloc] init] autorelease];
//    delegate.templateWillInterpretBlock = ^(GRMustacheTemplate *template, GRMustacheInvocation *invocation, GRMustacheInterpretation interpretation) {
//        invocation.returnValue = @"delegate";
//    };
//    
//    NSDictionary *context = [NSDictionary dictionaryWithObjectsAndKeys:
//                             helper, @"helper",
//                             @"---", @"subject", nil];
//    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{helper}}" error:NULL];
//    template.delegate = delegate;
//    NSString *result = [template renderObject:context];
//    STAssertEqualObjects(result, @"delegate", @"");
//}
//
- (void)testDynamicPartialHelper
{
    NSDictionary *partials = @{@"partial": @"In partial."};
    GRMustacheTemplateRepository *repository = [GRMustacheTemplateRepository templateRepositoryWithPartialsDictionary:partials];
    
    GRMustacheTemplate *template = [repository templateFromString:@"{{partial}}" error:NULL];
    id partial = [repository templateNamed:@"partial" error:NULL];
    NSDictionary *context = @{@"partial": partial};
    NSString *result = [template renderObject:context];
    
    STAssertEqualObjects(result, @"In partial.", @"");
}

- (void)testRenderingOfDynamicPartialHelperIsNotHTMLEscaped
{
    NSDictionary *partials = @{@"partial": @"&<>{{foo}}"};
    GRMustacheTemplateRepository *repository = [GRMustacheTemplateRepository templateRepositoryWithPartialsDictionary:partials];
    
    GRMustacheTemplate *template = [repository templateFromString:@"{{partial}}" error:nil];
    id partial = [repository templateNamed:@"partial" error:NULL];
    NSDictionary *context = @{@"partial": partial};
    NSString *result = [template renderObject:context];
    
    STAssertEqualObjects(result, @"&<>", @"");
}

- (void)testDynamicPartialCollectionsCanRenderItemProperties
{
    NSDictionary *partials = @{@"partial": @"<{{name}}>"};
    GRMustacheTemplateRepository *repository = [GRMustacheTemplateRepository templateRepositoryWithPartialsDictionary:partials];
    GRMustacheTemplate *template = [repository templateFromString:@"{{items}}" error:nil];
    
    id item1 = [GRMustache renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheRuntime *runtime, GRMustacheTemplateRepository *templateRepository, BOOL *HTMLEscaped) {
        GRMustacheTemplate *template = [templateRepository templateNamed:@"partial" error:NULL];
        runtime = [runtime runtimeByAddingContextObject:@{ @"name": @"item1" }];
        return [template renderForTag:tag inRuntime:runtime templateRepository:templateRepository HTMLEscaped:HTMLEscaped];
    }];
    id item2 = [GRMustache renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheRuntime *runtime, GRMustacheTemplateRepository *templateRepository, BOOL *HTMLEscaped) {
        GRMustacheTemplate *template = [templateRepository templateNamed:@"partial" error:NULL];
        runtime = [runtime runtimeByAddingContextObject:@{ @"name": @"item2" }];
        return [template renderForTag:tag inRuntime:runtime templateRepository:templateRepository HTMLEscaped:HTMLEscaped];
    }];

    NSDictionary *context = @{@"items": @[item1, item2]};
    NSString *result = [template renderObject:context];
    STAssertEqualObjects(result, @"<item1><item2>", @"");
}

//- (void)testHelperDoesEnterContextStack
//{
//    GRMustacheSelfRenderingWithTemplateStringVariableTagHelper *item = [[[GRMustacheSelfRenderingWithTemplateStringVariableTagHelper alloc] init] autorelease];
//    item.templateString = @"{{name}}";
//    item.name = @"name";
//    NSDictionary *context = @{@"item": item};
//    NSDictionary *partials = @{@"item": @"{{name}}"};
//    GRMustacheTemplateRepository *repository = [GRMustacheTemplateRepository templateRepositoryWithPartialsDictionary:partials];
//    GRMustacheTemplate *template = [repository templateFromString:@"{{item}}" error:nil];
//    NSString *result = [template renderObject:context];
//    STAssertEqualObjects(result, @"name", @"");
//}
//
//- (void)testArrayOfHelpersInSectionTag
//{
//    GRMustacheStringVariableTagHelper *helper1 = [[[GRMustacheStringVariableTagHelper alloc] init] autorelease];
//    helper1.rendering = @"1";
//    
//    GRMustacheStringVariableTagHelper *helper2 = [[[GRMustacheStringVariableTagHelper alloc] init] autorelease];
//    helper2.rendering = @"2";
//    
//    id items = @{@"items": @[helper1, helper2] };
//    NSString *rendering = [[GRMustacheTemplate templateFromString:@"{{#items}}{{.}}{{/items}}" error:NULL] renderObject:items];
//    STAssertEqualObjects(rendering, @"12", @"");
//}
//
//- (void)testArrayOfHelpersInVariableTag
//{
//    GRMustacheStringVariableTagHelper *helper1 = [[[GRMustacheStringVariableTagHelper alloc] init] autorelease];
//    helper1.rendering = @"1";
//    
//    GRMustacheStringVariableTagHelper *helper2 = [[[GRMustacheStringVariableTagHelper alloc] init] autorelease];
//    helper2.rendering = @"2";
//    
//    id items = @{@"items": @[helper1, helper2] };
//    NSString *rendering = [[GRMustacheTemplate templateFromString:@"{{items}}" error:NULL] renderObject:items];
//    STAssertEqualObjects(rendering, @"12", @"");
//}
//
//- (void)testDelegateInVariableTag
//{
//    GRMustacheVariableTagHelperDelegate *helper = [[[GRMustacheVariableTagHelperDelegate alloc] init] autorelease];
//    NSString *rendering = [[GRMustacheTemplate templateFromString:@"{{helper}}" error:NULL] renderObject:@{ @"helper": helper }];
//    STAssertEqualObjects(rendering, @"<foo>", @"");
//    STAssertEqualObjects(helper.returnValue, @"foo", @"");
//}

@end
