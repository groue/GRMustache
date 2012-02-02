[up](../README.md), [next](templates.md)

Embedding GRMustache in your XCode project
==========================================

**TL;DR** Choose a static library in the `/lib` folder, and import the `/include/GRMustache.h` header.

---

GRMustache ships as a static library and a header file, and only depends on the Foundation.framework.

The `GRMustache.h` header file is located into the `/include` folder at the root of the GRMustache repository. Add it to your project.

You'll have next to choose a static library among those located in the `/lib` folder:

- `libGRMustache1-ios3.a`
- `libGRMustache1-ios4.a`
- `libGRMustache1-macosx10.6.a`

`libGRMustache1-ios3.a` targets iOS3+, and include both device and simulator architectures (i386 armv6 armv7). This single static library allows you to run GRMustache on both simulator and iOS devices.

`libGRMustache1-ios4.a` targets iOS4+, and include both device and simulator architectures (i386 armv6 armv7). On top of all the APIs provided by `libGRMustache1-ios3.a`, you'll find blocks and NSURL* APIs in this version of the lib.

`libGRMustache1-macosx10.6.a` targets MaxOSX 10.6+. It includes both 32 and 64 bits architectures (i386 x86_64), and the full set of GRMustache APIs.

Other headers
-------------

Generally, importing the `GRMustache.h` header provides you with all the core GRMustache features.

However, you will have to explicitely import:

- `GRMustacheTemplateLoader_protected.h`
    
    when you want to subclass `GRMustacheTemplateLoader`, and provide your own template loading strategy. See [guides/template_loaders.md](template_loaders.md)

- `GRMustacheNumberFormatterHelper.h` and `GRMustacheDateFormatterHelper.h`
    
    when you want to use these helpers in order to format your numbers and dates. See [guides/number_formatting.md](number_formatting.md) and [guides/date_formatting.md](date_formatting.md)

[up](../README.md), [next](templates.md)
