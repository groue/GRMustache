[up](../../../../tree/master/Guides/sample_code), [next](../forking.md)

Collection Indexes
==================

In a genuine Mustache way
-------------------------

Mustache is a simple template language. Its [specification](https://github.com/mustache/spec) does not provide any built-in access to collection indexes. It does not provide any way to render a section at the beginning of a loop, and another section at the end. It does not help you render different sections for odd and even indexes.

If your goal is to design your templates so that they are compatible with [other Mustache implementations](https://github.com/defunkt/mustache/wiki/Other-Mustache-implementations), the best way to render indices and provide custom looping logic is to have each of your data objects provide with its index, regardless of how tedious it may be for you to prepare the rendered data.

For instance, instead of `[ { name:'Alice' }, { name:'Bob' } ]`, you would provide: `[ { name:'Alice', position:1, isFirst:true, isOdd:true }, { name:'Bob', position:2, isFirst:false, isOdd:false } ]`.


GRMustache solution
-------------------

**[Download the code](../../../../tree/master/Guides/sample_code/indexes)**

You can have Mustache templates render positional keys like `position` or `isFirst` for you, and avoid preparing your data.

**However, it may be tedious or impossible for other Mustache implementations to produce the same rendering.**

So check again the genuine Mustache way, above. Or keep on reading, now that you are warned.

### The rendering

Below we'll implement the special keys `position`, `isFirst`, and `isOdd`:

`Document.mustache`:

    <ul>
    {{# withPosition(people) }}
      <li class="{{# isOdd }}odd{{/ isOdd }} {{# isFirst }}first{{/ isFirst }}">
        {{ position }}:{{ name }}
      </li>
    {{/ withPosition(people) }}
    </ul>

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


### PositionFilter implementation

You may just skip the rest of this document, and [download the `PositionFilter` class](../../../../tree/master/Guides/sample_code/indexes). It should be trivial to adapt, should you need the `isLast` property, for example.

Let's see how it is implemented.

Due to the parenthesis in the `withPosition(people)` expression, we know that it is a [filter](../filters.md), an object that conforms to the `GRMustacheFilter` protocol:

```objc
/**
 * A filter that renders its array argument with the extra following keys
 * defined for each item:
 *
 * - position: returns the 1-based index of the item
 * - isOdd: returns YES if the position of the item is odd
 * - isFirst: returns YES if the item is at position 1
 */
@interface PositionFilter : NSObject<GRMustacheFilter>
@end
```

The protocol requires the `transformedValue:` method, that returns the result of the filter.

Since we need a custom rendering of the array, the result of the filter will conform to the `GRMustacheRendering` protocol (see the [Rendering Objects Guide](../rendering_objects.md)).

Rendering objects take full responsability of their rendering. Our will render the section tag as many times as the array has items, extending the [context stack](../runtime.md#the-context-stack) with both a dictionary containing the special keys, and the array items that will provide the `name` key.

```objc
@implementation PositionFilter

/**
 * The transformedValue: method is required by the GRMustacheFilter protocol.
 * 
 * Don't provide any type checking, and assume the filter argument is an array:
 */

- (id)transformedValue:(NSArray *)array
{
    // We want to provide custom rendering of the array.
    //
    // So let's return an object that does custom rendering.
    
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

See the [GRMustacheTag Class Reference](http://groue.github.io/GRMustache/Reference/Classes/GRMustacheTag.html) and [GRMustacheContext Class Reference](http://groue.github.io/GRMustache/Reference/Classes/GRMustacheContext.html) for a full documentation of GRMustacheTag and GRMustacheContext, and details on the `contextByAddingObject:` and `renderContentWithContext:HTMLSafe:error:` methods.

Writing [filters](../filters.md) that return [rendering objects](../rendering_objects.md) lead to code that is pretty close to the [Handlebars.js block helpers](http://handlebarsjs.com/block_helpers.html). You may enjoy comparing the code above to the [`each_with_index` Handlebars helper](https://gist.github.com/1048968).

**[Download the code](../../../../tree/master/Guides/sample_code/indexes)**

[up](../../../../tree/master/Guides/sample_code), [next](../forking.md)
