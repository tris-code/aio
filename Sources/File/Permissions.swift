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

public struct Permissions: RawRepresentable {
    #if os(macOS)
    public typealias RawType = UInt16
    #else
    public typealias RawType = UInt32
    #endif

    public struct PermissionSet: OptionSet {
        public let rawValue: RawType

        public init(rawValue: RawType) {
            self.rawValue = rawValue
        }

        public static let execute = PermissionSet(rawValue: 1 << 0)
        public static let write = PermissionSet(rawValue: 1 << 1)
        public static let read = PermissionSet(rawValue: 1 << 2)
    }

    public var owner: PermissionSet
    public var group: PermissionSet
    public var others: PermissionSet

    public init(
        owner: PermissionSet,
        group: PermissionSet,
        others: PermissionSet)
    {
        self.owner = owner
        self.group = group
        self.others = others
    }

    public var rawValue: RawType {
        return owner.rawValue << 8 | group.rawValue << 4 | others.rawValue
    }

    public init(rawValue: RawType) {
        self.owner = PermissionSet(rawValue: rawValue >> 8 & 0b0111)
        self.group = PermissionSet(rawValue: rawValue >> 4 & 0b0111)
        self.others = PermissionSet(rawValue: rawValue & 0b0111)
    }

    /// rw-r--r--
    public static var file: Permissions {
        return Permissions(rawValue: 0x644)
    }

    /// rwxr-xr-x
    public static var directory: Permissions {
        return Permissions(rawValue: 0x0755)
    }

    /// rwxrwxrwx
    public static var intermediateDirectories: Permissions {
        return Permissions(rawValue: 0x0777)
    }
}

// MARK: conversion

extension Permissions {
    var rawMask: RawType {
        return owner.rawValue << 6 | group.rawValue << 3 | others.rawValue
    }

    init(rawMask: RawType) {
        self.owner = PermissionSet(rawValue: rawMask >> 6 & 0b0111)
        self.group = PermissionSet(rawValue: rawMask >> 3 & 0b0111)
        self.others = PermissionSet(rawValue: rawMask >> 0 & 0b0111)
    }
}

// MARK: utils

import Platform

extension Permissions {
    init(for descriptor: Descriptor) throws {
        var st = stat()
        try system { fstat(descriptor.rawValue, &st) }
        self = Permissions(rawMask: st.st_mode)
    }

    init?(for descriptor: Descriptor?) throws {
        guard let descriptor = descriptor else {
            return nil
        }
        try self.init(for: descriptor)
    }
}

extension Optional where Wrapped == Permissions {
    func set(for descriptor: Descriptor) throws {
        guard let newValue = self else {
            try system { fchmod(descriptor.rawValue, 0) }
            return
        }
        try system { fchmod(descriptor.rawValue, newValue.rawMask) }
    }

    func set(for descriptor: Descriptor?) throws {
        guard let descriptor = descriptor else {
            return
        }
        try set(for: descriptor)
    }
}
