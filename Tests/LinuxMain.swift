/*
 * Copyright 2017 Tris Foundation and the project authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License
 *
 * See LICENSE.txt in the project root for license information
 * See CONTRIBUTORS.txt for the list of the project authors
 */

import XCTest
@testable import NetworkTests

XCTMain([
    testCase(IPTests.allTests),
    testCase(SocketTests.allTests),
    testCase(AddressTests.allTests),
    testCase(OptionsTests.allTests),
    testCase(AbstractionTests.allTests),
    testCase(PerformanceTests.allTests),
    testCase(DNSMessageTests.allTests),
    testCase(DNSTests.allTests),
    testCase(NetworkStreamTests.allTests),
])
