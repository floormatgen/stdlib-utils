// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "swift-stdlib-utils",
  products: [
    // Products define the executables and libraries a package produces, making them visible to other packages.
    .library(name: "ObservationUtils", targets: ["ObservationUtils"])
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-async-algorithms", from: "1.0.0"),
  ],
  targets: [
    // Targets are the basic building blocks of a package, defining a module or a test suite.
    // Targets can depend on other targets in this package and products from dependencies.
    .target(
      name: "ObservationUtils",
      dependencies: [
        .target(name: "Compatability"),
        .product(name: "AsyncAlgorithms", package: "swift-async-algorithms"),
      ]
    ),
    .target(
      name: "Compatability"
    )
  ],
  swiftLanguageModes: [.v6]
)

// MARK: - Swift Settings

let swiftSettings: [SwiftSetting] = [
  
]

for target in package.targets {
  target.swiftSettings = (target.swiftSettings ?? []) + swiftSettings
}
