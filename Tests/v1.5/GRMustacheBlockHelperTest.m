// The MIT License
// 
// Copyright (c) 2010 Gwendal Roué
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

#import "GRMustache_context.h"
#import "GRMustacheBlockHelperTest.h"


@implementation GRMustacheBlockHelperTest

#if GRMUSTACHE_BLOCKS_AVAILABLE
- (void)testDoesntExecuteWhatItDoesntNeedTo {
	__block BOOL dead = NO;
	GRMustacheBlockHelper *dieHelper = [GRMustacheBlockHelper helperWithBlock:^(GRMustacheSection *section, id context) {
		dead = YES;
		return @"foo";
	}];
	NSString *templateString = @"{{#show}}<li>{{#die}}{{/die}}</li>{{/show}}yay";
	NSDictionary *context = [NSDictionary dictionaryWithObject:dieHelper forKey:@"die"];
	NSString *result = [GRMustacheTemplate renderObject:context fromString:templateString error:nil];
	STAssertEqualObjects(result, @"yay", nil);
	STAssertEquals(dead, NO, nil);
}

- (void)testSectionsReturningLambdasGetCalledWithText {
	__block int renderedCalls = 0;
	__block NSString *cache = nil;
	
	GRMustacheBlockHelper *renderedHelper = [GRMustacheBlockHelper helperWithBlock:^(GRMustacheSection *section, id context) {
		if (cache == nil) {
			renderedCalls++;
			cache = [[section renderObject:context] retain];
		}
		return cache;
	}];
    [cache release];
	
	GRMustacheBlockHelper *notRenderedHelper = [GRMustacheBlockHelper helperWithBlock:^(GRMustacheSection *section, id context) {
		return section.templateString;
	}];
	
	NSDictionary *context = [NSDictionary dictionaryWithObjectsAndKeys:
							 renderedHelper, @"rendered",
							 notRenderedHelper, @"not_rendered",
							 @"Gwendal", @"name",
							 nil];
	
	NSString *result;
	
	result = [self renderObject:context fromResource:@"lambda"];
	STAssertEqualObjects(result, @"|Gwendal|-|{{name}}|", @"");
	STAssertEquals(renderedCalls, 1, @"");
	
	result = [self renderObject:context fromResource:@"lambda"];
	STAssertEqualObjects(result, @"|Gwendal|-|{{name}}|", @"");
	STAssertEquals(renderedCalls, 1, @"");
	
	result = [self renderObject:context fromResource:@"lambda"];
	STAssertEqualObjects(result, @"|Gwendal|-|{{name}}|", @"");
	STAssertEquals(renderedCalls, 1, @"");
}

- (void)testSectionLambdasCanRenderCurrentContextInSpecificTemplate {
	NSString *templateString = @"{{#wrapper}}{{/wrapper}}";
	GRMustacheTemplate *wrapperTemplate = [GRMustacheTemplate parseString:@"<b>{{name}}</b>" error:nil];
	GRMustacheBlockHelper *wrapperHelper = [GRMustacheBlockHelper helperWithBlock:^(GRMustacheSection *section, id context) {
		return [wrapperTemplate renderObject:context];
	}];
	NSDictionary *context = [NSDictionary dictionaryWithObjectsAndKeys:
							 wrapperHelper, @"wrapper",
							 @"Gwendal", @"name",
							 nil];
	NSString *result = [GRMustacheTemplate renderObject:context fromString:templateString error:nil];
	STAssertEqualObjects(result, @"<b>Gwendal</b>", nil);
}

- (void)testSectionLambdasCanReturnNil {
	NSString *templateString = @"foo{{#wrapper}}{{/wrapper}}bar";
	GRMustacheBlockHelper *wrapperHelper = [GRMustacheBlockHelper helperWithBlock:^(GRMustacheSection *section, id context) {
		return (NSString *)nil;
	}];
	NSDictionary *context = [NSDictionary dictionaryWithObject:wrapperHelper forKey:@"wrapper"];
	NSString *result = [GRMustacheTemplate renderObject:context fromString:templateString error:nil];
	STAssertEqualObjects(result, @"foobar", nil);
}
#endif

@end
