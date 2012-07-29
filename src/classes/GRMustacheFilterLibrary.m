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

#import "GRMustacheFilterLibrary_private.h"
#import "GRMustacheContext_private.h"
#import "GRMustacheFilter.h"


// =============================================================================
#pragma mark - Private concrete class GRMustacheStandardCapitalizeFilter

@interface GRMustacheStandardCapitalizeFilter: NSObject<GRMustacheFilter>
@end

@implementation GRMustacheStandardCapitalizeFilter

- (id)transformedValue:(id)object
{
    return [[object description] capitalizedString];
}

@end


// =============================================================================
#pragma mark - Private concrete class GRMustacheStandardLowercaseFilter

@interface GRMustacheStandardLowercaseFilter: NSObject<GRMustacheFilter>
@end

@implementation GRMustacheStandardLowercaseFilter

- (id)transformedValue:(id)object
{
    return [[object description] lowercaseString];
}

@end


// =============================================================================
#pragma mark - Private concrete class GRMustacheStandardUppercaseFilter

@interface GRMustacheStandardUppercaseFilter: NSObject<GRMustacheFilter>
@end

@implementation GRMustacheStandardUppercaseFilter

- (id)transformedValue:(id)object
{
    return [[object description] uppercaseString];
}

@end


// =============================================================================
#pragma mark - Private concrete class GRMustacheStandardFirstFilter

@interface GRMustacheStandardFirstFilter: NSObject<GRMustacheFilter>
@end

@implementation GRMustacheStandardFirstFilter

- (id)transformedValue:(id)object
{
    return [(NSArray *)object objectAtIndex:0];
}

@end


// =============================================================================
#pragma mark - Private concrete class GRMustacheStandardLastFilter

@interface GRMustacheStandardLastFilter: NSObject<GRMustacheFilter>
@end

@implementation GRMustacheStandardLastFilter

- (id)transformedValue:(id)object
{
    return [(NSArray *)object lastObject];
}

@end


// =============================================================================
#pragma mark - GRMustacheFilterLibrary

@implementation GRMustacheFilterLibrary

+ (GRMustacheContext *)filterContextWithFilters:(id)filters
{
    static NSDictionary *standardLibrary = nil;
    if (standardLibrary == nil) {
        standardLibrary = [[NSDictionary dictionaryWithObjectsAndKeys:
                            [[[GRMustacheStandardCapitalizeFilter alloc] init] autorelease], @"capitalize",
                            [[[GRMustacheStandardLowercaseFilter alloc] init] autorelease], @"lowercase",
                            [[[GRMustacheStandardUppercaseFilter alloc] init] autorelease], @"uppercase",
                            [[[GRMustacheStandardFirstFilter alloc] init] autorelease], @"first",
                            [[[GRMustacheStandardLastFilter alloc] init] autorelease], @"last",
                            nil] retain];
    }
    
    GRMustacheContext *filterContext = [GRMustacheContext contextWithObject:standardLibrary];
    if (filters == nil) {
        return filterContext;
    }
    return [filterContext contextByAddingObject:filters];
}

@end
