[up](../../../../GRMustache#documentation), [next](html_vs_text.md)

The Standard Library
====================

GRMustache ships with a library of built-in goodies available for your templates:

- String Processing
    - [HTML.escape](#htmlescape)
    - [capitalized](#capitalized)
    - [javascript.escape](#javascriptescape)
    - [lowercase](#lowercase)
    - [uppercase](#uppercase)
    - [URL.escape](#urlescape)
- Collection Processing
    - [each](#each)
- Miscellaneous
    - [isBlank](#isblank)
    - [isEmpty](#isempty)
    - [localize](#localize)


String Processing
-----------------

### `HTML.escape`

Usage:

- `{{ HTML.escape(...) }}`
- `{{# HTML.escape }}...{{/}}`

As a [filter](filters.md), `HTML.escape` returns its argument, HTML-escaped. Since Mustache generally provides HTML-escaping, this filter will generally be used in conjunction with other escaping filters. For example:

    <script type="text/javascript">
      $("element").html("{{{ javascript.escape(HTML.escape(content))) }}}")
    </script>

As a [rendering object](rendering_objects.md), `HTML.escape` escapes all inner variable tags in a section:

    {{# HTML.escape }}
      {{ firstName }}
      {{ lastName }}
    {{/ HTML.escape }}

Variable tags buried inside inner sections are escaped as well, so that you can render loop and conditional sections:

    {{# HTML.escape }}
      {{# items }}
        {{ name }}
      {{/}}
    {{/ HTML.escape }}

See also [javascript.escape](#javascriptescape), [URL.escape](#urlescape)


### `capitalized`

Usage:

- `{{ capitalized(...) }}`

This [filter](filters.md) returns its argument, capitalized: the first character from each word is changed to its corresponding uppercase value, and all remaining characters set to their corresponding lowercase values.

See also [lowercase](#lowercase), [uppercase](#uppercase).


### `javascript.escape`

Usage:

- `{{ javascript.escape(...) }}`
- `{{# javascript.escape }}...{{/}}`

As a [filter](filters.md), `javascript.escape` outputs a Javascript and JSON-savvy string:

    <script type="text/javascript">
      var name = "{{ javascript.escape(name) }}";
    </script>

As a [rendering object](rendering_objects.md), `javascript.escape` escapes all inner variable tags in a section:

    <script type="text/javascript">
      {{# javascript.escape }}
        var firstName = "{{ firstName }}";
        var lastName = "{{ lastName }}";
      {{/ javascript.escape }}
    </script>

Variable tags buried inside inner sections are escaped as well, so that you can render loop and conditional sections:

    <script type="text/javascript">
      {{# javascript.escape }}
        var firstName = {{# firstName }}"{{ firstName }}"{{^}}null{{/}};
        var lastName = {{# lastName }}"{{ lastName }}"{{^}}null{{/}};
      {{/ javascript.escape }}
    </script>

See also [HTML.escape](#htmlescape), [URL.escape](#urlescape)


### `lowercase`

Usage:

- `{{ lowercase(...) }}`

This [filter](filters.md) returns a lowercased representation of its argument.

See also [capitalized](#capitalized), [uppercase](#uppercase).


### `uppercase`

Usage:

- `{{ uppercase(...) }}`

This [filter](filters.md) returns a uppercased representation of its argument.

See also [lowercase](#lowercase), [uppercase](#uppercase).


### `URL.escape`

Usage:

- `{{ URL.escape(...) }}`
- `{{# URL.escape }}...{{/}}`

As a [filter](filters.md), `URL.escape` returns its argument, percent-escaped.

    <a href="http://google.com?q={{ URL.escape(query) }}">

As a [rendering object](rendering_objects.md), `URL.escape` escapes all inner variable tags in a section:

    {{# URL.escape }}
      <a href="http://google.com?q={{ query }}&hl={{ language }}">
    {{/ URL.escape }}

Variable tags buried inside inner sections are escaped as well, so that you can render loop and conditional sections:

    {{# URL.escape }}
      <a href="http://google.com?q={{ query }}{{#language}}&hl={{ language }}{{/language}}">
    {{/ URL.escape }}

See also [HTML.escape](#htmlescape), [javascript.escape](#javascriptescape)


Collection Processing
---------------------

### `each`

Usage:

- `{{# each(list) }}...{{/}}`
- `{{# each(dictionary) }}...{{/}}`

Iteration is natural to Mustache templates: `{{# users }}{{ name }}, {{/ users }}` renders "Alice, Bob, etc." when the `users` key is given a list of users.

The `each` filter is there to give you some extra keys:

- `@index` contains the 0-based index of the item (0, 1, 2, etc.)
- `@indexPlusOne` contains the 1-based index of the item (1, 2, 3, etc.)
- `@indexIsEven` is true if the 0-based index is even.
- `@first` is true for the first item only.
- `@last` is true for the last item only.

```
One line per user:
{{# each(users) }}
- {{ @index }}: {{ name }}
{{/}}

Comma-separated user names:
{{# each(users) }}{{ name }}{{^ @last }}, {{/}}{{/}}.
```

```
One line per user:
- 0: Alice
- 1: Bob
- 2: Craig

Comma-separated user names: Alice, Bob, Craig.
```

When provided with a dictionary, `each` iterates each key/value pair of the dictionary, stores the key in `@key`, and sets the value as the current context:

```
{{# each(dictionary) }}
- {{ @key }}: {{.}}
{{/}}
```

```
- name: Alice
- score: 200
- level: 5
```

The other positional keys `@index`, `@first`, etc. are still available when iterating dictionaries.


Miscellaneous
-------------

### `isBlank`

Usage:

- `{{# isBlank(...) }}...{{/}}`

This [filter](filters.md) is true if and only if its argument is "blank", that is to say nil, null, empty (empty string or empty enumerable), or a string only made of white spaces. 

    {{# isBlank(name) }}
      Blank name
    {{^}}
      {{name}}
    {{/}}

See also [isEmpty](#isempty).


### `isEmpty`

Usage:

- `{{# isEmpty(...) }}...{{/}}`

This [filter](filters.md) is true if and only if its argument is "empty", that is to say nil, null, or empty (empty string or empty enumerable).

    {{# isEmpty(name) }}
      No name
    {{^}}
      {{name}}
    {{/}}

See also [isBlank](#isblank).


### `localize`

Usage:

- `{{ localize(...) }}`
- `{{# localize }}...{{/}}`

#### Localizing a value

As a [filter](filters.md), `localize` outputs a string looked in the Localizable.string table of the main bundle:

    {{ localize(greeting) }}

This would render `Bonjour`, given `Hello` as a greeting, and a French localization for `Hello`.

#### Localizing template content

As a [rendering object](rendering_objects.md), `localize` outputs the localization of a full section:

    {{# localize }}Hello{{/ localize }}

This would render `Bonjour`, given a French localization for `Hello` in the Localizable.string table of the main bundle.

*Warning*: HTML-escaping is done as usual: you localize template snippets that are HTML chunks. There is no escaping.

#### Localizing template content with embedded variables

When looking for the localized string, GRMustache replaces all variable tags with "%@":

    {{# localize }}Hello {{name}}{{/ localize }}

This would render `Bonjour Arthur`, given a French localization for `Hello %@` in the Localizable.string table of the main bundle. `[NSString stringWithFormat:]` is used for the final interpolation.

*Warning 1*: HTML-escaping is done as usual: you localize template snippets that are HTML chunks. There is no escaping, but for `{{name}}`.

*Warning 2*: because of the invocation of `stringWithFormat:`, make sure your localized strings escape their percents. `{{# localize }}%:{{name}}{{/ localize }}` will render fine as long as you provide a localization for `%%:%@`.

#### Localizing template content with embedded variables and conditions

You can embed conditional sections inside:

    {{# localize }}Hello {{#name}}{{name}}{{^}}you{{/}}{{/ localize }}

Depending on the name, this would render `Bonjour Arthur` or `Bonjour toi`, given French localizations for both `Hello %@` and `Hello you`.


#### GRMustacheLocalizer

The `localize` helper is based on the GRMustacheLocalizer class. You can create your own, and localize from a specific localization table from a specific bundle:

```objc
// Will localize from the given string file from the given bundle:
GRMustacheLocalizer *localizer = [[GRMustacheLocalizer alloc] initWithBundle:... tableName:...];

id data = @{
    // With the `localize` key, this localizer overrides the default one:
    @"localize": localizer,
    ...
};

NSString *rendering = [GRMustacheTemplate renderObject:data from...];
```

Get inspired
------------

All items of the standard library, but the `each` filter, are built using public APIs: check the code for inspiration:

- [GRMustacheHTMLLibrary.m](../src/classes/Services/StandardLibrary/GRMustacheHTMLLibrary.m)
- [GRMustacheLocalizer.m](../src/classes/Services/StandardLibrary/GRMustacheLocalizer.m)
- [GRMustacheStandardLibrary.m](../src/classes/Services/StandardLibrary/GRMustacheStandardLibrary.m)


[up](../../../../GRMustache#documentation), [next](html_vs_text.md)
