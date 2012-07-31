# Mustache support for "Filters"

Here are a few arguments for the introduction of "filters" in Mustache, and a description of what they should be. There is no syntax proposal here, because syntax should be derived from what filters *are*, and I think we should first agree on what they *are* before discussing the syntax.

GRMustache provides an implementation of filters that does not cover all the points described here. However, the documentation is freely available in the [filters guide](https://github.com/groue/GRMustache/blob/filter_chain/Guides/filters.md).

1. Why filters are good for Mustache
2. Why Mustache tags should contain expressions, not statements

## 1. Why filters are good for Mustache

### History of user-provided code: lambdas

Mustache users today have a single way to have their own code executed while rendering a template: lambdas.

Lambdas operate at the *template canvas* level: they can alter raw portions of a template, insert and process raw text, add and remove mustache tags, and their output is then processed by the Mustache engine which renders it.

One can for instance write a lambda that turns `{{#link}}{{name}}{{/link}}` into `<a href="{{url}}">{{name}}</a>`, which is later rendered as `<a href="/stuff/1">blah</a>`.

However, lambdas do not have access to the *view model* level. They can not, for instance, render the uppercase version of a value.

Precisely: should a lambda evaluate the inner rendering of a section, turn it into uppercase, and provide the result to the Mustache engine, there is the possibility that the view model data would contain mustache tags that would be then processed by the Mustache engine. An application user could "attack" the rendering engine by setting his name to `{{pwned}}`, for instance.

### The consequences of a drastic interpretation of "logiclessness"

The inability for library user's to provide code that operates on the view model level has until now be considered positive and "pure", because of the "logiclessness" of Mustache. Yes, there is no logic code in the template itself, no "if", no "while", no "==" , no "<", etc.

However, the interpretation of "logiclessness" becomes uselessly drastic, and painful to the library user when the view model is made 100% responsible for the rendering of value tags and the control of section tags. The problem arises at the the *view model preparation phase*, when the library user has to prepare all the values that will be interpreted by the Mustache engine. The preparation phase becomes a chore when the user has to process many values in the same way.

For instance, a model may hold a dozen named numerical values, that should be rendered in a formatted way. It thus has to be turned into a view model holding a dozen named formatted values, with the necessity of duplicated code.

Another chore is processing model arrays so that the view model contains arrays whose items know about their index in the array. Again, if many model arrays should be processed this way, we again have a duplicated code problem.

Some would say: "use your language features, and dynamically add the needed properties to your objects". This argument is invalid, because Mustache is a language-agnostic template language, and some host languages do not have dynamic features.

### Filters empower the library user, and Mustache itself

This is why Mustache should provide a way to let the library user provide code that processes the view model values before they enter the rendering engine, and express directly in the template how the view model values should be processed.

These code chunks would be called *filters*, because they are functions that take a mustache-interpretable value as an input, and return an other mustache-interpretable value. In the template itself, tags would contain *filtered expressions* that would tell the rendering engine which filters should be applied to the raw view model values.

Since the role of filters is to releive view models from providing "final" values, filters do not conceptually belong to them. They instead belong the template: for instance, a template would provide a filter for rendering uppercase values. Now all the view models are releived from the burden of computing those. Another template would provide a filter for rendering array indexes. View models would then provide raw arrays, and the template would be able to render item indexes.

Since filters belong to the templates, Mustache can provide a *standard library* of filters, that would be pre-baked into all Mustache templates.

Since filters are not tied to the view model, they are *reusable*. 


## 2. Why Mustache tags should contain expressions, not statements

### Composition

There are major differences between *expressions* and *statements*. Statements chain, one after the other, independently, and can not provide any value. Statements *perform* and return nothing. Expressions are a different kind of beast: by essence, they provide *values*, and can be *composed* from other expressions.

Obviously, Mustache needs values: substitution tags need a value that they can render, section tags need a value that they can test, loop, or make enter the context stack. Since only expressions provide with values, they are what Mustache need.

Mustache already has two kinds of expressions: keys and key paths. `name` is a key. `person.name` is a key path. Both expressions evaluate in a different manner. The key expression looks in the context stack for an object that would provide the "name" key. The key path expression looks in the context stack for an object that would provide the "person" key, and then extract the "name" key right from this person. The latter behavior is called a "scoped lookup".

Let filters enter, and turn them into expressions:

Library users should be able to build filter expressions with other expressions. One should be able to filter `person.name` with the filter `uppercase`.

Composition goes further: library users should be able to perform a "scoped" lookup out of a filtered expression.

The latter point is important: there is no good reason to prevent the library user to perform a scoped lookup out of a filtered expression.

### Filtered variable and sections

Expressions as a way for the library user to build values that would be rendered by Mustache. Now those values are actually rendered as variables (substitution tags) tags, or sections.

The only argument so far I've read against filtered sections is: "I see no compelling use case that need this feature".

This argument fails for two reasons. First it only shows the lack of imagination of the one expressing it. Second, it artificially limits the empowerment of the library user, who deserves more respect. If Mustache allows the library user to inject code, there is no point nannying him and preventing him from injecting his code where he thinks it is relevant. This only makes Mustache painful to use, without any benefit for anybody.

Here is a nice section filter, for the unimaginative ones:

```js
with_index = function(array) {
    for (i=0; i<array.length; ++i) {
        var object = array[i];
        object.index = i;
        object.even = (i % 2 == 0);
        object.first = (i == 0);
        object.last = (i == array.length - 1);
    }
    return array;
};
```

Yes, this filters allows to render collections with the `index`, `even`, `first`, and `last` keys usable in the template.
