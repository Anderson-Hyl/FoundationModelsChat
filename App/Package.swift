// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "App",
    platforms: [
        .iOS(.v18),
        .macOS(.v15),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "AppFeature",
            targets: ["AppFeature"]
        ),
        .library(
            name: "OnboardingFeature",
            targets: ["OnboardingFeature"]
        ),
        .library(
            name: "HomeFeature",
            targets: ["HomeFeature"]
        ),
        .library(
            name: "Components",
            targets: ["Components"]
        ),
    ],
    dependencies: [
        .package(path: "../ChatDatabase"),
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", from: "1.20.1")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "AppFeature",
            dependencies: [
                "OnboardingFeature",
                "HomeFeature",
                .product(name: "Schema", package: "ChatDatabase"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ],
        ),
        .target(
            name: "OnboardingFeature",
            dependencies: [
                "Components",
                .product(name: "Schema", package: "ChatDatabase"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ],
        ),
        .target(
            name: "HomeFeature",
            dependencies: [
                .product(name: "Schema", package: "ChatDatabase"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ],
        ),
        .target(
            name: "Components",
        ),
    ]
)
