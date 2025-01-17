// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "native_image_picker_macos",
    platforms: [
        .macOS("10.14")
    ],
    products: [
        .library(name: "native-image-picker-macos", targets: ["native_image_picker_macos"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "native_image_picker_macos",
            dependencies: [],
            resources: [
                .process("Resources"),
            ]
        )
    ]
)