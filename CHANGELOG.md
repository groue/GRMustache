# Change Log

## [Unreleased](https://github.com/groue/GRMustache/tree/HEAD)

[Full Changelog](https://github.com/groue/GRMustache/compare/v7.3.0...HEAD)

**Fixed bugs:**

- NSNumber treated as context for rendering blocks [\#83](https://github.com/groue/GRMustache/issues/83)

- Conditional expression always returns true for tokens named the same as a filter [\#82](https://github.com/groue/GRMustache/issues/82)

**Closed issues:**

- Existing Project - Not Working [\#90](https://github.com/groue/GRMustache/issues/90)

- When supplying arguments to a variadic filter, the argument must be declared on the object. [\#88](https://github.com/groue/GRMustache/issues/88)

- Cannot resolve partials relative to localized templates in app bundle [\#87](https://github.com/groue/GRMustache/issues/87)

- Localize a variable key [\#85](https://github.com/groue/GRMustache/issues/85)

- appledoc crashes in initialize metthod in GRMustacheImplicitIteratorExpression.m [\#84](https://github.com/groue/GRMustache/issues/84)

- Retrieving NSAttributedString objects instead of NSString objects. [\#60](https://github.com/groue/GRMustache/issues/60)

**Merged pull requests:**

- wrong-demo.patch [\#89](https://github.com/groue/GRMustache/pull/89) ([leodie](https://github.com/leodie))

## [v7.3.0](https://github.com/groue/GRMustache/tree/v7.3.0) (2014-09-13)

[Full Changelog](https://github.com/groue/GRMustache/compare/v7.2.0...v7.3.0)

## [v7.2.0](https://github.com/groue/GRMustache/tree/v7.2.0) (2014-08-29)

[Full Changelog](https://github.com/groue/GRMustache/compare/v7.1.0...v7.2.0)

**Closed issues:**

- Render if condition is true [\#81](https://github.com/groue/GRMustache/issues/81)

## [v7.1.0](https://github.com/groue/GRMustache/tree/v7.1.0) (2014-08-15)

[Full Changelog](https://github.com/groue/GRMustache/compare/v7.0.2...v7.1.0)

**Closed issues:**

- Get element from array by index [\#80](https://github.com/groue/GRMustache/issues/80)

- Unchecked mallocs [\#79](https://github.com/groue/GRMustache/issues/79)

- Make template extension configurable [\#77](https://github.com/groue/GRMustache/issues/77)

**Merged pull requests:**

- Search for templates in a relative path [\#78](https://github.com/groue/GRMustache/pull/78) ([apauly](https://github.com/apauly))

- Fixed the return value type for renderContentWithContent [\#76](https://github.com/groue/GRMustache/pull/76) ([marcopifferi](https://github.com/marcopifferi))

- Added missing newlines to EOF in several public headers. [\#75](https://github.com/groue/GRMustache/pull/75) ([zygoat](https://github.com/zygoat))

## [v7.0.2](https://github.com/groue/GRMustache/tree/v7.0.2) (2014-03-25)

[Full Changelog](https://github.com/groue/GRMustache/compare/v7.0.1...v7.0.2)

## [v7.0.1](https://github.com/groue/GRMustache/tree/v7.0.1) (2014-03-22)

[Full Changelog](https://github.com/groue/GRMustache/compare/v7.0.0...v7.0.1)

## [v7.0.0](https://github.com/groue/GRMustache/tree/v7.0.0) (2014-03-15)

[Full Changelog](https://github.com/groue/GRMustache/compare/v6.9.2...v7.0.0)

**Fixed bugs:**

- Crash using NSObject's -valueForKey: IMP with collections on arm64 [\#70](https://github.com/groue/GRMustache/issues/70)

**Closed issues:**

- Computing a value out of several objects inside a template [\#73](https://github.com/groue/GRMustache/issues/73)

- +\[GRMustache version\] improperly overrides NSObject with different return type [\#71](https://github.com/groue/GRMustache/issues/71)

**Merged pull requests:**

- Removed warnings compiling with Xcode 5.1 [\#74](https://github.com/groue/GRMustache/pull/74) ([marcopifferi](https://github.com/marcopifferi))

## [v6.9.2](https://github.com/groue/GRMustache/tree/v6.9.2) (2014-02-28)

[Full Changelog](https://github.com/groue/GRMustache/compare/v6.9.1...v6.9.2)

**Closed issues:**

- Empty template returned [\#69](https://github.com/groue/GRMustache/issues/69)

- Fix Warnings [\#68](https://github.com/groue/GRMustache/issues/68)

- Avoidance of KV-Exceptions [\#66](https://github.com/groue/GRMustache/issues/66)

**Merged pull requests:**

- Build into include/GRMustache in the built products directory. [\#55](https://github.com/groue/GRMustache/pull/55) ([samdeane](https://github.com/samdeane))

## [v6.9.1](https://github.com/groue/GRMustache/tree/v6.9.1) (2014-02-03)

[Full Changelog](https://github.com/groue/GRMustache/compare/v6.9.0...v6.9.1)

**Merged pull requests:**

- GRMustacheRenderNSFastEnumeration fix crash handling rendering error [\#67](https://github.com/groue/GRMustache/pull/67) ([nolanw](https://github.com/nolanw))

## [v6.9.0](https://github.com/groue/GRMustache/tree/v6.9.0) (2014-01-27)

[Full Changelog](https://github.com/groue/GRMustache/compare/v6.8.4...v6.9.0)

**Closed issues:**

- Thread safety [\#65](https://github.com/groue/GRMustache/issues/65)

## [v6.8.4](https://github.com/groue/GRMustache/tree/v6.8.4) (2014-01-11)

[Full Changelog](https://github.com/groue/GRMustache/compare/v6.8.3...v6.8.4)

**Closed issues:**

- x86\_64 slice in static library [\#64](https://github.com/groue/GRMustache/issues/64)

## [v6.8.3](https://github.com/groue/GRMustache/tree/v6.8.3) (2013-10-19)

[Full Changelog](https://github.com/groue/GRMustache/compare/v6.8.2...v6.8.3)

**Closed issues:**

- Variable name with spaces [\#63](https://github.com/groue/GRMustache/issues/63)

- getting second parameter in a filter [\#62](https://github.com/groue/GRMustache/issues/62)

- leaving a space if number is null [\#61](https://github.com/groue/GRMustache/issues/61)

- Documentation lacks of precision in filter definition [\#59](https://github.com/groue/GRMustache/issues/59)

## [v6.8.2](https://github.com/groue/GRMustache/tree/v6.8.2) (2013-08-10)

[Full Changelog](https://github.com/groue/GRMustache/compare/v6.8.1...v6.8.2)

## [v6.8.1](https://github.com/groue/GRMustache/tree/v6.8.1) (2013-08-10)

[Full Changelog](https://github.com/groue/GRMustache/compare/v6.8.0...v6.8.1)

## [v6.8.0](https://github.com/groue/GRMustache/tree/v6.8.0) (2013-08-09)

[Full Changelog](https://github.com/groue/GRMustache/compare/v6.7.5...v6.8.0)

**Closed issues:**

- Extra 'is object' test required [\#58](https://github.com/groue/GRMustache/issues/58)

- use of word "template" as variable name and Objective-C++ files [\#57](https://github.com/groue/GRMustache/issues/57)

- How can you pass in a literal value from a template into to a filter? [\#37](https://github.com/groue/GRMustache/issues/37)

**Merged pull requests:**

- Filter literals [\#54](https://github.com/groue/GRMustache/pull/54) ([samdeane](https://github.com/samdeane))

## [v6.7.5](https://github.com/groue/GRMustache/tree/v6.7.5) (2013-07-16)

[Full Changelog](https://github.com/groue/GRMustache/compare/v6.7.4...v6.7.5)

**Fixed bugs:**

- Passing nil string to renderObject:fromString:error: causes EXC\_BAD\_ACCESS [\#56](https://github.com/groue/GRMustache/issues/56)

**Merged pull requests:**

- Ignore .DS\_Store [\#53](https://github.com/groue/GRMustache/pull/53) ([paulmelnikow](https://github.com/paulmelnikow))

## [v6.7.4](https://github.com/groue/GRMustache/tree/v6.7.4) (2013-06-14)

[Full Changelog](https://github.com/groue/GRMustache/compare/v6.7.3...v6.7.4)

**Merged pull requests:**

- Xcode 5 fixes [\#52](https://github.com/groue/GRMustache/pull/52) ([samdeane](https://github.com/samdeane))

## [v6.7.3](https://github.com/groue/GRMustache/tree/v6.7.3) (2013-06-02)

[Full Changelog](https://github.com/groue/GRMustache/compare/v6.7.2...v6.7.3)

**Fixed bugs:**

- Setting delimiters to the current delimiters causes error [\#38](https://github.com/groue/GRMustache/issues/38)

## [v6.7.2](https://github.com/groue/GRMustache/tree/v6.7.2) (2013-05-30)

[Full Changelog](https://github.com/groue/GRMustache/compare/v6.7.1...v6.7.2)

## [v6.7.1](https://github.com/groue/GRMustache/tree/v6.7.1) (2013-05-26)

[Full Changelog](https://github.com/groue/GRMustache/compare/v6.7.0...v6.7.1)

## [v6.7.0](https://github.com/groue/GRMustache/tree/v6.7.0) (2013-05-25)

[Full Changelog](https://github.com/groue/GRMustache/compare/v6.6.0...v6.7.0)

**Closed issues:**

- Migration to ARC [\#51](https://github.com/groue/GRMustache/issues/51)

## [v6.6.0](https://github.com/groue/GRMustache/tree/v6.6.0) (2013-05-20)

[Full Changelog](https://github.com/groue/GRMustache/compare/v6.5.1...v6.6.0)

## [v6.5.1](https://github.com/groue/GRMustache/tree/v6.5.1) (2013-05-19)

[Full Changelog](https://github.com/groue/GRMustache/compare/v6.5.0...v6.5.1)

## [v6.5.0](https://github.com/groue/GRMustache/tree/v6.5.0) (2013-05-18)

[Full Changelog](https://github.com/groue/GRMustache/compare/v6.5...v6.5.0)

## [v6.5](https://github.com/groue/GRMustache/tree/v6.5) (2013-05-18)

[Full Changelog](https://github.com/groue/GRMustache/compare/v6.4.1...v6.5)

**Closed issues:**

- Pluralizing/singularizing strings? [\#50](https://github.com/groue/GRMustache/issues/50)

- Localization with variable not working [\#49](https://github.com/groue/GRMustache/issues/49)

## [v6.4.1](https://github.com/groue/GRMustache/tree/v6.4.1) (2013-03-02)

[Full Changelog](https://github.com/groue/GRMustache/compare/v6.4.0...v6.4.1)

**Closed issues:**

- Query template for delimited value [\#47](https://github.com/groue/GRMustache/issues/47)

**Merged pull requests:**

- Added missing @autoreleasepool to +load method. [\#48](https://github.com/groue/GRMustache/pull/48) ([oleganza](https://github.com/oleganza))

## [v6.4.0](https://github.com/groue/GRMustache/tree/v6.4.0) (2013-02-14)

[Full Changelog](https://github.com/groue/GRMustache/compare/v6.3.0...v6.4.0)

## [v6.3.0](https://github.com/groue/GRMustache/tree/v6.3.0) (2013-01-30)

[Full Changelog](https://github.com/groue/GRMustache/compare/v6.2.0...v6.3.0)

**Closed issues:**

- Escape query [\#42](https://github.com/groue/GRMustache/issues/42)

**Merged pull requests:**

- Updated GRMustachio demo app to include Content Type popup menu [\#44](https://github.com/groue/GRMustache/pull/44) ([mugginsoft](https://github.com/mugginsoft))

- Update Guides/compatibility.md [\#43](https://github.com/groue/GRMustache/pull/43) ([oleganza](https://github.com/oleganza))

## [v6.2.0](https://github.com/groue/GRMustache/tree/v6.2.0) (2013-01-27)

[Full Changelog](https://github.com/groue/GRMustache/compare/v6.1.4...v6.2.0)

## [v6.1.4](https://github.com/groue/GRMustache/tree/v6.1.4) (2013-01-12)

[Full Changelog](https://github.com/groue/GRMustache/compare/v6.1.3...v6.1.4)

**Closed issues:**

- Garbage Collection support [\#40](https://github.com/groue/GRMustache/issues/40)

- Build and install isn't quite as described, here's what I did. [\#39](https://github.com/groue/GRMustache/issues/39)

- Problem with IMG [\#36](https://github.com/groue/GRMustache/issues/36)

- Page not found 404 [\#35](https://github.com/groue/GRMustache/issues/35)

- Issues with GRMustacheTagDelegate [\#34](https://github.com/groue/GRMustache/issues/34)

**Merged pull requests:**

- GC support and test targets [\#41](https://github.com/groue/GRMustache/pull/41) ([mugginsoft](https://github.com/mugginsoft))

## [v6.1.3](https://github.com/groue/GRMustache/tree/v6.1.3) (2012-11-28)

[Full Changelog](https://github.com/groue/GRMustache/compare/v6.1.2...v6.1.3)

**Closed issues:**

- iOS 4.2.1 crash [\#5](https://github.com/groue/GRMustache/issues/5)

**Merged pull requests:**

- typo fix [\#33](https://github.com/groue/GRMustache/pull/33) ([oleganza](https://github.com/oleganza))

- Added popular apps using GRMustache [\#32](https://github.com/groue/GRMustache/pull/32) ([oleganza](https://github.com/oleganza))

## [v6.1.2](https://github.com/groue/GRMustache/tree/v6.1.2) (2012-11-23)

[Full Changelog](https://github.com/groue/GRMustache/compare/v6.1.1...v6.1.2)

**Merged pull requests:**

- Fixed typo in Filters Guide [\#31](https://github.com/groue/GRMustache/pull/31) ([oleganza](https://github.com/oleganza))

## [v6.1.1](https://github.com/groue/GRMustache/tree/v6.1.1) (2012-11-19)

[Full Changelog](https://github.com/groue/GRMustache/compare/v6.1.0...v6.1.1)

**Closed issues:**

- Add 'set delimiter' functionality for {{{html\_safe\_tags}}} [\#30](https://github.com/groue/GRMustache/issues/30)

**Merged pull requests:**

- Suggestion to add as update-able submodule vs clon [\#29](https://github.com/groue/GRMustache/pull/29) ([devinrhode2](https://github.com/devinrhode2))

## [v6.1.0](https://github.com/groue/GRMustache/tree/v6.1.0) (2012-11-02)

[Full Changelog](https://github.com/groue/GRMustache/compare/v6.0.1...v6.1.0)

## [v6.0.1](https://github.com/groue/GRMustache/tree/v6.0.1) (2012-11-01)

[Full Changelog](https://github.com/groue/GRMustache/compare/v6.0.0...v6.0.1)

## [v6.0.0](https://github.com/groue/GRMustache/tree/v6.0.0) (2012-10-30)

[Full Changelog](https://github.com/groue/GRMustache/compare/v5.5.2...v6.0.0)

## [v5.5.2](https://github.com/groue/GRMustache/tree/v5.5.2) (2012-10-22)

[Full Changelog](https://github.com/groue/GRMustache/compare/v5.5.1...v5.5.2)

## [v5.5.1](https://github.com/groue/GRMustache/tree/v5.5.1) (2012-10-21)

[Full Changelog](https://github.com/groue/GRMustache/compare/v5.5.0...v5.5.1)

## [v5.5.0](https://github.com/groue/GRMustache/tree/v5.5.0) (2012-10-20)

[Full Changelog](https://github.com/groue/GRMustache/compare/v5.4.4...v5.5.0)

**Closed issues:**

- Filters doesn't work on versions prior to 5.4.4 [\#28](https://github.com/groue/GRMustache/issues/28)

## [v5.4.4](https://github.com/groue/GRMustache/tree/v5.4.4) (2012-10-11)

[Full Changelog](https://github.com/groue/GRMustache/compare/v5.4.3...v5.4.4)

**Closed issues:**

- Error with Cocoapods for 5.4.3 [\#27](https://github.com/groue/GRMustache/issues/27)

## [v5.4.3](https://github.com/groue/GRMustache/tree/v5.4.3) (2012-10-02)

[Full Changelog](https://github.com/groue/GRMustache/compare/v5.4.2...v5.4.3)

## [v5.4.2](https://github.com/groue/GRMustache/tree/v5.4.2) (2012-09-29)

[Full Changelog](https://github.com/groue/GRMustache/compare/v5.4.1...v5.4.2)

## [v5.4.1](https://github.com/groue/GRMustache/tree/v5.4.1) (2012-09-29)

[Full Changelog](https://github.com/groue/GRMustache/compare/v5.4.0...v5.4.1)

## [v5.4.0](https://github.com/groue/GRMustache/tree/v5.4.0) (2012-09-28)

[Full Changelog](https://github.com/groue/GRMustache/compare/v5.2.0...v5.4.0)

## [v5.2.0](https://github.com/groue/GRMustache/tree/v5.2.0) (2012-09-23)

[Full Changelog](https://github.com/groue/GRMustache/compare/v5.1.0...v5.2.0)

## [v5.1.0](https://github.com/groue/GRMustache/tree/v5.1.0) (2012-09-22)

[Full Changelog](https://github.com/groue/GRMustache/compare/v5.0.1...v5.1.0)

## [v5.0.1](https://github.com/groue/GRMustache/tree/v5.0.1) (2012-09-15)

[Full Changelog](https://github.com/groue/GRMustache/compare/v5.0.0...v5.0.1)

**Merged pull requests:**

- support for iPhone5 \(armv7s\) + dropped support for armv6 because of Xcode 4.5 [\#26](https://github.com/groue/GRMustache/pull/26) ([oleganza](https://github.com/oleganza))

- support for iPhone5 \(armv7s\) + dropped support for armv6 because of Xcode 4.5 [\#25](https://github.com/groue/GRMustache/pull/25) ([oleganza](https://github.com/oleganza))

- Please pull support for armv7s \(also armv6 dropped because of Xcode 4.5\) [\#24](https://github.com/groue/GRMustache/pull/24) ([oleganza](https://github.com/oleganza))

## [v5.0.0](https://github.com/groue/GRMustache/tree/v5.0.0) (2012-09-13)

[Full Changelog](https://github.com/groue/GRMustache/compare/v4.3.4...v5.0.0)

## [v4.3.4](https://github.com/groue/GRMustache/tree/v4.3.4) (2012-09-06)

[Full Changelog](https://github.com/groue/GRMustache/compare/v4.3.3...v4.3.4)

**Closed issues:**

- File Reading Using Mustache [\#22](https://github.com/groue/GRMustache/issues/22)

**Merged pull requests:**

- Compatibility with older sdks [\#23](https://github.com/groue/GRMustache/pull/23) ([Bertrand](https://github.com/Bertrand))

## [v4.3.3](https://github.com/groue/GRMustache/tree/v4.3.3) (2012-08-30)

[Full Changelog](https://github.com/groue/GRMustache/compare/v4.3.2...v4.3.3)

**Fixed bugs:**

- Accessing NSArray count [\#21](https://github.com/groue/GRMustache/issues/21)

**Closed issues:**

- Device crash when linking from Xcode 4.1 [\#15](https://github.com/groue/GRMustache/issues/15)

## [v4.3.2](https://github.com/groue/GRMustache/tree/v4.3.2) (2012-08-06)

[Full Changelog](https://github.com/groue/GRMustache/compare/v4.3.1...v4.3.2)

## [v4.3.1](https://github.com/groue/GRMustache/tree/v4.3.1) (2012-08-05)

[Full Changelog](https://github.com/groue/GRMustache/compare/v4.3.0...v4.3.1)

## [v4.3.0](https://github.com/groue/GRMustache/tree/v4.3.0) (2012-08-04)

[Full Changelog](https://github.com/groue/GRMustache/compare/v4.2.0...v4.3.0)

## [v4.2.0](https://github.com/groue/GRMustache/tree/v4.2.0) (2012-07-27)

[Full Changelog](https://github.com/groue/GRMustache/compare/v4.1.1...v4.2.0)

## [v4.1.1](https://github.com/groue/GRMustache/tree/v4.1.1) (2012-07-01)

[Full Changelog](https://github.com/groue/GRMustache/compare/v4.1.0...v4.1.1)

## [v4.1.0](https://github.com/groue/GRMustache/tree/v4.1.0) (2012-06-30)

[Full Changelog](https://github.com/groue/GRMustache/compare/v4.0.0...v4.1.0)

**Closed issues:**

- Helpers as data formatters [\#20](https://github.com/groue/GRMustache/issues/20)

- prevent mustache from looking up the context stack? [\#19](https://github.com/groue/GRMustache/issues/19)

## [v4.0.0](https://github.com/groue/GRMustache/tree/v4.0.0) (2012-05-26)

[Full Changelog](https://github.com/groue/GRMustache/compare/v3.0.1...v4.0.0)

**Fixed bugs:**

- The library doesn't contain ARM6 slice. [\#17](https://github.com/groue/GRMustache/issues/17)

**Closed issues:**

- Implementing -first and -last and then multiple index counters in one loop iteration [\#18](https://github.com/groue/GRMustache/issues/18)

## [v3.0.1](https://github.com/groue/GRMustache/tree/v3.0.1) (2012-04-27)

[Full Changelog](https://github.com/groue/GRMustache/compare/v3.0.0...v3.0.1)

## [v3.0.0](https://github.com/groue/GRMustache/tree/v3.0.0) (2012-04-03)

[Full Changelog](https://github.com/groue/GRMustache/compare/v2.0.0...v3.0.0)

## [v2.0.0](https://github.com/groue/GRMustache/tree/v2.0.0) (2012-04-01)

[Full Changelog](https://github.com/groue/GRMustache/compare/v1.13.1...v2.0.0)

**Closed issues:**

- Installation: GRMustache.h vs. all the .h files in /include [\#16](https://github.com/groue/GRMustache/issues/16)

## [v1.13.1](https://github.com/groue/GRMustache/tree/v1.13.1) (2012-03-25)

[Full Changelog](https://github.com/groue/GRMustache/compare/v1.13.0...v1.13.1)

## [v1.13.0](https://github.com/groue/GRMustache/tree/v1.13.0) (2012-03-24)

[Full Changelog](https://github.com/groue/GRMustache/compare/v1.12.2...v1.13.0)

## [v1.12.2](https://github.com/groue/GRMustache/tree/v1.12.2) (2012-03-08)

[Full Changelog](https://github.com/groue/GRMustache/compare/v1.12.1...v1.12.2)

## [v1.12.1](https://github.com/groue/GRMustache/tree/v1.12.1) (2012-03-08)

[Full Changelog](https://github.com/groue/GRMustache/compare/v1.12.0...v1.12.1)

**Closed issues:**

- Render index in loop [\#14](https://github.com/groue/GRMustache/issues/14)

## [v1.12.0](https://github.com/groue/GRMustache/tree/v1.12.0) (2012-03-04)

[Full Changelog](https://github.com/groue/GRMustache/compare/v1.11.2...v1.12.0)

**Closed issues:**

- Crashes on OSX 10.7 [\#13](https://github.com/groue/GRMustache/issues/13)

## [v1.11.2](https://github.com/groue/GRMustache/tree/v1.11.2) (2012-02-25)

[Full Changelog](https://github.com/groue/GRMustache/compare/v1.11.1...v1.11.2)

**Closed issues:**

- document download procedure [\#12](https://github.com/groue/GRMustache/issues/12)

## [v1.11.1](https://github.com/groue/GRMustache/tree/v1.11.1) (2012-02-23)

[Full Changelog](https://github.com/groue/GRMustache/compare/v1.11.0...v1.11.1)

## [v1.11.0](https://github.com/groue/GRMustache/tree/v1.11.0) (2012-02-23)

[Full Changelog](https://github.com/groue/GRMustache/compare/v1.10.3...v1.11.0)

## [v1.10.3](https://github.com/groue/GRMustache/tree/v1.10.3) (2012-02-22)

[Full Changelog](https://github.com/groue/GRMustache/compare/v1.10.2...v1.10.3)

## [v1.10.2](https://github.com/groue/GRMustache/tree/v1.10.2) (2012-02-17)

[Full Changelog](https://github.com/groue/GRMustache/compare/v1.10.1...v1.10.2)

## [v1.10.1](https://github.com/groue/GRMustache/tree/v1.10.1) (2012-02-17)

[Full Changelog](https://github.com/groue/GRMustache/compare/v1.10.0...v1.10.1)

## [v1.10.0](https://github.com/groue/GRMustache/tree/v1.10.0) (2012-02-16)

[Full Changelog](https://github.com/groue/GRMustache/compare/v1.9.0...v1.10.0)

## [v1.9.0](https://github.com/groue/GRMustache/tree/v1.9.0) (2012-01-24)

[Full Changelog](https://github.com/groue/GRMustache/compare/v1.8.6...v1.9.0)

**Fixed bugs:**

- renderObjects: stopped working [\#11](https://github.com/groue/GRMustache/issues/11)

## [v1.8.6](https://github.com/groue/GRMustache/tree/v1.8.6) (2011-10-16)

[Full Changelog](https://github.com/groue/GRMustache/compare/v1.8.5...v1.8.6)

**Closed issues:**

- Build fail since commit 18dc85c5890852a596a5f5db9d3c813e98d2571b cause of missing GRMustacheContextStrategy reference [\#10](https://github.com/groue/GRMustache/issues/10)

## [v1.8.5](https://github.com/groue/GRMustache/tree/v1.8.5) (2011-10-14)

[Full Changelog](https://github.com/groue/GRMustache/compare/v1.8.4...v1.8.5)

**Fixed bugs:**

- Undefined symbols [\#9](https://github.com/groue/GRMustache/issues/9)

## [v1.8.4](https://github.com/groue/GRMustache/tree/v1.8.4) (2011-10-14)

[Full Changelog](https://github.com/groue/GRMustache/compare/v1.8.3...v1.8.4)

## [v1.8.3](https://github.com/groue/GRMustache/tree/v1.8.3) (2011-10-09)

[Full Changelog](https://github.com/groue/GRMustache/compare/v1.8.2...v1.8.3)

## [v1.8.2](https://github.com/groue/GRMustache/tree/v1.8.2) (2011-10-09)

[Full Changelog](https://github.com/groue/GRMustache/compare/v1.8.1...v1.8.2)

## [v1.8.1](https://github.com/groue/GRMustache/tree/v1.8.1) (2011-10-08)

[Full Changelog](https://github.com/groue/GRMustache/compare/v1.8.0...v1.8.1)

## [v1.8.0](https://github.com/groue/GRMustache/tree/v1.8.0) (2011-10-08)

[Full Changelog](https://github.com/groue/GRMustache/compare/v1.7.4...v1.8.0)

## [v1.7.4](https://github.com/groue/GRMustache/tree/v1.7.4) (2011-09-22)

[Full Changelog](https://github.com/groue/GRMustache/compare/v1.7.3...v1.7.4)

## [v1.7.3](https://github.com/groue/GRMustache/tree/v1.7.3) (2011-09-17)

[Full Changelog](https://github.com/groue/GRMustache/compare/v1.7.2...v1.7.3)

**Fixed bugs:**

- Over-released NSError in renderObject:fromContentsOfFile:error: [\#6](https://github.com/groue/GRMustache/issues/6)

**Merged pull requests:**

- Small language changes [\#8](https://github.com/groue/GRMustache/pull/8) ([oalders](https://github.com/oalders))

## [v1.7.2](https://github.com/groue/GRMustache/tree/v1.7.2) (2011-07-27)

[Full Changelog](https://github.com/groue/GRMustache/compare/v1.7.1...v1.7.2)

**Fixed bugs:**

- header files reference GRMustache\_context.h instead of GRMustacheContext.h [\#4](https://github.com/groue/GRMustache/issues/4)

**Merged pull requests:**

- Over-released NSError in renderObject:fromContentsOfFile:error: [\#7](https://github.com/groue/GRMustache/pull/7) ([pix0r](https://github.com/pix0r))

## [v1.7.1](https://github.com/groue/GRMustache/tree/v1.7.1) (2011-06-25)

[Full Changelog](https://github.com/groue/GRMustache/compare/v1.7.0...v1.7.1)

## [v1.7.0](https://github.com/groue/GRMustache/tree/v1.7.0) (2011-06-09)

[Full Changelog](https://github.com/groue/GRMustache/compare/v1.6.2...v1.7.0)

## [v1.6.2](https://github.com/groue/GRMustache/tree/v1.6.2) (2011-06-08)

[Full Changelog](https://github.com/groue/GRMustache/compare/v1.6.1...v1.6.2)

**Closed issues:**

- va\_list variant of variadic methods [\#3](https://github.com/groue/GRMustache/issues/3)

## [v1.6.1](https://github.com/groue/GRMustache/tree/v1.6.1) (2011-04-09)

[Full Changelog](https://github.com/groue/GRMustache/compare/v1.6.0...v1.6.1)

## [v1.6.0](https://github.com/groue/GRMustache/tree/v1.6.0) (2011-03-17)

[Full Changelog](https://github.com/groue/GRMustache/compare/v1.5.2...v1.6.0)

## [v1.5.2](https://github.com/groue/GRMustache/tree/v1.5.2) (2011-03-08)

[Full Changelog](https://github.com/groue/GRMustache/compare/v1.5.1...v1.5.2)

## [v1.5.1](https://github.com/groue/GRMustache/tree/v1.5.1) (2011-03-03)

[Full Changelog](https://github.com/groue/GRMustache/compare/v1.5.0...v1.5.1)

## [v1.5.0](https://github.com/groue/GRMustache/tree/v1.5.0) (2011-02-27)

[Full Changelog](https://github.com/groue/GRMustache/compare/v1.4.1...v1.5.0)

## [v1.4.1](https://github.com/groue/GRMustache/tree/v1.4.1) (2011-02-26)

[Full Changelog](https://github.com/groue/GRMustache/compare/v1.4.0...v1.4.1)

## [v1.4.0](https://github.com/groue/GRMustache/tree/v1.4.0) (2011-02-26)

[Full Changelog](https://github.com/groue/GRMustache/compare/v1.3.3...v1.4.0)

## [v1.3.3](https://github.com/groue/GRMustache/tree/v1.3.3) (2011-02-05)

[Full Changelog](https://github.com/groue/GRMustache/compare/v1.3.2...v1.3.3)

## [v1.3.2](https://github.com/groue/GRMustache/tree/v1.3.2) (2010-12-14)

[Full Changelog](https://github.com/groue/GRMustache/compare/v1.3.1...v1.3.2)

## [v1.3.1](https://github.com/groue/GRMustache/tree/v1.3.1) (2010-12-09)

[Full Changelog](https://github.com/groue/GRMustache/compare/v1.3.0...v1.3.1)

## [v1.3.0](https://github.com/groue/GRMustache/tree/v1.3.0) (2010-12-07)

[Full Changelog](https://github.com/groue/GRMustache/compare/v1.2.1...v1.3.0)

## [v1.2.1](https://github.com/groue/GRMustache/tree/v1.2.1) (2010-12-05)

[Full Changelog](https://github.com/groue/GRMustache/compare/v1.2.0...v1.2.1)

## [v1.2.0](https://github.com/groue/GRMustache/tree/v1.2.0) (2010-12-04)

[Full Changelog](https://github.com/groue/GRMustache/compare/v1.1.6...v1.2.0)

## [v1.1.6](https://github.com/groue/GRMustache/tree/v1.1.6) (2010-12-01)

[Full Changelog](https://github.com/groue/GRMustache/compare/v1.1.5...v1.1.6)

## [v1.1.5](https://github.com/groue/GRMustache/tree/v1.1.5) (2010-11-27)

[Full Changelog](https://github.com/groue/GRMustache/compare/v1.1.4...v1.1.5)

## [v1.1.4](https://github.com/groue/GRMustache/tree/v1.1.4) (2010-11-22)

[Full Changelog](https://github.com/groue/GRMustache/compare/v1.1.3...v1.1.4)

## [v1.1.3](https://github.com/groue/GRMustache/tree/v1.1.3) (2010-11-21)

[Full Changelog](https://github.com/groue/GRMustache/compare/v1.1.2...v1.1.3)

## [v1.1.2](https://github.com/groue/GRMustache/tree/v1.1.2) (2010-11-21)

[Full Changelog](https://github.com/groue/GRMustache/compare/v1.1.1...v1.1.2)

## [v1.1.1](https://github.com/groue/GRMustache/tree/v1.1.1) (2010-11-20)

[Full Changelog](https://github.com/groue/GRMustache/compare/v1.1.0...v1.1.1)

## [v1.1.0](https://github.com/groue/GRMustache/tree/v1.1.0) (2010-11-12)

[Full Changelog](https://github.com/groue/GRMustache/compare/v1.0.0...v1.1.0)

## [v1.0.0](https://github.com/groue/GRMustache/tree/v1.0.0) (2010-11-12)



\* *This Change Log was automatically generated by [github_changelog_generator](https://github.com/skywinder/Github-Changelog-Generator)*