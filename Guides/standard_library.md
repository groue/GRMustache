[up](../../../../GRMustache#documentation), [next](../../../tree/master/Guides/sample_code)

The Standard Library
====================

GRMustache [default configuration](configuration.md) contains a library of predefined keys available for your templates:

- `HTML.escape`
- `javascript.escape`
- `capitalized`
- `isBlank`
- `isEmpty`
- `localize`
- `lowercase`
- `uppercase`
- `URL.escape`

The standard library is built with GRMustache public APIs: you can build your own nifty library as well.

HTML.escape
-----------

As a [filter](filters.md), `HTML.escape` returns its argument, HTML-escaped. Since Mustache generally provides HTML-escaping, this filter will generally be used in conjunction with other escaping filters. For example:

    <script type="text/javascript">
      $("element").html("{{{ javascript.escape(HTML.escape(content))) }}}")
    </script>

As a [rendering object](rendering_objects.md), `HTML.escape` escapes all inner variable tags in a section:

    {{# HTML.escape }}
      {{ firstName }}
      {{ lastName }}
    {{/ HTML.escape }}

Inner sections are unaffected, so that you can render loop and conditional sections without escaping side effects:

    {{# HTML.escape }}
      {{# items }}
        {{ name }}
      {{/}}
    {{/ HTML.escape }}

See also `javascript.escape`, `URL.escape`


javascript.escape
-----------------

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

Inner sections are unaffected, so that you can render loop and conditional sections without escaping side effects:

    <script type="text/javascript">
      {{# javascript.escape }}
        var firstName = {{# firstName }}"{{ firstName }}"{{^}}null{{/}};
        var lastName = {{# lastName }}"{{ lastName }}"{{^}}null{{/}};
      {{/ javascript.escape }}
    </script>

See also `HTML.escape`, `URL.escape`


capitalized
-----------

This [filter](filters.md) returns its argument, capitalized: the first character from each word is changed to its corresponding uppercase value, and all remaining characters set to their corresponding lowercase values.

    {{ capitalized(firstName) }} {{ capitalized(lastName) }}

See also `lowercase`, `uppercase`.


isBlank
-------

This [filter](filters.md) is true if and only if its argument is "blank", that is to say nil, null, empty (empty string or empty enumerable), or a string only made of white spaces. 

    {{# isBlank(name) }}
      Blank name
    {{^}}
      {{name}}
    {{/}}

See also `isEmpty`.


isEmpty
-------

This [filter](filters.md) is true if and only if its argument is "empty", that is to say nil, null, or empty (empty string or empty enumerable).

    {{# isEmpty(name) }}
      No name
    {{^}}
      {{name}}
    {{/}}

See also `isBlank`.


localize
--------

As a [filter](filters.md), `localize` outputs a string looked in the Localizable.string table of the main bundle:

    {{ localize(greeting) }}

This would render "Bonjour", given "Hello" as a greeting, and a French localization for "Hello".

As a [rendering object](rendering_objects.md), `localize` outputs the localization of a full section:

    {{# localize }}Hello{{/ localize }}

This would render "Bonjour" given a French localization for "Hello".

When looking for the localized string is the main bundle, GRMustache replaces all variable tags with "%@":

    {{# localize }}Hello {{name}}{{/ localize }}

This would render "Bonjour Arthur" given a French localization for "Hello %@".

You can embed conditional sections inside:

    {{# localize }}Hello {{#name}}{{name}}{{^}}you{{/}}{{/ localize }}

Depending on the name, this would render "Bonjour Arthur" or "Bonjour toi", given French localizations for both "Hello %@" and "Hello you".


lowercase
---------

This [filter](filters.md) returns a lowercased representation of its argument.

    {{ lowercase(name) }}

See also `capitalized`, `uppercase`.


uppercase
---------

This [filter](filters.md) returns a uppercased representation of its argument.

    {{ uppercase(name) }}

See also `lowercase`, `uppercase`.


URL.escape
-----------

As a [filter](filters.md), `URL.escape` returns its argument, percent-escaped.

    <a href="http://google.com?q={{ URL.escape(query) }}">

As a [rendering object](rendering_objects.md), `URL.escape` escapes all inner variable tags in a section:

    {{# URL.escape }}
      <a href="http://google.com?q={{ query }}&hl={{ language }}">
    {{/ URL.escape }}

Inner sections are unaffected, so that you can render loop and conditional sections without escaping side effects:

    {{# URL.escape }}
      <a href="http://google.com?q={{ query }}{{#language}}&hl={{ language }}{{/language}}">
    {{/ URL.escape }}

See also `HTML.escape`, `javascript.escape`


[up](../../../../GRMustache#documentation), [next](../../../tree/master/Guides/sample_code)
