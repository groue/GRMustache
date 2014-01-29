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

@interface GRMustacheTemplateRepositoryDataSourceTest : GRMustachePublicAPITest
@end

@interface GRMustacheTemplateRepositoryTestDataSource : NSObject<GRMustacheTemplateRepositoryDataSource> {
    NSUInteger _templateIDForNameCount;
    NSUInteger _templateStringForTemplateIDCount;
}
@property (nonatomic) NSUInteger templateIDForNameCount;
@property (nonatomic) NSUInteger templateStringForTemplateIDCount;
@end

@implementation GRMustacheTemplateRepositoryTestDataSource
@synthesize templateIDForNameCount=_templateIDForNameCount;
@synthesize templateStringForTemplateIDCount=_templateStringForTemplateIDCount;

- (id)templateRepository:(GRMustacheTemplateRepository *)templateRepository templateIDForName:(NSString *)name relativeToTemplateID:(id)baseTemplateID
{
    _templateIDForNameCount++;
    return name;
}

- (NSString *)templateRepository:(GRMustacheTemplateRepository *)templateRepository templateStringForTemplateID:(id)templateID error:(NSError **)error
{
    _templateStringForTemplateIDCount++;
    if ([templateID isEqualToString:@"not_found"]) {
        return nil;
    }
    if ([templateID isEqualToString:@"error"]) {
        if (error != NULL) {
            *error = [NSError errorWithDomain:@"GRMustacheTemplateRepositoryTestDataSource" code:0 userInfo:nil];
        }
        return nil;
    }
    return templateID;
}

@end

@implementation GRMustacheTemplateRepositoryDataSourceTest

- (void)testTemplateRepositoryDataSource
{
    NSString *result;
    NSError *error;
    GRMustacheTemplateRepository *repository = [GRMustacheTemplateRepository templateRepository];
    GRMustacheTemplateRepositoryTestDataSource *dataSource = [[[GRMustacheTemplateRepositoryTestDataSource alloc] init] autorelease];
    repository.dataSource = dataSource;
    
    STAssertEquals(dataSource.templateIDForNameCount, (NSUInteger)0, @"");
    STAssertEquals(dataSource.templateStringForTemplateIDCount, (NSUInteger)0, @"");
    
    result = [[repository templateNamed:@"foo" error:NULL] renderObject:nil error:NULL];
    STAssertEqualObjects(result, @"foo", @"");
    STAssertEquals(dataSource.templateIDForNameCount, (NSUInteger)1, @"");
    STAssertEquals(dataSource.templateStringForTemplateIDCount, (NSUInteger)1, @"");
    
    result = [[repository templateFromString:@"{{>foo}}" error:NULL] renderObject:nil error:NULL];
    STAssertEqualObjects(result, @"foo", @"");
    STAssertEquals(dataSource.templateIDForNameCount, (NSUInteger)2, @"");
    STAssertEquals(dataSource.templateStringForTemplateIDCount, (NSUInteger)1, @"");
    
    [repository templateFromString:@"{{> not_found }}" error:&error];
    STAssertEqualObjects(error.domain, GRMustacheErrorDomain, @"");
    STAssertEquals((NSInteger)error.code, (NSInteger)GRMustacheErrorCodeTemplateNotFound, @"");
    
    [repository templateFromString:@"{{> error }}" error:&error];
    STAssertEqualObjects(error.domain, @"GRMustacheTemplateRepositoryTestDataSource", @"");
}

@end
