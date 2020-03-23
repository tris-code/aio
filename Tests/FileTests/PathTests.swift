import Test
import File
import Platform

final class PathTests: TestCase {
    func testDescription() {
        let path = Path("/tmp/test")
        expect(path.description == "/tmp/test")
    }

    func testAbsolutePath() {
        let path = Path("/tmp/test")
        expect(path.components == ["tmp", "test"])
        expect(path.type == .absolute)
    }

    func testRelativePath() {
        let path = Path("tmp/test")
        expect(path.components == ["tmp", "test"])
        expect(path.type == .relative)
    }

    func testString() {
        let string = "/tmp/test"
        let path = Path(string)
        expect(path.components == ["tmp", "test"])
        expect(path.string == string)
    }

    func testAppend() {
        var path = Path("/tmp")
        path.append("test")
        expect(path.string == "/tmp/test")
    }

    func testAppending() {
        let path = Path("/tmp")
        let test = path.appending("test")
        expect(test.string == "/tmp/test")
    }

    func testAppendingMany() {
        let path = Path("/tmp")
        let test = path.appending("one/two")
        expect(test.string == "/tmp/one/two")
        expect(test.components == ["tmp", "one", "two"])
    }

    func testAppendPath() {
        var path = Path("/tmp")
        path.append(.init("test"))
        expect(path.string == "/tmp/test")
    }

    func testAppendingPath() {
        let path = Path("/tmp")
        let test = Path("test")
        let combined = path.appending(test)
        expect(combined.string == "/tmp/test")
    }

    func testDeletingLastComponent() {
        let path = Path("/tmp/test")
        let tmp = path.deletingLastComponent
        expect(tmp.string == "/tmp")
    }

    func testExpandTilde() throws {
        // TODO: Fix the CI
        guard let home = Environment["HOME"],
            !home.isEmpty else {
                return
        }
        let path = Path("~/test")
        let homeTest = try path.expandingTilde()

        var copy = path
        try copy.expandTilde()
        expect(homeTest == copy)

        #if os(macOS)
        expect(homeTest.string.starts(with: "/Users"))
        #else
        if !homeTest.string.starts(with: "/home") {
            expect(homeTest.string.starts(with: "/root"))
        }
        #endif
        expect(homeTest.string.suffix(5) == "/test")
    }

    func testEquatable() {
        expect(Path("/") == Path("/"))
        expect(Path("/") == String("/"))
        expect(String("/") == Path("/"))
    }

    func testStringProtocol() {
        var path = Path("/"[...])
        path.append("component"[...])
        _ = path.appending("component"[...])
        expect(Path("/") == String("/")[...])
        expect(String("/")[...] == Path("/"))
    }
}
