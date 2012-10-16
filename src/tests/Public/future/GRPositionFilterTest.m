//
//  GRPositionFilterTest.m
//  GRMustache
//
//  Created by Gwendal Roué on 16/10/12.
//
//

#import "GRMustachePublicAPITest.h"

@interface GRPositionFilterItem : NSObject
@property (nonatomic, readonly) NSUInteger position;
- (id)initWithObjectAtIndex:(NSUInteger)index fromArray:(NSArray *)array;
@end

@interface GRPositionFilter : NSObject<GRMustacheFilter>
@end

@implementation GRPositionFilter

- (id)transformedValue:(id)object
{
    NSAssert([object isKindOfClass:[NSArray class]], @"Not an NSArray");
    NSArray *array = (NSArray *)object;
    
    NSMutableArray *replacementArray = [NSMutableArray arrayWithCapacity:array.count];
    [array enumerateObjectsUsingBlock:^(id object, NSUInteger index, BOOL *stop) {
        GRPositionFilterItem *item = [[[GRPositionFilterItem alloc] initWithObjectAtIndex:index fromArray:array] autorelease];
        [replacementArray addObject:item];
    }];
    return replacementArray;
}

@end

@interface GRPositionFilterItem()<GRMustacheSectionTagHelper>
@property (nonatomic, retain) NSArray *array_;
@property (nonatomic) NSUInteger index_;
@end

@implementation GRPositionFilterItem

- (void)dealloc
{
    self.array_ = nil;
    [super dealloc];
}

- (id)initWithObjectAtIndex:(NSUInteger)index fromArray:(NSArray *)array
{
    self = [super init];
    if (self) {
        self.index_ = index;
        self.array_ = array;
    }
    return self;
}

- (NSUInteger)position
{
    return self.index_ + 1;
}

- (NSString *)renderForSectionTagInContext:(GRMustacheSectionTagRenderingContext *)context
{
    NSString *templateString = [NSString stringWithFormat:@"{{#originalObject_}}%@{{/originalObject_}}", context.innerTemplateString];
    return [context renderTemplateString:templateString error:NULL];
}

- (id)originalObject_
{
    return [self.array_ objectAtIndex:self.index_];
}

@end


@interface GRPositionFilterTest : GRMustachePublicAPITest

@end

@implementation GRPositionFilterTest

- (void)testGRPositionFilterRendersPositions
{
    // GRPositionFilter should do its job
    id data = @{ @"array": @[@"foo", @"bar"] };
    id filters = @{ @"f": [[[GRPositionFilter alloc] init] autorelease] };
    NSString *rendering = [GRMustacheTemplate renderObject:data
                                               withFilters:filters
                                                fromString:@"{{#f(array)}}{{position}}:{{.}} {{/}}"
                                                     error:NULL];
    STAssertEqualObjects(rendering, @"1:foo 2:bar ", @"");
}

- (void)testGRPositionFilterRendersArrayOfFalseValuesJustAsOriginalArray
{
    // GRPositionFilter should not alter the way an array is rendered
    id data = @{ @"array": @[[NSNull null], @NO] };
    id filters = @{ @"f": [[[GRPositionFilter alloc] init] autorelease] };
    NSString *rendering1 = [GRMustacheTemplate renderObject:data
                                                 fromString:@"{{#array}}<{{.}}>{{/}}"
                                                      error:NULL];
    NSString *rendering2 = [GRMustacheTemplate renderObject:data
                                                withFilters:filters
                                                 fromString:@"{{#f(array)}}<{{.}}>{{/}}"
                                                      error:NULL];
    STAssertEqualObjects(rendering1, rendering2, @"");
}

- (void)testGRPositionFilterRendersEmptyArrayJustAsOriginalArray
{
    // GRPositionFilter should not alter the way an array is rendered
    id data = @{ @"array": @[] };
    id filters = @{ @"f": [[[GRPositionFilter alloc] init] autorelease] };
    
    {
        NSString *rendering1 = [GRMustacheTemplate renderObject:data
                                                     fromString:@"{{#array}}<{{.}}>{{/}}"
                                                          error:NULL];
        NSString *rendering2 = [GRMustacheTemplate renderObject:data
                                                    withFilters:filters
                                                     fromString:@"{{#f(array)}}<{{.}}>{{/}}"
                                                          error:NULL];
        STAssertEqualObjects(rendering1, rendering2, @"");
    }
    {
        NSString *rendering1 = [GRMustacheTemplate renderObject:data
                                                     fromString:@"{{^array}}empty{{/}}"
                                                          error:NULL];
        NSString *rendering2 = [GRMustacheTemplate renderObject:data
                                                    withFilters:filters
                                                     fromString:@"{{^f(array)}}empty{{/}}"
                                                          error:NULL];
        STAssertEqualObjects(rendering1, rendering2, @"");
    }
}

@end
