import XCTest

import FileTests
import NetworkTests

var tests = [XCTestCaseEntry]()
tests += FileTests.__allTests()
tests += NetworkTests.__allTests()

XCTMain(tests)
