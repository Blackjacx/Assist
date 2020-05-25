// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "Assist",
    platforms: [
        // Add support for all platforms starting from a specific version.
        .macOS(.v10_15),
        //        .iOS(.v11),
        //        .watchOS(.v5),
        //        .tvOS(.v11)
    ],
    products: [
        .executable(name: "asc", targets: ["ASC"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "0.0.1"),
        .package(url: "https://github.com/apple/swift-tools-support-core", from: "0.0.1"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "Assist",
            dependencies: []
        ),
        .testTarget(
            name: "AssistTests",
            dependencies: ["Assist"]
        ),
        .target(
            name: "ASC",
            dependencies: [
                "Assist",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "SwiftToolsSupport", package: "swift-tools-support-core")]
        ),
        .testTarget(
            name: "ASCTests",
            dependencies: ["ASC"]
        ),
    ]
)
