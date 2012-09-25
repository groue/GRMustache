[up](introduction.md), [next](template_repositories.md)

Partial templates
=================

When a `{{>name}}` Mustache tag occurs in a template, GRMustache renders in place the content of another template, the *partial*, identified by its name.

You can write recursive partials. Just avoid infinite loops in your context objects.


Source of partials
------------------

Depending on the method which has been used to create the original template, partials will be searched in different places :

- In the main bundle, with ".mustache" extension:
    - `renderObject:fromString:error:`
    - `templateFromString:error:`
- In the specified bundle, with ".mustache" extension:
    - `renderObject:fromResource:bundle:error:`
    - `templateFromResource:bundle:error:`
- In the specified bundle, with the provided extension:
    - `renderObject:fromResource:withExtension:bundle:error:`
    - `templateFromResource:withExtension:bundle:error:`
- Relatively to the URL of the including template, with the same extension:
    - `renderObject:fromContentsOfURL:error:`
    - `templateFromContentsOfURL:error:`
- Relatively to the path of the including template, with the same extension:
    - `renderObject:fromContentsOfFile:error:`
    - `templateFromContentsOfFile:error:`

Check [Guides/template_repositories.md](template_repositories.md) for more partial loading strategies.


Overriding portions of partials
-------------------------------

Partials may contain *overridable sections*. Those sections start with a dollar instead of a pound. For example, let's consider the following partial:

    page_layout.mustache
    <html>
    <head>
        <title>{{$page_title}}Default title{{/page_title}}</title>
    </head>
    <body>
        <h1>{{$page_title}}Default title{{/page_title}}</h1>
        {{$page_content}
            Default content
        {{/page_content}}}
    </body>
    </html>

You can embed such an overridable partial, and override its sections with the `{{<partial}}...{{/partial}}` syntax:

    article_page.mustache
    {{<page_layout}}
    
        {{! override page_title }}
        {{$page_title}}{{article.title}}{{/page_title}}
        
        {{! override page_content }}
        {{$page_content}}
            {{$article}}
                {{body}}
                by {{author}}
            {{/article}}
        {{/page_content}}
        
    {{/page_layout}}

When you render `article.mustache`, you will get a full HTML page.

You can override a section with attached data, as well:

    anonymous_article.mustache
    {{<article_page}}
        {{$article}}
            {{body}}
            by anonymous coward
        {{/article}}
    {{/article_page}}

[up](introduction.md), [next](template_repositories.md)

