GRMustache FAQ
==============

- **Is GRMustache thread-safe?**
    
    Thread-safety of non-mutating methods is guaranteed. Thread-safety of mutating methods is not guaranteed.

- **Is it possible to render array indexes? Customize first and last elements? Distinguish odd and even items, play fizzbuzz?**
    
    [Yes, yes, and yes](sample_code/indexes.md).

- **Is it possible to format numbers and dates?**
    
    Yes. Use [NSNumberFormatter and NSDateFormatter](NSFormatter.md).

- **Is it possible to pluralize/singularize strings?**
    
    Yes. You have some [sample code](https://github.com/groue/GRMustache/issues/50#issuecomment-16197912) in issue #50. You may check [@mattt's InflectorKit](https://github.com/mattt/InflectorKit) for actual inflection methods.

- **Is it possible to write Handlebars-like helpers?**
    
    [Yes](rendering_objects.md#example-a-handlebarsjs-helper)

- **Is it possible to localize templates?**

    [Yes](standard_library.md#localize)

- **Is it possible to embed partial templates whose name is only known at runtime?**

    [Yes](rendering_objects.md)

- **Does GRMustache provide any layout or template inheritance facility?**
    
    [Yes](partials.md)

- **Is it possible to render a default value for missing keys?**

    [Yes](view_model.md#default-values)

- **Is it possible to disable HTML escaping?**

    [Yes](html_vs_text.md)

- **What are those NSUndefinedKeyException?**

    When GRMustache has to try several objects until it finds the one that provides a `{{key}}`, several NSUndefinedKeyException may be raised and caught. Those exceptions are part of the normal template rendering. You can be prevent them, though: see the [Runtime Guide](runtime.md#detailed-description-of-grmustache-handling-of-valueforkey).

- **Why does GRMustache need JRSwizzle?**

    GRMustache does not need it, and does not swizzle anything unless you explicitly ask for it. `[GRMustache preventNSUndefinedKeyExceptionAttack]` swizzles NSObject's `valueForUndefinedKey:` in order to prevent NSUndefinedKeyException during template rendering. See the [Runtime Guide](runtime.md#detailed-description-of-grmustache-handling-of-valueforkey) for a detailed discussion.


