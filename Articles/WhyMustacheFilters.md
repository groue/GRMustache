# Mustache support for "Filters"

Here are a few arguments for the introduction of "filters" in Mustache, and a description of what they should be, as a contribution to the [open discussion](http://github.com/mustache/spec/issues/41) on the mustache/spec repository.

GRMustache provides an implementation of [filters](../Guides/filters.md) that fully cover all the points described here.

1. Why filters are good for Mustache
2. Why Mustache tags should contain expressions, not statements
3. Parsing GRMustache expressions
4. The details

## 1. Why filters are good for Mustache

### History of user-provided code: lambdas

Mustache users today have a single way to have their own code executed while rendering a template: "Mustache lambdas".

Lambdas operate at the *template canvas* level: they can alter raw portions of a template, insert and process raw text, add and remove mustache tags, and their output is then processed by the Mustache engine which renders it.

One can for instance write a lambda that turns `{{#link}}{{name}}{{/link}}` into `<a href="{{url}}">{{name}}</a>`, which is later rendered as `<a href="/stuff/1">blah</a>`.

However, lambdas do not have access to the *view model* level. They can not, for instance, render the uppercase version of a value.

> Precisely: should a lambda evaluate the inner rendering of a section, turn it into uppercase, and provide the result to the Mustache engine, there is the possibility that the view model data would contain mustache tags that would be then processed by the Mustache engine. An application user could "attack" the rendering engine by setting his name to `{{pwned}}`, for instance.

### The consequences of a drastic interpretation of "logiclessness"

The inability for library user's to provide code that operates on the view model level has until now be considered positive and "pure", because of the "logiclessness" of Mustache. Yes, there is no logic code in the template itself, no "if", no "while", no operators, etc. Actually, there is no code at all in a Mustache template.

However, the interpretation of "logiclessness" becomes uselessly drastic, and painful to the library user when the view model is made 100% responsible for the rendering of value tags and the control of section tags. The problem arises at the the *view model preparation phase*, when the library user has to prepare all the values that will be interpreted by the Mustache engine. The preparation phase becomes a chore when the user has to process many values in the same way.

For instance, a model may hold a dozen named numerical values, that should be rendered in a formatted way. It thus has to be turned into a view model holding a dozen named formatted values, with the necessity of duplicated code. I, as a Mustache implementor, have received many feature requests on this topic. There is more evidence that this is a recurrent issue with Mustache at: [mustache/spec/issues/41](https://github.com/mustache/spec/issues/41) and [bobthecow/mustache.php/pull/102](https://github.com/bobthecow/mustache.php/pull/102).

Another common chore is preparing the input in order to test if a collection is empty or not. See [mustache/spec/issues/23](https://github.com/mustache/spec/pull/23), and [defunkt/mustache/issues/4](https://github.com/defunkt/mustache/issues/4).

Another chore is processing model arrays so that the view model contains arrays whose items know about their index in the array. Again, if many model arrays should be processed this way, we again have a duplicated code problem. Evidence can be found at [janl/mustache.js/pull/205](https://github.com/janl/mustache.js/pull/205), [groue/GRMustache/issues/14](https://github.com/groue/GRMustache/issues/14), [groue/GRMustache/issues/18](https://github.com/groue/GRMustache/issues/18), and the language extension implemented by [samskivert/jmustache](https://github.com/samskivert/jmustache) and [christophercotton/GRMustache](https://github.com/christophercotton/GRMustache).

Some would say: "use your language features, and dynamically add the needed properties to your objects". This argument is invalid for many reasons, and primarily because Mustache is a language-agnostic template language, and some host languages do not sport any dynamic features.

Some readers might be interested by a [more general rebuttal of the drastic interpretation of Mustache "logiclessness"](TheNatureOfLogicLessTemplates.md).

### Filters empower the library user, and Mustache itself

This is why Mustache should provide a way to let the library user provide code that processes the view model values before they enter the rendering engine, and express directly in the template how the view model values should be processed.

These code chunks would be called *filters*, because they are functions that take a mustache-interpretable value as an input, and return an other mustache-interpretable value. In the template itself, tags would contain *filtered expressions* that would tell the rendering engine which filters should be applied to the raw view model values.

Since the role of filters is to relieve view models from providing "final" values, filters do not conceptually belong to them. They instead belong the template: for instance, a template would provide a filter for rendering uppercase values. Now all the view models are relieved from the burden of computing those. Another template would provide a filter for rendering array indexes. View models would then provide raw arrays, and the template would be able to render item indexes. (For real examples, check [number formatting](../Guides/sample_code/number_formatting.md) and [indexes](../Guides/sample_code/indexes.md) sample code).

Since filters belong to the templates, Mustache can provide a *standard library* of filters, that would be pre-baked into all Mustache templates.

Since filters are not tied to the view model, they are *reusable*. 


## 2. Why Mustache tags should contain expressions, not statements

### Composition

There are major differences between *expressions* and *statements*. Statements chain, one after the other, independently, and can not provide any value. Statements *perform* and return nothing. Expressions are a different kind of beast: by essence, they provide *values*, and can be *composed* from other expressions.

Obviously, Mustache needs values: variable tags need a value that they can render, section tags need a value that they can test, loop, or make enter the context stack. Since only expressions provide with values, they are what Mustache need.

Mustache already has two kinds of expressions: keys and key paths. `name` is a key. `person.name` is a key path. Both expressions evaluate in a different manner. The key expression looks in the context stack for an object that would provide the "name" key. The key path expression looks in the context stack for an object that would provide the "person" key, and then extract the "name" key right from this person. The latter behavior is called a "scoped lookup".

Let filters enter, and turn them into expressions:

Library users should be able to build filter expressions with other expressions. One should be able to filter `person.name` with the filter `uppercase`.

Composition goes further: library users should be able to perform a "scoped" lookup out of a filtered expression.

The latter point is important: there is no good reason to prevent the library user to perform a scoped lookup out of a filtered expression.

### A syntax that fulfills those properties

GRMustache implements filters with a good old function call syntax: `f(x)`.

Just like `x`, `f(x)` is an expression that has a value. The GRMustache expression syntax let the user write `f(*)` and `*(x)` anywhere he can write `*`:

- One can render `{{ f(x) }}` instead of `{{ x }}`.
- One can render `{{ f(x.y) }}` instead of `{{ x.y }}`.
- One can render `{{ f(g(x)) }}` instead of `{{ g(x) }}`.
- One can render `{{ f(x)(y) }}` instead of `{{ f(x) }}` (`f` is a meta-filter: a filter that returns a filter).

This fits pretty well with the "scoped" Mustache expression: the regular Mustache syntax lets the user write `*.y` anywhere he can write `*`:

- One can render `{{ x.y }}` instead of `{{ x }}`.
- One can render `{{ f(x).y }}` instead of `{{ f(x) }}`.
- One can render `{{ f.g(x) }}` instead of `{{ f(x) }}`.

A contrieved user could write `{{a.b(c.d(e.f).g.h).i.j(k.l)}}`. Whether this is sane or not is not the business of a library that embraces userland code.

Last point: white space is irrelevant. `f(x)` is the same as `f ( x )`.

You'll find below a grammar and a state machine that implement the parsing of those expressions.

### A syntax that does not fullfill those properties

The only other syntax that I'm aware of is the one of bobthecow's [mustache.php](https://github.com/bobthecow/mustache.php/pull/102), which is not yet merged in the released branch of his library.

    {{ created_at | date.iso8601 }}

Pipes have great ascendants (unix shell, Liquid filters), and this syntax sports a genuine relevance for its purpose. Pipable unix commands such as sort, uniq, etc. have a great deal in common with template filters.

However, it fails on the composition part, since pipes build *statements*, not expressions.

For example, how would pipes handle cases like `f(x).y` without the introduction of parenthesis in a fashion that is not common to pipes?

    {{ (x | f).y }}         vs.    {{ f(x).y }}
    {{ (x | f).y | g }}     vs.    {{ g(f(x).y) }}

More, how would pipes handle meta-filters like `f(x)(y)` ?

    {{ y | (x | f) }}       vs.    {{ f(x)(y) }}

The `f(x)` notation has here an advantage, which is its pervasiveness if many widely adopted languages that also use the dot as a property accessor.


### Filters can't load from the "implicit iterator"

We've said above that filters should not come from the view model provided by the user, but instead be tied to a template. This allows a template to provide filters as services, including a standard library of filters.

As a consequence, the `.(x)` syntax is forbidden. In Mustache, `.` aka the "implicit iterator", represents the currently rendered object from the view model. It thus can not provide any filter. Identically, the `.a(x)` syntax is invalid as well (it would mean "perform a scoped lookup for `a` in the view model, and apply the result as a filter").


## 3. Parsing GRMustache expressions

Here is a state machine that describes GRMustache expressions. It reads one character
after the other, until it reaches the *VALID*, *EMPTY*, or *INVALID* state:

    # ID stands for "identifier character"
    # WS stands for "white space character"
    # EOF stands for "end of input"
    # All non explicited transitions end up in the INVALID state.
    -> parenthesisLevel=0, INITIAL
    INITIAL -> WS -> INITIAL
    INITIAL -> ID -> scopable=YES, IDENTIFIER
    INITIAL -> '.' -> scopable=NO, LEADING_DOT
    INITIAL && parenthesisLevel==0 -> EOF -> EMPTY
    LEADING_DOT -> WS -> IDENTIFIER_DONE
    LEADING_DOT -> ID -> IDENTIFIER
    LEADING_DOT && parenthesisLevel>0 -> ')' -> --parenthesisLevel, FILTER_DONE
    LEADING_DOT && parenthesisLevel==0 -> EOF -> VALID
    IDENTIFIER -> WS -> IDENTIFIER_DONE
    IDENTIFIER -> ID -> IDENTIFIER
    IDENTIFIER -> '.' -> WAITING_FOR_IDENTIFIER
    IDENTIFIER && scopable -> '(' -> ++parenthesisLevel, INITIAL
    IDENTIFIER && parenthesisLevel>0 -> ')' -> --parenthesisLevel, FILTER_DONE
    IDENTIFIER && parenthesisLevel==0 -> EOF -> VALID
    WAITING_FOR_IDENTIFIER -> ID -> IDENTIFIER
    IDENTIFIER_DONE -> WS -> IDENTIFIER_DONE
    IDENTIFIER_DONE && scopable -> '(' -> ++parenthesisLevel, INITIAL
    IDENTIFIER_DONE && parenthesisLevel==0 -> EOF -> VALID
    FILTER_DONE -> WS -> FILTER_DONE
    FILTER_DONE -> '.' -> WAITING_FOR_IDENTIFIER
    FILTER_DONE -> '(' -> ++parenthesisLevel, INITIAL
    FILTER_DONE && parenthesisLevel>0 -> ')' -> --parenthesisLevel, FILTER_DONE
    FILTER_DONE && parenthesisLevel==0 -> EOF -> VALID


## 4. The details

### Filtered variables, filtered sections

Expressions as a way for the library user to build values that would be rendered by Mustache. Now those values are actually rendered by variable tags, or section tags.

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

Yes, this filters allows to render collections with the `index`, `even`, `first`, and `last` keys usable in the template, as requested by at least five github issues (the ones linked above).

### Empty closing section tags

Mustache sections are implemented by a pair of symetric tags: `{{#name}}...{{/name}}`, and `{{^name}}...{{/name}}`.

When we introduce filters, this symetry becomes quite verbose: `{{^ isEmpty(people) }}...{{/ isEmpty(people) }}`. Although this point is not required, GRMustache allows for empty closing tags: `{{^ isEmpty(people) }}...{{/}}`

### Missing or invalid filters

In order to perform, filters must be fetched by name, as written in the template, and apply to a value. Both operations may fail.

The failure must not be silent, returning nil/null/undefined. This would prevent debugging, and mislead chained filters such as `f(g(x))` in unpredictable (presumably hilarious) ways.

GRMustache raises an exception in those cases.

### Filter namespaces

Just as Mustache users can extract a value with a scoped expression as `person.pet.name`, filters should be addressable in the same way.

This would allow the definition of filter namespaces, so that the user can define `math.abs`, `javascript.escape`, or load a third-party filter library that would not clash with his own filters.
