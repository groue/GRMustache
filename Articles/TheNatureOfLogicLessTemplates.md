# The nature of logicless templates

[@pvande](https://github.com/pvande) [wonders](https://github.com/mustache/spec/wiki/%5BDiscussion%5D-Logic-Free-vs.-Non-Evaled) what is the difference between the "Logic Free" templates such as [Mustache](http://mustache.github.io) and the "Non-Evaled" templates like [Liquid](http://liquidmarkup.org).

He enumerates different properties of both kinds of templates, and feels perplexed when wondering what are the fundamental properties he should be the guardian of, as the maintainer of the [Mustache Specification](http://github.com/mustache/spec).

My opinion on the subject is that he has been misled by an artificial distinction created by names such as "Logic-Free" and "Non-Evaled", which are actual synonyms for "codeless".

## "Get the code out of the view!"

We have seen MVC emerging as a powerful pattern to code desktop, mobile and web applications. It became quickly clear that template engines were the weak link in this nice building. Most of them used to allow the coder to embed raw code right into his views. and raw code means any code, including code that should not lie in a view component. And while embedding code has more and more been considered as a quick and dirty practice, nothing would prevent the coder to do so, because the template engines were explicitely allowing it.

For some people, allowing bad practices is the same as advocating it. The need for strict and clean template engine that totally forbid the coder to embed code in his view was now imperious.

So came Mustache, Liquid, and others. All have this single common property: *they explicitely disallow embedding raw code*. Plus, add that those template engines are fundamentally language-agnostic (Mustache has achieved a [tremendous success](https://github.com/defunkt/mustache/wiki/Other-Mustache-implementations) here), and you know why those new template language have such a momentum these days.

## Logic and evaluation? They're right under the carpet

So, names. "Logic-Free". "Non-Evaled".

Is the logic totally banned? Of course not: template engines still provide a syntax for controlling the rendering of templates. But the control is a consequence of the values that are computed, and provided by the template user. The actual controlling code is in *userland*.

Is the evaluation totally banned? Of course not: template engines provide syntax for rendering values. But not all values can be rendered: only values that are available to the template, chosen by the template user. Those values come, again, from *userland*.

There we are now: in codeless languages, the code (there is always code) has been sent out to userland.


## There is no other important property

@pvande [enumerates](https://github.com/mustache/spec/wiki/%5BDiscussion%5D-Logic-Free-vs.-Non-Evaled) a few other properties for Liquid and Mustache. Let's see if they wouldn't be plain consequence of the fundamental "codeless" motto:

- promotes "safe" templating (Liquid + Mustache)

The idea is that a template can't crash the runtime it is rendered in. Since the library user can not run arbitrary code right from the template, this property looks like it is a direct consequence from the codelessness.

Actually, a template engine that would define its own Turing-complete language and provide a robust virtual machine could be very safe as well. Think PHP, for instance. Unfortunately, this is very difficult, and the "safe templating" argument of codeless languages could be rewritten as "easily-implemented safety". Anyway, as long as code from userland is executed, I don't know which kind of safety we're discussing here: eventually "safe templating" means "safety is not my problem". The Liquid team is rather honest here, claiming safety from *template editors*, and not claiming anything about the code written by *developpers* that gets executed by the templates.

- disallows execution of any code accessible from the data (Liquid)

Yet Liquid allows execution of filters. Filters whose code lies in userland. Check.

- permits execution of code accessible from the data stack (Mustache)

Yes, Mustache "lambda sections" contain code. In userland. Check.

- keeps executable code in a separate context (Liquid)

Check.

- allows basic literal types in templates as values (Liquid)
- encourages "procedural" templates and internal template state (e.g. via assign variables) (Liquid)
- discourages internal template state (Mustache)
has (should have?) no explicit order-dependency -- "declarative" templates (Mustache)

It looks like the Liquid designers, generally, needed some expressivity. Yet these points are irrelevant to the "Non-Evaled" claim of Liquid and "Logic-Less" claim of Mustache: I can't see any relationship between those interesting properties and these nice expressions.

So as the dedicated reader has noticed, "Logic Less" and "Non Evaled" are really just plain synonyms for "GTFCO", as Get The Filthy Code Out.


## The last @pvande's questions

> Open questions:
> 
> - Since Mustache has basic conditionals, what is the logic we're trying to avoid in templates?
>   - Database access?
>   - Data construction?
>   - Data manipulation?
>   - Arbitrary data manipulation?
>   - Predefined data manipulation?
> - Do filters fit in that worldview?
> - Do parameterized filters fit in that worldview?
> - Do data literals fit in that worldview?
> - Are there other significant differences between Logic-Free and Non-Evaling templates?

Keep relaxed. You're not trying to avoid anything. All the job has already been done when the code has been removed from the template.

Now it's time to empower your users, and to give them the tools and the expressivity they need.
