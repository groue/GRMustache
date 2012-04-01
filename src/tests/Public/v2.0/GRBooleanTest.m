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

#import "GRBooleanTest.h"

@interface GRBooleanTestSupport: NSObject
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
@synthesize customGetterBOOLProperty;
@synthesize customGetterboolProperty;
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

- (BOOL)booleanInterpretationForKey:(NSString *)key inObject:(id)object options:(GRMustacheTemplateOptions) options
{
    NSString *templateString = [NSString stringWithFormat:@"{{#%@}}YES{{/%@}}{{^%@}}NO{{/%@}}", key, key, key, key];
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:templateString options:options error:NULL];
    NSString *result = [template renderObject:object];
    if ([result isEqualToString:@"YES"]) {
        return YES;
    } else if ([result isEqualToString:@"NO"]) {
        return NO;
    } else {
        STAssertTrue(NO, @"");
        return NO; // meaningless
    }
}

- (BOOL)strictBooleanInterpretationForKey:(NSString *)key inObject:(id)object
{
    return [self booleanInterpretationForKey:key inObject:object options:GRMustacheTemplateOptionStrictBoolean];
}

- (BOOL)looseBooleanInterpretationForKey:(NSString *)key inObject:(id)object
{
    return [self booleanInterpretationForKey:key inObject:object options:GRMustacheTemplateOptionNone];
}

- (BOOL)booleanInterpretationOfObject:(id)object
{
    NSDictionary *context = object ? [NSDictionary dictionaryWithObject:object forKey:@"bool"] : [NSDictionary dictionary];
    return [self looseBooleanInterpretationForKey:@"bool" inObject:context];
}

- (BOOL)doesObjectRender:(id)object
{
    NSDictionary *context = object ? [NSDictionary dictionaryWithObject:object forKey:@"bool"] : [NSDictionary dictionary];
    NSString *result = [GRMustacheTemplate renderObject:context fromString:@"<{{bool}}>" error:NULL];
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

- (void)test_NSNumberWithZero_isTrueValue
{
    // Test boolean interpretation of values that we could not test in GRMustacheSuites/sections.json and GRMustacheSuites/inverted_sections.json
    STAssertEquals(YES, [self booleanInterpretationOfObject:[NSNumber numberWithChar:0]], nil);
    STAssertEquals(YES, [self booleanInterpretationOfObject:[NSNumber numberWithFloat:0]], nil);
    STAssertEquals(YES, [self booleanInterpretationOfObject:[NSNumber numberWithDouble:0]], nil);
    STAssertEquals(YES, [self booleanInterpretationOfObject:[NSNumber numberWithInt:0]], nil);
    STAssertEquals(YES, [self booleanInterpretationOfObject:[NSNumber numberWithInteger:0]], nil);
    STAssertEquals(YES, [self booleanInterpretationOfObject:[NSNumber numberWithLong:0]], nil);
    STAssertEquals(YES, [self booleanInterpretationOfObject:[NSNumber numberWithLongLong:0]], nil);
    STAssertEquals(YES, [self booleanInterpretationOfObject:[NSNumber numberWithShort:0]], nil);
    STAssertEquals(YES, [self booleanInterpretationOfObject:[NSNumber numberWithUnsignedChar:0]], nil);
    STAssertEquals(YES, [self booleanInterpretationOfObject:[NSNumber numberWithUnsignedInt:0]], nil);
    STAssertEquals(YES, [self booleanInterpretationOfObject:[NSNumber numberWithUnsignedInteger:0]], nil);
    STAssertEquals(YES, [self booleanInterpretationOfObject:[NSNumber numberWithUnsignedLong:0]], nil);
    STAssertEquals(YES, [self booleanInterpretationOfObject:[NSNumber numberWithUnsignedLongLong:0]], nil);
    STAssertEquals(YES, [self booleanInterpretationOfObject:[NSNumber numberWithUnsignedShort:0]], nil);
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

- (void)testStrictCustomGetterBOOLProperty
{
    GRBooleanTestSupport *context = [[[GRBooleanTestSupport alloc] init] autorelease];
    GRBooleanTestSupportSubClass *inheritingContext = [[[GRBooleanTestSupportSubClass alloc] init] autorelease];
    
    context.customGetterBOOLProperty = NO;
    inheritingContext.customGetterBOOLProperty = NO;
    STAssertEquals(YES, [self strictBooleanInterpretationForKey:@"customGetterBOOLProperty" inObject:context], @"");
    STAssertEquals(YES, [self strictBooleanInterpretationForKey:@"isCustomGetterBOOLProperty" inObject:context], @"");
    STAssertEquals(YES, [self strictBooleanInterpretationForKey:@"customGetterBOOLProperty" inObject:inheritingContext], @"");
    STAssertEquals(YES, [self strictBooleanInterpretationForKey:@"isCustomGetterBOOLProperty" inObject:inheritingContext], @"");
    
    context.customGetterBOOLProperty = YES;
    inheritingContext.customGetterBOOLProperty = YES;
    STAssertEquals(YES, [self strictBooleanInterpretationForKey:@"customGetterBOOLProperty" inObject:context], @"");
    STAssertEquals(YES, [self strictBooleanInterpretationForKey:@"isCustomGetterBOOLProperty" inObject:context], @"");
    STAssertEquals(YES, [self strictBooleanInterpretationForKey:@"customGetterBOOLProperty" inObject:inheritingContext], @"");
    STAssertEquals(YES, [self strictBooleanInterpretationForKey:@"isCustomGetterBOOLProperty" inObject:inheritingContext], @"");
}

- (void)testStrictCustomGetterboolProperty
{
    GRBooleanTestSupport *context = [[[GRBooleanTestSupport alloc] init] autorelease];
    GRBooleanTestSupportSubClass *inheritingContext = [[[GRBooleanTestSupportSubClass alloc] init] autorelease];
    
    context.customGetterboolProperty = NO;
    inheritingContext.customGetterboolProperty = NO;
    STAssertEquals(NO, [self strictBooleanInterpretationForKey:@"customGetterboolProperty" inObject:context], @"");
    STAssertEquals(NO, [self strictBooleanInterpretationForKey:@"isCustomGetterboolProperty" inObject:context], @"");
    STAssertEquals(NO, [self strictBooleanInterpretationForKey:@"customGetterboolProperty" inObject:inheritingContext], @"");
    STAssertEquals(NO, [self strictBooleanInterpretationForKey:@"isCustomGetterboolProperty" inObject:inheritingContext], @"");
    
    context.customGetterboolProperty = YES;
    inheritingContext.customGetterboolProperty = YES;
    STAssertEquals(YES, [self strictBooleanInterpretationForKey:@"customGetterboolProperty" inObject:context], @"");
    STAssertEquals(YES, [self strictBooleanInterpretationForKey:@"isCustomGetterboolProperty" inObject:context], @"");
    STAssertEquals(YES, [self strictBooleanInterpretationForKey:@"customGetterboolProperty" inObject:inheritingContext], @"");
    STAssertEquals(YES, [self strictBooleanInterpretationForKey:@"isCustomGetterboolProperty" inObject:inheritingContext], @"");
}

- (void)testStrict_boolFalseProperty_isFalseValue
{
    id context = [[[GRBooleanTestSupport alloc] init] autorelease];
    id inheritingContext = [[[GRBooleanTestSupportSubClass alloc] init] autorelease];
    STAssertEquals(NO, [self strictBooleanInterpretationForKey:@"boolFalseProperty" inObject:context], @"");
    STAssertEquals(NO, [self strictBooleanInterpretationForKey:@"boolFalseProperty" inObject:inheritingContext], @"");
}
- (void)testStrict_boolTrueProperty_isTrueValue
{
    id context = [[[GRBooleanTestSupport alloc] init] autorelease];
    id inheritingContext = [[[GRBooleanTestSupportSubClass alloc] init] autorelease];
    STAssertEquals(YES, [self strictBooleanInterpretationForKey:@"boolTrueProperty" inObject:context], @"");
    STAssertEquals(YES, [self strictBooleanInterpretationForKey:@"boolTrueProperty" inObject:inheritingContext], @"");
}
- (void)testStrict_BOOLFalseProperty_isTrueValue
{
    id context = [[[GRBooleanTestSupport alloc] init] autorelease];
    id inheritingContext = [[[GRBooleanTestSupportSubClass alloc] init] autorelease];
    STAssertEquals(YES, [self strictBooleanInterpretationForKey:@"BOOLFalseProperty" inObject:context], @"");
    STAssertEquals(YES, [self strictBooleanInterpretationForKey:@"BOOLFalseProperty" inObject:inheritingContext], @"");
}
- (void)testStrict_BOOLTrueProperty_isTrueValue
{
    id context = [[[GRBooleanTestSupport alloc] init] autorelease];
    id inheritingContext = [[[GRBooleanTestSupportSubClass alloc] init] autorelease];
    STAssertEquals(YES, [self strictBooleanInterpretationForKey:@"BOOLTrueProperty" inObject:context], @"");
    STAssertEquals(YES, [self strictBooleanInterpretationForKey:@"BOOLTrueProperty" inObject:inheritingContext], @"");
}
- (void)testStrict_charFalseProperty_isTrueValue
{
    id context = [[[GRBooleanTestSupport alloc] init] autorelease];
    id inheritingContext = [[[GRBooleanTestSupportSubClass alloc] init] autorelease];
    STAssertEquals(YES, [self strictBooleanInterpretationForKey:@"charFalseProperty" inObject:context], @"");
    STAssertEquals(YES, [self strictBooleanInterpretationForKey:@"charFalseProperty" inObject:inheritingContext], @"");
}
- (void)testStrict_charTrueProperty_isTrueValue
{
    id context = [[[GRBooleanTestSupport alloc] init] autorelease];
    id inheritingContext = [[[GRBooleanTestSupportSubClass alloc] init] autorelease];
    STAssertEquals(YES, [self strictBooleanInterpretationForKey:@"charTrueProperty" inObject:context], @"");
    STAssertEquals(YES, [self strictBooleanInterpretationForKey:@"charTrueProperty" inObject:inheritingContext], @"");
}
- (void)testStrict_unsigned_charFalseProperty_isTrueValue
{
    id context = [[[GRBooleanTestSupport alloc] init] autorelease];
    id inheritingContext = [[[GRBooleanTestSupportSubClass alloc] init] autorelease];
    STAssertEquals(YES, [self strictBooleanInterpretationForKey:@"unsigned_charFalseProperty" inObject:context], @"");
    STAssertEquals(YES, [self strictBooleanInterpretationForKey:@"unsigned_charFalseProperty" inObject:inheritingContext], @"");
}
- (void)testStrict_unsigned_charTrueProperty_isTrueValue
{
    id context = [[[GRBooleanTestSupport alloc] init] autorelease];
    id inheritingContext = [[[GRBooleanTestSupportSubClass alloc] init] autorelease];
    STAssertEquals(YES, [self strictBooleanInterpretationForKey:@"unsigned_charTrueProperty" inObject:context], @"");
    STAssertEquals(YES, [self strictBooleanInterpretationForKey:@"unsigned_charTrueProperty" inObject:inheritingContext], @"");
}
- (void)testStrict_intFalseProperty_isTrueValue
{
    id context = [[[GRBooleanTestSupport alloc] init] autorelease];
    id inheritingContext = [[[GRBooleanTestSupportSubClass alloc] init] autorelease];
    STAssertEquals(YES, [self strictBooleanInterpretationForKey:@"intFalseProperty" inObject:context], @"");
    STAssertEquals(YES, [self strictBooleanInterpretationForKey:@"intFalseProperty" inObject:inheritingContext], @"");
}
- (void)testStrict_intTrueProperty_isTrueValue
{
    id context = [[[GRBooleanTestSupport alloc] init] autorelease];
    id inheritingContext = [[[GRBooleanTestSupportSubClass alloc] init] autorelease];
    STAssertEquals(YES, [self strictBooleanInterpretationForKey:@"intTrueProperty" inObject:context], @"");
    STAssertEquals(YES, [self strictBooleanInterpretationForKey:@"intTrueProperty" inObject:inheritingContext], @"");
}
- (void)testStrict_boolFalseMethod_isFalseValue
{
    id context = [[[GRBooleanTestSupport alloc] init] autorelease];
    id inheritingContext = [[[GRBooleanTestSupportSubClass alloc] init] autorelease];
    STAssertEquals(NO, [self strictBooleanInterpretationForKey:@"boolFalseMethod" inObject:context], @"");
    STAssertEquals(NO, [self strictBooleanInterpretationForKey:@"boolFalseMethod" inObject:inheritingContext], @"");
}
- (void)testStrict_boolTrueMethod_isTrueValue
{
    id context = [[[GRBooleanTestSupport alloc] init] autorelease];
    id inheritingContext = [[[GRBooleanTestSupportSubClass alloc] init] autorelease];
    STAssertEquals(YES, [self strictBooleanInterpretationForKey:@"boolTrueMethod" inObject:context], @"");
    STAssertEquals(YES, [self strictBooleanInterpretationForKey:@"boolTrueMethod" inObject:inheritingContext], @"");
}
- (void)testStrict_BOOLFalseMethod_isTrueValue
{
    id context = [[[GRBooleanTestSupport alloc] init] autorelease];
    id inheritingContext = [[[GRBooleanTestSupportSubClass alloc] init] autorelease];
    STAssertEquals(YES, [self strictBooleanInterpretationForKey:@"BOOLFalseMethod" inObject:context], @"");
    STAssertEquals(YES, [self strictBooleanInterpretationForKey:@"BOOLFalseMethod" inObject:inheritingContext], @"");
}
- (void)testStrict_BOOLTrueMethod_isTrueValue
{
    id context = [[[GRBooleanTestSupport alloc] init] autorelease];
    id inheritingContext = [[[GRBooleanTestSupportSubClass alloc] init] autorelease];
    STAssertEquals(YES, [self strictBooleanInterpretationForKey:@"BOOLTrueMethod" inObject:context], @"");
    STAssertEquals(YES, [self strictBooleanInterpretationForKey:@"BOOLTrueMethod" inObject:inheritingContext], @"");
}
- (void)testStrict_charFalseMethod_isTrueValue
{
    id context = [[[GRBooleanTestSupport alloc] init] autorelease];
    id inheritingContext = [[[GRBooleanTestSupportSubClass alloc] init] autorelease];
    STAssertEquals(YES, [self strictBooleanInterpretationForKey:@"charFalseMethod" inObject:context], @"");
    STAssertEquals(YES, [self strictBooleanInterpretationForKey:@"charFalseMethod" inObject:inheritingContext], @"");
}
- (void)testStrict_charTrueMethod_isTrueValue
{
    id context = [[[GRBooleanTestSupport alloc] init] autorelease];
    id inheritingContext = [[[GRBooleanTestSupportSubClass alloc] init] autorelease];
    STAssertEquals(YES, [self strictBooleanInterpretationForKey:@"charTrueMethod" inObject:context], @"");
    STAssertEquals(YES, [self strictBooleanInterpretationForKey:@"charTrueMethod" inObject:inheritingContext], @"");
}
- (void)testStrict_unsigned_charFalseMethod_isTrueValue
{
    id context = [[[GRBooleanTestSupport alloc] init] autorelease];
    id inheritingContext = [[[GRBooleanTestSupportSubClass alloc] init] autorelease];
    STAssertEquals(YES, [self strictBooleanInterpretationForKey:@"unsigned_charFalseMethod" inObject:context], @"");
    STAssertEquals(YES, [self strictBooleanInterpretationForKey:@"unsigned_charFalseMethod" inObject:inheritingContext], @"");
}
- (void)testStrict_unsigned_charTrueMethod_isTrueValue
{
    id context = [[[GRBooleanTestSupport alloc] init] autorelease];
    id inheritingContext = [[[GRBooleanTestSupportSubClass alloc] init] autorelease];
    STAssertEquals(YES, [self strictBooleanInterpretationForKey:@"unsigned_charTrueMethod" inObject:context], @"");
    STAssertEquals(YES, [self strictBooleanInterpretationForKey:@"unsigned_charTrueMethod" inObject:inheritingContext], @"");
}
- (void)testStrict_intFalseMethod_isTrueValue
{
    id context = [[[GRBooleanTestSupport alloc] init] autorelease];
    id inheritingContext = [[[GRBooleanTestSupportSubClass alloc] init] autorelease];
    STAssertEquals(YES, [self strictBooleanInterpretationForKey:@"intFalseMethod" inObject:context], @"");
    STAssertEquals(YES, [self strictBooleanInterpretationForKey:@"intFalseMethod" inObject:inheritingContext], @"");
}
- (void)testStrict_intTrueMethod_isTrueValue
{
    id context = [[[GRBooleanTestSupport alloc] init] autorelease];
    id inheritingContext = [[[GRBooleanTestSupportSubClass alloc] init] autorelease];
    STAssertEquals(YES, [self strictBooleanInterpretationForKey:@"intTrueMethod" inObject:context], @"");
    STAssertEquals(YES, [self strictBooleanInterpretationForKey:@"intTrueMethod" inObject:inheritingContext], @"");
}

- (void)testLooseCustomGetterBOOLProperty
{
    GRBooleanTestSupport *context = [[[GRBooleanTestSupport alloc] init] autorelease];
    GRBooleanTestSupportSubClass *inheritingContext = [[[GRBooleanTestSupportSubClass alloc] init] autorelease];
    
    context.customGetterBOOLProperty = NO;
    inheritingContext.customGetterBOOLProperty = NO;
    STAssertEquals(NO, [self looseBooleanInterpretationForKey:@"customGetterBOOLProperty" inObject:context], @"");
    STAssertEquals(NO, [self looseBooleanInterpretationForKey:@"isCustomGetterBOOLProperty" inObject:context], @"");
    STAssertEquals(NO, [self looseBooleanInterpretationForKey:@"customGetterBOOLProperty" inObject:inheritingContext], @"");
    STAssertEquals(NO, [self looseBooleanInterpretationForKey:@"isCustomGetterBOOLProperty" inObject:inheritingContext], @"");
    
    context.customGetterBOOLProperty = YES;
    inheritingContext.customGetterBOOLProperty = YES;
    STAssertEquals(YES, [self looseBooleanInterpretationForKey:@"customGetterBOOLProperty" inObject:context], @"");
    STAssertEquals(YES, [self looseBooleanInterpretationForKey:@"isCustomGetterBOOLProperty" inObject:context], @"");
    STAssertEquals(YES, [self looseBooleanInterpretationForKey:@"customGetterBOOLProperty" inObject:inheritingContext], @"");
    STAssertEquals(YES, [self looseBooleanInterpretationForKey:@"isCustomGetterBOOLProperty" inObject:inheritingContext], @"");
}

- (void)testLooseCustomGetterboolProperty
{
    GRBooleanTestSupport *context = [[[GRBooleanTestSupport alloc] init] autorelease];
    GRBooleanTestSupportSubClass *inheritingContext = [[[GRBooleanTestSupportSubClass alloc] init] autorelease];
    
    context.customGetterboolProperty = NO;
    inheritingContext.customGetterboolProperty = NO;
    STAssertEquals(NO, [self looseBooleanInterpretationForKey:@"customGetterboolProperty" inObject:context], @"");
    STAssertEquals(NO, [self looseBooleanInterpretationForKey:@"isCustomGetterboolProperty" inObject:context], @"");
    STAssertEquals(NO, [self looseBooleanInterpretationForKey:@"customGetterboolProperty" inObject:inheritingContext], @"");
    STAssertEquals(NO, [self looseBooleanInterpretationForKey:@"isCustomGetterboolProperty" inObject:inheritingContext], @"");
    
    context.customGetterboolProperty = YES;
    inheritingContext.customGetterboolProperty = YES;
    STAssertEquals(YES, [self looseBooleanInterpretationForKey:@"customGetterboolProperty" inObject:context], @"");
    STAssertEquals(YES, [self looseBooleanInterpretationForKey:@"isCustomGetterboolProperty" inObject:context], @"");
    STAssertEquals(YES, [self looseBooleanInterpretationForKey:@"customGetterboolProperty" inObject:inheritingContext], @"");
    STAssertEquals(YES, [self looseBooleanInterpretationForKey:@"isCustomGetterboolProperty" inObject:inheritingContext], @"");
}

- (void)testLoose_boolFalseProperty_isFalseValue
{
    id context = [[[GRBooleanTestSupport alloc] init] autorelease];
    id inheritingContext = [[[GRBooleanTestSupportSubClass alloc] init] autorelease];
    STAssertEquals(NO, [self looseBooleanInterpretationForKey:@"boolFalseProperty" inObject:context], @"");
    STAssertEquals(NO, [self looseBooleanInterpretationForKey:@"boolFalseProperty" inObject:inheritingContext], @"");
}
- (void)testLoose_boolTrueProperty_isTrueValue
{
    id context = [[[GRBooleanTestSupport alloc] init] autorelease];
    id inheritingContext = [[[GRBooleanTestSupportSubClass alloc] init] autorelease];
    STAssertEquals(YES, [self looseBooleanInterpretationForKey:@"boolTrueProperty" inObject:context], @"");
    STAssertEquals(YES, [self looseBooleanInterpretationForKey:@"boolTrueProperty" inObject:inheritingContext], @"");
}
- (void)testLoose_BOOLFalseProperty_isTrueValue
{
    id context = [[[GRBooleanTestSupport alloc] init] autorelease];
    id inheritingContext = [[[GRBooleanTestSupportSubClass alloc] init] autorelease];
    STAssertEquals(NO, [self looseBooleanInterpretationForKey:@"BOOLFalseProperty" inObject:context], @"");
    STAssertEquals(NO, [self looseBooleanInterpretationForKey:@"BOOLFalseProperty" inObject:inheritingContext], @"");
}
- (void)testLoose_BOOLTrueProperty_isTrueValue
{
    id context = [[[GRBooleanTestSupport alloc] init] autorelease];
    id inheritingContext = [[[GRBooleanTestSupportSubClass alloc] init] autorelease];
    STAssertEquals(YES, [self looseBooleanInterpretationForKey:@"BOOLTrueProperty" inObject:context], @"");
    STAssertEquals(YES, [self looseBooleanInterpretationForKey:@"BOOLTrueProperty" inObject:inheritingContext], @"");
}
- (void)testLoose_charFalseProperty_isTrueValue
{
    id context = [[[GRBooleanTestSupport alloc] init] autorelease];
    id inheritingContext = [[[GRBooleanTestSupportSubClass alloc] init] autorelease];
    STAssertEquals(NO, [self looseBooleanInterpretationForKey:@"charFalseProperty" inObject:context], @"");
    STAssertEquals(NO, [self looseBooleanInterpretationForKey:@"charFalseProperty" inObject:inheritingContext], @"");
}
- (void)testLoose_charTrueProperty_isTrueValue
{
    id context = [[[GRBooleanTestSupport alloc] init] autorelease];
    id inheritingContext = [[[GRBooleanTestSupportSubClass alloc] init] autorelease];
    STAssertEquals(YES, [self looseBooleanInterpretationForKey:@"charTrueProperty" inObject:context], @"");
    STAssertEquals(YES, [self looseBooleanInterpretationForKey:@"charTrueProperty" inObject:inheritingContext], @"");
}
- (void)testLoose_unsigned_charFalseProperty_isTrueValue
{
    id context = [[[GRBooleanTestSupport alloc] init] autorelease];
    id inheritingContext = [[[GRBooleanTestSupportSubClass alloc] init] autorelease];
    STAssertEquals(YES, [self looseBooleanInterpretationForKey:@"unsigned_charFalseProperty" inObject:context], @"");
    STAssertEquals(YES, [self looseBooleanInterpretationForKey:@"unsigned_charFalseProperty" inObject:inheritingContext], @"");
}
- (void)testLoose_unsigned_charTrueProperty_isTrueValue
{
    id context = [[[GRBooleanTestSupport alloc] init] autorelease];
    id inheritingContext = [[[GRBooleanTestSupportSubClass alloc] init] autorelease];
    STAssertEquals(YES, [self looseBooleanInterpretationForKey:@"unsigned_charTrueProperty" inObject:context], @"");
    STAssertEquals(YES, [self looseBooleanInterpretationForKey:@"unsigned_charTrueProperty" inObject:inheritingContext], @"");
}
- (void)testLoose_intFalseProperty_isTrueValue
{
    id context = [[[GRBooleanTestSupport alloc] init] autorelease];
    id inheritingContext = [[[GRBooleanTestSupportSubClass alloc] init] autorelease];
    STAssertEquals(YES, [self looseBooleanInterpretationForKey:@"intFalseProperty" inObject:context], @"");
    STAssertEquals(YES, [self looseBooleanInterpretationForKey:@"intFalseProperty" inObject:inheritingContext], @"");
}
- (void)testLoose_intTrueProperty_isTrueValue
{
    id context = [[[GRBooleanTestSupport alloc] init] autorelease];
    id inheritingContext = [[[GRBooleanTestSupportSubClass alloc] init] autorelease];
    STAssertEquals(YES, [self looseBooleanInterpretationForKey:@"intTrueProperty" inObject:context], @"");
    STAssertEquals(YES, [self looseBooleanInterpretationForKey:@"intTrueProperty" inObject:inheritingContext], @"");
}
- (void)testLoose_boolFalseMethod_isFalseValue
{
    id context = [[[GRBooleanTestSupport alloc] init] autorelease];
    id inheritingContext = [[[GRBooleanTestSupportSubClass alloc] init] autorelease];
    STAssertEquals(NO, [self looseBooleanInterpretationForKey:@"boolFalseMethod" inObject:context], @"");
    STAssertEquals(NO, [self looseBooleanInterpretationForKey:@"boolFalseMethod" inObject:inheritingContext], @"");
}
- (void)testLoose_boolTrueMethod_isTrueValue
{
    id context = [[[GRBooleanTestSupport alloc] init] autorelease];
    id inheritingContext = [[[GRBooleanTestSupportSubClass alloc] init] autorelease];
    STAssertEquals(YES, [self looseBooleanInterpretationForKey:@"boolTrueMethod" inObject:context], @"");
    STAssertEquals(YES, [self looseBooleanInterpretationForKey:@"boolTrueMethod" inObject:inheritingContext], @"");
}
- (void)testLoose_BOOLFalseMethod_isTrueValue
{
    id context = [[[GRBooleanTestSupport alloc] init] autorelease];
    id inheritingContext = [[[GRBooleanTestSupportSubClass alloc] init] autorelease];
    STAssertEquals(YES, [self looseBooleanInterpretationForKey:@"BOOLFalseMethod" inObject:context], @"");
    STAssertEquals(YES, [self looseBooleanInterpretationForKey:@"BOOLFalseMethod" inObject:inheritingContext], @"");
}
- (void)testLoose_BOOLTrueMethod_isTrueValue
{
    id context = [[[GRBooleanTestSupport alloc] init] autorelease];
    id inheritingContext = [[[GRBooleanTestSupportSubClass alloc] init] autorelease];
    STAssertEquals(YES, [self looseBooleanInterpretationForKey:@"BOOLTrueMethod" inObject:context], @"");
    STAssertEquals(YES, [self looseBooleanInterpretationForKey:@"BOOLTrueMethod" inObject:inheritingContext], @"");
}
- (void)testLoose_charFalseMethod_isTrueValue
{
    id context = [[[GRBooleanTestSupport alloc] init] autorelease];
    id inheritingContext = [[[GRBooleanTestSupportSubClass alloc] init] autorelease];
    STAssertEquals(YES, [self looseBooleanInterpretationForKey:@"charFalseMethod" inObject:context], @"");
    STAssertEquals(YES, [self looseBooleanInterpretationForKey:@"charFalseMethod" inObject:inheritingContext], @"");
}
- (void)testLoose_charTrueMethod_isTrueValue
{
    id context = [[[GRBooleanTestSupport alloc] init] autorelease];
    id inheritingContext = [[[GRBooleanTestSupportSubClass alloc] init] autorelease];
    STAssertEquals(YES, [self looseBooleanInterpretationForKey:@"charTrueMethod" inObject:context], @"");
    STAssertEquals(YES, [self looseBooleanInterpretationForKey:@"charTrueMethod" inObject:inheritingContext], @"");
}
- (void)testLoose_unsigned_charFalseMethod_isTrueValue
{
    id context = [[[GRBooleanTestSupport alloc] init] autorelease];
    id inheritingContext = [[[GRBooleanTestSupportSubClass alloc] init] autorelease];
    STAssertEquals(YES, [self looseBooleanInterpretationForKey:@"unsigned_charFalseMethod" inObject:context], @"");
    STAssertEquals(YES, [self looseBooleanInterpretationForKey:@"unsigned_charFalseMethod" inObject:inheritingContext], @"");
}
- (void)testLoose_unsigned_charTrueMethod_isTrueValue
{
    id context = [[[GRBooleanTestSupport alloc] init] autorelease];
    id inheritingContext = [[[GRBooleanTestSupportSubClass alloc] init] autorelease];
    STAssertEquals(YES, [self looseBooleanInterpretationForKey:@"unsigned_charTrueMethod" inObject:context], @"");
    STAssertEquals(YES, [self looseBooleanInterpretationForKey:@"unsigned_charTrueMethod" inObject:inheritingContext], @"");
}
- (void)testLoose_intFalseMethod_isTrueValue
{
    id context = [[[GRBooleanTestSupport alloc] init] autorelease];
    id inheritingContext = [[[GRBooleanTestSupportSubClass alloc] init] autorelease];
    STAssertEquals(YES, [self looseBooleanInterpretationForKey:@"intFalseMethod" inObject:context], @"");
    STAssertEquals(YES, [self looseBooleanInterpretationForKey:@"intFalseMethod" inObject:inheritingContext], @"");
}
- (void)testLoose_intTrueMethod_isTrueValue
{
    id context = [[[GRBooleanTestSupport alloc] init] autorelease];
    id inheritingContext = [[[GRBooleanTestSupportSubClass alloc] init] autorelease];
    STAssertEquals(YES, [self looseBooleanInterpretationForKey:@"intTrueMethod" inObject:context], @"");
    STAssertEquals(YES, [self looseBooleanInterpretationForKey:@"intTrueMethod" inObject:inheritingContext], @"");
}

@end
