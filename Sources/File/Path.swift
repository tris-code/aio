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

public struct Path: Equatable {
    public enum `Type`: Equatable {
        case absolute
        case relative
    }

    public var type: Type
    public var components: [String]

    public var string: String {
        let path = components.joined(separator: "/")
        switch type {
        case .absolute: return "/" + path
        case .relative: return path
        }
    }

    public func removingLastComponent() -> Path {
        return Path(type: type, components: [String](components.dropLast()))
    }

    public func appending(_ component: String) -> Path {
        let suffix = component.split(separator: "/").map(String.init)
        return Path(type: type, components: components + suffix)
    }
}

extension Path {
    public init(string: String) {
        switch string.starts(with: "/") {
        case true: self.type = .absolute
        case false: self.type = .relative
        }
        self.components = string.split(separator: "/").map(String.init)
    }
}

extension Path {
    enum Error: Swift.Error {
        case cantGetHome
    }

    mutating func expandTilde() throws {
        guard type == .relative, components.first == "~" else {
            return
        }
        guard let home = Environment["HOME"] else {
            throw Error.cantGetHome
        }
        let homeComponents = home.split(separator: "/").map(String.init)
        self.type = .absolute
        self.components = homeComponents + components[1...]
    }

    func expandingTilde() throws -> Path {
        var path = self
        try path.expandTilde()
        return path
    }
}

extension Path: CustomStringConvertible {
    public var description: String {
        return string
    }
}

extension Path: ExpressibleByStringLiteral {
    public init(stringLiteral string: String) {
        self.init(string: string)
    }
}

extension Path {
    public static func ==(lhs: Path, rhs: String) -> Bool {
        return lhs == Path(string: rhs)
    }

    public static func ==(lhs: String, rhs: Path) -> Bool {
        return Path(string: lhs) == rhs
    }
}
