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

Should a key be missing in the current context, GRMustache will look for it in the enclosing contexts. This is the context stack. It starts with the object initially provided, grows when GRMustache enters a section, and shrinks on section leaving.

### What about NSUndefinedKeyException?

I can hear you: "What about the `NSUndefinedKeyException` raised by the Key-Value Coding `valueForKey:` method when a key is missed?"

*GRMustache catches those exceptions*, and behaves as if the value for that key were `nil`.

For instance, the following code will ask `@"foo"` for the key `XXX`. The string will raise, GRMustache will catch, and the final rendering will be the empty string:

    [GRMustacheTemplate renderObject:@"foo"
                          fromString:@"{{XXX}}"
                               error:NULL];

When debugging your project, those exceptions may become a real annoyance, because you tell your debugger to stop on every Objective-C exceptions.

You can avoid that: make sure you call before any GRMustache rendering the following method:

    [GRMustache preventNSUndefinedKeyExceptionAttack];

You'll get a slight performance hit, so you'd probably make sure this call does not enter your Release configuration.

One way to achieve this is to add `-DDEBUG` to the "Other C Flags" setting of your development configuration, and to wrap the preventNSUndefinedKeyExceptionAttack method call in a #if block, like:

    #ifdef DEBUG
    [GRMustache preventNSUndefinedKeyExceptionAttack];
    #endif

Sections vs. Key paths
----------------------

You should be aware that these two template snippets are quite similar, but not stricly equivalent:

- `...{{#foo}}{{bar}}{{/foo}}...`
- `...{{foo.bar}}...`

The first will look for `bar` anywhere in the context stack, starting with the `foo` object.

The latter ensures the `bar` key comes from the `foo` object.

[up](../runtime.md), [next](loops.md)
