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
import Foundation
import File

final class PathTests: TestCase {
    func testDescription() {
        let path = Path(string: "/tmp/test")
        assertEqual(path.description, "/tmp/test")
    }

    func testAbsolutePath() {
        let path = Path(string: "/tmp/test")
        assertEqual(path.components, ["tmp", "test"])
        assertEqual(path.type, .absolute)
    }

    func testRelativePath() {
        let path = Path(string: "tmp/test")
        assertEqual(path.components, ["tmp", "test"])
        assertEqual(path.type, .relative)
    }

    func testString() {
        let string = "/tmp/test"
        let path = Path(string: string)
        assertEqual(path.components, ["tmp", "test"])
        assertEqual(path.string, string)
    }

    func testAppending() {
        let path = Path(string: "/tmp")
        let test = path.appending("test")
        assertEqual(test.string, "/tmp/test")
    }

    func testAppendingMany() {
        let path = Path(string: "/tmp")
        let test = path.appending("one/two")
        assertEqual(test.components.count, 3)
    }

    func testDeletingLastComponent() {
        let path = Path(string: "/tmp/test")
        let tmp = path.deletingLastComponent()
        assertEqual(tmp.string, "/tmp")
    }

    func testExpandTilde() {
        scope {
            // TODO: Fix the CI
            guard let home = ProcessInfo.processInfo.environment["HOME"],
                !home.isEmpty else {
                    return
            }
            let path = Path(string: "~/test")
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
}
