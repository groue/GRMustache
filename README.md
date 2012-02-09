GRMustache
==========

GRMustache is an Objective-C implementation of the [Mustache](http://mustache.github.com/) logic-less template engine.

The Mustache syntax: http://mustache.github.com/mustache.5.html (not wrong, but somewhat outdated).

A list of Mustache implementations in other languages: http://mustache.github.com/

Breaking news on Twitter: http://twitter.com/GRMustache


What you get
------------

**An ARC-compatible static library**, that will run on your computers, devices, simulators.

**MacOS 10.6+, iPhoneOS 3.0, iOS 4.0+ support**

**Compatibility with other Mustache implementations**: [Mustache specification v1.1.2](https://github.com/mustache/spec) conformance, and a touch of [Handlebars.js](https://github.com/wycats/handlebars.js) (details in [guides/flavors.md](GRMustache/blob/master/guides/flavors.md)).
    
**Compatibility with previous GRMustache versions**: update GRMustache, enjoy performance improvements and bugfixes, and don't change a line of your code.

**Number and date formatting.** Handy, and built-in.

**Guides**: GRMustache online documentation is provided as guides. The first one tells you how to embed GRMustache in your XCode project: [guides/embedding.md](GRMustache/blob/master/guides/embedding.md).


Usage
-----

GRMustache rendering is the combination of a template string and of an object that will provide the data.

You can render templates on the fly:

    #import "GRMustache.h"
    
    NSString *templateString = @"Hello {{name}}!";
    Person *arthur = [Person personWithName:@"Arthur"];
    
    // Returns "Hello Arthur!"
    [GRMustacheTemplate renderObject:arthur
                          fromString:templateString
                               error:NULL];

You can also parse a template once, and render it many times.

    GRMustacheTemplate *template = [GRMustacheTemplate parseString:templateString error:NULL];
    [template renderObject:arthur];
    [template renderObject:...];

Speaking of templates, GRMustache eats many kinds of them: files and bundle resources as well as raw strings. For more information, check [guides/templates.md](GRMustache/blob/master/guides/templates.md).

Regarding the data objects, GRMustache fetches values with the standard Key-Value Coding `valueForKey:` method. Check [guides/runtime.md](GRMustache/blob/master/guides/runtime.md).

Mustache flavors
----------------

GRMustache supports two Mustache flavors : the genuine Mustache, and a bit a [Handlebars.js](https://github.com/wycats/handlebars.js).

The main difference lies in the syntax of key paths: genuine Mustache reads `{{foo.bar.baz}}`, while Handlebars reads `{{foo/bar/baz}}` and even `{{../foo/bar/baz}}`.

If your templates use such compound key paths, you should read [guides/flavors.md](GRMustache/blob/master/guides/flavors.md).


Features worth noting
---------------------

### Lambda sections

Mustache has "lambda sections". These are sections that allow you to execute custom code, and implement nifty features like caching, filtering, whatever, on portions of your templates.

Be sure to read GRMustache's take on the subject: [guides/runtime/helpers.md](GRMustache/blob/master/guides/runtime/helpers.md).

### Number and Date formatting

GRMustache ships with a few helper classes. One allows you to format all numbers in a section with a `NSNumberFormatter` instance, the other does the same, for dates.

They are covered by [guides/number_formatting.md](GRMustache/blob/master/guides/number_formatting.md) and  [guides/date_formatting.md](GRMustache/blob/master/guides/date_formatting.md)

Forking
-------

Please fork. You'll learn useful information in [guides/forking.md](GRMustache/blob/master/guides/forking.md).

License
-------

Released under the [MIT License](http://en.wikipedia.org/wiki/MIT_License)

Copyright (c) 2012 Gwendal Roué

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

