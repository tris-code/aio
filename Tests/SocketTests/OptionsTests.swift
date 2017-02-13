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

class OptionsTests: XCTestCase {
    func testReuseAddr() {
        do {
            let socket = try Socket()
            var options = socket.options

            XCTAssertTrue(options.reuseAddr)
        } catch {
            XCTFail(String(describing: error))
        }
    }

    func testReuseAddrUnix() {
        unlink("/tmp/unix1")
        do {
            _ = try Socket()
                .bind(to: "/tmp/unix1")

            _ = try Socket()
                .bind(to: "/tmp/unix1")

            XCTFail("did not throw an error")
        } catch {
            
        }
    }

    func testReusePort() {
        do {
            let socket = try Socket()
            var options = socket.options

            XCTAssertFalse(options.reusePort)
            options.reusePort = true
            XCTAssertTrue(options.reusePort)
        } catch {
            XCTFail(String(describing: error))
        }
    }

    func testNoSignalPipe() {
        do {
            let socket = try Socket()
            var options = socket.options
        #if os(macOS)
            XCTAssertTrue(options.noSignalPipe)
        #endif
        } catch {
            XCTFail(String(describing: error))
        }
    }

    func testConfigureReusePort() {
        do {
            let socket = try Socket().configure(reusePort: true)

            XCTAssertTrue(socket.options.reuseAddr)
            XCTAssertTrue(socket.options.reusePort)
        } catch {
            XCTFail(String(describing: error))
        }
    }


    static var allTests : [(String, (OptionsTests) -> () throws -> Void)] {
        return [
            ("testReuseAddr", testReuseAddr),
            ("testReuseAddrUnix", testReuseAddrUnix),
            ("testReusePort", testReusePort),
            ("testNoSignalPipe", testNoSignalPipe),
            ("testConfigureReusePort", testConfigureReusePort),
        ]
    }
}
