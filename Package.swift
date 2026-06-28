// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "CodexMeter",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "CodexMeter",
            targets: ["CodexMeter"]
        )
    ],
    targets: [
        .executableTarget(
            name: "CodexMeter",
            path: "Sources/CodexMeter",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "CodexMeterTests",
            dependencies: ["CodexMeter"],
            path: "Tests/CodexMeterTests",
            resources: [
                .process("Fixtures")
            ]
        )
    ]
)
