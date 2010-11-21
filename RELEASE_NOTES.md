GRMustache Release Notes
========================

## v1.1.3

Noticeable rendering performance improvement.

## v1.1.2

Noticeable compiling performance improvement.

## v1.1.1

Bug fixes around extented paths:

- ../.. should base the remaining path on the including context of the including context.
- A .. suite which rewinds too far should stop the evaluation and render an empty string.

## v1.1.0

New methods:

- `[GRYes yes]` responds to `boolValue`
- `[GRNo no]` responds to `boolValue`

## v1.0.0

First versioned release
