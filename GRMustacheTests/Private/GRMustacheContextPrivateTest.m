// The MIT License
// 
// Copyright (c) 2014 Gwendal Roué
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
#import "NSObject+GRMustacheKeyValueCoding_private.h"

@interface GRMustacheContextPrivateTest : GRMustachePrivateAPITest
@end


@interface GRKVCRecorder: NSObject<GRMustacheKeyValueCoding> {
    NSString *lastAccessedKey;
    NSArray *keys;
}
@property (nonatomic, retain) NSString *lastAccessedKey;
@property (nonatomic, retain) NSArray *keys;
@end

@implementation GRKVCRecorder
@synthesize lastAccessedKey;
@synthesize keys;

- (BOOL)hasValue:(id *)value forMustacheKey:(NSString *)key
{
    *value = [self valueForKey:key];
    return YES;
}

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

@interface ThrowingObjectFromValueForKey: NSObject<GRMustacheKeyValueCoding>
@end

@implementation ThrowingObjectFromValueForKey

- (BOOL)hasValue:(id *)value forMustacheKey:(NSString *)key
{
    *value = [self valueForKey:key];
    return YES;
}

- (id)valueForKey:(NSString *)key
{
    if ([key isEqualToString:@"KnownKey"]) {
        return @"KnownValue";
    }
    if ([key isEqualToString:@"NonNSUndefinedKeyException"]) {
        NSAssert(NO, @"");
    }
    if ([key isEqualToString:@"NonSelfNSUndefinedKeyException"]) {
        return [@"" valueForKey:@"foo"];
    }
    return [super valueForKey:key];
}

@end

@interface ThrowingObjectFromValueForUndefinedKey: NSObject<GRMustacheKeyValueCoding>
@end

@implementation ThrowingObjectFromValueForUndefinedKey

- (BOOL)hasValue:(id *)value forMustacheKey:(NSString *)key
{
    *value = [self valueForKey:key];
    return YES;
}

- (id)valueForUndefinedKey:(NSString *)key
{
    if ([key isEqualToString:@"KnownKey"]) {
        return @"KnownValue";
    }
    if ([key isEqualToString:@"NonNSUndefinedKeyException"]) {
        NSAssert(NO, @"");
    }
    if ([key isEqualToString:@"NonSelfNSUndefinedKeyException"]) {
        return [@"" valueForKey:@"foo"];
    }
    return [super valueForUndefinedKey:key];
}

@end


@interface GRKVCRecorderTest: XCTestCase
@end

@implementation GRKVCRecorderTest

- (void)testRecorderKnownKey
{
    GRKVCRecorder *recorder = [GRKVCRecorder recorderWithRecognizedKey:@"foo"];
    XCTAssertNoThrow([recorder valueForKey:@"foo"]);
}

- (void)testRecorderUnknownKey
{
    GRKVCRecorder *recorder = [GRKVCRecorder recorderWithRecognizedKey:@"foo"];
    XCTAssertThrows([recorder valueForKey:@"bar"]);
}

- (void)testRecorderRecordsKey
{
    GRKVCRecorder *recorder = [GRKVCRecorder recorderWithRecognizedKey:@"foo"];
    [recorder valueForKey:@"foo"];
    XCTAssertEqualObjects(recorder.lastAccessedKey, @"foo");
}

- (void)testRecorderValueForKeyReturnsKey
{
    GRKVCRecorder *recorder = [GRKVCRecorder recorderWithRecognizedKey:@"foo"];
    XCTAssertEqualObjects([recorder valueForKey:@"foo"], @"foo");
}

@end

@implementation GRMustacheContextPrivateTest

- (void)testOneDepthRuntimeForwardsValueForKeyToItsObject
{
    GRKVCRecorder *recorder = [GRKVCRecorder recorderWithRecognizedKey:@"foo"];
    GRMustacheContext *context = [[[GRMustacheContext alloc] init] autorelease];
    context = [context contextByAddingObject:recorder];
    [context valueForMustacheKey:@"foo" protected:NULL];
    XCTAssertEqualObjects(recorder.lastAccessedKey, @"foo");
}

- (void)testTwoDepthRuntimeForwardsValueForKeyToTopObjectOnlyIfTopObjectHasKey
{
    GRKVCRecorder *rootRecorder = [GRKVCRecorder recorderWithRecognizedKey:@"root"];
    GRKVCRecorder *topRecorder = [GRKVCRecorder recorderWithRecognizedKey:@"top"];
    GRMustacheContext *context = [[[GRMustacheContext alloc] init] autorelease];
    context = [context contextByAddingObject:rootRecorder];
    context = [context contextByAddingObject:topRecorder];
    XCTAssertEqualObjects([context valueForMustacheKey:@"top" protected:NULL], @"top");
    XCTAssertEqualObjects(topRecorder.lastAccessedKey, @"top");
    XCTAssertNil(rootRecorder.lastAccessedKey);
}

- (void)testTwoDepthRuntimeForwardsValueForKeyToBothObjectIfTopObjectMisses
{
    GRKVCRecorder *rootRecorder = [GRKVCRecorder recorderWithRecognizedKey:@"root"];
    GRKVCRecorder *topRecorder = [GRKVCRecorder recorderWithRecognizedKey:@"top"];
    GRMustacheContext *context = [[[GRMustacheContext alloc] init] autorelease];
    context = [context contextByAddingObject:rootRecorder];
    context = [context contextByAddingObject:topRecorder];
    XCTAssertEqualObjects([context valueForMustacheKey:@"root" protected:NULL], @"root");
    XCTAssertEqualObjects(topRecorder.lastAccessedKey, @"root");
    XCTAssertEqualObjects(rootRecorder.lastAccessedKey, @"root");
}

- (void)testTwoDepthRuntimeMissesIfBothObjectMisses
{
    GRKVCRecorder *rootRecorder = [GRKVCRecorder recorderWithRecognizedKey:@"root"];
    GRKVCRecorder *topRecorder = [GRKVCRecorder recorderWithRecognizedKey:@"top"];
    GRMustacheContext *context = [[[GRMustacheContext alloc] init] autorelease];
    context = [context contextByAddingObject:rootRecorder];
    context = [context contextByAddingObject:topRecorder];
    XCTAssertNil([context valueForMustacheKey:@"foo" protected:NULL]);
    XCTAssertEqualObjects(topRecorder.lastAccessedKey, @"foo");
    XCTAssertEqualObjects(rootRecorder.lastAccessedKey, @"foo");
}

- (void)testNilDoesNotStopsExploration
{
    NSDictionary *dictionary = [NSDictionary dictionaryWithObject:@"foo" forKey:@"key"];
    GRMustacheContext *context = [[[GRMustacheContext alloc] init] autorelease];
    context = [context contextByAddingObject:dictionary];
    dictionary = [NSDictionary dictionary];
    context = [context contextByAddingObject:dictionary];
    XCTAssertEqualObjects([context valueForMustacheKey:@"key" protected:NULL], @"foo");
}

- (void)testNSNullDoesStopExploration
{
    NSDictionary *dictionary = [NSDictionary dictionaryWithObject:@"foo" forKey:@"key"];
    GRMustacheContext *context = [[[GRMustacheContext alloc] init] autorelease];
    context = [context contextByAddingObject:dictionary];
    dictionary = [NSDictionary dictionaryWithObject:[NSNull null] forKey:@"key"];
    context = [context contextByAddingObject:dictionary];
    XCTAssertEqualObjects([context valueForMustacheKey:@"key" protected:NULL], [NSNull null]);
}

- (void)testNSNumberWithBoolNODoesStopExploration
{
    NSDictionary *dictionary = [NSDictionary dictionaryWithObject:@"foo" forKey:@"key"];
    GRMustacheContext *context = [[[GRMustacheContext alloc] init] autorelease];
    context = [context contextByAddingObject:dictionary];
    dictionary = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:@"key"];
    context = [context contextByAddingObject:dictionary];
    XCTAssertEqualObjects([context valueForMustacheKey:@"key" protected:NULL], [NSNumber numberWithBool:NO]);
}

- (void)testOneDepthRuntimeTemplate
{
    NSString *result = [[GRMustacheTemplate templateFromString:@"{{length}}" error:NULL] renderObject:@"foo" error:NULL];
    XCTAssertEqualObjects(result, @"3");
}

- (void)testTwoDepthRuntimeTemplateWithTopObjectSuccess
{
    NSString *templateString = @"{{#name}}{{length}}{{/name}}";
    id recorder = [GRKVCRecorder recorderWithRecognizedKey:@"name"];
    NSString *result = [[GRMustacheTemplate templateFromString:templateString error:NULL] renderObject:recorder error:NULL];
    XCTAssertEqualObjects(result, @"4");
}

- (void)testTwoDepthRuntimeTemplateWithTopObjectMiss
{
    NSString *templateString = @"{{#name}}{{name}}{{/name}}";
    NSDictionary *recorder = [NSDictionary dictionaryWithObject:@"foo" forKey:@"name"];
    NSString *result = [[GRMustacheTemplate templateFromString:templateString error:NULL] renderObject:recorder error:NULL];
    XCTAssertEqualObjects(result, @"foo");
}

- (void)testRuntimeDoNotThrowForKnownKey
{
    {
        id throwingObject = [[[ThrowingObjectFromValueForKey alloc] init] autorelease];
        id value = [throwingObject valueForKey:@"KnownKey"];
        XCTAssertEqualObjects(value, @"KnownValue");
        
        GRMustacheContext *context = [[[GRMustacheContext alloc] init] autorelease];
        context = [context contextByAddingObject:throwingObject];
        value = [context valueForMustacheKey:@"KnownKey" protected:NULL];
        XCTAssertEqualObjects(value, @"KnownValue");
    }
    {
        id throwingObject = [[[ThrowingObjectFromValueForUndefinedKey alloc] init] autorelease];
        id value = [throwingObject valueForKey:@"KnownKey"];
        XCTAssertEqualObjects(value, @"KnownValue");
        
        GRMustacheContext *context = [[[GRMustacheContext alloc] init] autorelease];
        context = [context contextByAddingObject:throwingObject];
        value = [context valueForMustacheKey:@"KnownKey" protected:NULL];
        XCTAssertEqualObjects(value, @"KnownValue");
    }
}

- (void)testRuntimeRethrowsNonNSUndefinedKeyException
{
    {
        id throwingObject = [[[ThrowingObjectFromValueForKey alloc] init] autorelease];
        XCTAssertThrows([throwingObject valueForKey:@"NonNSUndefinedKeyException"]);
        
        GRMustacheContext *context = [[[GRMustacheContext alloc] init] autorelease];
        context = [context contextByAddingObject:throwingObject];
        XCTAssertThrows([context valueForMustacheKey:@"NonNSUndefinedKeyException" protected:NULL]);
    }
    {
        id throwingObject = [[[ThrowingObjectFromValueForUndefinedKey alloc] init] autorelease];
        XCTAssertThrows([throwingObject valueForKey:@"NonNSUndefinedKeyException"]);
        
        GRMustacheContext *context = [[[GRMustacheContext alloc] init] autorelease];
        context = [context contextByAddingObject:throwingObject];
        XCTAssertThrows([context valueForMustacheKey:@"NonNSUndefinedKeyException" protected:NULL]);
    }
}

- (void)testRuntimeSwallowsNonSelfNSUndefinedKeyException
{
    {
        id throwingObject = [[[ThrowingObjectFromValueForKey alloc] init] autorelease];
        XCTAssertThrows([throwingObject valueForKey:@"NonSelfNSUndefinedKeyException"]);
        
        GRMustacheContext *context = [[[GRMustacheContext alloc] init] autorelease];
        context = [context contextByAddingObject:throwingObject];
        XCTAssertNoThrow([context valueForMustacheKey:@"NonSelfNSUndefinedKeyException" protected:NULL]);
    }
    {
        id throwingObject = [[[ThrowingObjectFromValueForUndefinedKey alloc] init] autorelease];
        XCTAssertThrows([throwingObject valueForKey:@"NonSelfNSUndefinedKeyException"]);
        
        GRMustacheContext *context = [[[GRMustacheContext alloc] init] autorelease];
        context = [context contextByAddingObject:throwingObject];
        XCTAssertNoThrow([context valueForMustacheKey:@"NonSelfNSUndefinedKeyException" protected:NULL]);
    }
}

- (void)testRuntimeSwallowsSelfNSUndefinedKeyException
{
    {
        id throwingObject = [[[ThrowingObjectFromValueForKey alloc] init] autorelease];
        XCTAssertThrows([throwingObject valueForKey:@"SelfNSUndefinedKeyException"]);
        
        GRMustacheContext *context = [[[GRMustacheContext alloc] init] autorelease];
        context = [context contextByAddingObject:throwingObject];
        XCTAssertNoThrow([context valueForMustacheKey:@"SelfNSUndefinedKeyException" protected:NULL]);
    }
    {
        id throwingObject = [[[ThrowingObjectFromValueForUndefinedKey alloc] init] autorelease];
        XCTAssertThrows([throwingObject valueForKey:@"SelfNSUndefinedKeyException"]);
        
        GRMustacheContext *context = [[[GRMustacheContext alloc] init] autorelease];
        context = [context contextByAddingObject:throwingObject];
        XCTAssertNoThrow([context valueForMustacheKey:@"SelfNSUndefinedKeyException" protected:NULL]);
    }
}

- (void)testContextByAddingProtectedObject
{
    GRMustacheContext *context = [[[GRMustacheContext alloc] init] autorelease];
    context = [context contextByAddingProtectedObject:@{ @"safe": @"important" }];
    XCTAssertEqualObjects([context valueForMustacheKey:@"safe" protected:NULL], @"important", @"");
    context = [context contextByAddingObject:@{ @"safe": @"hack", @"fragile": @"A" }];
    XCTAssertEqualObjects([context valueForMustacheKey:@"safe" protected:NULL], @"important", @"");
    XCTAssertEqualObjects([context valueForMustacheKey:@"fragile" protected:NULL], @"A", @"");
    context = [context contextByAddingObject:@{ @"safe": @"hack", @"fragile": @"B" }];
    XCTAssertEqualObjects([context valueForMustacheKey:@"safe" protected:NULL], @"important", @"");
    XCTAssertEqualObjects([context valueForMustacheKey:@"fragile" protected:NULL], @"B", @"");
}

@end
