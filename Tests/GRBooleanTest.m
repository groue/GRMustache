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

@implementation GRBooleanTest

- (void)testGRYesIsTrueObject {
	STAssertEquals([GRMustache objectKind:[GRYes yes]], GRMustacheObjectKindTrueValue, nil);
}

- (void)testGRNoIsFalseObject {
	STAssertEquals([GRMustache objectKind:[GRNo no]], GRMustacheObjectKindFalseValue, nil);
}

@end



@implementation GRBooleanKVCTestStrictBooleanMode

- (void)setUp {
	strictBooleanMode = [GRMustacheContext strictBooleanMode];
	[GRMustacheContext setStrictBooleanMode:YES];
	context = [[GRMustacheContext contextWithObject:[[[GRBooleanTestSupport alloc] init] autorelease]] retain];
}

- (void)tearDown {
	[GRMustacheContext setStrictBooleanMode:strictBooleanMode];
	[context release];
}

- (void)test_boolFalseDeclared_isFalseObject {
	STAssertEquals([GRMustache objectKind:[context valueForKey:@"boolFalseDeclared"]], GRMustacheObjectKindFalseValue, nil);
}
- (void)test_boolTrueDeclared_isTrueObject {
	STAssertEquals([GRMustache objectKind:[context valueForKey:@"boolTrueDeclared"]], GRMustacheObjectKindTrueValue, nil);
}
- (void)test_BOOLFalseDeclared_isTrueObject {
	STAssertEquals([GRMustache objectKind:[context valueForKey:@"BOOLFalseDeclared"]], GRMustacheObjectKindTrueValue, nil);
}
- (void)test_BOOLTrueDeclared_isTrueObject {
	STAssertEquals([GRMustache objectKind:[context valueForKey:@"BOOLTrueDeclared"]], GRMustacheObjectKindTrueValue, nil);
}
- (void)test_charFalseDeclared_isTrueObject {
	STAssertEquals([GRMustache objectKind:[context valueForKey:@"charFalseDeclared"]], GRMustacheObjectKindTrueValue, nil);
}
- (void)test_charTrueDeclared_isTrueObject {
	STAssertEquals([GRMustache objectKind:[context valueForKey:@"charTrueDeclared"]], GRMustacheObjectKindTrueValue, nil);
}
- (void)test_unsigned_charFalseDeclared_isTrueObject {
	STAssertEquals([GRMustache objectKind:[context valueForKey:@"unsigned_charFalseDeclared"]], GRMustacheObjectKindTrueValue, nil);
}
- (void)test_unsigned_charTrueDeclared_isTrueObject {
	STAssertEquals([GRMustache objectKind:[context valueForKey:@"unsigned_charTrueDeclared"]], GRMustacheObjectKindTrueValue, nil);
}
- (void)test_intFalseDeclared_isTrueObject {
	STAssertEquals([GRMustache objectKind:[context valueForKey:@"intFalseDeclared"]], GRMustacheObjectKindTrueValue, nil);
}
- (void)test_intTrueDeclared_isTrueObject {
	STAssertEquals([GRMustache objectKind:[context valueForKey:@"intTrueDeclared"]], GRMustacheObjectKindTrueValue, nil);
}
- (void)test_boolFalseUndeclared_isFalseObject {
	STAssertEquals([GRMustache objectKind:[context valueForKey:@"boolFalseUndeclared"]], GRMustacheObjectKindFalseValue, nil);
}
- (void)test_boolTrueUndeclared_isTrueObject {
	STAssertEquals([GRMustache objectKind:[context valueForKey:@"boolTrueUndeclared"]], GRMustacheObjectKindTrueValue, nil);
}
- (void)test_BOOLFalseUndeclared_isTrueObject {
	STAssertEquals([GRMustache objectKind:[context valueForKey:@"BOOLFalseUndeclared"]], GRMustacheObjectKindTrueValue, nil);
}
- (void)test_BOOLTrueUndeclared_isTrueObject {
	STAssertEquals([GRMustache objectKind:[context valueForKey:@"BOOLTrueUndeclared"]], GRMustacheObjectKindTrueValue, nil);
}
- (void)test_charFalseUndeclared_isTrueObject {
	STAssertEquals([GRMustache objectKind:[context valueForKey:@"charFalseUndeclared"]], GRMustacheObjectKindTrueValue, nil);
}
- (void)test_charTrueUndeclared_isTrueObject {
	STAssertEquals([GRMustache objectKind:[context valueForKey:@"charTrueUndeclared"]], GRMustacheObjectKindTrueValue, nil);
}
- (void)test_unsigned_charFalseUndeclared_isTrueObject {
	STAssertEquals([GRMustache objectKind:[context valueForKey:@"unsigned_charFalseUndeclared"]], GRMustacheObjectKindTrueValue, nil);
}
- (void)test_unsigned_charTrueUndeclared_isTrueObject {
	STAssertEquals([GRMustache objectKind:[context valueForKey:@"unsigned_charTrueUndeclared"]], GRMustacheObjectKindTrueValue, nil);
}
- (void)test_intFalseUndeclared_isTrueObject {
	STAssertEquals([GRMustache objectKind:[context valueForKey:@"intFalseUndeclared"]], GRMustacheObjectKindTrueValue, nil);
}
- (void)test_intTrueUndeclared_isTrueObject {
	STAssertEquals([GRMustache objectKind:[context valueForKey:@"intTrueUndeclared"]], GRMustacheObjectKindTrueValue, nil);
}

@end



@implementation GRBooleanKVCTestNotStrictBooleanMode

- (void)setUp {
	strictBooleanMode = [GRMustacheContext strictBooleanMode];
	[GRMustacheContext setStrictBooleanMode:NO];
	context = [[GRMustacheContext contextWithObject:[[[GRBooleanTestSupport alloc] init] autorelease]] retain];
}

- (void)tearDown {
	[GRMustacheContext setStrictBooleanMode:strictBooleanMode];
	[context release];
}

- (void)test_boolFalseDeclared_isFalseObject {
	STAssertEquals([GRMustache objectKind:[context valueForKey:@"boolFalseDeclared"]], GRMustacheObjectKindFalseValue, nil);
}
- (void)test_boolTrueDeclared_isTrueObject {
	STAssertEquals([GRMustache objectKind:[context valueForKey:@"boolTrueDeclared"]], GRMustacheObjectKindTrueValue, nil);
}
- (void)test_BOOLFalseDeclared_isFalseObject {
	STAssertEquals([GRMustache objectKind:[context valueForKey:@"BOOLFalseDeclared"]], GRMustacheObjectKindFalseValue, nil);
}
- (void)test_BOOLTrueDeclared_isTrueObject {
	STAssertEquals([GRMustache objectKind:[context valueForKey:@"BOOLTrueDeclared"]], GRMustacheObjectKindTrueValue, nil);
}
- (void)test_charFalseDeclared_isFalseObject {
	STAssertEquals([GRMustache objectKind:[context valueForKey:@"charFalseDeclared"]], GRMustacheObjectKindFalseValue, nil);
}
- (void)test_charTrueDeclared_isTrueObject {
	STAssertEquals([GRMustache objectKind:[context valueForKey:@"charTrueDeclared"]], GRMustacheObjectKindTrueValue, nil);
}
- (void)test_unsigned_charFalseDeclared_isTrueObject {
	STAssertEquals([GRMustache objectKind:[context valueForKey:@"unsigned_charFalseDeclared"]], GRMustacheObjectKindTrueValue, nil);
}
- (void)test_unsigned_charTrueDeclared_isTrueObject {
	STAssertEquals([GRMustache objectKind:[context valueForKey:@"unsigned_charTrueDeclared"]], GRMustacheObjectKindTrueValue, nil);
}
- (void)test_intFalseDeclared_isTrueObject {
	STAssertEquals([GRMustache objectKind:[context valueForKey:@"intFalseDeclared"]], GRMustacheObjectKindTrueValue, nil);
}
- (void)test_intTrueDeclared_isTrueObject {
	STAssertEquals([GRMustache objectKind:[context valueForKey:@"intTrueDeclared"]], GRMustacheObjectKindTrueValue, nil);
}
- (void)test_boolFalseUndeclared_isFalseObject {
	STAssertEquals([GRMustache objectKind:[context valueForKey:@"boolFalseUndeclared"]], GRMustacheObjectKindFalseValue, nil);
}
- (void)test_boolTrueUndeclared_isTrueObject {
	STAssertEquals([GRMustache objectKind:[context valueForKey:@"boolTrueUndeclared"]], GRMustacheObjectKindTrueValue, nil);
}
- (void)test_BOOLFalseUndeclared_isTrueObject {
	STAssertEquals([GRMustache objectKind:[context valueForKey:@"BOOLFalseUndeclared"]], GRMustacheObjectKindTrueValue, nil);
}
- (void)test_BOOLTrueUndeclared_isTrueObject {
	STAssertEquals([GRMustache objectKind:[context valueForKey:@"BOOLTrueUndeclared"]], GRMustacheObjectKindTrueValue, nil);
}
- (void)test_charFalseUndeclared_isTrueObject {
	STAssertEquals([GRMustache objectKind:[context valueForKey:@"charFalseUndeclared"]], GRMustacheObjectKindTrueValue, nil);
}
- (void)test_charTrueUndeclared_isTrueObject {
	STAssertEquals([GRMustache objectKind:[context valueForKey:@"charTrueUndeclared"]], GRMustacheObjectKindTrueValue, nil);
}
- (void)test_unsigned_charFalseUndeclared_isTrueObject {
	STAssertEquals([GRMustache objectKind:[context valueForKey:@"unsigned_charFalseUndeclared"]], GRMustacheObjectKindTrueValue, nil);
}
- (void)test_unsigned_charTrueUndeclared_isTrueObject {
	STAssertEquals([GRMustache objectKind:[context valueForKey:@"unsigned_charTrueUndeclared"]], GRMustacheObjectKindTrueValue, nil);
}
- (void)test_intFalseUndeclared_isTrueObject {
	STAssertEquals([GRMustache objectKind:[context valueForKey:@"intFalseUndeclared"]], GRMustacheObjectKindTrueValue, nil);
}
- (void)test_intTrueUndeclared_isTrueObject {
	STAssertEquals([GRMustache objectKind:[context valueForKey:@"intTrueUndeclared"]], GRMustacheObjectKindTrueValue, nil);
}

@end

