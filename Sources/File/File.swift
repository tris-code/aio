/*
 * Copyright 2017 Tris Foundation and the project authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License
 *
 * See LICENSE.txt in the project root for license information
 * See CONTRIBUTORS.txt for the list of the project authors
 */

import Stream
import Platform

public class File {
    var descriptor: Descriptor?

    public let name: String
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
        case invalidName = "Invalid file name"
        case alreadyOpened = "The file is already opened"
        case closed = "The file was closed or wasn't opened"
        case exists = "The file is already exists"
    }

    public init(
        name: String,
        at location: Path = Path(string: "~/"),
        bufferSize: Int = 4096)
    {
        self.name = name
        self.location = location
        self.bufferSize = bufferSize
    }

    public init(path: Path, bufferSize: Int = 4096) throws {
        var path = path
        guard let name = path.components.popLast() else {
            throw Error.invalidName
        }
        self.name = name
        self.location = path
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
        self.descriptor = Descriptor(rawValue: try systemError {
            return Platform.open(path.string, flags, permissions.rawMask)
        })

    }

    public func open(
        flags: Flags = .read,
        permissions: Permissions = .file) throws -> BufferedStream<File>
    {
        try open(flags, permissions)
        return BufferedStream(baseStream: self, capacity: bufferSize)
    }

    public func close() throws {
        if let descriptor = descriptor {
            try systemError { Platform.close(descriptor.rawValue) }
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
        try systemError { Platform.remove(path.string) }
    }
}

// MARK: static

extension File {
    public static func isExists(at path: Path) -> Bool {
        return access(path.string, F_OK) == 0
    }

    public static func remove(at path: Path) throws {
        try systemError { Platform.remove(path.string) }
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
}

// MARK: convenience

extension File {
    convenience
    public init(path: String, bufferSize: Int = 4096) throws {
        try self.init(path: Path(string: path), bufferSize: bufferSize)
    }
}

// MARK: description

extension File: CustomStringConvertible {
    public var description: String {
        return "file://" + path.description
    }
}