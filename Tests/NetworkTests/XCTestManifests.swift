#if !canImport(ObjectiveC)
import XCTest

extension AbstractionTests {
    // DO NOT MODIFY: This is autogenerated, use: 
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__AbstractionTests = [
        ("testFamily", testFamily),
        ("testSocketType", testSocketType),
    ]
}

extension AddressTests {
    // DO NOT MODIFY: This is autogenerated, use: 
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__AddressTests = [
        ("testIP4DNSResolve", testIP4DNSResolve),
        ("testIPv4", testIPv4),
        ("testIPv4Detect", testIPv4Detect),
        ("testIPv6", testIPv6),
        ("testIPv6Detect", testIPv6Detect),
        ("testLocal6Address", testLocal6Address),
        ("testLocalAddress", testLocalAddress),
        ("testRemote6Address", testRemote6Address),
        ("testRemoteAddress", testRemoteAddress),
        ("testUnix", testUnix),
        ("testUnixDetect", testUnixDetect),
    ]
}

extension DNSMessageTests {
    // DO NOT MODIFY: This is autogenerated, use: 
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__DNSMessageTests = [
        ("testRequest", testRequest),
        ("testResponse", testResponse),
    ]
}

extension DNSTests {
    // DO NOT MODIFY: This is autogenerated, use: 
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__DNSTests = [
        ("testMakeRequest", testMakeRequest),
        ("testPerformance", testPerformance),
        ("testResolve", testResolve),
    ]
}

extension IPTests {
    // DO NOT MODIFY: This is autogenerated, use: 
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__IPTests = [
        ("testIPAddress", testIPAddress),
        ("testIPv4", testIPv4),
        ("testIPv6", testIPv6),
    ]
}

extension NetworkStreamTests {
    // DO NOT MODIFY: This is autogenerated, use: 
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__NetworkStreamTests = [
        ("testNetworkStream", testNetworkStream),
        ("testNetworkStreamError", testNetworkStreamError),
    ]
}

extension OptionsTests {
    // DO NOT MODIFY: This is autogenerated, use: 
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__OptionsTests = [
        ("testConfigureBroadcast", testConfigureBroadcast),
        ("testConfigureReusePort", testConfigureReusePort),
        ("testNoSignalPipe", testNoSignalPipe),
        ("testReuseAddr", testReuseAddr),
        ("testReuseAddrUnix", testReuseAddrUnix),
        ("testReusePort", testReusePort),
    ]
}

extension SocketTests {
    // DO NOT MODIFY: This is autogenerated, use: 
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__SocketTests = [
        ("testSocket", testSocket),
        ("testSocketInet6Datagram", testSocketInet6Datagram),
        ("testSocketInet6Stream", testSocketInet6Stream),
        ("testSocketInetDatagram", testSocketInetDatagram),
        ("testSocketInetStream", testSocketInetStream),
        ("testSocketUnixDatagram", testSocketUnixDatagram),
        ("testSocketUnixSequenced", testSocketUnixSequenced),
        ("testSocketUnixStream", testSocketUnixStream),
    ]
}

extension SystemLoggerTests {
    // DO NOT MODIFY: This is autogenerated, use: 
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__SystemLoggerTests = [
        ("testSystemLogger", testSystemLogger),
    ]
}

public func __allTests() -> [XCTestCaseEntry] {
    return [
        testCase(AbstractionTests.__allTests__AbstractionTests),
        testCase(AddressTests.__allTests__AddressTests),
        testCase(DNSMessageTests.__allTests__DNSMessageTests),
        testCase(DNSTests.__allTests__DNSTests),
        testCase(IPTests.__allTests__IPTests),
        testCase(NetworkStreamTests.__allTests__NetworkStreamTests),
        testCase(OptionsTests.__allTests__OptionsTests),
        testCase(SocketTests.__allTests__SocketTests),
        testCase(SystemLoggerTests.__allTests__SystemLoggerTests),
    ]
}
#endif
