// The MIT License
// 
// Copyright (c) 2013 Gwendal Roué
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

#import "GRMustachePrivateAPITest.h"
#import "GRMustacheContext_private.h"
#import "GRMustacheTemplate_private.h"

@interface GRMustacheContextPrivateTest : GRMustachePrivateAPITest
@end


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
+ (instancetype)recorderWithRecognizedKeys:(NSArray *)keys
{
    GRKVCRecorder *recorder = [[[self alloc] init] autorelease];
    recorder.keys = keys;
    return recorder;
}
+ (instancetype)recorderWithRecognizedKey:(NSString *)key
{
    GRKVCRecorder *recorder = [[[self alloc] init] autorelease];
    recorder.keys = [NSArray arrayWithObject:key];
    return recorder;
}
- (id)valueForKey:(NSString *)key
{
    self.lastAccessedKey = key;
    if ([keys indexOfObject:key] == NSNotFound) {
        return [super valueForKey:key];
    }
    return key;
}
- (void)dealloc
{
    [lastAccessedKey release];
    [keys release];
    [super dealloc];
}
@end

@interface ThrowingObject: NSObject
@end

@implementation ThrowingObject

- (id)valueForKey:(NSString *)key
{
    if ([key isEqualToString:@"NonNSUndefinedKeyException"]) {
        NSAssert(NO, @"");
    }
    if ([key isEqualToString:@"NonSelfNSUndefinedKeyException"]) {
        return [@"" valueForKey:@"foo"];
    }
    return [super valueForKey:key];
}

@end


@interface GRKVCRecorderTest: SenTestCase
@end

@implementation GRKVCRecorderTest

- (void)testRecorderKnownKey
{
    GRKVCRecorder *recorder = [GRKVCRecorder recorderWithRecognizedKey:@"foo"];
    STAssertNoThrow([recorder valueForKey:@"foo"], nil);
}

- (void)testRecorderUnknownKey
{
    GRKVCRecorder *recorder = [GRKVCRecorder recorderWithRecognizedKey:@"foo"];
    STAssertThrows([recorder valueForKey:@"bar"], nil);
}

- (void)testRecorderRecordsKey
{
    GRKVCRecorder *recorder = [GRKVCRecorder recorderWithRecognizedKey:@"foo"];
    [recorder valueForKey:@"foo"];
    STAssertEqualObjects(recorder.lastAccessedKey, @"foo", nil);
}

- (void)testRecorderValueForKeyReturnsKey
{
    GRKVCRecorder *recorder = [GRKVCRecorder recorderWithRecognizedKey:@"foo"];
    STAssertEqualObjects([recorder valueForKey:@"foo"], @"foo", nil);
}

@end

@implementation GRMustacheContextPrivateTest

- (void)testOneDepthRuntimeForwardsValueForKeyToItsObject
{
    GRKVCRecorder *recorder = [GRKVCRecorder recorderWithRecognizedKey:@"foo"];
    GRMustacheContext *context = [[[GRMustacheContext alloc] init] autorelease];
    context = [context contextByAddingObject:recorder];
    [context contextValueForKey:@"foo" protected:NULL];
    STAssertEqualObjects(recorder.lastAccessedKey, @"foo", nil);
}

- (void)testTwoDepthRuntimeForwardsValueForKeyToTopObjectOnlyIfTopObjectHasKey
{
    GRKVCRecorder *rootRecorder = [GRKVCRecorder recorderWithRecognizedKey:@"root"];
    GRKVCRecorder *topRecorder = [GRKVCRecorder recorderWithRecognizedKey:@"top"];
    GRMustacheContext *context = [[[GRMustacheContext alloc] init] autorelease];
    context = [context contextByAddingObject:rootRecorder];
    context = [context contextByAddingObject:topRecorder];
    STAssertEqualObjects([context contextValueForKey:@"top" protected:NULL], @"top", nil);
    STAssertEqualObjects(topRecorder.lastAccessedKey, @"top", nil);
    STAssertNil(rootRecorder.lastAccessedKey, nil);
}

- (void)testTwoDepthRuntimeForwardsValueForKeyToBothObjectIfTopObjectMisses
{
    GRKVCRecorder *rootRecorder = [GRKVCRecorder recorderWithRecognizedKey:@"root"];
    GRKVCRecorder *topRecorder = [GRKVCRecorder recorderWithRecognizedKey:@"top"];
    GRMustacheContext *context = [[[GRMustacheContext alloc] init] autorelease];
    context = [context contextByAddingObject:rootRecorder];
    context = [context contextByAddingObject:topRecorder];
    STAssertEqualObjects([context contextValueForKey:@"root" protected:NULL], @"root", nil);
    STAssertEqualObjects(topRecorder.lastAccessedKey, @"root", nil);
    STAssertEqualObjects(rootRecorder.lastAccessedKey, @"root", nil);
}

- (void)testTwoDepthRuntimeMissesIfBothObjectMisses
{
    GRKVCRecorder *rootRecorder = [GRKVCRecorder recorderWithRecognizedKey:@"root"];
    GRKVCRecorder *topRecorder = [GRKVCRecorder recorderWithRecognizedKey:@"top"];
    GRMustacheContext *context = [[[GRMustacheContext alloc] init] autorelease];
    context = [context contextByAddingObject:rootRecorder];
    context = [context contextByAddingObject:topRecorder];
    STAssertNil([context contextValueForKey:@"foo" protected:NULL], nil);
    STAssertEqualObjects(topRecorder.lastAccessedKey, @"foo", nil);
    STAssertEqualObjects(rootRecorder.lastAccessedKey, @"foo", nil);
}

- (void)testNilDoesNotStopsExploration
{
    NSDictionary *dictionary = [NSDictionary dictionaryWithObject:@"foo" forKey:@"key"];
    GRMustacheContext *context = [[[GRMustacheContext alloc] init] autorelease];
    context = [context contextByAddingObject:dictionary];
    dictionary = [NSDictionary dictionary];
    context = [context contextByAddingObject:dictionary];
    STAssertEqualObjects([context contextValueForKey:@"key" protected:NULL], @"foo", nil);
}

- (void)testNSNullDoesStopExploration
{
    NSDictionary *dictionary = [NSDictionary dictionaryWithObject:@"foo" forKey:@"key"];
    GRMustacheContext *context = [[[GRMustacheContext alloc] init] autorelease];
    context = [context contextByAddingObject:dictionary];
    dictionary = [NSDictionary dictionaryWithObject:[NSNull null] forKey:@"key"];
    context = [context contextByAddingObject:dictionary];
    STAssertEqualObjects([context contextValueForKey:@"key" protected:NULL], [NSNull null], nil);
}

- (void)testNSNumberWithBoolNODoesStopExploration
{
    NSDictionary *dictionary = [NSDictionary dictionaryWithObject:@"foo" forKey:@"key"];
    GRMustacheContext *context = [[[GRMustacheContext alloc] init] autorelease];
    context = [context contextByAddingObject:dictionary];
    dictionary = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:@"key"];
    context = [context contextByAddingObject:dictionary];
    STAssertEqualObjects([context contextValueForKey:@"key" protected:NULL], [NSNumber numberWithBool:NO], nil);
}

- (void)testOneDepthRuntimeTemplate
{
    NSString *result = [[GRMustacheTemplate templateFromString:@"{{length}}" error:NULL] renderObject:@"foo" error:NULL];
    STAssertEqualObjects(result, @"3", nil);
}

- (void)testTwoDepthRuntimeTemplateWithTopObjectSuccess
{
    NSString *templateString = @"{{#name}}{{length}}{{/name}}";
    id recorder = [GRKVCRecorder recorderWithRecognizedKey:@"name"];
    NSString *result = [[GRMustacheTemplate templateFromString:templateString error:NULL] renderObject:recorder error:NULL];
    STAssertEqualObjects(result, @"4", nil);
}

- (void)testTwoDepthRuntimeTemplateWithTopObjectMiss
{
    NSString *templateString = @"{{#name}}{{name}}{{/name}}";
    NSDictionary *recorder = [NSDictionary dictionaryWithObject:@"foo" forKey:@"name"];
    NSString *result = [[GRMustacheTemplate templateFromString:templateString error:NULL] renderObject:recorder error:NULL];
    STAssertEqualObjects(result, @"foo", nil);
}

- (void)testRuntimeRethrowsNonNSUndefinedKeyException
{
    ThrowingObject *throwingObject = [[[ThrowingObject alloc] init] autorelease];
    GRMustacheContext *context = [[[GRMustacheContext alloc] init] autorelease];
    context = [context contextByAddingObject:throwingObject];
    STAssertThrows([context contextValueForKey:@"NonNSUndefinedKeyException" protected:NULL], nil);
}

- (void)testRuntimeSwallowsNonSelfNSUndefinedKeyException
{
    // This test makes sure users can implement proxy objects
    ThrowingObject *throwingObject = [[[ThrowingObject alloc] init] autorelease];
    GRMustacheContext *context = [[[GRMustacheContext alloc] init] autorelease];
    context = [context contextByAddingObject:throwingObject];
    STAssertNoThrow([context contextValueForKey:@"NonSelfNSUndefinedKeyException" protected:NULL], nil);
}

- (void)testRuntimeSwallowsSelfNSUndefinedKeyException
{
    ThrowingObject *throwingObject = [[[ThrowingObject alloc] init] autorelease];
    GRMustacheContext *context = [[[GRMustacheContext alloc] init] autorelease];
    context = [context contextByAddingObject:throwingObject];
    STAssertNoThrow([context contextValueForKey:@"SelfNSUndefinedKeyException" protected:NULL], nil);
}

- (void)testContextByAddingProtectedObject
{
    GRMustacheContext *context = [[[GRMustacheContext alloc] init] autorelease];
    context = [context contextByAddingProtectedObject:@{ @"safe": @"important" }];
    STAssertEqualObjects([context contextValueForKey:@"safe" protected:NULL], @"important", @"");
    context = [context contextByAddingObject:@{ @"safe": @"hack", @"fragile": @"A" }];
    STAssertEqualObjects([context contextValueForKey:@"safe" protected:NULL], @"important", @"");
    STAssertEqualObjects([context contextValueForKey:@"fragile" protected:NULL], @"A", @"");
    context = [context contextByAddingObject:@{ @"safe": @"hack", @"fragile": @"B" }];
    STAssertEqualObjects([context contextValueForKey:@"safe" protected:NULL], @"important", @"");
    STAssertEqualObjects([context contextValueForKey:@"fragile" protected:NULL], @"B", @"");
}

@end
