GRMustache
==========

GRMustache is a production-ready implementation of [Mustache](http://mustache.github.com/) templates for MacOS Cocoa and iOS.

**July 27th, 2012: GRMustache 4.2.0 is out.** [Release notes](GRMustache/blob/master/RELEASE_NOTES.md)

Breaking news on Twitter: http://twitter.com/GRMustache

How To
------

### 1. Download and add to your Xcode project

    $ git clone https://github.com/groue/GRMustache.git

- For MacOS development, add `include/GRMustache.h` and `lib/libGRMustache4-MacOS.a` to your project.
- For iOS development, add `include/GRMustache.h` and `lib/libGRMustache4-iOS.a` to your project.

GRMustache can target MacOS down to 10.6 Snow Leopard, and iOS down to version 3. However, APIs based on Objective-C blocks and NSURL are only available from iOS4.

Alternatively, you may use [CocoaPods](https://github.com/CocoaPods/CocoaPods): append `dependency 'GRMustache'` to your Podfile. In its current version, CocoaPods exposes private headers that you should not rely on, because future versions of GRMustache may change them, without notice, in an incompatible fashion. Make sure you only import `GRMustache.h`.

### 2. Import "GRMustache.h" and start rendering templates

```objc
#import "GRMustache.h"

// Renders "Hello Arthur!"
NSString *rendering = [GRMustacheTemplate renderObject:[Person personWithName:@"Arthur"]
                                            fromString:@"Hello {{name}}!"
                                                 error:NULL];

// Renders from a resource
NSString *rendering = [GRMustacheTemplate renderObject:[Person personWithName:@"Arthur"]
                                          fromResource:@"Profile"  // loads `Profile.mustache`
                                                bundle:nil
                                                 error:NULL];
```


Documentation
-------------

### Mustache syntax

- http://mustache.github.com/mustache.5.html

### Guides

- [Guides/templates.md](GRMustache/blob/master/Guides/templates.md): how to load, parse, and render templates from various sources.
- [Guides/runtime.md](GRMustache/blob/master/Guides/runtime.md): how to provide data to templates.
- [Guides/delegate.md](GRMustache/blob/master/Guides/delegate.md): how to hook into template rendering.

### Sample code

- [Guides/sample_code](GRMustache/tree/master/Guides/sample_code): because some tasks are easier to do with some guidelines.

### Reference

- [Reference](http://groue.github.com/GRMustache/Reference/): the GRMustache reference, automatically generated from inline documentation, for fun and profit, by [appledoc](http://gentlebytes.com/appledoc/).


FAQ
---

- **Q: How do I render array indexes?**
    
    A: Check [Guides/sample_code/indexes.md](GRMustache/blob/master/Guides/sample_code/indexes.md)

- **Q: How do I implement filters, format numbers, dates, etc?**
    
    A: Check documentation of [Mustache lambda sections](GRMustache/blob/master/Guides/runtime/helpers.md) first. If it would not help, maybe you'll get some inspiration from the [number formatting sample code](GRMustache/blob/master/Guides/sample_code/number_formatting.md). If you are still stuck after those, go and look for a [closed issue](GRMustache/issues?state=closed) that covers your need. Finally, open a new issue :-)

- **Q: Does GRMustache provide any layout facility?**
    
    A: No. But there is a [sample Xcode project](GRMustache/tree/master/Guides/sample_code/layout) that demonstrates how to do that.

- **Q: How do I render default values for missing keys?**

    A: This can be done by providing your template a delegate: check [Guides/delegate.md](GRMustache/blob/master/Guides/delegate.md).

- **Q: I have a bunch of templates and partials that live in memory / a database / the cloud / wherever.**
    
    A: Check [Guides/template_repositories.md](GRMustache/blob/master/Guides/template_repositories.md).

- **Q: What is this NSUndefinedKeyException stuff?**

    A: When GRMustache has to try several objects until it finds the one that provides a `{{key}}`, several NSUndefinedKeyException are raised and caught. Let us double guess you: it's likely that you wish Xcode would stop breaking on those exceptions. This use case is covered in [Guides/runtime/context_stack.md](GRMustache/blob/master/Guides/runtime/context_stack.md).

- **Q: Why does GRMustache need JRSwizzle?**

    A: GRMustache will [swizzle](http://www.mikeash.com/pyblog/friday-qa-2010-01-29-method-replacement-for-fun-and-profit.html) the implementation of `valueForUndefinedKey:` in the NSObject and NSManagedObject classes when you invoke `[GRMustache preventNSUndefinedKeyExceptionAttack]`. This use case is covered in [Guides/runtime/context_stack.md](GRMustache/blob/master/Guides/runtime/context_stack.md). The dreadful swizzling happens in [src/classes/GRMustacheNSUndefinedKeyExceptionGuard.m](GRMustache/blob/master/src/classes/GRMustacheNSUndefinedKeyExceptionGuard.m).


Contribution wish-list
----------------------

I wish somebody would review my non-native English, and clean up the guides, if you ask.


Forking
-------

Please fork. You'll learn useful information in [Guides/forking.md](GRMustache/blob/master/Guides/forking.md).


License
-------

Released under the [MIT License](http://en.wikipedia.org/wiki/MIT_License)

Copyright (c) 2012 Gwendal Roué

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

