GRMustache
==========

GRMustache is a flexible and production-ready implementation of [Mustache](http://mustache.github.io/) templates for MacOS Cocoa and iOS.

GRMustache targets iOS down to version 4.3, MacOS down to 10.6 Snow Leopard (with or without garbage collection), and only depends on the Foundation framework.

**August 10, 2013: GRMustache 6.8.2 is out.** [Release notes](RELEASE_NOTES.md)

Get release announcements and usage tips: follow [@GRMustache on Twitter](http://twitter.com/GRMustache).

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

// Renders "Hello Arthur!"
NSString *rendering = [GRMustacheTemplate renderObject:@{ @"name": @"Arthur" }
                                            fromString:@"Hello {{name}}!"
                                                 error:NULL];

// Renders a document from the `Profile.mustache` resource
GRMustacheTemplate *template = [GRMustacheTemplate templateFromResource:@"Profile" bundle:nil error:NULL];
NSString *rendering = [template renderObject:self.currentUser error:NULL];
```

[GRMustachio](https://github.com/mugginsoft/GRMustachio) by Jonathan Mitchell is "A super simple, interactive GRMustache based application". It can help you design and test your templates.

Documentation
-------------

### Mustache syntax

- http://mustache.github.io/mustache.5.html

### Reference

- [Reference](http://groue.github.io/GRMustache/Reference/): the GRMustache reference, automatically generated from inline documentation, for fun and profit, by [appledoc](http://gentlebytes.com/appledoc/).

### Guides

Introduction:

- [Introduction](Guides/introduction.md): a tour of the library features, and most common use cases.

Basics:

- [Templates](Guides/templates.md): how to load templates.
- [Partials](Guides/partials.md): decompose your templates into components named "partials".
- [Templates Repositories](Guides/template_repositories.md): manage groups of templates.
- [Runtime](Guides/runtime.md): how GRMustache renders your data.
- [ViewModel](Guides/view_model.md): an overview of various techniques to feed templates.

Services:

- [Configuration](Guides/configuration.md)
- [HTML vs. Text templates](Guides/html_vs_text.md)
- [Standard Library](Guides/standard_library.md): built-in candy, for your convenience.
- [NSFormatter](Guides/NSFormatter.md), NSNumberFormatter, NSDateFormatter, etc. Use them.

Hooks:

- [Filters](Guides/filters.md): `{{ uppercase(name) }}` et al.
- [Rendering Objects](Guides/rendering_objects.md): "Mustache lambdas", and more.
- [Tag Delegates](Guides/delegate.md): observe and alter template rendering.
- [Protected Contexts](Guides/protected_contexts.md): protect some keys so that they always evaluate to the same value.

Mustache, and beyond:

- [Compatibility](Guides/compatibility.md): compatibility with other Mustache implementations, in details.

### Sample code

Check the [FAQ](#faq) right below.


FAQ
---

- **Q: I get "unrecognized selector sent to instance" errors.**
    
    A: Check that you have added the `-ObjC` option in the "Other Linker Flags" of your target ([how to](http://developer.apple.com/library/mac/#qa/qa1490/_index.html)).

- **Q: Is it possible to render array indexes? Customize first and last elements? Distinguish odd and even items, play fizzbuzz?**
    
    A: [Yes, yes, and yes](Guides/sample_code/indexes.md)

- **Q: Is it possible to format numbers and dates?**
    
    A: Yes. Use [NSNumberFormatter and NSDateFormatter](Guides/NSFormatter.md).

- **Q: Is it possible to pluralize/singularize strings?**
    
    A: Yes. You have some [sample code](https://github.com/groue/GRMustache/issues/50#issuecomment-16197912) in issue #50. You may check [@mattt's InflectorKit](https://github.com/mattt/InflectorKit) for actual inflection methods.

- **Q: Is it possible to write Handlebars-like helpers?**
    
    A: [Yes](Guides/rendering_objects.md)

- **Q: Is it possible to localize templates?**

    A: [Yes](Guides/standard_library.md#localize)

- **Q: Is it possible to embed partial templates whose name is only known at runtime?**

    A: [Yes](Guides/rendering_objects.md)

- **Q: Does GRMustache provide any layout or template inheritance facility?**
    
    A: [Yes](Guides/partials.md)

- **Q: Is it possible to render a default value for missing keys?**

    A: [Yes](Guides/view_model.md#default-values).

- **Q: Is it possible to disable HTML escaping?**

    A: [Yes](Guides/html_vs_text.md)

- **Q: What is this NSUndefinedKeyException stuff?**

    A: When GRMustache has to try several objects until it finds the one that provides a `{{key}}`, several NSUndefinedKeyException may be raised and caught. It's likely that you wish Xcode would stop breaking on those exceptions: see the [Runtime Guide](Guides/runtime.md#nsundefinedkeyexception-prevention).

- **Q: Why does GRMustache need JRSwizzle?**

    A: GRMustache does not need it, and does not swizzle anything unless you explicitly ask for it. `[GRMustache preventNSUndefinedKeyExceptionAttack]` swizzles NSObject's `valueForUndefinedKey:` in order to prevent NSUndefinedKeyException during template rendering.
    
    You will debug your application without Xcode's exception breakpoint disturbing you. You may even improve rendering performances. See the [Runtime Guide](Guides/runtime.md#nsundefinedkeyexception-prevention).

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

[@dannolan](https://twitter.com/dannolan/status/301088034173120512)

> okay GRMustache is the fucking daddy

[@OldManKris](https://twitter.com/oldmankris/status/307683824362483712)

> GRMustache is teh awesome. Nice to find an open-source library that is more pleasant to use than expected.


Who's using GRMustache
----------------------------------------

* [tomaz/appledoc](https://github.com/tomaz/appledoc): Objective-c code Apple style documentation set generator.
* [mapbox/mapbox-ios-sdk](https://github.com/mapbox/mapbox-ios-sdk): MapBox iOS SDK, an open source alternative to MapKit.
* [CarterA/Tribo](https://github.com/CarterA/Tribo): Extremely fast static site generator written in Objective-C.
* [AutoLib](http://itunes.com/apps/autolib) uses GRMustache and [spullara/mustache.java](https://github.com/spullara/mustache.java) for rendering an identical set of Mustache templates on iOS and Android.
* [Bee](http://www.neat.io/bee): Bee is a desktop bug tracker for the Mac. It currently syncs with GitHub Issues, JIRA and FogBugz.
* [CinéObs](http://itunes.com/apps/cineobs) uses GRMustache for RSS feeds rendering.
* [Fotopedia](http://itunes.com/apps/fotonautsinc), the first collaborative photo encyclopedia.
* [FunGolf GPS](http://itunes.com/apps/fungolf), a golf app with 3D maps.
* [KosmicTask](http://www.mugginsoft.com/kosmictask), an integrated scripting environment for OS X that supports more than 20 scripting languages.
* [MyInvoice](http://www.myinvoice.biz/en), an invoicing iOS app.
* [Servus](https://servus.io) can turn any file on your computer into a branded download page hosted on Dropbox.

Do you use GRMustache? [Tweet me your story and your link](http://twitter.com/GRMustache).


Contribution wish-list
----------------------

Please look for an [open issue](GRMustache/issues) that smiles at you!

... And I wish somebody would review the non-native English of the documentation and guides.


Forking
-------

Please fork. You'll learn useful information in the [Forking Guide](Guides/forking.md).


License
-------

Released under the [MIT License](LICENSE).
