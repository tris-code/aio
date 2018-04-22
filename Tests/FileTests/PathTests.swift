/*
 * Copyright 2017 Tris Foundation and the project authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License
 *
 * See LICENSE.txt in the project root for license information
 * See CONTRIBUTORS.txt for the list of the project authors
 */

import Test
import Foundation
@testable import File

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

    func testRemovingLastComponent() {
        let path = Path(string: "/tmp/test")
        let tmp = path.removingLastComponent()
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
            print(homeTest.string)
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
