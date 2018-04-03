import XCTest

import NetworkTests
import FileTests

var tests = [XCTestCaseEntry]()
tests += NetworkTests.__allTests()
tests += FileTests.__allTests()

XCTMain(tests)
