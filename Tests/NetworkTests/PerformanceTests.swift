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
@testable import Network

class PerformanceTests: TestCase {
    let message = [UInt8]("Hello, World!".utf8)

    var port: UInt16 = {
        return UInt16(arc4random_uniform(64_000)) + 1_500
    }()

    func testPerformance() {
        let ready = AtomicCondition()

        DispatchQueue.global().async {
            do {
                let socket = try Socket()
                    .bind(to: "127.0.0.1", port: self.port)
                    .listen()

                ready.signal()

                while true {
                    let client = try socket.accept()
                    var buffer = [UInt8](repeating: 0, count: self.message.count)
                    do {
                        var read = 0
                        repeat {
                            read = try client.receive(to: &buffer)
                            _ = try client.send(bytes: buffer)
                        } while read > 0
                    } catch {
                        fail(String(describing: error))
                    }
                }
            } catch {
                fail(String(describing: error))
            }
        }

        ready.wait()

        measure {
            do {
                let socket = try Socket()
                _ = try socket.connect(to: "127.0.0.1", port: self.port)

                var response = [UInt8](repeating: 0, count: self.message.count)

                for _ in 0..<1_000 {
                    _ = try socket.send(bytes: self.message)
                    _ = try socket.receive(to: &response)
                }
            } catch {
                fail(String(describing: error))
            }
        }
    }


    static var allTests = [
        ("testPerformance", testPerformance),
    ]
}
