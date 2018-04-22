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

extension File {
    public struct Flags: OptionSet {
        public let rawValue: Int

        public init(rawValue: Int) {
            self.rawValue = rawValue
        }

        public static let read = Flags(rawValue: 1 << 0)
        public static let write = Flags(rawValue: 1 << 1)
        public static let create = Flags(rawValue: 1 << 2)
        public static let truncate = Flags(rawValue: 1 << 3)
    }

    // open flags use 0 for read, 1 for write and 2 for read/write
    // and doesn't allow us to use convenience [.read, .write] api

    struct OpenFlags: OptionSet {
        let rawValue: Int32

        init(rawValue: Int32) {
            self.rawValue = rawValue
        }

        init(_ flags: Flags) {
            var result = OpenFlags(rawValue: 0)

            if flags.contains(.read) && flags.contains(.write) {
                result.insert(.readWrite)
            } else if flags.contains(.read) {
                result.insert(.readOnly)
            } else if flags.contains(.write) {
                result.insert(.writeOnly)
            }

            if flags.contains(.create) {
                result.insert(.create)
            }
            if flags.contains(.truncate) {
                result.insert(.truncate)
            }
            self = result
        }

        static let readOnly = OpenFlags(rawValue: O_RDONLY)
        static let writeOnly = OpenFlags(rawValue: O_WRONLY)
        static let readWrite = OpenFlags(rawValue: O_RDWR)

        static let create = OpenFlags(rawValue: O_CREAT)
        static let truncate = OpenFlags(rawValue: O_TRUNC)
    }
}
