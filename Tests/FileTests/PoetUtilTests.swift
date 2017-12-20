//
//  PoetUtilTests.swift
//  SwiftPoet
//
//  Created by Kyle Dorman on 11/17/15.
//
//

import XCTest
@testable import SwiftPoet

class PoetUtilTests: XCTestCase {

    func testAddDataToList() {
        var list = [1, 2, 3, 4]
        PoetUtil.addUnique(5, to: &list)
        XCTAssertEqual(5, list.count)
    }

    func testAddDataToListNoRepeat() {
        var list = [1, 2, 3, 4]
        PoetUtil.addUnique(4, to: &list)

        XCTAssertEqual(4, list.count)
    }

    func testCleanTypeNameUnderscore() {
        let name = "test_underscore"
        XCTAssertEqual("TestUnderscore", name.cleaned(.typeName))
    }

    func testCleanTypeNameAllCaps() {
        let name = "TEST_ALL_CAPS"
        XCTAssertEqual("TESTALLCAPS", name.cleaned(.typeName))
    }

    func testTypeNameWithBrackets() {
        let name = "billing_address[street_line1]"
        XCTAssertEqual("BillingAddressStreetLine1", name.cleaned(.typeName))
    }

    func testcammelCaseNameWithBrackets() {
        let name = "billing_address[street_line1]"
        XCTAssertEqual("billingAddressStreetLine1", name.cleaned(.paramName))
    }

    func testCleanTypeNameSpaces() {
        let name = "test many spaces"
        XCTAssertEqual("TestManySpaces", name.cleaned(.typeName))
    }

    func testCamelCaseName() {
        let name = "test"
        XCTAssertEqual("test", name.cleaned(.paramName))
    }

    func testCamelCaseNameSpaces() {
        let name = "test test test"
        XCTAssertEqual("testTestTest", name.cleaned(.paramName))
    }

    func testCamelCaseNameUnderscores() {
        let name = "test_test_test"
        XCTAssertEqual("testTestTest", name.cleaned(.paramName))
    }

    func testCamelCaseNameAllCaps() {
        let name = "TEST_ALL_CAPS"
        XCTAssertEqual("testAllCaps", name.cleaned(.paramName))
    }

    func testUppercasedCaseName() {
        let name = "TEST"
        XCTAssertEqual("TEST", name.cleaned(.uppercasedName))
    }

    func testPeriodsInName() {
        let name = "test.periods.in.name"
        XCTAssertEqual("testPeriodsInName", name.cleaned(.paramName))
    }

}
