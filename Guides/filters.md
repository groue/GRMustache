[up](../../../../GRMustache#documentation), [next](rendering_objects.md)

Filters
=======

Overview
--------

You apply a filter just like calling a function, with parentheses:

- `My name is {{ uppercase(name) }}` would render `My name is ARTHUR`, provided with "Arthur" as a name.

- Filters can chain: `{{ uppercase(reversed(name)) }}` would render `RUHTRA`.

- Filters can apply to compound key paths: `{{ uppercase(person.name) }}`.

- You can extract values from filtered values: `{{ last(people).name }}`.

- You can filter sections as well : `{{^ isEmpty(people) }}...{{/ isEmpty(people) }}` renders if the people collection is not empty.
    
    For brevity's sake, closing section tags can be empty: `{{^ isEmpty(people) }}...{{/}}` is valid.

- Filters can take several arguments: `{{ localize(date, format) }}`.

- Filters can return filters: `{{ f(x)(y) }}`.


Defining your own filters
-------------------------

You can implement your own filters with objects that conform to the `GRMustacheFilter` protocol.

This protocol defines a single required method:

```objc
@protocol GRMustacheFilter <NSObject>
@required
- (id)transformedValue:(id)object;
@end
```

You can for instance declare a filter that outputs numbers as percentages:

```objc
@interface PercentFilter : NSObject<GRMustacheFilter>
@end

@implementation PercentFilter
- (id)transformedValue:(id)object
{
    NSNumberFormatter *percentNumberFormatter = [[NSNumberFormatter alloc] init];
    percentNumberFormatter.numberStyle = kCFNumberFormatterPercentStyle;
    return [numberFormatter stringFromNumber:object];
}
@end

id percentFilters = [[PercentFilter alloc] init];
```

The protocol comes with a `GRMustacheFilter` class, which provides a convenient method for building a filter without implementing a full class that conforms to the protocol:

```objc
id data = @{
    @"gain": @0.5,
    @"percent": [GRMustacheFilter filterWithBlock:^id(id object) {
        NSNumberFormatter *numberFormatter = [NSNumberFormatter new];
        numberFormatter.numberStyle = kCFNumberFormatterPercentStyle;
        return [numberFormatter stringFromNumber:object];
    }],
};

// Enjoy your 50% productivity bump!
NSString *templateString = @"Enjoy your {{ percent(gain) }} productivity bump!";
NSString *rendering = [GRMustacheTemplate renderObject:data
                                            fromString:templateString
                                                 error:NULL];
```

Variadic filters
----------------

A *variadic filter* is a filter that accepts a variable number of arguments.

You create a variadic filter with the `variadicFilterWithBlock:` method:

`Document.mustache`:

    {{#object1}}
        {{ dateFormat(date, format) }}
    {{/object1}}
    {{#object2}}
        {{ dateFormat(date, format) }}
    {{/object2}}

`Render.m`:

```objc
id data = @{
    @"object1": @{
        @"format": @"yyyy-MM-dd 'at' HH:mm",
        @"date": [NSDate date]
    },
    @"object2": @{
        @"format": @"yyyy-MM-dd",
        @"date": [NSDate date]
    },
    @"dateFormat": [GRMustacheFilter variadicFilterWithBlock:^id(NSArray *arguments) {
        // first argument is date
        NSDate *date = [arguments objectAtIndex:0];
        
        // second argument is format
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = [arguments objectAtIndex:1];
        
        // compute the result
        return [dateFormatter stringFromDate:date];
    }]
};

NSString *rendering = [GRMustacheTemplate renderObject:data
                                          fromResource:@"Document"
                                                bundle:nil
                                                 error:NULL];
```

Final rendering:

    2012-10-28 at 17:10
    2012-10-28


Filters that return rendering objects
-------------------------------------

"Rendering objects" are objects that perform a custom rendering. They are described in detail in the [Rendering Objects Guide](rendering_objects.md).

A fundamental technique of advanced GRMustache rendering is filters that return rendering objects. For example:

    I have {{ cats.count }} {{# pluralize(cats.count) }}cat{{/ }}.

would render, depending on the number of cats:

    I have 1 cat.
    I have 5 cats.

The `pluralize` filter returns an object that is able to pluralize the inner content of the section it is attached to. Go check the [Rendering Objects Guide](rendering_objects.md) for more details.


Filters namespaces
------------------

Just as you can provide an object hierarchy for rendered values, and extract `person.pet.name` from it, you can provide filters as an object hierarchy, and "namespace" your filters. For instance, let's declare the `math.abs` filter, and render `{{ math.abs(x) }}`:

```objc
NSString *templateString = @"{{ math.abs(x) }}";
GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:templateString error:NULL];

id data = @{
    @"x": @(-1),
    @"math": @{
        @"abs": [GRMustacheFilter filterWithBlock:^id(id object) {
            return @(abs([object intValue]));
        }],
    },
};

// 1
NSString *rendering = [template renderObject:data error:NULL];
```


Filters errors
--------------

Should a filter be missing, or should the matching object not conform to the `GRMustacheFilter` protocol, GRMustache will return an error of domain `GRMustacheErrorDomain` and code `GRMustacheErrorCodeRenderingError`.

The message describes the exact place where the error occur has occurred:

    Missing filter for key `f` in tag `{{ f(foo) }}` at line 13 of /path/to/template.
    
    Object for key `f` in tag `{{ f(foo) }}` at line 13 of /path/to/template does not conform to GRMustacheFilter protocol: "blah"


Compatibility with other Mustache implementations
-------------------------------------------------

The [Mustache specification](https://github.com/mustache/spec) does not have any concept of "filters".

The topic is under [discussion](http://github.com/mustache/spec/issues/41) with other implementors of Mustache. A detailed explanation of the ideas behind the filtering API described above is available at [WhyMustacheFilters.md](../Articles/WhyMustacheFilters.md).

**If your goal is to design templates that remain compatible with [other Mustache implementations](https://github.com/defunkt/mustache/wiki/Other-Mustache-implementations), do NOT use filters.**

Instead, have a look at tag delegates, especially the [Tag Delegates as Cross-Platform Filters](delegate.md#tag-delegates-as-cross-platform-filters) section of the Tag Delegates Guide.


Sample code
-----------

Custom filters are used in the [Collection Indexes](sample_code/indexes.md) sample code, and in many items of the [standard library](standard_library.md). [NSFormatter](NSFormatter.md) are ready-made filters in GRMustache. Go check inspiration there.


[up](../../../../GRMustache#documentation), [next](rendering_objects.md)
