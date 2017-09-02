// swift-tools-version:4.0
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
    name: "Network",
    products: [
        .library(name: "Network", targets: ["Network"])
    ],
    dependencies: [
        .package(
            url: "https://github.com/tris-foundation/platform.git",
            from: "0.4.0"
        ),
        .package(
            url: "https://github.com/tris-foundation/async.git",
            from: "0.4.0"
        ),
        .package(
            url: "https://github.com/tris-foundation/test.git",
            from: "0.4.0"
        )
    ],
    targets: [
        .target(name: "Network", dependencies: ["Async"]),
        .testTarget(name: "NetworkTests", dependencies: ["Network", "Test"])
    ]
)

#if os(macOS)
    import Darwin.C
#else
    import Glibc
#endif

if getenv("Tris.Stream") != nil || getenv("Development") != nil {
    package.dependencies.append(
        .package(
            url: "https://github.com/tris-foundation/stream.git",
            from: "0.4.0")
    )

    package.targets
        .first(where: { $0.name == "Network" })?
        .dependencies
        .append("Stream")
}
