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

#define GRMUSTACHE_VERSION_MAX_ALLOWED GRMUSTACHE_VERSION_6_0
#import "GRMustachePublicAPITest.h"

@interface GRMustacheFoundationCollectionTest : GRMustachePublicAPITest
@end

@implementation GRMustacheFoundationCollectionTest

- (void)testNSArray
{
    id data = @{ @"collection": @[ @{@"key" : @"value"} ] };
    
    {
        // Content of NSArray should be iterated
        NSString *rendering = [[GRMustacheTemplate templateFromString:@"{{#collection}}{{key}}{{/collection}}" error:NULL] renderObject:data error:NULL];
        STAssertEqualObjects(rendering, @"value", @"");
    }
    
    {
        // Content of NSArray should not be iterated via NSArray's implementation of valueForKey:
        NSString *rendering = [[GRMustacheTemplate templateFromString:@"{{#collection.key}}{{.}}{{/collection.key}}" error:NULL] renderObject:data error:NULL];
        STAssertEqualObjects(rendering, @"", @"");
    }
    
    {
        // [NSArray count] should be accessible (test for method returning a scalar)
        NSString *rendering = [[GRMustacheTemplate templateFromString:@"{{collection.count}}" error:NULL] renderObject:data error:NULL];
        STAssertEqualObjects(rendering, @"1", @"");
    }
    
    {
        // [NSArray lastObject] should be accessible (test for method returning an object)
        NSString *rendering = [[GRMustacheTemplate templateFromString:@"{{collection.lastObject.key}}" error:NULL] renderObject:data error:NULL];
        STAssertEqualObjects(rendering, @"value", @"");
    }
}

- (void)testNSSet
{
    id data = @{ @"collection": [NSSet setWithObject:@{@"key" : @"value"}] };
    
    {
        // Content of NSSet should be iterated
        NSString *rendering = [[GRMustacheTemplate templateFromString:@"{{#collection}}{{key}}{{/collection}}" error:NULL] renderObject:data error:NULL];
        STAssertEqualObjects(rendering, @"value", @"");
    }
    
    {
        // Content of NSSet should not be iterated via NSSet's implementation of valueForKey:
        NSString *rendering = [[GRMustacheTemplate templateFromString:@"{{#collection.key}}{{.}}{{/collection.key}}" error:NULL] renderObject:data error:NULL];
        STAssertEqualObjects(rendering, @"", @"");
    }
    
    {
        // [NSSet count] should be accessible (test for method returning a scalar)
        NSString *rendering = [[GRMustacheTemplate templateFromString:@"{{collection.count}}" error:NULL] renderObject:data error:NULL];
        STAssertEqualObjects(rendering, @"1", @"");
    }
    
    {
        // [NSSet anyObject] should be accessible (test for method returning an object)
        NSString *rendering = [[GRMustacheTemplate templateFromString:@"{{collection.anyObject.key}}" error:NULL] renderObject:data error:NULL];
        STAssertEqualObjects(rendering, @"value", @"");
    }
}

- (void)testNSOrderedSet
{
    id data = @{ @"collection": [NSOrderedSet orderedSetWithObject:@{@"key" : @"value"}] };
    
    {
        // Content of NSOrderedSet should be iterated
        NSString *rendering = [[GRMustacheTemplate templateFromString:@"{{#collection}}{{key}}{{/collection}}" error:NULL] renderObject:data error:NULL];
        STAssertEqualObjects(rendering, @"value", @"");
    }
    
    {
        // Content of NSOrderedSet should not be iterated via NSOrderedSet's implementation of valueForKey:
        NSString *rendering = [[GRMustacheTemplate templateFromString:@"{{#collection.key}}{{.}}{{/collection.key}}" error:NULL] renderObject:data error:NULL];
        STAssertEqualObjects(rendering, @"", @"");
    }
    
    {
        // [NSOrderedSet count] should be accessible (test for method returning a scalar)
        NSString *rendering = [[GRMustacheTemplate templateFromString:@"{{collection.count}}" error:NULL] renderObject:data error:NULL];
        STAssertEqualObjects(rendering, @"1", @"");
    }
    
    {
        // [NSOrderedSet firstObject] should be accessible (test for method returning an object)
        NSString *rendering = [[GRMustacheTemplate templateFromString:@"{{collection.firstObject.key}}" error:NULL] renderObject:data error:NULL];
        STAssertEqualObjects(rendering, @"value", @"");
    }
}

@end
