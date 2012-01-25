GRMustache rendering
====================

[up](../README.md), [next](rendering/context_stack.md)

GRMustache rendering is the combination of a template and of an object that will provide the data. This guide describes this interaction in detail.

Generally speaking, GRMustache will look for values in your data objects through the standard Key-Value Coding `valueForKey:` method.

You can thus provide rendering methods with NSDictionary instances, or custom objects with properties or methods whose name match the keys in the template tags.

    GRMustacheTemplate *template = [GRMustacheTemplate parseString:@"{{name}}" error:NULL];
    
    NSDictionary *dictionary = [NSDictionary dictionaryWithObject:@"dictionary" forKey:@"name"];
    Person *arthur = [Person personWithName:@"arthur"];
    
    // "dictionary"
    [template renderObject:dictionary];
    
    // "arthur"
    [template renderObject:arthur];

- [The context stack](rendering/context_stack.md) will cover Mustache sections
- [Mustache loops](rendering/loops.md)
- [Mustache booleans](rendering/booleans.md)
- [Helpers](rendering/helpers.md)

[up](../README.md), [next](rendering/context_stack.md)
