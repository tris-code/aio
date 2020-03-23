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

    func testName() throws {
        let file = try File(name: "file")
        expect(file.name == "file")
        expect(throws: File.Error.invalidName) {
            _ = try File(name: "")
        }
    }

    func testInit() throws {
        let file = try File(name: #function, at: temp)
        expect(file.name == #function)
        expect(file.location == temp)
        expect(file.path == temp.appending(#function))
    }

    func testInitPath() throws {
        let file = try File(at: temp.appending(#function))
        expect(file.name == #function)
        expect(file.location == temp)
        expect(file.path == temp.appending(#function))
    }

    func testInitString() throws {
        let file = try File(at: temp.appending(#function).string)
        expect(file.name == #function)
        expect(file.location == temp)
        expect(file.path == temp.appending(#function))
    }

    func testDescription() throws {
        let file = try File(name: #function, at: temp)
        expect(file.description == "file://\(temp)/\(#function)")
    }

    func testOpen() throws {
        let file = try File(name: #function, at: temp)
        expect(throws: File.Error.doesntExist) {
            _ = try file.open(flags: .read)
        }
        expect(throws: File.Error.doesntExist) {
            _ = try file.open(flags: .write)
        }

        _ = try file.open(flags: .create)

        expect(throws: File.Error.alreadyOpened) {
            _ = try file.open(flags: .read)
        }

        try file.close()

        _ = try file.open(flags: .write)
        try file.close()

        _ = try file.open(flags: [.read, .write])
        try file.close()

        try file.remove()
    }

    func testCreateExists() throws {
        let file = try File(name: #function, at: temp)
        expect(!file.isExists)
        try file.create()
        expect(file.isExists)
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
            expect(string == "test string")
            try file.remove()
        }
    }

    func testRename() {
        scope {
            let file = try File(name: "test.move", at: temp)
            try file.create()

            try file.rename(to: "new-test.move")
            expect(!File.isExists(at: temp.appending("test.move")))
            expect(File.isExists(at: temp.appending("new-test.move")))
        }

        scope {
            try File.rename("new-test.move", to: "test.move", at: temp)
            expect(File.isExists(at: temp.appending("test.move")))
            expect(!File.isExists(at: temp.appending("new-test.move")))
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
            expect(string == "test string")
        }
    }

    func testPermissions() {
        let permissions = Permissions.file
        expect(permissions.rawValue == 0x644)
        expect(permissions.owner == [.read, .write])
        expect(permissions.group == .read)
        expect(permissions.others == .read)

        expect(permissions.rawMask == S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH)
    }

    func testEquatable() throws {
        expect(try File(at: "/tmp/file") != (try File(at: "/file")))
        expect(try File(at: "/file") == (try File(at: "/file")))
        expect(try File(at: "/file") == String("/file"))
        expect(String("/file") == (try File(at: "/file")))
    }

    func testStringProtocol() throws {
        _ = try File(at: "/file"[...])
        _ = try File(name: "file"[...])
        _ = try File(name: "file"[...], at: "/"[...])
        _ = try File(name: "file"[...], at: Path("/"))
        expect(try File(at: "/file") == String("/file")[...])
        expect(String("/file")[...] == (try File(at: "/file")))
    }

    func testSize() throws {
        let file = try File(name: #function, at: temp)
        try file.create()
        expect(file.size == 0)
        let stream = try file.open(flags: .write)
        try stream.write(.a)
        try stream.flush()
        expect(file.size == 1)
    }
}
