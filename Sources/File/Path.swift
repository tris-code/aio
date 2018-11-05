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

public struct Path {
    public var type: Type
    public var components: [String]

    public enum `Type` {
        case absolute
        case relative
    }

    public init<T: Sequence>(type: Type, components: T) 
        where T.Element == String 
    {
        self.type = type
        self.components = [String](components)
    }

    public mutating func append(_ another: Path) {
        components.append(contentsOf: another.components)
    }

    @discardableResult
    public mutating func deleteLastComponent() -> String? {
        return components.popLast()
    }
}

extension Path {
    public var deletingLastComponent: Path {
        guard components.count > 0 else { return self }
        return .init(type: type, components: components.dropLast())
    }

    public func appending(_ another: Path) -> Path {
        var path = self
        path.append(another)
        return path
    }
}

extension Path {
    public var string: String {
        let path = components.joined(separator: "/")
        switch type {
        case .absolute: return "/" + path
        case .relative: return path
        }
    }

    public init<T: StringProtocol>(_ path: T) {
        switch path.first {
        case "/": self.type = .absolute
        default: self.type = .relative
        }
        self.components = path.split(separator: "/").map { String($0) }
    }

    public mutating func append<T: StringProtocol>(_ another: T) {
        append(.init(another))
    }

    public func appending<T: StringProtocol>(_ another: T) -> Path {
        return appending(.init(another))
    }
}

extension Path {
    enum Error: String, Swift.Error {
        case cantGetHome = "Environment variable HOME is empty"
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

// MARK: ExpressibleByStringLiteral

extension Path: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(value)
    }
}

// MARK: Equatable

extension Path: Equatable {
    public static func ==<T: StringProtocol>(lhs: Path, rhs: T) -> Bool {
        return lhs == Path(rhs)
    }

    public static func ==<T: StringProtocol>(lhs: T, rhs: Path) -> Bool {
        return rhs == lhs
    }
}

// MARK: CustomStringConvertible

extension Path: CustomStringConvertible {
    public var description: String {
        return string
    }
}
