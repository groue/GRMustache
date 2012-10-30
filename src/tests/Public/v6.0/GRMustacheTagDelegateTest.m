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

@interface GRMustacheTagDelegateTest : GRMustachePublicAPITest
@end

@implementation GRMustacheTagDelegateTest

- (void)testMustacheTagWillRenderIsNotTriggeredByText
{
    GRMustacheTestingDelegate *delegate = [[[GRMustacheTestingDelegate alloc] init] autorelease];
    
    __block BOOL success = YES;
    delegate.mustacheTagWillRenderBlock = ^id(GRMustacheTag *tag, id object) {
        success = NO;
        return object;
    };
    
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"---" error:NULL];
    template.tagDelegate = delegate;
    [template renderObject:nil error:NULL];
    
    STAssertEquals(success, YES, @"");
}

- (void)testMustacheTagDidRenderIsNotTriggeredByText
{
    GRMustacheTestingDelegate *delegate = [[[GRMustacheTestingDelegate alloc] init] autorelease];
    
    __block BOOL success = YES;
    delegate.mustacheTagDidRenderBlock = ^(GRMustacheTag *tag, id object, NSString *rendering) {
        success = NO;
    };
    
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"---" error:NULL];
    template.tagDelegate = delegate;
    [template renderObject:nil error:NULL];
    
    STAssertEquals(success, YES, @"");
}

- (void)testVariableTagDelegate
{
    GRMustacheTestingDelegate *delegate = [[[GRMustacheTestingDelegate alloc] init] autorelease];
    
    __block GRMustacheTagType preRenderingTagType = -1;
    __block GRMustacheTagType postRenderingTagType = -1;
    __block id preRenderedObjet = nil;
    __block id postRenderedObjet = nil;
    delegate.mustacheTagWillRenderBlock = ^id(GRMustacheTag *tag, id object) {
        preRenderedObjet = object;
        preRenderingTagType = tag.type;
        return @"delegate";
    };
    delegate.mustacheTagDidRenderBlock = ^(GRMustacheTag *tag, id object, NSString *rendering) {
        postRenderedObjet = object;
        postRenderingTagType = tag.type;
    };
    
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"---{{foo}}---" error:NULL];
    template.tagDelegate = delegate;
    NSString *rendering = [template renderObject:@{@"foo": @"value"} error:NULL];
    
    STAssertEqualObjects(rendering, @"---delegate---", @"");
    STAssertEquals(preRenderingTagType, GRMustacheTagTypeVariable, @"", @"");
    STAssertEquals(postRenderingTagType, GRMustacheTagTypeVariable, @"", @"");
    STAssertEqualObjects(preRenderedObjet, @"value", @"");
    STAssertEqualObjects(postRenderedObjet, @"delegate", @"");
}

- (void)testSectionTagDelegate
{
    GRMustacheTestingDelegate *delegate = [[[GRMustacheTestingDelegate alloc] init] autorelease];
    
    __block GRMustacheTagType preRenderingTagType = -1;
    __block GRMustacheTagType postRenderingTagType = -1;
    delegate.mustacheTagWillRenderBlock = ^id(GRMustacheTag *tag, id object) {
        preRenderingTagType = tag.type;
        return object;
    };
    delegate.mustacheTagDidRenderBlock = ^(GRMustacheTag *tag, id object, NSString *rendering) {
        postRenderingTagType = tag.type;
    };
    
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"<{{#foo}}{{bar}}{{/foo}}>" error:NULL];
    template.tagDelegate = delegate;
    NSString *rendering = [template renderObject:nil error:NULL];
    
    STAssertEqualObjects(rendering, @"<>", @"");
    STAssertEquals(preRenderingTagType, GRMustacheTagTypeSection, @"", @"");
    STAssertEquals(postRenderingTagType, GRMustacheTagTypeSection, @"", @"");
}

- (void)testMultipleTagsDelegate
{
    GRMustacheTestingDelegate *delegate = [[[GRMustacheTestingDelegate alloc] init] autorelease];
    
    __block NSUInteger templateWillInterpretCount = 0;
    __block NSUInteger templateDidInterpretCount = 0;
    __block GRMustacheTagType preRenderingTagType1 = -1;
    __block GRMustacheTagType postRenderingTagType1 = -1;
    __block id preRenderedObjet1 = nil;
    __block id postRenderedObjet1 = nil;
    __block GRMustacheTagType preRenderingTagType2 = -1;
    __block GRMustacheTagType postRenderingTagType2 = -1;
    __block id preRenderedObjet2 = nil;
    __block id postRenderedObjet2 = nil;
    delegate.mustacheTagWillRenderBlock = ^id(GRMustacheTag *tag, id object) {
        ++templateWillInterpretCount;
        switch (templateWillInterpretCount) {
            case 1:
                preRenderedObjet1 = object;
                preRenderingTagType1 = tag.type;
                return @YES;
                
            case 2:
                preRenderedObjet2 = object;
                preRenderingTagType2 = tag.type;
                return @"delegate";
        }
        return object;
    };
    delegate.mustacheTagDidRenderBlock = ^(GRMustacheTag *tag, id object, NSString *rendering) {
        ++templateDidInterpretCount;
        switch (templateDidInterpretCount) {
            case 1:
                postRenderedObjet1 = object;
                postRenderingTagType1 = tag.type;
                break;
                
            case 2:
                postRenderedObjet2 = object;
                postRenderingTagType2 = tag.type;
                break;
        }
    };
    
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"<{{#foo}}{{bar}}{{/foo}}>" error:NULL];
    template.tagDelegate = delegate;
    NSString *rendering = [template renderObject:nil error:NULL];
    
    STAssertEqualObjects(rendering, @"<delegate>", @"");
    STAssertEquals(templateWillInterpretCount, (NSUInteger)2, @"");
    STAssertEquals(templateDidInterpretCount, (NSUInteger)2, @"");
    STAssertEqualObjects(preRenderedObjet1, (id)nil, @"");
    STAssertEqualObjects(preRenderedObjet2, (id)nil, @"");
    STAssertEqualObjects(postRenderedObjet1, @"delegate", @"");
    STAssertEqualObjects(postRenderedObjet2, @(YES), @"");
    STAssertEquals(preRenderingTagType1, GRMustacheTagTypeSection, @"", @"");
    STAssertEquals(preRenderingTagType2, GRMustacheTagTypeVariable, @"", @"");
    STAssertEquals(postRenderingTagType1, GRMustacheTagTypeVariable, @"", @"");
    STAssertEquals(postRenderingTagType2, GRMustacheTagTypeSection, @"", @"");
}

- (void)testDelegateInterpretsRenderedValue
{
    {
        GRMustacheTestingDelegate *delegate = [[[GRMustacheTestingDelegate alloc] init] autorelease];
        __block id renderedObject = nil;
        __block NSUInteger templateWillInterpretCount = 0;
        delegate.mustacheTagWillRenderBlock = ^id(GRMustacheTag *tag, id object) {
            ++templateWillInterpretCount;
            renderedObject = object;
            return object;
        };
        
        GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{subject}}" error:NULL];
        template.tagDelegate = delegate;
        NSString *rendering = [template renderObject:nil error:NULL];
        
        STAssertEqualObjects(rendering, @"", @"");
        STAssertEquals(templateWillInterpretCount, (NSUInteger)1, @"");
        STAssertEquals(renderedObject, (id)nil, @"");
    }
    
    {
        GRMustacheTestingDelegate *delegate = [[[GRMustacheTestingDelegate alloc] init] autorelease];
        __block id renderedObject = nil;
        __block NSUInteger templateWillInterpretCount = 0;
        delegate.mustacheTagWillRenderBlock = ^id(GRMustacheTag *tag, id object) {
            ++templateWillInterpretCount;
            renderedObject = object;
            return object;
        };
        
        GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{subject}}" error:NULL];
        template.tagDelegate = delegate;
        NSString *rendering = [template renderObject:@{@"subject":@"foo"} error:NULL];
        
        STAssertEqualObjects(rendering, @"foo", @"");
        STAssertEquals(templateWillInterpretCount, (NSUInteger)1, @"");
        STAssertEqualObjects(renderedObject, @"foo", @"");
    }
    
    {
        GRMustacheTestingDelegate *delegate = [[[GRMustacheTestingDelegate alloc] init] autorelease];
        __block id renderedObject = nil;
        __block NSUInteger templateWillInterpretCount = 0;
        delegate.mustacheTagWillRenderBlock = ^id(GRMustacheTag *tag, id object) {
            ++templateWillInterpretCount;
            renderedObject = object;
            return object;
        };
        
        GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{subject.foo}}" error:NULL];
        template.tagDelegate = delegate;
        NSString *rendering = [template renderObject:nil error:NULL];
        
        STAssertEqualObjects(rendering, @"", @"");
        STAssertEquals(templateWillInterpretCount, (NSUInteger)1, @"");
        STAssertEquals(renderedObject, (id)nil, @"");
    }
    
    {
        GRMustacheTestingDelegate *delegate = [[[GRMustacheTestingDelegate alloc] init] autorelease];
        __block id renderedObject = nil;
        __block NSUInteger templateWillInterpretCount = 0;
        delegate.mustacheTagWillRenderBlock = ^id(GRMustacheTag *tag, id object) {
            ++templateWillInterpretCount;
            renderedObject = object;
            return object;
        };
        
        GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{subject.foo}}" error:NULL];
        template.tagDelegate = delegate;
        NSString *rendering = [template renderObject:@{@"subject":@"foo"} error:NULL];
        
        STAssertEqualObjects(rendering, @"", @"");
        STAssertEquals(templateWillInterpretCount, (NSUInteger)1, @"");
        STAssertEquals(renderedObject, (id)nil, @"");
    }
    
    {
        GRMustacheTestingDelegate *delegate = [[[GRMustacheTestingDelegate alloc] init] autorelease];
        __block id renderedObject = nil;
        __block NSUInteger templateWillInterpretCount = 0;
        delegate.mustacheTagWillRenderBlock = ^id(GRMustacheTag *tag, id object) {
            ++templateWillInterpretCount;
            renderedObject = object;
            return object;
        };
        
        GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{subject.foo}}" error:NULL];
        template.tagDelegate = delegate;
        NSString *rendering = [template renderObject:@{@"subject":@{@"foo":@"bar"}} error:NULL];
        
        STAssertEqualObjects(rendering, @"bar", @"");
        STAssertEquals(templateWillInterpretCount, (NSUInteger)1, @"");
        STAssertEqualObjects(renderedObject, @"bar", @"");
    }
    
    {
        GRMustacheTestingDelegate *delegate = [[[GRMustacheTestingDelegate alloc] init] autorelease];
        __block id renderedObject = nil;
        __block NSUInteger templateWillInterpretCount = 0;
        delegate.mustacheTagWillRenderBlock = ^id(GRMustacheTag *tag, id object) {
            ++templateWillInterpretCount;
            renderedObject = object;
            return object;
        };
        
        GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{uppercase(subject)}}" error:NULL];
        template.tagDelegate = delegate;
        NSString *rendering = [template renderObject:nil error:NULL];
        
        STAssertEqualObjects(rendering, @"", @"");
        STAssertEquals(templateWillInterpretCount, (NSUInteger)1, @"");
        STAssertEquals(renderedObject, (id)nil, @"");
    }
    
    {
        GRMustacheTestingDelegate *delegate = [[[GRMustacheTestingDelegate alloc] init] autorelease];
        __block id renderedObject = nil;
        __block NSUInteger templateWillInterpretCount = 0;
        delegate.mustacheTagWillRenderBlock = ^id(GRMustacheTag *tag, id object) {
            ++templateWillInterpretCount;
            [renderedObject release];
            renderedObject = [object retain];
            return object;
        };
        
        GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{uppercase(subject)}}" error:NULL];
        template.tagDelegate = delegate;
        NSString *rendering = [template renderObject:@{@"subject":@"foo"} error:NULL];
        
        STAssertEqualObjects(rendering, @"FOO", @"");
        STAssertEquals(templateWillInterpretCount, (NSUInteger)1, @"");
        STAssertEqualObjects(renderedObject, @"FOO", @"");
    }
    
    {
        GRMustacheTestingDelegate *delegate = [[[GRMustacheTestingDelegate alloc] init] autorelease];
        __block id renderedObject = nil;
        __block NSUInteger templateWillInterpretCount = 0;
        delegate.mustacheTagWillRenderBlock = ^id(GRMustacheTag *tag, id object) {
            ++templateWillInterpretCount;
            renderedObject = object;
            return object;
        };
        
        GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{uppercase(subject).length}}" error:NULL];
        template.tagDelegate = delegate;
        NSString *rendering = [template renderObject:@{@"subject":@"foo"} error:NULL];
        
        STAssertEqualObjects(rendering, @"3", @"");
        STAssertEquals(templateWillInterpretCount, (NSUInteger)1, @"");
        STAssertEqualObjects(renderedObject, @3, @"");
    }
}

- (void)testTagDescriptionContainsTag
{
    {
        GRMustacheTestingDelegate *delegate = [[[GRMustacheTestingDelegate alloc] init] autorelease];
        __block NSString *description = nil;
        delegate.mustacheTagWillRenderBlock = ^id(GRMustacheTag *tag, id object) {
            [description release];
            description = [[tag description] retain];
            return object;
        };
        
        GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{name}}" error:NULL];
        template.tagDelegate = delegate;
        [template renderObject:nil error:NULL];
        
        STAssertNotNil(description, @"");
        NSRange range = [description rangeOfString:@"{{name}}"];
        STAssertTrue(range.location != NSNotFound, @"");
    }
    {
        GRMustacheTestingDelegate *delegate = [[[GRMustacheTestingDelegate alloc] init] autorelease];
        __block NSString *description = nil;
        delegate.mustacheTagWillRenderBlock = ^id(GRMustacheTag *tag, id object) {
            [description release];
            description = [[tag description] retain];
            return object;
        };
        
        GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{#name}}{{/name}}" error:NULL];
        template.tagDelegate = delegate;
        [template renderObject:nil error:NULL];
        
        STAssertNotNil(description, @"");
        NSRange range = [description rangeOfString:@"{{#name}}"];
        STAssertTrue(range.location != NSNotFound, @"");
    }
    {
        GRMustacheTestingDelegate *delegate = [[[GRMustacheTestingDelegate alloc] init] autorelease];
        __block NSString *description = nil;
        delegate.mustacheTagWillRenderBlock = ^id(GRMustacheTag *tag, id object) {
            [description release];
            description = [[tag description] retain];
            return object;
        };
        
        GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{   name\t}}" error:NULL];
        template.tagDelegate = delegate;
        [template renderObject:nil error:NULL];
        
        STAssertNotNil(description, @"");
        NSRange range = [description rangeOfString:@"{{   name\t}}"];
        STAssertTrue(range.location != NSNotFound, @"");
    }
}

- (void)testTagDescriptionContainsLineNumber
{
    {
        GRMustacheTestingDelegate *delegate = [[[GRMustacheTestingDelegate alloc] init] autorelease];
        __block NSString *description = nil;
        delegate.mustacheTagWillRenderBlock = ^id(GRMustacheTag *tag, id object) {
            [description release];
            description = [[tag description] retain];
            return object;
        };
        
        GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{name}}" error:NULL];
        template.tagDelegate = delegate;
        [template renderObject:nil error:NULL];
        
        STAssertNotNil(description, @"");
        NSRange range = [description rangeOfString:@"line 1"];
        STAssertTrue(range.location != NSNotFound, @"");
    }
    {
        GRMustacheTestingDelegate *delegate = [[[GRMustacheTestingDelegate alloc] init] autorelease];
        __block NSString *description = nil;
        delegate.mustacheTagWillRenderBlock = ^id(GRMustacheTag *tag, id object) {
            [description release];
            description = [[tag description] retain];
            return object;
        };
        
        GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"\n {{name}}" error:NULL];
        template.tagDelegate = delegate;
        [template renderObject:nil error:NULL];
        
        STAssertNotNil(description, @"");
        NSRange range = [description rangeOfString:@"line 2"];
        STAssertTrue(range.location != NSNotFound, @"");
    }
    {
        GRMustacheTestingDelegate *delegate = [[[GRMustacheTestingDelegate alloc] init] autorelease];
        __block NSString *description = nil;
        delegate.mustacheTagWillRenderBlock = ^id(GRMustacheTag *tag, id object) {
            [description release];
            description = [[tag description] retain];
            return object;
        };
        
        GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"\n\n  {{#name}}\n\n{{/name}}" error:NULL];
        template.tagDelegate = delegate;
        [template renderObject:nil error:NULL];
        
        STAssertNotNil(description, @"");
        NSRange range = [description rangeOfString:@"line 3"];
        STAssertTrue(range.location != NSNotFound, @"");
    }
}

- (void)testTagDescriptionContainsResourceBasedTemplatePath
{
    {
        GRMustacheTestingDelegate *delegate = [[[GRMustacheTestingDelegate alloc] init] autorelease];
        __block NSString *description = nil;
        delegate.mustacheTagWillRenderBlock = ^id(GRMustacheTag *tag, id object) {
            [description release];
            description = [[tag description] retain];
            return object;
        };
        
        GRMustacheTemplate *template = [GRMustacheTemplate templateFromResource:@"GRMustacheTagDelegateTest" bundle:self.testBundle error:NULL];
        template.tagDelegate = delegate;
        [template renderObject:nil error:NULL];
        
        STAssertNotNil(description, @"");
        NSRange range = [description rangeOfString:[self.testBundle pathForResource:@"GRMustacheTagDelegateTest" ofType:@"mustache"]];
        STAssertTrue(range.location != NSNotFound, @"");
    }
    {
        GRMustacheTestingDelegate *delegate = [[[GRMustacheTestingDelegate alloc] init] autorelease];
        __block NSString *description = nil;
        delegate.mustacheTagWillRenderBlock = ^id(GRMustacheTag *tag, id object) {
            [description release];
            description = [[tag description] retain];
            return object;
        };
        
        GRMustacheTemplateRepository *repository = [GRMustacheTemplateRepository templateRepositoryWithBundle:self.testBundle];
        GRMustacheTemplate *template = [repository templateNamed:@"GRMustacheTagDelegateTest" error:NULL];
        template.tagDelegate = delegate;
        [template renderObject:nil error:NULL];
        
        STAssertNotNil(description, @"");
        NSRange range = [description rangeOfString:[self.testBundle pathForResource:@"GRMustacheTagDelegateTest" ofType:@"mustache"]];
        STAssertTrue(range.location != NSNotFound, @"");
    }
}

- (void)testTagDescriptionContainsURLBasedTemplatePath
{
    {
        GRMustacheTestingDelegate *delegate = [[[GRMustacheTestingDelegate alloc] init] autorelease];
        __block NSString *description = nil;
        delegate.mustacheTagWillRenderBlock = ^id(GRMustacheTag *tag, id object) {
            [description release];
            description = [[tag description] retain];
            return object;
        };
        
        GRMustacheTemplate *template = [GRMustacheTemplate templateFromContentsOfURL:[self.testBundle URLForResource:@"GRMustacheTagDelegateTest" withExtension:@"mustache"] error:NULL];
        template.tagDelegate = delegate;
        [template renderObject:nil error:NULL];
        
        STAssertNotNil(description, @"");
        NSRange range = [description rangeOfString:[self.testBundle pathForResource:@"GRMustacheTagDelegateTest" ofType:@"mustache"]];
        STAssertTrue(range.location != NSNotFound, @"");
    }
    {
        GRMustacheTestingDelegate *delegate = [[[GRMustacheTestingDelegate alloc] init] autorelease];
        __block NSString *description = nil;
        delegate.mustacheTagWillRenderBlock = ^id(GRMustacheTag *tag, id object) {
            [description release];
            description = [[tag description] retain];
            return object;
        };
        
        GRMustacheTemplateRepository *repository = [GRMustacheTemplateRepository templateRepositoryWithBaseURL:[self.testBundle resourceURL]];
        GRMustacheTemplate *template = [repository templateNamed:@"GRMustacheTagDelegateTest" error:NULL];
        template.tagDelegate = delegate;
        [template renderObject:nil error:NULL];
        
        STAssertNotNil(description, @"");
        NSRange range = [description rangeOfString:[self.testBundle pathForResource:@"GRMustacheTagDelegateTest" ofType:@"mustache"]];
        STAssertTrue(range.location != NSNotFound, @"");
    }
}

- (void)testTagDescriptionContainsPathBasedTemplatePath
{
    {
        GRMustacheTestingDelegate *delegate = [[[GRMustacheTestingDelegate alloc] init] autorelease];
        __block NSString *description = nil;
        delegate.mustacheTagWillRenderBlock = ^id(GRMustacheTag *tag, id object) {
            [description release];
            description = [[tag description] retain];
            return object;
        };
        
        GRMustacheTemplate *template = [GRMustacheTemplate templateFromContentsOfFile:[self.testBundle pathForResource:@"GRMustacheTagDelegateTest" ofType:@"mustache"] error:NULL];
        template.tagDelegate = delegate;
        [template renderObject:nil error:NULL];
        
        STAssertNotNil(description, @"");
        NSRange range = [description rangeOfString:[self.testBundle pathForResource:@"GRMustacheTagDelegateTest" ofType:@"mustache"]];
        STAssertTrue(range.location != NSNotFound, @"");
    }
    {
        GRMustacheTestingDelegate *delegate = [[[GRMustacheTestingDelegate alloc] init] autorelease];
        __block NSString *description = nil;
        delegate.mustacheTagWillRenderBlock = ^id(GRMustacheTag *tag, id object) {
            [description release];
            description = [[tag description] retain];
            return object;
        };
        
        GRMustacheTemplateRepository *repository = [GRMustacheTemplateRepository templateRepositoryWithDirectory:[self.testBundle resourcePath]];
        GRMustacheTemplate *template = [repository templateNamed:@"GRMustacheTagDelegateTest" error:NULL];
        template.tagDelegate = delegate;
        [template renderObject:nil error:NULL];
        
        STAssertNotNil(description, @"");
        NSRange range = [description rangeOfString:[self.testBundle pathForResource:@"GRMustacheTagDelegateTest" ofType:@"mustache"]];
        STAssertTrue(range.location != NSNotFound, @"");
    }
}

- (void)testTagDescriptionContainsResourceBasedPartialPath
{
    {
        GRMustacheTestingDelegate *delegate = [[[GRMustacheTestingDelegate alloc] init] autorelease];
        __block NSString *description = nil;
        delegate.mustacheTagWillRenderBlock = ^id(GRMustacheTag *tag, id object) {
            [description release];
            description = [[tag description] retain];
            return object;
        };
        
        GRMustacheTemplate *template = [GRMustacheTemplate templateFromResource:@"GRMustacheTagDelegateTest_wrapper" bundle:self.testBundle error:NULL];
        template.tagDelegate = delegate;
        [template renderObject:nil error:NULL];
        
        STAssertNotNil(description, @"");
        NSRange range = [description rangeOfString:[self.testBundle pathForResource:@"GRMustacheTagDelegateTest" ofType:@"mustache"]];
        STAssertTrue(range.location != NSNotFound, @"");
    }
    {
        GRMustacheTestingDelegate *delegate = [[[GRMustacheTestingDelegate alloc] init] autorelease];
        __block NSString *description = nil;
        delegate.mustacheTagWillRenderBlock = ^id(GRMustacheTag *tag, id object) {
            [description release];
            description = [[tag description] retain];
            return object;
        };
        
        GRMustacheTemplateRepository *repository = [GRMustacheTemplateRepository templateRepositoryWithBundle:self.testBundle];
        GRMustacheTemplate *template = [repository templateNamed:@"GRMustacheTagDelegateTest_wrapper" error:NULL];
        template.tagDelegate = delegate;
        [template renderObject:nil error:NULL];
        
        STAssertNotNil(description, @"");
        NSRange range = [description rangeOfString:[self.testBundle pathForResource:@"GRMustacheTagDelegateTest" ofType:@"mustache"]];
        STAssertTrue(range.location != NSNotFound, @"");
    }
    {
        GRMustacheTestingDelegate *delegate = [[[GRMustacheTestingDelegate alloc] init] autorelease];
        __block NSString *description = nil;
        delegate.mustacheTagWillRenderBlock = ^id(GRMustacheTag *tag, id object) {
            [description release];
            description = [[tag description] retain];
            return object;
        };
        
        GRMustacheTemplateRepository *repository = [GRMustacheTemplateRepository templateRepositoryWithBundle:self.testBundle];
        GRMustacheTemplate *template = [repository templateFromString:@"{{>GRMustacheTagDelegateTest}}" error:NULL];
        template.tagDelegate = delegate;
        [template renderObject:nil error:NULL];
        
        STAssertNotNil(description, @"");
        NSRange range = [description rangeOfString:[self.testBundle pathForResource:@"GRMustacheTagDelegateTest" ofType:@"mustache"]];
        STAssertTrue(range.location != NSNotFound, @"");
    }
}

- (void)testTagDescriptionContainsURLBasedPartialPath
{
    {
        GRMustacheTestingDelegate *delegate = [[[GRMustacheTestingDelegate alloc] init] autorelease];
        __block NSString *description = nil;
        delegate.mustacheTagWillRenderBlock = ^id(GRMustacheTag *tag, id object) {
            [description release];
            description = [[tag description] retain];
            return object;
        };
        
        GRMustacheTemplate *template = [GRMustacheTemplate templateFromContentsOfURL:[self.testBundle URLForResource:@"GRMustacheTagDelegateTest_wrapper" withExtension:@"mustache"] error:NULL];
        template.tagDelegate = delegate;
        [template renderObject:nil error:NULL];
        
        STAssertNotNil(description, @"");
        NSRange range = [description rangeOfString:[self.testBundle pathForResource:@"GRMustacheTagDelegateTest" ofType:@"mustache"]];
        STAssertTrue(range.location != NSNotFound, @"");
    }
    {
        GRMustacheTestingDelegate *delegate = [[[GRMustacheTestingDelegate alloc] init] autorelease];
        __block NSString *description = nil;
        delegate.mustacheTagWillRenderBlock = ^id(GRMustacheTag *tag, id object) {
            [description release];
            description = [[tag description] retain];
            return object;
        };
        
        GRMustacheTemplateRepository *repository = [GRMustacheTemplateRepository templateRepositoryWithBaseURL:[self.testBundle resourceURL]];
        GRMustacheTemplate *template = [repository templateNamed:@"GRMustacheTagDelegateTest_wrapper" error:NULL];
        template.tagDelegate = delegate;
        [template renderObject:nil error:NULL];
        
        STAssertNotNil(description, @"");
        NSRange range = [description rangeOfString:[self.testBundle pathForResource:@"GRMustacheTagDelegateTest" ofType:@"mustache"]];
        STAssertTrue(range.location != NSNotFound, @"");
    }
    {
        GRMustacheTestingDelegate *delegate = [[[GRMustacheTestingDelegate alloc] init] autorelease];
        __block NSString *description = nil;
        delegate.mustacheTagWillRenderBlock = ^id(GRMustacheTag *tag, id object) {
            [description release];
            description = [[tag description] retain];
            return object;
        };
        
        GRMustacheTemplateRepository *repository = [GRMustacheTemplateRepository templateRepositoryWithBaseURL:[self.testBundle resourceURL]];
        GRMustacheTemplate *template = [repository templateFromString:@"{{>GRMustacheTagDelegateTest}}" error:NULL];
        template.tagDelegate = delegate;
        [template renderObject:nil error:NULL];
        
        STAssertNotNil(description, @"");
        NSRange range = [description rangeOfString:[self.testBundle pathForResource:@"GRMustacheTagDelegateTest" ofType:@"mustache"]];
        STAssertTrue(range.location != NSNotFound, @"");
    }
}

- (void)testTagDescriptionContainsPathBasedPartialPath
{
    {
        GRMustacheTestingDelegate *delegate = [[[GRMustacheTestingDelegate alloc] init] autorelease];
        __block NSString *description = nil;
        delegate.mustacheTagWillRenderBlock = ^id(GRMustacheTag *tag, id object) {
            [description release];
            description = [[tag description] retain];
            return object;
        };
        
        GRMustacheTemplate *template = [GRMustacheTemplate templateFromContentsOfFile:[self.testBundle pathForResource:@"GRMustacheTagDelegateTest_wrapper" ofType:@"mustache"] error:NULL];
        template.tagDelegate = delegate;
        [template renderObject:nil error:NULL];
        
        STAssertNotNil(description, @"");
        NSRange range = [description rangeOfString:[self.testBundle pathForResource:@"GRMustacheTagDelegateTest" ofType:@"mustache"]];
        STAssertTrue(range.location != NSNotFound, @"");
    }
    {
        GRMustacheTestingDelegate *delegate = [[[GRMustacheTestingDelegate alloc] init] autorelease];
        __block NSString *description = nil;
        delegate.mustacheTagWillRenderBlock = ^id(GRMustacheTag *tag, id object) {
            [description release];
            description = [[tag description] retain];
            return object;
        };
        
        GRMustacheTemplateRepository *repository = [GRMustacheTemplateRepository templateRepositoryWithDirectory:[self.testBundle resourcePath]];
        GRMustacheTemplate *template = [repository templateNamed:@"GRMustacheTagDelegateTest_wrapper" error:NULL];
        template.tagDelegate = delegate;
        [template renderObject:nil error:NULL];
        
        STAssertNotNil(description, @"");
        NSRange range = [description rangeOfString:[self.testBundle pathForResource:@"GRMustacheTagDelegateTest" ofType:@"mustache"]];
        STAssertTrue(range.location != NSNotFound, @"");
    }
    {
        GRMustacheTestingDelegate *delegate = [[[GRMustacheTestingDelegate alloc] init] autorelease];
        __block NSString *description = nil;
        delegate.mustacheTagWillRenderBlock = ^id(GRMustacheTag *tag, id object) {
            [description release];
            description = [[tag description] retain];
            return object;
        };
        
        GRMustacheTemplateRepository *repository = [GRMustacheTemplateRepository templateRepositoryWithDirectory:[self.testBundle resourcePath]];
        GRMustacheTemplate *template = [repository templateFromString:@"{{>GRMustacheTagDelegateTest}}" error:NULL];
        template.tagDelegate = delegate;
        [template renderObject:nil error:NULL];
        
        STAssertNotNil(description, @"");
        NSRange range = [description rangeOfString:[self.testBundle pathForResource:@"GRMustacheTagDelegateTest" ofType:@"mustache"]];
        STAssertTrue(range.location != NSNotFound, @"");
    }
}

- (void)testTagDelegateOnSection
{
    GRMustacheTestingDelegate *delegate = [[[GRMustacheTestingDelegate alloc] init] autorelease];
    __block GRMustacheTagType preRenderingTagType = -1;
    __block GRMustacheTagType postRenderingTagType = -1;
    __block id preRenderedObjet = nil;
    __block id postRenderedObjet = nil;
    delegate.mustacheTagWillRenderBlock = ^id(GRMustacheTag *tag, id object) {
        preRenderedObjet = object;
        preRenderingTagType = tag.type;
        return @"delegate";
    };
    delegate.mustacheTagDidRenderBlock = ^(GRMustacheTag *tag, id object, NSString *rendering) {
        postRenderedObjet = object;
        postRenderingTagType = tag.type;
    };
    
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{#delegate}}{{value}}{{/delegate}}" error:NULL];
    NSString *rendering = [template renderObject:@{@"delegate":delegate, @"value":@"foo"} error:NULL];
    
    STAssertEqualObjects(rendering, @"delegate", @"");
    STAssertEquals(preRenderingTagType, GRMustacheTagTypeVariable, @"");
    STAssertEquals(postRenderingTagType, GRMustacheTagTypeVariable, @"");
    STAssertEqualObjects(preRenderedObjet, @"foo", @"");
    STAssertEqualObjects(postRenderedObjet, @"delegate", @"");
}

- (void)testTagDelegateOrdering
{
    GRMustacheTestingDelegate *uppercaseDelegate = [[[GRMustacheTestingDelegate alloc] init] autorelease];
    uppercaseDelegate.mustacheTagWillRenderBlock = ^id(GRMustacheTag *tag, id object) {
        if ([object isKindOfClass:[NSString class]]) {
            return [[object description] uppercaseString];
        }
        return object;
    };
    
    GRMustacheTestingDelegate *prefixDelegate = [[[GRMustacheTestingDelegate alloc] init] autorelease];
    prefixDelegate.mustacheTagWillRenderBlock = ^id(GRMustacheTag *tag, id object) {
        if ([object isKindOfClass:[NSString class]]) {
            return [NSString stringWithFormat:@"prefix%@", object];
        }
        return object;
    };
    
    GRMustacheTestingDelegate *wrapDelegate = [[[GRMustacheTestingDelegate alloc] init] autorelease];
    wrapDelegate.mustacheTagWillRenderBlock = ^id(GRMustacheTag *tag, id object) {
        if ([object isKindOfClass:[NSString class]]) {
            return [NSString stringWithFormat:@"(%@)", object];
        }
        return object;
    };
    
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{#prefix}}{{value}} {{#uppercase}}{{value}}{{/uppercase}}{{/prefix}} {{#uppercase}}{{value}} {{#prefix}}{{value}}{{/prefix}}{{/uppercase}} {{value}}" error:NULL];
    template.tagDelegate = wrapDelegate;
    NSString *rendering = [template renderObject:@{@"prefix":prefixDelegate, @"uppercase":uppercaseDelegate, @"value":@"foo"} error:NULL];
    
    STAssertEqualObjects(rendering, @"(prefixfoo) (prefixFOO) (FOO) (PREFIXFOO) (foo)", @"");
}

- (void)testTagDelegatePreAndPostHooksConsistency
{
    GRMustacheTestingDelegate *delegate1 = [[[GRMustacheTestingDelegate alloc] init] autorelease];
    delegate1.mustacheTagWillRenderBlock = ^id(GRMustacheTag *tag, id object) {
        return @"1";
    };
    delegate1.mustacheTagDidRenderBlock = ^(GRMustacheTag *tag, id object, NSString *rendering) {
        STAssertEqualObjects(object, @"1", @"");
    };

    GRMustacheTestingDelegate *delegate2 = [[[GRMustacheTestingDelegate alloc] init] autorelease];
    delegate2.mustacheTagWillRenderBlock = ^id(GRMustacheTag *tag, id object) {
        return @"2";
    };
    delegate2.mustacheTagDidRenderBlock = ^(GRMustacheTag *tag, id object, NSString *rendering) {
        STAssertEqualObjects(object, @"2", @"");
    };
    
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{#d1}}{{#d2}}{{value}}{{/}}{{/}} {{#d2}}{{#d1}}{{value}}{{/}}{{/}}" error:NULL];
    [template renderObject:@{@"d1":delegate1, @"d2":delegate2} error:NULL];
}

- (void)testArrayOfTagDelegatesInSectionTag
{
    __block BOOL delegate1HasBeenInvoked = NO;
    GRMustacheTestingDelegate *delegate1 = [[[GRMustacheTestingDelegate alloc] init] autorelease];
    delegate1.mustacheTagWillRenderBlock = ^id(GRMustacheTag *tag, id object) { delegate1HasBeenInvoked = YES; return object; };
    
    __block BOOL delegate2HasBeenInvoked = NO;
    GRMustacheTestingDelegate *delegate2 = [[[GRMustacheTestingDelegate alloc] init] autorelease];
    delegate2.mustacheTagWillRenderBlock = ^id(GRMustacheTag *tag, id object) { delegate2HasBeenInvoked = YES; return object; };
    
    id items = @{@"items": @[delegate1, delegate2] };
    [[GRMustacheTemplate templateFromString:@"{{#items}}{{.}}{{/items}}" error:NULL] renderObject:items error:NULL];
    
    STAssertTrue(delegate1HasBeenInvoked, @"");
    STAssertTrue(delegate2HasBeenInvoked, @"");
}

@end
