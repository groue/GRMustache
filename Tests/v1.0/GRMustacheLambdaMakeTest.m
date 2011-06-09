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

#import "GRMUstache_context.h"
#import "GRMustacheLambdaMakeTest.h"


@implementation GRMustacheLambdaMakeTest

#if GRMUSTACHE_BLOCKS_AVAILABLE
- (void)testDoesntExecuteWhatItDoesntNeedTo {
	__block BOOL dead = NO;
	GRMustacheLambda dieLambda = GRMustacheLambdaMake(^(GRMustacheRenderer renderer, id context, NSString *templateString) {
		dead = YES;
		return templateString;
	});
	NSString *templateString = @"{{#show}}<li>{{die}}</li>{{/show}}yay";
	NSDictionary *context = [NSDictionary dictionaryWithObject:dieLambda forKey:@"die"];
	NSString *result = [GRMustacheTemplate renderObject:context fromString:templateString error:nil];
	STAssertEqualObjects(result, @"yay", nil);
	STAssertEquals(dead, NO, nil);
}
#endif

#if GRMUSTACHE_BLOCKS_AVAILABLE
- (void)testSectionsReturningLambdasGetCalledWithText {
	__block int renderedCalls = 0;
	__block NSString *cache = nil;
	
	GRMustacheLambda renderedLambda = GRMustacheLambdaMake(^(GRMustacheRenderer renderer, id context, NSString *templateString) {
		if (cache == nil) {
			renderedCalls++;
			cache = [renderer(context) retain];
		}
		return cache;
	});
    [cache release];
	
	GRMustacheLambda notRenderedLambda = GRMustacheLambdaMake(^(GRMustacheRenderer renderer, id context, NSString *templateString) {
		return templateString;
	});
	
	NSDictionary *context = [NSDictionary dictionaryWithObjectsAndKeys:
							 renderedLambda, @"rendered",
							 notRenderedLambda, @"not_rendered",
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
#endif

#if GRMUSTACHE_BLOCKS_AVAILABLE
- (void)testSectionLambdasCanRenderCurrentContextInSpecificTemplate {
	NSString *templateString = @"{{#wrapper}}{{/wrapper}}";
	GRMustacheTemplate *wrapperTemplate = [GRMustacheTemplate parseString:@"<b>{{name}}</b>" error:nil];
	GRMustacheLambda wrapperLambda = GRMustacheLambdaMake(^(GRMustacheRenderer renderer, id context, NSString *templateString) {
		return [wrapperTemplate renderObject:context];
	});
	NSDictionary *context = [NSDictionary dictionaryWithObjectsAndKeys:
							 wrapperLambda, @"wrapper",
							 @"Gwendal", @"name",
							 nil];
	NSString *result = [GRMustacheTemplate renderObject:context fromString:templateString error:nil];
	STAssertEqualObjects(result, @"<b>Gwendal</b>", nil);
}
#endif

#if GRMUSTACHE_BLOCKS_AVAILABLE
- (void)testSectionLambdasCanReturnNil {
	NSString *templateString = @"foo{{#wrapper}}{{/wrapper}}bar";
	GRMustacheLambda wrapperLambda = GRMustacheLambdaMake(^(GRMustacheRenderer renderer, id context, NSString *templateString) {
		return (NSString *)nil;
	});
	NSDictionary *context = [NSDictionary dictionaryWithObject:wrapperLambda forKey:@"wrapper"];
	NSString *result = [GRMustacheTemplate renderObject:context fromString:templateString error:nil];
	STAssertEqualObjects(result, @"foobar", nil);
}
#endif

@end
