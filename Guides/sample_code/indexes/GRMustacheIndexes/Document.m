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

#import "Document.h"
#import "Person.h"
#import "ArrayElementProxy.h"
#import "GRMustache.h"

@interface Document() <GRMustacheTemplateDelegate>

@end

@implementation Document

- (NSString *)render
{
    /**
     * First, let's attach an array of people to the `people` key, so that they
     * are sequentially rendered by the `{{#people}}...{{/people}}` sections.
     * 
     * We'll use a NSDictionary for storing the data, but you can use any other
     * KVC-compliant container.
     */
    
    Person *alice = [Person personWithName:@"Alice"];
    Person *bob = [Person personWithName:@"Bob"];
    Person *craig = [Person personWithName:@"Craig"];
    NSArray *people = [NSArray arrayWithObjects: alice, bob, craig, nil];
    NSDictionary *data = [NSDictionary dictionaryWithObject:people forKey:@"people"];
    
    /**
     Render. The rendering of indices will happen in the
     GRMustacheTemplateDelegate methods, hereafter.
     */
    
    NSString *templateString = @"<ul>\n"
                               @"{{#people}}"
                               @"<li class=\"{{#even}}even{{/even}} {{#first}}first{{/first}}\">\n"
                               @"{{index}}:{{name}}\n"
                               @"</li>\n"
                               @"{{/people}}"
                               @"</ul>";
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:templateString error:NULL];
    template.delegate = self;
    return [template renderObject:data];
}

#pragma mark GRMustacheTemplateDelegate

/**
 * This method is called when the template is about to render a tag.
 */
- (void)template:(GRMustacheTemplate *)template willInterpretReturnValueOfInvocation:(GRMustacheInvocation *)invocation as:(GRMustacheInterpretation)interpretation
{
    /**
     * The invocation object tells us which object is about to be rendered.
     */
    
    if ([invocation.returnValue isKindOfClass:[NSArray class]]) {
        
        /**
         * If it is an NSArray, create a new array containing proxies.
         */
        
        NSArray *array = invocation.returnValue;
        NSMutableArray *proxiesArray = [NSMutableArray arrayWithCapacity:array.count];
        [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            ArrayElementProxy *proxy = [[ArrayElementProxy alloc] initWithObjectAtIndex:idx inArray:array];
            [proxiesArray addObject:proxy];
        }];
        
        /**
         * Now set the invocation's returnValue to the array of proxies: it will
         * be rendered instead.
         */
        
        invocation.returnValue = proxiesArray;
    }
}

@end
