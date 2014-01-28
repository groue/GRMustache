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

#define GRMUSTACHE_VERSION_MAX_ALLOWED GRMUSTACHE_VERSION_6_9
#import "GRMustachePublicAPITest.h"

@interface GRMustacheKeyedSubscriptingClass : NSObject {
    NSMutableDictionary *_dictionary;
}
@property (nonatomic, retain) NSMutableDictionary *dictionary;
@end

@implementation GRMustacheKeyedSubscriptingClass
@synthesize dictionary=_dictionary;

- (void)dealloc
{
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

- (id)valueForKey:(NSString *)key
{
    return @"value";
}

- (void)setObject:(id)object forKeyedSubscript:(id<NSCopying>)key
{
    [self.dictionary setObject:object forKey:key];
}

- (id)objectForKeyedSubscript:(id)key
{
    return [self.dictionary objectForKey:key];
}

@end

@interface GRMustacheKeyedSubscriptingTest : GRMustachePublicAPITest
@end

@implementation GRMustacheKeyedSubscriptingTest

- (void)testKeyedSubscripting
{
    GRMustacheKeyedSubscriptingClass *object = [[[GRMustacheKeyedSubscriptingClass alloc] init] autorelease];
    NSString *key = @"foo";
    NSString *value = @"value";
    [object setObject:value forKeyedSubscript:key];
    
    STAssertEqualObjects([object objectForKeyedSubscript:key], value, nil);
    STAssertEqualObjects(([GRMustacheTemplate renderObject:object fromString:[NSString stringWithFormat:@"{{%@}}", key] error:NULL]), value, nil);
}

- (void)testKeyedSubscriptingOverridesValueForKey
{
    GRMustacheKeyedSubscriptingClass *object = [[[GRMustacheKeyedSubscriptingClass alloc] init] autorelease];
    NSString *key = @"foo";
    NSString *value = @"value";
    
    // Empty rendering for key `foo` despite [object valueForKey:@"foo"] is not empty
    STAssertEqualObjects([object valueForKey:key], value, nil);
    STAssertEqualObjects(([GRMustacheTemplate renderObject:object fromString:[NSString stringWithFormat:@"{{%@}}", key] error:NULL]), @"", nil);
}

@end
