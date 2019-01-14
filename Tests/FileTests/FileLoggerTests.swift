import Test
import File
@testable import Log

class FileLoggerTests: TestCase {
    var temp = Path("/tmp/FileLoggerTests")

    var isEnabled: Bool! = nil
    var level: Log.Message.Level! = nil
    var delegate: LogProtocol! = nil

    override func setUp() {
        try? Directory.create(at: temp)

        isEnabled = Log.isEnabled
        level = Log.level
        delegate = Log.delegate
    }

    override func tearDown() {
        try? Directory.remove(at: temp)

        Log.isEnabled = isEnabled
        Log.level = level
        Log.delegate = delegate
    }

    func testFileLogger() {
        scope {
            let file = try File(name: #function, at: temp)
            assertFalse(file.isExists)

            Log.use(try FileLogger(file))
            Log.info("message")

            assertTrue(file.isExists)
        }

        scope {
            let file = try File(name: #function, at: temp)
            let stream = try file.open(flags: .read).inputStream
            let content = try stream.readUntilEnd(as: String.self)
            assertEqual(content, "[info] message\n")
        }
    }
}
