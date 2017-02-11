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

public struct Endpoint {
    public let host: String
    public let port: UInt16
}

extension Socket {
    public var local: Endpoint {
        var addr = sockaddr()
        var length = sockaddr.size
        getsockname(descriptor, &addr, &length)
        let sin = sockaddr_in(addr)
        return Endpoint(host: sin.host, port: sin.port)
    }

    public var remote: Endpoint {
        var addr = sockaddr()
        var length = sockaddr.size
        getpeername(descriptor, &addr, &length)
        let sin = sockaddr_in(addr)
        return Endpoint(host: sin.host, port: sin.port)
    }
}
