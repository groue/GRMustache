[up](../runtime.md), [next](helpers.md)

# Booleans

**TL;DR** Sections render or not, depending on the boolean value of the object they are attached to. Generally speaking, all objects are considered true, except:

- `nil`, and missing KVC keys
- `[NSNull null]`
- `[NSNumber numberWithBool:NO]`, aka `kCFBooleanFalse`
- the empty string `@""`

The most direct ways to provide sections with actual booleans are the explicit `[NSNumber numberWithBool:]` objects, and BOOL properties in your model objects.

Beware zero (an NSNumber whose value is zero) is not considered false in GRMustache.

---

Mustache sections can be controlled by booleans. For instance, the following template would render as an empty string, or as `"whistle"`, depending on the boolean value of the `pretty` key in the rendering context:

	{{#pretty}}whistle{{/pretty}}

We'll first talk about some simple cases. We'll then discuss caveats.

## Simple booleans: [NSNumber numberWithBool:]

The simplest way to provide booleans to GRMustache is to provide objects returned by the `[NSNumber numberWithBool:]` method:

    NSString *templateString = @"{{#pretty}}whistle{{/pretty}}";
    GRMustacheTemplate *template = [GRMustacheTemplate parseString:templateString error:nil];

    // @"whistle"
    [template renderObject:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES]
                                                       forKey:@"pretty"]];
    // @""
    [template renderObject:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO]
                                                       forKey:@"pretty"]];


## BOOL properties

Since GRMustache uses Key-Value Coding for accessing context keys, you may also provide objects with BOOL properties.

For instance:

    @interface Person: NSObject
    @property BOOL pretty;
    + (id)person;
    @end

    Person *alice = [Person person];
    alice.pretty = YES;

    Person *bob = [Person person];
    bob.pretty = NO;

    // @"whistle"
    [template renderObject:alice];

    // @""
    [template renderObject:bob];


## Other false values

GRMustache considers as false the following values, and only those:

- `nil` and missing KVC keys
- `[NSNull null]`
- `[NSNumber numberWithBool:NO]`, aka `kCFBooleanFalse`
- the empty string `@""`

Each of those renderings return the empty string:

    // @"foobar" has no `pretty` key
    [template renderObject:@"foobar"];
    
    // nil is false
    [template renderObject:[NSDictionary dictionary]];
    
    // [NSNull null] is false
    [template renderObject:[NSDictionary dictionaryWithObject:[NSNull null]
                                                       forKey:@"pretty"]];
    
    // [NSNumber numberWithBool:NO] is false
    [template renderObject:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO]
                                                       forKey:@"pretty"]];
    
    // @"" is false
    [template renderObject:[NSDictionary dictionaryWithObject:@""
                                                       forKey:@"pretty"]];

Note that zero, as an explicit NSNumber whose value is zero, or as an int/float property, is not considered false in GRMustache:

    // @"whistle"
    [template renderObject:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:0]
                                                   forKey:@"pretty"]];


## Caveats

### Avoid methods returning BOOL

GRMustache handles properly BOOL properties, but not methods which return BOOL values.

For instance, the following class would **not** render as expected:

    @interface BadPerson: NSObject
    + (id)person;
    - (void)setPretty:(BOOL)value;
    - (BOOL)pretty;
    @end

    Person *carol = [BadPerson person];
    [carol setPretty:NO];

    // @"whistle"
    [template renderObject:carol];

GRMustache considers Carol as pretty, although she's not!

That is because `BOOL` type is defined as `signed char` in `<objc/objc.h>`. Since `char` is a number, `[carol objectForKey:@"pretty"]` is `[NSNumber numberWithChar:0]`, which GRMustache considers as an actual number, and not as a falsy value.

Objective-C properties can be analysed at runtime, and that is why GRMustache is able to nicely handle the `BOOL` property of the `Person` class. However, `BadPerson`, which defines no property, can not be applied this extra care.

### Avoid property getters

For the very same reason, you should not use your property getters in templates:

    @interface Person: NSObject
    @property (getter=isPretty) BOOL pretty;
    + (id)person;
    @end

    Person *dave = [Person person];
    dave.pretty = NO;

    // Note the use of the property getter, this time
    NSString *templateString = @"{{#isPretty}}whistle{{/isPretty}}";
    GRMustacheTemplate *template = [GRMustacheTemplate parseString:templateString error:nil];

    // @"whistle"
    [template renderObject:dave];

GRMustache considers Dave as pretty, although he's not! That is because there is no `isPretty` property. `isPretty` behaves just like a plain method returning BOOL, and we have seen above how GRMustache handles those.

### Collateral damage: signed characters properties

A consequence is that all properties declared as `char` will be considered as booleans...:

    @interface Person: NSObject
    @property char initial;	// will be considered as boolean
    @end

We thought that built-in support for `BOOL` properties was worth this annoyance, since it should be pretty rare  that you would use a value of such a type in a template.

However, should this behavior annoy you, we provide a mechanism for having GRMustache behave strictly about boolean properties:

Enter the *strict boolean mode* with the following statement, prior to any rendering:

    [GRMustache setStrictBooleanMode:YES];

In strict boolean mode, `char` and `BOOL` properties will be considered as what they really are: numbers.

### The case for C99 bool

You may consider using the unbeloved C99 `bool` type. They can reliably control boolean sections whatever the boolean mode, and with ou without property declaration.

    @interface Person: NSObject
    - (bool)pretty;
    @end

[up](../runtime.md), [next](helpers.md)
