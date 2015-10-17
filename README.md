GRMustache
==========

GRMustache is a [Mustache](http://mustache.github.io) template engine written in Objective-C, for both MacOS Cocoa and iOS.

It ships with built-in goodies and extensibility hooks that let you avoid the strict minimalism of the genuine Mustache language when you need it.

**April 22, 2015: GRMustache 7.3.2 is out.** [Release notes](CHANGELOG.md)


Get release announcements and usage tips: follow [@GRMustache on Twitter](http://twitter.com/GRMustache).


Features
--------

- Support for the full [Mustache syntax](http://mustache.github.io/mustache.5.html)
- Filters, as `{{ uppercase(name) }}`
- Template inheritance, as in [hogan.js](http://twitter.github.com/hogan.js/), [mustache.java](https://github.com/spullara/mustache.java) and [mustache.php](https://github.com/bobthecow/mustache.php).
- Built-in [goodies](Docs/Guides/goodies.md)


Requirements
------------

- iOS 7.0+ / OSX 10.9+
- Xcode 7

See [GRMustache 7.3.2](https://github.com/groue/GRMustache/tree/v7.3.2) for older systems and Xcode versions.

**Swift developers**: You can use GRMustache from Swift, with a limitation: you can only render Objective-C objects. Instead, consider using [GRMustache.swift](https://github.com/groue/GRMustache.swift), a pure Swift implementation of GRMustache.


Usage
-----

`document.mustache`:

```mustache
Hello {{name}}
Your beard trimmer will arrive on {{format(date)}}.
{{#late}}
Well, on {{format(realDate)}} because of a Martian attack.
{{/late}}
```

```objc
@import GRMustache;

// Load the `document.mustache` resource of the main bundle
GRMustacheTemplate *template;
template = [GRMustacheTemplate templateFromResource:@"document"
                                             bundle:nil
                                              error:NULL];

// Let template format dates with `{{format(...)}}`
NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
dateFormatter.dateStyle = NSDateFormatterMediumStyle;
[template extendBaseContextWithObject:@{ @"format": dateFormatter }];

// The rendered data
id data = @{
    @"name": @"Arthur",
    @"date": [NSDate date],
    @"realDate": [[NSDate date] dateByAddingTimeInterval:60*60*24*3],
    @"late": @YES,
};

// The rendering: "Hello Arthur..."
NSString *rendering = [template renderObject:data error:NULL];
```


Installation
------------

### CocoaPods

[CocoaPods](http://cocoapods.org/) is a dependency manager for Xcode projects.

To use GRMustache with Cocoapods, specify in your Podfile:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
use_frameworks!

pod 'GRMustache', '~> 8.0'
```


### Carthage

[Carthage](https://github.com/Carthage/Carthage) is another dependency manager for Xcode projects.

To use GRMustache with Carthage, specify in your Cartfile:

```
github "groue/GRMustache" ~> 8.0
```


### Manually

Download a copy of GRMustache, embed the `GRMustache.xcodeproj` project in your own project, and add the `GRMustacheOSX` or `GRMustacheiOS` target as a dependency of your own target.


Documentation
=============

External links:

- [The Mustache Language](http://mustache.github.io/mustache.5.html): the Mustache language itself. You should start here.
- [GRMustache Reference](http://cocoadocs.org/docsets/GRMustache/7.3.2/index.html) on cocoadocs.org

Rendering templates:

- [Loading Templates](#loading-templates)
- [Errors](#errors)
- [Mustache Tags Reference](#mustache-tags-reference)
- [The Context Stack and Expressions](#the-context-stack-and-expressions)

Feeding templates:

- [Standard Foundation Types Reference](#standard-foundation-types-reference)
- [Custom Types](#custom-types)
- [Lambdas](#lambdas)
- [Filters](#filters)
- [Advanced Boxes](#advanced-boxes)

Misc:

- [Built-in goodies](#built-in-goodies)


Loading Templates
-----------------

Templates may come from various sources:

- **Raw strings:**

    ```objc
    GRMustacheTemplate *template;
    template = [GRMustacheTemplate
                templateFromString:@"Hello {{name}}"
                             error:NULL];
    ```

- **Bundle resources:**

    ```objc
    // Loads the "document.mustache" resource of the main bundle:
    template = [GRMustacheTemplate
                templateFromResource:@"document"
                              bundle:nil
                               error:NULL];
    ```

- **Files and URLs:**

    ```objc
    
    template = [GRMustacheTemplate
                templateFromContentsOfURL:templateURL
                                    error:NULL];
    template = [GRMustacheTemplate
                templateFromContentsOfFile:@"/path/document.mustache"
                                     error:NULL];
    ```

- **Template Repositories:**
    
    Template repositories represent a group of templates. They can be configured independently, and provide neat features like template caching. For example:
    
    ```objc
    // The repository of Bash templates, with extension ".sh":
    GRMustacheTemplateRepository *repo;
    repo = [GRMustacheTemplateRepository
            templateRepositoryWithBundle:nil
                       templateExtension:@"sh"
                                encoding:NSUTF8StringEncoding];
    
    // Disable HTML escaping for Bash scripts:
    repo.configuration.contentType = GRMustacheContentTypeText;
    
    // Load a template:
    template = [repo templateNamed:@"script" error:NULL];
    ```

For more information, check:

- [GRMustacheTemplate](http://cocoadocs.org/docsets/GRMustache/7.3.2/Classes/GRMustacheTemplate.html)
- [GRMustacheTemplateRepository](http://cocoadocs.org/docsets/GRMustache/7.3.2/Classes/GRMustacheTemplateRepository.html)


Errors
------

Not funny, but they happen. Standard NSErrors of domain NSCocoaErrorDomain, etc. may be thrown whenever the library needs to access the file system or other system resource. GRMustache itself can return errors are of domain `GRMustacheErrorDomain`:

```objc
extern NSString * const GRMustacheRenderingException;
extern NSString * const GRMustacheErrorDomain;

typedef enum {
    GRMustacheErrorCodeParseError,          // bad Mustache syntax
    GRMustacheErrorCodeTemplateNotFound,    // missing template
    GRMustacheErrorCodeRenderingError,      // bad food
} GRMustacheErrorCode;
```

Error handling follows [Cocoa conventions](https://developer.apple.com/library/ios/#documentation/Cocoa/Conceptual/ErrorHandlingCocoa/CreateCustomizeNSError/CreateCustomizeNSError.html). Especially:

> Success or failure is indicated by the return value of the method. [...] **You should always check that the return value is nil or NO before attempting to do anything with the NSError object.**

```objc
NSError *error;
GRMustacheTemplate *template;
NSString *rendering;
template = [GRMustacheTemplate templateFromResource:@"document" bundle:nil error:&error];
rendering = [template renderObject:... error:&error]
if (!rendering) {
    // Parse error at line 2 of template /path/to/template.mustache:
    // Unclosed Mustache tag.
    NSLog(@"%@", error);
}
```


Mustache Tags Reference
-----------------------

Mustache is based on tags: `{{name}}`, `{{#registered}}...{{/registered}}`, `{{>include}}`, etc.

Each one of them performs its own little task:

- [Variable Tags](#variable-tags) `{{name}}` render values.
- [Section Tags](#section-tags) `{{#items}}...{{/items}}` perform conditionals, loops, and object scoping.
- [Inverted Section Tags](#inverted-section-tags) `{{^items}}...{{/items}}` are sisters of regular section tags, and render when the other one does not.
- [Partial Tags](#partial-tags) `{{>partial}}` let you include a template in another one.
- [Partial Override Tags](#partial-override-tags) `{{<layout}}...{{/layout}}` provide *template inheritance*.
- [Set Delimiters Tags](#set-delimiters-tags) `{{=<% %>=}}` let you change the tag delimiters.
- [Comment Tags](#comment-tags) let you comment: `{{! Wow. Such comment. }}`
- [Pragma Tags](#pragma-tags) trigger implementation-specific features.


### Variable Tags

A *Variable tag* `{{value}}` renders the value associated with the key `value`, HTML-escaped. To avoid HTML-escaping, use triple mustache tags `{{{value}}}`:

```objc
NSString *templateString = @"{{value}} - {{{value}}}";
GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:templateString error:NULL];

// Mario &amp; Luigi - Mario & Luigi
id data = @{ @"value": @"Mario & Luigi" };
[template renderObject:data error:NULL];
```


### Section Tags

A *Section tag* `{{#value}}...{{/value}}` is a common syntax for three different usages:

- conditionally render a section.
- loop over a collection.
- dig inside an object.

Those behaviors are triggered by the value associated with `value`:


#### Falsey values

If the value is *falsey*, the section is not rendered. Falsey values are:

- missing values
- false boolean
- zero numbers
- empty strings
- empty collections
- NSNull

For example:

```objc
NSString *templateString = @"<{{#value}}Truthy{{/value}}>";
GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:templateString error:NULL];

// "<Truthy>"
[template renderObject:@{ @"value": @YES } error:NULL];
// "<>"
[template renderObject:@{ } error:NULL];               // missing value
[template renderObject:@{ @"value": @NO } error:NULL]; // false boolean
```


#### Collections

If the value is a *collection*, the section is rendered as many times as there are elements in the collection, and inner tags have direct access to the keys of elements:

Template:

```mustache
{{# friends }}
- {{# name }}
{{/ friends }}
```

Data:

```objc
@{
  @"friends": @[
    @{ @"name": @"Hulk Hogan" },
    @{ @"name": @"Albert Einstein" },
    @{ @"name": @"Tom Selleck" },
  ]
}
```

Rendering:

```
- Hulk Hogan
- Albert Einstein
- Tom Selleck
```

Collections can be NSArray, NSSet, and any object that conforms to NSFastEnumeration (but NSDictionary).


#### Other Values

If the value is not falsey, and not a collection, then the section is rendered once, and inner tags have direct access to the value's keys:

Template:

```mustache
{{# user }}
- {{ name }}
- {{ score }}
{{/ user }}
```

Data:

```objc
@{
  @"user": @{
    @"name": @"Mario"
    @"score": @(1500)
  }
}
```

Rendering:

```
- Mario
- 1500
```


### Inverted Section Tags

An *Inverted section tag* `{{^value}}...{{/value}}` renders when a regular section `{{#value}}...{{/value}}` would not. You can think of it as the Mustache "else" or "unless".

Template:

```
{{# persons }}
- {{name}} is {{#alive}}alive{{/alive}}{{^alive}}dead{{/alive}}.
{{/ persons }}
{{^ persons }}
Nobody
{{/ persons }}
```

Data:

```objc
@{
  @"persons": @[]
}
```

Rendering:

```
Nobody
```

Data:

```objc
@{
  @"persons": @[
    @{ @"name": @"Errol Flynn", @"alive": @NO },
    @{ @"name": @"Sacha Baron Cohen", @"alive": @YES },
  ]
}
```

Rendering:

```
- Errol Flynn is dead.
- Sacha Baron Cohen is alive.
```


### Partial Tags

A *Partial tag* `{{> partial }}` includes another template, identified by its name. The included template has access to the currently available data:

`document.mustache`:

```mustache
Guests:
{{# guests }}
  {{> person }}
{{/ guests }}
```

`person.mustache`:

```mustache
{{ name }}
```

Data:

```objc
@{
  @"guests": @[
    @{ @"name": @"Frank Zappa" },
    @{ @"name": @"Lionel Richie" },
  ]
}
```

Rendering:

```
Guests:
- Frank Zappa
- Lionel Richie
```

Recursive partials are supported, but your data should avoid infinite loops.

Partial lookup depends on the origin of the main template:


#### File system

Partial names are **relative paths** when the template comes from the file system (via paths or URLs):

```objc
GRMustacheTemplate *template;

// Load /path/to/document.mustache
NSString *templatePath = @"/path/document.mustache";
template = [GRMustacheTemplate templateFromContentsOfFile:templatePath error:NULL];

// {{> partial }} includes /path/partial.mustache.
// {{> shared/partial }} includes /path/shared/partial.mustache.
```

Partials have the same file extension as the main template.

```objc
// Load /path/document.html
NSString *templatePath = @"/path/document.html";
template = [GRMustacheTemplate templateFromContentsOfFile:templatePath error:NULL];

// {{> partial }} includes /path/partial.html.
```

When your templates are stored in a hierarchy of directories, you can use **absolute paths** to partials, with a leading slash. For that, you need a *template repository* which will define the root of absolute partial paths:

```objc
GRMustacheTemplateRepository *repo;
GRMustacheTemplate *template;

NSString *templatesPath = @"/path";
repo = [GRMustacheTemplateRepository templateRepositoryWithDirectory:templatesPath];
template = [repo templateNamed:... error:NULL];

// {{> /shared/partial }} includes /path/shared/partial.mustache.
```


#### Bundle resources
    
Partial names are interpreted as **resource names** when the template is a bundle resource:

```objc
// Load the document.mustache resource from the main bundle
GRMustacheTemplate *template;
template = [GRMustacheTemplate templateFromResource:@"document" bundle:nil error:NULL];

// {{> partial }} includes the partial.mustache resource.
```


#### General case

Generally speaking, partial names are always interpreted by a **Template Repository**:

- `+[GRMustacheTemplate templateFromResource:bundle:error:]` uses a bundle-based template repository: partial names are resource names.
- `+[GRMustacheTemplate templateFromContentsOfFile:error:]` uses a file-based template repository: partial names are relative paths.
- `+[GRMustacheTemplate templateFromContentsOfURL:error:]` uses a URL-based template repository: partial names are relative URLs.
- `+[GRMustacheTemplate templateFromString:error:]` uses a template repository that can’t load any partial.
- `-[GRMustacheTemplateRepository templateNamed:error:]` uses the partial loading mechanism of the template repository.

Check [GRMustacheTemplateRepository](http://cocoadocs.org/docsets/GRMustache/7.3.2/Classes/GRMustacheTemplateRepository.html) for more information.


#### Dynamic partials

A tag `{{> partial }}` includes a template, the one that is named "partial". One can say it is **statically** determined, since that partial has already been loaded before the template is rendered:

```objc
GRMustacheTemplateRepository *repo;
GRMustacheTemplate *template;
repo = [GRMustacheTemplateRepository templateRepositoryWithBundle:nil];
template = [repo templateFromString:@"{{#user}}{{>partial}}{{/user}}" error:NULL];

// Now the `partial.mustache` resource has been loaded. It will be used when
// the template is rendered. Nothing can change that.
```

You can also include **dynamic partials**. To do so, use a regular variable tag `{{ partial }}`, and provide the template of your choice for the key "partial" in your rendered data:

```objc
// A template that delegates the rendering of a user to a partial.
// No partial has been loaded yet.
GRMustacheTemplate *template;
template = [GRMustacheTemplate templateFromString:@"{{#user}}{{partial}}{{/user}}" error:NULL];

// The user
id user = @{ @"firstName": @"Georges", @"lastName": @"Brassens", @"occupation": @"Singer" };

// Two different partials:
GRMustacheTemplate *partial1 = [GRMustacheTemplate templateFromString:@"{{firstName}} {{lastName}}" error:NULL];
GRMustacheTemplate *partial2 = [GRMustacheTemplate templateFromString:@"{{occupation}}" error:NULL];

// Two different renderings of the same template:
// "Georges Brassens"
[template renderObject:@{ @"user": user, @"partial": partial1 } error:NULL];
// "Singer"
[template renderObject:@{ @"user": user, @"partial": partial2 } error:NULL];
```


### Partial Override Tags

GRMustache supports **Template Inheritance**, like [hogan.js](http://twitter.github.com/hogan.js/), [mustache.java](https://github.com/spullara/mustache.java) and [mustache.php](https://github.com/bobthecow/mustache.php).

A *Partial Override Tag* `{{< layout }}...{{/ layout }}` includes another template inside the rendered template, just like a regular [partial tag](#partial-tags) `{{> partial}}`.

However, this time, the included template can contain *blocks*, and the rendered template can override them. Blocks look like sections, but use a dollar sign: `{{$ overrideMe }}...{{/ overrideMe }}`.

The included template `layout.mustache` below has `title` and `content` blocks that the rendered template can override:

```mustache
<html>
<head>
    <title>{{$ title }}Default title{{/ title }}</title>
</head>
<body>
    <h1>{{$ title }}Default title{{/ title }}</h1>
    {{$ content }}
        Default content
    {{/ content }}}
</body>
</html>
```

The rendered template `article.mustache`:

```mustache
{{< layout }}

    {{$ title }}{{ article.title }}{{/ title }}
    
    {{$ content }}
        {{{ article.html_body }}}
        <p>by {{ article.author }}</p>
    {{/ content }}
    
{{/ layout }}
```

```objc
GRMustacheTemplate *template;
template = [GRMustacheTemplate templateFromResource:@"article" bundle:nil error:&error];

id data = @{
    @"article": @{
        @"title": @"The 10 most amazing handlebars",
        @"html_body": @"<p>...</p>",
        @"author": @"John Doe"
    }
};
NSString *rendering = [template renderObject:data error:NULL];
```

The rendering is a full HTML page:

```HTML
<html>
<head>
    <title>The 10 most amazing handlebars</title>
</head>
<body>
    <h1>The 10 most amazing handlebars</h1>
    <p>...</p>
    <p>by John Doe</p>
</body>
</html>
```

A few things to know:

- A block `{{$ title }}...{{/ title }}` is always rendered, and rendered once. There is no boolean checks, no collection iteration. The "title" identifier is a name that allows other templates to override the block, not a key in your rendered data.

- A template can contain several partial override tags.

- A template can override a partial which itself overrides another one. Recursion is possible, but your data should avoid infinite loops.

- Generally speaking, any part of a template can be refactored with partials and partial override tags, without requiring any modification anywhere else (in other templates that depend on it, or in your code).


#### Dynamic partial overrides

Like a regular partial tag, a partial override tag `{{< layout }}...{{/ layout }}` includes a statically determined template, the very one that is named "layout".

To override a dynamic partial, use a regular section tag `{{# layout }}...{{/ layout }}`, and provide the template of your choice for the key "layout" in your rendered data.


### Set Delimiters Tags

Mustache tags are generally enclosed by "mustaches" `{{` and `}}`. A *Set Delimiters Tag* can change that, right inside a template.

```
Default tags: {{ name }}
{{=<% %>=}}
ERB-styled tags: <% name %>
<%={{ }}=%>
Default tags again: {{ name }}
```

There are also APIs for setting those delimiters. Check `tagStartDelimiter` and `tagEndDelimiter` in [GRMustacheConfiguration](http://cocoadocs.org/docsets/GRMustache/7.3.2/Classes/GRMustacheConfiguration.html).


### Comment Tags

`{{! Comment tags }}` are simply not rendered at all.


### Pragma Tags

Several Mustache implementations use *Pragma tags*. They start with a percent `%` and are not rendered at all. Instead, they trigger implementation-specific features.

GRMustache interprets two pragma tags that set the content type of the template:

- `{{% CONTENT_TYPE:TEXT }}`
- `{{% CONTENT_TYPE:HTML }}`

**HTML templates** is the default. They HTML-escape values rendered by variable tags `{{name}}`.

In a **text template**, there is no HTML-escaping. Both `{{name}}` and `{{{name}}}` have the same rendering. Text templates are globally HTML-escaped when included in HTML templates.

For a more complete discussion, see the documentation of `contentType` in [GRMustacheConfiguration](http://cocoadocs.org/docsets/GRMustache/7.3.2/Classes/GRMustacheConfiguration.html).


The Context Stack and Expressions
---------------------------------

### The Context Stack

Variable and section tags fetch values in the data you feed your templates with: `{{name}}` looks for the key "name" in your input data, or, more precisely, in the *context stack*.

That context stack grows as the rendering engine enters sections, and shrinks when it leaves. Its top value, pushed by the last entered section, is where a `{{name}}` tag starts looking for the "name" identifier. If this top value does not provide the key, the tag digs further down the stack, until it finds the name it looks for.

For example, given the template:

```mustache
{{#family}}
- {{firstName}} {{lastName}}
{{/family}}
```

Data:

```objc
@{
    @"lastName": @"Johnson",
    @"family": @[
        @{ @"firstName": @"Peter" },
        @{ @"firstName": @"Barbara" },
        @{ @"firstName": @"Emily", @"lastName": @"Scott" },
    ]
}
```

The rendering is:

```
- Peter Johnson
- Barbara Johnson
- Emily Scott
```

The context stack is usually initialized with the data you render your template with:

```objc
// The rendering starts with a context stack containing `data`
[template renderObject:data error:NULL];
```

Precisely speaking, a template has a *base context stack* on top of which the rendered data is added. This base context is always available whatever the rendered data. For example:

```objc
// The base context contains `baseData`
[template extendBaseContextWithObject:baseData];

// The rendering starts with a context stack containing `baseData` and `data`
[template renderObject:data error:NULL];
```

The base context is usually a good place to register [filters](#filters).

See [GRMustacheTemplate](http://cocoadocs.org/docsets/GRMustache/7.3.2/Classes/GRMustacheTemplate.html).


### Expressions

Variable and section tags contain *Expressions*. `name` is an expression, but also `article.title`, and `format(article.modificationDate)`. When a tag renders, it evaluates its expression, and renders the result.

There are four kinds of expressions:

- **The dot** `.` aka "Implicit Iterator" in the Mustache lingo:
    
    Implicit iterator evaluates to the top of the context stack, the value pushed by the last entered section.
    
    It lets you iterate over collection of strings, for example. `{{#items}}<{{.}}>{{/items}}` renders `<1><2><3>` when given [1,2,3].

- **Identifiers** like `name`:
    
    Evaluation of identifiers like `name` goes through the context stack until a value provides the `name` key.
    
    Identifiers can not contain white space, dots, parentheses and commas. They can not start with any of those characters: `{}&$#^/<>`.

- **Compound expressions** like `article.title` and generally `<expression>.<identifier>`:
    
    This time there is no going through the context stack: `article.title` evaluates to the title of the article, regardless of `title` keys defined by enclosing contexts.
    
    `.title` (with a leading dot) is a compound expression based on the implicit iterator: it looks for `title` at the top of the context stack.
    
    Compare these three templates:
    
    - `...{{# article }}{{  title }}{{/ article }}...`
    - `...{{# article }}{{ .title }}{{/ article }}...`
    - `...{{ article.title }}...`
    
    The first will look for `title` anywhere in the context stack, starting with the `article` object.
    
    The two others are identical: they ensure the `title` key comes from the very `article` object.

- **Filter expressions** like `format(date)` and generally `<expression>(<expression>, ...)`:
    
    [Filters](#filters) are introduced below.


Standard Foundation Types Reference
-----------------------------------

GRMustache comes with built-in support for the following standard Foundation types:

- [NSArray](#nsarray)
- [NSDictionary](#nsdictionary)
- [NSFastEnumeration](#nsfastenumeration)
- [NSNull](#nsnull)
- [NSNumber](#nsnumber)
- [NSOrderedSet](#nsorderedset)
- [NSSet](#nsset)
- [NSString](#nsstring)
- [NSObject](#nsobject)


### NSArray

- `{{array}}` renders the concatenation of the renderings of array elements.
- `{{#array}}...{{/array}}` renders as many times as there are elements in the array, pushing them on top of the [context stack](#the-context-stack).
- `{{^array}}...{{/array}}` renders if and only if the array is empty.

Exposed keys:

- `array.first`: the first element.
- `array.last`: the last element.
- `array.count`: the number of elements in the array.


### NSDictionary

- `{{dictionary}}` renders the standard description of *dictionary* (not very useful).
- `{{#dictionary}}...{{/dictionary}}` renders once, pushing the dictionary on top of the [context stack](#the-context-stack).
- `{{^dictionary}}...{{/dictionary}}` does not render.


### NSFastEnumeration

- `{{collection}}` renders the concatenation of the renderings of collection elements.
- `{{#collection}}...{{/collection}}` renders as many times as there are elements in the collection, pushing them on top of the [context stack](#the-context-stack).
- `{{^collection}}...{{/collection}}` renders if and only if the collection is empty.


### NSNull

- `{{null}}` does not render.
- `{{#null}}...{{/null}}` does not render.
- `{{^null}}...{{/null}}` renders.


### NSNumber

- `{{number}}` renders the standard description of *number*.
- `{{#number}}...{{/number}}` renders if and only if `[number boolValue]` is YES.
- `{{^number}}...{{/number}}` renders if and only if `[number boolValue]` is NO.

To format numbers, use `NSNumberFormatter`:

```objc
NSNumberFormatter *percentFormatter = [[NSNumberFormatter alloc] init];
percentFormatter.numberStyle = NSNumberFormatterPercentStyle;

GRMustacheTemplate *template;
NSString *templateString = @"{{ percent(x) }}";
template = [GRMustacheTemplate templateFromString:templateString error:NULL];

// Rendering: 50%
id data = @{ @"x": @(0.5) };
NSString *rendering = [template renderObject:data error:NULL];
```

[More info on NSFormatter](Docs/Guides/goodies.md#nsformatter).


### NSOrderedSet

- `{{orderedSet}}` renders the concatenation of the renderings of ordered set elements.
- `{{#orderedSet}}...{{/orderedSet}}` renders as many times as there are elements in the ordered set, pushing them on top of the [context stack](#the-context-stack).
- `{{^orderedSet}}...{{/orderedSet}}` renders if and only if the orderedSet is empty.

Exposed keys:

- `orderedSet.first`: the first element.
- `orderedSet.last`: the last element.
- `orderedSet.count`: the number of elements in the array.


### NSSet

- `{{set}}` renders the concatenation of the renderings of set elements.
- `{{#set}}...{{/set}}` renders as many times as there are elements in the set, pushing them on top of the [context stack](#the-context-stack).
- `{{^set}}...{{/set}}` renders if and only if the set is empty.

Exposed keys:

- `set.first`: any element of the set.
- `set.count`: the number of elements in the set.


### NSString

- `{{string}}` renders *string*, HTML-escaped.
- `{{{string}}}` renders *string*, not HTML-escaped.
- `{{#string}}...{{/string}}` renders if and only if *string* is not empty.
- `{{^string}}...{{/string}}` renders if and only if *string* is empty.

Exposed keys:

- `string.length`: the length of the string.


### NSObject

When an object is not one of the specific ones decribed above, it renders as follows:

- `{{object}}` renders the `description` method, HTML-escaped.
- `{{{object}}}` renders the `description` method, not HTML-escaped.
- `{{#object}}...{{/object}}` renders once, pushing the object on top of the [context stack](#the-context-stack).
- `{{^object}}...{{/object}}` does not render.
    
Templates can access object's properties: `{{ user.name }}`.



TO BE CONTINUED
--------------------------------------------------------------------------



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


Documentation
-------------

If you don't know Mustache, start here: http://mustache.github.io/mustache.5.html

- [Guides](Guides/README.md): a guided tour of GRMustache
- [Reference](http://groue.github.io/GRMustache/Reference/): all classes & protocols
- [Troubleshooting](Guides/troubleshooting.md)
- [FAQ](Guides/faq.md)


License
-------

Released under the [MIT License](LICENSE).


Other Nifty Libraries
---------------------

- [groue/GRMustache.swift](http://github.com/groue/GRMustache.swift): Flexible Mustache templates for Swift 1.2 and 2.
- [groue/GRDB.swift](http://github.com/groue/GRDB.swift): SQLite toolkit for Swift 2.
- [groue/GRValidation](http://github.com/groue/GRDB.swift): Validation toolkit for Swift 2.
