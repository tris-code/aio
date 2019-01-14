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
        scope {
            let file = try File(name: "file")
            assertEqual(file.name, "file")
        }
        assertThrowsError(try File(name: "")) { error in
            assertEqual(error as? File.Error, .invalidName)
        }
    }

    func testInit() {
        scope {
            let file = try File(name: #function, at: temp)
            assertEqual(file.name, #function)
            assertEqual(file.location, temp)
            assertEqual(file.path, temp.appending(#function))
        }
    }

    func testInitPath() {
        scope {
            let file = try File(at: temp.appending(#function))
            assertEqual(file.name, #function)
            assertEqual(file.location, temp)
            assertEqual(file.path, temp.appending(#function))
        }
    }

    func testInitString() {
        scope {
            let file = try File(at: temp.appending(#function).string)
            assertEqual(file.name, #function)
            assertEqual(file.location, temp)
            assertEqual(file.path, temp.appending(#function))
        }
    }

    func testDescription() {
        scope {
            let file = try File(name: #function, at: temp)
            assertEqual(file.description, "file://\(temp)/\(#function)")
        }
    }

    func testOpen() {
        scope {
            let file = try File(name: #function, at: temp)
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
    }

    func testCreateExists() {
        scope {
            let file = try File(name: #function, at: temp)
            assertFalse(file.isExists)
            assertNoThrow(try file.create())
            assertTrue(file.isExists)
        }
    }

    func testReadWrite() {
        scope {
            let file = try File(name: "test.read-write", at: temp)
            let stream = try file.open(flags: [.write, .create, .truncate])
            try stream.write("test string")
        }

        scope {
            let file = try File(name: "test.read-write", at: temp)
            let string = try String(reading: file, as: UTF8.self)
            assertEqual(string, "test string")
            try file.remove()
        }
    }

    func testRename() {
        scope {
            let file = try File(name: "test.move", at: temp)
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
            let file = try File(name: "test.lifetime", at: temp)
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

    func testEquatable() {
        assertNotEqual(try File(at: "/tmp/file"), try File(at: "/file"))
        assertEqual(try File(at: "/file"), try File(at: "/file"))
        assertTrue(try File(at: "/file") == String("/file"))
        assertTrue(String("/file") == (try File(at: "/file")))
    }

    func testStringProtocol() {
        scope {
            _ = try File(at: "/file"[...])
            _ = try File(name: "file"[...])
            _ = try File(name: "file"[...], at: "/"[...])
            _ = try File(name: "file"[...], at: Path("/"))
            assertTrue(try File(at: "/file") == String("/file")[...])
            assertTrue(String("/file")[...] == (try File(at: "/file")))
        }
    }

    func testSize() {
        scope {
            let file = try File(name: #function, at: temp)
            try file.create()
            assertEqual(file.size, 0)
            let stream = try file.open(flags: .write)
            try stream.write(.a)
            try stream.flush()
            assertEqual(file.size, 1)
        }
    }
}
