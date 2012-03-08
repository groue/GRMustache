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

#import "GRMustacheInvocationDescriptionTest.h"

@interface GRMustacheInvocationDescriptionTestRecorder : NSObject<GRMustacheTemplateDelegate>
@property (nonatomic, retain) GRMustacheInvocation *lastInvocation;
@end

@implementation GRMustacheInvocationDescriptionTestRecorder
@synthesize lastInvocation=_lastInvocation;

- (void)dealloc
{
    self.lastInvocation = nil;
    [super dealloc];
}

- (void)template:(GRMustacheTemplate *)template willRenderReturnValueOfInvocation:(GRMustacheInvocation *)invocation
{
    self.lastInvocation = invocation;
}

@end

@implementation GRMustacheInvocationDescriptionTest

- (void)testInvocationDescriptionContainsTag
{
    GRMustacheInvocationDescriptionTestRecorder *recorder = [[[GRMustacheInvocationDescriptionTestRecorder alloc] init] autorelease];
    GRMustacheTemplate *template;
    NSString *description;
    NSRange range;
    
    template = [GRMustacheTemplate templateFromString:@"{{name}}" error:NULL];
    template.delegate = recorder;
    [template render];
    description = recorder.lastInvocation.description;
    range = [description rangeOfString:@"{{name}}"];
    STAssertTrue(range.location != NSNotFound, @"");
    
    template = [GRMustacheTemplate templateFromString:@"{{#name}}{{/name}}" error:NULL];
    template.delegate = recorder;
    [template render];
    description = recorder.lastInvocation.description;
    range = [description rangeOfString:@"{{#name}}"];
    STAssertTrue(range.location != NSNotFound, @"");
    
    template = [GRMustacheTemplate templateFromString:@"{{   name\t}}" error:NULL];
    template.delegate = recorder;
    [template render];
    description = recorder.lastInvocation.description;
    range = [description rangeOfString:@"{{   name\t}}"];
    STAssertTrue(range.location != NSNotFound, @"");
}

- (void)testInvocationDescriptionContainsLineNumber
{
    GRMustacheInvocationDescriptionTestRecorder *recorder = [[[GRMustacheInvocationDescriptionTestRecorder alloc] init] autorelease];
    GRMustacheTemplate *template;
    NSString *description;
    NSRange range;
    
    template = [GRMustacheTemplate templateFromString:@"{{name}}" error:NULL];
    template.delegate = recorder;
    [template render];
    description = recorder.lastInvocation.description;
    range = [recorder.lastInvocation.description rangeOfString:@"line 1"];
    STAssertTrue(range.location != NSNotFound, @"");
    
    template = [GRMustacheTemplate templateFromString:@"\n {{name}}" error:NULL];
    template.delegate = recorder;
    [template render];
    description = recorder.lastInvocation.description;
    range = [description rangeOfString:@"line 2"];
    STAssertTrue(range.location != NSNotFound, @"");
    
    template = [GRMustacheTemplate templateFromString:@"\n\n  {{#name}}\n\n{{/name}}" error:NULL];
    template.delegate = recorder;
    [template render];
    description = recorder.lastInvocation.description;
    range = [description rangeOfString:@"line 3"];
    STAssertTrue(range.location != NSNotFound, @"");
}

- (void)testInvocationDescriptionContainsResourceBasedTemplatePath
{
    GRMustacheInvocationDescriptionTestRecorder *recorder = [[[GRMustacheInvocationDescriptionTestRecorder alloc] init] autorelease];
    GRMustacheTemplate *template;
    NSString *description;
    NSRange range;
    
    template = [GRMustacheTemplate templateFromResource:@"passenger" withExtension:@"conf" bundle:self.testBundle error:NULL];
    template.delegate = recorder;
    [template render];
    description = recorder.lastInvocation.description;
    range = [recorder.lastInvocation.description rangeOfString:[self.testBundle pathForResource:@"passenger" ofType:@"conf"]];
    STAssertTrue(range.location != NSNotFound, @"");
    
    GRMustacheTemplateLoader *loader = [GRMustacheTemplateLoader templateLoaderWithBundle:self.testBundle extension:@"conf"];
    template = [loader templateWithName:@"passenger" error:NULL];
    template.delegate = recorder;
    [template render];
    description = recorder.lastInvocation.description;
    range = [recorder.lastInvocation.description rangeOfString:[self.testBundle pathForResource:@"passenger" ofType:@"conf"]];
    STAssertTrue(range.location != NSNotFound, @"");
}

- (void)testInvocationDescriptionContainsURLBasedTemplatePath
{
    GRMustacheInvocationDescriptionTestRecorder *recorder = [[[GRMustacheInvocationDescriptionTestRecorder alloc] init] autorelease];
    GRMustacheTemplate *template;
    NSString *description;
    NSRange range;
    
    template = [GRMustacheTemplate templateFromContentsOfURL:[self.testBundle URLForResource:@"passenger" withExtension:@"conf"] error:NULL];
    template.delegate = recorder;
    [template render];
    description = recorder.lastInvocation.description;
    range = [recorder.lastInvocation.description rangeOfString:[self.testBundle pathForResource:@"passenger" ofType:@"conf"]];
    STAssertTrue(range.location != NSNotFound, @"");
    
    GRMustacheTemplateLoader *loader = [GRMustacheTemplateLoader templateLoaderWithBaseURL:[self.testBundle resourceURL] extension:@"conf"];
    template = [loader templateWithName:@"passenger" error:NULL];
    template.delegate = recorder;
    [template render];
    description = recorder.lastInvocation.description;
    range = [recorder.lastInvocation.description rangeOfString:[self.testBundle pathForResource:@"passenger" ofType:@"conf"]];
    STAssertTrue(range.location != NSNotFound, @"");
}

- (void)testInvocationDescriptionContainsPathBasedTemplatePath
{
    GRMustacheInvocationDescriptionTestRecorder *recorder = [[[GRMustacheInvocationDescriptionTestRecorder alloc] init] autorelease];
    GRMustacheTemplate *template;
    NSString *description;
    NSRange range;
    
    template = [GRMustacheTemplate templateFromContentsOfFile:[self.testBundle pathForResource:@"passenger" ofType:@"conf"] error:NULL];
    template.delegate = recorder;
    [template render];
    description = recorder.lastInvocation.description;
    range = [recorder.lastInvocation.description rangeOfString:[self.testBundle pathForResource:@"passenger" ofType:@"conf"]];
    STAssertTrue(range.location != NSNotFound, @"");
    
    GRMustacheTemplateLoader *loader = [GRMustacheTemplateLoader templateLoaderWithDirectory:[self.testBundle resourcePath] extension:@"conf"];
    template = [loader templateWithName:@"passenger" error:NULL];
    template.delegate = recorder;
    [template render];
    description = recorder.lastInvocation.description;
    range = [recorder.lastInvocation.description rangeOfString:[self.testBundle pathForResource:@"passenger" ofType:@"conf"]];
    STAssertTrue(range.location != NSNotFound, @"");
}

- (void)testInvocationDescriptionContainsResourceBasedPartialPath
{
    GRMustacheInvocationDescriptionTestRecorder *recorder = [[[GRMustacheInvocationDescriptionTestRecorder alloc] init] autorelease];
    GRMustacheTemplate *template;
    NSString *description;
    NSRange range;
    
    template = [GRMustacheTemplate templateFromResource:@"template_partial" bundle:self.testBundle error:NULL];
    template.delegate = recorder;
    [template render];
    description = recorder.lastInvocation.description;
    range = [recorder.lastInvocation.description rangeOfString:[self.testBundle pathForResource:@"inner_partial" ofType:@"mustache"]];
    STAssertTrue(range.location != NSNotFound, @"");
    
    GRMustacheTemplateLoader *loader = [GRMustacheTemplateLoader templateLoaderWithBundle:self.testBundle];

    template = [loader templateWithName:@"template_partial" error:NULL];
    template.delegate = recorder;
    [template render];
    description = recorder.lastInvocation.description;
    range = [recorder.lastInvocation.description rangeOfString:[self.testBundle pathForResource:@"inner_partial" ofType:@"mustache"]];
    STAssertTrue(range.location != NSNotFound, @"");
    
    template = [loader templateFromString:@"{{>inner_partial}}" error:NULL];
    template.delegate = recorder;
    [template render];
    description = recorder.lastInvocation.description;
    range = [recorder.lastInvocation.description rangeOfString:[self.testBundle pathForResource:@"inner_partial" ofType:@"mustache"]];
    STAssertTrue(range.location != NSNotFound, @"");
}

- (void)testInvocationDescriptionContainsURLBasedPartialPath
{
    GRMustacheInvocationDescriptionTestRecorder *recorder = [[[GRMustacheInvocationDescriptionTestRecorder alloc] init] autorelease];
    GRMustacheTemplate *template;
    NSString *description;
    NSRange range;
    
    template = [GRMustacheTemplate templateFromContentsOfURL:[self.testBundle URLForResource:@"template_partial" withExtension:@"conf"] error:NULL];
    template.delegate = recorder;
    [template render];
    description = recorder.lastInvocation.description;
    range = [recorder.lastInvocation.description rangeOfString:[self.testBundle pathForResource:@"inner_partial" ofType:@"mustache"]];
    STAssertTrue(range.location != NSNotFound, @"");
    
    GRMustacheTemplateLoader *loader = [GRMustacheTemplateLoader templateLoaderWithBaseURL:[self.testBundle resourceURL]];
    
    template = [loader templateWithName:@"template_partial" error:NULL];
    template.delegate = recorder;
    [template render];
    description = recorder.lastInvocation.description;
    range = [recorder.lastInvocation.description rangeOfString:[self.testBundle pathForResource:@"inner_partial" ofType:@"mustache"]];
    STAssertTrue(range.location != NSNotFound, @"");
    
    template = [loader templateFromString:@"{{>inner_partial}}" error:NULL];
    template.delegate = recorder;
    [template render];
    description = recorder.lastInvocation.description;
    range = [recorder.lastInvocation.description rangeOfString:[self.testBundle pathForResource:@"inner_partial" ofType:@"mustache"]];
    STAssertTrue(range.location != NSNotFound, @"");
}

- (void)testInvocationDescriptionContainsPathBasedPartialPath
{
    GRMustacheInvocationDescriptionTestRecorder *recorder = [[[GRMustacheInvocationDescriptionTestRecorder alloc] init] autorelease];
    GRMustacheTemplate *template;
    NSString *description;
    NSRange range;
    
    template = [GRMustacheTemplate templateFromContentsOfFile:[self.testBundle pathForResource:@"template_partial" ofType:@"mustache"] error:NULL];
    template.delegate = recorder;
    [template render];
    description = recorder.lastInvocation.description;
    range = [recorder.lastInvocation.description rangeOfString:[self.testBundle pathForResource:@"inner_partial" ofType:@"mustache"]];
    STAssertTrue(range.location != NSNotFound, @"");
    
    GRMustacheTemplateLoader *loader = [GRMustacheTemplateLoader templateLoaderWithDirectory:[self.testBundle resourcePath]];
    
    template = [loader templateWithName:@"template_partial" error:NULL];
    template.delegate = recorder;
    [template render];
    description = recorder.lastInvocation.description;
    range = [recorder.lastInvocation.description rangeOfString:[self.testBundle pathForResource:@"inner_partial" ofType:@"mustache"]];
    STAssertTrue(range.location != NSNotFound, @"");
    
    template = [loader templateFromString:@"{{>inner_partial}}" error:NULL];
    template.delegate = recorder;
    [template render];
    description = recorder.lastInvocation.description;
    range = [recorder.lastInvocation.description rangeOfString:[self.testBundle pathForResource:@"inner_partial" ofType:@"mustache"]];
    STAssertTrue(range.location != NSNotFound, @"");
}

@end
