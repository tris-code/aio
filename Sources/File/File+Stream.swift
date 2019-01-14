import Stream
import Platform

extension File: Stream {
    public func read(
        to buffer: UnsafeMutableRawPointer,
        byteCount: Int) throws -> Int
    {
        guard let descriptor = descriptor else {
            throw Error.closed
        }
        return try system {
            return Platform.read(descriptor.rawValue, buffer, byteCount)
        }
    }

    public func write(
        from buffer: UnsafeRawPointer,
        byteCount: Int) throws -> Int
    {
        guard let descriptor = descriptor else {
            throw Error.closed
        }
        return try system {
            return Platform.write(descriptor.rawValue, buffer, byteCount)
        }
    }
}
