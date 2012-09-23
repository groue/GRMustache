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

#define GRMUSTACHE_VERSION_MAX_ALLOWED GRMUSTACHE_VERSION_5_2
#import "GRMustachePublicAPITest.h"

@interface GRMustacheSuites5_2Test : GRMustachePublicAPITest
- (void)runTest:(NSDictionary *)test atPath:(NSString *)path;
@end

@implementation GRMustacheSuites5_2Test

- (void)testGRMustacheSuites
{
    void(^block)(NSDictionary *test, NSString *path) = ^(NSDictionary *test, NSString *path) { [self runTest:test atPath:path]; };
    [self enumerateTestsFromResource:@"overridable_sections.json" subdirectory:@"GRMustacheSuites5_2" usingBlock:block];
    [self enumerateTestsFromResource:@"template_inheritance.json" subdirectory:@"GRMustacheSuites5_2" usingBlock:block];
}

- (void)runTest:(NSDictionary *)test atPath:(NSString *)path
{
    NSError *error;
    
    // Load template
    
    GRMustacheTemplate *template = nil;
    
    NSDictionary *partialsDictionary = [test objectForKey:@"partials"];
    NSString *templateName = [test objectForKey:@"template_name"];
    if (templateName.length > 0) {
        
        // Write partials in a file hierarchy
        
        NSFileManager *fm = [NSFileManager defaultManager];
        NSString *templatesDirectoryPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"GRMustacheTest"];
        [fm removeItemAtPath:templatesDirectoryPath error:nil];
        
        NSNumber *encodingNumber = [test objectForKey:@"encoding"];
        NSStringEncoding encoding = encodingNumber ? [encodingNumber unsignedIntegerValue] : NSUTF8StringEncoding;
        
        for (NSString *partialName in partialsDictionary) {
            NSString *partialString = [partialsDictionary objectForKey:partialName];
            NSString *partialPath = [templatesDirectoryPath stringByAppendingPathComponent:partialName];
            [fm createDirectoryAtPath:[partialPath stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:&error];
            [fm createFileAtPath:partialPath contents:[partialString dataUsingEncoding:encoding] attributes:nil];
        }
        
        GRMustacheTemplateRepository *repository = [GRMustacheTemplateRepository templateRepositoryWithDirectory:templatesDirectoryPath
                                                                                               templateExtension:[templateName pathExtension]
                                                                                                        encoding:encoding];
        template = [repository templateForName:[templateName stringByDeletingPathExtension] error:&error];
        
        [fm removeItemAtPath:templatesDirectoryPath error:NULL];
    } else {
        
        // Keep partials in memory
        
        NSString *templateString = [test objectForKey:@"template"];
        GRMustacheTemplateRepository *repository = [GRMustacheTemplateRepository templateRepositoryWithPartialsDictionary:partialsDictionary];
        template = [repository templateFromString:templateString error:&error];
    }
    STAssertNotNil(template, @"Could not template: %@", error);
    if (!template) return;

    
    // Test rendering
    
    id data = [test objectForKey:@"data"];
    NSString *expected = [test objectForKey:@"expected"];
    NSString *rendering = [template renderObject:data];
    
    // Allow Breakpointing failing tests
    
    if (![expected isEqualToString:rendering]) {
        [template renderObject:data];
    }
    
    STAssertEqualObjects(rendering, expected, @"Failed test in suite at %@: %@", path, test);
}

@end
