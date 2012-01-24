// The MIT License
// 
// Copyright (c) 2010 Gwendal Roué
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

#import "GRMustacheDateFormatterHelperTest.h"
#import "GRMustacheUtils.h"

@implementation GRMustacheDateFormatterHelperTest

- (void)testDateFormatting
{
    NSString *templateString = @"{{#format}}{{value}}{{/format}}";
    GRMustacheTemplate *template = [GRMustacheTemplate parseString:templateString error:NULL];
    
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    dateFormatter.dateStyle = NSDateFormatterFullStyle;
    dateFormatter.timeStyle = NSDateFormatterShortStyle;
    dateFormatter.doesRelativeDateFormatting = NO;
    dateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    dateFormatter.locale = [[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] autorelease];
    dateFormatter.calendar = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
    NSDictionary *helper = [NSDictionary dictionaryWithObject:[GRMustacheDateFormatterHelper helperWithDateFormatter:dateFormatter] forKey:@"format"];
    
    NSDictionary *data = [NSDictionary dictionaryWithObject:[NSDate dateWithTimeIntervalSince1970:0] forKey:@"value"];
    NSString *result = [template renderObjects:helper, data, nil];
    STAssertEqualObjects(result, @"Thursday, January 1, 1970 12:00 AM", nil);
}

@end
