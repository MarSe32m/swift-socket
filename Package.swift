// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-socket",
    products: [
        .executable(name: "Socket", targets: ["Socket"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(name: "CSocket"),
        .target(name: "Socket", dependencies: ["CSocket"])
    ]
)
