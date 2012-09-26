[up](../runtime.md), [next](../section_tag_helpers.md)

# Booleans

Mustache sections can be controlled by booleans. For instance, the following template would render as an empty string, or as `"whistle"`, depending on the boolean value of the `pretty` key in the rendering context:

	{{#pretty}}whistle{{/pretty}}

We'll first talk about some simple cases. We'll then discuss caveats.

## Simple booleans

The simplest way to provide booleans to GRMustache is to provide `@YES` or `@NO`, that is to say objects returned by the `[NSNumber numberWithBool:]` method:

```objc
NSString *templateString = @"{{#pretty}}whistle{{/pretty}}";
GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:templateString error:NULL];

// @"whistle"
[template renderObject:@{ @"pretty": @YES }];
// @""
[template renderObject:@{ @"pretty": @NO }];
```

## BOOL properties

Since GRMustache uses Key-Value Coding for accessing context keys, you may also provide objects with BOOL properties.

For instance:

```objc
@interface Person: NSObject
@property BOOL pretty;
@end

Person *alice = [Person new];
alice.pretty = YES;

Person *bob = [Person new];
bob.pretty = NO;

[template renderObject:alice]; // @"whistle"
[template renderObject:bob];   // @""
```

Your custom property getters will work just as fine.


## Other false values

GRMustache considers as false the following values, and only those:

- `nil` and missing KVC keys
- `[NSNull null]`
- `NSNumber` instances whose `boolValue` method returns `NO`
- the empty string `@""`
- empty enumerables (all objects conforming to the NSFastEnumeration protocol, but NSDictionary -- the most obvious enumerable is NSArray).

They all prevent Mustache sections `{{#name}}...{{/name}}` rendering.

They all trigger inverted sections `{{^name}}...{{/name}}` rendering.

[up](../runtime.md), [next](../section_tag_helpers.md)
