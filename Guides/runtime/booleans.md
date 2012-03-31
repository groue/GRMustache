[up](../runtime.md), [next](helpers.md)

# Booleans

Mustache sections can be controlled by booleans. For instance, the following template would render as an empty string, or as `"whistle"`, depending on the boolean value of the `pretty` key in the rendering context:

	{{#pretty}}whistle{{/pretty}}

We'll first talk about some simple cases. We'll then discuss caveats.

## Simple booleans: [NSNumber numberWithBool:]

The simplest way to provide booleans to GRMustache is to provide objects returned by the `[NSNumber numberWithBool:]` method:

```objc
NSString *templateString = @"{{#pretty}}whistle{{/pretty}}";
GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:templateString error:NULL];

// @"whistle"
[template renderObject:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES]
                                                   forKey:@"pretty"]];
// @""
[template renderObject:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO]
                                                   forKey:@"pretty"]];
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
- `[NSNumber numberWithBool:NO]`, aka `kCFBooleanFalse`
- the empty string `@""`

All those values will never be rendered with `{{name}}` tags.

They all prevent Mustache sections `{{#name}}...{{/name}}` rendering.

They all trigger inverted sections `{{^name}}...{{/name}}` rendering.

Note that zero, as an explicit NSNumber whose value is zero, or as an int/float property, is not considered false in GRMustache.


## Caveats

### Avoid methods returning BOOL

GRMustache handles properly BOOL properties, but not methods which return BOOL values.

For instance, the following class would **not** render as expected:

```objc
@interface BadPerson: NSObject
- (void)setPretty:(BOOL)value;
- (BOOL)pretty;
@end

Person *carol = [BadPerson new];
[carol setPretty:NO];

// @"whistle"
[template renderObject:carol];
```

GRMustache considers Carol as pretty, although she's not!

That is because `BOOL` type is defined as `signed char` in `<objc/objc.h>`. Since `char` is a number, `[carol objectForKey:@"pretty"]` is `[NSNumber numberWithChar:0]`, which GRMustache considers as an actual number whose value is zero, and not as a falsy value.

Objective-C properties can be analysed at runtime, and that is why GRMustache is able to nicely handle the `BOOL` property of the `Person` class. However, `BadPerson`, which defines no property, can not be applied this extra care.

### Collateral damage: signed characters properties

A consequence is that all properties declared as `char` will be considered as booleans...:

```objc
@interface Person: NSObject
@property char initial;	// will be considered as boolean
@end
```

We thought that built-in support for `BOOL` properties was worth this annoyance, since it should be pretty rare  that you would use a value of such a type in a template.

However, should this behavior annoy you, we provide a mechanism for having GRMustache consider `char` and `BOOL` properties as what they really are: numbers;

Use the GRMustacheTemplateOptionStrictBoolean option when loading and rendering templates:

```objc
Person *alice = [Person new];
alice.pretty = NO;

// All the following renderings return @"whistle", because alice's pretty property is now considered as a number.

// On-the-fly rendering:
[GRMustacheTemplate renderObject:alice fromString:templateString options:GRMustacheTemplateOptionStrictBoolean];

// With a GRMustacheTemplate:
GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:templateString options:GRMustacheTemplateOptionStrictBoolean error:NULL];
[template renderObject:alice];

// With a GRMustacheTemplate loaded from a GRMustacheTemplateRepository:
GRMustacheTemplateRepository *templateRepository = [GRMustacheTemplateRepository templateRepositoryWith... options:GRMustacheTemplateOptionStrictBoolean];
GRMustacheTemplate *template = [templateRepository templateFromString:templateString];
[template renderObject:alice];
```


### The case for C99 bool

You may consider using the unbeloved C99 `bool` type. They can reliably control boolean sections whatever the template options, and with ou without property declaration.

```objc
@interface Person: NSObject
- (bool)pretty;
@end
```

[up](../runtime.md), [next](helpers.md)
