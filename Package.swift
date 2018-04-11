// swift-tools-version:4.2
/*
 * Copyright 2017 Tris Foundation and the project authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License
 *
 * See LICENSE.txt in the project root for license information
 * See CONTRIBUTORS.txt for the list of the project authors
 */

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
