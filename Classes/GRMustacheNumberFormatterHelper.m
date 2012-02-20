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
#import "GRMustacheNumberFormatterHelper.h"

@interface GRNumberFormatterContext : NSObject {
@private
    NSNumberFormatter *_numberFormatter;
    id _wrappedContext;
}
@property (nonatomic, retain) NSNumberFormatter *numberFormatter;
@property (nonatomic, retain) id wrappedContext;
@end

@interface GRMustacheNumberFormatterHelper()
@property (nonatomic, retain) NSNumberFormatter *numberFormatter;
@end

@implementation GRMustacheNumberFormatterHelper
@synthesize numberFormatter=_numberFormatter;

- (void)dealloc
{
    self.numberFormatter = nil;
    [super dealloc];
}

+ (id)helperWithNumberFormatter:(NSNumberFormatter *)numberFormatter
{
    GRMustacheNumberFormatterHelper *helper = [[[GRMustacheNumberFormatterHelper alloc] init] autorelease];
    helper.numberFormatter = numberFormatter;
    return helper;
}

- (NSString *)renderSection:(GRMustacheSection *)section withContext:(id)context
{
    if (_numberFormatter == nil) {
        return [section renderObject:context];
    }
    
    // Let's replace the current context with a GRNumberFormatterContext
    // that will output formatted numbers instead of raw numbers.
    GRNumberFormatterContext *numberFormatterContext = [[GRNumberFormatterContext alloc] init];
    numberFormatterContext.wrappedContext = context;
    numberFormatterContext.numberFormatter = _numberFormatter;
    NSString *string = [section renderObject:numberFormatterContext];
    [numberFormatterContext release];
    return string;
}

@end

@implementation GRNumberFormatterContext
@synthesize numberFormatter=_numberFormatter;
@synthesize wrappedContext=_wrappedContext;

- (void)dealloc
{
    self.numberFormatter = nil;
    self.wrappedContext = nil;
    [super dealloc];
}

- (id)valueForKey:(NSString *)key
{
    // Fetch the value that we may format
    id value = [_wrappedContext valueForKey:key];
    
    // We format only numbers
    if (![value isKindOfClass:[NSNumber class]]) {
        return value;
    }
    
    // Let's not mess with booleans, which control mustache section logic.
    if ((void *)value == kCFBooleanFalse || (void *)value == kCFBooleanTrue) {
        return value;
    }
    
    // Let's format our number
    return [_numberFormatter stringFromNumber:(NSNumber *)value];
}

@end

