[up](../../../../GRMustache), [next](runtime/context_stack.md)

GRMustache runtime
==================

GRMustache rendering is the combination of a template and of an object that will provide the data. This guide describes this interaction in detail.

Generally speaking, GRMustache will look for values in your data objects through the standard Key-Value Coding `valueForKey:` method.

You can thus provide rendering methods with NSDictionary instances, or custom objects with properties or methods whose name match the keys in the template tags.

```objc
// This template waits for a `name` key:
GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"{{name}}" error:NULL];

// Those two objects provide this `name` key:
NSDictionary *dictionary = [NSDictionary dictionaryWithObject:@"dictionary" forKey:@"name"];
Person *arthur = [Person personWithName:@"arthur"];

// "dictionary"
[template renderObject:dictionary];

// "arthur"
[template renderObject:arthur];
```

- [context_stack.md](runtime/context_stack.md)

    This guide digs into the key lookup mechanism.
    
- [loops.md](runtime/loops.md)
    
    Learn how to iterate through enumerable objects such as arrays.
    
- [booleans.md](runtime/booleans.md)

    Control whether a Mustache section should render or not.
    
- [helpers.md](runtime/helpers.md)

    Mustache has "lambda sections". These are sections that allow you to execute custom code, and implement nifty features like caching, filtering, whatever, on portions of your templates.


[up](../../../../GRMustache), [next](runtime/context_stack.md)
