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

#import "GRMustacheHelperTest.h"

@interface GRMustacheStringHelper : NSObject<GRMustacheHelper>
@property (nonatomic, copy) NSString *string;
@end

@implementation GRMustacheStringHelper
@synthesize string=_string;
- (NSString *)renderSection:(GRMustacheSection *)section withContext:(id)context
{
    return self.string;
}
@end

@interface GRMustacheRecorderHelper : NSObject<GRMustacheHelper>
@property (nonatomic) NSUInteger invocationCount;
@property (nonatomic, retain) NSString *lastInnerTemplateString;
@property (nonatomic, retain) NSString *lastRenderedContent;
@end

@implementation GRMustacheRecorderHelper
@synthesize invocationCount=_invocationCount;
@synthesize lastInnerTemplateString=_lastInnerTemplateString;
@synthesize lastRenderedContent=_lastRenderedContent;
- (NSString *)renderSection:(GRMustacheSection *)section withContext:(id)context
{
    self.invocationCount += 1;
    self.lastInnerTemplateString = section.innerTemplateString;
    self.lastRenderedContent = [section renderObject:context];
    return self.lastRenderedContent;
}
@end

@interface GRMustacheTemplateHelper : NSObject<GRMustacheHelper>
@property (nonatomic, copy) NSString *templateString;
@end

@implementation GRMustacheTemplateHelper
@synthesize templateString=_templateString;
- (NSString *)renderSection:(GRMustacheSection *)section withContext:(id)context
{
    return [GRMustacheTemplate renderObject:context fromString:self.templateString error:NULL];
}
@end

@implementation GRMustacheHelperTest

- (void)testHelperPerformsRendering
{
    {
        // GRMustacheHelper protocol
        GRMustacheStringHelper *helper = [[[GRMustacheStringHelper alloc] init] autorelease];
        helper.string = @"---";
        NSDictionary *context = [NSDictionary dictionaryWithObject:helper forKey:@"helper"];
        NSString *result = [GRMustacheTemplate renderObject:context fromString:@"{{#helper}}{{/helper}}" error:nil];
        STAssertEqualObjects(result, @"---", @"");
    }
    {
        // [GRMustacheHelper helperWithBlock:]
        id helper = [GRMustacheHelper helperWithBlock:^NSString *(GRMustacheSection *section, id context) {
            return @"---";
        }];
        NSDictionary *context = [NSDictionary dictionaryWithObject:helper forKey:@"helper"];
        NSString *result = [GRMustacheTemplate renderObject:context fromString:@"{{#helper}}{{/helper}}" error:nil];
        STAssertEqualObjects(result, @"---", @"");
    }
}

- (void)testHelperRenderingIsNotProcessed
{
    // This test is against Mustache spec lambda definition, which render a template string that should be processed.
    {
        // GRMustacheHelper protocol
        GRMustacheStringHelper *helper = [[[GRMustacheStringHelper alloc] init] autorelease];
        helper.string = @"&<>{{foo}}";
        NSDictionary *context = [NSDictionary dictionaryWithObject:helper forKey:@"helper"];
        NSString *result = [GRMustacheTemplate renderObject:context fromString:@"{{#helper}}{{/helper}}" error:nil];
        STAssertEqualObjects(result, @"&<>{{foo}}", @"");
    }
    {
        // [GRMustacheHelper helperWithBlock:]
        id helper = [GRMustacheHelper helperWithBlock:^NSString *(GRMustacheSection *section, id context) {
            return @"&<>{{foo}}";
        }];
        NSDictionary *context = [NSDictionary dictionaryWithObject:helper forKey:@"helper"];
        NSString *result = [GRMustacheTemplate renderObject:context fromString:@"{{#helper}}{{/helper}}" error:nil];
        STAssertEqualObjects(result, @"&<>{{foo}}", @"");
    }
}

- (void)testHelperCanRenderNil
{
    {
        // GRMustacheHelper protocol
        GRMustacheStringHelper *helper = [[[GRMustacheStringHelper alloc] init] autorelease];
        helper.string = nil;
        NSDictionary *context = [NSDictionary dictionaryWithObject:helper forKey:@"helper"];
        NSString *result = [GRMustacheTemplate renderObject:context fromString:@"{{#helper}}{{/helper}}" error:nil];
        STAssertEqualObjects(result, @"", @"");
    }
    {
        // [GRMustacheHelper helperWithBlock:]
        id helper = [GRMustacheHelper helperWithBlock:^NSString *(GRMustacheSection *section, id context) {
            return nil;
        }];
        NSDictionary *context = [NSDictionary dictionaryWithObject:helper forKey:@"helper"];
        NSString *result = [GRMustacheTemplate renderObject:context fromString:@"{{#helper}}{{/helper}}" error:nil];
        STAssertEqualObjects(result, @"", @"");
    }
}

- (void)testHelperCanAccessInnerTemplateString
{
    {
        // GRMustacheHelper protocol
        GRMustacheRecorderHelper *helper = [[[GRMustacheRecorderHelper alloc] init] autorelease];
        NSDictionary *context = [NSDictionary dictionaryWithObject:helper forKey:@"helper"];
        [GRMustacheTemplate renderObject:context fromString:@"{{#helper}}{{subject}}{{/helper}}" error:nil];
        STAssertEqualObjects(helper.lastInnerTemplateString, @"{{subject}}", @"");
    }
    {
        // [GRMustacheHelper helperWithBlock:]
        __block NSString *lastInnerTemplateString = nil;
        id helper = [GRMustacheHelper helperWithBlock:^NSString *(GRMustacheSection *section, id context) {
            [lastInnerTemplateString release];
            lastInnerTemplateString = [section.innerTemplateString retain];
            return nil;
        }];
        NSDictionary *context = [NSDictionary dictionaryWithObject:helper forKey:@"helper"];
        [GRMustacheTemplate renderObject:context fromString:@"{{#helper}}{{subject}}{{/helper}}" error:nil];
        STAssertEqualObjects(lastInnerTemplateString, @"{{subject}}", @"");
        [lastInnerTemplateString release];
    }
}

- (void)testHelperCanAccessRenderedContent
{
    {
        // GRMustacheHelper protocol
        GRMustacheRecorderHelper *helper = [[[GRMustacheRecorderHelper alloc] init] autorelease];
        NSDictionary *context = [NSDictionary dictionaryWithObjectsAndKeys:
                                 helper, @"helper",
                                 @"---", @"subject", nil];
        [GRMustacheTemplate renderObject:context fromString:@"{{#helper}}{{subject}}==={{subject}}{{/helper}}" error:nil];
        STAssertEqualObjects(helper.lastRenderedContent, @"---===---", @"");
    }
    {
        // [GRMustacheHelper helperWithBlock:]
        __block NSString *lastRenderedContent = nil;
        id helper = [GRMustacheHelper helperWithBlock:^NSString *(GRMustacheSection *section, id context) {
            [lastRenderedContent release];
            lastRenderedContent = [[section renderObject:context] retain];
            return nil;
        }];
        NSDictionary *context = [NSDictionary dictionaryWithObjectsAndKeys:
                                 helper, @"helper",
                                 @"---", @"subject", nil];
        [GRMustacheTemplate renderObject:context fromString:@"{{#helper}}{{subject}}==={{subject}}{{/helper}}" error:nil];
        STAssertEqualObjects(lastRenderedContent, @"---===---", @"");
        [lastRenderedContent release];
    }
}

- (void)testHelperCanRenderCurrentContextInDistinctTemplate
{
    // This test is against Mustache spec lambda definition, which do not have access to the current rendering context.
    {
        // GRMustacheHelper protocol
        GRMustacheTemplateHelper *helper = [[[GRMustacheTemplateHelper alloc] init] autorelease];
        helper.templateString = @"{{subject}}";
        NSDictionary *context = [NSDictionary dictionaryWithObjectsAndKeys:
                                 helper, @"helper",
                                 @"---", @"subject", nil];
        NSString *result = [GRMustacheTemplate renderObject:context fromString:@"{{#helper}}{{/helper}}" error:nil];
        STAssertEqualObjects(result, @"---", @"");
    }
    {
        // [GRMustacheHelper helperWithBlock:]
        id helper = [GRMustacheHelper helperWithBlock:^NSString *(GRMustacheSection *section, id context) {
            return [GRMustacheTemplate renderObject:context fromString:@"{{subject}}" error:NULL];
        }];
        NSDictionary *context = [NSDictionary dictionaryWithObjectsAndKeys:
                                 helper, @"helper",
                                 @"---", @"subject", nil];
        NSString *result = [GRMustacheTemplate renderObject:context fromString:@"{{#helper}}{{/helper}}" error:nil];
        STAssertEqualObjects(result, @"---", @"");
    }
}

- (void)testHelperIsNotCalledWhenItDoesntNeedTo
{
    {
        // GRMustacheHelper protocol
        {
            GRMustacheRecorderHelper *helper = [[[GRMustacheRecorderHelper alloc] init] autorelease];
            NSDictionary *context = [NSDictionary dictionaryWithObject:helper forKey:@"helper"];
            [GRMustacheTemplate renderObject:context fromString:@"{{helper}}" error:nil];
            STAssertEquals(helper.invocationCount, (NSUInteger)0, @"");
        }
        {
            GRMustacheRecorderHelper *helper = [[[GRMustacheRecorderHelper alloc] init] autorelease];
            NSDictionary *context = [NSDictionary dictionaryWithObject:helper forKey:@"helper"];
            [GRMustacheTemplate renderObject:context fromString:@"{{#helper}}{{/helper}}" error:nil];
            STAssertEquals(helper.invocationCount, (NSUInteger)1, @"");
        }
        {
            GRMustacheRecorderHelper *helper = [[[GRMustacheRecorderHelper alloc] init] autorelease];
            NSDictionary *context = [NSDictionary dictionaryWithObject:helper forKey:@"helper"];
            [GRMustacheTemplate renderObject:context fromString:@"{{^helper}}{{/helper}}" error:nil];
            STAssertEquals(helper.invocationCount, (NSUInteger)0, @"");
        }
        {
            GRMustacheRecorderHelper *helper = [[[GRMustacheRecorderHelper alloc] init] autorelease];
            NSDictionary *context = [NSDictionary dictionaryWithObject:helper forKey:@"helper"];
            [GRMustacheTemplate renderObject:context fromString:@"{{#false}}{{#helper}}{{/helper}}{{/false}}" error:nil];
            STAssertEquals(helper.invocationCount, (NSUInteger)0, @"");
        }
    }
    {
        // [GRMustacheHelper helperWithBlock:]
        {
            __block NSUInteger invocationCount = 0;
            id helper = [GRMustacheHelper helperWithBlock:^NSString *(GRMustacheSection *section, id context) {
                invocationCount++;
                return nil;
            }];
            NSDictionary *context = [NSDictionary dictionaryWithObject:helper forKey:@"helper"];
            [GRMustacheTemplate renderObject:context fromString:@"{{helper}}" error:nil];
            STAssertEquals(invocationCount, (NSUInteger)0, @"");
        }
        {
            __block NSUInteger invocationCount = 0;
            id helper = [GRMustacheHelper helperWithBlock:^NSString *(GRMustacheSection *section, id context) {
                invocationCount++;
                return nil;
            }];
            NSDictionary *context = [NSDictionary dictionaryWithObject:helper forKey:@"helper"];
            [GRMustacheTemplate renderObject:context fromString:@"{{#helper}}{{/helper}}" error:nil];
            STAssertEquals(invocationCount, (NSUInteger)1, @"");
        }
        {
            __block NSUInteger invocationCount = 0;
            id helper = [GRMustacheHelper helperWithBlock:^NSString *(GRMustacheSection *section, id context) {
                invocationCount++;
                return nil;
            }];
            NSDictionary *context = [NSDictionary dictionaryWithObject:helper forKey:@"helper"];
            [GRMustacheTemplate renderObject:context fromString:@"{{^helper}}{{/helper}}" error:nil];
            STAssertEquals(invocationCount, (NSUInteger)0, @"");
        }
        {
            __block NSUInteger invocationCount = 0;
            id helper = [GRMustacheHelper helperWithBlock:^NSString *(GRMustacheSection *section, id context) {
                invocationCount++;
                return nil;
            }];
            NSDictionary *context = [NSDictionary dictionaryWithObject:helper forKey:@"helper"];
            [GRMustacheTemplate renderObject:context fromString:@"{{#false}}{{#helper}}{{/helper}}{{/false}}" error:nil];
            STAssertEquals(invocationCount, (NSUInteger)0, @"");
        }
    }
}

@end
