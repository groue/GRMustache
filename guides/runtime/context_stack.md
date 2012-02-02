[up](../runtime.md), [next](loops.md)

The context stack
=================

Mustache sections open new context
----------------------------------

Mustache sections allow you digging inside an object:

    {{#me}}
      {{#pet}}
          My pet is named {{name}}.
      {{/pet}}
    {{/me}}

Suppose this template is provided this object (forgive the JSON notation):

    { me: {
        pet: {
          name: 'Plato' }}}

The `me` key will return a person.

This person becomes the context in the `me` section: the `pet` key will be looked in that person.

Finally, the `name` key will be looked in the pet.

The stack in action: missing keys
---------------------------------

However, should a key be missing in the current context, GRMustache will look for it in the enclosing contexts. This is the context stack. It starts with the object initially provided, grows when GRMustache enters a section, and shrinks on section leaving.

For instance, consider:

    {{! If there is a title, render it in a <h1> tag }}
    {{#title}}
      <h1>{{title}}</h1>
    {{title}}

The `{{title}}` value tag will fail finding the `title` key in the title string, and thus will look deeper, find the title string again, and render it.

TODO: talk about NSUndefinedKeyException handling

Sections vs. Key paths
----------------------

You should be aware that these two template snippets are quite similar, but not stricly equivalent:

- `...{{#foo}}{{bar}}{{/foo}}...`
- `...{{foo.bar}}...`

The first will look for `bar` anywhere in the context stack, starting with the `foo` object.

The latter ensures the `bar` key comes from the `foo` object.

[up](../runtime.md), [next](loops.md)
