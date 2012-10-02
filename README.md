GRMustache
==========

GRMustache is a production-ready implementation of [Mustache](http://mustache.github.com/) templates for MacOS Cocoa and iOS.

**october 2nd, 2012: GRMustache 5.4.3 is out.** [Release notes](GRMustache/blob/master/RELEASE_NOTES.md)

Don't miss a single release: follow [@GRMustache](http://twitter.com/GRMustache) on Twitter.

How To
------

### 1. Download and add to your Xcode project

    $ git clone https://github.com/groue/GRMustache.git

- For MacOS development, add `include/GRMustache.h` and `lib/libGRMustache5-MacOS.a` to your project.
- For iOS development, add `include/GRMustache.h` and `lib/libGRMustache5-iOS.a` to your project.

Alternatively, you may use [CocoaPods](https://github.com/CocoaPods/CocoaPods): append `pod 'GRMustache', '~> 5.4'` to your Podfile.

GRMustache targets MacOS down to 10.6 Snow Leopard, iOS down to version 4.3, and only depends on the Foundation framework.

**armv6 architecture**: The last GRMustache library that embeds the armv6 slice is [GRMustache 5.0.1](https://github.com/groue/GRMustache/tree/v5.0.1).

### 2. Start rendering templates

```objc
#import "GRMustache.h"

// Renders "Hello Arthur!"
NSString *rendering = [GRMustacheTemplate renderObject:[Person personWithName:@"Arthur"]
                                            fromString:@"Hello {{name}}!"
                                                 error:NULL];

// Renders a document from the `Profile.mustache` resource
NSString *rendering = [GRMustacheTemplate renderObject:[Person personWithName:@"Arthur"]
                                          fromResource:@"Profile"
                                                bundle:nil
                                                 error:NULL];
```


Documentation
-------------

### Mustache syntax

- http://mustache.github.com/mustache.5.html

### Guides

Introduction:

- [introduction.md](GRMustache/blob/master/Guides/introduction.md): a tour of the library features, and most common use cases.

Loading templates:

- [templates.md](GRMustache/blob/master/Guides/templates.md): how to load templates from common sources.
- [partials.md](GRMustache/blob/master/Guides/partials.md): how to embed templates in other templates.
- [templates_repositories.md](GRMustache/blob/master/Guides/template_repositories.md): load templates from less common sources.

Rendering templates:

- [runtime.md](GRMustache/blob/master/Guides/runtime.md): how to provide data to templates: an overview
- [runtime/context_stack.md](GRMustache/blob/master/Guides/runtime/context_stack.md): the key lookup in detail.
- [runtime/booleans.md](GRMustache/blob/master/Guides/runtime/booleans.md): boolean sections.
- [runtime/loops.md](GRMustache/blob/master/Guides/runtime/loops.md): enumerable sections.

Advanced Mustache:

- [section_tag_helpers.md](GRMustache/blob/master/Guides/section_tag_helpers.md): how to process the template canvas before it is rendered with Mustache "lambda sections".
- [variable_tag_helpers.md](GRMustache/blob/master/Guides/variable_tag_helpers.md): how to perform rich rendering out of a simple `{{name}}` tag.
- [filters.md](GRMustache/blob/master/Guides/filters.md): how to process data before it is rendered with "filters".
- [delegate.md](GRMustache/blob/master/Guides/delegate.md): how to hook into template rendering.

Sample code:

- [layout template](../../../tree/master/Guides/sample_code/layout): how to wrap a template in a "layout" template
- [number_formatting.md](GRMustache/blob/master/Guides/sample_code/number_formatting.md): how to format numbers
- [indexes.md](GRMustache/blob/master/Guides/sample_code/indexes.md): how to render array indexes, render sections for the first or the last element, for odd or even elements, etc.
- [localization.md](GRMustache/blob/master/Guides/sample_code/localization.md): how to localize portions of your templates

### Reference

- [Reference](http://groue.github.com/GRMustache/Reference/): the GRMustache reference, automatically generated from inline documentation, for fun and profit, by [appledoc](http://gentlebytes.com/appledoc/).

### Internals

- [forking.md](GRMustache/blob/master/Guides/forking.md): the forking guide tells you everything about GRMustache organization.

FAQ
---

- **Q: How do I render array indexes?**
    
    A: Check [Guides/sample_code/indexes.md](GRMustache/blob/master/Guides/sample_code/indexes.md)

- **Q: How do I format numbers and dates?**
    
    A: Check [Guides/sample_code/number_formatting.md](GRMustache/blob/master/Guides/sample_code/number_formatting.md)

- **Q: How do I render partial templates whose name is only known at runtime?**

    A: Check [Guides/variable_tag_helpers.md](GRMustache/blob/master/Guides/variable_tag_helpers.md)

- **Q: Does GRMustache provide any layout or template inheritance facility?**
    
    A: Check [Guides/partials.md](GRMustache/blob/master/Guides/partials.md), and the [sample Xcode project](GRMustache/tree/master/Guides/sample_code/layout).

- **Q: How do I localize templates?**

    A: Check [Guides/sample_code/localization.md](GRMustache/blob/master/Guides/sample_code/localization.md)

- **Q: How do I render default values for missing keys?**

    A: Check [Guides/delegate.md](GRMustache/blob/master/Guides/delegate.md).

- **Q: What is this NSUndefinedKeyException stuff?**

    A: When GRMustache has to try several objects until it finds the one that provides a `{{key}}`, several NSUndefinedKeyException are raised and caught. Let us double guess you: it's likely that you wish Xcode would stop breaking on those exceptions. This use case is covered in [Guides/runtime/context_stack.md](GRMustache/blob/master/Guides/runtime/context_stack.md).

- **Q: Why does GRMustache need JRSwizzle?**

    A: GRMustache does not need it. However, *you* may happy having GRMustache [swizzle](http://www.mikeash.com/pyblog/friday-qa-2010-01-29-method-replacement-for-fun-and-profit.html) `valueForUndefinedKey:` in the NSObject and NSManagedObject classes when you invoke `[GRMustache preventNSUndefinedKeyExceptionAttack]`. The use case is described in [Guides/runtime/context_stack.md](GRMustache/blob/master/Guides/runtime/context_stack.md).

What other people say
---------------------

[@JeffSchilling](https://twitter.com/jeffschilling/status/142374437776408577):

> I'm loving grmustache

[@basilshkara](https://twitter.com/basilshkara/status/218569924296187904):

> Oh man GRMustache saved my ass once again. Awesome lib.

[@guiheneuf](https://twitter.com/guiheneuf/status/249061029978460160):

> GRMustache filters extension saved us from great escaping PITAs. Thanks @groue.

[@orj](https://twitter.com/orj/status/195310301820878848):

> Thank fucking christ for decent iOS developers who ship .lib files in their Github repos. #GRMustache



Contribution wish-list
----------------------

I wish somebody would review my non-native English, and clean up the guides, if you ask.


Forking
-------

Please fork. You'll learn useful information in [Guides/forking.md](GRMustache/blob/master/Guides/forking.md).


License
-------

Released under the [MIT License](GRMustache/blob/master/LICENSE).
