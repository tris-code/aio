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

extension sockaddr_in {
    public init(_ addr: sockaddr) {
        self = unsafeBitCast(addr, to: sockaddr_in.self)
    }
    static let length = socklen_t(MemoryLayout<sockaddr_in>.size)
}

extension sockaddr {
    public init(_ addr: sockaddr_in) {
        self = unsafeBitCast(addr, to: sockaddr.self)
    }
    static let length = socklen_t(MemoryLayout<sockaddr>.size)
}

extension sockaddr_in {
    var host: String {
        get { return String(cString: inet_ntoa(self.sin_addr)) }
        set { _ = inet_pton(AF_INET, newValue, &self.sin_addr) }
    }

    var port: UInt16 {
        get { return self.sin_port.byteSwapped }
        set { self.sin_port = in_port_t(newValue).bigEndian }
    }

    var family: Int32 {
        get { return Int32(self.sin_family) }
        set { self.sin_family = sa_family_t(newValue) }
    }

    public init(host: String, port: UInt16, family: Int32) {
        self = sockaddr_in()
        self.host = host
        self.port = port
        self.family = family
    }
}
