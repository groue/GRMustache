[up](../../../../GRMustache#documentation), [next](standard_library.md)

Template inheritance
====================

Templates may contain *inheritable sections*. Those sections start with a dollar instead of a pound. For example, let's consider the following template:

`layout.mustache`:

    <html>
    <head>
        <title>{{$ page_title }}Default title{{/ page_title }}</title>
    </head>
    <body>
        <h1>{{$ page_title }}Default title{{/ page_title }}</h1>
        {{$ page_content }}
            Default content
        {{/ page_content }}}
    </body>
    </html>

You can inherit from it from another template, and override its sections:

`article.mustache`:

    {{< layout }}
    
        {{! override page_title }}
        {{$ page_title }}{{ article.title }}{{/ page_title }}
        
        {{! override page_content }}
        {{$ page_content }}
            {{# article }}
                {{ body }}
                by {{ author }}
            {{/ article }}
        {{/ page_content }}
        
    {{/ layout }}

When you render `article.mustache`, you get a full HTML page.

The loading of inherited template follow the same rules as the partial loading tag `{{> partial }}`. Check the [Partial Guide](partials.md) for more information.


Compatibility with other Mustache implementations
-------------------------------------------------

The [Mustache specification](https://github.com/mustache/spec) does not have the concept of template inheritance. Our support for this feature was inspired by [hogan.js](http://twitter.github.com/hogan.js/) and [spullara/mustache.java](https://github.com/spullara/mustache.java).

There is no guarantee that our implementations are identical, though.

**As a consequence, if your goal is to design templates that are compatible with [other Mustache implementations](https://github.com/defunkt/mustache/wiki/Other-Mustache-implementations), use template inheritance with great care.**


[up](../../../../GRMustache#documentation), [next](standard_library.md)
