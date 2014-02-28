[up](../../../../GRMustache#documentation), [next](introduction.md)

Installation
============

Option 1: CocoaPods
-------------------

Append `pod 'GRMustache', '~> 6.9.2'` to your [Podfile](https://github.com/CocoaPods/CocoaPods).


Option 2: Static Library
------------------------

The distribution includes pre-built static libraries:

1. Clone the repository with the `git clone https://github.com/groue/GRMustache.git` command.

2. Embed GRMustache in your Xcode project:
    - For MacOS development, add `include/GRMustache.h` and `lib/libGRMustache6-MacOS.a` to your project.
    - For iOS development, add `include/GRMustache.h` and `lib/libGRMustache6-iOS.a` to your project.
    
    NB: If you have GRMustache files *copied* in your project, you'll need to copy all header files of the `include` directory, not only `GRMustache.h`.

3. Edit your target settings, and pass the `-ObjC` option in the "Other Linker Flags" ([how to](http://developer.apple.com/library/mac/#qa/qa1490/_index.html)).

The armv6 slice is not included. In order to target this architecture, you have to compile GRMustache yourself (see below), or to use CocoaPods (see above).

### Updating your static library

When pulling the `master` branch of GRMustache, you'll get the latest stable release. Should a new major version be shipped, you may pull incompatible changes. In order to prevent this, checkout and pull the `GRMustache6` branch:

    $ git clone https://github.com/groue/GRMustache.git
    $ cd GRMustache
    $ git checkout -b GRMustache6 origin/GRMustache6
    $ git pull  # checkout the latest version 6

Option 3: Compiling the raw sources
-----------------------------------

You may also embed the raw GRMustache sources in your project:

    $ git clone https://github.com/groue/GRMustache.git
    $ cd GRMustache
    $ git checkout v6.9.2  # checkout the latest stable release
    $ git submodule update --init src/vendor/groue/jrswizzle

Add all files of `src/classes` plus `src/vendor/groue/jrswizzle/JRSwizzle.*` to your project.

If your project uses ARC, flag the source files with the `-fno-objc-arc` compiler flag ([how to](http://stackoverflow.com/questions/6646052/how-can-i-disable-arc-for-a-single-file-in-a-project)).

In your own sources, avoid importing header files whose name ends with `_private.h`: those are private headers that may change, without notice, in future releases.


[up](../../../../GRMustache#documentation), [next](introduction.md)
