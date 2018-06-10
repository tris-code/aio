/******************************************************************************
 *                                                                            *
 * Tris Foundation disclaims copyright to this source code.                   *
 * In place of a legal notice, here is a blessing:                            *
 *                                                                            *
 *     May you do good and not evil.                                          *
 *     May you find forgiveness for yourself and forgive others.              *
 *     May you share freely, never taking more than you give.                 *
 *                                                                            *
 ******************************************************************************/

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

    public func appending(_ component: String) -> Path {
        let suffix = component.split(separator: "/").map(String.init)
        return Path(type: type, components: components + suffix)
    }

    public func deletingLastComponent() -> Path {
        return Path(type: type, components: [String](components.dropLast()))
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

    public mutating func expandTilde() throws {
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

    public func expandingTilde() throws -> Path {
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
