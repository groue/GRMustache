[up](../../../../tree/master/Guides/sample_code), [next](../forking.md)

Indexes
=======

In a genuine Mustache way
-------------------------

Mustache is a simple template language. Its [specification](https://github.com/mustache/spec) does not provide any built-in access to loop indexes. It does not provide any way to render a section at the beginning of the loop, and another section at the end. It does not help you render different sections for odd and even indexes.

If your goal is to design your templates so that they are compatible with [other Mustache implementations](https://github.com/defunkt/mustache/wiki/Other-Mustache-implementations), the best way to render indices and provide custom looping logic is to have each of your data objects provide with its index, regardless of how tedious it may be for you to prepare the rendered data.

For instance, instead of `[ { name:'Alice' }, { name:'Bob' } ]`, you would provide: `[ { name:'Alice', position:1, isFirst:true, isOdd:true }, { name:'Bob', position:2, isFirst:false, isOdd:false } ]`.


GRMustache solution: filters
----------------------------

**[Download the code](../../../../tree/master/Guides/sample_code/indexes)**

The [GRMustacheFilter](../filters.md) protocol can help you extend the mustache language, and avoid preparing your data.

**However, it may be tedious or impossible for other Mustache implementations to produce the same rendering.**

So check again the genuine Mustache way, above. Or keep on reading, now that you are warned.

### The template

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

### The rendering

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

### The filter implementation

Now it's time to implement this nifty PositionFilter class.

We have already seen above its declaration: it's simply a class that conforms to the GRMustacheFilter protocol:

```objc
@interface PositionFilter : NSObject<GRMustacheFilter>
@end
```

As such, it must implement the `transformedValue:` method:

```objc
@implementation PositionFilter
- (id)transformedValue:(id)object
{
    return ...;
}
```

Provided with an array, it returns another array filled with objects "that forward all keys to the original array items, but the following: position, isOdd, isFirst". We have to implement those objects as well. In order to do their job, they have to now both the original item in the original array, and its index. Here is the declaration of those objects:

```objc
/**
 * PositionFilterItem's responsability is, given an array and an index, to
 * forward to the original item in the array all keys but:
 *
 * - position: returns the 1-based index of the item
 * - isOdd: returns YES if the position of the item is odd
 * - isFirst: returns YES if the item is at position 1
 *
 * All other keys are forwared to the original item.
 */
@interface PositionFilterItem : NSObject
@property (nonatomic, readonly) NSUInteger position;
@property (nonatomic, readonly) BOOL isFirst;
@property (nonatomic, readonly) BOOL isOdd;
- (id)initWithObjectAtIndex:(NSUInteger)index inArray:(NSArray *)array;
@end
```

Now we can implement the PositionFilter class itself:

```objc
@implementation PositionFilter

/**
 * GRMustacheFilter protocol required method
 */
- (id)transformedValue:(id)object
{
    /**
     * Let's first validate the input: we can only filter arrays.
     */
    
    NSAssert([object isKindOfClass:[NSArray class]], @"Not an NSArray");
    NSArray *array = (NSArray *)object;
    
    
    /**
     * Let's return a new array made of PositionFilterItem instances.
     * They will provide the `position`, `isOdd` and `isFirst` keys while
     * letting original array items provide the other keys.
     */
    
    NSMutableArray *replacementArray = [NSMutableArray arrayWithCapacity:array.count];
    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        PositionFilterItem *item = [[PositionFilterItem alloc] initWithObjectAtIndex:idx inArray:array];
        [replacementArray addObject:item];
    }];
    return replacementArray;
}

@end
```

And finally, write the PositionFilterItem implementation:

```objc
@implementation PositionFilterItem {
    /**
     * The original 0-based index and the array of original items are stored in
     * ivars without any exposed property: we do not want GRMustache to render
     * {{ index }} or {{ array }}
     */
    NSUInteger _index;
    NSArray *_array;
}

- (id)initWithObjectAtIndex:(NSUInteger)index inArray:(NSArray *)array
{
    self = [super init];
    if (self) {
        _index = index;
        _array = array;
    }
    return self;
}

/**
 * The implementation of `description` is required so that whenever GRMustache
 * wants to render the original item itself (with a `{{ . }}` tag, for
 * instance).
 */
- (NSString *)description
{
    id originalObject = [_array objectAtIndex:_index];
    return [originalObject description];
}

/**
 * Support for `{{position}}`: return a 1-based index.
 */
- (NSUInteger)position
{
    return _index + 1;
}

/**
 * Support for `{{#isFirst}}...{{/isFirst}}`: return YES if element is the first
 */
- (BOOL)isFirst
{
    return _index == 0;
}

/**
 * Support for `{{#isOdd}}...{{/isOdd}}`: return YES if element's position is
 * odd.
 */
- (BOOL)isOdd
{
    return (_index % 2) == 0;
}

/**
 * Support for other keys: forward to original array element
 */
- (id)valueForUndefinedKey:(NSString *)key
{
    id originalObject = [_array objectAtIndex:_index];
    return [originalObject valueForKey:key];
}

@end
```

**[Download the code](../../../../tree/master/Guides/sample_code/indexes)**

[up](../../../../tree/master/Guides/sample_code), [next](../forking.md)