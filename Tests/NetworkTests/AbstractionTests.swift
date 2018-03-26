/*
 * Copyright 2017 Tris Foundation and the project authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License
 *
 * See LICENSE.txt in the project root for license information
 * See CONTRIBUTORS.txt for the list of the project authors
 */

import Test
import Platform
@testable import Network

class AbstractionTests: TestCase {
    func testFamily() {
        assertEqual(Socket.Family.local.rawValue, PF_LOCAL)
        assertEqual(Socket.Family.inet.rawValue, PF_INET)
        assertEqual(Socket.Family.inet6.rawValue, PF_INET6)
    }

    func testSocketType() {
        func rawValue(of type: Socket.`Type`) -> Int32 {
            return type.rawValue
        }
        assertEqual(rawValue(of: .stream), SOCK_STREAM)
        assertEqual(rawValue(of: .datagram), SOCK_DGRAM)
        assertEqual(rawValue(of: .sequenced), SOCK_SEQPACKET)
        assertEqual(rawValue(of: .raw), SOCK_RAW)
    }
}
