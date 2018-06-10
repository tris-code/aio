import XCTest

extension DirectoryTests {
    static let __allTests = [
        ("testChangeWorkingDirectory", testChangeWorkingDirectory),
        ("testCreate", testCreate),
        ("testCreateIntermediate", testCreateIntermediate),
        ("testCurrent", testCurrent),
        ("testDescription", testDescription),
        ("testExist", testExist),
        ("testInitFromString", testInitFromString),
        ("testLocation", testLocation),
        ("testName", testName),
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
        ("testInitPath", testInitPath),
        ("testInitString", testInitString),
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
        ("testExpandTilde", testExpandTilde),
        ("testRelativePath", testRelativePath),
        ("testDeletingLastComponent", testDeletingLastComponent),
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
