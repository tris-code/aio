import Platform

public final class Directory {
    public let name: String
    public let location: Path

    public var path: Path {
        return location.appending(name)
    }

    var handle: DirectoryHandle?

    public init<T: StringProtocol>(name: T, at location: Path) {
        self.name = String(name)
        self.location = location
    }

    deinit {
        try? close()
    }

    public var isExists: Bool {
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
        try close()
        try Directory.remove(at: path)
    }

    public func contents() throws -> [Entry] {
        return try Directory.contents(at: path)
    }
}

// MARK: static

extension Directory {
    public static var current: Directory? {
        get {
            var directory = [Int8](repeating: 0, count: Int(PATH_MAX))
            guard getcwd(&directory, directory.count) != nil else { return nil }
            return Directory(at: String(cString: directory))
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
                let path = path.deletingLastComponent
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
        let iterator = try DirectoryContentsIterator(at: path)
        while let entry = iterator.next() {
            switch entry.isDirectory {
            case true: try Directory.remove(at: entry.path)
            case false: unlink(entry.path.string)
            }
        }
        iterator.close()
        try system { rmdir(path.string) }
    }

    public static func changeWorkingDirectory(to path: Path) throws {
        try system { chdir(path.string) }
    }

    public static func contents(at path: Path) throws -> [Entry] {
        let iterator = try DirectoryContentsIterator(at: path)
        return [Entry](IteratorSequence(iterator))
    }
}

extension Directory {
    convenience
    public init(at path: Path) {
        var path = path
        let name = path.deleteLastComponent() ?? ""
        self.init(name: name, at: path)
    }

    convenience
    public init<T: StringProtocol>(at path: T) {
        self.init(at: .init(path))
    }

    convenience
    public init<T: StringProtocol>(name: T) {
        self.init(name: name, at: Directory.current?.path ?? "~/")
    }

    convenience
    public init<T: StringProtocol, U: StringProtocol>(name: T, at path: U) {
        self.init(name: name, at: .init(path))
    }
}

// MARK: ExpressibleByStringLiteral

extension Directory: ExpressibleByStringLiteral {
    convenience
    public init(stringLiteral value: String) {
        self.init(at: value)
    }
}

// MARK: Equatable

extension Directory: Equatable {
    public static func == (lhs: Directory, rhs: Directory) -> Bool {
        return lhs.name == rhs.name && lhs.location == rhs.location
    }

    public static func ==<T: StringProtocol>(lhs: Directory, rhs: T) -> Bool {
        return lhs == Directory(at: rhs)
    }

    public static func ==<T: StringProtocol>(lhs: T, rhs: Directory) -> Bool {
        return rhs == lhs
    }
}

// MARK: CustomStringConvertible

extension Directory: CustomStringConvertible {
    public var description: String {
        return path.description
    }
}

// MARK: DirectoryContentsIterator

extension Directory {
    public struct Entry: Equatable {
        public let path: Path
        public let isDirectory: Bool

        public init(path: Path, isDirectory: Bool) {
            self.path = path
            self.isDirectory = isDirectory
        }
    }
}

public class DirectoryContentsIterator: IteratorProtocol {
    let path: Path
    var handle: DirectoryHandle?

    init(at path: Path) throws {
        self.path = path
        self.handle = try system { opendir(path.string) }
    }

    deinit {
        close()
        handle = nil
    }

    func close() {
        guard let handle = handle else {
            return
        }
        closedir(handle)
        self.handle = nil
    }

    public func next() -> Directory.Entry? {
        guard let handle = handle else {
            return nil
        }

        while let entry = readdir(handle) {
            // skip "." and ".."
            if entry.isCurrentDirectory || entry.isParentDirectory {
                continue
            }
            return Directory.Entry(
                path: path.appending(entry.name),
                isDirectory: entry.isDirectory)
        }

        close()
        return nil
    }
}
