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

#define GRMUSTACHE_VERSION_MAX_ALLOWED GRMUSTACHE_VERSION_6_0
#import "GRMustachePublicAPITest.h"

@interface GRBooleanTest : GRMustachePublicAPITest
@end

@interface GRBooleanTestSupport: NSObject {
    BOOL _customGetterBOOLProperty;
    bool _customGetterboolProperty;
}
@property (readonly) bool boolFalseProperty;
@property (readonly) bool boolTrueProperty;
@property (readonly) BOOL BOOLFalseProperty;
@property (readonly) BOOL BOOLTrueProperty;
@property (readonly) char charFalseProperty;
@property (readonly) char charTrueProperty;
@property (readonly) unsigned char unsigned_charFalseProperty;
@property (readonly) unsigned char unsigned_charTrueProperty;
@property (readonly) int intFalseProperty;
@property (readonly) int intTrueProperty;
@property (getter=isCustomGetterBOOLProperty) BOOL customGetterBOOLProperty;
@property (getter=isCustomGetterboolProperty) bool customGetterboolProperty;
@end

@implementation GRBooleanTestSupport
@synthesize customGetterBOOLProperty=_customGetterBOOLProperty;
@synthesize customGetterboolProperty=_customGetterboolProperty;
- (bool)boolFalseProperty { return NO; }
- (bool)boolTrueProperty { return YES; }
- (BOOL)BOOLFalseProperty { return NO; }
- (BOOL)BOOLTrueProperty { return YES; }
- (char)charFalseProperty { return NO; }
- (char)charTrueProperty { return YES; }
- (unsigned char)unsigned_charFalseProperty { return NO; }
- (unsigned char)unsigned_charTrueProperty { return YES; }
- (int)intFalseProperty { return NO; }
- (int)intTrueProperty { return YES; }
- (bool)boolFalseMethod { return NO; }
- (bool)boolTrueMethod { return YES; }
- (BOOL)BOOLFalseMethod { return NO; }
- (BOOL)BOOLTrueMethod { return YES; }
- (char)charFalseMethod { return NO; }
- (char)charTrueMethod { return YES; }
- (unsigned char)unsigned_charFalseMethod { return NO; }
- (unsigned char)unsigned_charTrueMethod { return YES; }
- (int)intFalseMethod { return NO; }
- (int)intTrueMethod { return YES; }
@end

@interface GRBooleanTestSupportSubClass: GRBooleanTestSupport
@end

@implementation GRBooleanTestSupportSubClass
@end

@implementation GRBooleanTest

- (BOOL)booleanInterpretationForKey:(NSString *)key inObject:(id)object
{
    NSString *templateString = [NSString stringWithFormat:@"{{#%@}}YES{{/%@}}{{^%@}}NO{{/%@}}", key, key, key, key];
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:templateString error:NULL];
    NSString *result = [template renderObject:object error:NULL];
    if ([result isEqualToString:@"YES"]) {
        return YES;
    } else if ([result isEqualToString:@"NO"]) {
        return NO;
    } else {
        result = [template renderObject:object error:NULL];    // allow breakpoint
        STAssertTrue(NO, @"");
        return NO; // meaningless
    }
}

- (BOOL)booleanInterpretationOfObject:(id)object
{
    NSDictionary *context = object ? [NSDictionary dictionaryWithObject:object forKey:@"bool"] : [NSDictionary dictionary];
    return [self booleanInterpretationForKey:@"bool" inObject:context];
}

- (BOOL)doesObjectRender:(id)object
{
    NSDictionary *context = object ? [NSDictionary dictionaryWithObject:object forKey:@"bool"] : [NSDictionary dictionary];
    NSString *result = [[GRMustacheTemplate templateFromString:@"<{{bool}}>" error:NULL] renderObject:context error:NULL];
    if ([result isEqualToString:@"<>"]) {
        return NO;
    } else {
        return YES;
    }
}

- (void)test_Nil_isFalseValue
{
    // Test boolean interpretation of values that we could not test in GRMustacheSuites/sections.json and GRMustacheSuites/inverted_sections.json
    STAssertEquals(NO, [self booleanInterpretationOfObject:nil], nil);
}

- (void)test_Nil_doesNotRender
{
    // Test boolean interpretation of values that we could not test in GRMustacheSuites/sections.json and GRMustacheSuites/inverted_sections.json
    STAssertEquals(NO, [self doesObjectRender:nil], @"");
}

- (void)test_NSNull_isFalseValue
{
    // Test boolean interpretation of values that we could not test in GRMustacheSuites/sections.json and GRMustacheSuites/inverted_sections.json
    STAssertEquals(NO, [self booleanInterpretationOfObject:[NSNull null]], (NSInteger)NO, nil);
}

- (void)test_NSNull_doesNotRender
{
    // Test boolean interpretation of values that we could not test in GRMustacheSuites/sections.json and GRMustacheSuites/inverted_sections.json
    STAssertEquals(NO, [self doesObjectRender:[NSNull null]], @"");
}

- (void)test_NSNumberWithZero_isFalseValue
{
    // Test boolean interpretation of values that we could not test in GRMustacheSuites/sections.json and GRMustacheSuites/inverted_sections.json
    STAssertEquals(NO, [self booleanInterpretationOfObject:[NSNumber numberWithChar:0]], nil);
    STAssertEquals(NO, [self booleanInterpretationOfObject:[NSNumber numberWithFloat:0]], nil);
    STAssertEquals(NO, [self booleanInterpretationOfObject:[NSNumber numberWithDouble:0]], nil);
    STAssertEquals(NO, [self booleanInterpretationOfObject:[NSNumber numberWithInt:0]], nil);
    STAssertEquals(NO, [self booleanInterpretationOfObject:[NSNumber numberWithInteger:0]], nil);
    STAssertEquals(NO, [self booleanInterpretationOfObject:[NSNumber numberWithLong:0]], nil);
    STAssertEquals(NO, [self booleanInterpretationOfObject:[NSNumber numberWithLongLong:0]], nil);
    STAssertEquals(NO, [self booleanInterpretationOfObject:[NSNumber numberWithShort:0]], nil);
    STAssertEquals(NO, [self booleanInterpretationOfObject:[NSNumber numberWithUnsignedChar:0]], nil);
    STAssertEquals(NO, [self booleanInterpretationOfObject:[NSNumber numberWithUnsignedInt:0]], nil);
    STAssertEquals(NO, [self booleanInterpretationOfObject:[NSNumber numberWithUnsignedInteger:0]], nil);
    STAssertEquals(NO, [self booleanInterpretationOfObject:[NSNumber numberWithUnsignedLong:0]], nil);
    STAssertEquals(NO, [self booleanInterpretationOfObject:[NSNumber numberWithUnsignedLongLong:0]], nil);
    STAssertEquals(NO, [self booleanInterpretationOfObject:[NSNumber numberWithUnsignedShort:0]], nil);
}

- (void)test_NSNumberWithZero_doesRender
{
    // Test boolean interpretation of values that we could not test in GRMustacheSuites/sections.json and GRMustacheSuites/inverted_sections.json
    STAssertEquals(YES, [self doesObjectRender:[NSNumber numberWithChar:0]], @"");
    STAssertEquals(YES, [self doesObjectRender:[NSNumber numberWithFloat:0]], @"");
    STAssertEquals(YES, [self doesObjectRender:[NSNumber numberWithDouble:0]], @"");
    STAssertEquals(YES, [self doesObjectRender:[NSNumber numberWithInt:0]], @"");
    STAssertEquals(YES, [self doesObjectRender:[NSNumber numberWithInteger:0]], @"");
    STAssertEquals(YES, [self doesObjectRender:[NSNumber numberWithLong:0]], @"");
    STAssertEquals(YES, [self doesObjectRender:[NSNumber numberWithLongLong:0]], @"");
    STAssertEquals(YES, [self doesObjectRender:[NSNumber numberWithShort:0]], @"");
    STAssertEquals(YES, [self doesObjectRender:[NSNumber numberWithUnsignedChar:0]], @"");
    STAssertEquals(YES, [self doesObjectRender:[NSNumber numberWithUnsignedInt:0]], @"");
    STAssertEquals(YES, [self doesObjectRender:[NSNumber numberWithUnsignedInteger:0]], @"");
    STAssertEquals(YES, [self doesObjectRender:[NSNumber numberWithUnsignedLong:0]], @"");
    STAssertEquals(YES, [self doesObjectRender:[NSNumber numberWithUnsignedLongLong:0]], @"");
    STAssertEquals(YES, [self doesObjectRender:[NSNumber numberWithUnsignedShort:0]], @"");
}

- (void)testCustomGetterBOOLProperty
{
    GRBooleanTestSupport *context = [[[GRBooleanTestSupport alloc] init] autorelease];
    GRBooleanTestSupportSubClass *inheritingContext = [[[GRBooleanTestSupportSubClass alloc] init] autorelease];
    
    context.customGetterBOOLProperty = NO;
    inheritingContext.customGetterBOOLProperty = NO;
    STAssertEquals(NO, [self booleanInterpretationForKey:@"customGetterBOOLProperty" inObject:context], @"");
    STAssertEquals(NO, [self booleanInterpretationForKey:@"isCustomGetterBOOLProperty" inObject:context], @"");
    STAssertEquals(NO, [self booleanInterpretationForKey:@"customGetterBOOLProperty" inObject:inheritingContext], @"");
    STAssertEquals(NO, [self booleanInterpretationForKey:@"isCustomGetterBOOLProperty" inObject:inheritingContext], @"");
    
    context.customGetterBOOLProperty = YES;
    inheritingContext.customGetterBOOLProperty = YES;
    STAssertEquals(YES, [self booleanInterpretationForKey:@"customGetterBOOLProperty" inObject:context], @"");
    STAssertEquals(YES, [self booleanInterpretationForKey:@"isCustomGetterBOOLProperty" inObject:context], @"");
    STAssertEquals(YES, [self booleanInterpretationForKey:@"customGetterBOOLProperty" inObject:inheritingContext], @"");
    STAssertEquals(YES, [self booleanInterpretationForKey:@"isCustomGetterBOOLProperty" inObject:inheritingContext], @"");
}

- (void)testCustomGetterboolProperty
{
    GRBooleanTestSupport *context = [[[GRBooleanTestSupport alloc] init] autorelease];
    GRBooleanTestSupportSubClass *inheritingContext = [[[GRBooleanTestSupportSubClass alloc] init] autorelease];
    
    context.customGetterboolProperty = NO;
    inheritingContext.customGetterboolProperty = NO;
    STAssertEquals(NO, [self booleanInterpretationForKey:@"customGetterboolProperty" inObject:context], @"");
    STAssertEquals(NO, [self booleanInterpretationForKey:@"isCustomGetterboolProperty" inObject:context], @"");
    STAssertEquals(NO, [self booleanInterpretationForKey:@"customGetterboolProperty" inObject:inheritingContext], @"");
    STAssertEquals(NO, [self booleanInterpretationForKey:@"isCustomGetterboolProperty" inObject:inheritingContext], @"");
    
    context.customGetterboolProperty = YES;
    inheritingContext.customGetterboolProperty = YES;
    STAssertEquals(YES, [self booleanInterpretationForKey:@"customGetterboolProperty" inObject:context], @"");
    STAssertEquals(YES, [self booleanInterpretationForKey:@"isCustomGetterboolProperty" inObject:context], @"");
    STAssertEquals(YES, [self booleanInterpretationForKey:@"customGetterboolProperty" inObject:inheritingContext], @"");
    STAssertEquals(YES, [self booleanInterpretationForKey:@"isCustomGetterboolProperty" inObject:inheritingContext], @"");
}

- (void)test_boolFalseProperty_isFalseValue
{
    id context = [[[GRBooleanTestSupport alloc] init] autorelease];
    id inheritingContext = [[[GRBooleanTestSupportSubClass alloc] init] autorelease];
    STAssertEquals(NO, [self booleanInterpretationForKey:@"boolFalseProperty" inObject:context], @"");
    STAssertEquals(NO, [self booleanInterpretationForKey:@"boolFalseProperty" inObject:inheritingContext], @"");
}
- (void)test_boolTrueProperty_isTrueValue
{
    id context = [[[GRBooleanTestSupport alloc] init] autorelease];
    id inheritingContext = [[[GRBooleanTestSupportSubClass alloc] init] autorelease];
    STAssertEquals(YES, [self booleanInterpretationForKey:@"boolTrueProperty" inObject:context], @"");
    STAssertEquals(YES, [self booleanInterpretationForKey:@"boolTrueProperty" inObject:inheritingContext], @"");
}
- (void)test_BOOLFalseProperty_isTrueValue
{
    id context = [[[GRBooleanTestSupport alloc] init] autorelease];
    id inheritingContext = [[[GRBooleanTestSupportSubClass alloc] init] autorelease];
    STAssertEquals(NO, [self booleanInterpretationForKey:@"BOOLFalseProperty" inObject:context], @"");
    STAssertEquals(NO, [self booleanInterpretationForKey:@"BOOLFalseProperty" inObject:inheritingContext], @"");
}
- (void)test_BOOLTrueProperty_isTrueValue
{
    id context = [[[GRBooleanTestSupport alloc] init] autorelease];
    id inheritingContext = [[[GRBooleanTestSupportSubClass alloc] init] autorelease];
    STAssertEquals(YES, [self booleanInterpretationForKey:@"BOOLTrueProperty" inObject:context], @"");
    STAssertEquals(YES, [self booleanInterpretationForKey:@"BOOLTrueProperty" inObject:inheritingContext], @"");
}
- (void)test_charFalseProperty_isTrueValue
{
    id context = [[[GRBooleanTestSupport alloc] init] autorelease];
    id inheritingContext = [[[GRBooleanTestSupportSubClass alloc] init] autorelease];
    STAssertEquals(NO, [self booleanInterpretationForKey:@"charFalseProperty" inObject:context], @"");
    STAssertEquals(NO, [self booleanInterpretationForKey:@"charFalseProperty" inObject:inheritingContext], @"");
}
- (void)test_charTrueProperty_isTrueValue
{
    id context = [[[GRBooleanTestSupport alloc] init] autorelease];
    id inheritingContext = [[[GRBooleanTestSupportSubClass alloc] init] autorelease];
    STAssertEquals(YES, [self booleanInterpretationForKey:@"charTrueProperty" inObject:context], @"");
    STAssertEquals(YES, [self booleanInterpretationForKey:@"charTrueProperty" inObject:inheritingContext], @"");
}
- (void)test_unsigned_charFalseProperty_isFalseValue
{
    id context = [[[GRBooleanTestSupport alloc] init] autorelease];
    id inheritingContext = [[[GRBooleanTestSupportSubClass alloc] init] autorelease];
    STAssertEquals(NO, [self booleanInterpretationForKey:@"unsigned_charFalseProperty" inObject:context], @"");
    STAssertEquals(NO, [self booleanInterpretationForKey:@"unsigned_charFalseProperty" inObject:inheritingContext], @"");
}
- (void)test_unsigned_charTrueProperty_isTrueValue
{
    id context = [[[GRBooleanTestSupport alloc] init] autorelease];
    id inheritingContext = [[[GRBooleanTestSupportSubClass alloc] init] autorelease];
    STAssertEquals(YES, [self booleanInterpretationForKey:@"unsigned_charTrueProperty" inObject:context], @"");
    STAssertEquals(YES, [self booleanInterpretationForKey:@"unsigned_charTrueProperty" inObject:inheritingContext], @"");
}
- (void)test_intFalseProperty_isFalseValue
{
    id context = [[[GRBooleanTestSupport alloc] init] autorelease];
    id inheritingContext = [[[GRBooleanTestSupportSubClass alloc] init] autorelease];
    STAssertEquals(NO, [self booleanInterpretationForKey:@"intFalseProperty" inObject:context], @"");
    STAssertEquals(NO, [self booleanInterpretationForKey:@"intFalseProperty" inObject:inheritingContext], @"");
}
- (void)test_intTrueProperty_isTrueValue
{
    id context = [[[GRBooleanTestSupport alloc] init] autorelease];
    id inheritingContext = [[[GRBooleanTestSupportSubClass alloc] init] autorelease];
    STAssertEquals(YES, [self booleanInterpretationForKey:@"intTrueProperty" inObject:context], @"");
    STAssertEquals(YES, [self booleanInterpretationForKey:@"intTrueProperty" inObject:inheritingContext], @"");
}
- (void)test_boolFalseMethod_isFalseValue
{
    id context = [[[GRBooleanTestSupport alloc] init] autorelease];
    id inheritingContext = [[[GRBooleanTestSupportSubClass alloc] init] autorelease];
    STAssertEquals(NO, [self booleanInterpretationForKey:@"boolFalseMethod" inObject:context], @"");
    STAssertEquals(NO, [self booleanInterpretationForKey:@"boolFalseMethod" inObject:inheritingContext], @"");
}
- (void)test_boolTrueMethod_isTrueValue
{
    id context = [[[GRBooleanTestSupport alloc] init] autorelease];
    id inheritingContext = [[[GRBooleanTestSupportSubClass alloc] init] autorelease];
    STAssertEquals(YES, [self booleanInterpretationForKey:@"boolTrueMethod" inObject:context], @"");
    STAssertEquals(YES, [self booleanInterpretationForKey:@"boolTrueMethod" inObject:inheritingContext], @"");
}
- (void)test_BOOLFalseMethod_isFalseValue
{
    id context = [[[GRBooleanTestSupport alloc] init] autorelease];
    id inheritingContext = [[[GRBooleanTestSupportSubClass alloc] init] autorelease];
    STAssertEquals(NO, [self booleanInterpretationForKey:@"BOOLFalseMethod" inObject:context], @"");
    STAssertEquals(NO, [self booleanInterpretationForKey:@"BOOLFalseMethod" inObject:inheritingContext], @"");
}
- (void)test_BOOLTrueMethod_isTrueValue
{
    id context = [[[GRBooleanTestSupport alloc] init] autorelease];
    id inheritingContext = [[[GRBooleanTestSupportSubClass alloc] init] autorelease];
    STAssertEquals(YES, [self booleanInterpretationForKey:@"BOOLTrueMethod" inObject:context], @"");
    STAssertEquals(YES, [self booleanInterpretationForKey:@"BOOLTrueMethod" inObject:inheritingContext], @"");
}
- (void)test_charFalseMethod_isFalseValue
{
    id context = [[[GRBooleanTestSupport alloc] init] autorelease];
    id inheritingContext = [[[GRBooleanTestSupportSubClass alloc] init] autorelease];
    STAssertEquals(NO, [self booleanInterpretationForKey:@"charFalseMethod" inObject:context], @"");
    STAssertEquals(NO, [self booleanInterpretationForKey:@"charFalseMethod" inObject:inheritingContext], @"");
}
- (void)test_charTrueMethod_isTrueValue
{
    id context = [[[GRBooleanTestSupport alloc] init] autorelease];
    id inheritingContext = [[[GRBooleanTestSupportSubClass alloc] init] autorelease];
    STAssertEquals(YES, [self booleanInterpretationForKey:@"charTrueMethod" inObject:context], @"");
    STAssertEquals(YES, [self booleanInterpretationForKey:@"charTrueMethod" inObject:inheritingContext], @"");
}
- (void)test_unsigned_charFalseMethod_isFalseValue
{
    id context = [[[GRBooleanTestSupport alloc] init] autorelease];
    id inheritingContext = [[[GRBooleanTestSupportSubClass alloc] init] autorelease];
    STAssertEquals(NO, [self booleanInterpretationForKey:@"unsigned_charFalseMethod" inObject:context], @"");
    STAssertEquals(NO, [self booleanInterpretationForKey:@"unsigned_charFalseMethod" inObject:inheritingContext], @"");
}
- (void)test_unsigned_charTrueMethod_isTrueValue
{
    id context = [[[GRBooleanTestSupport alloc] init] autorelease];
    id inheritingContext = [[[GRBooleanTestSupportSubClass alloc] init] autorelease];
    STAssertEquals(YES, [self booleanInterpretationForKey:@"unsigned_charTrueMethod" inObject:context], @"");
    STAssertEquals(YES, [self booleanInterpretationForKey:@"unsigned_charTrueMethod" inObject:inheritingContext], @"");
}
- (void)test_intFalseMethod_isFalseValue
{
    id context = [[[GRBooleanTestSupport alloc] init] autorelease];
    id inheritingContext = [[[GRBooleanTestSupportSubClass alloc] init] autorelease];
    STAssertEquals(NO, [self booleanInterpretationForKey:@"intFalseMethod" inObject:context], @"");
    STAssertEquals(NO, [self booleanInterpretationForKey:@"intFalseMethod" inObject:inheritingContext], @"");
}
- (void)test_intTrueMethod_isTrueValue
{
    id context = [[[GRBooleanTestSupport alloc] init] autorelease];
    id inheritingContext = [[[GRBooleanTestSupportSubClass alloc] init] autorelease];
    STAssertEquals(YES, [self booleanInterpretationForKey:@"intTrueMethod" inObject:context], @"");
    STAssertEquals(YES, [self booleanInterpretationForKey:@"intTrueMethod" inObject:inheritingContext], @"");
}

@end
