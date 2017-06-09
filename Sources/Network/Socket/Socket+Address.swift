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
        case unspecified

        public enum Family {
            case inet, inet6, unspecified, unix
        }

        var family: Family {
            switch self {
            case .ip4: return .inet
            case .ip6: return .inet6
            case .unix: return .unix
            case .unspecified: return .unspecified
            }
        }

        var size: socklen_t {
            switch self {
            case .ip4: return sockaddr_in.size
            case .ip6: return sockaddr_in6.size
            case .unix: return sockaddr_un.size
            case .unspecified: return 0
            }
        }
    }

    public var selfAddress: Address? {
        var storage = sockaddr_storage()
        var size = UInt32(sockaddr_storage.size)
        getsockname(descriptor, rebounded(&storage), &size)
        return Address(storage)
    }

    public var peerAddress: Address? {
        var storage = sockaddr_storage()
        var size = UInt32(sockaddr_storage.size)
        getpeername(descriptor, rebounded(&storage), &size)
        return Address(storage)
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

extension Socket.Address {
    init?(_ storage: sockaddr_storage) {
        guard let family = Family(storage.ss_family) else {
            return nil
        }
        switch family {
        case .inet: self = .ip4(sockaddr_in(storage))
        case .inet6: self = .ip6(sockaddr_in6(storage))
        case .unix: self = .unix(sockaddr_un(storage))
        case .unspecified: self = .unspecified
        }
    }
}

extension Socket.Address.Family {
    init?(_ family: sa_family_t) {
        self.init(rawValue: Int32(family))
    }

    init?(rawValue: Int32) {
        switch rawValue {
        case AF_INET: self = .inet
        case AF_INET6: self = .inet6
        case AF_UNIX: self = .unix
        case AF_UNSPEC: self = .unspecified
        default: return nil
        }
    }

    var rawValue: Int32 {
        switch self {
        case .inet: return AF_INET
        case .inet6: return AF_INET6
        case .unix: return AF_UNIX
        case .unspecified: return AF_UNSPEC
        }
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
