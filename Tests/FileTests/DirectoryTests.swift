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
        assertEqual(directory.description, "/tmp")
    }

    func testName() {
        let directory = Directory(name: "test")
        assertEqual(directory.name, "test")
    }

    func testLocation() {
        let directory = Directory(name: "test", at: "/tmp")
        assertEqual(directory.name, "test")
        assertEqual(directory.location.string, "/tmp")
    }

    func testPath() {
        let directory = Directory(at: "/tmp")
        assertEqual(directory.location, "/")
        assertEqual(directory.name, "tmp")
        assertEqual(directory.path, "/tmp")
    }

    func testExists() {
        let directory = Directory(at: temp.appending("testExists"))
        assertFalse(directory.isExists)
    }

    func testCreate() {
        let directory = Directory(at: temp.appending("testCreate"))
        assertFalse(directory.isExists)
        assertNoThrow(try directory.create())
        assertTrue(directory.isExists)
    }

    func testCreateIntermediate() {
        let path = temp.appending("testCreateIntermediate/one/two")
        let directory = Directory(at: path)

        assertFalse(directory.isExists)
        assertNoThrow(try directory.create(withIntermediateDirectories: true))
        assertTrue(directory.isExists)
    }

    func testRemove() {
        let directory = Directory(at: temp.appending("testRemove"))
        assertNoThrow(try directory.create())
        assertNoThrow(try directory.remove())
        assertFalse(directory.isExists)
    }

    func testRemoveWithContent() {
        let path = temp.appending("testRemoveWithContent")
        assertNoThrow(try Directory.create(at: path.appending("one")))
        assertNoThrow(try Directory.remove(at: path))
        assertFalse(Directory.isExists(at: path))
    }

    func testCurrent() {
        #if Xcode
        assertEqual(Directory.current, "/private/tmp")
        #else
        let aio = Directory.current?.path.string.suffix(3).uppercased()
        assertEqual(aio, "AIO")
        #endif

        Directory.current = Directory(at: temp)

        #if os(macOS)
        assertEqual(Directory.current, "/private/tmp/DirectoryTests")
        #else
        assertEqual(Directory.current, "/tmp/DirectoryTests")
        #endif
    }

    func testChangeWorkingDirectory() {
        scope {
            guard let previous = Directory.current else {
                fail()
                return
            }

            try Directory.changeWorkingDirectory(to: "/")
            assertEqual(Directory.current, "/")

            try Directory.changeWorkingDirectory(to: "/tmp")
            #if os(macOS)
            assertEqual(Directory.current, "/private/tmp")
            #else
            assertEqual(Directory.current, "/tmp")
            #endif

            try Directory.changeWorkingDirectory(to: previous.path)
        }
    }

    func testInitFromString() {
        let path: String = "/"
        let directory = Directory(at: path)
        assertTrue(directory.isExists)
    }

    func testContents() {
        scope {
            let temp = self.temp.appending(#function)
            let dir1 = Directory(name: "dir1", at: temp)
            try dir1.create()

            let directory = Directory(at: temp)
            let contents = try directory.contents()

            assertEqual(contents, [Directory.Entry(
                path: temp.appending("dir1"),
                isDirectory: true)])
        }
    }

    func testEquatable() {
        assertNotEqual(Directory(at: "/tmp"), Directory(at: "/"))
        assertEqual(Directory(at: "/"), Directory(at: "/"))
        assertTrue(Directory("/") == String("/"))
        assertTrue(String("/") == Directory("/"))
    }

    func testStringProtocol() {
        _ = Directory(at: "/tmp"[...])
        _ = Directory(name: "tmp"[...])
        _ = Directory(name: "tmp"[...], at: "/"[...])
        _ = Directory(name: "tmp"[...], at: Path("/"))
        assertTrue(Directory(at: "/") == String("/")[...])
        assertTrue(String("/")[...] == Directory(at: "/"))
    }
}
