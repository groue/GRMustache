[up](../../../../tree/master/Guides/sample_code), [next](localization.md)

Indexes
=======

In a genuine Mustache way
-------------------------

Mustache is a simple template language. Its [specification](https://github.com/mustache/spec) does not provide any built-in access to loop indexes. It does not provide any way to render a section at the beginning of the loop, and another section at the end. It does not help you render different sections for odd and even indexes.

If your goal is to design your templates so that they are compatible with [other Mustache implementations](https://github.com/defunkt/mustache/wiki/Other-Mustache-implementations), the best way to render indices and provide custom looping logic is to have each of your data objects provide with its index, regardless of how tedious it may be for you to prepare the rendered data.

For instance, instead of `[ { name:'Alice' }, { name:'Bob' } ]`, you would provide: `[ { name:'Alice', position:1, isFirst:true, isOdd:true }, { name:'Bob', position:2, isFirst:false, isOdd:false } ]`.


GRMustache solution
-------------------

**[Download the code](../../../../tree/master/Guides/sample_code/indexes)**

You can have Mustache templates render positional keys like `position` or `isFirst` for you, and avoid preparing your data.

**However, it may be tedious or impossible for other Mustache implementations to produce the same rendering.**

So check again the genuine Mustache way, above. Or keep on reading, now that you are warned.

### The template

Below we'll implement the special keys `position`, `isFirst`, and `isOdd`. We'll render the following template:

    <ul>
    {{# withPosition(people) }}
      <li class="{{# isOdd }}odd{{/ isOdd }} {{# isFirst }}first{{/ isFirst }}">
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
    

Our people array will be a plain array filled with plain people who don't know anything but their name. The support for the special positional keys will be brought by the `withPosition` [filter](../filters.md).

### The rendering

Let's first assume that the filter is already implemented, ready to be used. It comes as a `PositionFilter` class that is documented this way:

```objc
/**
 * A GRMustache filter that, given an array, returns another array made of
 * objects that render just as original array items, but for the extra
 * following keys:
 *
 * - position: returns the 1-based index of the item
 * - isOdd: returns YES if the position of the item is odd
 * - isFirst: returns YES if the item is at position 1
 */
@interface PositionFilter : NSObject<GRMustacheFilter>
@end
```

Well, it looks quite a good fit for our task: if we provide this filter with an array of people, it will return an array of objects that will be able to give a template both their positions, and the properties of their people.

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
    
    NSDictionary *filters = @{ @"withPosition": positionFilter };
    
    
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
    NSDictionary *data = @{ @"people": @[alice, bob, craig] };
    
    
    /**
     * Render.
     */
    
    return [template renderObject:data withFilters:filters];
}
```

### The filter implementation

You may just skip the rest of this document, and [download the `PositionFilter` class](../../../../tree/master/Guides/sample_code/indexes). It should be trivial to adapt, should you need the `isLast` property, for example.

Let's now implement this nifty `PositionFilter` class.

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

Provided with an array, it returns another array filled with objects "that render just as original array items, but for the extra following keys: `position`, `isOdd`, `isFirst`."

We have to implement those objects as well. In order to do their job, they have to now both the original item in the original array, and its index. Below is the declaration of those objects, madeof an initialization method that provides all the required information. They are a subclass of the `GRMustacheProxy` class, we'll explain why soon.

```objc
@interface PositionFilterItem : GRMustacheProxy
- (id)initWithObjectAtIndex:(NSUInteger)index fromArray:(NSArray *)array;
@end
```

Based on this declaration, we can implement the `PositionFilter` class itself:

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
    [array enumerateObjectsUsingBlock:^(id object, NSUInteger index, BOOL *stop) {
        PositionFilterItem *item = [[PositionFilterItem alloc] initWithObjectAtIndex:index fromArray:array];
        [replacementArray addObject:item];
    }];
    return replacementArray;
}

@end
```

Our filter is ready. We now just need to implement the `PositionFilterItem` class itself.

It must "*render just as original array items, but for the extra following keys: `position`, `isOdd`, `isFirst`.*"

This is the job of the [GRMustacheProxy](../proxies) class. `GRMustacheProxy` is a convenience class that let you build objects that behaves exactly the same as another object, named its "delegate". It is simply a matter of subclassing it in
order to add support for our extra keys, and this is why `PositionFilterItem` is a subclass of `GRMustacheProxy`.

Here we go:

```objc
/**
 * Let's declare a private property that stored the index: `index_`, and allows
 * us to implement the `position`, `isFirst` and `isOdd` keys.
 *
 * The underscore suffix avoids the property to pollute Mustache context:
 * your templates may contain a {{position}} tag, but it's unlikely they embed
 * any {{index_}} tags.
 */
@interface PositionFilterItem()
@property (nonatomic) NSUInteger index_;
@end
```

The initializer is straightforward:

```objc
@implementation PositionFilterItem

/**
 * PositionFilterItem is a subclass of GRMustacheProxy, so that it behaves
 * just as the array item. The array item is the "delegate" of the proxy.
 *
 * Let's also store the index, so that we can compute values for `position`,
 * `isFirst`, and `isOdd`.
 */
- (id)initWithObjectAtIndex:(NSUInteger)index fromArray:(NSArray *)array
{
    // Initialize as a GRMustacheProxy with delegate:
    self = [super initWithDelegate:[array objectAtIndex:index]];
    
    // Store the index:
    if (self) {
        self.index_ = index;
    }
    return self;
}
```

So are the three positional properties, `position`, `isOdd`, and `isFirst`:

```objc
/**
 * Support for {{position}}: returns the 1-based index of the object.
 */
- (NSUInteger)position
{
    return self.index_ + 1;
}

/**
 * Support for `{{#isFirst}}...{{/isFirst}}`: return YES if element is the
 * first.
 */
- (BOOL)isFirst
{
    return self.index_ == 0;
}

/**
 * Support for `{{#isOdd}}...{{/isOdd}}`: return YES if element's position is
 * odd.
 */
- (BOOL)isOdd
{
    return (self.index_ % 2) == 0;
}

@end
```

**[Download the code](../../../../tree/master/Guides/sample_code/indexes)**

[up](../../../../tree/master/Guides/sample_code), [next](localization.md)
