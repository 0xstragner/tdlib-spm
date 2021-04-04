// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "tdjson",
    platforms: [
        .iOS(.v10), 
        .macOS(.v10_14), 
        .tvOS(.v10), 
        .watchOS(.v5)
    ],
    products: [
        .library(
            name: "tdjson", 
            targets: ["tdjson"]
        )
    ],
    targets: [
        .binaryTarget(
            name: "tdjson",
            url: "https://github.com/oboupo/tdlib-spm/releases/download/v1.7.0/tdjson.xcframework.zip",
            checksum: "993981a37046b81b432b146ecb1f94d14ea64a913979dc691e9d301a82e72597"
        )
    ]
)
