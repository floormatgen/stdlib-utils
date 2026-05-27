# swift-stdlib-utils

A collection of utility functions, types and macros for the [**Swift Standard Library**](https://developer.apple.com/documentation/swift).

Currently these utilities are split into 3 sections:
- [**TypeUtils**](https://floormatgen.github.io/swift-stdlib-utils/documentation/typeutils/)
- [**ConcurrencyUtils**](https://floormatgen.github.io/swift-stdlib-utils/documentation/concurrencyutils)
- [**ObservationUtils**](https://floormatgen.github.io/swift-stdlib-utils/documentation/observationutils/)

## [SwiftSyntax](https://swiftpackageindex.com/swiftlang/swift-syntax/603.0.1/documentation/swiftsyntax) Version Support

The current preferred major version of [**SwiftSyntax**](https://swiftpackageindex.com/swiftlang/swift-syntax/603.0.1/documentation/swiftsyntax) is [`603`](https://github.com/swiftlang/swift-syntax/releases/tag/603.0.0). 
Due to [SwiftPM dependency resolution rules](https://www.pointfree.co/blog/posts/116-being-a-good-citizen-in-the-land-of-swiftsyntax), this package also supports versions since [`600`](https://github.com/swiftlang/swift-syntax/releases/tag/600.0.0), with the following considerations:

### Versions older than [`603`](https://github.com/swiftlang/swift-syntax/releases/tag/603.0.0)
- Module selectors are ignored when checking types

### Versions older than [`602`](https://github.com/swiftlang/swift-syntax/releases/tag/602.0.0)
- `nonisolated(nonsending)` is no longer added by ``Reasync()``

### Versions older than [`601`](https://github.com/swiftlang/swift-syntax/releases/tag/601.0.0)
- None

---

It is recommended to use the newest SwiftSyntax version possible.