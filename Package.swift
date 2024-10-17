// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftVite",
    platforms: [
        .iOS(.v13),
        .macOS(.v13),
        .tvOS(.v13),
        .watchOS(.v6)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "SwiftVite",
            targets: ["SwiftVite"]),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.106.0"),
        .package(url: "https://github.com/vapor/leaf.git", from: "4.4.0"),
        .package(url: "https://github.com/vapor/fluent.git", from: "4.0.0"),
        .package(url: "https://github.com/vapor/fluent-sqlite-driver.git", from: "4.0.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "SwiftVite",
            dependencies: [
                .product(name: "Vapor", package: "Vapor")
            ]
        ),
        .testTarget(
            name: "SwiftViteTests",
            dependencies: ["SwiftVite"]
        ),
        .executableTarget(
            name: "Development",
            dependencies: [
                .target(name: "SwiftVite"),
                .product(name: "Vapor", package: "Vapor"),
                .product(name: "Leaf", package: "Leaf"),
                .product(name: "Fluent", package: "Fluent"),
                .product(name: "FluentSQLiteDriver", package: "fluent-sqlite-driver")
            ]
        )
    ]
)
