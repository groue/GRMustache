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

#import "GRBoolean_v1_0_Test.h"


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

@implementation GRBoolean_v1_0_Test

- (NSInteger)booleanInterpretationForObject:(id)object key:(NSString *)key {
	NSString *templateString = [NSString stringWithFormat:@"{{#%@}}YES{{/%@}}{{^%@}}NO{{/%@}}", key, key, key, key];
	NSString *result = [GRMustacheTemplate renderObject:object fromString:templateString error:nil];
	if ([result isEqualToString:@"YES"]) {
		return YES;
	} else if ([result isEqualToString:@"NO"]) {
		return NO;
	}
	return NSNotFound;
}	

- (void)test_Nil_isFalseValue {
	NSDictionary *context = [NSDictionary dictionary];
	STAssertNil([context valueForKey:@"bool"], nil);
	STAssertEquals((NSInteger)[self booleanInterpretationForObject:context key:@"bool"], (NSInteger)NO, nil);
}

- (void)test_NSNull_isFalseValue {
	NSDictionary *context = [NSDictionary dictionaryWithObject:[NSNull null] forKey:@"bool"];
	STAssertEquals((NSInteger)[self booleanInterpretationForObject:context key:@"bool"], (NSInteger)NO, nil);
}

- (void)test_EmptyString_isFalseValue {
	NSDictionary *context = [NSDictionary dictionaryWithObject:@"" forKey:@"bool"];
	STAssertEquals((NSInteger)[self booleanInterpretationForObject:context key:@"bool"], (NSInteger)NO, nil);
}

- (void)test_GRYes_isTrueValue {
	NSDictionary *context = [NSDictionary dictionaryWithObject:[GRYes yes] forKey:@"bool"];
	STAssertEquals((NSInteger)[self booleanInterpretationForObject:context key:@"bool"], (NSInteger)YES, nil);
}

- (void)test_GRNo_isFalseValue {
	NSDictionary *context = [NSDictionary dictionaryWithObject:[GRNo no] forKey:@"bool"];
	STAssertEquals((NSInteger)[self booleanInterpretationForObject:context key:@"bool"], (NSInteger)NO, nil);
}

- (void)test_NSNumberWithBoolYES_isTrueValue {
	NSDictionary *context = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:@"bool"];
	STAssertEquals((NSInteger)[self booleanInterpretationForObject:context key:@"bool"], (NSInteger)YES, nil);
	STAssertEquals((NSInteger)[self booleanInterpretationForObject:[NSNumber numberWithBool:YES] key:@"."], (NSInteger)YES, nil);
}

- (void)test_NSNumberWithBoolNO_isFalseValue {
	NSDictionary *context = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:@"bool"];
	STAssertEquals((NSInteger)[self booleanInterpretationForObject:context key:@"bool"], (NSInteger)NO, nil);
	STAssertEquals((NSInteger)[self booleanInterpretationForObject:[NSNumber numberWithBool:NO] key:@"."], (NSInteger)NO, nil);
}

@end

@implementation GRStrictBooleanMode_v1_0_Test

- (void)setUp {
	strictBooleanMode = [GRMustache strictBooleanMode];
	[GRMustache setStrictBooleanMode:YES];
	context = [[GRBooleanTestSupport alloc] init];
	inheritingContext = [[GRBooleanTestSupportSubClass alloc] init];
}

- (void)tearDown {
	[GRMustache setStrictBooleanMode:strictBooleanMode];
	[context release];
	[inheritingContext release];
}

- (void)test_boolFalseDeclared_isFalseValue {
	STAssertEquals((NSInteger)[self booleanInterpretationForObject:context key:@"boolFalseDeclared"], (NSInteger)NO, nil);
	STAssertEquals((NSInteger)[self booleanInterpretationForObject:inheritingContext key:@"boolFalseDeclared"], (NSInteger)NO, nil);
}
- (void)test_boolTrueDeclared_isTrueValue {
	STAssertEquals((NSInteger)[self booleanInterpretationForObject:context key:@"boolTrueDeclared"], (NSInteger)YES, nil);
	STAssertEquals((NSInteger)[self booleanInterpretationForObject:inheritingContext key:@"boolTrueDeclared"], (NSInteger)YES, nil);
}
- (void)test_BOOLFalseDeclared_isTrueValue {
	STAssertEquals((NSInteger)[self booleanInterpretationForObject:context key:@"BOOLFalseDeclared"], (NSInteger)YES, nil);
	STAssertEquals((NSInteger)[self booleanInterpretationForObject:inheritingContext key:@"BOOLFalseDeclared"], (NSInteger)YES, nil);
}
- (void)test_BOOLTrueDeclared_isTrueValue {
	STAssertEquals((NSInteger)[self booleanInterpretationForObject:context key:@"BOOLTrueDeclared"], (NSInteger)YES, nil);
	STAssertEquals((NSInteger)[self booleanInterpretationForObject:inheritingContext key:@"BOOLTrueDeclared"], (NSInteger)YES, nil);
}
- (void)test_charFalseDeclared_isTrueValue {
	STAssertEquals((NSInteger)[self booleanInterpretationForObject:context key:@"charFalseDeclared"], (NSInteger)YES, nil);
	STAssertEquals((NSInteger)[self booleanInterpretationForObject:inheritingContext key:@"charFalseDeclared"], (NSInteger)YES, nil);
}
- (void)test_charTrueDeclared_isTrueValue {
	STAssertEquals((NSInteger)[self booleanInterpretationForObject:context key:@"charTrueDeclared"], (NSInteger)YES, nil);
	STAssertEquals((NSInteger)[self booleanInterpretationForObject:inheritingContext key:@"charTrueDeclared"], (NSInteger)YES, nil);
}
- (void)test_unsigned_charFalseDeclared_isTrueValue {
	STAssertEquals((NSInteger)[self booleanInterpretationForObject:context key:@"unsigned_charFalseDeclared"], (NSInteger)YES, nil);
	STAssertEquals((NSInteger)[self booleanInterpretationForObject:inheritingContext key:@"unsigned_charFalseDeclared"], (NSInteger)YES, nil);
}
- (void)test_unsigned_charTrueDeclared_isTrueValue {
	STAssertEquals((NSInteger)[self booleanInterpretationForObject:context key:@"unsigned_charTrueDeclared"], (NSInteger)YES, nil);
	STAssertEquals((NSInteger)[self booleanInterpretationForObject:inheritingContext key:@"unsigned_charTrueDeclared"], (NSInteger)YES, nil);
}
- (void)test_intFalseDeclared_isTrueValue {
	STAssertEquals((NSInteger)[self booleanInterpretationForObject:context key:@"intFalseDeclared"], (NSInteger)YES, nil);
	STAssertEquals((NSInteger)[self booleanInterpretationForObject:inheritingContext key:@"intFalseDeclared"], (NSInteger)YES, nil);
}
- (void)test_intTrueDeclared_isTrueValue {
	STAssertEquals((NSInteger)[self booleanInterpretationForObject:context key:@"intTrueDeclared"], (NSInteger)YES, nil);
	STAssertEquals((NSInteger)[self booleanInterpretationForObject:inheritingContext key:@"intTrueDeclared"], (NSInteger)YES, nil);
}
- (void)test_boolFalseUndeclared_isFalseValue {
	STAssertEquals((NSInteger)[self booleanInterpretationForObject:context key:@"boolFalseUndeclared"], (NSInteger)NO, nil);
	STAssertEquals((NSInteger)[self booleanInterpretationForObject:inheritingContext key:@"boolFalseUndeclared"], (NSInteger)NO, nil);
}
- (void)test_boolTrueUndeclared_isTrueValue {
	STAssertEquals((NSInteger)[self booleanInterpretationForObject:context key:@"boolTrueUndeclared"], (NSInteger)YES, nil);
	STAssertEquals((NSInteger)[self booleanInterpretationForObject:inheritingContext key:@"boolTrueUndeclared"], (NSInteger)YES, nil);
}
- (void)test_BOOLFalseUndeclared_isTrueValue {
	STAssertEquals((NSInteger)[self booleanInterpretationForObject:context key:@"BOOLFalseUndeclared"], (NSInteger)YES, nil);
	STAssertEquals((NSInteger)[self booleanInterpretationForObject:inheritingContext key:@"BOOLFalseUndeclared"], (NSInteger)YES, nil);
}
- (void)test_BOOLTrueUndeclared_isTrueValue {
	STAssertEquals((NSInteger)[self booleanInterpretationForObject:context key:@"BOOLTrueUndeclared"], (NSInteger)YES, nil);
	STAssertEquals((NSInteger)[self booleanInterpretationForObject:inheritingContext key:@"BOOLTrueUndeclared"], (NSInteger)YES, nil);
}
- (void)test_charFalseUndeclared_isTrueValue {
	STAssertEquals((NSInteger)[self booleanInterpretationForObject:context key:@"charFalseUndeclared"], (NSInteger)YES, nil);
	STAssertEquals((NSInteger)[self booleanInterpretationForObject:inheritingContext key:@"charFalseUndeclared"], (NSInteger)YES, nil);
}
- (void)test_charTrueUndeclared_isTrueValue {
	STAssertEquals((NSInteger)[self booleanInterpretationForObject:context key:@"charTrueUndeclared"], (NSInteger)YES, nil);
	STAssertEquals((NSInteger)[self booleanInterpretationForObject:inheritingContext key:@"charTrueUndeclared"], (NSInteger)YES, nil);
}
- (void)test_unsigned_charFalseUndeclared_isTrueValue {
	STAssertEquals((NSInteger)[self booleanInterpretationForObject:context key:@"unsigned_charFalseUndeclared"], (NSInteger)YES, nil);
	STAssertEquals((NSInteger)[self booleanInterpretationForObject:inheritingContext key:@"unsigned_charFalseUndeclared"], (NSInteger)YES, nil);
}
- (void)test_unsigned_charTrueUndeclared_isTrueValue {
	STAssertEquals((NSInteger)[self booleanInterpretationForObject:context key:@"unsigned_charTrueUndeclared"], (NSInteger)YES, nil);
	STAssertEquals((NSInteger)[self booleanInterpretationForObject:inheritingContext key:@"unsigned_charTrueUndeclared"], (NSInteger)YES, nil);
}
- (void)test_intFalseUndeclared_isTrueValue {
	STAssertEquals((NSInteger)[self booleanInterpretationForObject:context key:@"intFalseUndeclared"], (NSInteger)YES, nil);
	STAssertEquals((NSInteger)[self booleanInterpretationForObject:inheritingContext key:@"intFalseUndeclared"], (NSInteger)YES, nil);
}
- (void)test_intTrueUndeclared_isTrueValue {
	STAssertEquals((NSInteger)[self booleanInterpretationForObject:context key:@"intTrueUndeclared"], (NSInteger)YES, nil);
	STAssertEquals((NSInteger)[self booleanInterpretationForObject:inheritingContext key:@"intTrueUndeclared"], (NSInteger)YES, nil);
}

@end



@implementation GRNotStrictBooleanMode_v1_0_Test

- (void)setUp {
	strictBooleanMode = [GRMustache strictBooleanMode];
	[GRMustache setStrictBooleanMode:NO];
	context = [[GRBooleanTestSupport alloc] init];
	inheritingContext = [[GRBooleanTestSupportSubClass alloc] init];
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
	STAssertEquals((NSInteger)[self booleanInterpretationForObject:context key:@"boolFalseDeclared"], (NSInteger)NO, nil);
	STAssertEquals((NSInteger)[self booleanInterpretationForObject:inheritingContext key:@"boolFalseDeclared"], (NSInteger)NO, nil);
}
- (void)test_boolTrueDeclared_isTrueValue {
	STAssertEquals((NSInteger)[self booleanInterpretationForObject:context key:@"boolTrueDeclared"], (NSInteger)YES, nil);
	STAssertEquals((NSInteger)[self booleanInterpretationForObject:inheritingContext key:@"boolTrueDeclared"], (NSInteger)YES, nil);
}
- (void)test_BOOLFalseDeclared_isFalseValue {
	STAssertEquals((NSInteger)[self booleanInterpretationForObject:context key:@"BOOLFalseDeclared"], (NSInteger)NO, nil);
	STAssertEquals((NSInteger)[self booleanInterpretationForObject:inheritingContext key:@"BOOLFalseDeclared"], (NSInteger)NO, nil);
}
- (void)test_BOOLTrueDeclared_isTrueValue {
	STAssertEquals((NSInteger)[self booleanInterpretationForObject:context key:@"BOOLTrueDeclared"], (NSInteger)YES, nil);
	STAssertEquals((NSInteger)[self booleanInterpretationForObject:inheritingContext key:@"BOOLTrueDeclared"], (NSInteger)YES, nil);
}
- (void)test_charFalseDeclared_isFalseValue {
	STAssertEquals((NSInteger)[self booleanInterpretationForObject:context key:@"charFalseDeclared"], (NSInteger)NO, nil);
	STAssertEquals((NSInteger)[self booleanInterpretationForObject:inheritingContext key:@"charFalseDeclared"], (NSInteger)NO, nil);
}
- (void)test_charTrueDeclared_isTrueValue {
	STAssertEquals((NSInteger)[self booleanInterpretationForObject:context key:@"charTrueDeclared"], (NSInteger)YES, nil);
	STAssertEquals((NSInteger)[self booleanInterpretationForObject:inheritingContext key:@"charTrueDeclared"], (NSInteger)YES, nil);
}
- (void)test_unsigned_charFalseDeclared_isTrueValue {
	STAssertEquals((NSInteger)[self booleanInterpretationForObject:context key:@"unsigned_charFalseDeclared"], (NSInteger)YES, nil);
	STAssertEquals((NSInteger)[self booleanInterpretationForObject:inheritingContext key:@"unsigned_charFalseDeclared"], (NSInteger)YES, nil);
}
- (void)test_unsigned_charTrueDeclared_isTrueValue {
	STAssertEquals((NSInteger)[self booleanInterpretationForObject:context key:@"unsigned_charTrueDeclared"], (NSInteger)YES, nil);
	STAssertEquals((NSInteger)[self booleanInterpretationForObject:inheritingContext key:@"unsigned_charTrueDeclared"], (NSInteger)YES, nil);
}
- (void)test_intFalseDeclared_isTrueValue {
	STAssertEquals((NSInteger)[self booleanInterpretationForObject:context key:@"intFalseDeclared"], (NSInteger)YES, nil);
	STAssertEquals((NSInteger)[self booleanInterpretationForObject:inheritingContext key:@"intFalseDeclared"], (NSInteger)YES, nil);
}
- (void)test_intTrueDeclared_isTrueValue {
	STAssertEquals((NSInteger)[self booleanInterpretationForObject:context key:@"intTrueDeclared"], (NSInteger)YES, nil);
	STAssertEquals((NSInteger)[self booleanInterpretationForObject:inheritingContext key:@"intTrueDeclared"], (NSInteger)YES, nil);
}
- (void)test_boolFalseUndeclared_isFalseValue {
	STAssertEquals((NSInteger)[self booleanInterpretationForObject:context key:@"boolFalseUndeclared"], (NSInteger)NO, nil);
	STAssertEquals((NSInteger)[self booleanInterpretationForObject:inheritingContext key:@"boolFalseUndeclared"], (NSInteger)NO, nil);
}
- (void)test_boolTrueUndeclared_isTrueValue {
	STAssertEquals((NSInteger)[self booleanInterpretationForObject:context key:@"boolTrueUndeclared"], (NSInteger)YES, nil);
	STAssertEquals((NSInteger)[self booleanInterpretationForObject:inheritingContext key:@"boolTrueUndeclared"], (NSInteger)YES, nil);
}
- (void)test_BOOLFalseUndeclared_isTrueValue {
	STAssertEquals((NSInteger)[self booleanInterpretationForObject:context key:@"BOOLFalseUndeclared"], (NSInteger)YES, nil);
	STAssertEquals((NSInteger)[self booleanInterpretationForObject:inheritingContext key:@"BOOLFalseUndeclared"], (NSInteger)YES, nil);
}
- (void)test_BOOLTrueUndeclared_isTrueValue {
	STAssertEquals((NSInteger)[self booleanInterpretationForObject:context key:@"BOOLTrueUndeclared"], (NSInteger)YES, nil);
	STAssertEquals((NSInteger)[self booleanInterpretationForObject:inheritingContext key:@"BOOLTrueUndeclared"], (NSInteger)YES, nil);
}
- (void)test_charFalseUndeclared_isTrueValue {
	STAssertEquals((NSInteger)[self booleanInterpretationForObject:context key:@"charFalseUndeclared"], (NSInteger)YES, nil);
	STAssertEquals((NSInteger)[self booleanInterpretationForObject:inheritingContext key:@"charFalseUndeclared"], (NSInteger)YES, nil);
}
- (void)test_charTrueUndeclared_isTrueValue {
	STAssertEquals((NSInteger)[self booleanInterpretationForObject:context key:@"charTrueUndeclared"], (NSInteger)YES, nil);
	STAssertEquals((NSInteger)[self booleanInterpretationForObject:inheritingContext key:@"charTrueUndeclared"], (NSInteger)YES, nil);
}
- (void)test_unsigned_charFalseUndeclared_isTrueValue {
	STAssertEquals((NSInteger)[self booleanInterpretationForObject:context key:@"unsigned_charFalseUndeclared"], (NSInteger)YES, nil);
	STAssertEquals((NSInteger)[self booleanInterpretationForObject:inheritingContext key:@"unsigned_charFalseUndeclared"], (NSInteger)YES, nil);
}
- (void)test_unsigned_charTrueUndeclared_isTrueValue {
	STAssertEquals((NSInteger)[self booleanInterpretationForObject:context key:@"unsigned_charTrueUndeclared"], (NSInteger)YES, nil);
	STAssertEquals((NSInteger)[self booleanInterpretationForObject:inheritingContext key:@"unsigned_charTrueUndeclared"], (NSInteger)YES, nil);
}
- (void)test_intFalseUndeclared_isTrueValue {
	STAssertEquals((NSInteger)[self booleanInterpretationForObject:context key:@"intFalseUndeclared"], (NSInteger)YES, nil);
	STAssertEquals((NSInteger)[self booleanInterpretationForObject:inheritingContext key:@"intFalseUndeclared"], (NSInteger)YES, nil);
}
- (void)test_intTrueUndeclared_isTrueValue {
	STAssertEquals((NSInteger)[self booleanInterpretationForObject:context key:@"intTrueUndeclared"], (NSInteger)YES, nil);
	STAssertEquals((NSInteger)[self booleanInterpretationForObject:inheritingContext key:@"intTrueUndeclared"], (NSInteger)YES, nil);
}

@end

