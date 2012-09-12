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
#import "GRMustacheFilter.h"


// =============================================================================
#pragma mark - Private concrete class GRMustacheCapitalizedFilter

@interface GRMustacheCapitalizedFilter: NSObject<GRMustacheFilter>
@end

@implementation GRMustacheCapitalizedFilter

- (id)transformedValue:(id)object
{
    return [[object description] capitalizedString];
}

@end


// =============================================================================
#pragma mark - Private concrete class GRMustacheLowercaseFilter

@interface GRMustacheLowercaseFilter: NSObject<GRMustacheFilter>
@end

@implementation GRMustacheLowercaseFilter

- (id)transformedValue:(id)object
{
    return [[object description] lowercaseString];
}

@end


// =============================================================================
#pragma mark - Private concrete class GRMustacheUppercaseFilter

@interface GRMustacheUppercaseFilter: NSObject<GRMustacheFilter>
@end

@implementation GRMustacheUppercaseFilter

- (id)transformedValue:(id)object
{
    return [[object description] uppercaseString];
}

@end


// =============================================================================
#pragma mark - Private concrete class GRMustacheBlankFilter

@interface GRMustacheBlankFilter: NSObject<GRMustacheFilter>
@end

@implementation GRMustacheBlankFilter

- (id)transformedValue:(id)object
{
    if (object == nil || object == [NSNull null]) {
        return [NSNumber numberWithBool:YES];
    }
    
    if ([object conformsToProtocol:@protocol(NSFastEnumeration)]) {
        for (id _ in object) {
            return [NSNumber numberWithBool:NO];
        }
        return [NSNumber numberWithBool:YES];
    }
    
    NSString *trimmedDescription = [[object description] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return [NSNumber numberWithBool:trimmedDescription.length == 0];
}

@end


// =============================================================================
#pragma mark - Private concrete class GRMustacheEmptyFilter

@interface GRMustacheEmptyFilter: NSObject<GRMustacheFilter>
@end

@implementation GRMustacheEmptyFilter

- (id)transformedValue:(id)object
{
    if (object == nil || object == [NSNull null]) {
        return [NSNumber numberWithBool:YES];
    }
    
    if ([object conformsToProtocol:@protocol(NSFastEnumeration)]) {
        for (id _ in object) {
            return [NSNumber numberWithBool:NO];
        }
        return [NSNumber numberWithBool:YES];
    }
    
    NSString *description = [object description];
    return [NSNumber numberWithBool:description.length == 0];
}

@end


// =============================================================================
#pragma mark - GRMustacheFilterLibrary

@implementation GRMustacheFilterLibrary

+ (id)filterLibrary
{
    static NSDictionary *GRMustacheLibrary = nil;
    if (GRMustacheLibrary == nil) {
        GRMustacheLibrary = [[NSDictionary dictionaryWithObjectsAndKeys:
                              [[[GRMustacheCapitalizedFilter alloc] init] autorelease], @"capitalized",
                              [[[GRMustacheLowercaseFilter alloc] init] autorelease], @"lowercase",
                              [[[GRMustacheUppercaseFilter alloc] init] autorelease], @"uppercase",
                              [[[GRMustacheBlankFilter alloc] init] autorelease], @"isBlank",
                              [[[GRMustacheEmptyFilter alloc] init] autorelease], @"isEmpty",
                              nil] retain];
    }
    
    return GRMustacheLibrary;
}

@end
