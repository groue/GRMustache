[up](../runtime.md), [next](booleans.md)

Mustache loops
==============

Mustache sections that are provided with an enumerable object will be rendered once for each item in it.

Those are all objects conforming to the NSFastEnumeration protocol, but NSDictionary. The most obvious enumerable is NSArray.

Each item enters the context stack on its turn. Below, the `name` key will be looked in each item:

    My shopping list:
    {{#items}}
    - {{name}}
    {{/items}}

Arrays of scalar values
-----------------------

The "implicit iterator" `{{.}}` tag will help you iterating arrays of strings or numbers, generally objects that don't have any dedicated key for rendering themselves.

For instance, the following template can render `{ items: ['ham', 'jam'] }`.

    <ul>
    {{#items}}
        <li>{{.}}</li>
    {{/items}}
    </ul>

[up](../runtime.md), [next](booleans.md)
