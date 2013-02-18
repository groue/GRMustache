[up](../../../../GRMustache#documentation), [next](filters.md)

NSFormatter
===========

GRMustache provides built-in support for NSFormatter and its subclasses such as NSNumberFormatter and NSDateFormatter.

There are ready-made [filters](filters.md) and [rendering objects](rendering_objects.md) (aka "lambdas").


Filter facet
------------

Just add your formatters to the data you render: they get ready to be used as filters:

`Document.mustache`:

    {{ percent(x) }}

Rendering code:

```objc
NSNumberFormatter *percentFormatter = [NSNumberFormatter new];
percentFormatter.numberStyle = NSNumberFormatterPercentStyle;

id data = @{
    @"x": @(0.5),
    @"percent": percentFormatter,
};

NSString *rendering = [GRMustacheTemplate renderObject:data
                                          fromResource:@"Document"
                                                bundle:nil
                                                 error:NULL];
```

Rendering:

    50%


Rendering object facet
----------------------

[Rendering objects](rendering_objects.md) are able to render a full Mustache section as they want. NSFormatters take the opportunity to *format all variable tags* inside the section:

`Document.mustache`:

    {{# percent }}
    hourly: {{ hourly }}
    daily: {{ daily }}
    weekly: {{ weekly }}
    {{/ percent }}

Rendering code:

```objc
NSNumberFormatter *percentFormatter = [NSNumberFormatter new];
percentFormatter.numberStyle = NSNumberFormatterPercentStyle;

id data = @{
    @"hourly": @(0.1),
    @"daily": @(1.5),
    @"weekly": @(4),
    @"percent": percentFormatter,
};

NSString *rendering = [GRMustacheTemplate renderObject:data
                                          fromResource:@"Document"
                                                bundle:nil
                                                 error:NULL];
```

Rendering:

    hourly: 10%
    daily: 150%
    weekly: 400%

Variable tags buried inside inner sections are escaped as well, so that you can render loop and conditional sections. However, values that can't be formatted are left untouched:

`Document.mustache`:

    {{# percent }}
      {{# ingredients }}
      - {{ name }}: {{ proportion }}  {{! name is intact, proportion is formatted. }}
      {{/ ingredients }}
    {{/ percent }}

Would render:

    - bread: 50%
    - ham: 22%
    - butter: 43%

Precisely speaking, "values that can't be formatted" are the ones that have the `stringForObjectValue:` method return nil, as stated by [apple](https://developer.apple.com/library/mac/#documentation/Cocoa/Reference/Foundation/Classes/NSFormatter_Class/Reference/Reference.html#//apple_ref/occ/instm/NSFormatter/stringForObjectValue:).

Typically, NSNumberFormatter only formats numbers, and NSDateFormatter, dates: you can safely mix various data types in a section controlled by those well-behaved formatters.



Get inspired
------------

NSFormatter has been turned into a citizen of GRMustache using public APIs: check [the code](../src/classes/NSFormatter%2BGRMustache.m) for inspiration.

[up](../../../../GRMustache#documentation), [next](filters.md)
