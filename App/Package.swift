// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "App",
    platforms: [
        .iOS(.v26),
				.macOS(.v26)
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
				.library(
						name: "DialogsListFeature",
						targets: ["DialogsListFeature"]
				),
				.library(
						name: "DialogsListRowFeature",
						targets: ["DialogsListRowFeature"]
				),
				.library(
						name: "MessageListFeature",
						targets: ["MessageListFeature"]
				),
				.library(
						name: "ChatClient",
						targets: ["ChatClient"]
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
							"DialogsListFeature",
							"MessageListFeature",
                .product(name: "Schema", package: "ChatDatabase"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ],
        ),
        .target(
            name: "Components",
						dependencies: [
							.product(name: "Schema", package: "ChatDatabase"),
						],
        ),
				.target(
						name: "DialogsListFeature",
						dependencies: [
							"Components",
							"DialogsListRowFeature",
							.product(name: "Schema", package: "ChatDatabase"),
							.product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
						],
				),
				.target(
						name: "DialogsListRowFeature",
						dependencies: [
							"Components",
							.product(name: "Schema", package: "ChatDatabase"),
							.product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
						],
				),
				.target(
						name: "MessageListFeature",
						dependencies: [
							"Components",
							"ChatClient",
							.product(name: "Schema", package: "ChatDatabase"),
							.product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
						],
				),
				.target(
						name: "ChatClient",
						dependencies: [
							.product(name: "Schema", package: "ChatDatabase"),
						],
				),
    ]
)
