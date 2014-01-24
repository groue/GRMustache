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

#define GRMUSTACHE_VERSION_MAX_ALLOWED GRMUSTACHE_VERSION_6_8
#import "GRMustachePublicAPITest.h"

@interface GRMustacheKeyedSubscriptingClass : NSObject
@property (nonatomic, retain) NSString *property;
@property (nonatomic, retain) NSMutableDictionary *dictionary;
@end

@implementation GRMustacheKeyedSubscriptingClass

- (void)dealloc
{
    self.property = nil;
    self.dictionary = nil;
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self) {
        self.dictionary = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)setObject:(id)object forKeyedSubscript:(id<NSCopying>)key
{
    self.dictionary[key] = object;
}

- (id)objectForKeyedSubscript:(id)key
{
    return self.dictionary[key];
}

@end

@interface GRMustacheKeyedSubscriptingTest : GRMustachePublicAPITest
@end

@implementation GRMustacheKeyedSubscriptingTest

- (void)testKeyedSubscriptingHidesProperties
{
    GRMustacheKeyedSubscriptingClass *object = [[[GRMustacheKeyedSubscriptingClass alloc] init] autorelease];
    object.property = @"foo";
    STAssertEqualObjects([object valueForKey:@"property"], @"foo", nil);
    NSString *rendering = [GRMustacheTemplate renderObject:object fromString:@"<{{property}}>" error:NULL];
    STAssertEqualObjects(rendering, @"<>", nil);
}

- (void)testKeyedSubscripting
{
    id object = [[[GRMustacheKeyedSubscriptingClass alloc] init] autorelease];
    object[@"foo"] = @"bar";
    STAssertEqualObjects(object[@"foo"], @"bar", nil);
    NSString *rendering = [GRMustacheTemplate renderObject:object fromString:@"<{{foo}}>" error:NULL];
    STAssertEqualObjects(rendering, @"<bar>", nil);
}

@end
