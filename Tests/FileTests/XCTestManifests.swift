import XCTest

extension DirectoryTests {
    static let __allTests = [
        ("testCreate", testCreate),
        ("testCreateIntermediate", testCreateIntermediate),
        ("testDescription", testDescription),
        ("testExist", testExist),
        ("testPath", testPath),
        ("testRemove", testRemove),
        ("testRemoveWithContent", testRemoveWithContent),
    ]
}

extension FileTests {
    static let __allTests = [
        ("testCreateExists", testCreateExists),
        ("testDescription", testDescription),
        ("testInit", testInit),
        ("testLifetime", testLifetime),
        ("testName", testName),
        ("testOpen", testOpen),
        ("testPermissions", testPermissions),
        ("testReadWrite", testReadWrite),
    ]
}

extension PathTests {
    static let __allTests = [
        ("testAbsolutePath", testAbsolutePath),
        ("testAppending", testAppending),
        ("testAppendingMany", testAppendingMany),
        ("testDescription", testDescription),
        ("testRelativePath", testRelativePath),
        ("testRemovingLastComponent", testRemovingLastComponent),
        ("testString", testString),
    ]
}

#if !os(macOS)
public func __allTests() -> [XCTestCaseEntry] {
    return [
        testCase(DirectoryTests.__allTests),
        testCase(FileTests.__allTests),
        testCase(PathTests.__allTests),
    ]
}
#endif
