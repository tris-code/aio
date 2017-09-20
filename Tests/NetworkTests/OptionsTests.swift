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
import AsyncDispatch
@testable import Network

class OptionsTests: TestCase {
    override func setUp() {
        AsyncDispatch().registerGlobal()
    }

    func testReuseAddr() {
        do {
            let socket = try Socket()
            var options = socket.options

            assertTrue(options.reuseAddr)
        } catch {
            fail(String(describing: error))
        }
    }

    func testReuseAddrUnix() {
        unlink("/tmp/unix1")
        do {
            _ = try Socket()
                .bind(to: "/tmp/unix1")

            _ = try Socket()
                .bind(to: "/tmp/unix1")

            fail("did not throw an error")
        } catch {
            
        }
    }

    func testReusePort() {
        do {
            let socket = try Socket()
            var options = socket.options

            assertFalse(options.reusePort)
            options.reusePort = true
            assertTrue(options.reusePort)
        } catch {
            fail(String(describing: error))
        }
    }

    func testNoSignalPipe() {
        do {
            let socket = try Socket()
            var options = socket.options
        #if os(macOS)
            assertTrue(options.noSignalPipe)
        #endif
        } catch {
            fail(String(describing: error))
        }
    }

    func testConfigureReusePort() {
        do {
            let socket = try Socket().configure(reusePort: true)

            assertTrue(socket.options.reuseAddr)
            assertTrue(socket.options.reusePort)
        } catch {
            fail(String(describing: error))
        }
    }


    static var allTests = [
        ("testReuseAddr", testReuseAddr),
        ("testReuseAddrUnix", testReuseAddrUnix),
        ("testReusePort", testReusePort),
        ("testNoSignalPipe", testNoSignalPipe),
        ("testConfigureReusePort", testConfigureReusePort),
    ]
}
