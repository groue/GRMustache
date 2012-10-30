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

`Document.mustache`:

    <ul>
    {{# withPosition(people) }}
      <li class="{{# isOdd }}odd{{/ isOdd }} {{# isFirst }}first{{/ isFirst }}">
        {{ position }}:{{ name }}
      </li>
    {{/ withPosition(people) }}
    </ul>

Final rendering:

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
 * A GRMustache filter that render its array argument with the extra following
 * keys defined for each item:
 *
 * - position: returns the 1-based index of the item
 * - isOdd: returns YES if the position of the item is odd
 * - isFirst: returns YES if the item is at position 1
 */
@interface PositionFilter : NSObject<GRMustacheFilter>
@end
```

Well, it looks quite a good fit for our task. We have everything we need to render our template:

`Render.m`:

```objc
id data = @{
    @"people": @[
        @{ @"name": @"Alice" },
        @{ @"name": @"Bob" },
        @{ @"name": @"Craig" },
    ],
    @"withPosition": [PositionFilter new]
};

NSString *rendering = [GRMustacheTemplate renderObject:data
                                          fromResource:@"Document"
                                                bundle:nil
                                                 error:NULL];
```

### The filter implementation

You may just skip the rest of this document, and [download the `PositionFilter` class](../../../../tree/master/Guides/sample_code/indexes). It should be trivial to adapt, should you need the `isLast` property, for example.

Let's now implement this nifty `PositionFilter` class.

We have already seen above its declaration: it's simply a class that conforms to the GRMustacheFilter protocol:

```objc
/**
 * A GRMustache filter that render its array argument with the extra following
 * keys defined for each item:
 *
 * - position: returns the 1-based index of the item
 * - isOdd: returns YES if the position of the item is odd
 * - isFirst: returns YES if the item is at position 1
 */
@interface PositionFilter : NSObject<GRMustacheFilter>
@end
```

As such, it must implement the `transformedValue:` method, that returns the result of the filter. That result will perform a custom rendering of its array argument.

You provide custom rendering with objects that conform to the `GRMustacheRendering` protocol (see the [Rendering Objects Guide](../rendering_objects.md)). Our custom rendering object will render the section tag as many times as it has items, extending the [context stack](../runtime.md) with both a dictionary containing the special keys, and the array items that will provide the `name` key.

Actually, writing [filters](../filters.md) that return [rendering objects](../rendering_objects.md) lead to code that is pretty close to the [Handlebars.js block helpers](http://handlebarsjs.com/block_helpers.html). You may enjoy comparing the code below to the [`each_with_index` Handlebars helper](https://gist.github.com/1048968).

```objc
@implementation PositionFilter

/**
 * The transformedValue: method is required by the GRMustacheFilter protocol.
 * 
 * Don't provide any type checking, and assume the filter argument is an array:
 */

- (id)transformedValue:(NSArray *)array
{
    /**
     * We want to provide custom rendering of the array.
     *
     * So let's provide an object that does custom rendering.
     */
    
    return [GRMustache renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError *__autoreleasing *error)
    {
        NSMutableString *buffer = [NSMutableString string];
        
        [array enumerateObjectsUsingBlock:^(id item, NSUInteger index, BOOL *stop) {
            
            // Have our "specials" keys enter the context stack,
            // so that the `{{ position }}` tags etc. can render:
            
            id specials = @{
                @"position": @(index + 1),
                @"isFirst" : @(index == 0),
                @"isOdd" : @(index % 2 == 0),
            };
            GRMustacheContext *itemContext = [context contextByAddingObject:specials];
            
            
            // Have the item itself enter the context stack,
            // so that the `{{ name }}` tag can render:
            
            itemContext = [itemContext contextByAddingObject:item];
            
            
            // Render the item:
            
            NSString *itemRendering = [tag renderContentWithContext:itemContext HTMLSafe:HTMLSafe error:error];
            [buffer appendString:itemRendering];
        }];
        
        return buffer;
    }];
}

@end
```


**[Download the code](../../../../tree/master/Guides/sample_code/indexes)**

[up](../../../../tree/master/Guides/sample_code), [next](localization.md)
