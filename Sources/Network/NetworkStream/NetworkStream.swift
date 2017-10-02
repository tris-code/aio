/*
 * Copyright 2017 Tris Foundation and the project authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License
 *
 * See LICENSE.txt in the project root for license information
 * See CONTRIBUTORS.txt for the list of the project authors
 */

import Stream

public class NetworkStream: Stream {
    public enum Error: Swift.Error {
        case closed
    }

    let socket: Socket

    public init(socket: Socket) {
        self.socket = socket
    }

    public func read(to buffer: UnsafeMutableRawBufferPointer) throws -> Int {
        let read = try socket.receive(to: buffer)
        guard read > 0 else {
            throw Error.closed
        }
        return read
    }

    public func write(_ bytes: UnsafeRawBufferPointer) throws -> Int {
        let written = try socket.send(
            bytes: bytes.baseAddress!,
            count: bytes.count)
        guard written > 0 else {
            throw Error.closed
        }
        return written
    }
}
