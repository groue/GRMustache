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

#import "GRMustacheBooleanPropertyTest.h"

@interface GRMustacheBooleanPropertyTestSupport: NSObject
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

@implementation GRMustacheBooleanPropertyTestSupport
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

@interface GRMustacheBooleanPropertyTestSupportSubClass: GRMustacheBooleanPropertyTestSupport
@end

@implementation GRMustacheBooleanPropertyTestSupportSubClass
@end

@implementation GRMustacheBooleanPropertyTest

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

- (void)testStrictCustomGetterBOOLProperty
{
    GRMustacheBooleanPropertyTestSupport *context = [[[GRMustacheBooleanPropertyTestSupport alloc] init] autorelease];
    GRMustacheBooleanPropertyTestSupportSubClass *inheritingContext = [[[GRMustacheBooleanPropertyTestSupportSubClass alloc] init] autorelease];
    
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
    GRMustacheBooleanPropertyTestSupport *context = [[[GRMustacheBooleanPropertyTestSupport alloc] init] autorelease];
    GRMustacheBooleanPropertyTestSupportSubClass *inheritingContext = [[[GRMustacheBooleanPropertyTestSupportSubClass alloc] init] autorelease];
    
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
    id context = [[[GRMustacheBooleanPropertyTestSupport alloc] init] autorelease];
    id inheritingContext = [[[GRMustacheBooleanPropertyTestSupportSubClass alloc] init] autorelease];
    STAssertEquals(NO, [self strictBooleanInterpretationForKey:@"boolFalseProperty" inObject:context], @"");
    STAssertEquals(NO, [self strictBooleanInterpretationForKey:@"boolFalseProperty" inObject:inheritingContext], @"");
}
- (void)testStrict_boolTrueProperty_isTrueValue
{
    id context = [[[GRMustacheBooleanPropertyTestSupport alloc] init] autorelease];
    id inheritingContext = [[[GRMustacheBooleanPropertyTestSupportSubClass alloc] init] autorelease];
    STAssertEquals(YES, [self strictBooleanInterpretationForKey:@"boolTrueProperty" inObject:context], @"");
    STAssertEquals(YES, [self strictBooleanInterpretationForKey:@"boolTrueProperty" inObject:inheritingContext], @"");
}
- (void)testStrict_BOOLFalseProperty_isTrueValue
{
    id context = [[[GRMustacheBooleanPropertyTestSupport alloc] init] autorelease];
    id inheritingContext = [[[GRMustacheBooleanPropertyTestSupportSubClass alloc] init] autorelease];
    STAssertEquals(YES, [self strictBooleanInterpretationForKey:@"BOOLFalseProperty" inObject:context], @"");
    STAssertEquals(YES, [self strictBooleanInterpretationForKey:@"BOOLFalseProperty" inObject:inheritingContext], @"");
}
- (void)testStrict_BOOLTrueProperty_isTrueValue
{
    id context = [[[GRMustacheBooleanPropertyTestSupport alloc] init] autorelease];
    id inheritingContext = [[[GRMustacheBooleanPropertyTestSupportSubClass alloc] init] autorelease];
    STAssertEquals(YES, [self strictBooleanInterpretationForKey:@"BOOLTrueProperty" inObject:context], @"");
    STAssertEquals(YES, [self strictBooleanInterpretationForKey:@"BOOLTrueProperty" inObject:inheritingContext], @"");
}
- (void)testStrict_charFalseProperty_isTrueValue
{
    id context = [[[GRMustacheBooleanPropertyTestSupport alloc] init] autorelease];
    id inheritingContext = [[[GRMustacheBooleanPropertyTestSupportSubClass alloc] init] autorelease];
    STAssertEquals(YES, [self strictBooleanInterpretationForKey:@"charFalseProperty" inObject:context], @"");
    STAssertEquals(YES, [self strictBooleanInterpretationForKey:@"charFalseProperty" inObject:inheritingContext], @"");
}
- (void)testStrict_charTrueProperty_isTrueValue
{
    id context = [[[GRMustacheBooleanPropertyTestSupport alloc] init] autorelease];
    id inheritingContext = [[[GRMustacheBooleanPropertyTestSupportSubClass alloc] init] autorelease];
    STAssertEquals(YES, [self strictBooleanInterpretationForKey:@"charTrueProperty" inObject:context], @"");
    STAssertEquals(YES, [self strictBooleanInterpretationForKey:@"charTrueProperty" inObject:inheritingContext], @"");
}
- (void)testStrict_unsigned_charFalseProperty_isTrueValue
{
    id context = [[[GRMustacheBooleanPropertyTestSupport alloc] init] autorelease];
    id inheritingContext = [[[GRMustacheBooleanPropertyTestSupportSubClass alloc] init] autorelease];
    STAssertEquals(YES, [self strictBooleanInterpretationForKey:@"unsigned_charFalseProperty" inObject:context], @"");
    STAssertEquals(YES, [self strictBooleanInterpretationForKey:@"unsigned_charFalseProperty" inObject:inheritingContext], @"");
}
- (void)testStrict_unsigned_charTrueProperty_isTrueValue
{
    id context = [[[GRMustacheBooleanPropertyTestSupport alloc] init] autorelease];
    id inheritingContext = [[[GRMustacheBooleanPropertyTestSupportSubClass alloc] init] autorelease];
    STAssertEquals(YES, [self strictBooleanInterpretationForKey:@"unsigned_charTrueProperty" inObject:context], @"");
    STAssertEquals(YES, [self strictBooleanInterpretationForKey:@"unsigned_charTrueProperty" inObject:inheritingContext], @"");
}
- (void)testStrict_intFalseProperty_isTrueValue
{
    id context = [[[GRMustacheBooleanPropertyTestSupport alloc] init] autorelease];
    id inheritingContext = [[[GRMustacheBooleanPropertyTestSupportSubClass alloc] init] autorelease];
    STAssertEquals(YES, [self strictBooleanInterpretationForKey:@"intFalseProperty" inObject:context], @"");
    STAssertEquals(YES, [self strictBooleanInterpretationForKey:@"intFalseProperty" inObject:inheritingContext], @"");
}
- (void)testStrict_intTrueProperty_isTrueValue
{
    id context = [[[GRMustacheBooleanPropertyTestSupport alloc] init] autorelease];
    id inheritingContext = [[[GRMustacheBooleanPropertyTestSupportSubClass alloc] init] autorelease];
    STAssertEquals(YES, [self strictBooleanInterpretationForKey:@"intTrueProperty" inObject:context], @"");
    STAssertEquals(YES, [self strictBooleanInterpretationForKey:@"intTrueProperty" inObject:inheritingContext], @"");
}
- (void)testStrict_boolFalseMethod_isFalseValue
{
    id context = [[[GRMustacheBooleanPropertyTestSupport alloc] init] autorelease];
    id inheritingContext = [[[GRMustacheBooleanPropertyTestSupportSubClass alloc] init] autorelease];
    STAssertEquals(NO, [self strictBooleanInterpretationForKey:@"boolFalseMethod" inObject:context], @"");
    STAssertEquals(NO, [self strictBooleanInterpretationForKey:@"boolFalseMethod" inObject:inheritingContext], @"");
}
- (void)testStrict_boolTrueMethod_isTrueValue
{
    id context = [[[GRMustacheBooleanPropertyTestSupport alloc] init] autorelease];
    id inheritingContext = [[[GRMustacheBooleanPropertyTestSupportSubClass alloc] init] autorelease];
    STAssertEquals(YES, [self strictBooleanInterpretationForKey:@"boolTrueMethod" inObject:context], @"");
    STAssertEquals(YES, [self strictBooleanInterpretationForKey:@"boolTrueMethod" inObject:inheritingContext], @"");
}
- (void)testStrict_BOOLFalseMethod_isTrueValue
{
    id context = [[[GRMustacheBooleanPropertyTestSupport alloc] init] autorelease];
    id inheritingContext = [[[GRMustacheBooleanPropertyTestSupportSubClass alloc] init] autorelease];
    STAssertEquals(YES, [self strictBooleanInterpretationForKey:@"BOOLFalseMethod" inObject:context], @"");
    STAssertEquals(YES, [self strictBooleanInterpretationForKey:@"BOOLFalseMethod" inObject:inheritingContext], @"");
}
- (void)testStrict_BOOLTrueMethod_isTrueValue
{
    id context = [[[GRMustacheBooleanPropertyTestSupport alloc] init] autorelease];
    id inheritingContext = [[[GRMustacheBooleanPropertyTestSupportSubClass alloc] init] autorelease];
    STAssertEquals(YES, [self strictBooleanInterpretationForKey:@"BOOLTrueMethod" inObject:context], @"");
    STAssertEquals(YES, [self strictBooleanInterpretationForKey:@"BOOLTrueMethod" inObject:inheritingContext], @"");
}
- (void)testStrict_charFalseMethod_isTrueValue
{
    id context = [[[GRMustacheBooleanPropertyTestSupport alloc] init] autorelease];
    id inheritingContext = [[[GRMustacheBooleanPropertyTestSupportSubClass alloc] init] autorelease];
    STAssertEquals(YES, [self strictBooleanInterpretationForKey:@"charFalseMethod" inObject:context], @"");
    STAssertEquals(YES, [self strictBooleanInterpretationForKey:@"charFalseMethod" inObject:inheritingContext], @"");
}
- (void)testStrict_charTrueMethod_isTrueValue
{
    id context = [[[GRMustacheBooleanPropertyTestSupport alloc] init] autorelease];
    id inheritingContext = [[[GRMustacheBooleanPropertyTestSupportSubClass alloc] init] autorelease];
    STAssertEquals(YES, [self strictBooleanInterpretationForKey:@"charTrueMethod" inObject:context], @"");
    STAssertEquals(YES, [self strictBooleanInterpretationForKey:@"charTrueMethod" inObject:inheritingContext], @"");
}
- (void)testStrict_unsigned_charFalseMethod_isTrueValue
{
    id context = [[[GRMustacheBooleanPropertyTestSupport alloc] init] autorelease];
    id inheritingContext = [[[GRMustacheBooleanPropertyTestSupportSubClass alloc] init] autorelease];
    STAssertEquals(YES, [self strictBooleanInterpretationForKey:@"unsigned_charFalseMethod" inObject:context], @"");
    STAssertEquals(YES, [self strictBooleanInterpretationForKey:@"unsigned_charFalseMethod" inObject:inheritingContext], @"");
}
- (void)testStrict_unsigned_charTrueMethod_isTrueValue
{
    id context = [[[GRMustacheBooleanPropertyTestSupport alloc] init] autorelease];
    id inheritingContext = [[[GRMustacheBooleanPropertyTestSupportSubClass alloc] init] autorelease];
    STAssertEquals(YES, [self strictBooleanInterpretationForKey:@"unsigned_charTrueMethod" inObject:context], @"");
    STAssertEquals(YES, [self strictBooleanInterpretationForKey:@"unsigned_charTrueMethod" inObject:inheritingContext], @"");
}
- (void)testStrict_intFalseMethod_isTrueValue
{
    id context = [[[GRMustacheBooleanPropertyTestSupport alloc] init] autorelease];
    id inheritingContext = [[[GRMustacheBooleanPropertyTestSupportSubClass alloc] init] autorelease];
    STAssertEquals(YES, [self strictBooleanInterpretationForKey:@"intFalseMethod" inObject:context], @"");
    STAssertEquals(YES, [self strictBooleanInterpretationForKey:@"intFalseMethod" inObject:inheritingContext], @"");
}
- (void)testStrict_intTrueMethod_isTrueValue
{
    id context = [[[GRMustacheBooleanPropertyTestSupport alloc] init] autorelease];
    id inheritingContext = [[[GRMustacheBooleanPropertyTestSupportSubClass alloc] init] autorelease];
    STAssertEquals(YES, [self strictBooleanInterpretationForKey:@"intTrueMethod" inObject:context], @"");
    STAssertEquals(YES, [self strictBooleanInterpretationForKey:@"intTrueMethod" inObject:inheritingContext], @"");
}

- (void)testLooseCustomGetterBOOLProperty
{
    GRMustacheBooleanPropertyTestSupport *context = [[[GRMustacheBooleanPropertyTestSupport alloc] init] autorelease];
    GRMustacheBooleanPropertyTestSupportSubClass *inheritingContext = [[[GRMustacheBooleanPropertyTestSupportSubClass alloc] init] autorelease];
    
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
    GRMustacheBooleanPropertyTestSupport *context = [[[GRMustacheBooleanPropertyTestSupport alloc] init] autorelease];
    GRMustacheBooleanPropertyTestSupportSubClass *inheritingContext = [[[GRMustacheBooleanPropertyTestSupportSubClass alloc] init] autorelease];
    
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
    id context = [[[GRMustacheBooleanPropertyTestSupport alloc] init] autorelease];
    id inheritingContext = [[[GRMustacheBooleanPropertyTestSupportSubClass alloc] init] autorelease];
    STAssertEquals(NO, [self looseBooleanInterpretationForKey:@"boolFalseProperty" inObject:context], @"");
    STAssertEquals(NO, [self looseBooleanInterpretationForKey:@"boolFalseProperty" inObject:inheritingContext], @"");
}
- (void)testLoose_boolTrueProperty_isTrueValue
{
    id context = [[[GRMustacheBooleanPropertyTestSupport alloc] init] autorelease];
    id inheritingContext = [[[GRMustacheBooleanPropertyTestSupportSubClass alloc] init] autorelease];
    STAssertEquals(YES, [self looseBooleanInterpretationForKey:@"boolTrueProperty" inObject:context], @"");
    STAssertEquals(YES, [self looseBooleanInterpretationForKey:@"boolTrueProperty" inObject:inheritingContext], @"");
}
- (void)testLoose_BOOLFalseProperty_isTrueValue
{
    id context = [[[GRMustacheBooleanPropertyTestSupport alloc] init] autorelease];
    id inheritingContext = [[[GRMustacheBooleanPropertyTestSupportSubClass alloc] init] autorelease];
    STAssertEquals(NO, [self looseBooleanInterpretationForKey:@"BOOLFalseProperty" inObject:context], @"");
    STAssertEquals(NO, [self looseBooleanInterpretationForKey:@"BOOLFalseProperty" inObject:inheritingContext], @"");
}
- (void)testLoose_BOOLTrueProperty_isTrueValue
{
    id context = [[[GRMustacheBooleanPropertyTestSupport alloc] init] autorelease];
    id inheritingContext = [[[GRMustacheBooleanPropertyTestSupportSubClass alloc] init] autorelease];
    STAssertEquals(YES, [self looseBooleanInterpretationForKey:@"BOOLTrueProperty" inObject:context], @"");
    STAssertEquals(YES, [self looseBooleanInterpretationForKey:@"BOOLTrueProperty" inObject:inheritingContext], @"");
}
- (void)testLoose_charFalseProperty_isTrueValue
{
    id context = [[[GRMustacheBooleanPropertyTestSupport alloc] init] autorelease];
    id inheritingContext = [[[GRMustacheBooleanPropertyTestSupportSubClass alloc] init] autorelease];
    STAssertEquals(NO, [self looseBooleanInterpretationForKey:@"charFalseProperty" inObject:context], @"");
    STAssertEquals(NO, [self looseBooleanInterpretationForKey:@"charFalseProperty" inObject:inheritingContext], @"");
}
- (void)testLoose_charTrueProperty_isTrueValue
{
    id context = [[[GRMustacheBooleanPropertyTestSupport alloc] init] autorelease];
    id inheritingContext = [[[GRMustacheBooleanPropertyTestSupportSubClass alloc] init] autorelease];
    STAssertEquals(YES, [self looseBooleanInterpretationForKey:@"charTrueProperty" inObject:context], @"");
    STAssertEquals(YES, [self looseBooleanInterpretationForKey:@"charTrueProperty" inObject:inheritingContext], @"");
}
- (void)testLoose_unsigned_charFalseProperty_isTrueValue
{
    id context = [[[GRMustacheBooleanPropertyTestSupport alloc] init] autorelease];
    id inheritingContext = [[[GRMustacheBooleanPropertyTestSupportSubClass alloc] init] autorelease];
    STAssertEquals(YES, [self looseBooleanInterpretationForKey:@"unsigned_charFalseProperty" inObject:context], @"");
    STAssertEquals(YES, [self looseBooleanInterpretationForKey:@"unsigned_charFalseProperty" inObject:inheritingContext], @"");
}
- (void)testLoose_unsigned_charTrueProperty_isTrueValue
{
    id context = [[[GRMustacheBooleanPropertyTestSupport alloc] init] autorelease];
    id inheritingContext = [[[GRMustacheBooleanPropertyTestSupportSubClass alloc] init] autorelease];
    STAssertEquals(YES, [self looseBooleanInterpretationForKey:@"unsigned_charTrueProperty" inObject:context], @"");
    STAssertEquals(YES, [self looseBooleanInterpretationForKey:@"unsigned_charTrueProperty" inObject:inheritingContext], @"");
}
- (void)testLoose_intFalseProperty_isTrueValue
{
    id context = [[[GRMustacheBooleanPropertyTestSupport alloc] init] autorelease];
    id inheritingContext = [[[GRMustacheBooleanPropertyTestSupportSubClass alloc] init] autorelease];
    STAssertEquals(YES, [self looseBooleanInterpretationForKey:@"intFalseProperty" inObject:context], @"");
    STAssertEquals(YES, [self looseBooleanInterpretationForKey:@"intFalseProperty" inObject:inheritingContext], @"");
}
- (void)testLoose_intTrueProperty_isTrueValue
{
    id context = [[[GRMustacheBooleanPropertyTestSupport alloc] init] autorelease];
    id inheritingContext = [[[GRMustacheBooleanPropertyTestSupportSubClass alloc] init] autorelease];
    STAssertEquals(YES, [self looseBooleanInterpretationForKey:@"intTrueProperty" inObject:context], @"");
    STAssertEquals(YES, [self looseBooleanInterpretationForKey:@"intTrueProperty" inObject:inheritingContext], @"");
}
- (void)testLoose_boolFalseMethod_isFalseValue
{
    id context = [[[GRMustacheBooleanPropertyTestSupport alloc] init] autorelease];
    id inheritingContext = [[[GRMustacheBooleanPropertyTestSupportSubClass alloc] init] autorelease];
    STAssertEquals(NO, [self looseBooleanInterpretationForKey:@"boolFalseMethod" inObject:context], @"");
    STAssertEquals(NO, [self looseBooleanInterpretationForKey:@"boolFalseMethod" inObject:inheritingContext], @"");
}
- (void)testLoose_boolTrueMethod_isTrueValue
{
    id context = [[[GRMustacheBooleanPropertyTestSupport alloc] init] autorelease];
    id inheritingContext = [[[GRMustacheBooleanPropertyTestSupportSubClass alloc] init] autorelease];
    STAssertEquals(YES, [self looseBooleanInterpretationForKey:@"boolTrueMethod" inObject:context], @"");
    STAssertEquals(YES, [self looseBooleanInterpretationForKey:@"boolTrueMethod" inObject:inheritingContext], @"");
}
- (void)testLoose_BOOLFalseMethod_isTrueValue
{
    id context = [[[GRMustacheBooleanPropertyTestSupport alloc] init] autorelease];
    id inheritingContext = [[[GRMustacheBooleanPropertyTestSupportSubClass alloc] init] autorelease];
    STAssertEquals(YES, [self looseBooleanInterpretationForKey:@"BOOLFalseMethod" inObject:context], @"");
    STAssertEquals(YES, [self looseBooleanInterpretationForKey:@"BOOLFalseMethod" inObject:inheritingContext], @"");
}
- (void)testLoose_BOOLTrueMethod_isTrueValue
{
    id context = [[[GRMustacheBooleanPropertyTestSupport alloc] init] autorelease];
    id inheritingContext = [[[GRMustacheBooleanPropertyTestSupportSubClass alloc] init] autorelease];
    STAssertEquals(YES, [self looseBooleanInterpretationForKey:@"BOOLTrueMethod" inObject:context], @"");
    STAssertEquals(YES, [self looseBooleanInterpretationForKey:@"BOOLTrueMethod" inObject:inheritingContext], @"");
}
- (void)testLoose_charFalseMethod_isTrueValue
{
    id context = [[[GRMustacheBooleanPropertyTestSupport alloc] init] autorelease];
    id inheritingContext = [[[GRMustacheBooleanPropertyTestSupportSubClass alloc] init] autorelease];
    STAssertEquals(YES, [self looseBooleanInterpretationForKey:@"charFalseMethod" inObject:context], @"");
    STAssertEquals(YES, [self looseBooleanInterpretationForKey:@"charFalseMethod" inObject:inheritingContext], @"");
}
- (void)testLoose_charTrueMethod_isTrueValue
{
    id context = [[[GRMustacheBooleanPropertyTestSupport alloc] init] autorelease];
    id inheritingContext = [[[GRMustacheBooleanPropertyTestSupportSubClass alloc] init] autorelease];
    STAssertEquals(YES, [self looseBooleanInterpretationForKey:@"charTrueMethod" inObject:context], @"");
    STAssertEquals(YES, [self looseBooleanInterpretationForKey:@"charTrueMethod" inObject:inheritingContext], @"");
}
- (void)testLoose_unsigned_charFalseMethod_isTrueValue
{
    id context = [[[GRMustacheBooleanPropertyTestSupport alloc] init] autorelease];
    id inheritingContext = [[[GRMustacheBooleanPropertyTestSupportSubClass alloc] init] autorelease];
    STAssertEquals(YES, [self looseBooleanInterpretationForKey:@"unsigned_charFalseMethod" inObject:context], @"");
    STAssertEquals(YES, [self looseBooleanInterpretationForKey:@"unsigned_charFalseMethod" inObject:inheritingContext], @"");
}
- (void)testLoose_unsigned_charTrueMethod_isTrueValue
{
    id context = [[[GRMustacheBooleanPropertyTestSupport alloc] init] autorelease];
    id inheritingContext = [[[GRMustacheBooleanPropertyTestSupportSubClass alloc] init] autorelease];
    STAssertEquals(YES, [self looseBooleanInterpretationForKey:@"unsigned_charTrueMethod" inObject:context], @"");
    STAssertEquals(YES, [self looseBooleanInterpretationForKey:@"unsigned_charTrueMethod" inObject:inheritingContext], @"");
}
- (void)testLoose_intFalseMethod_isTrueValue
{
    id context = [[[GRMustacheBooleanPropertyTestSupport alloc] init] autorelease];
    id inheritingContext = [[[GRMustacheBooleanPropertyTestSupportSubClass alloc] init] autorelease];
    STAssertEquals(YES, [self looseBooleanInterpretationForKey:@"intFalseMethod" inObject:context], @"");
    STAssertEquals(YES, [self looseBooleanInterpretationForKey:@"intFalseMethod" inObject:inheritingContext], @"");
}
- (void)testLoose_intTrueMethod_isTrueValue
{
    id context = [[[GRMustacheBooleanPropertyTestSupport alloc] init] autorelease];
    id inheritingContext = [[[GRMustacheBooleanPropertyTestSupportSubClass alloc] init] autorelease];
    STAssertEquals(YES, [self looseBooleanInterpretationForKey:@"intTrueMethod" inObject:context], @"");
    STAssertEquals(YES, [self looseBooleanInterpretationForKey:@"intTrueMethod" inObject:inheritingContext], @"");
}

@end

