/******************************************************************************
 *                                                                            *
 * Tris Foundation disclaims copyright to this source code.                   *
 * In place of a legal notice, here is a blessing:                            *
 *                                                                            *
 *     May you do good and not evil.                                          *
 *     May you find forgiveness for yourself and forgive others.              *
 *     May you share freely, never taking more than you give.                 *
 *                                                                            *
 ******************************************************************************
 *  This file contains code that has not yet been described                   *
 ******************************************************************************/

import Stream
import Platform

extension File: Stream {
    public func read(
        to buffer: UnsafeMutableRawPointer,
        byteCount: Int) throws -> Int
    {
        guard let descriptor = descriptor else {
            throw Error.closed
        }
        return try systemError {
            return Platform.read(descriptor.rawValue, buffer, byteCount)
        }
    }

    public func write(
        from buffer: UnsafeRawPointer,
        byteCount: Int) throws -> Int
    {
        guard let descriptor = descriptor else {
            throw Error.closed
        }
        return try systemError {
            return Platform.write(descriptor.rawValue, buffer, byteCount)
        }
    }
}
