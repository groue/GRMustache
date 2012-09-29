[up](introduction.md), [next](delegate.md)

Filters
=======

**Filters are not yet part of the Mustache specification**.

> The topic of filters is currently under [discussion](http://github.com/mustache/spec/issues/41) with other implementors of Mustache. A detailed explanation of the ideas behind the filtering API described below is available at [WhyMustacheFilters.md](../Articles/WhyMustacheFilters.md).


Overview
--------

You apply a filter just like calling a function, with parentheses:

- `My name is {{ uppercase(name) }}` would render `My name is ARTHUR`, provided with "Arthur" as a name.

- Filters can chain: `{{ uppercase(reversed(name)) }}` would render `RUHTRA`.

- Filters can apply to compound key paths: `{{ uppercase(person.name) }}`.

- You can extract values from filtered values: `{{ last(persons).name }}`.

- You can filter sections as well : `{{^ isEmpty(people) }}...{{/ isEmpty(people) }}` renders if the people collection is not empty.
    
    For brevity's sake, closing section tags can be empty: `{{^ isEmpty(people) }}...{{/}}` is valid.

- Filters can return filters: `{{ dateFormat(format)(date) }}`.


Standard filters library
------------------------

GRMustache ships with a bunch of already implemented filters:

- `isEmpty`
    
    Returns YES if the input is nil, [NSNull null], or an empty enumerable object, or an empty string. Returns NO otherwise.

- `isBlank`
    
    Returns YES if the input is nil, [NSNull null], or an empty enumerable object, or a string made of zero or more white space characters (space, tabs, newline). Returns NO otherwise.

- `capitalized`
    
    Given "johannes KEPLER", it returns "Johannes Kepler".
    
- `lowercase`
    
    Given "johannes KEPLER", it returns "johannes kepler".

- `uppercase`
    
    Given "johannes KEPLER", it returns "JOHANNES KEPLER".


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
id percentFilter = [GRMustacheFilter filterWithBlock:^id(id object) {
    NSNumberFormatter *percentNumberFormatter = [[NSNumberFormatter alloc] init];
    percentNumberFormatter.numberStyle = kCFNumberFormatterPercentStyle;
    return [numberFormatter stringFromNumber:object];
}];
```

Now, let's have GRMustache know about your custom filter, and use it:

```objc
// Prepare the data
id data = @{ @"gain": @0.5 };

// Prepare the filters
id filters = @{ @percent: percentFilter };

// Renders @"Enjoy your 50% productivity bump!"
NSString *templateString = @"Enjoy your {{ percent(gain) }} productivity bump!";
NSString *rendering = [GRMustacheTemplate renderObject:data
                                           withFilters:filters
                                            fromString:templateString
                                                 error:NULL];
```


Filters namespaces
------------------

Just as you can provide an object hierarchy for rendered values, and extract `person.pet.name` from it, you can provide filters as an object hierarchy, and "namespace" your filters. For instance, let's declare the `math.abs` filter, and render `{{ math.abs(x) }}`:

```objc
id filters = @{
    @"math": @{
        @"abs": [GRMustacheFilter filterWithBlock:^id(id object) {
            return @(abs([object intValue]));
        }]
    }
};

[GRMustacheTemplate renderObject:...
                     withFilters:filters
                      fromString:@"{{math.abs(x)}}"
                           error:NULL];
```


Filters that return filters
---------------------------

Some of you may like defining "meta-filters". No problem:

base.mustache:

    {{#object1}}
        {{ dateFormat(format)(date) }}
    {{/object1}}
    {{#object2}}
        {{ dateFormat(format)(date) }}
    {{/object2}}

render.m:

```objc
id filters = @{
    @"dateFormat": [GRMustacheFilter filterWithBlock:^id(id format) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = [format description]; // force string coercion
        return [GRMustacheFilter filterWithBlock:^id(id date) {
            return [dateFormatter stringFromDate:date];
        }];
    }]
};

id data = @{
    @"object1": @{
        @"format": @"yyyy-MM-dd 'at' HH:mm",
        @"date": [NSDate date]
    },
    @"object2": @{
        @"format": @"yyyy-MM-dd",
        @"date": [NSDate date]
    }
};

NSString *rendering = [GRMustacheTemplate renderObject:data
                                           withFilters:filters
                                          fromResource:@"base"
                                                bundle:nil
                                                 error:NULL];
```

Rendering:

    2012-09-29 at 12:54
    2012-09-29


Filters exceptions
------------------

Should a filter be missing, or should the matching object not conform to the GRMustacheFilter protocol, GRMustache will raise an exception of name `GRMustacheFilterException`.

The message describes the exact place where the error occur has occurred:

    Missing filter for key `f` in tag `{{ f(foo) }}` at line 13 of /path/to/template.
    
    Object for key `f` in tag `{{ f(foo) }}` at line 13 of /path/to/template does not conform to GRMustacheFilter protocol: "blah"


Sample code
-----------

Custom filters are the core tool used by the [formatted numbers](sample_code/number_formatting.md) and [collection indexes](sample_code/indexes.md) sample codes. Go check inspiration there.


[up](introduction.md), [next](delegate.md)
