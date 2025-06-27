// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ChatDatabase",
    platforms: [
        .iOS(.v18),
        .macOS(.v15)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Schema",
            targets: ["Schema"]),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/sharing-grdb.git", from: "0.5.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Schema",
            dependencies: [
                .product(name: "SharingGRDB", package: "sharing-grdb")
            ],
        ),

    ],
    swiftLanguageModes: [.v6]
)
