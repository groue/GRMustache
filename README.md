GRMustache
==========

GRMustache is an Objective-C implementation of the [Mustache](http://mustache.github.com/) logic-less template engine.

The Mustache syntax: http://mustache.github.com/mustache.5.html (not wrong, but somewhat outdated).

A list of Mustache implementations in other languages: http://mustache.github.com/

Breaking news on Twitter: http://twitter.com/GRMustache


Three steps to GRMustache
-------------------------

### 1. Download GRMustache

    $ git clone https://github.com/groue/GRMustache.git

### 2. Embed GRMustache in your Xcode project

- For MacOS 10.6+ development, import `/include/GRMustache.h` and `lib/libGRMustache1-macosx10.6.a` in your project.
- For iOS4+ development, import `/include/GRMustache.h` and `lib/libGRMustache1-ios4.a` in your project.
- For iOS3+ development, import `/include/GRMustache.h` and `lib/libGRMustache1-ios3.a` in your project.

### 3. Import "GRMustache.h" and start rendering templates

```objc
#import "GRMustache.h"

NSString *templateString = @"Hello {{name}}!";
Person *arthur = [Person personWithName:@"Arthur"];

// Renders "Hello Arthur!"
NSString *rendering = [GRMustacheTemplate renderObject:arthur fromString:templateString error:NULL];
```

You can also render many times a single template:

```objc
GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:templateString error:NULL];
rendering = [template renderObject:arthur];
rendering = [template renderObject:...];
```


Why GRMustache?
---------------

GRMustache conforms to the [Mustache specification v1.1.2](https://github.com/mustache/spec).

GRMustache respects your code: update GRMustache, enjoy [performance improvements](https://github.com/groue/GRMustacheBenchmark) and bugfixes, and don't change a line of your code. You may get harmless deprecation warnings, though (check the [release notes](GRMustache/blob/master/RELEASE_NOTES.md)).

GRMustache online documentation is provided as guides and sample code:

- [Guides/templates.md](GRMustache/blob/master/Guides/templates.md): how to parse and render templates
- [Guides/runtime.md](GRMustache/blob/master/Guides/runtime.md): how to provide data to templates
- [Guides/delegate.md](GRMustache/blob/master/Guides/delegate.md): how to hook into template rendering
- [Guides/sample_code.md](GRMustache/blob/master/Guides/sample_code.md): because some tasks are easier to do with some guidelines.
- [Guides/forking.md](GRMustache/blob/master/Guides/forking.md): how GRMustache is organized


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

