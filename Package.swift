// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import CompilerPluginSupport
import PackageDescription

let package = Package(
  name: "swift-stdlib-utils",
  platforms: [
    .iOS(.v13),
    .macOS(.v10_15),
    .tvOS(.v13),
    .watchOS(.v6),
    .visionOS(.v1),
  ],
  products: [
    // Products define the executables and libraries a package produces, making them visible to other packages.
    .library(name: "ObservationUtils", targets: ["ObservationUtils"]),
    .library(name: "ConcurrencyUtils", targets: ["ConcurrencyUtils"]),
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-async-algorithms", from: "1.0.0"),
    .package(url: "https://github.com/swiftlang/swift-syntax.git", from: "603.0.0"),
    .package(url: "https://github.com/swiftlang/swift-docc-plugin", from: "1.1.0"),
  ],
  targets: [
    
    // Observation
    .target(
      name: "ObservationUtils",
      dependencies: [
        .target(name: "Compatability"),
        .product(name: "AsyncAlgorithms", package: "swift-async-algorithms"),
      ]
    ),
    .testTarget(
      name: "ObservationUtilsTests",
      dependencies: [
        .target(name: "ObservationUtils"),
      ]
    ),
    
    // Concurrency
    .target(
      name: "ConcurrencyUtils",
      dependencies: [
        .target(name: "ConcurrencyUtilsMacros"),
      ]
    ),
    .macro(
      name: "ConcurrencyUtilsMacros",
      dependencies: [
        .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
        .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
        .product(name: "SwiftDiagnostics", package: "swift-syntax"),
      ]
    ),
    .testTarget(
      name: "ConcurrencyUtilsMacrosTests",
      dependencies: [
        .target(name: "ConcurrencyUtilsMacros"),
        .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
      ]
    ),
    
    // Internal
    .target(
      name: "Compatability"
    ),
    
  ],
  swiftLanguageModes: [.v6]
)

// MARK: - Swift Settings

let swiftSettings: [SwiftSetting] = [
  // .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
  .enableUpcomingFeature("ExistentialAny"),
  .enableUpcomingFeature("MemberImportVisibility"),
]

for target in package.targets {
  target.swiftSettings = (target.swiftSettings ?? []) + swiftSettings
}
