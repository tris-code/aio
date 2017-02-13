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
    public enum Address {
        case ip4(sockaddr_in)
        case ip6(sockaddr_in6)
        case unix(sockaddr_un)

        var size: socklen_t {
            switch self {
            case .ip4: return socklen_t(MemoryLayout<sockaddr_in>.size)
            case .ip6: return socklen_t(MemoryLayout<sockaddr_in6>.size)
            case .unix: return socklen_t(MemoryLayout<sockaddr_un>.size)
            }
        }
    }

    public var selfAddress: Address {
        var storage = sockaddr_storage()
        var length = UInt32(MemoryLayout<sockaddr_storage>.size)
        getsockname(descriptor, rebounded(&storage), &length)
        return transform(storage)
    }

    public var peerAddress: Address {
        var storage = sockaddr_storage()
        var length = UInt32(MemoryLayout<sockaddr_storage>.size)
        getpeername(descriptor, rebounded(&storage), &length)
        return transform(storage)
    }

    fileprivate func transform(_ storage: sockaddr_storage) -> Address {
        switch storage.ss_family {
        case sa_family_t(AF_INET): return .ip4(sockaddr_in(storage))
        case sa_family_t(AF_INET6): return .ip6(sockaddr_in6(storage))
        case sa_family_t(AF_UNIX): return .unix(sockaddr_un(storage))
        default: preconditionFailure("unexpected family")
        }
    }
}

extension Socket.Address {
    public init(_ address: String, port: UInt16? = nil) throws {
        if let port = port {
            if let ip4 = try? Socket.Address(ip4: address, port: port) {
                self = ip4
                return
            }

            if let ip6 = try? Socket.Address(ip6: address, port: port) {
                self = ip6
                return
            }
        }

        if let unix = try? Socket.Address(unix: address) {
            self = unix
            return
        }

        // TODO: resolve domain

        errno = EINVAL
        throw SocketError()
    }

    public init(ip4 address: String, port: UInt16) throws {
        self = .ip4(try sockaddr_in(address, port))
    }

    public init(ip6 address: String, port: UInt16) throws {
        self = .ip6(try sockaddr_in6(address, port))
    }

    public init(unix address: String) throws {
        self = .unix(try sockaddr_un(address))
    }
}

extension Socket.Address: Equatable {
    public static func ==(lhs: Socket.Address, rhs: Socket.Address) -> Bool {
        switch (lhs, rhs) {
        case let (.ip4(lhs), .ip4(rhs)): return lhs == rhs
        case let (.ip6(lhs), .ip6(rhs)): return lhs == rhs
        case let (.unix(lhs), .unix(rhs)): return lhs == rhs
        default: return false
        }
    }
}
