[up](../../../../GRMustache#documentation), [next](../../../tree/master/Guides/sample_code)

GRMustacheProxy class
=====================

When thrown in the Mustache rendering engine, GRMustacheProxy instances have the same behavior as another object, named their "delegate":

Mustache variable tags and section tags, `{{name}}`, `{{#name}}`, and `{{^name}}` render *exactly* the same whenever the `name` key resolves to an object or to a proxy whose delegate is that object.

You will generally subclass the GRMustacheProxy class in order to extend the abilities of the delegate.

For instance, you may define some extra keys: the `valueForKey:` implementation of GRMustacheProxy looks for custom keys in the proxy before forwarding the lookup in the delegate object. This is the technique used by the PositionFilter filter in the [indexes sample code](sample_code/indexes.md).

GRMustacheProxies provides two initialization methods: `initWithDelegate:`, and `init`. The `initWithDelegate:` sets the delegate of the proxy, which is from now on ready to use. The `init` method does not set the delegate: you will generally provide your own implementation of the `loadDelegate` method, whose responsability is to lazily set the delegate of the proxy.


Usage of proxies
----------------

Proxies are a reliable way to extend objects abilities. As such, they are a tool for the developer who wants to write reusable and robust filters or helpers.

Don't miss the [indexes sample code](sample_code/indexes.md), that demonstrates a typical use of proxies.


Proxies behavior in detail
--------------------------

Generally speaking, the methods of the delegate of a proxy are invoked if and only if the proxy does not provide its own implementation. This extends to the `valueForKey:` behavior as well: delegate values are returned if and only if the proxy does not provide any.

GRMustacheProxy makes a heavy usage of Objective-C runtime APIs in order to behave just as its delegate, while allowing extra behaviors. Its implementation is based on [Apple's documentation of "Message forwarding"](https://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtForwarding.html).

For instance, `GRMustacheProxy` overrides `isKindOfClass:`, `conformsToProtocol:`, etc.

The only known gotcha so far is about proxies whose delegate is `[NSNull null]`. They behave just as `[NSNull null]`, but can not be compared to it with the `==` equality operator. You should write `[object isKindOfClass:[NSNull class]]` whenever there is a possibility for your code to interact with a proxy wrapping NSNull.


[up](../../../../GRMustache#documentation), [next](../../../tree/master/Guides/sample_code)
