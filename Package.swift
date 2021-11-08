// swift-tools-version:5.5

/**
*  CollectionConcurrencyKit
*  Copyright (c) John Sundell 2021
*  MIT license, see LICENSE.md file for details
*/

import PackageDescription

let package = Package(
    name: "CollectionConcurrencyKit",
    platforms: [.iOS(.v15), .macOS(.v12), .watchOS(.v8), .tvOS(.v15)],
    products: [
        .library(
            name: "CollectionConcurrencyKit",
            targets: ["CollectionConcurrencyKit"]
        )
    ],
    targets: [
        .target(
            name: "CollectionConcurrencyKit",
            path: "Sources"
        ),
        .testTarget(
            name: "CollectionConcurrencyKitTests",
            dependencies: ["CollectionConcurrencyKit"],
            path: "Tests"
        )
    ]
)
