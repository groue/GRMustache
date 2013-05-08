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

@interface GRMustacheContextSubclass : GRMustacheContext
@end

@implementation GRMustacheContextSubclass

- (NSNumber *)succ
{
    return [NSNumber numberWithInteger:[(NSNumber *)[self valueForKey:@"number"] integerValue] + 1];
}

- (id)name
{
    return @"defaultName";
}

@end

@interface GRMustacheContextSubclassTest : GRMustachePublicAPITest
@end

@implementation GRMustacheContextSubclassTest

- (void)testMustacheContextSubclassExtendsAvailableKeys
{
    // Behave just as the Ruby version
    //
    //    require "mustache"
    //
    //    class Subclass < Mustache
    //      self.template = "{{succ}}"
    //      def succ
    //        self[:number] + 1
    //      end
    //    end
    //
    //    puts Subclass.render(:number => 1)  # => 2

    NSString *templateString = @"{{succ}}";
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:templateString error:NULL];
    template.baseContext = [GRMustacheContextSubclass context];
    
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
    //    class Subclass < Mustache
    //      self.template = "{{succ}},{{#a}}{{succ}}{{/a}},{{#b}}{{succ}}{{/b}}"
    //      def succ
    //        self[:number] + 1
    //      end
    //    end
    //
    //    puts Subclass.render(:number => 1, :a => { :number => 2 }, :b => {})  # => 2,3,2

    NSString *templateString = @"{{succ}},{{#a}}{{succ}}{{/}},{{#b}}{{succ}}{{/}}";
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:templateString error:NULL];
    template.baseContext = [GRMustacheContextSubclass context];
    
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
    //    class Subclass < Mustache
    //      self.template = "{{a.succ}},{{b.succ}}"
    //      def succ
    //        self[:number] + 1
    //      end
    //    end
    //
    //    puts Subclass.render(:number => 1, :a => { :number => 2 }, :b => {})  # => ,
    
    NSString *templateString = @"{{succ}},{{a.succ}},{{#a}}{{succ}}{{/}},{{b.succ}},{{#b}}{{succ}}{{/}}";
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:templateString error:NULL];
    template.baseContext = [GRMustacheContextSubclass context];
    
    id data = @{ @"number": @1, @"a" : @{ @"number": @2 }, @"b" : @{ } };
    NSString *rendering = [template renderObject:data error:NULL];
    STAssertEqualObjects(rendering, @"2,,3,,2", @"");
}

- (void)testMustacheContextValueForKeyIsNotTriggeredByDotPrefixedKeys
{
    // Ruby version does not support `.name` expressions
    
    NSString *templateString = @"{{#a}}{{.succ}}{{/}},{{#b}}{{.succ}}{{/}}";
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:templateString error:NULL];
    template.baseContext = [GRMustacheContextSubclass context];
    
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
    //    class Subclass < Mustache
    //      self.template = "name:{{name}}"
    //      def name
    //        "defaultName"
    //      end
    //    end
    //    
    //    puts Subclass.render                    # => name:defaultName
    //    puts Subclass.render(:name => 'Arthur') # => name:Arthur
    //    puts Subclass.render(:name => nil)      # => name:

    NSString *templateString = @"name:{{name}}";
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:templateString error:NULL];
    template.baseContext = [GRMustacheContextSubclass context];
    
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
    template.baseContext = [GRMustacheContextSubclass context];
    
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
    template.baseContext = [GRMustacheContextSubclass contextWithObject:[GRMustache standardLibrary]];
    
    // uppercase filter should be defined
    NSString *rendering = [template renderObject:nil error:NULL];
    STAssertEqualObjects(rendering, @"DEFAULTNAME", @"");
}

@end
