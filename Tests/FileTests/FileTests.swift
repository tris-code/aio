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

import Test
import Stream
import Platform
import File

@testable import struct File.Permissions

final class FileTests: TestCase {
    var temp = Path("/tmp/FileTests")

    override func setUp() {
        try? Directory.create(at: temp)
    }

    override func tearDown() {
        try? Directory.remove(at: temp)
    }

    func testName() {
        let file = File(name: "test.file")
        assertEqual(file.name, "test.file")
    }

    func testInit() {
        let file = File(name: #function, at: temp)
        assertEqual(file.name, #function)
        assertEqual(file.location, temp)
        assertEqual(file.path, temp.appending(#function))
    }

    func testInitPath() {
        scope {
            let file = try File(path: temp.appending(#function))
            assertEqual(file.name, #function)
            assertEqual(file.location, temp)
            assertEqual(file.path, temp.appending(#function))
        }
    }

    func testInitString() {
        scope {
            let file = try File(string: temp.appending(#function).string)
            assertEqual(file.name, #function)
            assertEqual(file.location, temp)
            assertEqual(file.path, temp.appending(#function))
        }
    }

    func testDescription() {
        let file = File(name: #function, at: temp)
        assertEqual(file.description, "file://\(temp)/\(#function)")
    }

    func testOpen() {
        let file = File(name: #function, at: temp)
        assertThrowsError(try file.open(flags: .read))
        assertThrowsError(try file.open(flags: .write))

        assertNoThrow(try file.open(flags: .create))

        assertThrowsError(try file.open(flags: .read)) { error in
            assertEqual(error as? File.Error, .alreadyOpened)
        }
        assertNoThrow(try file.close())

        assertNoThrow(try file.open(flags: .write))
        assertNoThrow(try file.close())

        assertNoThrow(try file.open(flags: [.read, .write]))
        assertNoThrow(try file.close())

        assertNoThrow(try file.remove())
    }

    func testCreateExists() {
        let file = File(name: #function, at: temp)
        assertFalse(file.isExists)
        assertNoThrow(try file.create())
        assertTrue(file.isExists)
    }

    func testReadWrite() {
        scope {
            let file = File(name: "test.read-write", at: temp)
            let stream = try file.open(flags: [.write, .create, .truncate])
            try stream.write("test string")
        }

        scope {
            let file = File(name: "test.read-write", at: temp)
            let string = try String(reading: file, as: UTF8.self)
            assertEqual(string, "test string")
            try file.remove()
        }
    }

    func testRename() {
        scope {
            let file = File(name: "test.move", at: temp)
            try file.create()

            try file.rename(to: "new-test.move")
            assertFalse(File.isExists(at: temp.appending("test.move")))
            assertTrue(File.isExists(at: temp.appending("new-test.move")))
        }

        scope {
            try File.rename("new-test.move", to: "test.move", at: temp)
            assertTrue(File.isExists(at: temp.appending("test.move")))
            assertFalse(File.isExists(at: temp.appending("new-test.move")))
        }
    }

    func testLifetime() {
        var streamReader: StreamReader? = nil

        scope {
            let file = File(name: "test.lifetime", at: temp)
            let stream = try file.open(flags: [.read, .write, .create])
            try stream.write("test string")
            try stream.flush()
            try stream.seek(to: .begin)

            streamReader = stream
        }

        guard let reader = streamReader else {
            fail()
            return
        }

        scope {
            let string = try String(readingFrom: reader, as: UTF8.self)
            assertEqual(string, "test string")
        }
    }

    func testPermissions() {
        let permissions = Permissions.file
        assertEqual(permissions.rawValue, 0x644)
        assertEqual(permissions.owner, [.read, .write])
        assertEqual(permissions.group, .read)
        assertEqual(permissions.others, .read)

        assertEqual(permissions.rawMask, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH)
    }
}
