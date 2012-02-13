[up](../../../../GRMustache), [next](runtime/context_stack.md)

GRMustache runtime
==================

GRMustache rendering is the combination of a template and of an object that will provide the data. This guide describes this interaction in detail.

Generally speaking, GRMustache will look for values in your data objects through the standard Key-Value Coding `valueForKey:` method.

You can thus provide rendering methods with NSDictionary instances, or custom objects with properties or methods whose name match the keys in the template tags.

    // This template waits for a `name` key:
    GRMustacheTemplate *template = [GRMustacheTemplate parseString:@"{{name}}" error:NULL];
    
    // Those two objects provide this `name` key:
    NSDictionary *dictionary = [NSDictionary dictionaryWithObject:@"dictionary" forKey:@"name"];
    Person *arthur = [Person personWithName:@"arthur"];
    
    // "dictionary"
    [template renderObject:dictionary];
    
    // "arthur"
    [template renderObject:arthur];

- [The context stack](runtime/context_stack.md) will cover Mustache sections and the KVC lookup mechanism.
- [Mustache loops](runtime/loops.md)
- [Mustache booleans](runtime/booleans.md)
- [Helpers](runtime/helpers.md)

[up](../../../../GRMustache), [next](runtime/context_stack.md)
