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

import Platform
import Stream

public class NetworkStream: Stream {
    let socket: Socket

    public init(socket: Socket) {
        self.socket = socket
    }

    public func read(
        to buffer: UnsafeMutableRawPointer, byteCount: Int) throws -> Int
    {
        let read = try socket.receive(to: buffer, count: byteCount)
        guard read != -1 else {
            throw SystemError()
        }
        return read
    }

    public func write(
        from buffer: UnsafeRawPointer,
        byteCount: Int) throws -> Int
    {
        let written = try socket.send(bytes: buffer, count: byteCount)
        guard written != -1 else {
            throw SystemError()
        }
        return written
    }
}
