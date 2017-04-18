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
        assertEqual(Socket.Family.inet.rawValue, AF_INET)
        assertEqual(Socket.Family.inet6.rawValue, AF_INET6)
        assertEqual(Socket.Family.unix.rawValue, AF_UNIX)
        assertEqual(Socket.Family.unspecified.rawValue, AF_UNSPEC)
    }

    func testSocketType() {
        assertEqual(Socket.SocketType.stream.rawValue, SOCK_STREAM)
        assertEqual(Socket.SocketType.datagram.rawValue, SOCK_DGRAM)
    }


    static var allTests = [
        ("testFamily", testFamily),
        ("testSocketType", testSocketType),
    ]
}
