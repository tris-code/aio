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

#if os(Linux)
    let SOCK_STREAM = Int32(Glibc.SOCK_STREAM.rawValue)
    let SOCK_DGRAM = Int32(Glibc.SOCK_DGRAM.rawValue)
    let SOCK_SEQPACKET = Int32(Glibc.SOCK_SEQPACKET.rawValue)
    let noSignal = Int32(MSG_NOSIGNAL)
#else
    let noSignal = Int32(0)
#endif

extension Socket.Family {
    var rawValue: Int32 {
        switch self {
        case .inet: return AF_INET
        case .inet6: return AF_INET6
        case .unix: return AF_UNIX
        case .unspecified: return AF_UNSPEC
        }
    }
}

extension Socket.SocketType {
    var rawValue: Int32 {
        switch self {
        case .stream: return SOCK_STREAM
        case .datagram: return SOCK_DGRAM
        case .sequenced: return SOCK_SEQPACKET
        }
    }
}

func rebounded<T>(_ pointer: UnsafePointer<T>) -> UnsafePointer<sockaddr> {
    return UnsafeRawPointer(pointer).assumingMemoryBound(to: sockaddr.self)
}

func rebounded<T>(_ pointer: UnsafeMutablePointer<T>) -> UnsafeMutablePointer<sockaddr> {
    return UnsafeMutableRawPointer(pointer).assumingMemoryBound(to: sockaddr.self)
}

fileprivate func presentationToNetwork(ip4 address: String) throws -> in_addr? {
    var addr = in_addr()
    switch inet_pton(AF_INET, address, &addr) {
    case 1: return addr
    case 0: return nil
    case -1: throw SocketError()
    default: preconditionFailure("inet_pton: unexpected return code")
    }
}

fileprivate func presentationToNetwork(ip6 address: String) throws -> in6_addr? {
    var addr6 = in6_addr()
    switch inet_pton(AF_INET6, address, &addr6) {
    case 1: return addr6
    case 0: return nil
    case -1: throw SocketError()
    default: preconditionFailure("inet_pton: unexpected return code")
    }
}

extension sockaddr_in {
    init(_ storage: sockaddr_storage) {
        var storage = storage
        var sockaddr = sockaddr_in()
        memcpy(&sockaddr, &storage, Int(sockaddr_in.size))
        self = sockaddr
    }
}

extension sockaddr_in6 {
    init(_ storage: sockaddr_storage) {
        var storage = storage
        var sockaddr = sockaddr_in6()
        memcpy(&sockaddr, &storage, Int(sockaddr_in6.size))
        self = sockaddr
    }
}

extension sockaddr_un {
    init(_ storage: sockaddr_storage) {
        var storage = storage
        var sockaddr = sockaddr_un()
        memcpy(&sockaddr, &storage, Int(sockaddr_un.size))
        self = sockaddr
    }
}

extension sockaddr_storage {
    static var size: socklen_t {
        return socklen_t(MemoryLayout<sockaddr_storage>.size)
    }
}

extension sockaddr_in {
    var address: String? {
        get {
            var bytes = [Int8](repeating: 0, count: Int(INET_ADDRSTRLEN) + 1)
            var addr = self.sin_addr
            inet_ntop(AF_INET, &addr, &bytes, socklen_t(INET_ADDRSTRLEN))
            return String(cString: bytes)
        }
    }

    var port: UInt16 {
        get { return self.sin_port.byteSwapped }
        set { self.sin_port = in_port_t(newValue).byteSwapped }
    }

    var family: Int32 {
        get { return Int32(self.sin_family) }
        set { self.sin_family = sa_family_t(newValue) }
    }

    static var size: socklen_t {
        return socklen_t(MemoryLayout<sockaddr_in>.size)
    }

    public init(_ address: String, _ port: UInt16) throws {
        guard let addr = try presentationToNetwork(ip4: address) else {
            errno = EINVAL
            throw SocketError()
        }
        var sockaddr = sockaddr_in()
    #if os(macOS)
        sockaddr.sin_len = sa_family_t(MemoryLayout<sockaddr_in>.size)
    #endif
        sockaddr.family = AF_INET
        sockaddr.sin_addr = addr
        sockaddr.port = port
        self = sockaddr
    }
}

extension sockaddr_in6 {
    var address: String? {
        get {
            var bytes = [Int8](repeating: 0, count: Int(INET6_ADDRSTRLEN) + 1)
            var addr = self.sin6_addr
            guard inet_ntop(AF_INET6, &addr, &bytes, socklen_t(INET6_ADDRSTRLEN)) != nil else {
                return nil
            }
            return String(cString: bytes)
        }
    }

    var port: UInt16 {
        get { return self.sin6_port.byteSwapped }
        set { self.sin6_port = in_port_t(newValue).byteSwapped }
    }

    var family: Int32 {
        get { return Int32(self.sin6_family) }
        set { self.sin6_family = sa_family_t(newValue) }
    }

    static var size: socklen_t {
        return socklen_t(MemoryLayout<sockaddr_in6>.size)
    }

    public init(_ address: String, _ port: UInt16) throws {
        guard let addr = try presentationToNetwork(ip6: address) else {
            errno = EINVAL
            throw SocketError()
        }
        var sockaddr = sockaddr_in6()
    #if os(macOS)
        sockaddr.sin6_len = sa_family_t(MemoryLayout<sockaddr_in6>.size)
    #endif
        sockaddr.family = AF_INET6
        sockaddr.sin6_addr = addr
        sockaddr.port = port
        self = sockaddr
    }
}

extension sockaddr_un {
    var address: String {
        get {
            var path = self.sun_path
            let size = MemoryLayout.size(ofValue: path)
            var bytes = [Int8](repeating: 0, count: size)
            memcpy(&bytes, &path, size-1)
            return String(cString: bytes)
        }
    }

    var family: Int32 {
        get { return Int32(self.sun_family) }
        set { self.sun_family = sa_family_t(newValue) }
    }

    static var size: socklen_t {
        return socklen_t(MemoryLayout<sockaddr_un>.size)
    }

    public init(_ address: String) throws {
        var bytes = [UInt8](address.utf8)
        var sockaddr = sockaddr_un()
        let size = MemoryLayout.size(ofValue: sockaddr.sun_path)
        guard bytes.count < size else {
            errno = EINVAL
            throw SocketError()
        }
    #if os(macOS)
        sockaddr.sun_len = sa_family_t(sockaddr_un.size)
    #endif
        sockaddr.family = AF_UNIX
        memcpy(&sockaddr.sun_path, &bytes, bytes.count)
        self = sockaddr
    }
}

protocol SockaddrProtocol: Equatable {}
extension sockaddr_in: SockaddrProtocol {}
extension sockaddr_in6: SockaddrProtocol {}
extension sockaddr_un: SockaddrProtocol {}

extension SockaddrProtocol {
    public static func ==(lhs: Self, rhs: Self) -> Bool {
        var lhs = lhs
        var rhs = rhs
        return withUnsafeBytes(of: &lhs) { lhs in
            return withUnsafeBytes(of: &rhs) { rhs in
                return lhs.elementsEqual(rhs)
            }
        }
    }
}
