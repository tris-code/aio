/******************************************************************************
 *                                                                            *
 * Tris Foundation disclaims copyright to this source code.                   *
 * In place of a legal notice, here is a blessing:                            *
 *                                                                            *
 *     May you do good and not evil.                                          *
 *     May you find forgiveness for yourself and forgive others.              *
 *     May you share freely, never taking more than you give.                 *
 *                                                                            *
 ******************************************************************************/

import Test
import Fiber
import Platform

@testable import Async
@testable import Network

class OptionsTests: TestCase {
    override func setUp() {
        async.setUp(Fiber.self)
    }

    func testReuseAddr() {
        scope {
            let socket = try Socket()
            assertTrue(try socket.options.get(.reuseAddr))
        }
    }

    func testReuseAddrUnix() {
        unlink("/tmp/unix1")
        scope {
            assertNoThrow(try Socket(family: .local).bind(to: "/tmp/unix1"))
            assertThrowsError(try Socket(family: .local).bind(to: "/tmp/unix1"))
        }
    }

    func testReusePort() {
        scope {
            let socket = try Socket()
            assertFalse(try socket.options.get(.reusePort))
            assertNoThrow(try socket.options.set(.reusePort, true))
            assertTrue(try socket.options.get(.reusePort))
        }
    }

    func testNoSignalPipe() {
        scope{
            let socket = try Socket()
            #if os(macOS)
            assertTrue(try socket.options.get(.noSignalPipe))
            #endif
        }
    }

    func testConfigureReusePort() {
        scope {
            let socket = try Socket().configure { options in
                try options.set(.reusePort, true)
            }

            assertTrue(try socket.options.get(.reuseAddr))
            assertTrue(try socket.options.get(.reusePort))
        }
    }

    func testConfigureBroadcast() {
        scope {
            let socket = try Socket().configure { options in
                try options.set(.broadcast, true)
            }

            assertTrue(try socket.options.get(.broadcast))
        }
    }
}
