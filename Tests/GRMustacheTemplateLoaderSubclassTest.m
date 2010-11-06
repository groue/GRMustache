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


@implementation GRMustacheTemplateLoaderSubclassTest

- (void)testThatTemplateLoaderSubclassFailingOnTemplateIdGeneratesGRMustacheErrorCodeTemplateNotFound {
	GRMustacheTemplateLoader *loader = [[[FailingOnTemplateIdTemplateLoader alloc] initWithExtension:nil] autorelease];
	NSError *error;
	GRMustacheTemplate *template = [loader parseString:@"{{>partial}}" error:&error];
	STAssertNil(template, nil);
	STAssertNotNil(error, nil);
	STAssertEquals(error.code, (NSInteger)GRMustacheErrorCodeTemplateNotFound, nil);
}

- (void)testThatLazyTemplateLoaderSubclassFailingOnTemplateStringGeneratesGRMustacheErrorCodeTemplateNotFound {
	GRMustacheTemplateLoader *loader = [[[FailingOnTemplateStringLazyTemplateLoader alloc] initWithExtension:nil] autorelease];
	NSError *error;
	GRMustacheTemplate *template = [loader parseString:@"{{>partial}}" error:&error];
	STAssertNil(template, nil);
	STAssertNotNil(error, nil);
	STAssertEquals(error.code, (NSInteger)GRMustacheErrorCodeTemplateNotFound, nil);
}

@end
