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

#import "GRMustache.h"
#import "Document.h"
#import "Person.h"
#import "PositionFilter.h"

@implementation Document

- (NSString *)render
{
    /**
     * Our template want to render the `people` array with support for various
     * positional information on top of regular keys fetched from each person
     * of the array:
     *
     * - position: the 1-based index of the person
     * - isOdd: YES if the position of the person is odd
     * - isFirst: YES if the person is the first of the people array.
     *
     * This is typically a job for filters: we'll define the `withPosition`
     * filters to be an instance of the PositionFilter class. That class has
     * been implemented so that it provides us with the extra keys for free.
     *
     * For now, we just declare our template.
     */
    NSString *templateString = @"<ul>\n"
                               @"{{# withPosition(people) }}"
                               @"  <li class=\"{{# isOdd }}odd{{/ isOdd }} {{# isFirst }}first{{/ isFirst }}\">\n"
                               @"    {{ position }}:{{ name }}\n"
                               @"  </li>\n"
                               @"{{/ withPosition(people) }}"
                               @"</ul>";
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:templateString error:NULL];
    
    
    /**
     * Now we have to define this filter. The PositionFilter class is already
     * there, ready to be instanciated:
     */
    
    PositionFilter *positionFilter = [[PositionFilter alloc] init];
    
    
    /**
     * GRMustache does not load filters from the rendered data, but from a
     * specific filters container.
     *
     * We'll use a NSDictionary for attaching positionFilter to the
     * "withPosition" key, but you can use any other KVC-compliant container.
     */
    
    NSDictionary *filters = [NSDictionary dictionaryWithObject:positionFilter forKey:@"withPosition"];
    
    
    /**
     * Now we need an array of people that will be sequentially rendered by the
     * `{{# withPosition(people) }}...{{/ withPosition(people) }}` section.
     * 
     * We'll use a NSDictionary for storing the array, but as always you can use
     * any other KVC-compliant container.
     */
    
    Person *alice = [Person personWithName:@"Alice"];
    Person *bob = [Person personWithName:@"Bob"];
    Person *craig = [Person personWithName:@"Craig"];
    NSArray *people = [NSArray arrayWithObjects: alice, bob, craig, nil];
    NSDictionary *data = [NSDictionary dictionaryWithObject:people forKey:@"people"];
    
    
    /**
     * Render.
     */
    
    return [template renderObject:data withFilters:filters];
}

@end
