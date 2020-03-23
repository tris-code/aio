import Test
import Platform
import File

final class DirectoryTests: TestCase {
    let temp = Path("/tmp/DirectoryTests")

    override func setUp() {
        try? Directory.create(at: temp)
    }

    override func tearDown() {
        try? Directory.remove(at: temp)
    }

    func testDescription() {
        let directory = Directory(at: "/tmp")
        expect(directory.description == "/tmp")
    }

    func testName() {
        let directory = Directory(name: "test")
        expect(directory.name == "test")
    }

    func testLocation() {
        let directory = Directory(name: "test", at: "/tmp")
        expect(directory.name == "test")
        expect(directory.location.string == "/tmp")
    }

    func testPath() {
        let directory = Directory(at: "/tmp")
        expect(directory.location == "/")
        expect(directory.name == "tmp")
        expect(directory.path == "/tmp")
    }

    func testExists() {
        let directory = Directory(at: temp.appending("testExists"))
        expect(!directory.isExists)
    }

    func testCreate() throws {
        let directory = Directory(at: temp.appending("testCreate"))
        expect(!directory.isExists)
        try directory.create()
        expect(directory.isExists)
    }

    func testCreateIntermediate() throws {
        let path = temp.appending("testCreateIntermediate/one/two")
        let directory = Directory(at: path)

        expect(!directory.isExists)
        try directory.create(withIntermediateDirectories: true)
        expect(directory.isExists)
    }

    func testRemove() throws {
        let directory = Directory(at: temp.appending("testRemove"))
        try directory.create()
        try directory.remove()
        expect(!directory.isExists)
    }

    func testRemoveWithContent() throws {
        let path = temp.appending("testRemoveWithContent")
        try Directory.create(at: path.appending("one"))
        try Directory.remove(at: path)
        expect(!Directory.isExists(at: path))
    }

    func testCurrent() {
        #if Xcode
        expect(Directory.current == "/private/tmp")
        #else
        let aio = Directory.current?.path.string.suffix(3).uppercased()
        expect(aio == "AIO")
        #endif

        Directory.current = Directory(at: temp)

        #if os(macOS)
        expect(Directory.current == "/private/tmp/DirectoryTests")
        #else
        expect(Directory.current == "/tmp/DirectoryTests")
        #endif
    }

    func testChangeWorkingDirectory() throws {
        guard let previous = Directory.current else {
            fail()
            return
        }

        try Directory.changeWorkingDirectory(to: "/")
        expect(Directory.current == "/")

        try Directory.changeWorkingDirectory(to: "/tmp")
        #if os(macOS)
        expect(Directory.current == "/private/tmp")
        #else
        expect(Directory.current == "/tmp")
        #endif

        try Directory.changeWorkingDirectory(to: previous.path)
    }

    func testInitFromString() {
        let path: String = "/"
        let directory = Directory(at: path)
        expect(directory.isExists)
    }

    func testContents() throws {
        let temp = self.temp.appending(#function)
        let dir1 = Directory(name: "dir1", at: temp)
        try dir1.create()

        let directory = Directory(at: temp)
        let contents = try directory.contents()

        expect(contents == [Directory.Entry(
            path: temp.appending("dir1"),
            isDirectory: true)])
    }

    func testEquatable() {
        expect(Directory(at: "/tmp") != Directory(at: "/"))
        expect(Directory(at: "/") == Directory(at: "/"))
        expect(Directory("/") == String("/"))
        expect(String("/") == Directory("/"))
    }

    func testStringProtocol() {
        _ = Directory(at: "/tmp"[...])
        _ = Directory(name: "tmp"[...])
        _ = Directory(name: "tmp"[...], at: "/"[...])
        _ = Directory(name: "tmp"[...], at: Path("/"))
        expect(Directory(at: "/") == String("/")[...])
        expect(String("/")[...] == Directory(at: "/"))
    }
}
