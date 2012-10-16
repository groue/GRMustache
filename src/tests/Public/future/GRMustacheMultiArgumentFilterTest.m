#import "GRMustachePublicAPITest.h"

@interface GRMustacheMultiArgumentFilterTest : GRMustachePublicAPITest

@end

@implementation GRMustacheMultiArgumentFilterTest

- (void)testBlahBlock
{
    GRMustacheFilter *f = [GRMustacheFilter multiArgumentsFilterWithBlock:^id(NSArray *arguments) {
        return [[arguments valueForKey:@"description"] componentsJoinedByString:@","];
    }];
    
    id data = @{ @"a": @"a", @"b": @"b" };
    id filters = @{ @"f": f };
    NSString *rendering = [GRMustacheTemplate renderObject:data withFilters:filters fromString:@"{{f(a,b)}}" error:NULL];
    STAssertEqualObjects(rendering, @"a,b", @"");
}

@end
