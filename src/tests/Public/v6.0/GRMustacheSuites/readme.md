Those JSON files require care about their embedded comments:

- single line comments are supported (//...)
- multi line comments are NOT supported (/*...*/)
- double slash in the JSON data is NOT supported ("foo":"//")

Rationale:

GRMustache claims support for iOS 4.3+, MaxOSX 10.6+, and Garbage collection. It also requires comments in its JSON test suites.

JSONKit, NSJSONSerialization and Xcode have various support for those environments:

                      | iOS4.3 | iOS5+ | MacOS10.6 | MacOS10.6GC | MacOS10.7+ | MacOS10.7+GC | JSON comments
----------------------+--------+-------+-----------+-------------+------------+--------------+--------------
| JSONKit             |   X    |   X   |     X     |             |     X      |              |      X
| NSJSONSerialization |        |   X   |     X     |      X      |     X      |      X       |
| Xcode 4.5.2         |        |   X   |           |             |     X      |      X       |
| Testable            |        |   X   |           |             |     X      |      X       |  hand-made

Conclusion: with a mix of JSONKit, NSJSONSerialization, and hand-made JSON comments parsing, we can actually test support for iOS5+ and MacOS10.7+ with our without GC.

Our claim for MacOS10.6 and iOS4.3 support is a hollow wish that can not be tested.
