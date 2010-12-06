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

#import "GRMustacheLambda_private.h"
#import "GRMustacheRendering.h"

@implementation GRMustacheLambdaWrapper

- (NSString *)renderObject:(id)context withSection:(GRMustacheSection *)section {
	return @"";
}

@end


@interface GRMustacheLambdaSelectorWrapper()
- (id)initWithObject:(id)object selector:(SEL)renderingSelector;
@end


@implementation GRMustacheLambdaSelectorWrapper

+ (id)helperWithObject:(id)object selector:(SEL)renderingSelector {
	return [[[self alloc] initWithObject:object selector:renderingSelector] autorelease];
}

- (id)initWithObject:(id)theObject selector:(SEL)theRenderingSelector {
	if ((self = [self init])) {
		object = [theObject retain];
		renderingSelector = theRenderingSelector;
	}
	return self;
}

- (void)dealloc {
	[object release];
	[super dealloc];
}

- (NSString *)renderObject:(id)context withSection:(GRMustacheSection *)section {
	NSString *result = objc_msgSend(object, renderingSelector, section, context);
	if (result == nil) {
		return @"";
	}
	return result;
}

@end


#if NS_BLOCKS_AVAILABLE

@interface GRMustacheDeprecatedLambdaBlockWrapper: GRMustacheLambdaWrapper {
@private
	GRMustacheDeprecatedLambdaBlock block;
}
+ (id)lambdaWithBlock:(GRMustacheDeprecatedLambdaBlock)block;
- (id)initWithBlock:(GRMustacheDeprecatedLambdaBlock)block;
@end


@implementation GRMustacheDeprecatedLambdaBlockWrapper

+ (id)lambdaWithBlock:(GRMustacheDeprecatedLambdaBlock)block {
	return [[[self alloc] initWithBlock:block] autorelease];
}

- (id)initWithBlock:(GRMustacheDeprecatedLambdaBlock)theBlock {
	if ((self = [self init])) {
		block = [theBlock copy];
	}
	return self;
}

- (NSString *)renderObject:(id)context withSection:(GRMustacheSection *)section {
	NSString *result = block(^(id object){ return [section renderObject:object]; }, context, section.templateString);
	if (result == nil) {
		return @"";
	}
	return result;
}

- (NSString *)description {
	return @"<GRMustacheLambda>";
}

- (void)dealloc {
	[block release];
	[super dealloc];
}

@end


GRMustacheLambda GRMustacheLambdaMake(GRMustacheDeprecatedLambdaBlock block) {
	return [GRMustacheDeprecatedLambdaBlockWrapper lambdaWithBlock:block];
}


@interface GRMustacheLambdaBlockWrapper: GRMustacheLambdaWrapper {
@private
	GRMustacheLambdaBlock block;
}
+ (id)lambdaWithBlock:(GRMustacheLambdaBlock)block;
- (id)initWithBlock:(GRMustacheLambdaBlock)block;
@end


@implementation GRMustacheLambdaBlockWrapper

+ (id)lambdaWithBlock:(GRMustacheLambdaBlock)block {
	return [[(GRMustacheLambdaBlockWrapper *)[self alloc] initWithBlock:block] autorelease];
}

- (id)initWithBlock:(GRMustacheLambdaBlock)theBlock {
	if ((self = [self init])) {
		block = [theBlock copy];
	}
	return self;
}

- (NSString *)renderObject:(id)context withSection:(GRMustacheSection *)section {
	NSString *result = block(section, context);
	if (result == nil) {
		return @"";
	}
	return result;
}

- (NSString *)description {
	return @"<GRMustacheLambda>";
}

- (void)dealloc {
	[block release];
	[super dealloc];
}

@end


GRMustacheLambda GRMustacheLambdaBlockMake(GRMustacheLambdaBlock block) {
	return [GRMustacheLambdaBlockWrapper lambdaWithBlock:block];
}
#endif
