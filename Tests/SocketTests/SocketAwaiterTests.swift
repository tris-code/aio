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
import Dispatch
@testable import Socket
import struct Foundation.Date

class SocketAwaiterTests: TestCase {
    class TestAwaiter: IOAwaiter {
        var event: IOEvent? = nil
        func wait(for descriptor: Descriptor, event: IOEvent, deadline: Date = Date.distantFuture) throws {
            self.event = event
        }
    }

    let message = [UInt8]("ping".utf8)

    func testSocketAwaiterAccept() {
        let ready = AtomicCondition()

        DispatchQueue.global().async {
            do {
                let awaiter = TestAwaiter()
                let socket = try Socket(awaiter: awaiter)
                    .bind(to: "127.0.0.1", port: 4001)
                    .listen()

                ready.signal()

                _ = try socket.accept()
                assertEqual(awaiter.event, .read)
            } catch {
                fail(String(describing: error))
            }
        }

        ready.wait()

        do {
            _ = try Socket().connect(to: "127.0.0.1", port: 4001)
        } catch {
            fail(String(describing: error))
        }
    }

    func testSocketAwaiterWrite() {
        let ready = AtomicCondition()
        DispatchQueue.global().async {
            do {
                let socket = try Socket()
                    .configure(reusePort: true)
                    .bind(to: "127.0.0.1", port: 4002)
                    .listen()

                ready.signal()

                let client = try socket.accept()
                _ = try client.send(bytes: self.message)
            } catch {
                fail(String(describing: error))
            }
        }

        ready.wait()

        do {
            let awaiter = TestAwaiter()
            let socket = try Socket(awaiter: awaiter)
                .connect(to: "127.0.0.1", port: 4002)

            _ = try socket.send(bytes: message)
            assertEqual(awaiter.event, .write)
        } catch {
            fail(String(describing: error))
        }
    }

    func testSocketAwaiterRead() {
        let ready = AtomicCondition()

        DispatchQueue.global().async {
            do {
                let awaiter = TestAwaiter()
                let socket = try Socket(awaiter: awaiter)
                    .bind(to: "127.0.0.1", port: 4003)
                    .listen()

                ready.signal()

                _ = try socket.accept()
                assertEqual(awaiter.event, .read)
            } catch {
                fail(String(describing: error))
            }
        }
        
        ready.wait()

        var response = [UInt8](repeating: 0, count: message.count)
        do {
            let awaiter = TestAwaiter()
            let socket = try Socket(awaiter: awaiter)
                .connect(to: "127.0.0.1", port: 4003)

            _ = try socket.receive(to: &response)
            assertEqual(awaiter.event, .read)
        } catch {
            fail(String(describing: error))
        }
    }

    func testSocketAwaiterWriteTo() {
        let ready = AtomicCondition()
        let done = AtomicCondition()

        let server = try! Socket.Address("127.0.0.1", port: 4004)

        DispatchQueue.global().async {
            do {
                let awaiter = TestAwaiter()
                _ = try Socket(type: .datagram, awaiter: awaiter)
                    .bind(to: server)

                ready.signal()

                done.wait()
            } catch {
                fail(String(describing: error))
            }
        }
        
        ready.wait()

        do {
            let awaiter = TestAwaiter()
            let socket = try Socket(type: .datagram, awaiter: awaiter)
            
            _ = try socket.send(bytes: message, to: server)
            assertEqual(awaiter.event, .write)
            done.signal()
        } catch {
            fail(String(describing: error))
        }
    }

    func testSocketAwaiterReadFrom() {
        let ready = AtomicCondition()
        let done = AtomicCondition()

        let server = try! Socket.Address("127.0.0.1", port: 4005)
        let client = try! Socket.Address("127.0.0.1", port: 4006)

        DispatchQueue.global().async {
            do {
                let awaiter = TestAwaiter()
                let socket = try Socket(type: .datagram, awaiter: awaiter)
                    .bind(to: server)

                ready.wait()

                _ = try socket.send(bytes: self.message, to: client)
                done.wait()
            } catch {
                fail(String(describing: error))
            }
        }

        var response = [UInt8](repeating: 0, count: message.count)
        do {
            let awaiter = TestAwaiter()
            let socket = try Socket(type: .datagram, awaiter: awaiter)
                .bind(to: client)

            ready.signal()

            var sender: Socket.Address? = nil
            _ = try socket.receive(to: &response, from: &sender)
            assertEqual(awaiter.event, .read)
            done.signal()
        } catch {
            fail(String(describing: error))
        }
    }


    static var allTests = [
        ("testSocketAwaiterAccept", testSocketAwaiterAccept),
        ("testSocketAwaiterWrite", testSocketAwaiterWrite),
        ("testSocketAwaiterRead", testSocketAwaiterRead),
        ("testSocketAwaiterWriteTo", testSocketAwaiterWriteTo),
        ("testSocketAwaiterReadFrom", testSocketAwaiterReadFrom),
    ]
}
