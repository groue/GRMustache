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

#import "GRMustacheContextTest.h"
#import "GRBoolean_private.h"
#import "GRMustacheContext_private.h"
#import "GRMustacheTemplate_private.h"


@interface GRKVCRecorder: NSObject {
	NSString *lastAccessedKey;
	NSArray *keys;
}
@property (nonatomic, retain) NSString *lastAccessedKey;
@property (nonatomic, retain) NSArray *keys;
@end

@implementation GRKVCRecorder
@synthesize lastAccessedKey;
@synthesize keys;
+ (id)recorderWithRecognizedKeys:(NSArray *)keys {
	GRKVCRecorder *recorder = [[[self alloc] init] autorelease];
	recorder.keys = keys;
	return recorder;
}
+ (id)recorderWithRecognizedKey:(NSString *)key {
	GRKVCRecorder *recorder = [[[self alloc] init] autorelease];
	recorder.keys = [NSArray arrayWithObject:key];
	return recorder;
}
- (id)valueForKey:(NSString *)key {
	self.lastAccessedKey = key;
	if ([keys indexOfObject:key] == NSNotFound) {
		return [super valueForKey:key];
	}
	return key;
}
- (void)dealloc {
	[lastAccessedKey release];
	[keys release];
	[super dealloc];
}
@end

@interface ThrowingObject: NSObject
@end

@implementation ThrowingObject

- (id)valueForKey:(NSString *)key {
	if ([key isEqualToString:@"NonNSUndefinedKeyException"]) {
		NSAssert(NO, @"");
	}
	if ([key isEqualToString:@"OtherNSUndefinedKeyException"]) {
		return [@"" valueForKey:@"foo"];
	}
	return [super valueForKey:key];
}

@end


@interface GRKVCRecorderTest: SenTestCase
@end

@implementation GRKVCRecorderTest

- (void)testRecorderKnownKey {
	GRKVCRecorder *recorder = [GRKVCRecorder recorderWithRecognizedKey:@"foo"];
	STAssertNoThrow([recorder valueForKey:@"foo"], nil);
}

- (void)testRecorderUnknownKey {
	GRKVCRecorder *recorder = [GRKVCRecorder recorderWithRecognizedKey:@"foo"];
	STAssertThrows([recorder valueForKey:@"bar"], nil);
}

- (void)testRecorderRecordsKey {
	GRKVCRecorder *recorder = [GRKVCRecorder recorderWithRecognizedKey:@"foo"];
	[recorder valueForKey:@"foo"];
	STAssertEqualObjects(recorder.lastAccessedKey, @"foo", nil);
}

- (void)testRecorderValueForKeyReturnsKey {
	GRKVCRecorder *recorder = [GRKVCRecorder recorderWithRecognizedKey:@"foo"];
	STAssertEqualObjects([recorder valueForKey:@"foo"], @"foo", nil);
}

@end

@implementation GRMustacheContextTest

- (void)testOneDepthContextForwardsValueForKeyToItsObject {
	GRKVCRecorder *recorder = [GRKVCRecorder recorderWithRecognizedKey:@"foo"];
	GRMustacheContext *context = [GRMustacheContext contextWithObject:recorder options:GRMustacheTemplateOptionNone];
	[context valueForKey:@"foo"];
	STAssertEqualObjects(recorder.lastAccessedKey, @"foo", nil);
}

- (void)testTwoDepthContextForwardsValueForKeyToTopObjectOnlyIfTopObjectHasKey {
	GRKVCRecorder *rootRecorder = [GRKVCRecorder recorderWithRecognizedKey:@"root"];
	GRKVCRecorder *topRecorder = [GRKVCRecorder recorderWithRecognizedKey:@"top"];
	GRMustacheContext *context = [GRMustacheContext contextWithObject:rootRecorder options:GRMustacheTemplateOptionNone];
	context = [context contextByAddingObject:topRecorder];
	STAssertEqualObjects([context valueForKey:@"top"], @"top", nil);
	STAssertEqualObjects(topRecorder.lastAccessedKey, @"top", nil);
	STAssertNil(rootRecorder.lastAccessedKey, nil);
}

- (void)testTwoDepthContextForwardsValueForKeyToBothObjectIfTopObjectMisses {
	GRKVCRecorder *rootRecorder = [GRKVCRecorder recorderWithRecognizedKey:@"root"];
	GRKVCRecorder *topRecorder = [GRKVCRecorder recorderWithRecognizedKey:@"top"];
	GRMustacheContext *context = [GRMustacheContext contextWithObject:rootRecorder options:GRMustacheTemplateOptionNone];
	context = [context contextByAddingObject:topRecorder];
	STAssertEqualObjects([context valueForKey:@"root"], @"root", nil);
	STAssertEqualObjects(topRecorder.lastAccessedKey, @"root", nil);
	STAssertEqualObjects(rootRecorder.lastAccessedKey, @"root", nil);
}

- (void)testTwoDepthContextMissesIfBothObjectMisses {
	GRKVCRecorder *rootRecorder = [GRKVCRecorder recorderWithRecognizedKey:@"root"];
	GRKVCRecorder *topRecorder = [GRKVCRecorder recorderWithRecognizedKey:@"top"];
	GRMustacheContext *context = [GRMustacheContext contextWithObject:rootRecorder options:GRMustacheTemplateOptionNone];
	context = [context contextByAddingObject:topRecorder];
	STAssertNil([context valueForKey:@"foo"], nil);
	STAssertEqualObjects(topRecorder.lastAccessedKey, @"foo", nil);
	STAssertEqualObjects(rootRecorder.lastAccessedKey, @"foo", nil);
}

- (void)testNilDoesNotStopsExploration {
	NSDictionary *dictionary = [NSDictionary dictionaryWithObject:@"foo" forKey:@"key"];
	GRMustacheContext *context = [GRMustacheContext contextWithObject:dictionary options:GRMustacheTemplateOptionNone];
	dictionary = [NSDictionary dictionary];
	context = [context contextByAddingObject:dictionary];
	STAssertEqualObjects([context valueForKey:@"key"], @"foo", nil);
}

- (void)testNSNullDoesStopExploration {
	NSDictionary *dictionary = [NSDictionary dictionaryWithObject:@"foo" forKey:@"key"];
	GRMustacheContext *context = [GRMustacheContext contextWithObject:dictionary options:GRMustacheTemplateOptionNone];
	dictionary = [NSDictionary dictionaryWithObject:[NSNull null] forKey:@"key"];
	context = [context contextByAddingObject:dictionary];
	STAssertEqualObjects([context valueForKey:@"key"], [NSNull null], nil);
}

- (void)testGRNoDoesStopExploration {
	NSDictionary *dictionary = [NSDictionary dictionaryWithObject:@"foo" forKey:@"key"];
	GRMustacheContext *context = [GRMustacheContext contextWithObject:dictionary options:GRMustacheTemplateOptionNone];
	dictionary = [NSDictionary dictionaryWithObject:[GRNo no] forKey:@"key"];
	context = [context contextByAddingObject:dictionary];
	STAssertEqualObjects([context valueForKey:@"key"], [GRNo no], nil);
}

- (void)testNSNumberWithBoolNODoesStopExploration {
	NSDictionary *dictionary = [NSDictionary dictionaryWithObject:@"foo" forKey:@"key"];
	GRMustacheContext *context = [GRMustacheContext contextWithObject:dictionary options:GRMustacheTemplateOptionNone];
	dictionary = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:@"key"];
	context = [context contextByAddingObject:dictionary];
	STAssertEqualObjects([context valueForKey:@"key"], [NSNumber numberWithBool:NO], nil);
}

- (void)testOneDepthContextTemplate {
	NSString *result = [GRMustacheTemplate renderObject:@"foo" fromString:@"{{length}}" error:nil];
	STAssertEqualObjects(result, @"3", nil);
}

- (void)testTwoDepthContextTemplateWithTopObjectSuccess {
	NSString *templateString = @"{{#name}}{{length}}{{/name}}";
	id context = [GRKVCRecorder recorderWithRecognizedKey:@"name"];
	NSString *result = [GRMustacheTemplate renderObject:context fromString:templateString error:nil];
	STAssertEqualObjects(result, @"4", nil);
}

- (void)testTwoDepthContextTemplateWithTopObjectMiss {
	NSString *templateString = @"{{#name}}{{name}}{{/name}}";
	NSDictionary *context = [NSDictionary dictionaryWithObject:@"foo" forKey:@"name"];
	NSString *result = [GRMustacheTemplate renderObject:context fromString:templateString error:nil];
	STAssertEqualObjects(result, @"foo", nil);
}

- (void)testContextRethrowsNonNSUndefinedKeyException {
	ThrowingObject *throwingObject = [[[ThrowingObject alloc] init] autorelease];
	GRMustacheContext *context = [GRMustacheContext contextWithObject:throwingObject options:GRMustacheTemplateOptionNone];
	STAssertThrows([context valueForKey:@"NonNSUndefinedKeyException"], nil);
}

- (void)testContextRethrowsOtherNSUndefinedKeyException {
	ThrowingObject *throwingObject = [[[ThrowingObject alloc] init] autorelease];
	GRMustacheContext *context = [GRMustacheContext contextWithObject:throwingObject options:GRMustacheTemplateOptionNone];
	STAssertThrows([context valueForKey:@"OtherNSUndefinedKeyException"], nil);
}

- (void)testContextSwallowsSelfNSUndefinedKeyException {
	ThrowingObject *throwingObject = [[[ThrowingObject alloc] init] autorelease];
	GRMustacheContext *context = [GRMustacheContext contextWithObject:throwingObject options:GRMustacheTemplateOptionNone];
	STAssertNoThrow([context valueForKey:@"SelfNSUndefinedKeyException"], nil);
}

@end
