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
            assertTrue(try socket.options.get(.reuseAddr))
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
            assertFalse(try socket.options.get(.reusePort))
            assertNoThrow(try socket.options.set(.reusePort, true))
            assertTrue(try socket.options.get(.reusePort))
        } catch {
            fail(String(describing: error))
        }
    }

    func testNoSignalPipe() {
        do {
            let socket = try Socket()
        #if os(macOS)
            assertTrue(try socket.options.get(.noSignalPipe))
        #endif
        } catch {
            fail(String(describing: error))
        }
    }

    func testConfigureReusePort() {
        do {
            let socket = try Socket().configure { options in
                try options.set(.reusePort, true)
            }

            assertTrue(try socket.options.get(.reuseAddr))
            assertTrue(try socket.options.get(.reusePort))
        } catch {
            fail(String(describing: error))
        }
    }

    func testConfigureBroadcast() {
        do {
            let socket = try Socket().configure { options in
                try options.set(.broadcast, true)
            }

            assertTrue(try socket.options.get(.broadcast))
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
        ("testConfigureBroadcast", testConfigureBroadcast),
    ]
}
