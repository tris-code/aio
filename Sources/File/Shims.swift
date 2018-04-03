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
