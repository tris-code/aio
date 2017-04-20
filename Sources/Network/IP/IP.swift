/*
 * Copyright 2017 Tris Foundation and the project authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License
 *
 * See LICENSE.txt in the project root for license information
 * See CONTRIBUTORS.txt for the list of the project authors
 */

import Platform

struct IPv4 {
    let address: in_addr

    public init(_ address: UInt32) {
        self.address = in_addr(s_addr: address)
    }

    public init(
        _ fragment1: UInt8,
        _ fragment2: UInt8,
        _ fragment3: UInt8,
        _ fragment4: UInt8
    ) {
        self.init(
            UInt32(fragment1) << 24 |
            UInt32(fragment1) << 16 |
            UInt32(fragment1) << 8 |
            UInt32(fragment1)
        )
    }
}

struct IPv6 {
    let address: in6_addr

    public init(
        _ fragment1: UInt16,
        _ fragment2: UInt16,
        _ fragment3: UInt16,
        _ fragment4: UInt16,
        _ fragment5: UInt16,
        _ fragment6: UInt16,
        _ fragment7: UInt16,
        _ fragment8: UInt16
        ) {
        self.address = in6_addr(
            (
                fragment1,
                fragment2,
                fragment3,
                fragment4,
                fragment5,
                fragment6,
                fragment7,
                fragment8
            )
        )
    }
}

extension IPv4: Equatable {
    static func ==(lhs: IPv4, rhs: IPv4) -> Bool {
        return lhs.address == rhs.address
    }
}

extension IPv6: Equatable {
    static func ==(lhs: IPv6, rhs: IPv6) -> Bool {
        return lhs.address == rhs.address
    }
}
