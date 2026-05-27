// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import CompilerPluginSupport
import PackageDescription
import Foundation

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
    .library(name: "TypeUtils",         targets: ["TypeUtils"]),
    .library(name: "ConcurrencyUtils",  targets: ["ConcurrencyUtils"]),
    .library(name: "ObservationUtils",  targets: ["ObservationUtils"]),
    .library(name: "StdlibUtils",       targets: ["TypeUtils", "ConcurrencyUtils", "ObservationUtils"]),
  ],
  dependencies: [
    .package(url: "https://github.com/swiftlang/swift-syntax.git",  from: "601.0.0"),
    .package(url: "https://github.com/swiftlang/swift-docc-plugin", from: "1.1.0"),
  ],
  targets: [
    
    // MARK: Types
    .target(
      name: "TypeUtils",
      dependencies: [
        .target(name: "TypeUtilsMacros")
      ]
    ),
    .macro(
      name: "TypeUtilsMacros",
      dependencies: [
        .target(name: "MacroUtils"),
        .product(name: "SwiftSyntax",         package: "swift-syntax"),
        .product(name: "SwiftSyntaxMacros",   package: "swift-syntax"),
        .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
        .product(name: "SwiftDiagnostics",    package: "swift-syntax"),
      ]
    ),
    .testTarget(
      name: "TypeUtilsTests",
      dependencies: [
        .target(name: "TypeUtils"),
      ]
    ),
    .testTarget(
      name: "TypeUtilsMacrosTests",
      dependencies: [
        .target(name: "TypeUtilsMacros"),
        .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
      ]
    ),
    
    // MARK: Concurrency
    .target(
      name: "ConcurrencyUtils",
      dependencies: [
        .target(name: "ConcurrencyUtilsMacros"),
      ]
    ),
    .macro(
      name: "ConcurrencyUtilsMacros",
      dependencies: [
        .target(name: "MacroUtils"),
        .product(name: "SwiftSyntax",         package: "swift-syntax"),
        .product(name: "SwiftSyntaxMacros",   package: "swift-syntax"),
        .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
        .product(name: "SwiftDiagnostics",    package: "swift-syntax"),
      ]
    ),
    .testTarget(
      name: "ConcurrencyUtilsTests",
      dependencies: [
        .target(name: "ConcurrencyUtils"),
      ]
    ),
    .testTarget(
      name: "ConcurrencyUtilsMacrosTests",
      dependencies: [
        .target(name: "ConcurrencyUtilsMacros"),
        .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
      ]
    ),

    // MARK: Observation
    .target(
      name: "ObservationUtils",
      dependencies: [
        .target(name: "Compatability"),
      ]
    ),
    .testTarget(
      name: "ObservationUtilsTests",
      dependencies: [
        .target(name: "ObservationUtils"),
      ]
    ),

    // MARK: Internal
    .target(
      name: "Compatability"
    ),
    // FIXME: Known issue with macro dependencies, see
    // https://forums.swift.org/t/swift-macro-linker-failures-on-linux-and-when-building-with-xcodebuild/84306
    //
    // Currently using symlinks to prevent code duplication
    .target(
      name: "MacroUtils",
      dependencies: [
        .product(name: "SwiftSyntax",         package: "swift-syntax"),
        .product(name: "SwiftSyntaxMacros",   package: "swift-syntax"),
        .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
        .product(name: "SwiftDiagnostics",    package: "swift-syntax"),
      ]
    ),
    
  ],
  swiftLanguageModes: [.v6]
)

// MARK: - Swift Settings

let swiftSettings: [SwiftSetting] = [
  // .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
  .enableUpcomingFeature("ExistentialAny"),
  .enableUpcomingFeature("MemberImportVisibility"),
  .enableUpcomingFeature("ImmutableWeakCaptures"),
]

for target in package.targets {
  target.swiftSettings = (target.swiftSettings ?? []) + swiftSettings
}

// FIXME: Known issue with macro dependencies, see
// https://forums.swift.org/t/swift-macro-linker-failures-on-linux-and-when-building-with-xcodebuild/84306
//
// Currently using symlinks to prevent code duplication

// Check if we are not on macOS
// macOS has access to xcodebuild, which causes linker failures

// https://forums.swift.org/t/detecting-xpm-from-package-swift/55297/3
let runningFromXcode = ProcessInfo.processInfo.environment["__CFBundleIdentifier"] == "com.apple.dt.Xcode"

if !runningFromXcode {
  for target in package.targets where target.type == .macro {
    target.exclude = ["./MacroUtils"]
  }
}
