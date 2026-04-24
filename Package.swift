// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "WhatsNewKit",
    platforms: [
        .iOS(.v26),
        .macOS(.v26),
    ],
    products: [
        .library(
            name: "WhatsNewKit",
            targets: ["WhatsNewKit"]),
    ],
    targets: [
        .target(
            name: "WhatsNewKit"),
        .testTarget(
            name: "WhatsNewKitTests",
            dependencies: ["WhatsNewKit"]),
    ])
