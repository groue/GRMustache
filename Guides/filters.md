Filters
=======

GRMustache allow you to filter values before they are rendered.

**Filters are not yet part of the Mustache specification**, and you need to explicitely opt-in in order to use them, with the `{{%FILTERS}}` special "pragma" tag in your templates.

You apply filter by adding a pipe character `|` after the value.

For instance, `{{%FILTERS}}My name is {{ name | uppercase }}` would render `My name is ARTHUR`, provided with "Arthur" as a name.

Filters can chain: `{{ name | reversed | uppercase }}` would render `RUHTRA`.

## Standard library

GRMustache ships with a bunch of filters already implemented:

- `capitalized`
    
    Given "johannes KEPLER", it returns "Johannes Kepler".
    
- `lowercase`
    
    Given "johannes KEPLER", it returns "johannes kepler".

- `uppercase`
    
    Given "johannes KEPLER", it returns "JOHANNES KEPLER".

- `empty?`
    
    Returns YES if the input is an empty enumerable object, or an empty string. Returns NO otherwise.

- `blank?`
    
    Returns YES if the input is an empty enumerable object, or a string made of zero or more white space characters (space, tabs, newline). Returns NO otherwise.

## Defining your own filters

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

Starting iOS4 and MacOS 10.6, the Objective-C language provides us with blocks. This can relieve the burden of declaring a full class for each filter:

```objc
id percentFilter = [GRMustacheFilter filterWithBlock:^id(id object) {
    NSNumberFormatter *percentNumberFormatter = [[NSNumberFormatter alloc] init];
    percentNumberFormatter.numberStyle = kCFNumberFormatterPercentStyle;
    return [numberFormatter stringFromNumber:object];
}];
```

Now, let's have GRMustache know about your custom filter, and use it:

```objc
```