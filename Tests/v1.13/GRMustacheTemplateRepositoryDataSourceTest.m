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

#import "GRMustacheTemplateRepositoryDataSourceTest.h"

@interface GRMustacheTemplateRepositoryTestDataSource : NSObject<GRMustacheTemplateRepositoryDataSource>
@property (nonatomic) NSUInteger templateIDForNameCount;
@property (nonatomic) NSUInteger templateStringForTemplateIDCount;
@end

@implementation GRMustacheTemplateRepositoryTestDataSource
@synthesize templateIDForNameCount=_templateIDForNameCount;
@synthesize templateStringForTemplateIDCount=_templateStringForTemplateIDCount;

- (id)templateRepository:(GRMustacheTemplateRepository *)templateRepository templateIDForName:(NSString *)name relativeToTemplateID:(id)templateID
{
    _templateIDForNameCount++;
    return name;
}

- (NSString *)templateRepository:(GRMustacheTemplateRepository *)templateRepository templateStringForTemplateID:(id)templateID error:(NSError **)outError
{
    _templateStringForTemplateIDCount++;
    if ([templateID isEqualToString:@"not found"]) {
        return nil;
    }
    if ([templateID isEqualToString:@"error"]) {
        if (outError != NULL) {
            *outError = [NSError errorWithDomain:@"GRMustacheTemplateRepositoryTestDataSource" code:0 userInfo:nil];
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
    
    result = [[repository templateForName:@"foo" error:NULL] render];
    STAssertEqualObjects(result, @"foo", @"");
    STAssertEquals(dataSource.templateIDForNameCount, (NSUInteger)1, @"");
    STAssertEquals(dataSource.templateStringForTemplateIDCount, (NSUInteger)1, @"");
    
    result = [[repository templateFromString:@"{{>foo}}" error:NULL] render];
    STAssertEqualObjects(result, @"foo", @"");
    STAssertEquals(dataSource.templateIDForNameCount, (NSUInteger)2, @"");
    STAssertEquals(dataSource.templateStringForTemplateIDCount, (NSUInteger)1, @"");
    
    [repository templateFromString:@"{{> not found }}" error:&error];
    STAssertEqualObjects(error.domain, GRMustacheErrorDomain, @"");
    STAssertEquals((NSInteger)error.code, (NSInteger)GRMustacheErrorCodeTemplateNotFound, @"");
    
    [repository templateFromString:@"{{> error }}" error:&error];
    STAssertEqualObjects(error.domain, @"GRMustacheTemplateRepositoryTestDataSource", @"");
}

@end
