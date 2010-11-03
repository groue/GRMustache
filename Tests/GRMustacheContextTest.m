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

#import "GRMustacheContextTest.h"
#import "GRMustacheContext_private.h"


@interface GRPerson: NSObject {
	NSString *name;
}
@property (nonatomic, retain) NSString *name;
@end

@implementation GRPerson
@synthesize name;
+ (id)personWithName:(NSString *)name {
	GRPerson *person = [[[self alloc] init] autorelease];
	person.name = name;
	return person;
}
- (void)dealloc {
	[name release];
	[super dealloc];
}
@end

@interface GRPersonContext:GRPerson<GRMustacheContext>
@end


@implementation GRMustacheContextTest

- (void)testContextInitedWithNilIsValid {
	STAssertNoThrow([GRMustacheContext contextWithObject:nil], nil);
}

- (void)testContextInitedWithNSNullIsValid {
	STAssertNoThrow([GRMustacheContext contextWithObject:[NSNull null]], nil);
}

- (void)testContextInitedWithRegularObjectIsValid {
	STAssertNoThrow([GRMustacheContext contextWithObject:@"foo"], nil);
}

- (void)testContextInitedWithLambdaIsInvalid {
	GRMustacheLambda lambda = GRMustacheLambdaMake(^(GRMustacheRenderer renderer, GRMustacheContext *context, NSString *templateString) {
		return renderer();
	});
	STAssertThrows([GRMustacheContext contextWithObject:lambda], nil);
}

- (void)testContextInitedWithContextIsValid {
	GRMustacheContext *context = [GRMustacheContext contextWithObject:nil];
	STAssertNoThrow([GRMustacheContext contextWithObject:context], nil);
}

- (void)testContextInitedWithEnumerableIsInvalid {
	STAssertThrows([GRMustacheContext contextWithObject:[NSArray array]], nil);
}

- (void)testContextInitedWithDictionaryIsInvalid {
	STAssertNoThrow([GRMustacheContext contextWithObject:[NSDictionary dictionary]], nil);
}

@end
