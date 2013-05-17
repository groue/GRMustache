// The MIT License
//
// Copyright (c) 2013 Gwendal Roué
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

#define GRMUSTACHE_VERSION_MAX_ALLOWED GRMUSTACHE_VERSION_6_5
#import "GRMustachePublicAPITest.h"

@interface GRDocumentMustacheContext : GRMustacheContext {
    NSInteger _age;
    NSNumber *_ageNumber;
}
@property (nonatomic) NSInteger age;
@property (nonatomic, retain) NSNumber *ageNumber;
@end

@implementation GRDocumentMustacheContext
@synthesize age=_age;
@synthesize ageNumber=_ageNumber;

- (void)dealloc
{
    [_ageNumber release];
    [super dealloc];
}

- (NSInteger)succ
{
    return [[self valueForKey:@"number"] integerValue] + 1;
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

@interface GRMustacheRubyExampleContext : GRMustacheContext {
    NSString *_name;
    float _value;
    BOOL _in_ca;
}
@property (nonatomic, retain) NSString *name;
@property (nonatomic) float value;
@property (nonatomic) BOOL in_ca;
@end

@implementation GRMustacheRubyExampleContext
@synthesize name=_name;
@synthesize value=_value;
@synthesize in_ca=_in_ca;

- (void)dealloc
{
    [_name release];
    [super dealloc];
}

- (float)taxed_value
{
    return self.value - self.value * 0.4;
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

- (void)testMustacheContextValueForKeyUsesFullContextStack
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

- (void)testMustacheContextValueForKeyIsNotTriggeredByCompoundKeys
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

- (void)testMustacheContextValueForKeyIsNotTriggeredByDotPrefixedKeys
{
    // Ruby version does not support `.name` expressions
    
    NSString *templateString = @"{{#a}}{{.succ}}{{/}},{{#b}}{{.succ}}{{/}}";
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:templateString error:NULL];
    template.baseContext = [GRDocumentMustacheContext context];
    
    id data = @{ @"number": @1, @"a" : @{ @"number": @2 }, @"b" : @{ } };
    NSString *rendering = [template renderObject:data error:NULL];
    STAssertEqualObjects(rendering, @",", @"");
}

- (void)testMustacheContextValueForKeyIsOnlyUsedForMissingKeys
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
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:templateString error:NULL];
    
    // Custom context
    GRMustacheRubyExampleContext *context = [GRMustacheRubyExampleContext context];
    context.name = @"Chris";
    context.value = 10000;
    context.in_ca = YES;
    template.baseContext = context;
    
    // Render
    NSString *rendering = [template renderAndReturnError:NULL];
    STAssertEqualObjects(rendering, @"Hello Chris\nYou have just won $10000!\nWell, $6000, after taxes.", @"");
}

- (void)testCustomObjectKeys
{
    GRDocumentMustacheContext *context = [GRDocumentMustacheContext context];
    context.age = 1;                // test scalar property
    context.ageNumber = @2;         // test object property
    
    {
        context = [context contextByAddingProtectedObject:@{}];
        
        // Test propagation with getters
        STAssertEquals(context.age, (NSInteger)1, @"");
        STAssertEqualObjects(context.ageNumber, @2, @"");
        
        // Test propagation with KVC
        STAssertEqualObjects([context valueForKey:@"age"], @1, @"");
        STAssertEqualObjects([context valueForKey:@"ageNumber"], @2, @"");
    }
    {
        context = [context contextByAddingTagDelegate:(id<GRMustacheTagDelegate>)@{}];
        
        // Test propagation with getters
        STAssertEquals(context.age, (NSInteger)1, @"");
        STAssertEqualObjects(context.ageNumber, @2, @"");
        
        // Test propagation with KVC
        STAssertEqualObjects([context valueForKey:@"age"], @1, @"");
        STAssertEqualObjects([context valueForKey:@"ageNumber"], @2, @"");
    }
    {
        context = [context contextByAddingObject:@{}];
        
        // Test propagation with getters
        STAssertEquals(context.age, (NSInteger)1, @"");
        STAssertEqualObjects(context.ageNumber, @2, @"");
        
        // Test propagation with KVC
        STAssertEqualObjects([context valueForKey:@"age"], @1, @"");
        STAssertEqualObjects([context valueForKey:@"ageNumber"], @2, @"");
    }
    {
        context = [context contextByAddingObject:@{ @"age": @3, @"ageNumber": @4}];
        
        // Test propagation with getters
        STAssertEquals(context.age, (NSInteger)3, @"");
        STAssertEqualObjects(context.ageNumber, @4, @"");
        
        // Test propagation with KVC
        STAssertEqualObjects([context valueForKey:@"age"], @3, @"");
        STAssertEqualObjects([context valueForKey:@"ageNumber"], @4, @"");
    }
}

@end
