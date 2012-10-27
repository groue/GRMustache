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

#import "GRMustachePublicAPITest.h"
#import "JSONKit.h"

static struct {
    NSString *tests;
} GRMustacheTestSuiteKeys = {
    .tests = @"tests",
};

static struct {
    NSString *partials;
    NSString *template;
    NSString *template_name;
    NSString *encoding;
    NSString *data;
    NSString *expected;
} GRMustachePublicAPITestItemKeys = {
    .partials = @"partials",
    .template = @"template",
    .template_name = @"template_name",
    .encoding = @"encoding",
    .data = @"data",
    .expected = @"expected",
};


@implementation GRMustachePublicAPITest
@end

@implementation GRMustachePublicAPISuiteTest

- (void)runTestsFromResource:(NSString *)name subdirectory:(NSString *)subpath
{
    NSString *path = [[self.testBundle pathForResource:subpath ofType:nil] stringByAppendingPathComponent:name];
    
    NSError *error;
    NSData *testSuiteData = [NSData dataWithContentsOfFile:path];
    STAssertNotNil(testSuiteData, @"Could not load test suite at %@", path);
    if (!testSuiteData) return;
    
    NSDictionary *testSuite = [testSuiteData objectFromJSONDataWithParseOptions:JKParseOptionComments error:&error];
    STAssertNotNil(testSuite, @"Could not load test suite at %@: %@", path, error);
    if (!testSuite) return;
    
    NSArray *tests = [testSuite objectForKey:GRMustacheTestSuiteKeys.tests];
    STAssertTrue((tests.count > 0), @"Empty test suite at %@", path);
    
    for (NSDictionary *testDictionary in tests) {
        
        NSString *testDescription = [NSString stringWithFormat:@"test at %@: %@", path, testDictionary];
        
        
        // load
        
        id data = [testDictionary objectForKey:GRMustachePublicAPITestItemKeys.data];
        NSString *templateString = [testDictionary objectForKey:GRMustachePublicAPITestItemKeys.template];
        NSString *templateName = [testDictionary objectForKey:GRMustachePublicAPITestItemKeys.template_name];
        NSString *expectedRendering = [testDictionary objectForKey:GRMustachePublicAPITestItemKeys.expected];
        NSDictionary *templatesDictionary = [testDictionary objectForKey:GRMustachePublicAPITestItemKeys.partials];
        
        
        // data is mandatory
        
        STAssertTrue((data != nil), @"Missing `%@` key in %@", GRMustachePublicAPITestItemKeys.data, testDescription);
        if (!(data != nil)) continue;
        
        
        // expected rendering must be a string
        
        STAssertTrue([expectedRendering isKindOfClass:[NSString class]], @"`%@` key is not a string in %@", GRMustachePublicAPITestItemKeys.expected, testDescription);
        if (![expectedRendering isKindOfClass:[NSString class]]) continue;
        
        
        // template string, if present, must be a string
        
        if (templateString) {
            STAssertTrue([templateString isKindOfClass:[NSString class]], @"`%@` key is not a string in %@", GRMustachePublicAPITestItemKeys.template, testDescription);
            if (![templateString isKindOfClass:[NSString class]]) continue;
        }
        
        
        // template name, if present, must be a string
        
        if (templateName) {
            STAssertTrue([templateName isKindOfClass:[NSString class]], @"`%@` key is not a string in %@", GRMustachePublicAPITestItemKeys.template_name, testDescription);
            if (![templateName isKindOfClass:[NSString class]]) continue;
        }
        
        
        // we need template string, or template name
        
        STAssertTrue(!((templateString == nil) && (templateName == nil)), @"Missing both `%@` and `%@` keys in %@", GRMustachePublicAPITestItemKeys.template, GRMustachePublicAPITestItemKeys.template_name, testDescription);
        if (((templateString == nil) && (templateName == nil))) continue;
        
        
        // we need template string, or template name, but not both
        
        STAssertTrue(!((templateString != nil) && (templateName != nil)), @"Can't have both `%@` and `%@` keys in %@", GRMustachePublicAPITestItemKeys.template, GRMustachePublicAPITestItemKeys.template_name, testDescription);
        if (((templateString != nil) && (templateName != nil))) continue;
        
        
        // partials dictionary, if present, must be a dictionary
        
        if (templatesDictionary) {
            STAssertTrue([templatesDictionary isKindOfClass:[NSDictionary class]], @"`%@` key is not an object in %@", GRMustachePublicAPITestItemKeys.partials, testDescription);
            if (![templatesDictionary isKindOfClass:[NSDictionary class]]) continue;
        }
        
        
        // run test
        
        if (templateName) {
            
            // run tests from the file system, with various encodings.
            
            NSStringEncoding encodings[] = { NSUTF8StringEncoding, NSUTF16StringEncoding };
            
            for (int i=0; i < (sizeof(encodings)/sizeof(NSStringEncoding)); ++i) {
                NSStringEncoding encoding = encodings[i];

                NSFileManager *fm = [NSFileManager defaultManager];
                NSString *templatesPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"GRMustacheTest"];
                [fm removeItemAtPath:templatesPath error:nil];
                
                for (NSString *partialName in templatesDictionary) {
                    NSString *partialString = [templatesDictionary objectForKey:partialName];
                    NSString *partialPath = [templatesPath stringByAppendingPathComponent:partialName];
                    [fm createDirectoryAtPath:[partialPath stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:NULL];
                    [fm createFileAtPath:partialPath contents:[partialString dataUsingEncoding:encoding] attributes:nil];
                }
                
                // run tests with NSString path
                
                {
                    NSError *error;
                    GRMustacheTemplate *template = [self templateForTemplateNamed:templateName
                                                                    templatesPath:templatesPath
                                                                         encoding:encoding
                                                                            error:&error];
                    
                    if (template) {
                        NSString *rendering = [template renderObject:data error:&error];
                        if (rendering) {
                            if (![expectedRendering isEqualToString:rendering]) {
                                // Allow Breakpointing failing tests
                                [template renderObject:data error:&error];
                            }
                            
                            STAssertEqualObjects(rendering, expectedRendering, @"Failed test: %@", testDescription);
                        } else {
                            // Allow Breakpointing failing tests
                            [template renderObject:data error:&error];
                            STAssertTrue(NO, @"Error rendering template: %@: %@", [error localizedDescription], testDescription);
                        }
                    } else {
                        STAssertTrue(NO, @"Error loading template: %@: %@", [error localizedDescription], testDescription);
                    }
                }
                
                // run tests with NSURL path
                
                {
                    NSError *error;
                    GRMustacheTemplate *template = [self templateForTemplateNamed:templateName
                                                                     templatesURL:[NSURL fileURLWithPath:templatesPath]
                                                                         encoding:encoding
                                                                            error:&error];
                    
                    if (template) {
                        NSString *rendering = [template renderObject:data error:&error];
                        if (rendering) {
                            if (![expectedRendering isEqualToString:rendering]) {
                                // Allow Breakpointing failing tests
                                [template renderObject:data error:&error];
                            }
                            
                            STAssertEqualObjects(rendering, expectedRendering, @"Failed test: %@", testDescription);
                        } else {
                            // Allow Breakpointing failing tests
                            [template renderObject:data error:&error];
                            STAssertTrue(NO, @"Error rendering template: %@: %@", [error localizedDescription], testDescription);
                        }
                    } else {
                        STAssertTrue(NO, @"Error loading template: %@: %@", [error localizedDescription], testDescription);
                    }
                }
                
                
                // clean up
                
                [fm removeItemAtPath:templatesPath error:NULL];
            }
            
        } else {
            
            // run tests from memory
            
            NSError *error;
            GRMustacheTemplate *template = [self templateForTemplateString:templateString
                                                        partialsDictionary:templatesDictionary
                                                                     error:&error];
            
            if (template) {
                NSString *rendering = [template renderObject:data error:&error];
                if (rendering) {
                    if (![expectedRendering isEqualToString:rendering]) {
                        // Allow Breakpointing failing tests
                        [template renderObject:data error:&error];
                    }
                    
                    STAssertEqualObjects(rendering, expectedRendering, @"Failed test: %@", testDescription);
                } else {
                    // Allow Breakpointing failing tests
                    [template renderObject:data error:&error];
                    STAssertTrue(NO, @"Error rendering template: %@: %@", [error localizedDescription], testDescription);
                }
            } else {
                STAssertTrue(NO, @"Error loading template: %@: %@", [error localizedDescription], testDescription);
            }
        }
    }
}

- (GRMustacheTemplate *)templateForTemplateString:(NSString *)templateString partialsDictionary:(NSDictionary *)partialsDictionary error:(NSError **)error
{
    GRMustacheTemplateRepository *repository = [GRMustacheTemplateRepository templateRepositoryWithPartialsDictionary:partialsDictionary];
    return [repository templateFromString:templateString error:error];
}

- (GRMustacheTemplate *)templateForTemplateNamed:(NSString *)templateName templatesPath:(NSString *)templatesPath encoding:(NSStringEncoding)encoding error:(NSError **)error
{
    GRMustacheTemplateRepository *repository = [GRMustacheTemplateRepository templateRepositoryWithDirectory:templatesPath
                                                                                           templateExtension:[templateName pathExtension]
                                                                                                    encoding:encoding];
    return [repository templateNamed:[templateName stringByDeletingPathExtension] error:error];
}

- (GRMustacheTemplate *)templateForTemplateNamed:(NSString *)templateName templatesURL:(NSURL *)templatesURL encoding:(NSStringEncoding)encoding error:(NSError **)error
{
    GRMustacheTemplateRepository *repository = [GRMustacheTemplateRepository templateRepositoryWithBaseURL:templatesURL
                                                                                         templateExtension:[templateName pathExtension]
                                                                                                  encoding:encoding];
    return [repository templateNamed:[templateName stringByDeletingPathExtension] error:error];
}

@end
