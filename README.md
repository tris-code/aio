# Socket

Blocking sockets with non-blocking awaiter designed for cooperative multitasking.

Another way to achieve that behaviour would be using blocking Socket base class and AsyncSocket subclass,<br>
but it will lead to more complex and tied code, plus the last time we checked it was significantly slower,<br>
while our primary goal is to have zero-cost non-blocking socket for cooperative multitasking.<br>
But we will revisit this design soon.

## Package.swift

 ```swift
.Package(url: "https://github.com/tris-foundation/socket.git", majorVersion: 0)
```

## Usage

You can find this code and more in [examples](https://github.com/tris-foundation/examples).

```swift
// you can also use AsyncDispatch fallback
// see the first README.md commit to get the idea

let async = AsyncFiber()
let hey = [UInt8]("hey there!".utf8)

async.task {
    do {
        let socket = try Socket(awaiter: async.awaiter)
        try socket.listen(at: "127.0.0.1", port: 7654)
        while true {
            let client = try socket.accept()
            let written = try client.write(bytes: hey)
        }
    } catch {
        print("server socket error \(error)")
    }
}

async.task {
    do {
        for _ in 0..<10 {
            let socket = try Socket(awaiter: async.awaiter)
            try socket.connect(to: "127.0.0.1", port: 7654)

            var buffer = [UInt8](repeating: 0, count: 100)
            let read = try socket.read(to: &buffer)

            print(String(cString: buffer))
        }
        exit(0)
    } catch {
        print("client socket error \(error)")
    }
}

async.loop.run()
```
