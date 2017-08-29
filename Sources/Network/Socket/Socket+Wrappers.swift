/*
 * Copyright 2017 Tris Foundation and the project authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License
 *
 * See LICENSE.txt in the project root for license information
 * See CONTRIBUTORS.txt for the list of the project authors
 */

import Foundation

extension Socket {
    @discardableResult
    public func bind(to address: String, port: UInt16) throws -> Self {
        return try bind(to: try Address(address, port: port))
    }

    @discardableResult
    public func bind(to address: String) throws -> Self {
        return try bind(to: try Address(unix: address))
    }

    @discardableResult
    public func connect(
        to address: String,
        port: UInt16,
        deadline: Date = Date.distantFuture
    ) throws -> Self {
        return try connect(
            to: try Address(address, port: port),
            deadline: deadline)
    }

    @discardableResult
    public func connect(
        to address: String,
        deadline: Date = Date.distantFuture
    ) throws -> Self {
        return try connect(
            to: try Address(address),
            deadline: deadline)
    }
}

extension Socket {
    public func send(
        bytes: UnsafeRawBufferPointer,
        deadline: Date = Date.distantFuture
    ) throws -> Int {
        return try send(
            bytes: bytes.baseAddress!,
            count: bytes.count,
            deadline: deadline)
    }

    public func send(
        bytes: UnsafeRawBufferPointer,
        to address: Address,
        deadline: Date = Date.distantFuture
    ) throws -> Int {
        return try send(
            bytes: bytes.baseAddress!,
            count: bytes.count,
            to: address,
            deadline: deadline)
    }

    public func send(
        bytes: [UInt8],
        deadline: Date = Date.distantFuture
    ) throws -> Int {
        return try send(
            bytes: bytes,
            count: bytes.count,
            deadline: deadline)
    }

    public func send(
        bytes: [UInt8],
        to address: Address,
        deadline: Date = Date.distantFuture
    ) throws -> Int {
        return try send(
            bytes: bytes,
            count: bytes.count,
            to: address,
            deadline: deadline)
    }

    public func receive(
        to buffer: inout [UInt8],
        deadline: Date = Date.distantFuture
    ) throws -> Int {
        return try receive(
            to: &buffer,
            count: buffer.count,
            deadline: deadline)
    }

    public func receive(
        to buffer: inout [UInt8],
        from address: inout Address?,
        deadline: Date = Date.distantFuture
    ) throws -> Int {
        return try receive(
            to: &buffer,
            count: buffer.count,
            from: &address,
            deadline: deadline)
    }

    public func receive(
        to buffer: UnsafeMutableRawBufferPointer,
        deadline: Date = Date.distantFuture
    ) throws -> Int {
        return try receive(
            to: buffer.baseAddress!,
            count: buffer.count,
            deadline: deadline)
    }

    public func receive(
        to buffer: UnsafeMutableRawBufferPointer,
        from address: inout Address?,
        deadline: Date = Date.distantFuture
    ) throws -> Int {
        return try receive(
            to: buffer.baseAddress!,
            count: buffer.count,
            from: &address,
            deadline: deadline)
    }
}
