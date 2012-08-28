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

#define GRMUSTACHE_VERSION_MAX_ALLOWED GRMUSTACHE_VERSION_4_1
#import "GRMustachePublicAPITest.h"

/*
@interface GRMustacheTemplateDelegate_v4_1_Test : GRMustachePublicAPITest
@end

@interface GRMustacheTemplateRecorder_v4_1 : NSObject<GRMustacheTemplateDelegate> {
    NSUInteger _willRenderReturnValueOfInvocationCount;
    NSUInteger _didRenderReturnValueOfInvocationCount;
    NSUInteger _willInterpretReturnValueOfInvocationAsCount;
    NSUInteger _didInterpretReturnValueOfInvocationAsCount;
    GRMustacheInterpretation _lastInterpretation;
}
@property (nonatomic) NSUInteger willRenderReturnValueOfInvocationCount;
@property (nonatomic) NSUInteger didRenderReturnValueOfInvocationCount;
@property (nonatomic) NSUInteger willInterpretReturnValueOfInvocationAsCount;
@property (nonatomic) NSUInteger didInterpretReturnValueOfInvocationAsCount;
@property (nonatomic) GRMustacheInterpretation lastInterpretation;
@end

@implementation GRMustacheTemplateRecorder_v4_1
@synthesize willRenderReturnValueOfInvocationCount=_willRenderReturnValueOfInvocationCount;
@synthesize didRenderReturnValueOfInvocationCount=_didRenderReturnValueOfInvocationCount;
@synthesize willInterpretReturnValueOfInvocationAsCount=_willInterpretReturnValueOfInvocationAsCount;
@synthesize didInterpretReturnValueOfInvocationAsCount=_didInterpretReturnValueOfInvocationAsCount;
@synthesize lastInterpretation=_lastInterpretation;

- (void)template:(GRMustacheTemplate *)template willRenderReturnValueOfInvocation:(GRMustacheInvocation *)invocation
{
    self.willRenderReturnValueOfInvocationCount += 1;
}

- (void)template:(GRMustacheTemplate *)template didRenderReturnValueOfInvocation:(GRMustacheInvocation *)invocation
{
    self.didRenderReturnValueOfInvocationCount += 1;
}

- (void)template:(GRMustacheTemplate *)template willInterpretReturnValueOfInvocation:(GRMustacheInvocation *)invocation as:(GRMustacheInterpretation)interpretation
{
    self.willInterpretReturnValueOfInvocationAsCount += 1;
    self.lastInterpretation = interpretation;
}

- (void)template:(GRMustacheTemplate *)template didInterpretReturnValueOfInvocation:(GRMustacheInvocation *)invocation as:(GRMustacheInterpretation)interpretation
{
    self.didInterpretReturnValueOfInvocationAsCount += 1;
}

@end

@implementation GRMustacheTemplateDelegate_v4_1_Test

- (void)testWillRenderReturnValueOfInvocationWithText
{
    GRMustacheTemplateRecorder_v4_1 *recorder = [[[GRMustacheTemplateRecorder_v4_1 alloc] init] autorelease];
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"---" error:NULL];
    template.delegate = recorder;
    [template render];
    STAssertEquals(recorder.willRenderReturnValueOfInvocationCount, (NSUInteger)0, @"");
}

- (void)testWillInterpretReturnValueOfInvocationAsWithText
{
    GRMustacheTemplateRecorder_v4_1 *recorder = [[[GRMustacheTemplateRecorder_v4_1 alloc] init] autorelease];
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"---" error:NULL];
    template.delegate = recorder;
    [template render];
    STAssertEquals(recorder.willInterpretReturnValueOfInvocationAsCount, (NSUInteger)0, @"");
}

- (void)testDidRenderReturnValueOfInvocationWithText
{
    GRMustacheTemplateRecorder_v4_1 *recorder = [[[GRMustacheTemplateRecorder_v4_1 alloc] init] autorelease];
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"---" error:NULL];
    template.delegate = recorder;
    [template render];
    STAssertEquals(recorder.didRenderReturnValueOfInvocationCount, (NSUInteger)0, @"");
}

- (void)testDidInterpretReturnValueOfInvocationAsWithText
{
    GRMustacheTemplateRecorder_v4_1 *recorder = [[[GRMustacheTemplateRecorder_v4_1 alloc] init] autorelease];
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"---" error:NULL];
    template.delegate = recorder;
    [template render];
    STAssertEquals(recorder.didInterpretReturnValueOfInvocationAsCount, (NSUInteger)0, @"");
}

- (void)testWillRenderReturnValueOfInvocationWithVariable
{
    GRMustacheTemplateRecorder_v4_1 *recorder = [[[GRMustacheTemplateRecorder_v4_1 alloc] init] autorelease];
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{foo}}{{bar}}" error:NULL];
    template.delegate = recorder;
    [template render];
    STAssertEquals(recorder.willRenderReturnValueOfInvocationCount, (NSUInteger)0, @"");
}

- (void)testWillInterpretReturnValueOfInvocationAsWithVariable
{
    GRMustacheTemplateRecorder_v4_1 *recorder = [[[GRMustacheTemplateRecorder_v4_1 alloc] init] autorelease];
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{foo}}{{bar}}" error:NULL];
    template.delegate = recorder;
    [template render];
    STAssertEquals(recorder.willInterpretReturnValueOfInvocationAsCount, (NSUInteger)2, @"");
    STAssertEquals(recorder.lastInterpretation, GRMustacheInterpretationVariable, @"");
}

- (void)testDidRenderReturnValueOfInvocationWithVariable
{
    GRMustacheTemplateRecorder_v4_1 *recorder = [[[GRMustacheTemplateRecorder_v4_1 alloc] init] autorelease];
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{foo}}{{bar}}" error:NULL];
    template.delegate = recorder;
    [template render];
    STAssertEquals(recorder.didRenderReturnValueOfInvocationCount, (NSUInteger)0, @"");
}

- (void)testDidInterpretReturnValueOfInvocationAsWithVariable
{
    GRMustacheTemplateRecorder_v4_1 *recorder = [[[GRMustacheTemplateRecorder_v4_1 alloc] init] autorelease];
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{foo}}{{bar}}" error:NULL];
    template.delegate = recorder;
    [template render];
    STAssertEquals(recorder.didInterpretReturnValueOfInvocationAsCount, (NSUInteger)2, @"");
}

- (void)testWillRenderReturnValueOfInvocationWithUnrenderedSection
{
    GRMustacheTemplateRecorder_v4_1 *recorder = [[[GRMustacheTemplateRecorder_v4_1 alloc] init] autorelease];
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{#foo}}{{bar}}{{/foo}}" error:NULL];
    template.delegate = recorder;
    [template render];
    STAssertEquals(recorder.willRenderReturnValueOfInvocationCount, (NSUInteger)0, @"");
}

- (void)testWillInterpretReturnValueOfInvocationAsWithUnrenderedSection
{
    GRMustacheTemplateRecorder_v4_1 *recorder = [[[GRMustacheTemplateRecorder_v4_1 alloc] init] autorelease];
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{#foo}}{{bar}}{{/foo}}" error:NULL];
    template.delegate = recorder;
    [template render];
    STAssertEquals(recorder.willInterpretReturnValueOfInvocationAsCount, (NSUInteger)1, @"");
    STAssertEquals(recorder.lastInterpretation, GRMustacheInterpretationSection, @"");
}

- (void)testDidRenderReturnValueOfInvocationWithUnrenderedSection
{
    GRMustacheTemplateRecorder_v4_1 *recorder = [[[GRMustacheTemplateRecorder_v4_1 alloc] init] autorelease];
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{#foo}}{{bar}}{{/foo}}" error:NULL];
    template.delegate = recorder;
    [template render];
    STAssertEquals(recorder.didRenderReturnValueOfInvocationCount, (NSUInteger)0, @"");
}

- (void)testDidInterpretReturnValueOfInvocationAsWithUnrenderedSection
{
    GRMustacheTemplateRecorder_v4_1 *recorder = [[[GRMustacheTemplateRecorder_v4_1 alloc] init] autorelease];
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{#foo}}{{bar}}{{/foo}}" error:NULL];
    template.delegate = recorder;
    [template render];
    STAssertEquals(recorder.didInterpretReturnValueOfInvocationAsCount, (NSUInteger)1, @"");
}

- (void)testWillRenderReturnValueOfInvocationWithRenderedSectionAndVariable
{
    GRMustacheTemplateRecorder_v4_1 *recorder = [[[GRMustacheTemplateRecorder_v4_1 alloc] init] autorelease];
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{^foo}}{{bar}}{{/foo}}" error:NULL];
    template.delegate = recorder;
    [template render];
    STAssertEquals(recorder.willRenderReturnValueOfInvocationCount, (NSUInteger)0, @"");
}

- (void)testWillInterpretReturnValueOfInvocationAsWithRenderedSectionAndVariable
{
    GRMustacheTemplateRecorder_v4_1 *recorder = [[[GRMustacheTemplateRecorder_v4_1 alloc] init] autorelease];
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{^foo}}{{bar}}{{/foo}}" error:NULL];
    template.delegate = recorder;
    [template render];
    STAssertEquals(recorder.willInterpretReturnValueOfInvocationAsCount, (NSUInteger)2, @"");
    STAssertEquals(recorder.lastInterpretation, GRMustacheInterpretationVariable, @"");
}

- (void)testDidRenderReturnValueOfInvocationWithRenderedSectionAndVariable
{
    GRMustacheTemplateRecorder_v4_1 *recorder = [[[GRMustacheTemplateRecorder_v4_1 alloc] init] autorelease];
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{^foo}}{{bar}}{{/foo}}" error:NULL];
    template.delegate = recorder;
    [template render];
    STAssertEquals(recorder.didRenderReturnValueOfInvocationCount, (NSUInteger)0, @"");
}

- (void)testDidInterpretReturnValueOfInvocationAsWithRenderedSectionAndVariable
{
    GRMustacheTemplateRecorder_v4_1 *recorder = [[[GRMustacheTemplateRecorder_v4_1 alloc] init] autorelease];
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{^foo}}{{bar}}{{/foo}}" error:NULL];
    template.delegate = recorder;
    [template render];
    STAssertEquals(recorder.didInterpretReturnValueOfInvocationAsCount, (NSUInteger)2, @"");
}

@end
*/
