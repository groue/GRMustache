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

#import "GRBooleanTest.h"
#import "GRMustache_private.h"
#import "GRMustacheContext_private.h"


@interface GRBooleanTestSupport: NSObject
@property (readonly) bool boolFalseDeclared;
@property (readonly) bool boolTrueDeclared;
@property (readonly) BOOL BOOLFalseDeclared;
@property (readonly) BOOL BOOLTrueDeclared;
@property (readonly) char charFalseDeclared;
@property (readonly) char charTrueDeclared;
@property (readonly) unsigned char unsigned_charFalseDeclared;
@property (readonly) unsigned char unsigned_charTrueDeclared;
@property (readonly) int intFalseDeclared;
@property (readonly) int intTrueDeclared;
@end

@implementation GRBooleanTestSupport
- (bool)boolFalseUndeclared { return NO; }
- (bool)boolTrueUndeclared { return YES; }
- (BOOL)BOOLFalseUndeclared { return NO; }
- (BOOL)BOOLTrueUndeclared { return YES; }
- (char)charFalseUndeclared { return NO; }
- (char)charTrueUndeclared { return YES; }
- (unsigned char)unsigned_charFalseUndeclared { return NO; }
- (unsigned char)unsigned_charTrueUndeclared { return YES; }
- (int)intFalseUndeclared { return NO; }
- (int)intTrueUndeclared { return YES; }
- (bool)boolFalseDeclared { return NO; }
- (bool)boolTrueDeclared { return YES; }
- (BOOL)BOOLFalseDeclared { return NO; }
- (BOOL)BOOLTrueDeclared { return YES; }
- (char)charFalseDeclared { return NO; }
- (char)charTrueDeclared { return YES; }
- (unsigned char)unsigned_charFalseDeclared { return NO; }
- (unsigned char)unsigned_charTrueDeclared { return YES; }
- (int)intFalseDeclared { return NO; }
- (int)intTrueDeclared { return YES; }
@end

@interface GRBooleanTestSupportSubClass: GRBooleanTestSupport
@end

@implementation GRBooleanTestSupportSubClass
@end

@interface GRBooleanTestCustomGetter: NSObject {
	BOOL dead;
}
@property (getter=isDead) BOOL dead;
@end

@implementation GRBooleanTestCustomGetter
@synthesize dead;
@end

@implementation GRBooleanTest

- (void)testGRYesBoolValueIsYES {
	STAssertEquals((int)[[GRYes yes] boolValue], (int)YES, nil);
}

- (void)testGRNoBoolValueIsNO {
	STAssertEquals((int)[[GRNo no] boolValue], (int)NO, nil);
}

- (void)testGRYesIsTrueObject {
	STAssertEquals([GRMustache objectKind:[GRYes yes]], GRMustacheObjectKindTrueValue, nil);
}

- (void)testGRNoIsFalseObject {
	STAssertEquals([GRMustache objectKind:[GRNo no]], GRMustacheObjectKindFalseValue, nil);
}

- (void)testNilIsAFalseValue {
	NSString *templateString = @"{{#bool}}YES{{/bool}}{{^bool}}NO{{/bool}}";
	NSDictionary *context = [NSDictionary dictionary];
	STAssertNil([context valueForKey:@"bool"], nil);
	NSString *result = [GRMustacheTemplate renderObject:context fromString:templateString error:nil];
	STAssertEqualObjects(result, @"NO", nil);
}

- (void)testNSNullIsAFalseValue {
	NSString *templateString = @"{{#bool}}YES{{/bool}}{{^bool}}NO{{/bool}}";
	NSDictionary *context = [NSDictionary dictionaryWithObject:[NSNull null] forKey:@"bool"];
	NSString *result = [GRMustacheTemplate renderObject:context fromString:templateString error:nil];
	STAssertEqualObjects(result, @"NO", nil);
}

- (void)testGRNoIsAFalseValue {
	NSString *templateString = @"{{#bool}}YES{{/bool}}{{^bool}}NO{{/bool}}";
	NSDictionary *context = [NSDictionary dictionaryWithObject:[GRNo no] forKey:@"bool"];
	NSString *result = [GRMustacheTemplate renderObject:context fromString:templateString error:nil];
	STAssertEqualObjects(result, @"NO", nil);
}

- (void)testEmptyStringIsAFalseValue {
	NSString *templateString = @"{{#bool}}YES{{/bool}}{{^bool}}NO{{/bool}}";
	NSDictionary *context = [NSDictionary dictionaryWithObject:@"" forKey:@"bool"];
	NSString *result = [GRMustacheTemplate renderObject:context fromString:templateString error:nil];
	STAssertEqualObjects(result, @"NO", nil);
}

- (void)testGRYesIsATrueValue {
	NSString *templateString = @"{{#bool}}YES{{/bool}}{{^bool}}NO{{/bool}}";
	NSDictionary *context = [NSDictionary dictionaryWithObject:[GRYes yes] forKey:@"bool"];
	NSString *result = [GRMustacheTemplate renderObject:context fromString:templateString error:nil];
	STAssertEqualObjects(result, @"YES", nil);
}

@end



@implementation GRStrictBooleanModeTest

- (void)setUp {
	strictBooleanMode = [GRMustache strictBooleanMode];
	[GRMustache setStrictBooleanMode:YES];
	context = [[GRMustacheContext contextWithObject:[[[GRBooleanTestSupport alloc] init] autorelease]] retain];
	inheritingContext = [[GRMustacheContext contextWithObject:[[[GRBooleanTestSupportSubClass alloc] init] autorelease]] retain];
}

- (void)tearDown {
	[GRMustache setStrictBooleanMode:strictBooleanMode];
	[context release];
	[inheritingContext release];
}

- (void)test_boolFalseDeclared_isFalseValue {
	STAssertEquals([GRMustache objectKind:[context valueForKey:@"boolFalseDeclared"]], GRMustacheObjectKindFalseValue, nil);
	STAssertEquals([GRMustache objectKind:[inheritingContext valueForKey:@"boolFalseDeclared"]], GRMustacheObjectKindFalseValue, nil);
}
- (void)test_boolTrueDeclared_isTrueValue {
	STAssertEquals([GRMustache objectKind:[context valueForKey:@"boolTrueDeclared"]], GRMustacheObjectKindTrueValue, nil);
	STAssertEquals([GRMustache objectKind:[inheritingContext valueForKey:@"boolTrueDeclared"]], GRMustacheObjectKindTrueValue, nil);
}
- (void)test_BOOLFalseDeclared_isTrueValue {
	STAssertEquals([GRMustache objectKind:[context valueForKey:@"BOOLFalseDeclared"]], GRMustacheObjectKindTrueValue, nil);
	STAssertEquals([GRMustache objectKind:[inheritingContext valueForKey:@"BOOLFalseDeclared"]], GRMustacheObjectKindTrueValue, nil);
}
- (void)test_BOOLTrueDeclared_isTrueValue {
	STAssertEquals([GRMustache objectKind:[context valueForKey:@"BOOLTrueDeclared"]], GRMustacheObjectKindTrueValue, nil);
	STAssertEquals([GRMustache objectKind:[inheritingContext valueForKey:@"BOOLTrueDeclared"]], GRMustacheObjectKindTrueValue, nil);
}
- (void)test_charFalseDeclared_isTrueValue {
	STAssertEquals([GRMustache objectKind:[context valueForKey:@"charFalseDeclared"]], GRMustacheObjectKindTrueValue, nil);
	STAssertEquals([GRMustache objectKind:[inheritingContext valueForKey:@"charFalseDeclared"]], GRMustacheObjectKindTrueValue, nil);
}
- (void)test_charTrueDeclared_isTrueValue {
	STAssertEquals([GRMustache objectKind:[context valueForKey:@"charTrueDeclared"]], GRMustacheObjectKindTrueValue, nil);
	STAssertEquals([GRMustache objectKind:[inheritingContext valueForKey:@"charTrueDeclared"]], GRMustacheObjectKindTrueValue, nil);
}
- (void)test_unsigned_charFalseDeclared_isTrueValue {
	STAssertEquals([GRMustache objectKind:[context valueForKey:@"unsigned_charFalseDeclared"]], GRMustacheObjectKindTrueValue, nil);
	STAssertEquals([GRMustache objectKind:[inheritingContext valueForKey:@"unsigned_charFalseDeclared"]], GRMustacheObjectKindTrueValue, nil);
}
- (void)test_unsigned_charTrueDeclared_isTrueValue {
	STAssertEquals([GRMustache objectKind:[context valueForKey:@"unsigned_charTrueDeclared"]], GRMustacheObjectKindTrueValue, nil);
	STAssertEquals([GRMustache objectKind:[inheritingContext valueForKey:@"unsigned_charTrueDeclared"]], GRMustacheObjectKindTrueValue, nil);
}
- (void)test_intFalseDeclared_isTrueValue {
	STAssertEquals([GRMustache objectKind:[context valueForKey:@"intFalseDeclared"]], GRMustacheObjectKindTrueValue, nil);
	STAssertEquals([GRMustache objectKind:[inheritingContext valueForKey:@"intFalseDeclared"]], GRMustacheObjectKindTrueValue, nil);
}
- (void)test_intTrueDeclared_isTrueValue {
	STAssertEquals([GRMustache objectKind:[context valueForKey:@"intTrueDeclared"]], GRMustacheObjectKindTrueValue, nil);
	STAssertEquals([GRMustache objectKind:[inheritingContext valueForKey:@"intTrueDeclared"]], GRMustacheObjectKindTrueValue, nil);
}
- (void)test_boolFalseUndeclared_isFalseValue {
	STAssertEquals([GRMustache objectKind:[context valueForKey:@"boolFalseUndeclared"]], GRMustacheObjectKindFalseValue, nil);
	STAssertEquals([GRMustache objectKind:[inheritingContext valueForKey:@"boolFalseUndeclared"]], GRMustacheObjectKindFalseValue, nil);
}
- (void)test_boolTrueUndeclared_isTrueValue {
	STAssertEquals([GRMustache objectKind:[context valueForKey:@"boolTrueUndeclared"]], GRMustacheObjectKindTrueValue, nil);
	STAssertEquals([GRMustache objectKind:[inheritingContext valueForKey:@"boolTrueUndeclared"]], GRMustacheObjectKindTrueValue, nil);
}
- (void)test_BOOLFalseUndeclared_isTrueValue {
	STAssertEquals([GRMustache objectKind:[context valueForKey:@"BOOLFalseUndeclared"]], GRMustacheObjectKindTrueValue, nil);
	STAssertEquals([GRMustache objectKind:[inheritingContext valueForKey:@"BOOLFalseUndeclared"]], GRMustacheObjectKindTrueValue, nil);
}
- (void)test_BOOLTrueUndeclared_isTrueValue {
	STAssertEquals([GRMustache objectKind:[context valueForKey:@"BOOLTrueUndeclared"]], GRMustacheObjectKindTrueValue, nil);
	STAssertEquals([GRMustache objectKind:[inheritingContext valueForKey:@"BOOLTrueUndeclared"]], GRMustacheObjectKindTrueValue, nil);
}
- (void)test_charFalseUndeclared_isTrueValue {
	STAssertEquals([GRMustache objectKind:[context valueForKey:@"charFalseUndeclared"]], GRMustacheObjectKindTrueValue, nil);
	STAssertEquals([GRMustache objectKind:[inheritingContext valueForKey:@"charFalseUndeclared"]], GRMustacheObjectKindTrueValue, nil);
}
- (void)test_charTrueUndeclared_isTrueValue {
	STAssertEquals([GRMustache objectKind:[context valueForKey:@"charTrueUndeclared"]], GRMustacheObjectKindTrueValue, nil);
	STAssertEquals([GRMustache objectKind:[inheritingContext valueForKey:@"charTrueUndeclared"]], GRMustacheObjectKindTrueValue, nil);
}
- (void)test_unsigned_charFalseUndeclared_isTrueValue {
	STAssertEquals([GRMustache objectKind:[context valueForKey:@"unsigned_charFalseUndeclared"]], GRMustacheObjectKindTrueValue, nil);
	STAssertEquals([GRMustache objectKind:[inheritingContext valueForKey:@"unsigned_charFalseUndeclared"]], GRMustacheObjectKindTrueValue, nil);
}
- (void)test_unsigned_charTrueUndeclared_isTrueValue {
	STAssertEquals([GRMustache objectKind:[context valueForKey:@"unsigned_charTrueUndeclared"]], GRMustacheObjectKindTrueValue, nil);
	STAssertEquals([GRMustache objectKind:[inheritingContext valueForKey:@"unsigned_charTrueUndeclared"]], GRMustacheObjectKindTrueValue, nil);
}
- (void)test_intFalseUndeclared_isTrueValue {
	STAssertEquals([GRMustache objectKind:[context valueForKey:@"intFalseUndeclared"]], GRMustacheObjectKindTrueValue, nil);
	STAssertEquals([GRMustache objectKind:[inheritingContext valueForKey:@"intFalseUndeclared"]], GRMustacheObjectKindTrueValue, nil);
}
- (void)test_intTrueUndeclared_isTrueValue {
	STAssertEquals([GRMustache objectKind:[context valueForKey:@"intTrueUndeclared"]], GRMustacheObjectKindTrueValue, nil);
	STAssertEquals([GRMustache objectKind:[inheritingContext valueForKey:@"intTrueUndeclared"]], GRMustacheObjectKindTrueValue, nil);
}

@end



@implementation GRNotStrictBooleanModeTest

- (void)setUp {
	strictBooleanMode = [GRMustache strictBooleanMode];
	[GRMustache setStrictBooleanMode:NO];
	context = [[GRMustacheContext contextWithObject:[[[GRBooleanTestSupport alloc] init] autorelease]] retain];
	inheritingContext = [[GRMustacheContext contextWithObject:[[[GRBooleanTestSupportSubClass alloc] init] autorelease]] retain];
}

- (void)tearDown {
	[GRMustache setStrictBooleanMode:strictBooleanMode];
	[context release];
	[inheritingContext release];
}

- (void)testCustomGetterForBOOLPropertyIsTrueValue {
	GRBooleanTestCustomGetter *object = [[[GRBooleanTestCustomGetter alloc] init] autorelease];
	NSString *templateString = @"{{#dead}}dead{{/dead}}{{#isDead}}isDead{{/isDead}}";
	GRMustacheTemplate *template = [GRMustacheTemplate parseString:templateString error:nil];
	NSString *result;
	
	object.dead = NO;
	result = [template renderObject:object];
	STAssertEqualObjects(result, @"isDead", nil);
	
	object.dead = YES;
	result = [template renderObject:object];
	STAssertEqualObjects(result, @"deadisDead", nil);
}

- (void)test_boolFalseDeclared_isFalseValue {
	STAssertEquals([GRMustache objectKind:[context valueForKey:@"boolFalseDeclared"]], GRMustacheObjectKindFalseValue, nil);
	STAssertEquals([GRMustache objectKind:[inheritingContext valueForKey:@"boolFalseDeclared"]], GRMustacheObjectKindFalseValue, nil);
}
- (void)test_boolTrueDeclared_isTrueValue {
	STAssertEquals([GRMustache objectKind:[context valueForKey:@"boolTrueDeclared"]], GRMustacheObjectKindTrueValue, nil);
	STAssertEquals([GRMustache objectKind:[inheritingContext valueForKey:@"boolTrueDeclared"]], GRMustacheObjectKindTrueValue, nil);
}
- (void)test_BOOLFalseDeclared_isFalseValue {
	STAssertEquals([GRMustache objectKind:[context valueForKey:@"BOOLFalseDeclared"]], GRMustacheObjectKindFalseValue, nil);
	STAssertEquals([GRMustache objectKind:[inheritingContext valueForKey:@"BOOLFalseDeclared"]], GRMustacheObjectKindFalseValue, nil);
}
- (void)test_BOOLTrueDeclared_isTrueValue {
	STAssertEquals([GRMustache objectKind:[context valueForKey:@"BOOLTrueDeclared"]], GRMustacheObjectKindTrueValue, nil);
	STAssertEquals([GRMustache objectKind:[inheritingContext valueForKey:@"BOOLTrueDeclared"]], GRMustacheObjectKindTrueValue, nil);
}
- (void)test_charFalseDeclared_isFalseValue {
	STAssertEquals([GRMustache objectKind:[context valueForKey:@"charFalseDeclared"]], GRMustacheObjectKindFalseValue, nil);
	STAssertEquals([GRMustache objectKind:[inheritingContext valueForKey:@"charFalseDeclared"]], GRMustacheObjectKindFalseValue, nil);
}
- (void)test_charTrueDeclared_isTrueValue {
	STAssertEquals([GRMustache objectKind:[context valueForKey:@"charTrueDeclared"]], GRMustacheObjectKindTrueValue, nil);
	STAssertEquals([GRMustache objectKind:[inheritingContext valueForKey:@"charTrueDeclared"]], GRMustacheObjectKindTrueValue, nil);
}
- (void)test_unsigned_charFalseDeclared_isTrueValue {
	STAssertEquals([GRMustache objectKind:[context valueForKey:@"unsigned_charFalseDeclared"]], GRMustacheObjectKindTrueValue, nil);
	STAssertEquals([GRMustache objectKind:[inheritingContext valueForKey:@"unsigned_charFalseDeclared"]], GRMustacheObjectKindTrueValue, nil);
}
- (void)test_unsigned_charTrueDeclared_isTrueValue {
	STAssertEquals([GRMustache objectKind:[context valueForKey:@"unsigned_charTrueDeclared"]], GRMustacheObjectKindTrueValue, nil);
	STAssertEquals([GRMustache objectKind:[inheritingContext valueForKey:@"unsigned_charTrueDeclared"]], GRMustacheObjectKindTrueValue, nil);
}
- (void)test_intFalseDeclared_isTrueValue {
	STAssertEquals([GRMustache objectKind:[context valueForKey:@"intFalseDeclared"]], GRMustacheObjectKindTrueValue, nil);
	STAssertEquals([GRMustache objectKind:[inheritingContext valueForKey:@"intFalseDeclared"]], GRMustacheObjectKindTrueValue, nil);
}
- (void)test_intTrueDeclared_isTrueValue {
	STAssertEquals([GRMustache objectKind:[context valueForKey:@"intTrueDeclared"]], GRMustacheObjectKindTrueValue, nil);
	STAssertEquals([GRMustache objectKind:[inheritingContext valueForKey:@"intTrueDeclared"]], GRMustacheObjectKindTrueValue, nil);
}
- (void)test_boolFalseUndeclared_isFalseValue {
	STAssertEquals([GRMustache objectKind:[context valueForKey:@"boolFalseUndeclared"]], GRMustacheObjectKindFalseValue, nil);
	STAssertEquals([GRMustache objectKind:[inheritingContext valueForKey:@"boolFalseUndeclared"]], GRMustacheObjectKindFalseValue, nil);
}
- (void)test_boolTrueUndeclared_isTrueValue {
	STAssertEquals([GRMustache objectKind:[context valueForKey:@"boolTrueUndeclared"]], GRMustacheObjectKindTrueValue, nil);
	STAssertEquals([GRMustache objectKind:[inheritingContext valueForKey:@"boolTrueUndeclared"]], GRMustacheObjectKindTrueValue, nil);
}
- (void)test_BOOLFalseUndeclared_isTrueValue {
	STAssertEquals([GRMustache objectKind:[context valueForKey:@"BOOLFalseUndeclared"]], GRMustacheObjectKindTrueValue, nil);
	STAssertEquals([GRMustache objectKind:[inheritingContext valueForKey:@"BOOLFalseUndeclared"]], GRMustacheObjectKindTrueValue, nil);
}
- (void)test_BOOLTrueUndeclared_isTrueValue {
	STAssertEquals([GRMustache objectKind:[context valueForKey:@"BOOLTrueUndeclared"]], GRMustacheObjectKindTrueValue, nil);
	STAssertEquals([GRMustache objectKind:[inheritingContext valueForKey:@"BOOLTrueUndeclared"]], GRMustacheObjectKindTrueValue, nil);
}
- (void)test_charFalseUndeclared_isTrueValue {
	STAssertEquals([GRMustache objectKind:[context valueForKey:@"charFalseUndeclared"]], GRMustacheObjectKindTrueValue, nil);
	STAssertEquals([GRMustache objectKind:[inheritingContext valueForKey:@"charFalseUndeclared"]], GRMustacheObjectKindTrueValue, nil);
}
- (void)test_charTrueUndeclared_isTrueValue {
	STAssertEquals([GRMustache objectKind:[context valueForKey:@"charTrueUndeclared"]], GRMustacheObjectKindTrueValue, nil);
	STAssertEquals([GRMustache objectKind:[inheritingContext valueForKey:@"charTrueUndeclared"]], GRMustacheObjectKindTrueValue, nil);
}
- (void)test_unsigned_charFalseUndeclared_isTrueValue {
	STAssertEquals([GRMustache objectKind:[context valueForKey:@"unsigned_charFalseUndeclared"]], GRMustacheObjectKindTrueValue, nil);
	STAssertEquals([GRMustache objectKind:[inheritingContext valueForKey:@"unsigned_charFalseUndeclared"]], GRMustacheObjectKindTrueValue, nil);
}
- (void)test_unsigned_charTrueUndeclared_isTrueValue {
	STAssertEquals([GRMustache objectKind:[context valueForKey:@"unsigned_charTrueUndeclared"]], GRMustacheObjectKindTrueValue, nil);
	STAssertEquals([GRMustache objectKind:[inheritingContext valueForKey:@"unsigned_charTrueUndeclared"]], GRMustacheObjectKindTrueValue, nil);
}
- (void)test_intFalseUndeclared_isTrueValue {
	STAssertEquals([GRMustache objectKind:[context valueForKey:@"intFalseUndeclared"]], GRMustacheObjectKindTrueValue, nil);
	STAssertEquals([GRMustache objectKind:[inheritingContext valueForKey:@"intFalseUndeclared"]], GRMustacheObjectKindTrueValue, nil);
}
- (void)test_intTrueUndeclared_isTrueValue {
	STAssertEquals([GRMustache objectKind:[context valueForKey:@"intTrueUndeclared"]], GRMustacheObjectKindTrueValue, nil);
	STAssertEquals([GRMustache objectKind:[inheritingContext valueForKey:@"intTrueUndeclared"]], GRMustacheObjectKindTrueValue, nil);
}

@end

