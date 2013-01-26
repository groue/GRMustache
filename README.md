GRMustache
==========

GRMustache is a flexible and production-ready implementation of [Mustache](http://mustache.github.com/) templates for MacOS Cocoa and iOS.

GRMustache targets iOS down to version 4.3, MacOS down to 10.6 Snow Leopard (with or without garbage collection), and only depends on the Foundation framework.

**January 12, 2013: GRMustache 6.1.4 is out.** [Release notes](GRMustache/blob/master/RELEASE_NOTES.md)

Don't miss a single release: follow [@GRMustache](http://twitter.com/GRMustache) on Twitter.

How To
------

### 1. Setup your Xcode project

**Option 1: CocoaPods**

Dear [CocoaPods](https://github.com/CocoaPods/CocoaPods) users, append `pod 'GRMustache', '~> 6.1'` to your Podfile.

**Option 2: Static Library**

The distribution includes pre-built static libraries:

Clone the repository with the `git clone https://github.com/groue/GRMustache.git` command.

- For MacOS development, add `include/GRMustache.h` and `lib/libGRMustache6-MacOS.a` to your project.
- For iOS development, add `include/GRMustache.h` and `lib/libGRMustache6-iOS.a` to your project.

If you have GRMustache files *copied* in your project, you'll need to copy all header files of the `include` directory, not only `GRMustache.h`.

The armv6 slice is not included. In order to target this architecture, you have to compile GRMustache yourself (see below), or to use CocoaPods (see above).

**Option 3: Compiling the raw sources**

You may also embed the raw GRMustache sources in your project:

    $ git clone https://github.com/groue/GRMustache.git
    $ cd GRMustache
    $ git checkout v6.1.4  # checkout the latest stable release
    $ git submodule update --init src/vendor/groue/jrswizzle

Add all files of `src/classes` plus `src/vendor/groue/jrswizzle/JRSwizzle.*` to your project.

If your project uses ARC, flag the source files with the `-fno-objc-arc` compiler flag ([how to](http://stackoverflow.com/questions/6646052/how-can-i-disable-arc-for-a-single-file-in-a-project)).

In your own sources, avoid importing header files whose name ends with `_private.h`: those are private headers that may change, without notice, in future releases.

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

- [Introduction](GRMustache/blob/master/Guides/introduction.md): a tour of the library features, and most common use cases.

Loading templates:

- [Templates](GRMustache/blob/master/Guides/templates.md): how to load templates from common sources.
- [Partials](GRMustache/blob/master/Guides/partials.md): how to embed templates in other templates.
- [Templates Repositories](GRMustache/blob/master/Guides/template_repositories.md): load templates from less common sources.
- [Configuration](GRMustache/blob/master/Guides/configuration.md): who said options?

Rendering templates:

- [Runtime](GRMustache/blob/master/Guides/runtime.md): how GRMustache renders your data
- [Feeding The Templates](GRMustache/blob/master/Guides/runtime_patterns.md): how to provide data to templates

Advanced GRMustache:

- [Filters](GRMustache/blob/master/Guides/filters.md): how to process data before it is rendered with "filters".
- [Tag Delegates](GRMustache/blob/master/Guides/delegate.md): how to observe and alter template rendering.
- [Rendering Objects](GRMustache/blob/master/Guides/rendering_objects.md): how to provide your custom rendering code.
- [Protected Contexts](GRMustache/blob/master/Guides/protected_contexts.md): how to have some keys always evaluate to the same value.

### Sample code

- [Number Formatting](GRMustache/blob/master/Guides/sample_code/number_formatting.md): how to format numbers
- [Collection Indexes](GRMustache/blob/master/Guides/sample_code/indexes.md): how to render array indexes, render sections for the first or the last element, for odd or even elements, etc.
- [Localization](GRMustache/blob/master/Guides/sample_code/localization.md): how to localize portions of your templates

### Reference

- [Reference](http://groue.github.com/GRMustache/Reference/): the GRMustache reference, automatically generated from inline documentation, for fun and profit, by [appledoc](http://gentlebytes.com/appledoc/).

### Internals

- [Forking](GRMustache/blob/master/Guides/forking.md): the forking guide tells you everything about GRMustache organization.

FAQ
---

- **Q: Is it possible to render array indexes, customize first, last, odd, even items, play fizzbuzz?**
    
    A: [YES](GRMustache/blob/master/Guides/sample_code/indexes.md)

- **Q: Is it possible to format numbers and dates?**
    
    A: [YES](GRMustache/blob/master/Guides/sample_code/number_formatting.md)

- **Q: Is it possible to render partial templates whose name is only known at runtime?**

    A: [YES](GRMustache/blob/master/Guides/rendering_objects.md)

- **Q: Does GRMustache provide any layout or template inheritance facility?**
    
    A: [YES](GRMustache/blob/master/Guides/partials.md)

- **Q: Is it possible to localize templates?**

    A: [YES](GRMustache/blob/master/Guides/sample_code/localization.md)

- **Q: Is it possible to render default values for missing keys?**

    A: [YES](GRMustache/blob/master/Guides/delegate.md)

- **Q: Is it possible to disabling HTML escaping?**

    A: [YES](GRMustache/blob/master/Guides/configuration.md)

- **Q: What is this NSUndefinedKeyException stuff?**

    A: When GRMustache has to try several objects until it finds the one that provides a `{{key}}`, several NSUndefinedKeyException are raised and caught. Let us double guess you: it's likely that you wish Xcode would stop breaking on those exceptions. This use case is covered in the [Runtime Guide](GRMustache/blob/master/Guides/runtime.md).

- **Q: Why does GRMustache need JRSwizzle?**

    A: GRMustache does not need it. However, *you* may happy having GRMustache [swizzle](http://www.mikeash.com/pyblog/friday-qa-2010-01-29-method-replacement-for-fun-and-profit.html) `valueForUndefinedKey:` in the NSObject and NSManagedObject classes when you invoke `[GRMustache preventNSUndefinedKeyExceptionAttack]`. The use case is described in the [Runtime Guide](GRMustache/blob/master/Guides/runtime.md).

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

[@SebastienPeek](https://twitter.com/sebastienpeek/status/290700413152423936)

> @issya should see the HTML template I built, pretty wicked. GRMustache is the best.

[@mugginsoft](https://twitter.com/mugginsoft/status/294758563698597888)

> Using GRMustache (Cocoa) for template processing. Looks like a top quality library. Good developer and good units tests. Get it on GitHub.


Popular projects & apps using GRMustache
----------------------------------------

* [tomaz/appledoc](https://github.com/tomaz/appledoc): Objective-c code Apple style documentation set generator
* [mapbox/mapbox-ios-sdk](https://github.com/mapbox/mapbox-ios-sdk): MapBox iOS SDK, an open source alternative to MapKit
* [CarterA/Tribo](https://github.com/CarterA/Tribo): Extremely fast static site generator written in Objective-C
* [AutoLib](http://itunes.com/apps/autolib) uses GRMustache and [spullara/mustache.java](https://github.com/spullara/mustache.java) for rendering an identical set of Mustache templates on iOS and Android.
* [CinéObs](http://itunes.com/apps/cineobs) uses GRMustache for RSS feeds rendering
* [Fotopedia](http://itunes.com/apps/fotonautsinc), the first collaborative photo encyclopedia
* [FunGolf GPS](http://itunes.com/apps/fungolf), a golf app with 3D maps
* [KosmicTask](http://www.mugginsoft.com/kosmictask), an integrated scripting environment for OS X that supports more than 20 scripting languages.


Contribution wish-list
----------------------

Please look for an [open issue](GRMustache/issues) that smiles at you!

... And I wish somebody would review the non-native English of the documentation and guides.


Forking
-------

Please fork. You'll learn useful information in the [Forking Guide](GRMustache/blob/master/Guides/forking.md).


License
-------

Released under the [MIT License](GRMustache/blob/master/LICENSE).
