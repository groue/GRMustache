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

#import "GRMustacheTemplateLoaderSubclassTest.h"
#import "GRMustacheTemplateLoader_protected.h"
#import "GRMustacheTemplate.h"


@interface FailingOnTemplateIdTemplateLoader : GRMustacheTemplateLoader
@end

@implementation FailingOnTemplateIdTemplateLoader
- (id)templateIdForTemplateNamed:(NSString *)name relativeToTemplateId:(id)baseTemplateId {
	return nil;
}
@end


@interface FailingOnTemplateStringLazyTemplateLoader : GRMustacheTemplateLoader
@end

@implementation FailingOnTemplateStringLazyTemplateLoader
- (id)templateIdForTemplateNamed:(NSString *)name relativeToTemplateId:(id)baseTemplateId {
	return name;
}

- (NSString *)templateStringForTemplateId:(id)templateId error:(NSError **)outError {
	// lazy because returns nil but doesn't set outError
	return nil;
}
@end


@interface FailingOnTemplateStringNotLazyTemplateLoader : GRMustacheTemplateLoader
@end

@implementation FailingOnTemplateStringNotLazyTemplateLoader
- (id)templateIdForTemplateNamed:(NSString *)name relativeToTemplateId:(id)baseTemplateId {
	return name;
}

- (NSString *)templateStringForTemplateId:(id)templateId error:(NSError **)outError {
	// not lazy because returns nil and set outError
    if (outError != NULL) {
        *outError = [NSError errorWithDomain:@"FailingOnTemplateStringNotLazyTemplateLoader" code:0 userInfo:nil];
    }
	return nil;
}
@end


@implementation GRMustacheTemplateLoaderSubclassTest

- (void)testThatTemplateLoaderSubclassFailingOnTemplateIdGeneratesError {
	GRMustacheTemplateLoader *loader = [[[FailingOnTemplateIdTemplateLoader alloc] initWithExtension:nil encoding:NSUTF8StringEncoding] autorelease];
	NSError *error;
	GRMustacheTemplate *template = [loader parseString:@"{{>partial}}" error:&error];
	STAssertNil(template, nil);
	STAssertNotNil(error, nil);
	STAssertEquals(error.code, (NSInteger)GRMustacheErrorCodeTemplateNotFound, nil);
}

- (void)testThatLazyTemplateLoaderSubclassFailingOnTemplateStringGeneratesError {
	GRMustacheTemplateLoader *loader = [[[FailingOnTemplateStringLazyTemplateLoader alloc] initWithExtension:nil encoding:NSUTF8StringEncoding] autorelease];
	NSError *error;
	GRMustacheTemplate *template = [loader parseString:@"{{>partial}}" error:&error];
	STAssertNil(template, nil);
	STAssertNotNil(error, nil);
	STAssertEquals(error.code, (NSInteger)GRMustacheErrorCodeTemplateNotFound, nil);
}

- (void)testThatNotLazyTemplateLoaderSubclassFailingOnTemplateStringGeneratesError {
	GRMustacheTemplateLoader *loader = [[[FailingOnTemplateStringNotLazyTemplateLoader alloc] initWithExtension:nil encoding:NSUTF8StringEncoding] autorelease];
	NSError *error;
	GRMustacheTemplate *template = [loader parseString:@"{{>partial}}" error:&error];
	STAssertNil(template, nil);
	STAssertNotNil(error, nil);
    STAssertEqualObjects(error.domain, @"FailingOnTemplateStringNotLazyTemplateLoader", @"");
}

@end
