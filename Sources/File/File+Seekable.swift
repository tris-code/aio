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

import Stream
import Platform

extension File: Seekable {
    public func seek(to offset: Int, from origin: SeekOrigin) throws {
        guard let descriptor = descriptor else {
            throw Error.closed
        }
        try systemError { lseek(descriptor.rawValue, offset, origin.rawValue) }
    }
}

extension Seekable {
    public func seek(to origin: SeekOrigin) throws {
        try seek(to: 0, from: origin)
    }
}

extension BufferedOutputStream: Seekable where T == File {
    public func seek(to offset: Int, from origin: SeekOrigin) throws {
        switch origin {
        case .current where offset == 0:
            return
        default:
            try flush()
            try baseStream.seek(to: offset, from: origin)
        }
    }
}

extension BufferedInputStream: Seekable where T == File {
    public func seek(to offset: Int, from origin: SeekOrigin) throws {
        switch origin {
        case .current where offset == 0:
            return
        case .current where offset > 0 && buffered > offset:
            try consume(count: offset)
        default:
            clear()
            try baseStream.seek(to: offset, from: origin)
        }
    }
}

extension BufferedStream: Seekable where T == File {
    public func seek(to offset: Int, from origin: SeekOrigin) throws {
        try inputStream.seek(to: offset, from: origin)
        try outputStream.seek(to: offset, from: origin)
    }
}

extension SeekOrigin {
    var rawValue: Int32 {
        switch self {
        case .end: return SEEK_END
        case .current: return SEEK_CUR
        case .begin: return SEEK_SET
        }
    }
}
