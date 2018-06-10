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

public final class Directory {
    public let name: String
    public let location: Path

    public var path: Path {
        return location.appending(name)
    }

    var handle: DirectoryHandle?

    public init(name: String, at location: Path) {
        self.name = name
        self.location = location
    }

    deinit {
        try? close()
    }

    public var isExist: Bool {
        return Directory.isExists(at: path)
    }

    public func open() throws {
        guard handle == nil else {
            return
        }
        self.handle = try system {
            return opendir(path.string)
        }
    }

    public func close() throws {
        if let handle = handle {
            closedir(handle)
            self.handle = nil
        }
    }

    public func create(
        withIntermediateDirectories: Bool = true,
        permissions: Permissions = .directory) throws
    {
        try Directory.create(
            at: path,
            withIntermediateDirectories: withIntermediateDirectories,
            permissions: permissions)
    }

    public func remove() throws {
        try open()

        while let entry = readdir(handle!) {
            // skip "." and ".."
            if entry.isCurrentDirectory || entry.isParentDirectory {
                continue
            }
            let child = path.appending(entry.name)
            if entry.isDirectory {
                try Directory(path: child).remove()
            } else {
                unlink(child.string)
            }
        }

        try close()
        try system { rmdir(path.string) }
    }
}

// MARK: static

extension Directory {
    public static var current: Directory? {
        get {
            var directory = [Int8](repeating: 0, count: Int(PATH_MAX))
            guard getcwd(&directory, directory.count) != nil else { return nil }
            let path = Path(string: String(cString: directory))
            return Directory(path: path)
        }
        set {
            if let newValue = newValue {
                chdir(newValue.path.string)
            }
        }
    }

    public static func isExists(at path: Path) -> Bool {
        return access(path.string, F_OK) == 0
    }

    public static func create(
        at path: Path,
        withIntermediateDirectories: Bool = true,
        permissions: Permissions = .directory) throws
    {
        func createCurrent() throws {
            try system { mkdir(path.string, permissions.rawMask) }
        }

        func createParent() throws {
            if !path.components.isEmpty {
                let path = path.removingLastComponent()
                if !isExists(at: path) {
                    try create(at: path, permissions: .intermediateDirectories)
                }
            }
        }

        switch withIntermediateDirectories {
        case true:
            try createParent()
            try createCurrent()
        case false:
            try createCurrent()
        }
    }

    public static func remove(at path: Path) throws {
        try Directory(path: path).remove()
    }

    public static func changeWorkingDirectory(to path: Path) throws {
        try system { chdir(path.string) }
    }
}

extension Directory {
    convenience
    public init(name: String) {
        self.init(name: name, at: Directory.current?.path ?? "~/")
    }

    convenience
    public init(path: Path) {
        var path = path
        let name = path.components.popLast() ?? ""
        self.init(name: name, at: path)
    }

    convenience
    public init(string: String) {
        self.init(path: Path(string: string))
    }
}

// MARK: description / equatable

extension Directory: ExpressibleByStringLiteral {
    convenience public init(stringLiteral value: String) {
        self.init(path: Path(string: value))
    }
}

extension Directory: CustomStringConvertible {
    public var description: String {
        return path.description
    }
}

extension Directory: Equatable {
    public static func == (lhs: Directory, rhs: Directory) -> Bool {
        return lhs.path == rhs.path
    }
}
