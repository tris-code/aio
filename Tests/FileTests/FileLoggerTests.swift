import Test
import File
@testable import Log

class FileLoggerTests: TestCase {
    var temp = Path("/tmp/FileLoggerTests")

    var isEnabled: Bool! = nil
    var level: Log.Message.Level! = nil
    var delegate: LogProtocol! = nil

    override func setUpWithError() throws {
        isEnabled = Log.isEnabled
        level = Log.level
        delegate = Log.delegate

        try Directory.create(at: temp)
    }

    override func tearDownWithError() throws {
        Log.isEnabled = isEnabled
        Log.level = level
        Log.delegate = delegate

        try Directory.remove(at: temp)
    }

    func testFileLogger() {
        scope {
            let file = try File(name: #function, at: temp)
            expect(!file.isExists)

            Log.use(try FileLogger(file))
            Log.info("message")

            expect(file.isExists)
        }

        scope {
            let file = try File(name: #function, at: temp)
            let stream = try file.open(flags: .read).inputStream
            let content = try stream.readUntilEnd(as: String.self)
            expect(content == "[info] message\n")
        }
    }
}
