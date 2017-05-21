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

enum IPAddress {
    case v4(IPv4)
    case v6(IPv6)
}

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
            UInt32(fragment1)
            | UInt32(fragment2) << 8
            | UInt32(fragment3) << 16
            | UInt32(fragment4) << 24
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
                fragment1.byteSwapped,
                fragment2.byteSwapped,
                fragment3.byteSwapped,
                fragment4.byteSwapped,
                fragment5.byteSwapped,
                fragment6.byteSwapped,
                fragment7.byteSwapped,
                fragment8.byteSwapped
            )
        )
    }
}

extension IPv4: CustomStringConvertible {
    var description: String {
        return address.description
    }
}

extension IPv6: CustomStringConvertible {
    var description: String {
        return address.description
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

extension IPAddress: Equatable {
    static func ==(lhs: IPAddress, rhs: IPAddress) -> Bool {
        switch (lhs, rhs) {
        case let (.v4(lhs), v4(rhs)): return lhs == rhs
        case let (.v6(lhs), v6(rhs)): return lhs == rhs
        default: return false
        }
    }
}
