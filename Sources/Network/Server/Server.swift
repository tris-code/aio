/******************************************************************************
 *                                                                            *
 * Tris Foundation disclaims copyright to this source code.                   *
 * In place of a legal notice, here is a blessing:                            *
 *                                                                            *
 *     May you do good and not evil.                                          *
 *     May you find forgiveness for yourself and forgive others.              *
 *     May you share freely, never taking more than you give.                 *
 *                                                                            *
 ******************************************************************************
 *  This file contains code that has not yet been described                   *
 ******************************************************************************/

import Log
import Platform

public class Server {
    public let socket: Socket

    public var onClient: (Socket) -> Void = { _ in }
    public var onError: (Error) -> Void = { _ in }

    public var address: String {
        return socket.selfAddress!.description
    }

    public init(host: String, port: Int) throws {
        let socket = try Socket()
        try socket.bind(to: host, port: port)
        self.socket = socket
        self.onClient = handleClient
        self.onError = handleError
    }

    convenience
    public init(host: String, reusePort: Int) throws {
        try self.init(host: host, port: reusePort)
        try socket.options.set(.reusePort, true)
    }

    deinit {
        try? socket.close()
    }

    public func start() throws {
        try socket.listen()
        while true {
            do {
                let client = try self.socket.accept()
                async.task { [unowned self] in
                    self.onClient(client)
                }
            } catch {
                onError(error)
            }
        }
    }

    func handleClient (_ socket: Socket) {
        try? socket.close()
        log(event: .warning, message: "unhandled client")
    }

    func handleError (_ error: Error) {
        switch error {
            /* connection reset by peer */
            /* do nothing, it's fine. */
        case let error as SocketError where error.number == ECONNRESET: break
            /* connection closed */
        case let error as NetworkStream.Error where error == .closed: break
            /* log other errors */
        default: log(event: .error, message: String(describing: error))
        }
    }
}
