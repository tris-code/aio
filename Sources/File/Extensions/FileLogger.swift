import Log
import Stream

public class FileLogger: LogProtocol {
    let file: File
    let stream: File.Stream

    convenience
    public init(fileAtPath path: String) throws {
        try self.init(fileAt: Path(path))
    }

    convenience
    public init(fileAt path: Path) throws {
        try self.init(.init(at: path))
    }

    public init(_ file: File) throws {
        if !file.isExists {
            try file.create(withIntermediateDirectories: true)
        }
        let stream = try file.open(flags: .write)
        try stream.seek(to: .end)
        self.file = file
        self.stream = stream
    }

    func format(_ message: Log.Message) -> String {
        return "[\(message.level)] \(message.payload)"
    }

    public func handle(_ message: Log.Message) {
        do {
            let string = format(message)
            try stream.write(string)
            try stream.write("\n")
            try stream.flush()
        } catch {
            print("can't write log message:", message)
        }
    }
}
