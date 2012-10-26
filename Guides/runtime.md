[up](../../../../GRMustache#documentation), [next](runtime/context_stack.md)

GRMustache runtime
==================

## Overview

Basically, there are only two methods and one protocol that you have to care about when providing data to GRMustache:

- `valueForKey:` is the standard [Key-Value Coding](http://developer.apple.com/documentation/Cocoa/Conceptual/KeyValueCoding/Articles/KeyValueCoding.html) method, that GRMustache invokes when looking for the data that will be rendered. Basically, for a `{{name}}` tag to be rendered, all you need to provide is an NSDictionary with the `@"name"` key, or an object declaring the `name` property.

- `description` is the standard [NSObject](http://developer.apple.com/documentation/Cocoa/Reference/Foundation/Protocols/NSObject_Protocol/Reference/NSObject.html) method, that GRMustache invokes when rendering the data it has fetched from `valueForKey:`. Most classes of Apple frameworks already have sensible implementations of `description`: NSString, NSNumber, etc. You generally won't have to think a lot about it.

- `NSFastEnumeration` is the standard protocol for [enumerable objects](http://developer.apple.com/documentation/Cocoa/Conceptual/ObjectiveC/Chapters/ocFastEnumeration.html). The most obvious enumerable is NSArray. There are others, and you may provide your own. Objects that conform to the `NSFastEnumeration` protocol are the base of GRMustache loops.
    
    Both variable tags `{{items}}` and section tags `{{#items}}...{{/items}}` can loop. You'll read more on this topic in the [loops.md](runtime/loops.md) guide.

For instance, let's consider the following code:

```obcj
NSDictionary *dictionary = @{ @"count": @2 };
NSString *templateString = @"I have {{count}} arms.";
NSString *rendering = [[GRMustacheTemplate templateFromString:templateString error:NULL] renderObject:dictionary];
```

1. When GRMustache renders the `{{count}}` tag, it invokes `valueForKey:` with the key `@"count"` on the dictionary. It gets an NSNumber of value 2 as a result.
2. The `description` method of the NSNumber returns a string: `@"2"`.
3. This string is inserted into the rendering: `@"I have 2 arms"`.

Two other "advanced" protocols let you implement some custom rendering:

- `GRMustacheVariableTagHelper`: when a value provided with `valueForKey:` conforms to this protocol, variable tags lets the value perform its own custom rendering. See [variable_tag_helpers.md](variable_tag_helpers.md).

- `GRMustacheSectionTagHelper`: when a value provided with `valueForKey:` conforms to this protocol, section tags lets the value perform its own custom rendering. See [section_tag_helpers.md](section_tag_helpers.md).


## In Detail

Mustache does a little more than rendering plain `{{name}}` tags. Let's review Mustache features and how GRMustache help you leverage them.

- [context_stack.md](runtime/context_stack.md)

    This guide digs into Mustache section tags such as `{{#section}}...{{/section}}`, and the key lookup mechanism.
    
- [loops.md](runtime/loops.md)
    
    Learn how to render template sections as many times as there are objects in enumerable objects such as arrays.
    
- [booleans.md](runtime/booleans.md)

    Control whether a Mustache section should render or not.


[up](../../../../GRMustache#documentation), [next](runtime/context_stack.md)
