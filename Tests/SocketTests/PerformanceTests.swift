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
import Platform
import Dispatch
@testable import Socket

class PerformanceTests: XCTestCase {
    let message = [UInt8]("Hello, World!".utf8)

    func testPerformance() {
        let condition = AtomicCondition()

        DispatchQueue.global().async {
            do {
                let socket = try Socket()

                try socket.listen(at: "127.0.0.1", port: 4446)
                condition.signal()
                while true {
                    let client = try socket.accept()
                    var buffer = [UInt8](repeating: 0, count: self.message.count)
                    do {
                        var read = 0
                        repeat {
                            read = try client.read(to: &buffer)
                            _ = try client.write(bytes: buffer, count: read)
                        } while read > 0
                    } catch {
                        print(error)
                    }
                }
            } catch {
                XCTFail(String(describing: error))
            }
        }

        condition.wait()

        measure {
            do {
                let socket = try Socket()
                _ = try socket.connect(to: "127.0.0.1", port: 4446)

                var response = [UInt8](repeating: 0, count: self.message.count)

                for _ in 0..<10_000 {
                    _ = try socket.write(bytes: self.message)
                    _ = try socket.read(to: &response)
                }

            } catch {
                XCTFail(String(describing: error))
            }
        }
    }


    static var allTests : [(String, (PerformanceTests) -> () throws -> Void)] {
        return [
            ("testPerformance", testPerformance),
        ]
    }
}
