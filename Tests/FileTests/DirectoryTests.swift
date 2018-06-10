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
import Platform
import File

final class DirectoryTests: TestCase {
    let temp = Path(string: "/tmp/DirectoryTests")

    override func setUp() {
        try? Directory.create(at: temp)
    }

    override func tearDown() {
        try? Directory.remove(at: temp)
    }

    func testDescription() {
        let directory = Directory(path: "/tmp")
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
        let directory = Directory(path: "/tmp")
        assertEqual(directory.path, "/tmp")
    }

    func testExist() {
        let directory = Directory(path: temp.appending("testExist"))
        assertFalse(directory.isExist)
    }

    func testCreate() {
        let directory = Directory(path: temp.appending("testCreate"))
        assertFalse(directory.isExist)
        assertNoThrow(try directory.create())
        assertTrue(directory.isExist)
    }

    func testCreateIntermediate() {
        let directory = Directory(
            path: temp.appending("testCreateIntermediate/one/two"))

        assertFalse(directory.isExist)
        assertNoThrow(try directory.create(withIntermediateDirectories: true))
        assertTrue(directory.isExist)
    }

    func testRemove() {
        let directory = Directory(path: temp.appending("testRemove"))
        assertNoThrow(try directory.create())
        assertNoThrow(try directory.remove())
        assertFalse(directory.isExist)
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

        Directory.current = Directory(path: temp)

        #if os(macOS)
        assertEqual(Directory.current, "/private/tmp/DirectoryTests")
        #else
        assertEqual(Directory.current, "/tmp/DirectoryTests")
        #endif
    }
}
