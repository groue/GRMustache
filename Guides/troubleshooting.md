GRMustache Troubleshooting
==========================

- **GRMustache does not render my object keys.**

    Check that you have declared Objective-C properties (with `@property`) for those keys.
    
    For security reasons, GRMustache, starting v7.0, does not blindly run the `valueForKey:` method when accessing keys. Check the [Runtime](Guides/runtime.md#key-access) and the [Security](Guides/security.md#safe-key-access) Guides for more information.

- **I get "unrecognized selector sent to instance" errors.**
    
    Check that you have added the `-ObjC` option in the "Other Linker Flags" of your target ([how to](http://developer.apple.com/library/mac/#qa/qa1490/_index.html)).
