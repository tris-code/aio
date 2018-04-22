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

#if os(macOS)
func lseek(_ handle: Int32, _ offset: Int, _ origin: Int32) -> Int {
    return Int(Platform.lseek(handle, Int64(offset), origin))
}
#endif

extension dirent {
    #if os(Linux)
    var d_namlen: Int {
        var d_name = self.d_name
        let buffer = UnsafeMutableRawBufferPointer(
            start: UnsafeMutableRawPointer(&d_name),
            count: Int(NAME_MAX))
        for i in 0..<buffer.count {
            if buffer[i] == 0 {
                return i
            }
        }
        return 0
    }
    #endif
}

extension UnsafeMutablePointer where Pointee == dirent {
    var isDirectory: Bool {
        return Int(pointee.d_type) & Int(DT_DIR) != 0
    }

    var isCurrentDirectory: Bool {
        return pointee.d_name.0 == UInt8(ascii: ".")
            && pointee.d_name.1 == 0
    }

    var isParentDirectory: Bool {
        return pointee.d_name.0 == UInt8(ascii: ".")
            && pointee.d_name.1 == UInt8(ascii: ".")
            && pointee.d_name.2 == 0
    }

    var name: String {
        let buffer = UnsafeMutableRawBufferPointer(
            start: &pointee.d_name,
            count: Int(pointee.d_namlen))
        return String(decoding: buffer, as: UTF8.self)
    }
}
