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

@interface GRMustacheTemplateDelegateTest : GRMustachePublicAPITest
@end

@implementation GRMustacheTemplateDelegateTest

- (void)testTemplateWillRenderIsCalledForTemplate
{
    GRMustacheTestingDelegate *delegate = [[[GRMustacheTestingDelegate alloc] init] autorelease];
    
    __block NSUInteger templateWillRenderCount = 0;
    __block GRMustacheTemplate *delegatingTemplate = nil;
    delegate.templateWillRenderBlock = ^(GRMustacheTemplate *template) {
        ++templateWillRenderCount;
        delegatingTemplate = template;
    };
    
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{foo}}" error:NULL];
    template.delegate = delegate;
    [template render];
    
    STAssertEquals(delegatingTemplate, template, @"");
    STAssertEquals(templateWillRenderCount, (NSUInteger)1, @"");
}

- (void)testTemplateDidRenderIsCalledForTemplate
{
    GRMustacheTestingDelegate *delegate = [[[GRMustacheTestingDelegate alloc] init] autorelease];
    
    __block NSUInteger templateDidRenderCount = 0;
    __block GRMustacheTemplate *delegatingTemplate = nil;
    delegate.templateDidRenderBlock = ^(GRMustacheTemplate *template) {
        ++templateDidRenderCount;
        delegatingTemplate = template;
    };
    
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{foo}}" error:NULL];
    template.delegate = delegate;
    [template render];
    
    STAssertEquals(delegatingTemplate, template, @"");
    STAssertEquals(templateDidRenderCount, (NSUInteger)1, @"");
}

- (void)testTemplateWillRenderIsNotCalledForPartial
{
    GRMustacheTestingDelegate *delegate = [[[GRMustacheTestingDelegate alloc] init] autorelease];
    
    __block NSUInteger templateWillRenderCount = 0;
    __block GRMustacheTemplate *delegatingTemplate = nil;
    delegate.templateWillRenderBlock = ^(GRMustacheTemplate *template) {
        ++templateWillRenderCount;
        delegatingTemplate = template;
    };
    
    GRMustacheTemplateRepository *repository = [GRMustacheTemplateRepository templateRepositoryWithBundle:self.testBundle];
    GRMustacheTemplate *template = [repository templateFromString:@"{{>GRMustacheTemplateDelegateTest}}" error:NULL];
    template.delegate = delegate;
    [template render];
    
    STAssertEquals(delegatingTemplate, template, @"");
    STAssertEquals(templateWillRenderCount, (NSUInteger)1, @"");
}

- (void)testTemplateDidRenderIsNotCalledForPartial
{
    GRMustacheTestingDelegate *delegate = [[[GRMustacheTestingDelegate alloc] init] autorelease];
    
    __block NSUInteger templateDidRenderCount = 0;
    __block GRMustacheTemplate *delegatingTemplate = nil;
    delegate.templateDidRenderBlock = ^(GRMustacheTemplate *template) {
        ++templateDidRenderCount;
        delegatingTemplate = template;
    };
    
    GRMustacheTemplateRepository *repository = [GRMustacheTemplateRepository templateRepositoryWithBundle:self.testBundle];
    GRMustacheTemplate *template = [repository templateFromString:@"{{>GRMustacheTemplateDelegateTest}}" error:NULL];
    template.delegate = delegate;
    [template render];
    
    STAssertEquals(delegatingTemplate, template, @"");
    STAssertEquals(templateDidRenderCount, (NSUInteger)1, @"");
}

- (void)testWillInterpretReturnValueOfInvocationIsNotTriggeredByText
{
    GRMustacheTestingDelegate *delegate = [[[GRMustacheTestingDelegate alloc] init] autorelease];
    
    __block BOOL success = YES;
    delegate.templateWillInterpretBlock = ^(GRMustacheTemplate *template, GRMustacheInvocation *invocation, GRMustacheInterpretation interpretation) {
        success = NO;
    };
    
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"---" error:NULL];
    template.delegate = delegate;
    [template render];
    
    STAssertEquals(success, YES, @"");
}

- (void)testDidInterpretReturnValueOfInvocationIsNotTriggeredByText
{
    GRMustacheTestingDelegate *delegate = [[[GRMustacheTestingDelegate alloc] init] autorelease];
    
    __block BOOL success = YES;
    delegate.templateDidInterpretBlock = ^(GRMustacheTemplate *template, GRMustacheInvocation *invocation, GRMustacheInterpretation interpretation) {
        success = NO;
    };
    
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"---" error:NULL];
    template.delegate = delegate;
    [template render];
    
    STAssertEquals(success, YES, @"");
}

- (void)testInterpretReturnValueOfInvocationWithVariable
{
    GRMustacheTestingDelegate *delegate = [[[GRMustacheTestingDelegate alloc] init] autorelease];
    
    __block GRMustacheTemplate *preRenderingTemplate = nil;
    __block GRMustacheTemplate *postRenderingTemplate = nil;
    __block GRMustacheInterpretation preRenderingInterpretation = -1;
    __block GRMustacheInterpretation postRenderingInterpretation = -1;
    __block id preRenderingValue = nil;
    __block id postRenderingValue = nil;
    delegate.templateWillInterpretBlock = ^(GRMustacheTemplate *template, GRMustacheInvocation *invocation, GRMustacheInterpretation interpretation) {
        preRenderingTemplate = template;
        preRenderingValue = invocation.returnValue;
        preRenderingInterpretation = interpretation;
        invocation.returnValue = @"delegate";
    };
    delegate.templateDidInterpretBlock = ^(GRMustacheTemplate *template, GRMustacheInvocation *invocation, GRMustacheInterpretation interpretation) {
        postRenderingTemplate = template;
        postRenderingValue = invocation.returnValue;
        postRenderingInterpretation = interpretation;
    };
    
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"---{{foo}}---" error:NULL];
    template.delegate = delegate;
    NSString *rendering = [template renderObject:@{@"foo": @"value"}];
    
    STAssertEqualObjects(rendering, @"---delegate---", @"");
    STAssertEquals(preRenderingTemplate, template, @"", @"");
    STAssertEquals(postRenderingTemplate, template, @"", @"");
    STAssertEquals(preRenderingInterpretation, GRMustacheVariableTagInterpretation, @"", @"");
    STAssertEquals(postRenderingInterpretation, GRMustacheVariableTagInterpretation, @"", @"");
    STAssertEqualObjects(preRenderingValue, @"value", @"");
    STAssertEqualObjects(postRenderingValue, @"delegate", @"");
}

- (void)testInterpretReturnValueOfInvocationWithUnrenderedSection
{
    GRMustacheTestingDelegate *delegate = [[[GRMustacheTestingDelegate alloc] init] autorelease];
    
    __block GRMustacheTemplate *preRenderingTemplate = nil;
    __block GRMustacheTemplate *postRenderingTemplate = nil;
    __block GRMustacheInterpretation preRenderingInterpretation = -1;
    __block GRMustacheInterpretation postRenderingInterpretation = -1;
    __block NSUInteger templateWillRenderCount = 0;
    __block NSUInteger templateDidRenderCount = 0;
    delegate.templateWillInterpretBlock = ^(GRMustacheTemplate *template, GRMustacheInvocation *invocation, GRMustacheInterpretation interpretation) {
        preRenderingTemplate = template;
        preRenderingInterpretation = interpretation;
        ++templateWillRenderCount;
    };
    delegate.templateDidInterpretBlock = ^(GRMustacheTemplate *template, GRMustacheInvocation *invocation, GRMustacheInterpretation interpretation) {
        postRenderingTemplate = template;
        postRenderingInterpretation = interpretation;
        ++templateDidRenderCount;
    };
    
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"<{{#foo}}{{bar}}{{/foo}}>" error:NULL];
    template.delegate = delegate;
    NSString *rendering = [template render];
    
    STAssertEqualObjects(rendering, @"<>", @"");
    STAssertEquals(templateWillRenderCount, (NSUInteger)1, @"");
    STAssertEquals(templateDidRenderCount, (NSUInteger)1, @"");
    STAssertEquals(preRenderingInterpretation, GRMustacheSectionTagInterpretation, @"", @"");
    STAssertEquals(postRenderingInterpretation, GRMustacheSectionTagInterpretation, @"", @"");
    STAssertEquals(preRenderingTemplate, template, @"", @"");
    STAssertEquals(postRenderingTemplate, template, @"", @"");
}

- (void)testInterpretReturnValueOfInvocationWithRenderedSectionContainingVariable
{
    GRMustacheTestingDelegate *delegate = [[[GRMustacheTestingDelegate alloc] init] autorelease];
    
    __block NSUInteger templateWillRenderCount = 0;
    __block NSUInteger templateDidRenderCount = 0;
    __block GRMustacheTemplate *preRenderingTemplate1 = nil;
    __block GRMustacheTemplate *postRenderingTemplate1 = nil;
    __block GRMustacheInterpretation preRenderingInterpretation1 = -1;
    __block GRMustacheInterpretation postRenderingInterpretation1 = -1;
    __block id preRenderingValue1 = nil;
    __block id postRenderingValue1 = nil;
    __block GRMustacheTemplate *preRenderingTemplate2 = nil;
    __block GRMustacheTemplate *postRenderingTemplate2 = nil;
    __block GRMustacheInterpretation preRenderingInterpretation2 = -1;
    __block GRMustacheInterpretation postRenderingInterpretation2 = -1;
    __block id preRenderingValue2 = nil;
    __block id postRenderingValue2 = nil;
    delegate.templateWillInterpretBlock = ^(GRMustacheTemplate *template, GRMustacheInvocation *invocation, GRMustacheInterpretation interpretation) {
        ++templateWillRenderCount;
        switch (templateWillRenderCount) {
            case 1:
                preRenderingTemplate1 = template;
                preRenderingValue1 = invocation.returnValue;
                preRenderingInterpretation1 = interpretation;
                invocation.returnValue = @YES;
                break;
                
            case 2:
                preRenderingTemplate2 = template;
                preRenderingValue2 = invocation.returnValue;
                preRenderingInterpretation2 = interpretation;
                invocation.returnValue = @"delegate";
                break;
        }
    };
    delegate.templateDidInterpretBlock = ^(GRMustacheTemplate *template, GRMustacheInvocation *invocation, GRMustacheInterpretation interpretation) {
        ++templateDidRenderCount;
        switch (templateDidRenderCount) {
            case 1:
                postRenderingTemplate1 = template;
                postRenderingValue1 = invocation.returnValue;
                postRenderingInterpretation1 = interpretation;
                break;
                
            case 2:
                postRenderingTemplate2 = template;
                postRenderingValue2 = invocation.returnValue;
                postRenderingInterpretation2 = interpretation;
                break;
        }
    };
    
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"<{{#foo}}{{bar}}{{/foo}}>" error:NULL];
    template.delegate = delegate;
    NSString *rendering = [template render];
    
    STAssertEqualObjects(rendering, @"<delegate>", @"");
    STAssertEquals(templateWillRenderCount, (NSUInteger)2, @"");
    STAssertEquals(templateDidRenderCount, (NSUInteger)2, @"");
    STAssertEquals(preRenderingTemplate1, template, @"", @"");
    STAssertEquals(preRenderingTemplate2, template, @"", @"");
    STAssertEquals(postRenderingTemplate1, template, @"", @"");
    STAssertEquals(postRenderingTemplate2, template, @"", @"");
    STAssertEqualObjects(preRenderingValue1, (id)nil, @"");
    STAssertEqualObjects(preRenderingValue2, (id)nil, @"");
    STAssertEqualObjects(postRenderingValue1, @"delegate", @"");
    STAssertEqualObjects(postRenderingValue2, @(YES), @"");
    STAssertEquals(preRenderingInterpretation1, GRMustacheSectionTagInterpretation, @"", @"");
    STAssertEquals(preRenderingInterpretation2, GRMustacheVariableTagInterpretation, @"", @"");
    STAssertEquals(postRenderingInterpretation1, GRMustacheVariableTagInterpretation, @"", @"");
    STAssertEquals(postRenderingInterpretation2, GRMustacheSectionTagInterpretation, @"", @"");
}

- (void)testDelegateInterpretsRenderedValue
{
    {
        GRMustacheTestingDelegate *delegate = [[[GRMustacheTestingDelegate alloc] init] autorelease];
        __block id interpretedValue = nil;
        __block NSUInteger templateWillRenderCount = 0;
        delegate.templateWillInterpretBlock = ^(GRMustacheTemplate *template, GRMustacheInvocation *invocation, GRMustacheInterpretation interpretation) {
            ++templateWillRenderCount;
            interpretedValue = invocation.returnValue;
        };
        
        GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{subject}}" error:NULL];
        template.delegate = delegate;
        NSString *rendering = [template render];
        
        STAssertEqualObjects(rendering, @"", @"");
        STAssertEquals(templateWillRenderCount, (NSUInteger)1, @"");
        STAssertEquals(interpretedValue, (id)nil, @"");
    }
    
    {
        GRMustacheTestingDelegate *delegate = [[[GRMustacheTestingDelegate alloc] init] autorelease];
        __block id interpretedValue = nil;
        __block NSUInteger templateWillRenderCount = 0;
        delegate.templateWillInterpretBlock = ^(GRMustacheTemplate *template, GRMustacheInvocation *invocation, GRMustacheInterpretation interpretation) {
            ++templateWillRenderCount;
            interpretedValue = invocation.returnValue;
        };
        
        GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{subject}}" error:NULL];
        template.delegate = delegate;
        NSString *rendering = [template renderObject:@{@"subject":@"foo"}];
        
        STAssertEqualObjects(rendering, @"foo", @"");
        STAssertEquals(templateWillRenderCount, (NSUInteger)1, @"");
        STAssertEqualObjects(interpretedValue, @"foo", @"");
    }
    
    {
        GRMustacheTestingDelegate *delegate = [[[GRMustacheTestingDelegate alloc] init] autorelease];
        __block id interpretedValue = nil;
        __block NSUInteger templateWillRenderCount = 0;
        delegate.templateWillInterpretBlock = ^(GRMustacheTemplate *template, GRMustacheInvocation *invocation, GRMustacheInterpretation interpretation) {
            ++templateWillRenderCount;
            interpretedValue = invocation.returnValue;
        };
        
        GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{subject.foo}}" error:NULL];
        template.delegate = delegate;
        NSString *rendering = [template render];
        
        STAssertEqualObjects(rendering, @"", @"");
        STAssertEquals(templateWillRenderCount, (NSUInteger)1, @"");
        STAssertEquals(interpretedValue, (id)nil, @"");
    }
    
    {
        GRMustacheTestingDelegate *delegate = [[[GRMustacheTestingDelegate alloc] init] autorelease];
        __block id interpretedValue = nil;
        __block NSUInteger templateWillRenderCount = 0;
        delegate.templateWillInterpretBlock = ^(GRMustacheTemplate *template, GRMustacheInvocation *invocation, GRMustacheInterpretation interpretation) {
            ++templateWillRenderCount;
            interpretedValue = invocation.returnValue;
        };
        
        GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{subject.foo}}" error:NULL];
        template.delegate = delegate;
        NSString *rendering = [template renderObject:@{@"subject":@"foo"}];
        
        STAssertEqualObjects(rendering, @"", @"");
        STAssertEquals(templateWillRenderCount, (NSUInteger)1, @"");
        STAssertEquals(interpretedValue, (id)nil, @"");
    }
    
    {
        GRMustacheTestingDelegate *delegate = [[[GRMustacheTestingDelegate alloc] init] autorelease];
        __block id interpretedValue = nil;
        __block NSUInteger templateWillRenderCount = 0;
        delegate.templateWillInterpretBlock = ^(GRMustacheTemplate *template, GRMustacheInvocation *invocation, GRMustacheInterpretation interpretation) {
            ++templateWillRenderCount;
            interpretedValue = invocation.returnValue;
        };
        
        GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{subject.foo}}" error:NULL];
        template.delegate = delegate;
        NSString *rendering = [template renderObject:@{@"subject":@{@"foo":@"bar"}}];
        
        STAssertEqualObjects(rendering, @"bar", @"");
        STAssertEquals(templateWillRenderCount, (NSUInteger)1, @"");
        STAssertEqualObjects(interpretedValue, @"bar", @"");
    }
    
    {
        GRMustacheTestingDelegate *delegate = [[[GRMustacheTestingDelegate alloc] init] autorelease];
        __block id interpretedValue = nil;
        __block NSUInteger templateWillRenderCount = 0;
        delegate.templateWillInterpretBlock = ^(GRMustacheTemplate *template, GRMustacheInvocation *invocation, GRMustacheInterpretation interpretation) {
            ++templateWillRenderCount;
            interpretedValue = invocation.returnValue;
        };
        
        GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{uppercase(subject)}}" error:NULL];
        template.delegate = delegate;
        NSString *rendering = [template render];
        
        STAssertEqualObjects(rendering, @"", @"");
        STAssertEquals(templateWillRenderCount, (NSUInteger)1, @"");
        STAssertEquals(interpretedValue, (id)nil, @"");
    }
    
    {
        GRMustacheTestingDelegate *delegate = [[[GRMustacheTestingDelegate alloc] init] autorelease];
        __block id interpretedValue = nil;
        __block NSUInteger templateWillRenderCount = 0;
        delegate.templateWillInterpretBlock = ^(GRMustacheTemplate *template, GRMustacheInvocation *invocation, GRMustacheInterpretation interpretation) {
            ++templateWillRenderCount;
            interpretedValue = invocation.returnValue;
        };
        
        GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{uppercase(subject)}}" error:NULL];
        template.delegate = delegate;
        NSString *rendering = [template renderObject:@{@"subject":@"foo"}];
        
        STAssertEqualObjects(rendering, @"FOO", @"");
        STAssertEquals(templateWillRenderCount, (NSUInteger)1, @"");
        STAssertEqualObjects(interpretedValue, @"FOO", @"");
    }
    
    {
        GRMustacheTestingDelegate *delegate = [[[GRMustacheTestingDelegate alloc] init] autorelease];
        __block id interpretedValue = nil;
        __block NSUInteger templateWillRenderCount = 0;
        delegate.templateWillInterpretBlock = ^(GRMustacheTemplate *template, GRMustacheInvocation *invocation, GRMustacheInterpretation interpretation) {
            ++templateWillRenderCount;
            interpretedValue = invocation.returnValue;
        };
        
        GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{uppercase(subject).length}}" error:NULL];
        template.delegate = delegate;
        NSString *rendering = [template renderObject:@{@"subject":@"foo"}];
        
        STAssertEqualObjects(rendering, @"3", @"");
        STAssertEquals(templateWillRenderCount, (NSUInteger)1, @"");
        STAssertEqualObjects(interpretedValue, @3, @"");
    }
}

- (void)testInvocationDescriptionContainsTag
{
    {
        GRMustacheTestingDelegate *delegate = [[[GRMustacheTestingDelegate alloc] init] autorelease];
        __block NSString *description = nil;
        delegate.templateWillInterpretBlock = ^(GRMustacheTemplate *template, GRMustacheInvocation *invocation, GRMustacheInterpretation interpretation) {
            description = [invocation description];
        };
        
        GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{name}}" error:NULL];
        template.delegate = delegate;
        [template render];
        
        STAssertNotNil(description, @"");
        NSRange range = [description rangeOfString:@"{{name}}"];
        STAssertTrue(range.location != NSNotFound, @"");
    }
    {
        GRMustacheTestingDelegate *delegate = [[[GRMustacheTestingDelegate alloc] init] autorelease];
        __block NSString *description = nil;
        delegate.templateWillInterpretBlock = ^(GRMustacheTemplate *template, GRMustacheInvocation *invocation, GRMustacheInterpretation interpretation) {
            description = [invocation description];
        };
        
        GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{#name}}{{/name}}" error:NULL];
        template.delegate = delegate;
        [template render];
        
        STAssertNotNil(description, @"");
        NSRange range = [description rangeOfString:@"{{#name}}"];
        STAssertTrue(range.location != NSNotFound, @"");
    }
    {
        GRMustacheTestingDelegate *delegate = [[[GRMustacheTestingDelegate alloc] init] autorelease];
        __block NSString *description = nil;
        delegate.templateWillInterpretBlock = ^(GRMustacheTemplate *template, GRMustacheInvocation *invocation, GRMustacheInterpretation interpretation) {
            description = [invocation description];
        };
        
        GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{   name\t}}" error:NULL];
        template.delegate = delegate;
        [template render];
        
        STAssertNotNil(description, @"");
        NSRange range = [description rangeOfString:@"{{   name\t}}"];
        STAssertTrue(range.location != NSNotFound, @"");
    }
}

- (void)testInvocationDescriptionContainsLineNumber
{
    {
        GRMustacheTestingDelegate *delegate = [[[GRMustacheTestingDelegate alloc] init] autorelease];
        __block NSString *description = nil;
        delegate.templateWillInterpretBlock = ^(GRMustacheTemplate *template, GRMustacheInvocation *invocation, GRMustacheInterpretation interpretation) {
            description = [invocation description];
        };
        
        GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{name}}" error:NULL];
        template.delegate = delegate;
        [template render];
        
        STAssertNotNil(description, @"");
        NSRange range = [description rangeOfString:@"line 1"];
        STAssertTrue(range.location != NSNotFound, @"");
    }
    {
        GRMustacheTestingDelegate *delegate = [[[GRMustacheTestingDelegate alloc] init] autorelease];
        __block NSString *description = nil;
        delegate.templateWillInterpretBlock = ^(GRMustacheTemplate *template, GRMustacheInvocation *invocation, GRMustacheInterpretation interpretation) {
            description = [invocation description];
        };
        
        GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"\n {{name}}" error:NULL];
        template.delegate = delegate;
        [template render];
        
        STAssertNotNil(description, @"");
        NSRange range = [description rangeOfString:@"line 2"];
        STAssertTrue(range.location != NSNotFound, @"");
    }
    {
        GRMustacheTestingDelegate *delegate = [[[GRMustacheTestingDelegate alloc] init] autorelease];
        __block NSString *description = nil;
        delegate.templateWillInterpretBlock = ^(GRMustacheTemplate *template, GRMustacheInvocation *invocation, GRMustacheInterpretation interpretation) {
            description = [invocation description];
        };
        
        GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"\n\n  {{#name}}\n\n{{/name}}" error:NULL];
        template.delegate = delegate;
        [template render];
        
        STAssertNotNil(description, @"");
        NSRange range = [description rangeOfString:@"line 3"];
        STAssertTrue(range.location != NSNotFound, @"");
    }
}

- (void)testInvocationDescriptionContainsResourceBasedTemplatePath
{
    {
        GRMustacheTestingDelegate *delegate = [[[GRMustacheTestingDelegate alloc] init] autorelease];
        __block NSString *description = nil;
        delegate.templateWillInterpretBlock = ^(GRMustacheTemplate *template, GRMustacheInvocation *invocation, GRMustacheInterpretation interpretation) {
            description = [invocation description];
        };
        
        GRMustacheTemplate *template = [GRMustacheTemplate templateFromResource:@"GRMustacheTemplateDelegateTest" bundle:self.testBundle error:NULL];
        template.delegate = delegate;
        [template render];
        
        STAssertNotNil(description, @"");
        NSRange range = [description rangeOfString:[self.testBundle pathForResource:@"GRMustacheTemplateDelegateTest" ofType:@"mustache"]];
        STAssertTrue(range.location != NSNotFound, @"");
    }
    {
        GRMustacheTestingDelegate *delegate = [[[GRMustacheTestingDelegate alloc] init] autorelease];
        __block NSString *description = nil;
        delegate.templateWillInterpretBlock = ^(GRMustacheTemplate *template, GRMustacheInvocation *invocation, GRMustacheInterpretation interpretation) {
            description = [invocation description];
        };
        
        GRMustacheTemplateRepository *repository = [GRMustacheTemplateRepository templateRepositoryWithBundle:self.testBundle];
        GRMustacheTemplate *template = [repository templateNamed:@"GRMustacheTemplateDelegateTest" error:NULL];
        template.delegate = delegate;
        [template render];
        
        STAssertNotNil(description, @"");
        NSRange range = [description rangeOfString:[self.testBundle pathForResource:@"GRMustacheTemplateDelegateTest" ofType:@"mustache"]];
        STAssertTrue(range.location != NSNotFound, @"");
    }
}

- (void)testInvocationDescriptionContainsURLBasedTemplatePath
{
    {
        GRMustacheTestingDelegate *delegate = [[[GRMustacheTestingDelegate alloc] init] autorelease];
        __block NSString *description = nil;
        delegate.templateWillInterpretBlock = ^(GRMustacheTemplate *template, GRMustacheInvocation *invocation, GRMustacheInterpretation interpretation) {
            description = [invocation description];
        };
        
        GRMustacheTemplate *template = [GRMustacheTemplate templateFromContentsOfURL:[self.testBundle URLForResource:@"GRMustacheTemplateDelegateTest" withExtension:@"mustache"] error:NULL];
        template.delegate = delegate;
        [template render];
        
        STAssertNotNil(description, @"");
        NSRange range = [description rangeOfString:[self.testBundle pathForResource:@"GRMustacheTemplateDelegateTest" ofType:@"mustache"]];
        STAssertTrue(range.location != NSNotFound, @"");
    }
    {
        GRMustacheTestingDelegate *delegate = [[[GRMustacheTestingDelegate alloc] init] autorelease];
        __block NSString *description = nil;
        delegate.templateWillInterpretBlock = ^(GRMustacheTemplate *template, GRMustacheInvocation *invocation, GRMustacheInterpretation interpretation) {
            description = [invocation description];
        };
        
        GRMustacheTemplateRepository *repository = [GRMustacheTemplateRepository templateRepositoryWithBaseURL:[self.testBundle resourceURL]];
        GRMustacheTemplate *template = [repository templateNamed:@"GRMustacheTemplateDelegateTest" error:NULL];
        template.delegate = delegate;
        [template render];
        
        STAssertNotNil(description, @"");
        NSRange range = [description rangeOfString:[self.testBundle pathForResource:@"GRMustacheTemplateDelegateTest" ofType:@"mustache"]];
        STAssertTrue(range.location != NSNotFound, @"");
    }
}

- (void)testInvocationDescriptionContainsPathBasedTemplatePath
{
    {
        GRMustacheTestingDelegate *delegate = [[[GRMustacheTestingDelegate alloc] init] autorelease];
        __block NSString *description = nil;
        delegate.templateWillInterpretBlock = ^(GRMustacheTemplate *template, GRMustacheInvocation *invocation, GRMustacheInterpretation interpretation) {
            description = [invocation description];
        };
        
        GRMustacheTemplate *template = [GRMustacheTemplate templateFromContentsOfFile:[self.testBundle pathForResource:@"GRMustacheTemplateDelegateTest" ofType:@"mustache"] error:NULL];
        template.delegate = delegate;
        [template render];
        
        STAssertNotNil(description, @"");
        NSRange range = [description rangeOfString:[self.testBundle pathForResource:@"GRMustacheTemplateDelegateTest" ofType:@"mustache"]];
        STAssertTrue(range.location != NSNotFound, @"");
    }
    {
        GRMustacheTestingDelegate *delegate = [[[GRMustacheTestingDelegate alloc] init] autorelease];
        __block NSString *description = nil;
        delegate.templateWillInterpretBlock = ^(GRMustacheTemplate *template, GRMustacheInvocation *invocation, GRMustacheInterpretation interpretation) {
            description = [invocation description];
        };
        
        GRMustacheTemplateRepository *repository = [GRMustacheTemplateRepository templateRepositoryWithDirectory:[self.testBundle resourcePath]];
        GRMustacheTemplate *template = [repository templateNamed:@"GRMustacheTemplateDelegateTest" error:NULL];
        template.delegate = delegate;
        [template render];
        
        STAssertNotNil(description, @"");
        NSRange range = [description rangeOfString:[self.testBundle pathForResource:@"GRMustacheTemplateDelegateTest" ofType:@"mustache"]];
        STAssertTrue(range.location != NSNotFound, @"");
    }
}

- (void)testInvocationDescriptionContainsResourceBasedPartialPath
{
    {
        GRMustacheTestingDelegate *delegate = [[[GRMustacheTestingDelegate alloc] init] autorelease];
        __block NSString *description = nil;
        delegate.templateWillInterpretBlock = ^(GRMustacheTemplate *template, GRMustacheInvocation *invocation, GRMustacheInterpretation interpretation) {
            description = [invocation description];
        };
        
        GRMustacheTemplate *template = [GRMustacheTemplate templateFromResource:@"GRMustacheTemplateDelegateTest_wrapper" bundle:self.testBundle error:NULL];
        template.delegate = delegate;
        [template render];
        
        STAssertNotNil(description, @"");
        NSRange range = [description rangeOfString:[self.testBundle pathForResource:@"GRMustacheTemplateDelegateTest" ofType:@"mustache"]];
        STAssertTrue(range.location != NSNotFound, @"");
    }
    {
        GRMustacheTestingDelegate *delegate = [[[GRMustacheTestingDelegate alloc] init] autorelease];
        __block NSString *description = nil;
        delegate.templateWillInterpretBlock = ^(GRMustacheTemplate *template, GRMustacheInvocation *invocation, GRMustacheInterpretation interpretation) {
            description = [invocation description];
        };
        
        GRMustacheTemplateRepository *repository = [GRMustacheTemplateRepository templateRepositoryWithBundle:self.testBundle];
        GRMustacheTemplate *template = [repository templateNamed:@"GRMustacheTemplateDelegateTest_wrapper" error:NULL];
        template.delegate = delegate;
        [template render];
        
        STAssertNotNil(description, @"");
        NSRange range = [description rangeOfString:[self.testBundle pathForResource:@"GRMustacheTemplateDelegateTest" ofType:@"mustache"]];
        STAssertTrue(range.location != NSNotFound, @"");
    }
    {
        GRMustacheTestingDelegate *delegate = [[[GRMustacheTestingDelegate alloc] init] autorelease];
        __block NSString *description = nil;
        delegate.templateWillInterpretBlock = ^(GRMustacheTemplate *template, GRMustacheInvocation *invocation, GRMustacheInterpretation interpretation) {
            description = [invocation description];
        };
        
        GRMustacheTemplateRepository *repository = [GRMustacheTemplateRepository templateRepositoryWithBundle:self.testBundle];
        GRMustacheTemplate *template = [repository templateFromString:@"{{>GRMustacheTemplateDelegateTest}}" error:NULL];
        template.delegate = delegate;
        [template render];
        
        STAssertNotNil(description, @"");
        NSRange range = [description rangeOfString:[self.testBundle pathForResource:@"GRMustacheTemplateDelegateTest" ofType:@"mustache"]];
        STAssertTrue(range.location != NSNotFound, @"");
    }
}

- (void)testInvocationDescriptionContainsURLBasedPartialPath
{
    {
        GRMustacheTestingDelegate *delegate = [[[GRMustacheTestingDelegate alloc] init] autorelease];
        __block NSString *description = nil;
        delegate.templateWillInterpretBlock = ^(GRMustacheTemplate *template, GRMustacheInvocation *invocation, GRMustacheInterpretation interpretation) {
            description = [invocation description];
        };
        
        GRMustacheTemplate *template = [GRMustacheTemplate templateFromContentsOfURL:[self.testBundle URLForResource:@"GRMustacheTemplateDelegateTest_wrapper" withExtension:@"mustache"] error:NULL];
        template.delegate = delegate;
        [template render];
        
        STAssertNotNil(description, @"");
        NSRange range = [description rangeOfString:[self.testBundle pathForResource:@"GRMustacheTemplateDelegateTest" ofType:@"mustache"]];
        STAssertTrue(range.location != NSNotFound, @"");
    }
    {
        GRMustacheTestingDelegate *delegate = [[[GRMustacheTestingDelegate alloc] init] autorelease];
        __block NSString *description = nil;
        delegate.templateWillInterpretBlock = ^(GRMustacheTemplate *template, GRMustacheInvocation *invocation, GRMustacheInterpretation interpretation) {
            description = [invocation description];
        };
        
        GRMustacheTemplateRepository *repository = [GRMustacheTemplateRepository templateRepositoryWithBaseURL:[self.testBundle resourceURL]];
        GRMustacheTemplate *template = [repository templateNamed:@"GRMustacheTemplateDelegateTest_wrapper" error:NULL];
        template.delegate = delegate;
        [template render];
        
        STAssertNotNil(description, @"");
        NSRange range = [description rangeOfString:[self.testBundle pathForResource:@"GRMustacheTemplateDelegateTest" ofType:@"mustache"]];
        STAssertTrue(range.location != NSNotFound, @"");
    }
    {
        GRMustacheTestingDelegate *delegate = [[[GRMustacheTestingDelegate alloc] init] autorelease];
        __block NSString *description = nil;
        delegate.templateWillInterpretBlock = ^(GRMustacheTemplate *template, GRMustacheInvocation *invocation, GRMustacheInterpretation interpretation) {
            description = [invocation description];
        };
        
        GRMustacheTemplateRepository *repository = [GRMustacheTemplateRepository templateRepositoryWithBaseURL:[self.testBundle resourceURL]];
        GRMustacheTemplate *template = [repository templateFromString:@"{{>GRMustacheTemplateDelegateTest}}" error:NULL];
        template.delegate = delegate;
        [template render];
        
        STAssertNotNil(description, @"");
        NSRange range = [description rangeOfString:[self.testBundle pathForResource:@"GRMustacheTemplateDelegateTest" ofType:@"mustache"]];
        STAssertTrue(range.location != NSNotFound, @"");
    }
}

- (void)testInvocationDescriptionContainsPathBasedPartialPath
{
    {
        GRMustacheTestingDelegate *delegate = [[[GRMustacheTestingDelegate alloc] init] autorelease];
        __block NSString *description = nil;
        delegate.templateWillInterpretBlock = ^(GRMustacheTemplate *template, GRMustacheInvocation *invocation, GRMustacheInterpretation interpretation) {
            description = [invocation description];
        };
        
        GRMustacheTemplate *template = [GRMustacheTemplate templateFromContentsOfFile:[self.testBundle pathForResource:@"GRMustacheTemplateDelegateTest_wrapper" ofType:@"mustache"] error:NULL];
        template.delegate = delegate;
        [template render];
        
        STAssertNotNil(description, @"");
        NSRange range = [description rangeOfString:[self.testBundle pathForResource:@"GRMustacheTemplateDelegateTest" ofType:@"mustache"]];
        STAssertTrue(range.location != NSNotFound, @"");
    }
    {
        GRMustacheTestingDelegate *delegate = [[[GRMustacheTestingDelegate alloc] init] autorelease];
        __block NSString *description = nil;
        delegate.templateWillInterpretBlock = ^(GRMustacheTemplate *template, GRMustacheInvocation *invocation, GRMustacheInterpretation interpretation) {
            description = [invocation description];
        };
        
        GRMustacheTemplateRepository *repository = [GRMustacheTemplateRepository templateRepositoryWithDirectory:[self.testBundle resourcePath]];
        GRMustacheTemplate *template = [repository templateNamed:@"GRMustacheTemplateDelegateTest_wrapper" error:NULL];
        template.delegate = delegate;
        [template render];
        
        STAssertNotNil(description, @"");
        NSRange range = [description rangeOfString:[self.testBundle pathForResource:@"GRMustacheTemplateDelegateTest" ofType:@"mustache"]];
        STAssertTrue(range.location != NSNotFound, @"");
    }
    {
        GRMustacheTestingDelegate *delegate = [[[GRMustacheTestingDelegate alloc] init] autorelease];
        __block NSString *description = nil;
        delegate.templateWillInterpretBlock = ^(GRMustacheTemplate *template, GRMustacheInvocation *invocation, GRMustacheInterpretation interpretation) {
            description = [invocation description];
        };
        
        GRMustacheTemplateRepository *repository = [GRMustacheTemplateRepository templateRepositoryWithDirectory:[self.testBundle resourcePath]];
        GRMustacheTemplate *template = [repository templateFromString:@"{{>GRMustacheTemplateDelegateTest}}" error:NULL];
        template.delegate = delegate;
        [template render];
        
        STAssertNotNil(description, @"");
        NSRange range = [description rangeOfString:[self.testBundle pathForResource:@"GRMustacheTemplateDelegateTest" ofType:@"mustache"]];
        STAssertTrue(range.location != NSNotFound, @"");
    }
}

- (void)testSectionDelegate
{
    GRMustacheTestingDelegate *delegate = [[[GRMustacheTestingDelegate alloc] init] autorelease];
    __block NSUInteger templateWillRenderCount = 0;
    __block NSUInteger templateDidRenderCount = 0;
    __block GRMustacheTemplate *preRenderingTemplate = nil;
    __block GRMustacheTemplate *postRenderingTemplate = nil;
    __block GRMustacheInterpretation preRenderingInterpretation = -1;
    __block GRMustacheInterpretation postRenderingInterpretation = -1;
    __block id preRenderingValue = nil;
    __block id postRenderingValue = nil;
    delegate.templateWillRenderBlock = ^(GRMustacheTemplate *template) {
        ++templateWillRenderCount;
    };
    delegate.templateDidRenderBlock = ^(GRMustacheTemplate *template) {
        ++templateDidRenderCount;
    };
    delegate.templateWillInterpretBlock = ^(GRMustacheTemplate *template, GRMustacheInvocation *invocation, GRMustacheInterpretation interpretation) {
        preRenderingTemplate = template;
        preRenderingValue = invocation.returnValue;
        preRenderingInterpretation = interpretation;
        invocation.returnValue = @"delegate";
    };
    delegate.templateDidInterpretBlock = ^(GRMustacheTemplate *template, GRMustacheInvocation *invocation, GRMustacheInterpretation interpretation) {
        postRenderingTemplate = template;
        postRenderingValue = invocation.returnValue;
        postRenderingInterpretation = interpretation;
    };
    
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{#delegate}}{{value}}{{/delegate}}" error:NULL];
    NSString *rendering = [template renderObject:@{@"delegate":delegate, @"value":@"foo"}];
    
    STAssertEqualObjects(rendering, @"delegate", @"");
    STAssertEquals(templateWillRenderCount, (NSUInteger)0, @"");
    STAssertEquals(templateDidRenderCount, (NSUInteger)0, @"");
    STAssertEquals(preRenderingTemplate, template, @"");
    STAssertEquals(postRenderingTemplate, template, @"");
    STAssertEquals(preRenderingInterpretation, GRMustacheVariableTagInterpretation, @"");
    STAssertEquals(postRenderingInterpretation, GRMustacheVariableTagInterpretation, @"");
    STAssertEqualObjects(preRenderingValue, @"foo", @"");
    STAssertEqualObjects(postRenderingValue, @"delegate", @"");
}

- (void)testSectionsDelegateOrdering
{
    GRMustacheTestingDelegate *uppercaseDelegate = [[[GRMustacheTestingDelegate alloc] init] autorelease];
    uppercaseDelegate.templateWillInterpretBlock = ^(GRMustacheTemplate *template, GRMustacheInvocation *invocation, GRMustacheInterpretation interpretation) {
        if ([invocation.returnValue isKindOfClass:[NSString class]]) {
            invocation.returnValue = [[invocation.returnValue description] uppercaseString];
        }
    };
    
    GRMustacheTestingDelegate *prefixDelegate = [[[GRMustacheTestingDelegate alloc] init] autorelease];
    prefixDelegate.templateWillInterpretBlock = ^(GRMustacheTemplate *template, GRMustacheInvocation *invocation, GRMustacheInterpretation interpretation) {
        if ([invocation.returnValue isKindOfClass:[NSString class]]) {
            invocation.returnValue = [NSString stringWithFormat:@"prefix%@", invocation.returnValue];
        }
    };
    
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{#prefix}}{{value}} {{#uppercase}}{{value}}{{/uppercase}}{{/prefix}} {{#uppercase}}{{value}} {{#prefix}}{{value}}{{/prefix}}{{/uppercase}}" error:NULL];
    NSString *rendering = [template renderObject:@{@"prefix":prefixDelegate, @"uppercase":uppercaseDelegate, @"value":@"foo"}];
    
    STAssertEqualObjects(rendering, @"prefixfoo prefixFOO FOO PREFIXFOO", @"");
}

- (void)testTemplateDelegatePlusSectionDelegate
{
    GRMustacheTestingDelegate *uppercaseDelegate = [[[GRMustacheTestingDelegate alloc] init] autorelease];
    uppercaseDelegate.templateWillInterpretBlock = ^(GRMustacheTemplate *template, GRMustacheInvocation *invocation, GRMustacheInterpretation interpretation) {
        if ([invocation.returnValue isKindOfClass:[NSString class]]) {
            invocation.returnValue = [[invocation.returnValue description] uppercaseString];
        }
    };
    
    GRMustacheTestingDelegate *prefixDelegate = [[[GRMustacheTestingDelegate alloc] init] autorelease];
    prefixDelegate.templateWillInterpretBlock = ^(GRMustacheTemplate *template, GRMustacheInvocation *invocation, GRMustacheInterpretation interpretation) {
        if ([invocation.returnValue isKindOfClass:[NSString class]]) {
            invocation.returnValue = [NSString stringWithFormat:@"prefix%@", invocation.returnValue];
        }
    };
    
    GRMustacheTestingDelegate *suffixDelegate = [[[GRMustacheTestingDelegate alloc] init] autorelease];
    suffixDelegate.templateWillInterpretBlock = ^(GRMustacheTemplate *template, GRMustacheInvocation *invocation, GRMustacheInterpretation interpretation) {
        if ([invocation.returnValue isKindOfClass:[NSString class]]) {
            invocation.returnValue = [NSString stringWithFormat:@"%@suffix", invocation.returnValue];
        }
    };
    
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{#prefix}}{{value}}{{/prefix}} {{#suffix}}{{value}}{{/suffix}} {{value}}" error:NULL];
    template.delegate = uppercaseDelegate;
    NSString *rendering = [template renderObject:@{@"prefix":prefixDelegate, @"suffix":suffixDelegate, @"value":@"foo"}];
    
    STAssertEqualObjects(rendering, @"PREFIXFOO FOOSUFFIX FOO", @"");
}

- (void)testTemplateDelegatePlusNestedSectionsDelegate
{
    GRMustacheTestingDelegate *uppercaseDelegate = [[[GRMustacheTestingDelegate alloc] init] autorelease];
    uppercaseDelegate.templateWillInterpretBlock = ^(GRMustacheTemplate *template, GRMustacheInvocation *invocation, GRMustacheInterpretation interpretation) {
        if ([invocation.returnValue isKindOfClass:[NSString class]]) {
            invocation.returnValue = [[invocation.returnValue description] uppercaseString];
        }
    };
    
    GRMustacheTestingDelegate *prefixDelegate = [[[GRMustacheTestingDelegate alloc] init] autorelease];
    prefixDelegate.templateWillInterpretBlock = ^(GRMustacheTemplate *template, GRMustacheInvocation *invocation, GRMustacheInterpretation interpretation) {
        if ([invocation.returnValue isKindOfClass:[NSString class]]) {
            invocation.returnValue = [NSString stringWithFormat:@"prefix%@", invocation.returnValue];
        }
    };
    
    GRMustacheTestingDelegate *suffixDelegate = [[[GRMustacheTestingDelegate alloc] init] autorelease];
    suffixDelegate.templateWillInterpretBlock = ^(GRMustacheTemplate *template, GRMustacheInvocation *invocation, GRMustacheInterpretation interpretation) {
        if ([invocation.returnValue isKindOfClass:[NSString class]]) {
            invocation.returnValue = [NSString stringWithFormat:@"%@suffix", invocation.returnValue];
        }
    };
    
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{#prefix}}{{value}} {{#uppercase}}{{value}}{{/uppercase}}{{/prefix}} {{#uppercase}}{{value}} {{#prefix}}{{value}}{{/prefix}}{{/uppercase}}" error:NULL];
    template.delegate = suffixDelegate;
    NSString *rendering = [template renderObject:@{@"uppercase":uppercaseDelegate, @"prefix":prefixDelegate, @"value":@"foo"}];
    
    STAssertEqualObjects(rendering, @"prefixfoosuffix prefixFOOsuffix FOOsuffix PREFIXFOOsuffix", @"");
}

- (void)testArrayOfDelegatesInSectionTag
{
    __block BOOL delegate1HasBeenInvoked = NO;
    GRMustacheTestingDelegate *delegate1 = [[[GRMustacheTestingDelegate alloc] init] autorelease];
    delegate1.templateWillInterpretBlock = ^(GRMustacheTemplate *template, GRMustacheInvocation *invocation, GRMustacheInterpretation interpretation) { delegate1HasBeenInvoked = YES; };
    
    __block BOOL delegate2HasBeenInvoked = NO;
    GRMustacheTestingDelegate *delegate2 = [[[GRMustacheTestingDelegate alloc] init] autorelease];
    delegate2.templateWillInterpretBlock = ^(GRMustacheTemplate *template, GRMustacheInvocation *invocation, GRMustacheInterpretation interpretation) { delegate2HasBeenInvoked = YES; };
    
    id items = @{@"items": @[delegate1, delegate2] };
    [GRMustacheTemplate renderObject:items fromString:@"{{#items}}{{.}}{{/items}}" error:NULL];
    
    STAssertTrue(delegate1HasBeenInvoked, @"");
    STAssertTrue(delegate2HasBeenInvoked, @"");
}

- (void)testArrayOfDelegatesInVariableTag
{
    __block BOOL delegate1HasBeenInvoked = NO;
    GRMustacheTestingDelegate *delegate1 = [[[GRMustacheTestingDelegate alloc] init] autorelease];
    delegate1.templateWillInterpretBlock = ^(GRMustacheTemplate *template, GRMustacheInvocation *invocation, GRMustacheInterpretation interpretation) { delegate1HasBeenInvoked = YES; };
    
    __block BOOL delegate2HasBeenInvoked = NO;
    GRMustacheTestingDelegate *delegate2 = [[[GRMustacheTestingDelegate alloc] init] autorelease];
    delegate2.templateWillInterpretBlock = ^(GRMustacheTemplate *template, GRMustacheInvocation *invocation, GRMustacheInterpretation interpretation) { delegate2HasBeenInvoked = YES; };
    
    id items = @{@"items": @[delegate1, delegate2] };
    [GRMustacheTemplate renderObject:items fromString:@"{{items}}" error:NULL];
    
    STAssertTrue(delegate1HasBeenInvoked, @"");
    STAssertTrue(delegate2HasBeenInvoked, @"");
}

@end
