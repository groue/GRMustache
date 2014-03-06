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

#import "GRMustachePublicAPITest.h"

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
    NSString *expected_error;
} GRMustachePublicAPITestItemKeys = {
    .partials = @"partials",
    .template = @"template",
    .template_name = @"template_name",
    .encoding = @"encoding",
    .data = @"data",
    .expected = @"expected",
    .expected_error = @"expected_error",
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
    
    NSDictionary *testSuite = [self JSONObjectWithData:testSuiteData error:&error];
    STAssertNotNil(testSuite, @"Could not load test suite at %@: %@", path, error);
    if (!testSuite) {
        // Allow breakpoint for failing tests
        return;
    }
    
    NSArray *tests = [testSuite objectForKey:GRMustacheTestSuiteKeys.tests];
    STAssertTrue((tests.count > 0), @"Empty test suite at %@", path);
    
    for (NSDictionary *testDictionary in tests) {
        
        NSString *testDescription = [NSString stringWithFormat:@"test at %@: %@", path, testDictionary];
        
        
        // load
        
        id data = [testDictionary objectForKey:GRMustachePublicAPITestItemKeys.data];
        NSString *templateString = [testDictionary objectForKey:GRMustachePublicAPITestItemKeys.template];
        NSString *templateName = [testDictionary objectForKey:GRMustachePublicAPITestItemKeys.template_name];
        NSString *expectedRendering = [testDictionary objectForKey:GRMustachePublicAPITestItemKeys.expected];
        NSString *expectedError = [testDictionary objectForKey:GRMustachePublicAPITestItemKeys.expected_error];
        NSDictionary *templatesDictionary = [testDictionary objectForKey:GRMustachePublicAPITestItemKeys.partials];
        NSRegularExpression *expectedErrorReg = nil;
        
        
        // data is mandatory
        
        STAssertTrue((data != nil), @"Missing `%@` key in %@", GRMustachePublicAPITestItemKeys.data, testDescription);
        if (!(data != nil)) continue;
        
        
        // expected rendering, if present, must be a string
        
        if (expectedRendering) {
            STAssertTrue([expectedRendering isKindOfClass:[NSString class]], @"`%@` key is not a string in %@", GRMustachePublicAPITestItemKeys.expected, testDescription);
            if (![expectedRendering isKindOfClass:[NSString class]]) continue;
        }
        
        
        // expected error, if present, must be a string
        
        if (expectedError) {
            STAssertTrue([expectedError isKindOfClass:[NSString class]], @"`%@` key is not a string in %@", GRMustachePublicAPITestItemKeys.expected_error, testDescription);
            if (![expectedError isKindOfClass:[NSString class]]) continue;
        }
        
        
        // expected error, if present, must be a regular expression pattern
        
        if (expectedError) {
            NSError *error;
            expectedErrorReg = [NSRegularExpression regularExpressionWithPattern:expectedError options:0 error:&error];
            STAssertNotNil(expectedErrorReg, @"`%@` key is not a regular expression pattern in %@ (%@)", GRMustachePublicAPITestItemKeys.expected_error, testDescription, error.localizedDescription);
            if (!expectedErrorReg) continue;
        }
        
        
        // we need expected rendering, or expected error
        
        STAssertTrue(!((expectedRendering == nil) && (expectedErrorReg == nil)), @"Missing both `%@` and `%@` keys in %@", GRMustachePublicAPITestItemKeys.expected, GRMustachePublicAPITestItemKeys.expected_error, testDescription);
        if (((expectedRendering == nil) && (expectedErrorReg == nil))) continue;
        
        
        // we need expected rendering, or expected error, but not both
        
        STAssertTrue(!((expectedRendering != nil) && (expectedErrorReg != nil)), @"Can't have both `%@` and `%@` keys in %@", GRMustachePublicAPITestItemKeys.expected, GRMustachePublicAPITestItemKeys.expected_error, testDescription);
        if (((expectedRendering != nil) && (expectedErrorReg != nil))) continue;
        
        
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
                    [self checkExpectedRendering:expectedRendering
                                expectedErrorReg:expectedErrorReg
                             fromTestDescription:testDescription
                           againstRenderedObject:data
                                        template:^(GRMustacheTemplate **template, NSError **error) {
                                            *template = [self templateForTemplateNamed:templateName
                                                                         templatesPath:templatesPath
                                                                              encoding:encoding
                                                                                 error:error];
                                        }];
                }
                
                // run tests with NSURL path
                
                {
                    [self checkExpectedRendering:expectedRendering
                                expectedErrorReg:expectedErrorReg
                             fromTestDescription:testDescription
                           againstRenderedObject:data
                                        template:^(GRMustacheTemplate **template, NSError **error) {
                                            *template = [self templateForTemplateNamed:templateName
                                                                          templatesURL:[NSURL fileURLWithPath:templatesPath]
                                                                              encoding:encoding
                                                                                 error:error];
                                        }];
                }
                
                
                // clean up
                
                [fm removeItemAtPath:templatesPath error:NULL];
            }
            
        } else {
            
            // run tests from memory
            
            [self checkExpectedRendering:expectedRendering
                        expectedErrorReg:expectedErrorReg
                     fromTestDescription:testDescription
                   againstRenderedObject:data
                                template:^(GRMustacheTemplate **template, NSError **error) {
                                    *template = [self templateForTemplateString:templateString
                                                             partialsDictionary:templatesDictionary
                                                                          error:error];
                                }];
        }
    }
}

- (GRMustacheTemplate *)templateForTemplateString:(NSString *)templateString partialsDictionary:(NSDictionary *)partialsDictionary error:(NSError **)error
{
    GRMustacheTemplateRepository *repository = [GRMustacheTemplateRepository templateRepositoryWithDictionary:partialsDictionary];
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

- (void)checkExpectedRendering:(NSString *)expectedRendering expectedErrorReg:(NSRegularExpression *)expectedErrorReg fromTestDescription:(NSString *)testDescription againstRenderedObject:(id)object template:(void(^)(GRMustacheTemplate **template, NSError **error))block
{
    NSError *error;
    GRMustacheTemplate *template;
    
    block(&template, &error);
    
    if (template) {
        NSString *rendering = [template renderObject:object error:&error];
        if (rendering) {
            if (expectedRendering) {
                // compare rendering to expected rendering
                
                if (![expectedRendering isEqualToString:rendering]) {
                    // Allow breakpoint for failing tests
                    [template renderObject:object error:&error];
                }
                
                STAssertEqualObjects(rendering, expectedRendering, @"Unexpected rendering: %@", testDescription);
            } else {
                // error was expected
                
                // Allow breakpoint for failing tests
                [template renderObject:object error:&error];
                
                STAssertTrue(NO, @"Unexpected rendering: %@: %@", rendering, testDescription);
            }
        } else {
            if (expectedErrorReg) {
                __block BOOL match = NO;
                [expectedErrorReg enumerateMatchesInString:error.localizedDescription options:0 range:NSMakeRange(0, error.localizedDescription.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                    match = YES;
                    *stop = YES;
                }];
                if (!match) {
                    // Allow breakpoint for failing tests
                    [template renderObject:object error:&error];
                    
                    STAssertTrue(NO, @"Unexpected error: %@: %@", error.localizedDescription, testDescription);
                }
            } else {
                // Allow breakpoint for failing tests
                [template renderObject:object error:&error];
                
                STAssertTrue(NO, @"Unexpected error: %@: %@", error.localizedDescription, testDescription);
            }
        }
    } else {
        if (expectedErrorReg) {
            __block BOOL match = NO;
            [expectedErrorReg enumerateMatchesInString:error.localizedDescription options:0 range:NSMakeRange(0, error.localizedDescription.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                match = YES;
                *stop = YES;
            }];
            if (!match) {
                // Allow breakpoint for failing tests
                block(&template, &error);
                
                STAssertTrue(NO, @"Unexpected error: %@: %@", error.localizedDescription, testDescription);
            }
        } else {
            // Allow breakpoint for failing tests
            block(&template, &error);
            
            STAssertTrue(NO, @"Error loading template: %@: %@", error.localizedDescription, testDescription);
        }
    }
}

@end
