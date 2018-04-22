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

import Platform

public struct SocketError: Error, CustomStringConvertible {
    public let number = errno
    public let description = String(cString: strerror(errno))

    public var interrupted: Bool {
        return number == EAGAIN || number == EWOULDBLOCK || number == EINTR
    }
}
