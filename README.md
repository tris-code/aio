# Network

Zero-cost socket abstraction with optional non-blocking awaiter designed for cooperative multitasking.

## Package.swift

 ```swift
.package(url: "https://github.com/tris-foundation/network.git", .branch("master"))
```

## Memo

```swift
final class Socket {
    enum Family {
        case inet, inet6, unspecified, unix
    }

    enum SocketType {
        case stream, datagram, sequenced
    }

    enum Address {
        init(_: String, port: UInt16? = nil) throws
        init(ip4: String, port: UInt16) throws
        init(ip6: String, port: UInt16) throws
        init(unix: String) throws
    }

    init(descriptor: Int32? = nil, family: Family = .tcp, type: SocketType = .stream, awaiter: IOAwaiter? = nil) throws

    func bind(to: Address) throws -> Socket
    func listen() throws -> Socket

    func accept() throws -> Socket
    func connect(to: Address) throws -> Socket

    func close(silent: Bool = false) throws

    func send(buffer: UnsafeRawPointer, count: Int) throws -> Int
    func send(buffer: UnsafeRawPointer, count: Int, to: Address) throws -> Int

    func receive(buffer: UnsafeMutableRawPointer, count: Int) throws -> Int
    func receive(buffer: UnsafeMutableRawPointer, count: Int, from: inout Address?) throws -> Int
}

extension Socket {
    func bind(to: String, port: UInt16) throws -> Socket
    func bind(to: String) throws -> Socket

    func connect(to: String, port: UInt16) throws -> Socket
    func connect(to: String) throws -> Socket

    func send(bytes: [UInt8]) throws -> Int
    func send(bytes: [UInt8], to: Address) throws -> Int

    func receive(to: inout [UInt8]) throws -> Int
    func receive(to: inout [UInt8], from: inout Address?) throws -> Int
}
```

## Usage

You can find this code and more in [examples](https://github.com/tris-foundation/examples).

### Sync
```swift
let socket = try Socket()
```

### Async
```swift
import Fiber

async.use(Fiber.selfs)

async.task {
    let socket = try Socket()
    // use non-blocking api
}

async.loop.run()
```

```swift
let hello = [UInt8]("Hello, World!".utf8)
let empty = [UInt8](repeating: 0, count: hello.count + 1)
```

### TCP
```swift
async.task {
    do {
        let socket = try Socket()
            .bind(to: "127.0.0.1", port: 1111)
            .listen()

        let client = try socket.accept()
        _ = try client.send(bytes: hello)
    } catch {
        print("tcp server socket error \(error)")
    }
}

async.task {
    do {
        let socket = try Socket()
            .connect(to: "127.0.0.1", port: 1111)

        var buffer = empty
        _ = try socket.receive(to: &buffer)

        print("tcp: \(String(cString: buffer))")
    } catch {
        print("tcp client socket error \(error)")
    }
}
```

### UDP
```swift
let udpServerAddress = try Socket.Address("127.0.0.1", port: 2222)

async.task {
    do {
        let socket = try Socket(type: .datagram)
            .bind(to: udpServerAddress)

        var buffer = empty
        var client: Socket.Address? = nil
        _ = try socket.receive(to: &buffer, from: &client)
        _ = try socket.send(bytes: hello, to: client!)
    } catch {
        print("udp server socket error \(error)")
    }
}

async.task {
    do {
        let socket = try Socket(type: .datagram)

        var buffer = empty
        _ = try socket.send(bytes: hello, to: udpServerAddress)
        _ = try socket.receive(to: &buffer)

        print("udp: \(String(cString: buffer))")
    } catch {
        print("udp client socket error \(error)")
    }
}
```

### TCP IPv6
```swift
async.task {
    do {
        let socket = try Socket(family: .inet6)
            .bind(to: "::1", port: 3333)
            .listen()

        let client = try socket.accept()
        _ = try client.send(bytes: hello)
    } catch {
        print("ip6 server socket error \(error)")
    }
}

async.task {
    do {
        let socket = try Socket(family: .inet6)
            .connect(to: "::1", port: 3333)

        var buffer = empty
        _ = try socket.receive(to: &buffer)

        print("ip6: \(String(cString: buffer))")
    } catch {
        print("ip6 client socket error \(error)")
    }
}
```

### UNIX
```swift
#if os(Linux)
let type: Socket.SocketType = .sequenced
#else
let type: Socket.SocketType = .stream
#endif

unlink("/tmp/socketexample.sock")

async.task {
    do {
        let socket = try Socket(family: .unix, type: type)
            .bind(to: "/tmp/socketexample.sock")
            .listen()

        let client = try socket.accept()
        _ = try client.send(bytes: hello)
    } catch {
        print("unix server socket error \(error)")
    }
}

async.task {
    do {
        let socket = try Socket(family: .unix, type: type)
            .connect(to: "/tmp/socketexample.sock")

        var buffer = empty
        _ = try socket.receive(to: &buffer)

        print("unix: \(String(cString: buffer))")
    } catch {
        print("unix client socket error \(error)")
    }
}
```
