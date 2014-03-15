GRMustache
==========

GRMustache is a flexible and production-ready implementation of [Mustache](http://mustache.github.io/) templates for MacOS Cocoa and iOS.

**February 28, 2014: GRMustache 6.9.2 is out.** [Release notes](RELEASE_NOTES.md)

**System requirements**: GRMustache targets iOS down to version 4.3, MacOS down to 10.6 Snow Leopard (without garbage collection), and only depends on the Foundation framework.

Get release announcements and usage tips: follow [@GRMustache on Twitter](http://twitter.com/GRMustache).


7.0
---

GRMustache 7.0 introduces several changes to the previous release, focusing on security, compatibility with other Mustache implementations, and API simplification. Those changes may break your existing applications.

The [GRMustache 7.0 Migration Guide](Guides/upgrading.md) is here to ease your transition


How To
------

### 1. Setup your Xcode project

You have three options, from the simplest to the hairiest:

- [CocoaPods](Guides/installation.md#option-1-cocoapods)
- [Static Library](Guides/installation.md#option-2-static-library)
- [Compile the raw sources](Guides/installation.md#option-3-compiling-the-raw-sources)


### 2. Start rendering templates

```objc
#import "GRMustache.h"
```

One-liners:

```objc
// Renders "Hello Arthur!"
NSString *rendering = [GRMustacheTemplate renderObject:@{ @"name": @"Arthur" } fromString:@"Hello {{name}}!" error:NULL];
```

```objc
// Renders the `Profile.mustache` resource of the main bundle
NSString *rendering = [GRMustacheTemplate renderObject:user fromResource:@"Profile" bundle:nil error:NULL];
```

Reuse templates in order to avoid parsing the same template several times:

```objc
GRMustacheTemplate *template = [GRMustacheTemplate templateFromResource:@"Profile" bundle:nil error:nil];
rendering = [template renderObject:arthur error:NULL];
rendering = [template renderObject:barbara error:NULL];
rendering = ...
```

[GRMustachio](https://github.com/mugginsoft/GRMustachio) by Jonathan Mitchell is "A super simple, interactive GRMustache based application". It can help you design and test your templates.

Documentation
-------------

- http://mustache.github.io/mustache.5.html
- [Guides](Guides#guides): a guided tour to the library
- [Reference](http://groue.github.io/GRMustache/Reference/): the GRMustache reference, automatically generated from inline documentation, for fun and profit, by [appledoc](http://gentlebytes.com/appledoc/).


Troubleshooting
---------------

- **GRMustache does not render my object keys.**

    Check that you have declared Objective-C properties (with `@property`) for those keys.
    
    For security reasons, GRMustache, starting v7.0, does not blindly run the `valueForKey:` method when accessing keys. Check the [Runtime](Guides/runtime.md#key-access) and the [Security](Guides/security.md#safe-key-access) Guides for more information.

- **I get "unrecognized selector sent to instance" errors.**
    
    Check that you have added the `-ObjC` option in the "Other Linker Flags" of your target ([how to](http://developer.apple.com/library/mac/#qa/qa1490/_index.html)).


FAQ
---

- **Is GRMustache thread-safe?**
    
    Thread-safety of non-mutating methods is guaranteed. Thread-safety of mutating methods is not guaranteed.

- **Is it possible to render array indexes? Customize first and last elements? Distinguish odd and even items, play fizzbuzz?**
    
    [Yes, yes, and yes](Guides/sample_code/indexes.md).

- **Is it possible to format numbers and dates?**
    
    Yes. Use [NSNumberFormatter and NSDateFormatter](Guides/NSFormatter.md).

- **Is it possible to pluralize/singularize strings?**
    
    Yes. You have some [sample code](https://github.com/groue/GRMustache/issues/50#issuecomment-16197912) in issue #50. You may check [@mattt's InflectorKit](https://github.com/mattt/InflectorKit) for actual inflection methods.

- **Is it possible to write Handlebars-like helpers?**
    
    [Yes](Guides/rendering_objects.md#example-a-handlebarsjs-helper)

- **Is it possible to localize templates?**

    [Yes](Guides/standard_library.md#localize)

- **Is it possible to embed partial templates whose name is only known at runtime?**

    [Yes](Guides/rendering_objects.md)

- **Does GRMustache provide any layout or template inheritance facility?**
    
    [Yes](Guides/partials.md)

- **Is it possible to render a default value for missing keys?**

    [Yes](Guides/view_model.md#default-values)

- **Is it possible to disable HTML escaping?**

    [Yes](Guides/html_vs_text.md)

- **What are those NSUndefinedKeyException?**

    When GRMustache has to try several objects until it finds the one that provides a `{{key}}`, several NSUndefinedKeyException may be raised and caught. Those exceptions are part of the normal template rendering. You can be prevent them, though: see the [Runtime Guide](Guides/runtime.md#detailed-description-of-grmustache-handling-of-valueforkey).

- **Why does GRMustache need JRSwizzle?**

    GRMustache does not need it, and does not swizzle anything unless you explicitly ask for it. `[GRMustache preventNSUndefinedKeyExceptionAttack]` swizzles NSObject's `valueForUndefinedKey:` in order to prevent NSUndefinedKeyException during template rendering. See the [Runtime Guide](Guides/runtime.md#detailed-description-of-grmustache-handling-of-valueforkey) for a detailed discussion.


Contribution wish-list
----------------------

Please look for an [open issue](GRMustache/issues) that smiles at you!

... And I wish somebody would review the non-native English of the documentation and guides.


You'll learn useful information in the [Forking Guide](Guides/forking.md).


License
-------

Released under the [MIT License](LICENSE).
