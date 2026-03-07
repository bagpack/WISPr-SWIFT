// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "WISPrSwift",
    platforms: [
        .iOS(.v13),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "WISPrSwift",
            targets: ["WISPrSwift"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/AliSoftware/OHHTTPStubs.git", from: "9.1.0")
    ],
    targets: [
        .target(
            name: "WISPrSwift",
            path: "Sources/WISPrSwift",
            resources: [
                .copy("PrivacyInfo.xcprivacy")
            ]
        ),
        .testTarget(
            name: "WISPrSwiftTests",
            dependencies: [
                "WISPrSwift",
                .product(name: "OHHTTPStubs", package: "OHHTTPStubs"),
                .product(name: "OHHTTPStubsSwift", package: "OHHTTPStubs")
            ],
            path: "Tests",
            sources: ["WISPrSwiftTests"],
            resources: [
                .copy("Fixtures")
            ]
        )
    ]
)
