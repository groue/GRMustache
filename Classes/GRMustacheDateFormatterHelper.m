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

#import "GRMustache.h"
#import "GRMustacheDateFormatterHelper.h"


// =============================================================================
#pragma mark - GRDateFormatterContext

@interface GRDateFormatterContext : NSObject {
@private
    NSDateFormatter *_dateFormatter;
    id _wrappedContext;
}
@property (nonatomic, retain) NSDateFormatter *dateFormatter;
@property (nonatomic, retain) id wrappedContext;
@end

@implementation GRDateFormatterContext
@synthesize dateFormatter=_dateFormatter;
@synthesize wrappedContext=_wrappedContext;

- (void)dealloc
{
    self.dateFormatter = nil;
    self.wrappedContext = nil;
    [super dealloc];
}

- (id)valueForKey:(NSString *)key
{
    // Fetch the value that we may format
    id value = [_wrappedContext valueForKey:key];
    
    // We format only dates
    if (![value isKindOfClass:[NSDate class]]) {
        return value;
    }
    
    // Let's format our date
    return [_dateFormatter stringFromDate:(NSDate *)value];
}

@end


// =============================================================================
#pragma mark - GRDateFormatterContext

@interface GRMustacheDateFormatterHelper()
@property (nonatomic, retain) NSDateFormatter *dateFormatter;
@end

@implementation GRMustacheDateFormatterHelper
@synthesize dateFormatter=_dateFormatter;

- (void)dealloc
{
    self.dateFormatter = nil;
    [super dealloc];
}

+ (id)helperWithDateFormatter:(NSDateFormatter *)dateFormatter
{
    GRMustacheDateFormatterHelper *helper = [[[GRMustacheDateFormatterHelper alloc] init] autorelease];
    helper.dateFormatter = dateFormatter;
    return helper;
}

#pragma mark <GRMustacheHelper>

- (NSString *)renderSection:(GRMustacheSection *)section withContext:(id)context
{
    if (_dateFormatter == nil) {
        return [section renderObject:context];
    }
    
    // Let's replace the current context with a GRDateFormatterContext
    // that will output formatted dates instead of raw dates.
    GRDateFormatterContext *dateFormatterContext = [[GRDateFormatterContext alloc] init];
    dateFormatterContext.wrappedContext = context;
    dateFormatterContext.dateFormatter = _dateFormatter;
    NSString *string = [section renderObject:dateFormatterContext];
    [dateFormatterContext release];
    return string;
}

@end

