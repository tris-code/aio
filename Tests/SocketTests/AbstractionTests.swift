/*
 * Copyright 2017 Tris Foundation and the project authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License
 *
 * See LICENSE.txt in the project root for license information
 * See CONTRIBUTORS.txt for the list of the project authors
 */

import XCTest
@testable import Socket

class AbstractionTests: XCTestCase {
    func testFamily() {
        XCTAssertEqual(Socket.Family.inet.rawValue, AF_INET)
        XCTAssertEqual(Socket.Family.inet6.rawValue, AF_INET6)
        XCTAssertEqual(Socket.Family.unix.rawValue, AF_UNIX)
        XCTAssertEqual(Socket.Family.unspecified.rawValue, AF_UNSPEC)
    }

    func testSocketType() {
        XCTAssertEqual(Socket.SocketType.stream.rawValue, SOCK_STREAM)
        XCTAssertEqual(Socket.SocketType.datagram.rawValue, SOCK_DGRAM)
    }


    static var allTests : [(String, (AbstractionTests) -> () throws -> Void)] {
        return [
            ("testFamily", testFamily),
            ("testSocketType", testSocketType),
        ]
    }
}
