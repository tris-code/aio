import Platform

public struct SocketError: Error, Equatable, CustomStringConvertible {
    public let number: Int32
    public var description: String { .init(cString: strerror(errno)) }

    public init(number: Int32 = errno) {
        self.number = number
    }

    public var interrupted: Bool {
        return number == EAGAIN || number == EWOULDBLOCK || number == EINTR
    }

    public static var badDescriptor: SocketError {
        return SocketError(number: EBADF)
    }

    public static var invalidArgument: SocketError {
        return SocketError(number: EINVAL)
    }
}
