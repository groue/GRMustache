GRMustache Release Notes
========================

## v1.2.1

- support for SDKs without blocks (MacOS before 10.6, and iOS before 4.0)

## v1.2.0

- iOS support
- Deprecated methods:
	- `[GRYes yes]`
	- `[GRNo no]`

## v1.1.6

- GRMustacheTemplateLoader subclasses can now rely on an immutable `extension` property.

## v1.1.5

- Memory management bug fixes

## v1.1.4

- No more warnings when compiling with LLVM 2.0

## v1.1.3

- Noticeable rendering performance improvement.

## v1.1.2

- Noticeable compiling performance improvement.

## v1.1.1

- Bug fixes around extented paths:
	- ../.. should base the remaining path on the including context of the including context.
	- A .. suite which rewinds too far should stop the evaluation and render an empty string.

## v1.1.0

- New methods:
	- `[GRYes yes]` responds to `boolValue`
	- `[GRNo no]` responds to `boolValue`

## v1.0.0

- First versioned release
