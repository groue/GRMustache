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

#define GRMUSTACHE_VERSION_MAX_ALLOWED GRMUSTACHE_VERSION_7_2
#import "GRMustachePublicAPITest.h"


// =============================================================================
#pragma mark - GRMustacheImplicitTrueRenderingObject

@interface GRMustacheImplicitTrueRenderingObject : NSObject<GRMustacheRendering>
@end

@implementation GRMustacheImplicitTrueRenderingObject

- (NSString *)renderForMustacheTag:(GRMustacheTag *)tag context:(GRMustacheContext *)context HTMLSafe:(BOOL *)HTMLSafe error:(NSError **)error
{
    switch (tag.type) {
        case GRMustacheTagTypeVariable:
            return @"variable";
            break;
            
        case GRMustacheTagTypeSection:
            return @"section";
            break;
    }
}

@end


// =============================================================================
#pragma mark - GRMustacheExplicitTrueRenderingObject

@interface GRMustacheExplicitTrueRenderingObject : NSObject<GRMustacheRendering>
@end

@implementation GRMustacheExplicitTrueRenderingObject

- (BOOL)mustacheBoolValue
{
    return YES;
}

- (NSString *)renderForMustacheTag:(GRMustacheTag *)tag context:(GRMustacheContext *)context HTMLSafe:(BOOL *)HTMLSafe error:(NSError **)error
{
    switch (tag.type) {
        case GRMustacheTagTypeVariable:
            return @"variable";
            break;
            
        case GRMustacheTagTypeSection:
            return @"section";
            break;
    }
}

@end


// =============================================================================
#pragma mark - GRMustacheExplicitFalseRenderingObject

@interface GRMustacheExplicitFalseRenderingObject : NSObject<GRMustacheRendering>
@end

@implementation GRMustacheExplicitFalseRenderingObject

- (BOOL)mustacheBoolValue
{
    return NO;
}

- (NSString *)renderForMustacheTag:(GRMustacheTag *)tag context:(GRMustacheContext *)context HTMLSafe:(BOOL *)HTMLSafe error:(NSError **)error
{
    switch (tag.type) {
        case GRMustacheTagTypeVariable:
            return @"variable";
            break;
            
        case GRMustacheTagTypeSection:
            return @"section";
            break;
    }
}

@end


// =============================================================================
#pragma mark - GRMustacheRenderingObject_7_2_Test

@interface GRMustacheRenderingObject_7_2_Test : GRMustachePublicAPITest

@end

@implementation GRMustacheRenderingObject_7_2_Test

- (void)testImplicitTrueRenderingObjects
{
    id object = [[[GRMustacheImplicitTrueRenderingObject alloc] init] autorelease];
    
    {
        NSString *rendering = [GRMustacheTemplate renderObject:@{ @"object": object }
                                                    fromString:@"<{{ object }}>"
                                                         error:NULL];
        XCTAssertEqualObjects(rendering, @"<variable>");
    }
    {
        NSString *rendering = [GRMustacheTemplate renderObject:@{ @"object": object }
                                                    fromString:@"<{{# object }}...{{/ }}>"
                                                         error:NULL];
        XCTAssertEqualObjects(rendering, @"<section>");
    }
    {
        NSString *rendering = [GRMustacheTemplate renderObject:@{ @"object": object }
                                                    fromString:@"<{{^ object }}...{{/ }}>"
                                                         error:NULL];
        XCTAssertEqualObjects(rendering, @"<>");
    }
}

- (void)testImplicitTrueRenderingObjectsWithBlocks
{
    id object = [GRMustacheRendering renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
        switch (tag.type) {
            case GRMustacheTagTypeVariable:
                return @"variable";
                break;
                
            case GRMustacheTagTypeSection:
                return @"section";
                break;
        }
    }];
    
    {
        NSString *rendering = [GRMustacheTemplate renderObject:@{ @"object": object }
                                                    fromString:@"<{{ object }}>"
                                                         error:NULL];
        XCTAssertEqualObjects(rendering, @"<variable>");
    }
    {
        NSString *rendering = [GRMustacheTemplate renderObject:@{ @"object": object }
                                                    fromString:@"<{{# object }}...{{/ }}>"
                                                         error:NULL];
        XCTAssertEqualObjects(rendering, @"<section>");
    }
    {
        NSString *rendering = [GRMustacheTemplate renderObject:@{ @"object": object }
                                                    fromString:@"<{{^ object }}...{{/ }}>"
                                                         error:NULL];
        XCTAssertEqualObjects(rendering, @"<>");
    }
}

- (void)testExplicitTrueRenderingObjects
{
    id object = [[[GRMustacheExplicitTrueRenderingObject alloc] init] autorelease];
    
    {
        NSString *rendering = [GRMustacheTemplate renderObject:@{ @"object": object }
                                                    fromString:@"<{{ object }}>"
                                                         error:NULL];
        XCTAssertEqualObjects(rendering, @"<variable>");
    }
    {
        NSString *rendering = [GRMustacheTemplate renderObject:@{ @"object": object }
                                                    fromString:@"<{{# object }}...{{/ }}>"
                                                         error:NULL];
        XCTAssertEqualObjects(rendering, @"<section>");
    }
    {
        NSString *rendering = [GRMustacheTemplate renderObject:@{ @"object": object }
                                                    fromString:@"<{{^ object }}...{{/ }}>"
                                                         error:NULL];
        XCTAssertEqualObjects(rendering, @"<>");
    }
}

- (void)testExplicitFalseRenderingObjects
{
    id object = [[[GRMustacheExplicitFalseRenderingObject alloc] init] autorelease];
    
    {
        NSString *rendering = [GRMustacheTemplate renderObject:@{ @"object": object }
                                                    fromString:@"<{{ object }}>"
                                                         error:NULL];
        XCTAssertEqualObjects(rendering, @"<variable>");
    }
    {
        NSString *rendering = [GRMustacheTemplate renderObject:@{ @"object": object }
                                                    fromString:@"<{{# object }}...{{/ }}>"
                                                         error:NULL];
        XCTAssertEqualObjects(rendering, @"<>");
    }
    {
        NSString *rendering = [GRMustacheTemplate renderObject:@{ @"object": object }
                                                    fromString:@"<{{^ object }}...{{/ }}>"
                                                         error:NULL];
        XCTAssertEqualObjects(rendering, @"<section>");
    }
}

- (void)testArrayOfRenderingObjectsInSectionTagDoesNotNeedExplicitInvocation
{
    id object1 = [GRMustacheRendering renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
        NSString *tagRendering = [tag renderContentWithContext:context HTMLSafe:HTMLSafe error:error];
        return [NSString stringWithFormat:@"[1:%@]", tagRendering];
    }];
    id object2 = [GRMustacheRendering renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError **error) {
        NSString *tagRendering = [tag renderContentWithContext:context HTMLSafe:HTMLSafe error:error];
        return [NSString stringWithFormat:@"[2:%@]", tagRendering];
    }];
    
    id items = @{@"items": @[object1, object2, @YES, @NO] };
    NSString *rendering = [[GRMustacheTemplate templateFromString:@"{{#items}}---{{/items}},{{#items}}{{#.}}---{{/.}}{{/items}}" error:NULL] renderObject:items error:NULL];
    XCTAssertEqualObjects(rendering, @"[1:---][2:---]------,[1:---][2:---]---", @"");
}

@end
