/*
 * Copyright 2017 Tris Foundation and the project authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License
 *
 * See LICENSE.txt in the project root for license information
 * See CONTRIBUTORS.txt for the list of the project authors
 */

import Dispatch
@testable import Network

class IPTests: TestCase {
    func testIPv4() {
        let ip4 = IPv4(127,0,0,1)
        assertNotNil(ip4)
        assertEqual(ip4.description, "127.0.0.1")
    }

    func testIPv6() {
        let ip6 = IPv6(0,0,0,0,0,0,0,1)
        assertNotNil(ip6)
        assertEqual(ip6.description, "::1")
    }


    static var allTests = [
        ("testIPv4", testIPv4),
        ("testIPv6", testIPv6),
    ]
}
