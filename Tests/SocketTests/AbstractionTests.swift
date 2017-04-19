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
@testable import Socket

class AbstractionTests: TestCase {
    func testFamily() {
        assertEqual(Socket.Family.local.rawValue, PF_LOCAL)
        assertEqual(Socket.Family.inet.rawValue, PF_INET)
        assertEqual(Socket.Family.route.rawValue, PF_ROUTE)
        assertEqual(Socket.Family.key.rawValue, PF_KEY)
        assertEqual(Socket.Family.inet6.rawValue, PF_INET6)
        assertEqual(Socket.Family.system.rawValue, PF_SYSTEM)
        assertEqual(Socket.Family.raw.rawValue, PF_NDRV)
    }

    func testSocketType() {
        assertEqual(Socket.SocketType.stream.rawValue, SOCK_STREAM)
        assertEqual(Socket.SocketType.datagram.rawValue, SOCK_DGRAM)
        assertEqual(Socket.SocketType.sequenced.rawValue, SOCK_SEQPACKET)
        assertEqual(Socket.SocketType.raw.rawValue, SOCK_RAW)
    }


    static var allTests = [
        ("testFamily", testFamily),
        ("testSocketType", testSocketType),
    ]
}
