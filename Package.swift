// swift-tools-version:4.2
/******************************************************************************
 *                                                                            *
 * Tris Foundation disclaims copyright to this source code.                   *
 * In place of a legal notice, here is a blessing:                            *
 *                                                                            *
 *     May you do good and not evil.                                          *
 *     May you find forgiveness for yourself and forgive others.              *
 *     May you share freely, never taking more than you give.                 *
 *                                                                            *
 ******************************************************************************/

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
            url: "https://github.com/tris-foundation/platform.git",
            .branch("master")),
        .package(
            url: "https://github.com/tris-foundation/time.git",
            .branch("master")),
        .package(
            url: "https://github.com/tris-foundation/log.git",
            .branch("master")),
        .package(
            url: "https://github.com/tris-foundation/async.git",
            .branch("master")),
        .package(
            url: "https://github.com/tris-foundation/stream.git",
            .branch("master")),
        .package(
            url: "https://github.com/tris-foundation/test.git",
            .branch("master")),
        .package(
            url: "https://github.com/tris-foundation/fiber.git",
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
