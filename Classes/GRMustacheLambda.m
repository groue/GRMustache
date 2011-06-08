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

#import <objc/message.h>
#import "GRMustacheLambda_private.h"
#import "GRMustacheRendering.h"

@interface GRMustacheSelectorHelper()
- (id)initWithObject:(id)object selector:(SEL)renderingSelector;
@end


@implementation GRMustacheSelectorHelper

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

@interface GRMustacheBlockHelper()<GRMustacheHelper>
- (id)initWithBlock:(NSString *(^)(GRMustacheSection* section, id context))block;
@end


@implementation GRMustacheBlockHelper

+ (id)helperWithBlock:(NSString *(^)(GRMustacheSection* section, id context))block {
	return [[(GRMustacheBlockHelper *)[self alloc] initWithBlock:block] autorelease];
}

- (id)initWithBlock:(NSString *(^)(GRMustacheSection* section, id context))theBlock {
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
	return @"<GRMustacheBlockHelper>";
}

- (void)dealloc {
	[block release];
	[super dealloc];
}

@end


// =================== DEPRECATED STUFF BELOW ===================


@interface GRMustacheDeprecatedBlockHelper1: NSObject<GRMustacheHelper> {
@private
	NSString *(^block)(NSString *(^)(id object), id, NSString *);
}
+ (id)helperWithBlock:(NSString *(^)(NSString *(^)(id object), id, NSString *))block;
- (id)initWithBlock:(NSString *(^)(NSString *(^)(id object), id, NSString *))block;
@end


@implementation GRMustacheDeprecatedBlockHelper1

+ (id)helperWithBlock:(NSString *(^)(NSString *(^)(id object), id, NSString *))block {
	return [[(GRMustacheDeprecatedBlockHelper1 *)[self alloc] initWithBlock:block] autorelease];
}

- (id)initWithBlock:(NSString *(^)(NSString *(^)(id object), id, NSString *))theBlock {
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
	return @"<GRMustacheDeprecatedBlockHelper1>";
}

- (void)dealloc {
	[block release];
	[super dealloc];
}

@end


id GRMustacheLambdaMake(NSString *(^block)(NSString *(^)(id object), id, NSString *)) {
	return [GRMustacheDeprecatedBlockHelper1 helperWithBlock:block];
}


@interface GRMustacheDeprecatedBlockHelper2: NSObject<GRMustacheHelper> {
@private
	GRMustacheRenderingBlock block;
}
+ (id)helperWithBlock:(GRMustacheRenderingBlock)block;
- (id)initWithBlock:(GRMustacheRenderingBlock)block;
@end


@implementation GRMustacheDeprecatedBlockHelper2

+ (id)helperWithBlock:(GRMustacheRenderingBlock)block {
	return [[(GRMustacheDeprecatedBlockHelper2 *)[self alloc] initWithBlock:block] autorelease];
}

- (id)initWithBlock:(GRMustacheRenderingBlock)theBlock {
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
	return @"<GRMustacheDeprecatedBlockHelper2>";
}

- (void)dealloc {
	[block release];
	[super dealloc];
}

@end

id GRMustacheLambdaBlockMake(GRMustacheRenderingBlock block) {
	return [GRMustacheDeprecatedBlockHelper2 helperWithBlock:block];
}


#endif
