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

#import "GRDefaultTemplateOptionsTest.h"

@interface GRDefaultTemplateOptionsTestSupport : NSObject
@property (nonatomic) BOOL pretty;
@end

@implementation GRDefaultTemplateOptionsTestSupport
@synthesize pretty;
@end

@implementation GRDefaultTemplateOptionsTest

- (void)testDefaultTemplateOptions
{
    NSString *templateString = @"{{#pretty}}YES{{/pretty}}{{^pretty}}NO{{/pretty}}";
    GRDefaultTemplateOptionsTestSupport *context = [[[GRDefaultTemplateOptionsTestSupport alloc] init] autorelease];
    context.pretty = NO;
    NSString *result = nil;
    
    GRMustacheTemplateOptions originalTemplateOptions = [GRMustache defaultTemplateOptions];
    {
        // Expect NO BOOL property to be interpreted as false boolean
        [GRMustache setDefaultTemplateOptions:GRMustacheTemplateOptionNone];
        result = [GRMustacheTemplate renderObject:context fromString:templateString error:nil];
        STAssertEqualObjects(result, @"NO", @"");
        
        // Expect NO BOOL property to be interpreted as true NSNumber
        [GRMustache setDefaultTemplateOptions:GRMustacheTemplateOptionStrictBoolean];
        result = [GRMustacheTemplate renderObject:context fromString:templateString error:nil];
        STAssertEqualObjects(result, @"YES", @"");
    }
    [GRMustache setDefaultTemplateOptions:originalTemplateOptions];
}

@end
