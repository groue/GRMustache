GRMustache
==========

GRMustache is an Objective-C implementation of the [Mustache](http://mustache.github.com/) logic-less template language ([version 1.1.2](https://github.com/mustache/spec)).

The Mustache syntax: http://mustache.github.com/mustache.5.html (not wrong, but somewhat outdated).

A list of Mustache implementations in other languages: http://mustache.github.com/

Breaking news on Twitter: http://twitter.com/GRMustache


How To
------

### 1. Download

    $ git clone https://github.com/groue/GRMustache.git

### 2. Add to your Xcode project

- For MacOS 10.6+ development, add `include/GRMustache.h` and `lib/libGRMustache1-macosx10.6.a` to your project.
- For iOS4+ development, add `include/GRMustache.h` and `lib/libGRMustache1-ios4.a` to your project.
- For iOS3+ development, add `include/GRMustache.h` and `lib/libGRMustache1-ios3.a` to your project.

### 3. Import "GRMustache.h" and start rendering templates

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

GRMustache online documentation is provided as guides and sample code:

- [Guides/templates.md](GRMustache/blob/master/Guides/templates.md): how to parse and render templates
- [Guides/runtime.md](GRMustache/blob/master/Guides/runtime.md): how to provide data to templates
- [Guides/delegate.md](GRMustache/blob/master/Guides/delegate.md): how to hook into template rendering
- [Guides/sample_code.md](GRMustache/blob/master/Guides/sample_code.md): because some tasks are easier to do with some guidelines.


FAQ
---

- **Q: I provide false (zero) to a `{{#section}}` but it renders anyway?**
    
    A: That's because zero (the number) is not considered false by GRMustache. Consider providing an actual boolean, and checking the list of "false" values at [Guides/runtime/booleans.md](GRMustache/blob/master/Guides/runtime/booleans.md).

- **Q: What is this NSUndefinedKeyException stuff?**

    A: When GRMustache has to try several objects until it finds the one that provides a `{{key}}`, several NSUndefinedKeyException are raised and caught. Let us double guess you: it's likely that you wish Xcode would stop breaking on those exceptions. This use case is covered in [Guides/runtime/context_stack.md](GRMustache/blob/master/Guides/runtime/context_stack.md).

- **Q: How do I render array indices?**
    
    A: Mustache the language does not provide any easy way to render array indices. However, GRMustache can help you:  [Guides/sample_code/counters.md](GRMustache/blob/master/Guides/sample_code/counters.md).

- **Q: How do I render default values for missing keys?**

    A: This can be done by providing your template a delegate: check [Guides/delegate.md](GRMustache/blob/master/Guides/delegate.md).

- **Q: I have a bunch of templates strings and partials that live in memory, not in the file system. How do I render them?**
    
    A: Check [Guides/template_loaders.md](GRMustache/blob/master/Guides/template_loaders.md).

- **Q: I have no clue how to get rid of deprecation warnings after I have updated GRMustache.**
    
    A: No need to rush: GRMustache won't break your code until it reaches version 2.0. Meanwhile, check the [release notes](GRMustache/blob/master/RELEASE_NOTES.md). They'll tell you how to update your deprecated code.

- **Q: You do not render white spaces in a spec-conformant fashion.**

    A: No, we haven't taken the time to do that. XML and HTML parsers do not care that much, actually. Feel free to submit a patch.


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

