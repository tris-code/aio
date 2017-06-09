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
import Foundation

struct DNS {
    static var dns: String = {
        // FIXME: implement async reader
        let fileManager = FileManager.default
        guard fileManager.isReadableFile(atPath: "/etc/resolv.conf") else {
            fatalError("/etc/resolv.conf not found")
        }

        guard let nameserver = String(
                data: fileManager.contents(atPath: "/etc/resolv.conf")!,
                encoding: .utf8)!
            .components(separatedBy: .newlines)
            .first(where: { $0.hasPrefix("nameserver") }) else {
                fatalError("nameserver not found")
        }
        
        guard let address = nameserver.components(separatedBy: .whitespaces)
            .last else {
                fatalError("invalid nameserver record")
        }
        return address
    }()

    static func makeRequest(
        query: Message,
        deadline: Date = Date.distantFuture
    ) throws -> Message {
        let server = try! Socket.Address(dns, port: 53)
        let socket = try Socket(type: .datagram)

        _ = try socket.send(bytes: query.bytes, to: server)
        var buffer = [UInt8](repeating: 0, count: 1024)
        let count = try socket.receive(to: &buffer)
        let response = [UInt8](buffer.prefix(upTo: count))

        return try Message(from: response)
    }

    public static func resolve(
        domain: String,
        type: ResourceType = .a,
        deadline: Date = Date.distantFuture
    ) throws -> [IPAddress] {
        let response = try makeRequest(
            query: Message(resolve: domain, type: type),
            deadline: deadline)

        return response.answer.reduce([IPAddress]()) { result, next in
            var result = result
            if case let .a(address) = next.data {
                result.append(.v4(address))
            } else if case let .aaaa(address) = next.data {
                result.append(.v6(address))
            }
            return result
        }
    }
}
