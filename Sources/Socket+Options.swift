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

extension Socket {
    public struct Options {
        let descriptor: Descriptor
        public init(for descriptor: Descriptor) {
            self.descriptor = descriptor
        }

        public subscript(option: Int32) -> Bool? {
            get {
                var value: Int32 = 0
                var valueSize = socklen_t(MemoryLayout<Int32>.size)
                guard getsockopt(descriptor, SOL_SOCKET, option, &value, &valueSize) != -1 else {
                    return nil
                }
                return value == 0 ? false : true
            }
            set {
                var value: Int32 = newValue == true ? 1 : 0
                let valueSize = socklen_t(MemoryLayout<Int32>.size)
                _ = setsockopt(descriptor, SOL_SOCKET, option, &value, valueSize)
            }
        }
    }
}
