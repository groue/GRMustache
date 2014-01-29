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

#define GRMUSTACHE_VERSION_MAX_ALLOWED GRMUSTACHE_VERSION_6_4
#import "GRMustachePublicAPITest.h"

@interface GRMustacheNSFormatterTest : GRMustachePublicAPITest
@end

@implementation GRMustacheNSFormatterTest

- (void)testFormatterIsAFilterForProcessableValues
{
    NSNumberFormatter *percentFormatter = [[[NSNumberFormatter alloc] init] autorelease];
    percentFormatter.numberStyle = NSNumberFormatterPercentStyle;
    percentFormatter.locale = [[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"] autorelease];
    
    // test that number is processable
    NSNumber *number = [NSNumber numberWithFloat:0.5];
    STAssertEqualObjects([percentFormatter stringFromNumber:number], @"50%", @"");
    
    // test filtering a number
    id data = @{ @"number": number, @"percent": percentFormatter };
    NSString *rendering = [GRMustacheTemplate renderObject:data
                                                fromString:@"{{ percent(number) }}"
                                                     error:NULL];
    STAssertEqualObjects(rendering, @"50%", @"");
}

- (void)testFormatterIsAFilterForUnprocessableValues
{
    NSNumberFormatter *percentFormatter = [[[NSNumberFormatter alloc] init] autorelease];
    percentFormatter.numberStyle = NSNumberFormatterPercentStyle;
    percentFormatter.locale = [[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"] autorelease];
    
    // test that string is unprocessable
    NSString *unprocessableValue = @"foo";
    STAssertNil([percentFormatter stringForObjectValue:unprocessableValue], @"");
    
    // test filtering a string
    id data = @{ @"value": unprocessableValue, @"percent": percentFormatter };
    NSString *rendering = [GRMustacheTemplate renderObject:data
                                                fromString:@"{{ percent(value) }}"
                                                     error:NULL];
    STAssertEqualObjects(rendering, @"", @"");
}

- (void)testFormatterSectionFormatsInnerVariableTags
{
    NSNumberFormatter *percentFormatter = [[[NSNumberFormatter alloc] init] autorelease];
    percentFormatter.numberStyle = NSNumberFormatterPercentStyle;
    percentFormatter.locale = [[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"] autorelease];
    
    NSNumber *number = [NSNumber numberWithFloat:0.5];
    id data = @{ @"number": number, @"percent": percentFormatter };
    NSString *rendering = [GRMustacheTemplate renderObject:data
                                                fromString:@"{{# percent }}{{ number }} {{ number }}{{/ percent }}"
                                                     error:NULL];
    STAssertEqualObjects(rendering, @"50% 50%", @"");
}

- (void)testFormatterSectionDoesNotFormatUnprocessableInnerVariableTags
{
    NSNumberFormatter *percentFormatter = [[[NSNumberFormatter alloc] init] autorelease];
    percentFormatter.numberStyle = NSNumberFormatterPercentStyle;
    percentFormatter.locale = [[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"] autorelease];
    
    // test that string is unprocessable
    NSString *unprocessableValue = @"foo";
    STAssertNil([percentFormatter stringForObjectValue:unprocessableValue], @"");
    
    // test filtering a string
    id data = @{ @"value": unprocessableValue, @"percent": percentFormatter };
    NSString *rendering = [GRMustacheTemplate renderObject:data
                                                fromString:@"{{# percent }}{{ value }}{{/ percent }}"
                                                     error:NULL];
    STAssertEqualObjects(rendering, @"foo", @"");
}

- (void)testFormatterAsSectionFormatsDeepInnerVariableTags
{
    NSNumberFormatter *percentFormatter = [[[NSNumberFormatter alloc] init] autorelease];
    percentFormatter.numberStyle = NSNumberFormatterPercentStyle;
    percentFormatter.locale = [[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"] autorelease];
    
    NSNumber *number = [NSNumber numberWithFloat:0.5];
    STAssertEqualObjects([percentFormatter stringFromNumber:number], @"50%", @"");
    
    id data = @{ @"number": number, @"percent": percentFormatter };
    NSString *rendering = [GRMustacheTemplate renderObject:data
                                                fromString:@"{{# percent }}{{# number }}Number is {{ number }}.{{/ number }}{{/ percent }}"
                                                     error:NULL];
    STAssertEqualObjects(rendering, @"Number is 50%.", @"");
}

- (void)testFormatterAsSectionDoesNotFormatInnerSectionTags
{
    NSNumberFormatter *percentFormatter = [[[NSNumberFormatter alloc] init] autorelease];
    percentFormatter.numberStyle = NSNumberFormatterPercentStyle;
    percentFormatter.locale = [[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"] autorelease];
    
    NSNumber *number = [NSNumber numberWithFloat:0.5];
    STAssertEqualObjects([percentFormatter stringFromNumber:number], @"50%", @"");
    
    id data = @{ @"number": number, @"percent": percentFormatter, @"NO": [NSNumber numberWithBool:NO] };
    NSString *rendering = [GRMustacheTemplate renderObject:data
                                                fromString:@"NO is {{ NO }}. {{^ NO }}NO is false.{{/ NO }} percent(NO) is {{ percent(NO) }}. {{# percent(NO) }}percent(NO) is true.{{/ percent(NO) }} {{# percent }}{{^ NO }}NO is now {{ NO }} and is still false.{{/ NO }}{{/ percent }}"
                                                     error:NULL];
    STAssertEqualObjects(rendering, @"NO is 0. NO is false. percent(NO) is 0%. percent(NO) is true. NO is now 0% and is still false.", @"");
}

- (void)testFormatterIsTruthy
{
    NSFormatter *formatter = [[[NSFormatter alloc] init] autorelease];

    id data = @{ @"formatter": formatter };
    NSString *rendering = [GRMustacheTemplate renderObject:data
                                                fromString:@"{{# formatter }}Formatter is true.{{/ formatter }}{{^ formatter }}Formatter is false.{{/ formatter }}"
                                                     error:NULL];
    STAssertEqualObjects(rendering, @"Formatter is true.", @"");
}

- (void)testFormatterRendersSelfAsSomething
{
    NSFormatter *formatter = [[[NSFormatter alloc] init] autorelease];
    
    id data = @{ @"formatter": formatter };
    NSString *rendering = [GRMustacheTemplate renderObject:data
                                                fromString:@"{{ formatter }}"
                                                     error:NULL];
    STAssertTrue(rendering.length > 0, @"");
}

- (void)testNumberFormatterRendersNothingForNil
{
    // Check that NSNumberFormatter does not have surprising behavior, and
    // does not format nil.
    NSNumberFormatter *formatter = [[[NSNumberFormatter alloc] init] autorelease];
    formatter.numberStyle = NSNumberFormatterPercentStyle;
    
    id data = @{ @"format":formatter };
    
    {
        GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"<{{format(value)}}>" error:NULL];
        NSString *rendering = [template renderObject:data error:NULL];
        STAssertEqualObjects(rendering, @"<>", @"");
    }
    {
        GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{#format(value)}}YES{{/}}{{^format(value)}}NO{{/}}" error:NULL];
        NSString *rendering = [template renderObject:data error:NULL];
        STAssertEqualObjects(rendering, @"NO", @"");
    }
}

- (void)testNumberFormatterRendersNothingForNSNull
{
    // Check that NSNumberFormatter does not have surprising behavior, and
    // does not format NSNull.
    NSNumberFormatter *formatter = [[[NSNumberFormatter alloc] init] autorelease];
    formatter.numberStyle = NSNumberFormatterPercentStyle;
    
    id data = @{ @"format":formatter, @"value": [NSNull null] };
    
    {
        GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"<{{format(value)}}>" error:NULL];
        NSString *rendering = [template renderObject:data error:NULL];
        STAssertEqualObjects(rendering, @"<>", @"");
    }
    {
        GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{#format(value)}}YES{{/}}{{^format(value)}}NO{{/}}" error:NULL];
        NSString *rendering = [template renderObject:data error:NULL];
        STAssertEqualObjects(rendering, @"NO", @"");
    }
}

- (void)testNumberFormatterRendersNothingForNSString
{
    // Check that NSNumberFormatter does not have surprising behavior, and
    // does not format NSString.
    NSNumberFormatter *formatter = [[[NSNumberFormatter alloc] init] autorelease];
    formatter.numberStyle = NSNumberFormatterPercentStyle;
    
    {
        id data = @{ @"format":formatter, @"value":@"1" };
        
        {
            GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"<{{format(value)}}>" error:NULL];
            NSString *rendering = [template renderObject:data error:NULL];
            STAssertEqualObjects(rendering, @"<>", @"");
        }
        {
            GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{#format(value)}}YES{{/}}{{^format(value)}}NO{{/}}" error:NULL];
            NSString *rendering = [template renderObject:data error:NULL];
            STAssertEqualObjects(rendering, @"NO", @"");
        }
    }
    {
        id data = @{ @"format":formatter, @"value":@"YES" };
        
        {
            GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"<{{format(value)}}>" error:NULL];
            NSString *rendering = [template renderObject:data error:NULL];
            STAssertEqualObjects(rendering, @"<>", @"");
        }
        {
            GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{#format(value)}}YES{{/}}{{^format(value)}}NO{{/}}" error:NULL];
            NSString *rendering = [template renderObject:data error:NULL];
            STAssertEqualObjects(rendering, @"NO", @"");
        }
    }
    {
        id data = @{ @"format":formatter, @"value":@"foo" };
        
        {
            GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"<{{format(value)}}>" error:NULL];
            NSString *rendering = [template renderObject:data error:NULL];
            STAssertEqualObjects(rendering, @"<>", @"");
        }
        {
            GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{#format(value)}}YES{{/}}{{^format(value)}}NO{{/}}" error:NULL];
            NSString *rendering = [template renderObject:data error:NULL];
            STAssertEqualObjects(rendering, @"NO", @"");
        }
    }
}

- (void)testNumberFormatterRendersNothingForNSDate
{
    // Check that NSNumberFormatter does not have surprising behavior, and
    // does not format NSDate.
    NSNumberFormatter *formatter = [[[NSNumberFormatter alloc] init] autorelease];
    formatter.numberStyle = NSNumberFormatterPercentStyle;
    
    id data = @{ @"format":formatter, @"value": [NSDate date] };
    
    {
        GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"<{{format(value)}}>" error:NULL];
        NSString *rendering = [template renderObject:data error:NULL];
        STAssertEqualObjects(rendering, @"<>", @"");
    }
    {
        GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{#format(value)}}YES{{/}}{{^format(value)}}NO{{/}}" error:NULL];
        NSString *rendering = [template renderObject:data error:NULL];
        STAssertEqualObjects(rendering, @"NO", @"");
    }
}

- (void)testDateFormatterRendersNothingForNil
{
    // Check that NSDateFormatter does not have surprising behavior, and
    // does not format nil.
    NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
    formatter.dateStyle = NSDateFormatterFullStyle;
    
    id data = @{ @"format":formatter };
    
    {
        GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"<{{format(value)}}>" error:NULL];
        NSString *rendering = [template renderObject:data error:NULL];
        STAssertEqualObjects(rendering, @"<>", @"");
    }
    {
        GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{#format(value)}}YES{{/}}{{^format(value)}}NO{{/}}" error:NULL];
        NSString *rendering = [template renderObject:data error:NULL];
        STAssertEqualObjects(rendering, @"NO", @"");
    }
}

- (void)testDateFormatterRendersNothingForNSNull
{
    // Check that NSDateFormatter does not have surprising behavior, and
    // does not format NSNull.
    NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
    formatter.dateStyle = NSDateFormatterFullStyle;
    
    id data = @{ @"format":formatter, @"value": [NSNull null] };
    
    {
        GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"<{{format(value)}}>" error:NULL];
        NSString *rendering = [template renderObject:data error:NULL];
        STAssertEqualObjects(rendering, @"<>", @"");
    }
    {
        GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{#format(value)}}YES{{/}}{{^format(value)}}NO{{/}}" error:NULL];
        NSString *rendering = [template renderObject:data error:NULL];
        STAssertEqualObjects(rendering, @"NO", @"");
    }
}

- (void)testDateFormatterRendersNothingForNSString
{
    // Check that NSDateFormatter does not have surprising behavior, and
    // does not format NSString.
    NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
    formatter.dateStyle = NSDateFormatterFullStyle;
    
    {
        id data = @{ @"format":formatter, @"value":@"1" };
        
        {
            GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"<{{format(value)}}>" error:NULL];
            NSString *rendering = [template renderObject:data error:NULL];
            STAssertEqualObjects(rendering, @"<>", @"");
        }
        {
            GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{#format(value)}}YES{{/}}{{^format(value)}}NO{{/}}" error:NULL];
            NSString *rendering = [template renderObject:data error:NULL];
            STAssertEqualObjects(rendering, @"NO", @"");
        }
    }
    {
        id data = @{ @"format":formatter, @"value":@"YES" };
        
        {
            GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"<{{format(value)}}>" error:NULL];
            NSString *rendering = [template renderObject:data error:NULL];
            STAssertEqualObjects(rendering, @"<>", @"");
        }
        {
            GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{#format(value)}}YES{{/}}{{^format(value)}}NO{{/}}" error:NULL];
            NSString *rendering = [template renderObject:data error:NULL];
            STAssertEqualObjects(rendering, @"NO", @"");
        }
    }
    {
        id data = @{ @"format":formatter, @"value":@"foo" };
        
        {
            GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"<{{format(value)}}>" error:NULL];
            NSString *rendering = [template renderObject:data error:NULL];
            STAssertEqualObjects(rendering, @"<>", @"");
        }
        {
            GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{#format(value)}}YES{{/}}{{^format(value)}}NO{{/}}" error:NULL];
            NSString *rendering = [template renderObject:data error:NULL];
            STAssertEqualObjects(rendering, @"NO", @"");
        }
    }
}

- (void)testDateFormatterRendersNothingForNSNumber
{
    // Check that NSDateFormatter does not have surprising behavior, and
    // does not format NSNumber.
    NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
    formatter.dateStyle = NSDateFormatterFullStyle;
    
    id data = @{ @"format":formatter, @"value": [NSNumber numberWithInteger:0] };
    
    {
        GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"<{{format(value)}}>" error:NULL];
        NSString *rendering = [template renderObject:data error:NULL];
        STAssertEqualObjects(rendering, @"<>", @"");
    }
    {
        GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{#format(value)}}YES{{/}}{{^format(value)}}NO{{/}}" error:NULL];
        NSString *rendering = [template renderObject:data error:NULL];
        STAssertEqualObjects(rendering, @"NO", @"");
    }
}

@end
