// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "TimeTracker",
    platforms: [
        .macOS(.v15)
    ],
    targets: [
        .target(
            name: "TimeTrackerWindowing",
            path: "Sources/Windowing"
        ),
        .executableTarget(
            name: "TimeTracker",
            dependencies: ["TimeTrackerWindowing"],
            path: "Sources",
            exclude: ["Windowing"],
            resources: [
                .copy("../Resources/Assets.xcassets")
            ]
        ),
        .executableTarget(
            name: "WindowFramePolicyCheck",
            dependencies: ["TimeTrackerWindowing"],
            path: "Tests/WindowFramePolicyCheck"
        )
    ]
)
