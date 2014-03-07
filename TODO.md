## TODO

- [ ] Remove all GRMustacheContext subclassing documentation
- [ ] Document secure key access to Foundation classes
- [ ] Document the drop of context in context support
- [X] Add GRMustacheContext.allowsAllKeys
- [ ] Rename validMustacheKeys to allowedMustacheKeys or something like that. Be consistent with GRMustacheContext.allowsAllKeys
- [ ] Rename "protected context" to something that rings a bell. "Protected keys"? "Locked keys"? "Priority keys"?
- [-] Tests for secure key access
- [X] change version method
- [X] have overridable section use their own identifiers, not expressions.
- [X] Fetch inspiration from "faster mutable strings" in fotonauts/handlebars-objc (https://github.com/fotonauts/handlebars-objc/commit/f2cbde7e12b1fb594c2807a57bd2ecd2adb839b4)
    - [X] for escaping methods
    - [X] for rendering buffers
- [X] Remove GRMustacheContext subclasses.
- [X] safe property access (https://github.com/fotonauts/handlebars-objc/blob/master/doc/ContextObjects.md#why-does-handlebars-limit-access-to-some-attributes-that-are-normally-accessible-using-key-value-coding)
- [ ] examine dependencies using https://github.com/nst/objc_dep $ python objc_dep.py -x "(GRMustacheAvailabilityMacros)" ~/Documents/git/groue/GRMustache/src/classes/ > ~/Desktop/GRMustacheDeps.dot

## Nice to have

- [ ] document migration path from all previous versions to latest version
- [ ] > But they do allow Xcode to see the symbols when creating the final executable and allow the static library symbols to get included in the final DSYM file thereby allowing full symoblication of crash reports. (https://github.com/RestKit/RestKit/issues/1277)

## Experiments

- [ ] {{.}}, {{..}}, {{...}}, {{.name}}, {{..name}}, {{...name}}, {{ROOT}}, {{ROOT.name}}
- [ ] Have filters put something in the scope: in `{{ dateFormat(date, ISO_8601) }}`, ISO_8601 would be defined by the dateFormat filter.
- [ ] date/time formatter: `{{ dateFormat(date, Short) }}`, `{{ timeFormat(date, Short) }}`, `{{ dateTimeFormat(date, Short, Full) }}`
