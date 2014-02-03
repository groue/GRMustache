// The MIT License
//
// Copyright (c) 2014 Nolan Waite
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

#define GRMUSTACHE_VERSION_MAX_ALLOWED GRMUSTACHE_VERSION_6_3
#import "GRMustachePublicAPITest.h"

@interface GRMustacheErrorHandlingTest : GRMustachePublicAPITest
@end

@implementation GRMustacheErrorHandlingTest

- (void)testFastEnumeration
{
    NSDictionary *repositoryDictionary = @{ @"profile": @"{{ intentionallyNonexistentFilter(name) }}",
                                            @"list": @"{{# people}} {{> profile}} {{/}}" };
    GRMustacheTemplateRepository *repository = [GRMustacheTemplateRepository templateRepositoryWithDictionary:repositoryDictionary];
    GRMustacheTemplate *template = [repository templateNamed:@"list" error:NULL];
    NSError *error;
    [template renderObject:@{ @"people": @[ @{ @"name": @"updog" } ] }  error:&error];
    STAssertNoThrow([error code], @"EXC_BAD_ACCESS message sent to deallocated instance");
}

@end
