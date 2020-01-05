// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "AIO",
    products: [
        .library(name: "AIO", targets: ["AIO"]),
        .library(name: "Network", targets: ["Network"]),
        .library(name: "File", targets: ["File"]),
    ],
    dependencies: [
        .package(path: "../Platform"),
        .package(path: "../Time"),
        .package(path: "../Log"),
        .package(path: "../Async"),
        .package(path: "../Stream"),
        .package(path: "../Test"),
        .package(path: "../Fiber")
    ],
    targets: [
        .target(
            name: "AIO",
            dependencies: ["File", "Network"]),
        .target(
            name: "File",
            dependencies: ["Platform", "Stream"]),
        .target(
            name: "Network",
            dependencies: ["Platform", "Time", "Async", "Stream", "Log"]),
        .testTarget(
            name: "FileTests",
            dependencies: ["Test", "File"]),
        .testTarget(
            name: "NetworkTests",
            dependencies: ["Network", "Test", "Fiber"])
    ]
)
