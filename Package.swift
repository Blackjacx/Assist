// swift-tools-version:5.8
import PackageDescription

let package = Package(
    name: "Assist",
//    platforms: [.macOS(.v10_15), .macCatalyst(.v13), .iOS(.v13), .tvOS(.v13), .watchOS(.v6)],
    platforms: [
      .macOS(.v13)
//        .iOS(.v11),
//        .watchOS(.v5),
//        .tvOS(.v11)
    ],
    products: [
        .executable(name: "asc", targets: ["ASC"]),
        .executable(name: "push", targets: ["Push"]),
        .executable(name: "snap", targets: ["Snap"])
    ],
    dependencies: [
        .package(url: "https://github.com/blackjacx/Engine", from: "0.0.3"),
        .package(url: "https://github.com/blackjacx/ASCKit", from: "0.1.0"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.2.2"),
        .package(url: "https://github.com/vapor/jwt-kit.git", from: "4.1.0"),
        .package(url: "https://github.com/kareman/SwiftShell", from: "5.1.0")
    ],
    targets: [
        .target(
            name: "Core", 
            dependencies: [
              .product(name: "JWTKit", package: "jwt-kit"),
              "SwiftShell",
              "Engine",
            ]
        ),

        .executableTarget(
            name: "ASC",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                "Core",
                "ASCKit",
            ]
        ),
        .testTarget(
            name: "ASCTests",
            dependencies: ["ASC"]
        ),


        .executableTarget(
            name: "Push",
            dependencies: [
                "Core",
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]
        ),
        .testTarget(
            name: "PushTests",
            dependencies: ["Push"]
        ),


        .executableTarget(
            name: "Snap",
            dependencies: [
                "Core",
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]
        ),
        .testTarget(
            name: "SnapTests",
            dependencies: ["Snap"]
        ),
    ]
)
