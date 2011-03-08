GRMustache Release Notes
========================

## v1.5.2

- The `DEBUG` macro has GRMustache raise much less NSUndefinedKeyException

## v1.5.1

- Memory bug fix

## v1.5.0

- New GRMustacheTemplate method:
	- `renderObjects:`
- New GRMustacheSection method:
	- `renderObjects:`
- New class:
	- `GRMustacheBlockHelper`
- Deprecated class:
	- `GRMustacheContext`
- Deprecated function:
	- `GRMustacheLambdaBlockMake`

## v1.4.0

- iOS 3.0 support
- New `GRMustacheTemplate` class methods:
	- `renderObject:fromContentsOfFile:error:`
	- `parseContentsOfFile:error:`
- New `GRMustacheTemplateLoader` class methods:
	- `templateLoaderWithBasePath:`
	- `templateLoaderWithBasePath:extension:`
	- `templateLoaderWithBasePath:extension:encoding:`

## v1.3.3

- Memory bug fix

## v1.3.2

- Bug fixes around extented paths

## v1.3.1

No more spurious deprecation warnings

## v1.3.0

Support for block-less Mustache lambdas.

- New classes:
	- `GRMustacheContext`
	- `GRMustacheSection`
- New functions:
	- `GRMustacheLambdaBlockMake`
- Deprecated functions:
	- `GRMustacheLambdaMake`

## v1.2.1

Useless release

## v1.2.0

- iOS 4.0 support
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
