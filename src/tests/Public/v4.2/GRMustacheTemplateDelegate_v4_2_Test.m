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

#import "GRMustacheTemplateDelegate_v4_2_Test.h"

@interface GRMustacheTemplatePrefixDelegate : NSObject<GRMustacheTemplateDelegate>
@end

@implementation GRMustacheTemplatePrefixDelegate
- (void)template:(GRMustacheTemplate *)template willRenderReturnValueOfInvocation:(GRMustacheInvocation *)invocation
{
    if ([invocation.returnValue isKindOfClass:[NSString class]]) {
        invocation.returnValue = [NSString stringWithFormat:@"prefix%@", invocation.returnValue];
    }
}
@end

@interface GRMustacheTemplateUppercaseDelegate : NSObject<GRMustacheTemplateDelegate>
@end

@implementation GRMustacheTemplateUppercaseDelegate
- (void)template:(GRMustacheTemplate *)template willRenderReturnValueOfInvocation:(GRMustacheInvocation *)invocation
{
    if ([invocation.returnValue isKindOfClass:[NSString class]]) {
        invocation.returnValue = [[invocation.returnValue description] uppercaseString];
    }
}
@end

@interface GRMustacheTemplateSuffixDelegate : NSObject<GRMustacheTemplateDelegate>
@end

@implementation GRMustacheTemplateSuffixDelegate
- (void)template:(GRMustacheTemplate *)template willRenderReturnValueOfInvocation:(GRMustacheInvocation *)invocation
{
    if ([invocation.returnValue isKindOfClass:[NSString class]]) {
        invocation.returnValue = [NSString stringWithFormat:@"%@suffix", invocation.returnValue];
    }
}
@end

@implementation GRMustacheTemplateDelegate_v4_2_Test

- (void)testSectionDelegate
{
    GRMustacheTemplatePrefixDelegate *prefixDelegate = [[[GRMustacheTemplatePrefixDelegate alloc] init] autorelease];
    GRMustacheTemplateSuffixDelegate *suffixDelegate = [[[GRMustacheTemplateSuffixDelegate alloc] init] autorelease];
    
    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                          prefixDelegate, @"prefix",
                          suffixDelegate, @"suffix",
                          @"foo", @"value",
                          nil];
    
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{#prefix}}{{value}}{{/prefix}} {{#suffix}}{{value}}{{/suffix}} {{value}}" error:NULL];
    
    NSString *rendering = [template renderObject:data];
    STAssertEqualObjects(rendering, @"prefixfoo foosuffix foo", @"");
}

- (void)testNestedSectionsDelegate
{
    GRMustacheTemplateUppercaseDelegate *uppercaseDelegate = [[[GRMustacheTemplateUppercaseDelegate alloc] init] autorelease];
    GRMustacheTemplatePrefixDelegate *prefixDelegate = [[[GRMustacheTemplatePrefixDelegate alloc] init] autorelease];
    
    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                          prefixDelegate, @"prefix",
                          uppercaseDelegate, @"uppercase",
                          @"foo", @"value",
                          nil];
    
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{#prefix}}{{value}} {{#uppercase}}{{value}}{{/uppercase}}{{/prefix}} {{#uppercase}}{{value}} {{#prefix}}{{value}}{{/prefix}}{{/uppercase}}" error:NULL];
    
    NSString *rendering = [template renderObject:data];
    STAssertEqualObjects(rendering, @"prefixfoo prefixFOO FOO PREFIXFOO", @"");
}

- (void)testTemplatePlusSectionDelegate
{
    GRMustacheTemplateUppercaseDelegate *uppercaseDelegate = [[[GRMustacheTemplateUppercaseDelegate alloc] init] autorelease];
    GRMustacheTemplatePrefixDelegate *prefixDelegate = [[[GRMustacheTemplatePrefixDelegate alloc] init] autorelease];
    GRMustacheTemplateSuffixDelegate *suffixDelegate = [[[GRMustacheTemplateSuffixDelegate alloc] init] autorelease];
    
    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                          prefixDelegate, @"prefix",
                          suffixDelegate, @"suffix",
                          @"foo", @"value",
                          nil];
    
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{#prefix}}{{value}}{{/prefix}} {{#suffix}}{{value}}{{/suffix}} {{value}}" error:NULL];
    template.delegate = uppercaseDelegate;
    
    NSString *rendering = [template renderObject:data];
    STAssertEqualObjects(rendering, @"PREFIXFOO FOOSUFFIX FOO", @"");
}

- (void)testTemplatePlusNestedSectionsDelegate
{
    GRMustacheTemplateUppercaseDelegate *uppercaseDelegate = [[[GRMustacheTemplateUppercaseDelegate alloc] init] autorelease];
    GRMustacheTemplatePrefixDelegate *prefixDelegate = [[[GRMustacheTemplatePrefixDelegate alloc] init] autorelease];
    GRMustacheTemplateSuffixDelegate *suffixDelegate = [[[GRMustacheTemplateSuffixDelegate alloc] init] autorelease];
    
    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                          prefixDelegate, @"prefix",
                          uppercaseDelegate, @"uppercase",
                          @"foo", @"value",
                          nil];
    
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{#prefix}}{{value}} {{#uppercase}}{{value}}{{/uppercase}}{{/prefix}} {{#uppercase}}{{value}} {{#prefix}}{{value}}{{/prefix}}{{/uppercase}}" error:NULL];
    template.delegate = suffixDelegate;
    
    NSString *rendering = [template renderObject:data];
    STAssertEqualObjects(rendering, @"prefixfoosuffix prefixFOOsuffix FOOsuffix PREFIXFOOsuffix", @"");
}


@end
