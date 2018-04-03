import XCTest

extension AbstractionTests {
    static let __allTests = [
        ("testFamily", testFamily),
        ("testSocketType", testSocketType),
    ]
}

extension AddressTests {
    static let __allTests = [
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
    static let __allTests = [
        ("testRequest", testRequest),
        ("testResponse", testResponse),
    ]
}

extension DNSTests {
    static let __allTests = [
        ("testMakeRequest", testMakeRequest),
        ("testPerformance", testPerformance),
        ("testResolve", testResolve),
    ]
}

extension IPTests {
    static let __allTests = [
        ("testIPAddress", testIPAddress),
        ("testIPv4", testIPv4),
        ("testIPv6", testIPv6),
    ]
}

extension NetworkStreamTests {
    static let __allTests = [
        ("testNetworkStream", testNetworkStream),
        ("testNetworkStreamError", testNetworkStreamError),
    ]
}

extension OptionsTests {
    static let __allTests = [
        ("testConfigureBroadcast", testConfigureBroadcast),
        ("testConfigureReusePort", testConfigureReusePort),
        ("testNoSignalPipe", testNoSignalPipe),
        ("testReuseAddr", testReuseAddr),
        ("testReuseAddrUnix", testReuseAddrUnix),
        ("testReusePort", testReusePort),
    ]
}

extension SocketTests {
    static let __allTests = [
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

#if !os(macOS)
public func __allTests() -> [XCTestCaseEntry] {
    return [
        testCase(AbstractionTests.__allTests),
        testCase(AddressTests.__allTests),
        testCase(DNSMessageTests.__allTests),
        testCase(DNSTests.__allTests),
        testCase(IPTests.__allTests),
        testCase(NetworkStreamTests.__allTests),
        testCase(OptionsTests.__allTests),
        testCase(SocketTests.__allTests),
    ]
}
#endif
