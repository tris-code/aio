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
import File
import Platform

final class PathTests: TestCase {
    func testDescription() {
        let path = Path("/tmp/test")
        assertEqual(path.description, "/tmp/test")
    }

    func testAbsolutePath() {
        let path = Path("/tmp/test")
        assertEqual(path.components, ["tmp", "test"])
        assertEqual(path.type, .absolute)
    }

    func testRelativePath() {
        let path = Path("tmp/test")
        assertEqual(path.components, ["tmp", "test"])
        assertEqual(path.type, .relative)
    }

    func testString() {
        let string = "/tmp/test"
        let path = Path(string)
        assertEqual(path.components, ["tmp", "test"])
        assertEqual(path.string, string)
    }

    func testAppend() {
        var path = Path("/tmp")
        path.append("test")
        assertEqual(path.string, "/tmp/test")
    }

    func testAppending() {
        let path = Path("/tmp")
        let test = path.appending("test")
        assertEqual(test.string, "/tmp/test")
    }

    func testAppendingMany() {
        let path = Path("/tmp")
        let test = path.appending("one/two")
        assertEqual(test.string, "/tmp/one/two")
        assertEqual(test.components, ["tmp", "one", "two"])
    }

    func testAppendPath() {
        scope {
            var path = Path("/tmp")
            path.append(.init("test"))
            assertEqual(path.string, "/tmp/test")
        }
    }

    func testAppendingPath() {
        scope {
            let path = Path("/tmp")
            let test = Path("test")
            let combined = path.appending(test)
            assertEqual(combined.string, "/tmp/test")
        }
    }

    func testDeletingLastComponent() {
        let path = Path("/tmp/test")
        let tmp = path.deletingLastComponent
        assertEqual(tmp.string, "/tmp")
    }

    func testExpandTilde() {
        scope {
            // TODO: Fix the CI
            guard let home = Environment["HOME"],
                !home.isEmpty else {
                    return
            }
            let path = Path("~/test")
            let homeTest = try path.expandingTilde()

            var copy = path
            try copy.expandTilde()
            assertEqual(homeTest, copy)

            #if os(macOS)
            assertTrue(homeTest.string.starts(with: "/Users"))
            #else
            if !homeTest.string.starts(with: "/home") {
                assertTrue(homeTest.string.starts(with: "/root"))
            }
            #endif
            assertEqual(homeTest.string.suffix(5), "/test")
        }
    }

    func testEquatable() {
        assertEqual(Path("/"), Path("/"))
        assertTrue(Path("/") == String("/"))
        assertTrue(String("/") == Path("/"))
    }

    func testStringProtocol() {
        var path = Path("/"[...])
        path.append("component"[...])
        _ = path.appending("component"[...])
        assertTrue(Path("/") == String("/")[...])
        assertTrue(String("/")[...] == Path("/"))
    }
}
