// swift-tools-version: 5.9

import CompilerPluginSupport
import PackageDescription

let package = Package(
  name: "Stub",
  platforms: [
    .macOS(.v10_15),
    .iOS(.v13),
    .tvOS(.v13),
    .watchOS(.v6),
    .macCatalyst(.v13),
  ],
  products: [
    .library(
      name: "Stub",
      targets: ["Stub"]
    )
  ],
  dependencies: [
    .package(
      url: "https://github.com/apple/swift-syntax",
      "509.0.0"..<"510.0.0"
    )
  ],
  targets: [
    .macro(
      name: "StubMacro",
      dependencies: [
        .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
        .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
      ]
    ),
    .target(
      name: "Stub",
      dependencies: [
        "StubMacro"
      ]
    ),
    .testTarget(
      name: "StubMacroTests",
      dependencies: [
        "StubMacro",
        .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
      ]
    ),
  ]
)
