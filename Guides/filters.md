Filters
=======

GRMustache allow you to filter values before they are rendered.

**Filters are not yet part of the Mustache specification**, and you need to explicitely opt-in in order to use them, with the `{{%FILTERS}}` special "pragma" tag in your templates.

You apply a filter just like calling a function, with parentheses.

For instance, `{{%FILTERS}}My name is {{ uppercase(name) }}` would render `My name is ARTHUR`, provided with "Arthur" as a name.

Filters can chain: `{{ uppercase(reversed(name)) }}` would render `RUHTRA`.

Filters can apply to compound key paths: `{{ uppercase(person.name) }}`.

You can extract values from filtered values: `{{ last(persons).name }}`.

You can filter sections as well : `{{^ isEmpty(people) }}...` renders if the people collection is not empty.

## Standard library

GRMustache ships with a bunch of filters already implemented:

- `capitalized`
    
    Given "johannes KEPLER", it returns "Johannes Kepler".
    
- `lowercase`
    
    Given "johannes KEPLER", it returns "johannes kepler".

- `uppercase`
    
    Given "johannes KEPLER", it returns "JOHANNES KEPLER".

- `isEmpty`
    
    Returns YES if the input is nil, or an empty enumerable object, or an empty string. Returns NO otherwise.

- `isBlank`
    
    Returns YES if the input is nil, or an empty enumerable object, or a string made of zero or more white space characters (space, tabs, newline). Returns NO otherwise.

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
// Prepare the data
float gain = 0.5;
NSDictionary *data = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:gain] forKey:@"gain"];

// Prepare the filters
NSDictionary *filters = [NSDictionary dictionaryWithObject:percentFilter forKey:@"percent"];

// Renders @"Enjoy your 50% productivity bump!"
NSString *templateString = @"{{%FILTERS}}Enjoy your {{ percent(gain) }} productivity bump!";
NSString *rendering = [GRMustacheTemplate renderObject:data
                                           withFilters:filters
                                            fromString:templateString
                                                 error:NULL];
```

## Missing filters

Should a filter be misspelled, missing, or should the matching object not conform to the GRMustacheFilter protocol, GRMustache will raise an exception.

GRMustache helps you debugging by providing the exact place where the error occurs:

    Missing filter for key `f` in tag `{{ f(foo) }}` at line 13.
    
    Object for key `f` in tag `{{ f(foo) }}` at line 13 does not conform to GRMustacheFilter protocol: "blah"
