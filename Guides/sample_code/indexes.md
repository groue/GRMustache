[up](../../../../tree/master/Guides/sample_code), [next](../forking.md)

Indexes
=======

Mustache is a simple template language. Its [specification](https://github.com/mustache/spec) does not provide any built-in access to loop indexes. It does not provide any way to render a section at the beginning of the loop, and another section at the end. It does not help you render different sections for odd and even indexes.

If your goal is to design your templates so that they are compatible with [other Mustache implementations](https://github.com/defunkt/mustache/wiki/Other-Mustache-implementations), the best way to render indices and provide custom looping logic is to have each of your data objects provide with its index, regardless of how tedious it may be for you to prepare the rendered data.

For instance, instead of `[ { name:'Alice' }, { name:'Bob' } ]`, you would provide: `[ { name:'Alice', index:0, first:true, last:false, even:false }, { name:'Bob', index:1, first:false, last:true, even:true } ]`.


GRMustache solution: filters
----------------------------

**[Download the code](../../../../tree/master/Guides/sample_code/indexes)**

The [GRMustacheFilter](../filter.md) protocol can help you extend the mustache language, and avoid preparing your data.

Below we'll implement the special keys `position`, `isFirst`, and `isOdd`. We'll render the following template:

    {{% FILTERS}}
    <ul>
    {{# withPosition(people) }}
      <li class="{{#isOdd}}odd{{/isOdd}} {{#isFirst}}first{{/isFirst}}">
        {{ position }}:{{ name }}
      </li>
    {{/ withPosition(people) }}
    </ul>

We expect, on output, the following rendering:

    <ul>
      <li class="odd first">
        1:Alice
      </li>
      <li class=" ">
        2:Bob
      </li>
      <li class="odd ">
        3:Craig
      </li>
    </ul>
    

Our people array will be a plain array filled with plain people who don't know anything but their name. The support for the special positional keys will be entirely done by a filter object.

We can thus focus on the two subjects separately.

Let's first assume that the class PositionFilter is already written. Here is its documentation:

```objc
/**
 * A GRMustache filter that, given an array, returns another array made of
 * objects that forward all keys to the original array items, but the following:
 *
 * - position: returns the 1-based index of the item
 * - isOdd: returns YES if the position of the item is odd
 * - isFirst: returns YES if the item is at position 1
 */
@interface PositionFilter : NSObject<GRMustacheFilter>
@end
```

Well, it looks quite a good fit for our task: if we provide to this filter an array of people, it will return an array of objects that will be able to tell a template their position, and for all other keys, will give the original person's value. 

We have everything we need to render our template:

```objc
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
     * For now, we just declare our template. The initial {{%FILTERS}} pragma
     * tag tells GRMustache to trigger support for filters, which are an
     * extension to the Mustache specification.
     */
    NSString *templateString = @"{{% FILTERS}}"
                               @"<ul>\n"
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
```

Now it's time to implement this nifty filter.




**[Download the code](../../../../tree/master/Guides/sample_code/indexes)**

[up](../../../../tree/master/Guides/sample_code), [next](../forking.md)