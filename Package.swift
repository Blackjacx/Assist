// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "Assist",
    platforms: [
        .macOS(.v10_15),
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
//        .package(name: "ASCKit", url: "https://github.com/blackjacx/asckit", .branch("develop")),
//        .package(name: "Engine", url: "https://github.com/blackjacx/Engine", .branch("develop")),
        .package(name: "ASCKit", path: "../ASCKit"),
        .package(name: "Engine", path: "../Engine"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "0.4.1"),
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

        .target(
            name: "ASC",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                "ASCKit",
            ]
        ),
        .testTarget(
            name: "ASCTests",
            dependencies: ["ASC"]
        ),


        .target(
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


        .target(
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
