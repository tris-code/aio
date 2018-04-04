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

public class Directory {
    public let path: Path

    var handle: DirectoryHandle?

    public init(path: Path) {
        self.path = path
        self.handle = nil
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
        self.handle = try systemError {
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
        try systemError { rmdir(path.string) }
    }
}

// MARK: static

extension Directory {
    static var current: Directory? {
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
            try systemError { mkdir(path.string, permissions.rawMask) }
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
}

// MARK: description / equatable

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
