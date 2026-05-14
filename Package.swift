// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "TimeTracker",
    platforms: [
        .macOS(.v15)
    ],
    targets: [
        .executableTarget(
            name: "TimeTracker",
            path: "Sources",
            resources: [
                .copy("../Resources/Assets.xcassets")
            ]
        )
    ]
)
