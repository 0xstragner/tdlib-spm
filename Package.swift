// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "libtdjson",
    platforms: [
        .iOS(.v10), 
        .macOS(.v10_14), 
        .tvOS(.v10), 
        .watchOS(.v5)
    ],
    products: [
        .library(
            name: "libtdjson", 
            targets: ["libtdjson"]
        )
    ],
    targets: [
        .binaryTarget(
            name: "libtdjson",
            url: "https://github.com/oboupo/tdlib-spm/releases/download/v1.7.0/libtdjson.xcframework.zip",
            checksum: "25d3fef1a2c7d060cc07f2c4f543d388cd5ff056a0f7a3ddc5e4f0497ed8b5ca"
        )
    ]
)
