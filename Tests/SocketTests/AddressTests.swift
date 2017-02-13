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
import Dispatch
@testable import Socket

class AddressTests: XCTestCase {
    func testIPv4() {
        do {
            let address = try Socket.Address(ip4: "127.0.0.1", port: 5000)

            var sockaddr = sockaddr_in()
            inet_pton(AF_INET, "127.0.0.1", &sockaddr.sin_addr)
            sockaddr.sin_port = UInt16(5000).byteSwapped
            sockaddr.sin_family = sa_family_t(AF_INET)

            XCTAssertEqual(address, Socket.Address.ip4(sockaddr))
            XCTAssertEqual(address.size, socklen_t(MemoryLayout<sockaddr_in>.size))
        } catch {
            XCTFail(String(describing: error))
        }
    }

    func testIPv6() {
        do {
            let address = try Socket.Address(ip6: "::1", port: 5001)

            var sockaddr = sockaddr_in6()
            inet_pton(AF_INET6, "::1", &sockaddr.sin6_addr)
            sockaddr.sin6_port = UInt16(5001).byteSwapped
            sockaddr.sin6_family = sa_family_t(AF_INET6)

            XCTAssertEqual(address, Socket.Address.ip6(sockaddr))
            XCTAssertEqual(address.size, socklen_t(MemoryLayout<sockaddr_in6>.size))
        } catch {
            XCTFail(String(describing: error))
        }
    }

    func testUnix() {
        do {
            unlink("/tmp/testunix")
            let address = try Socket.Address(unix: "/tmp/testunix")

            var bytes = [UInt8]("/tmp/testunix".utf8)
            var sockaddr = sockaddr_un()
            let size = MemoryLayout.size(ofValue: sockaddr.sun_path)
            guard bytes.count < size else {
                errno = EINVAL
                throw SocketError()
            }
            sockaddr.family = AF_UNIX
            memcpy(&sockaddr.sun_path, &bytes, bytes.count)

            XCTAssertEqual(address, Socket.Address.unix(sockaddr))
            XCTAssertEqual(address.size, socklen_t(MemoryLayout<sockaddr_un>.size))
        } catch {
            XCTFail(String(describing: error))
        }
    }

    func testIPv4Detect() {
        do {
            let address = try Socket.Address(ip4: "127.0.0.1", port: 5002)
            let detected = try Socket.Address("127.0.0.1", port: 5002)

            XCTAssertEqual(address, detected)
        } catch {
            XCTFail(String(describing: error))
        }
    }

    func testIPv6Detect() {
        do {
            let address = try Socket.Address(ip6: "::1", port: 5003)
            let detected = try Socket.Address("::1", port: 5003)

            XCTAssertEqual(address, detected)
        } catch {
            XCTFail(String(describing: error))
        }
    }

    func testUnixDetect() {
        do {
            unlink("/tmp/testunixdetect")
            let address = try Socket.Address(unix: "/tmp/testunixdetect")
            let detected = try Socket.Address("/tmp/testunixdetect")

            XCTAssertEqual(address, detected)
        } catch {
            XCTFail(String(describing: error))
        }
    }

    func testLocalAddress() {
        let ready = AtomicCondition()
        let done = AtomicCondition()

        DispatchQueue.global().async {
            do {
                let socket = try Socket()
                    .bind(to: "127.0.0.1", port: 5004)
                    .listen()

                ready.signal()
                _ = try socket.accept()
                done.wait()
            } catch {
                XCTFail(String(describing: error))
            }
        }

        ready.wait()

        do {
            let socket = try Socket()
            _ = try socket
                .bind(to: "127.0.0.1", port: 5005)
                .connect(to: "127.0.0.1", port: 5004)

            var sockaddr = sockaddr_in()
            inet_pton(AF_INET, "127.0.0.1", &sockaddr.sin_addr)
            sockaddr.sin_port = UInt16(5005).byteSwapped
            sockaddr.sin_family = sa_family_t(AF_INET)
        #if os(macOS)
            sockaddr.sin_len = 16
        #endif

            XCTAssertEqual(socket.selfAddress, Socket.Address.ip4(sockaddr))

            done.signal()
        } catch {
            XCTFail(String(describing: error))
        }
    }

    func testRemoteAddress() {
        let ready = AtomicCondition()
        let done = AtomicCondition()

        DispatchQueue.global().async {
            do {
                let socket = try Socket()
                    .bind(to: "127.0.0.1", port: 5006)
                    .listen()

                ready.signal()
                _ = try socket.accept()
                done.wait()
            } catch {
                XCTFail(String(describing: error))
            }
        }

        ready.wait()

        do {
            let socket = try Socket()
            _ = try socket
                .bind(to: "127.0.0.1", port: 5007)
                .connect(to: "127.0.0.1", port: 5006)

            var sockaddr = sockaddr_in()
            inet_pton(AF_INET, "127.0.0.1", &sockaddr.sin_addr)
            sockaddr.sin_port = UInt16(5006).byteSwapped
            sockaddr.sin_family = sa_family_t(AF_INET)
        #if os(macOS)
            sockaddr.sin_len = 16
        #endif

            XCTAssertEqual(socket.peerAddress, Socket.Address.ip4(sockaddr))
            
            done.signal()
        } catch {
            XCTFail(String(describing: error))
        }
    }

    func testLocal6Address() {
        let ready = AtomicCondition()
        let done = AtomicCondition()

        DispatchQueue.global().async {
            do {
                let socket = try Socket(family: .inet6)
                    .bind(to: "::1", port: 5008)
                    .listen()

                ready.signal()
                _ = try socket.accept()
                done.wait()
            } catch {
                XCTFail(String(describing: error))
            }
        }

        ready.wait()

        do {
            let socket = try Socket(family: .inet6)
            _ = try socket
                .bind(to: "::1", port: 5009)
                .connect(to: "::1", port: 5008)

            var sockaddr = sockaddr_in6()
            inet_pton(AF_INET6, "::1", &sockaddr.sin6_addr)
            sockaddr.sin6_port = UInt16(5009).byteSwapped
            sockaddr.sin6_family = sa_family_t(AF_INET6)
        #if os(macOS)
            sockaddr.sin6_len = 28
        #endif

            XCTAssertEqual(socket.selfAddress, Socket.Address.ip6(sockaddr))

            done.signal()
        } catch {
            XCTFail(String(describing: error))
        }
    }

    func testRemote6Address() {
        let ready = AtomicCondition()
        let done = AtomicCondition()

        DispatchQueue.global().async {
            do {
                let socket = try Socket(family: .inet6)
                    .bind(to: "::1", port: 5010)
                    .listen()

                ready.signal()
                _ = try socket.accept()
                done.wait()
            } catch {
                XCTFail(String(describing: error))
            }
        }

        ready.wait()

        do {
            let socket = try Socket(family: .inet6)
            _ = try socket
                .bind(to: "::1", port: 5011)
                .connect(to: "::1", port: 5010)

            var sockaddr = sockaddr_in6()
            inet_pton(AF_INET6, "::1", &sockaddr.sin6_addr)
            sockaddr.sin6_port = UInt16(5010).byteSwapped
            sockaddr.sin6_family = sa_family_t(AF_INET6)
        #if os(macOS)
            sockaddr.sin6_len = 28
        #endif

            XCTAssertEqual(socket.peerAddress, Socket.Address.ip6(sockaddr))
            
            done.signal()
        } catch {
            XCTFail(String(describing: error))
        }
    }


    static var allTests : [(String, (AddressTests) -> () throws -> Void)] {
        return [
            ("testIPv4", testIPv4),
            ("testIPv6", testIPv6),
            ("testUnix", testUnix),
            ("testIPv4Detect", testIPv4Detect),
            ("testIPv6Detect", testIPv6Detect),
            ("testUnixDetect", testIPv6Detect),
            ("testLocalAddress", testLocalAddress),
            ("testRemoteAddress", testRemoteAddress),
            ("testLocal6Address", testLocal6Address),
            ("testRemote6Address", testRemote6Address),
        ]
    }
}
