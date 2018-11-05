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

import Stream
import Platform

public class File {
    public private(set) var descriptor: Descriptor?

    public private(set) var name: String
    public let location: Path

    public let bufferSize: Int

    public var path: Path {
        return location.appending(name)
    }

    public var isExists: Bool {
        return File.isExists(at: path)
    }

    public var permissions: Permissions? {
        get { return (try? Permissions(for: descriptor)) ?? nil }
        set { try? newValue.set(for: descriptor) }
    }

    public enum Error: String, Swift.Error {
        case invalidFileName = "Invalid file name"
        case invalidPath = "Invalid file path"
        case alreadyOpened = "The file is already opened"
        case closed = "The file was closed or wasn't opened"
        case exists = "The file is already exists"
    }

    public init(name: String, at location: Path, bufferSize: Int = 4096) {
        self.name = name
        self.location = location
        self.bufferSize = bufferSize
    }

    deinit {
        try? close()
    }

    private func open(
        _ flags: Flags = .read,
        _ permissions: Permissions = .file) throws
    {
        guard self.descriptor == nil else {
            throw Error.alreadyOpened
        }
        let flags = OpenFlags(flags).rawValue
        self.descriptor = Descriptor(rawValue: try system {
            return Platform.open(path.string, flags, permissions.rawMask)
        })
    }

    public func close() throws {
        if let descriptor = descriptor {
            try system { Platform.close(descriptor.rawValue) }
            self.descriptor = nil
        }
    }

    public func create(
        withIntermediateDirectories: Bool = true,
        permissions: Permissions = .file
    ) throws {
        guard descriptor == nil else {
            throw Error.exists
        }
        if withIntermediateDirectories, !Directory.isExists(at: location) {
            try Directory.create(at: self.location)
        }
        try open(.create, permissions)
        try close()
    }

    public func remove() throws {
        try close()
        try system { Platform.remove(path.string) }
    }

    public func rename(to name: String) throws {
        guard name.isValidFileName else {
            throw Error.invalidFileName
        }
        let newPath = location.appending(name).string
        try system { Platform.rename(path.string, newPath) }
        self.name = name
    }
}

// MARK: stream

extension File {
    public typealias Stream = BufferedStream<File>

    public func open(
        flags: Flags = .read,
        permissions: Permissions = .file) throws -> Stream
    {
        try open(flags, permissions)
        return BufferedStream(baseStream: self, capacity: bufferSize)
    }
}

// MARK: static

extension File {
    public static func isExists(at path: Path) -> Bool {
        return access(path.string, F_OK) == 0
    }

    public static func remove(at path: Path) throws {
        try system { Platform.remove(path.string) }
    }

    public static func create(
        _ name: String,
        at path: Path,
        withIntermediateDirectories: Bool,
        permissions: Permissions = .file) throws
    {
        try File(name: name, at: path).create(
            withIntermediateDirectories: withIntermediateDirectories,
            permissions: permissions)
    }

    public static func rename(
        _ oldName: String,
        to newName: String,
        at path: Path) throws
    {
        try File(name: oldName, at: path).rename(to: newName)
    }
}

// MARK: convenience

extension File {
    convenience
    public init(name: String) {
        self.init(name: name, at: Directory.current?.path ?? "~/")
    }

    convenience
    public init(path: Path) throws {
        var path = path
        guard let name = path.components.popLast() else {
            throw Error.invalidPath
        }
        self.init(name: name, at: path)
    }

    convenience
    public init(string: String) throws {
        try self.init(path: .init(string))
    }
}

// MARK: description

extension File: CustomStringConvertible {
    public var description: String {
        return "file://" + path.description
    }
}

// MARK: utils

extension String {
    var pathSeparator: Character {
        #if os(Windows)
        return "\\"
        #else
        return "/"
        #endif
    }

    var isValidFileName: Bool {
        return !contains(pathSeparator)
    }
}
