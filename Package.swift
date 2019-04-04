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
        .package(
            url: "https://github.com/tris-code/platform.git",
            .branch("master")),
        .package(
            url: "https://github.com/tris-code/time.git",
            .branch("master")),
        .package(
            url: "https://github.com/tris-code/log.git",
            .branch("master")),
        .package(
            url: "https://github.com/tris-code/async.git",
            .branch("master")),
        .package(
            url: "https://github.com/tris-code/stream.git",
            .branch("master")),
        .package(
            url: "https://github.com/tris-code/test.git",
            .branch("master")),
        .package(
            url: "https://github.com/tris-code/fiber.git",
            .branch("master"))
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
