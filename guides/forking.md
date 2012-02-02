[up](../../..)

# Note on forking

After you have forked groue/GRMustache, you might want to change stuff, test, and then build the library.

You'll find below some useful information on each of those topics.

## Change GRMustache

There are two projects: one for MacOS, and one for iOS: `GRMustache1-macosx.xcodeproj` and `GRMustache1-ios.xcodeproj`. When XCode allows for multi-platform projects, there will be a single one :-) (addendum: it looks like XCode 4.2 allows for that, stay tuned).

Objective-C files that make GRMustache are stored in the `Classes` folder.

When a file is added or removed from the `Classes` folder, both projects are updated.

When a header file is added to the `Classes` folder, the "Copy headers" build phase of the three targets (one for the MacOS project, two for the iOS project) are updated accordingly. The set of public headers of all three targets are the same.

Headers are splitted in two categories:

- public headers
- private headers

### Public headers

Public headers must contain only declarations for APIs that are exposed to the GRMustache users. They must not import or include any private header.

Methods and functions declared in public headers must be decorated with the macros defined in `Classes/GRMustacheAvailabilityMacros.h`. Check existing public headers for inspiration.

### Private headers

Private headers have names ending in `_private.h`. They must not import or include any public header. The set of public APIs must be duplicated in both public and private headers.

## Test GRMustache

There are two kinds of tests, all stored in the `Tests` folder.

- tests of private APIs
- tests of public APIs

When a file is added or removed from the `Tests` folder, both `GRMustache1-macosx.xcodeproj` and `GRMustache1-ios.xcodeproj` projects are updated.

### Tests of private APIs

Tests of private internals are stored in the `Tests/Private` folder, and are all subclasses of `GRMustachePrivateAPITest`.

The implementation files of those tests must not include any public header.

### Tests of public APIS

Tests of public GRMustache API are versionned: the `Tests/v1.0` folder contains tests for features introduced in the version 1.0 of the library. `Tests/v1.1` contains tests for the version 1.1, etc.

Those tests are all subclasses of `GRMustachePublicAPITest`. Their implementation files must not include any private header.

You will use the macros defined in `Classes/GRMustacheAvailabilityMacros.h`. They help the tests acheiving three goals:

- use only APIs that are available in the GRMustache version they test against,
- emit deprecation warning when they use deprecated GRMustache APIs,
- help GRMustache achieve the full backward compatibility claimed by the [APR](http://apr.apache.org/versioning.html) compliance.

For instance, all header files for public API tests in `Tests/v1.4` begin with:

    #define GRMUSTACHE_VERSION_MIN_REQUIRED GRMUSTACHE_VERSION_1_4
    #define GRMUSTACHE_VERSION_MAX_REQUIRED GRMUSTACHE_VERSION_1_4
    #import "GRMustachePublicAPITest.h"

When you add a test for a specific behavior of a public API, make sure you place it in the version that introduced this behavior (check the release notes).

## Building

The GRMustache "product" itself is made of both the `lib` and `include` folders.

The XCode GUI can not build them. Instead, you'll issue the following command in the terminal:

    $ make clean && make

[up](../../..)
