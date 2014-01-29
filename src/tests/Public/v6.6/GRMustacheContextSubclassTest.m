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

#define GRMUSTACHE_VERSION_MAX_ALLOWED GRMUSTACHE_VERSION_6_6
#import "GRMustachePublicAPITest.h"

struct GRPoint {
    float x;
    float y;
};
@interface GRDocumentMustacheContext : GRMustacheContext
@property (nonatomic, readonly) NSInteger currentInteger;
@property (nonatomic, readonly) NSInteger succ;
@property (nonatomic) NSInteger age;
@property (nonatomic, copy) NSString *string;
@property (nonatomic, retain) NSNumber *ageNumber;
@property (nonatomic) struct GRPoint point;
@property (nonatomic) SEL selector;
@property (nonatomic) char *charPtr;
@property (nonatomic) int *intPtr;
@property (nonatomic) BOOL nice;
@property (nonatomic, getter = getPropertyWithCustomGetter) int propertyWithCustomGetter;
@property (nonatomic, setter = updatePropertyWithCustomSetter:) int propertyWithCustomSetter;
@property (nonatomic, setter = updatePointPropertyWithCustomSetter:) struct GRPoint pointPropertyWithCustomSetter;
@end

@implementation GRDocumentMustacheContext
@dynamic currentInteger;
@dynamic string;
@dynamic age;
@dynamic ageNumber;
@dynamic point;
@dynamic selector;
@dynamic charPtr;
@dynamic intPtr;
@dynamic nice;
@dynamic propertyWithCustomGetter;
@dynamic propertyWithCustomSetter;
@dynamic pointPropertyWithCustomSetter;

- (void)setNilValueForKey:(NSString *)key
{
    [self setValue:[NSNumber numberWithInt:0] forKey:key];
}

- (NSInteger)succ
{
    return [[self valueForMustacheKey:@"number"] integerValue] + 1;
}

- (NSInteger)pred
{
    return [self succ] - 2;
}

- (id)name
{
    return @"defaultName";
}

@end

@interface GRMustacheRubyExampleContext : GRMustacheContext
@property (nonatomic, retain) NSString *name;
@property (nonatomic) float value;
@property (nonatomic) BOOL in_ca;
@end

@implementation GRMustacheRubyExampleContext
@dynamic name;
@dynamic value;
@dynamic in_ca;

- (float)taxed_value
{
    return self.value - self.value * 0.4;
}

@end

@interface GRMustacheRubyExampleContextSubclass : GRMustacheRubyExampleContext
@property (nonatomic, retain) NSString *title;
@end

@implementation GRMustacheRubyExampleContextSubclass
@dynamic title;
@end

@interface GRMustacheContextSubclassWithInitializer : GRMustacheContext
@property (nonatomic, retain) NSString *name;
@end

@implementation GRMustacheContextSubclassWithInitializer
@dynamic name;

- (id)init
{
    self = [super init];
    if (self) {
        self.name = @"defaultName";
    }
    return self;
}

@end

@interface GRDocumentMustacheContextTest : GRMustachePublicAPITest
@end

@implementation GRDocumentMustacheContextTest

- (void)testMustacheContextSubclassExtendsAvailableKeys
{
    // Behave just as the Ruby version
    //
    //    require "mustache"
    //
    //    class Document < Mustache
    //      self.template = "{{succ}}"
    //      def succ
    //        self[:number] + 1
    //      end
    //    end
    //
    //    puts Document.render(:number => 1)  # => 2

    NSString *templateString = @"{{succ}}";
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:templateString error:NULL];
    template.baseContext = [GRDocumentMustacheContext context];
    
    id data = @{ @"number": @1 };
    NSString *rendering = [template renderObject:data error:NULL];
    STAssertEqualObjects(rendering, @"2", @"");
}

- (void)testValueForMustacheKeyUsesFullContextStack
{
    // Behave just as the Ruby version:
    //
    //    require "mustache"
    //
    //    class Document < Mustache
    //      self.template = "{{succ}},{{#a}}{{succ}}{{/a}},{{#b}}{{succ}}{{/b}}"
    //      def succ
    //        self[:number] + 1
    //      end
    //    end
    //
    //    puts Document.render(:number => 1, :a => { :number => 2 }, :b => {})  # => 2,3,2

    NSString *templateString = @"{{succ}},{{#a}}{{succ}}{{/}},{{#b}}{{succ}}{{/}}";
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:templateString error:NULL];
    template.baseContext = [GRDocumentMustacheContext context];
    
    id data = @{ @"number": @1, @"a" : @{ @"number": @2 }, @"b" : @{ } };
    NSString *rendering = [template renderObject:data error:NULL];
    STAssertEqualObjects(rendering, @"2,3,2", @"");
}

- (void)testValueForMustacheKeyIsNotTriggeredByCompoundKeys
{
    // Behave just as the Ruby version:
    //
    //    require "mustache"
    //
    //    class Document < Mustache
    //      self.template = "{{a.succ}},{{b.succ}}"
    //      def succ
    //        self[:number] + 1
    //      end
    //    end
    //
    //    puts Document.render(:number => 1, :a => { :number => 2 }, :b => {})  # => ,
    
    NSString *templateString = @"{{succ}},{{a.succ}},{{#a}}{{succ}}{{/}},{{b.succ}},{{#b}}{{succ}}{{/}}";
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:templateString error:NULL];
    template.baseContext = [GRDocumentMustacheContext context];
    
    id data = @{ @"number": @1, @"a" : @{ @"number": @2 }, @"b" : @{ } };
    NSString *rendering = [template renderObject:data error:NULL];
    STAssertEqualObjects(rendering, @"2,,3,,2", @"");
}

- (void)testValueForMustacheKeyIsNotTriggeredByDotPrefixedKeys
{
    // Ruby version does not support `.name` expressions
    
    NSString *templateString = @"{{#a}}{{.succ}}{{/}},{{#b}}{{.succ}}{{/}}";
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:templateString error:NULL];
    template.baseContext = [GRDocumentMustacheContext context];
    
    id data = @{ @"number": @1, @"a" : @{ @"number": @2 }, @"b" : @{ } };
    NSString *rendering = [template renderObject:data error:NULL];
    STAssertEqualObjects(rendering, @",", @"");
}

- (void)testValueForMustacheKeyIsOnlyUsedForMissingKeys
{
    // Behave just as the Ruby version:
    //
    //    require "mustache"
    //    
    //    class Document < Mustache
    //      self.template = "name:{{name}}"
    //      def name
    //        "defaultName"
    //      end
    //    end
    //    
    //    puts Document.render                    # => name:defaultName
    //    puts Document.render(:name => 'Arthur') # => name:Arthur
    //    puts Document.render(:name => nil)      # => name:

    NSString *templateString = @"name:{{name}}";
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:templateString error:NULL];
    template.baseContext = [GRDocumentMustacheContext context];
    
    {
        NSString *rendering = [template renderObject:nil error:NULL];
        STAssertEqualObjects(rendering, @"name:defaultName", @"");
    }
    {
        id data = @{ @"name": @"Arthur" };
        NSString *rendering = [template renderObject:data error:NULL];
        STAssertEqualObjects(rendering, @"name:Arthur", @"");
    }
    {
        id data = @{ @"name": [NSNull null] };
        NSString *rendering = [template renderObject:data error:NULL];
        STAssertEqualObjects(rendering, @"name:", @"");
    }
}

- (void)testMustacheContextSubclassWithoutStandardLibrary
{
    NSString *templateString = @"{{uppercase(name)}}";
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:templateString error:NULL];
    template.baseContext = [GRDocumentMustacheContext context];
    
    // uppercase filter should not be defined
    NSError *error;
    NSString *rendering = [template renderObject:nil error:&error];
    STAssertNil(rendering, @"");
    STAssertEqualObjects(error.domain, GRMustacheErrorDomain, @"");
    STAssertEquals(error.code, GRMustacheErrorCodeRenderingError, @"");
}

- (void)testMustacheContextSubclassWithStandardLibrary
{
    NSString *templateString = @"{{uppercase(name)}}";
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:templateString error:NULL];
    template.baseContext = [GRDocumentMustacheContext contextWithObject:[GRMustache standardLibrary]];
    
    // uppercase filter should be defined
    NSString *rendering = [template renderObject:nil error:NULL];
    STAssertEqualObjects(rendering, @"DEFAULTNAME", @"");
}

- (void)testMustacheContextSubclassKeyDependencies
{
    // Behave just as the Ruby version:
    //
    //    require "mustache"
    //
    //    class Document < Mustache
    //      self.template = "{{pred}},{{#a}}{{pred}}{{/a}},{{#b}}{{pred}}{{/b}}"
    //      def succ
    //        self[:number] + 1
    //      end
    //      def pred
    //        # depends on self[:succ]
    //        self[:succ] - 2
    //      end
    //    end
    //
    //    puts Document.render(:number => 1, :a => { :number => 2 }, :b => {})  # => 0,1,0
    
    NSString *templateString = @"{{pred}},{{#a}}{{pred}}{{/}},{{#b}}{{pred}}{{/}}";
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:templateString error:NULL];
    template.baseContext = [GRDocumentMustacheContext context];
    
    id data = @{ @"number": @1, @"a" : @{ @"number": @2 }, @"b" : @{ } };
    NSString *rendering = [template renderObject:data error:NULL];
    STAssertEqualObjects(rendering, @"0,1,0", @"");
}

- (void)testMustacheContextSubclassSetters
{
    // Behave just as the Ruby version:
    //
    //    require "mustache"
    //
    //    class Document < Mustache
    //      self.template = "{{age}},{{#a}}{{age}}{{/a}},{{#b}}{{age}}{{/b}},{{ageNumber}},{{#a}}{{ageNumber}}{{/a}},{{#b}}{{ageNumber}}{{/b}}"
    //      attr_accessor :age
    //      attr_accessor :ageNumber
    //    end
    //
    //    document = Document.new
    //    document.age = 1
    //    document.ageNumber = 2
    //    puts document.render(:a => {}, :b => { :age => 3, :ageNumber => 4 })    # => 1,1,3,2,2,4
    
    NSString *templateString = @"{{age}},{{#a}}{{age}}{{/a}},{{#b}}{{age}}{{/b}},{{ageNumber}},{{#a}}{{ageNumber}}{{/a}},{{#b}}{{ageNumber}}{{/b}}";
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:templateString error:NULL];
    GRDocumentMustacheContext *context = [GRDocumentMustacheContext context];
    context.age = 1;                // test scalar property
    context.ageNumber = @2;         // test object property
    template.baseContext = context;
    
    id data = @{ @"a" : @{ }, @"b" : @{ @"age": @3, @"ageNumber": @4 } };
    NSString *rendering = [template renderObject:data error:NULL];
    STAssertEqualObjects(rendering, @"1,1,3,2,2,4", @"");
}

- (void)testRubyMustacheExample
{
    // Template
    NSString *templateString = @"Hello {{name}}\n"
                               @"You have just won ${{value}}!\n"
                               @"{{#in_ca}}"
                               @"Well, ${{taxed_value}}, after taxes."
                               @"{{/in_ca}}"
                               @"{{^in_ca}}"
                               @"You're lucky - in CA you'd be taxed like crazy!"
                               @"{{/in_ca}}";
    
    // Custom context
    GRMustacheRubyExampleContext *context = [GRMustacheRubyExampleContext context];
    context.name = @"Chris";
    context.value = 10000;
    context.in_ca = YES;
    
    {
        // Render with base context
        GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:templateString error:NULL];
        template.baseContext = context;
        NSString *rendering = [template renderObject:nil error:NULL];
        STAssertEqualObjects(rendering, @"Hello Chris\nYou have just won $10000!\nWell, $6000, after taxes.", @"");
    }
    {
        // Render without base context
        GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:templateString error:NULL];
        NSString *rendering = [template renderObject:context error:NULL];
        STAssertEqualObjects(rendering, @"Hello Chris\nYou have just won $10000!\nWell, $6000, after taxes.", @"");
    }
}

- (void)testUndefinedContextKeys
{
    GRMustacheContext *context = [GRMustacheContext context];
    STAssertThrows([context setValue:@"bar" forKey:@"foo"], @"");
    
    GRDocumentMustacheContext *document = [GRDocumentMustacheContext context];
    STAssertThrows([document setValue:@"bar" forKey:@"foo"], @"");
    STAssertThrows([document setValue:@"bar" forKey:@"currentInteger"], @"");
}

- (void)testCustomObjectKeys
{
    char *str = "string";
    int integer = 4;
    SEL selector = @selector(valueForKey:);
    NSMutableString *string = [NSMutableString stringWithString:@"foo"];
    GRDocumentMustacheContext *rootContext = [GRDocumentMustacheContext context];
    GRDocumentMustacheContext *context = rootContext;
    context.age = 1;                            // test scalar property
    context.ageNumber = @2;                     // test object property
    context.string = string;                    // test object property with copy storage
    context.point = (struct GRPoint){ 2, 3 };   // test struct property
    context.selector = selector;                // test SEL property
    context.charPtr = str;                      // test char* property
    context.intPtr = &integer;                  // test int* property
    context.nice = YES;
    context.propertyWithCustomGetter = 5;
    context.propertyWithCustomSetter = 6;
    [context updatePropertyWithCustomSetter:7];
    
    STAssertTrue([context respondsToSelector:@selector(age)], @"");
    STAssertTrue([context respondsToSelector:@selector(setAge:)], @"");
    STAssertTrue([context respondsToSelector:@selector(point)], @"");
    STAssertTrue([context respondsToSelector:@selector(setPoint:)], @"");
    STAssertTrue([context respondsToSelector:sel_registerName("propertyWithCustomGetter")], @"");           // Use sel_registerName instead of @selector so that we avoid triggering -Wundeclared-selector
    STAssertTrue([context respondsToSelector:@selector(getPropertyWithCustomGetter)], @"");
    STAssertTrue(![context respondsToSelector:sel_registerName("setPropertyWithCustomSetter:")], @"");      // Use sel_registerName instead of @selector so that we avoid triggering -Wundeclared-selector
    STAssertTrue([context respondsToSelector:@selector(updatePropertyWithCustomSetter:)], @"");
    STAssertTrue(![context respondsToSelector:sel_registerName("setPointPropertyWithCustomSetter:")], @""); // Use sel_registerName instead of @selector so that we avoid triggering -Wundeclared-selector
    STAssertTrue([context respondsToSelector:@selector(updatePointPropertyWithCustomSetter:)], @"");
    
    [string appendString:@"bar"];
    STAssertEqualObjects(context.string, @"foo", @"");    // the copy of string has not been mutated
    
    {
        // test valid objects
        context.age = 1;
        [context setValue:@"foo" forKey:@"age"];
        STAssertEquals(context.age, (NSInteger)1, @"");
        [context setValue:nil forKey:@"age"];       // test setNilValueForKey
        STAssertEquals(context.age, (NSInteger)0, @"");
        context.age = 1;
        STAssertEquals(context.age, (NSInteger)1, @"");
        [context setNilValueForKey:@"age"];
        STAssertEquals(context.age, (NSInteger)0, @"");
        [context setValue:@1 forKey:@"age"];
        STAssertEquals(context.age, (NSInteger)1, @"");
    }
    
    {
        context = [context contextByAddingProtectedObject:@{ @"currentInteger" : @42 }];

        // Test propagation with getters
        STAssertEquals(context.currentInteger, (NSInteger)42, @"");
        STAssertEquals(context.age, (NSInteger)1, @"");
        STAssertEqualObjects(context.ageNumber, @2, @"");
        STAssertEquals(context.point.x, (float)2, @"");
        STAssertEquals(context.point.y, (float)3, @"");
        STAssertEquals(context.selector, selector, @"");
        STAssertEquals(context.charPtr, str, @"");
        STAssertEquals(context.intPtr, &integer, @"");
        STAssertEquals(context.nice, YES, @"");
        STAssertEquals(context.propertyWithCustomGetter, 5, @"");
        STAssertEquals(context.getPropertyWithCustomGetter, 5, @"");
        
        // Test propagation with KVC
        STAssertEqualObjects([context valueForKey:@"age"], @1, @"");
        STAssertEqualObjects([context valueForKey:@"ageNumber"], @2, @"");
        STAssertEqualObjects([context valueForKey:@"nice"], @YES, @"");
        STAssertEqualObjects([context valueForKey:@"isNice"], @YES, @"");
        STAssertEqualObjects([context valueForKey:@"propertyWithCustomGetter"], @5, @"");
        STAssertEqualObjects([context valueForKey:@"getPropertyWithCustomGetter"], @5, @"");
        
        // Test modification
        context.age = 2;
        STAssertEquals(context.age, (NSInteger)2, @"");
        STAssertEquals(rootContext.age, (NSInteger)1, @"");
    }
    {
        context = [context contextByAddingTagDelegate:(id<GRMustacheTagDelegate>)@{}];
        
        // Test propagation with getters
        STAssertEquals(context.currentInteger, (NSInteger)42, @"");
        STAssertEquals(context.age, (NSInteger)2, @"");
        STAssertEqualObjects(context.ageNumber, @2, @"");
        STAssertEquals(context.point.x, (float)2, @"");
        STAssertEquals(context.point.y, (float)3, @"");
        STAssertEquals(context.selector, selector, @"");
        STAssertEquals(context.charPtr, str, @"");
        STAssertEquals(context.intPtr, &integer, @"");
        
        // Test propagation with KVC
        STAssertEqualObjects([context valueForKey:@"age"], @2, @"");
        STAssertEqualObjects([context valueForKey:@"ageNumber"], @2, @"");
        
        // Test modification
        context.age = 3;
        STAssertEquals(context.age, (NSInteger)3, @"");
        STAssertEquals(rootContext.age, (NSInteger)1, @"");
    }
    {
        context = [context contextByAddingObject:@{}];
        
        // Test propagation with getters
        STAssertEquals(context.currentInteger, (NSInteger)42, @"");
        STAssertEquals(context.age, (NSInteger)3, @"");
        STAssertEqualObjects(context.ageNumber, @2, @"");
        STAssertEquals(context.point.x, (float)2, @"");
        STAssertEquals(context.point.y, (float)3, @"");
        STAssertEquals(context.selector, selector, @"");
        STAssertEquals(context.charPtr, str, @"");
        STAssertEquals(context.intPtr, &integer, @"");
        
        // Test propagation with KVC
        STAssertEqualObjects([context valueForKey:@"age"], @3, @"");
        STAssertEqualObjects([context valueForKey:@"ageNumber"], @2, @"");
        
        // Test modification
        context.age = 4;
        STAssertEquals(context.age, (NSInteger)4, @"");
        STAssertEquals(rootContext.age, (NSInteger)1, @"");
    }
    {
        context = [context contextByAddingObject:@{ @"age": @5, @"ageNumber": @4}];
        
        // Test propagation with getters
        STAssertEquals(context.age, (NSInteger)5, @"");
        STAssertEqualObjects(context.ageNumber, @4, @"");
        
        // Test propagation with KVC
        STAssertEqualObjects([context valueForKey:@"age"], @5, @"");
        STAssertEqualObjects([context valueForKey:@"ageNumber"], @4, @"");
        
        // Test modification
        context.age = 6;
        STAssertEquals(context.age, (NSInteger)5, @"");     // 6 is overriden by the context object
        STAssertEquals(rootContext.age, (NSInteger)1, @"");
    }
    {
        context = [context contextByAddingObject:@{}];
        
        // Test propagation with getters
        STAssertEquals(context.age, (NSInteger)5, @"");
        STAssertEqualObjects(context.ageNumber, @4, @"");
        
        // Test propagation with KVC
        STAssertEqualObjects([context valueForKey:@"age"], @5, @"");
        STAssertEqualObjects([context valueForKey:@"ageNumber"], @4, @"");
        
        // Test modification
        context.age = 7;
        STAssertEquals(context.age, (NSInteger)7, @"");
        STAssertEquals(rootContext.age, (NSInteger)1, @"");
    }
    
    GRMustacheRubyExampleContextSubclass *subContext = [GRMustacheRubyExampleContextSubclass context];
    subContext.value = 100;
    subContext.name = @"Chuck";
    subContext.title = @"Mr";
    STAssertEquals(subContext.value, 100.0f, @"");
    STAssertEqualObjects(subContext.name, @"Chuck", @"");
    STAssertEqualObjects(subContext.title, @"Mr", @"");
    STAssertEqualObjects([subContext valueForKey:@"value"], @100.0f, @"");
    STAssertEqualObjects([subContext valueForKey:@"name"], @"Chuck", @"");
    STAssertEqualObjects([subContext valueForKey:@"title"], @"Mr", @"");
    
    subContext = [subContext contextByAddingObject:@{@"name":@"Bruce"}];
    STAssertEquals(subContext.value, 100.0f, @"");
    STAssertEqualObjects(subContext.name, @"Bruce", @"");
    STAssertEqualObjects(subContext.title, @"Mr", @"");
    STAssertEqualObjects([subContext valueForKey:@"value"], @100.0f, @"");
    STAssertEqualObjects([subContext valueForKey:@"name"], @"Bruce", @"");
    STAssertEqualObjects([subContext valueForKey:@"title"], @"Mr", @"");
}

- (void)testContextExtension
{
    GRDocumentMustacheContext *context1 = [GRDocumentMustacheContext context];
    context1.age = 1;
    
    GRDocumentMustacheContext *context2 = [GRDocumentMustacheContext context];
    context2.point = (struct GRPoint){ 2, 3 };
    
    GRDocumentMustacheContext *context3 = [GRDocumentMustacheContext context];
    context3.string = @"foo";
    
    GRDocumentMustacheContext *context = [[context1 contextByAddingObject:context2] contextByAddingObject:context3];
    STAssertEquals(context.age, (NSInteger)1, @"");
    STAssertEquals(context.point.x, 2.0f, @"");
    STAssertEqualObjects(context.string, @"foo", @"");
}

- (void)testGRMustacheContextSubclassWithInitializer
{
    {
        GRMustacheContextSubclassWithInitializer *context = [[GRMustacheContextSubclassWithInitializer alloc] init];
        STAssertEqualObjects(context.name, @"defaultName", @"");
    }
    {
        GRMustacheContextSubclassWithInitializer *context = [GRMustacheContextSubclassWithInitializer context];
        STAssertEqualObjects(context.name, @"defaultName", @"");
    }
    {
        GRMustacheContextSubclassWithInitializer *context = [GRMustacheContextSubclassWithInitializer contextWithObject:@{@"name":@"Arthur"}];
        STAssertEqualObjects(context.name, @"Arthur", @""); // context object overrides custom property
    }
    {
        GRMustacheContextSubclassWithInitializer *context = [GRMustacheContextSubclassWithInitializer context];
        context = [context contextByAddingObject:@{@"name":@"Arthur"}];
        STAssertEqualObjects(context.name, @"Arthur", @"");
    }
}

- (void)testValueForKey
{
    // Test that GRMustache does not fuck with valueForKey: semantics, by
    // checking that the value returned by a nonmanaged properties is identical
    // to valueForKey:
    
    GRDocumentMustacheContext *context = [[GRDocumentMustacheContext alloc] init];
    {
        NSString *rendering = [GRMustacheTemplate renderObject:context fromString:@"{{name}}" error:NULL];
        STAssertEqualObjects(rendering, @"defaultName", @"");
        
        // nonmanaged property accessor and valueForKey: are bound
        STAssertEqualObjects(context.name, @"defaultName", @"");
        STAssertEqualObjects(context.name, [context valueForKey:@"name"], @"");
    }
    {
        context = [context contextByAddingObject:@{@"name":@"foo"}];
        
        // Context stack overrides nonmanaged properties, just as the Ruby Mustache does.
        NSString *rendering = [GRMustacheTemplate renderObject:context fromString:@"{{name}}" error:NULL];
        STAssertEqualObjects(rendering, @"foo", @"");
        
        // nonmanaged property accessor and valueForKey: are bound
        STAssertEqualObjects(context.name, @"defaultName", @"");
        STAssertEqualObjects(context.name, [context valueForKey:@"name"], @"");
    }
    {
        // Unknown key throws
        STAssertThrows([context valueForKey:@"unknown"], @"");
    }
    {
        // Unknown key looking like a setter throws
        STAssertThrows([context valueForKey:@"setAge:"], @"");
    }
}

- (void)testValueForMustacheKey
{
    GRDocumentMustacheContext *context = [[GRDocumentMustacheContext alloc] init];
    {
        STAssertEqualObjects(context.name, @"defaultName", @"");
        
        // rendering and valueForMustacheKey: are bound
        NSString *rendering = [GRMustacheTemplate renderObject:context fromString:@"{{name}}" error:NULL];
        STAssertEqualObjects(rendering, @"defaultName", @"");
        STAssertEqualObjects(rendering, [context valueForMustacheKey:@"name"], @"");
    }
    {
        context = [context contextByAddingObject:@{@"name":@"foo"}];
        
        STAssertEqualObjects(context.name, @"defaultName", @"");
        
        // rendering and valueForMustacheKey: are bound
        NSString *rendering = [GRMustacheTemplate renderObject:context fromString:@"{{name}}" error:NULL];
        STAssertEqualObjects(rendering, @"foo", @"");
        STAssertEqualObjects(rendering, [context valueForMustacheKey:@"name"], @"");
    }
    {
        // Unknown key returs nil
        STAssertNil([context valueForMustacheKey:@"unknown"], @"");
    }
}

- (void)testContextWithObject
{
    {
        GRDocumentMustacheContext *context = [[GRDocumentMustacheContext alloc] init];
        STAssertEquals([GRMustacheContext contextWithObject:context], context, @"");
    }
    {
        GRMustacheContext *context = [[GRMustacheContext alloc] init];
        STAssertThrowsSpecificNamed([GRDocumentMustacheContext contextWithObject:context], NSException, NSInvalidArgumentException, @"");
    }
}

@end
