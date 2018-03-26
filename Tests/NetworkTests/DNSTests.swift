/*
 * Copyright 2017 Tris Foundation and the project authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License
 *
 * See LICENSE.txt in the project root for license information
 * See CONTRIBUTORS.txt for the list of the project authors
 */

import Test
import Dispatch
import AsyncDispatch

@testable import Async
@testable import Network

import struct Foundation.Date

class DNSTests: TestCase {
    override func setUp() {
        async.setUp(Dispatch.self)
    }

    func testMakeRequest() {
        do {
            let query = Message(domain: "duckduckgo.com", type: .a)
            let response = try DNS.makeRequest(query: query)

            for answer in response.answer {
                assertEqual(answer.name, "duckduckgo.com")
                assertTrue(answer.ttl > 0)
                switch answer.data {
                case .a(_): break
                default: fail()
                }
            }

            let nsServers: [ResourceData] = [
                .ns("ns0.dnsmadeeasy.com"),
                .ns("ns1.dnsmadeeasy.com"),
                .ns("ns2.dnsmadeeasy.com"),
                .ns("ns3.dnsmadeeasy.com"),
                .ns("ns4.dnsmadeeasy.com")
            ]

            for answer in response.authority {
                assertEqual(answer.name, "duckduckgo.com")
                assertTrue(answer.ttl > 0)
                assertTrue(nsServers.contains(answer.data))
            }
        } catch {
            fail(String(describing: error))
        }
    }

    func testResolve() {
        do {
            let response = try DNS.resolve(domain: "duckduckgo.com")
            for address in response {
                switch address {
                case .v4(_): break
                default: fail()
                }
            }
        } catch {
            fail(String(describing: error))
        }
    }

    func testPerformance() {
        let query = Message(domain: "duckduckgo.com", type: .a)

        measure {
            do {
                _ = try DNS.makeRequest(query: query)
            } catch {
                fail(String(describing: error))
            }
        }
    }
}
