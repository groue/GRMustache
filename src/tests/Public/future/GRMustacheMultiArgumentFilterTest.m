#import "GRMustachePublicAPITest.h"

@interface GRMustacheMultiArgumentFilterTest : GRMustachePublicAPITest

@end

@implementation GRMustacheMultiArgumentFilterTest

- (void)testMultiArgumentsFiltersCanAccessAllArguments
{
    GRMustacheFilter *joinFilter = [GRMustacheFilter multiArgumentsFilterWithBlock:^id(NSArray *arguments) {
        return [[arguments valueForKey:@"description"] componentsJoinedByString:@","];
    }];
    
    id data = @{ @"a": @"a", @"b": @"b", @"c": @"c" };
    id filters = @{ @"join": joinFilter };
    NSString *rendering = [GRMustacheTemplate renderObject:data withFilters:filters fromString:@"{{join(a,b)}} {{join(a,b,c)}}" error:NULL];
    STAssertEqualObjects(rendering, @"a,b a,b,c", @"");
}

- (void)testMultiArgumentsFiltersHaveNSNullArgumentForNilInput
{
    __block NSUInteger NSNullCount = 0;
    GRMustacheFilter *filter = [GRMustacheFilter multiArgumentsFilterWithBlock:^id(NSArray *arguments) {
        for (id argument in arguments) {
            if (argument == [NSNull null]) {
                ++NSNullCount;
            }
        }
        return nil;
    }];
    
    id data = @{ };
    id filters = @{ @"f": filter };
    [GRMustacheTemplate renderObject:data withFilters:filters fromString:@"{{f(a,b,c)}}" error:NULL];
    STAssertEquals(NSNullCount, (NSUInteger)3, @"");
}

- (void)testMultiArgumentsFiltersCanBeRootOfScopedExpression
{
    GRMustacheFilter *filter = [GRMustacheFilter multiArgumentsFilterWithBlock:^id(NSArray *arguments) {
        return @{@"foo": @"bar"};
    }];
    
    id data = @{ };
    id filters = @{ @"f": filter };
    NSString *rendering = [GRMustacheTemplate renderObject:data withFilters:filters fromString:@"{{f(a,b).foo}}" error:NULL];
    STAssertEqualObjects(rendering, @"bar", @"");
}

- (void)testMultiArgumentsFiltersCanBeUsedForObjectSections
{
    GRMustacheFilter *filter = [GRMustacheFilter multiArgumentsFilterWithBlock:^id(NSArray *arguments) {
        return @{@"foo": @"bar"};
    }];
    
    id data = @{ };
    id filters = @{ @"f": filter };
    NSString *rendering = [GRMustacheTemplate renderObject:data withFilters:filters fromString:@"{{#f(a,b)}}{{foo}}{{/}}" error:NULL];
    STAssertEqualObjects(rendering, @"bar", @"");
}

- (void)testMultiArgumentsFiltersCanBeUsedForEnumerableSections
{
    GRMustacheFilter *filter = [GRMustacheFilter multiArgumentsFilterWithBlock:^id(NSArray *arguments) {
        return arguments;
    }];
    
    id data = @{ @"a": @"a", @"b": @"b", @"c": @"c" };
    id filters = @{ @"f": filter };
    NSString *rendering = [GRMustacheTemplate renderObject:data withFilters:filters fromString:@"{{#f(a,b)}}{{.}}{{/}} {{#f(a,b,c)}}{{.}}{{/}}" error:NULL];
    STAssertEqualObjects(rendering, @"ab abc", @"");
}

- (void)testMultiArgumentsFiltersCanBeUsedForBooleanSections
{
    GRMustacheFilter *filter = [GRMustacheFilter multiArgumentsFilterWithBlock:^id(NSArray *arguments) {
        return [arguments objectAtIndex:0];
    }];
    
    id data = @{ @"yes": @YES, @"no": @NO };
    id filters = @{ @"f": filter };
    NSString *rendering = [GRMustacheTemplate renderObject:data withFilters:filters fromString:@"{{#f(yes)}}YES{{/}} {{^f(no)}}NO{{/}}" error:NULL];
    STAssertEqualObjects(rendering, @"YES NO", @"");
}

@end
