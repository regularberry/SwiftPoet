//
//  FieldSpecTests.swift
//  SwiftPoet
//
//  Created by Kyle Dorman on 8/1/17.
//  Copyright © 2017 Gilt Groupe. All rights reserved.
//

import XCTest
import SwiftPoet

class FieldSpecTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testComputedProperty() {
        /*
         var hashValue: Int {
            return x.hashValue ^ y.hashValue &* 16777619
         }
        */
        let field = FieldSpec.builder(for: "hashValue", type: TypeName.IntegerType, construct: .mutableParam)
            .add(initializer: CodeBlock.builder()
                .add(literal: "return x.hashValue ^ y.hashValue &* 16777619")
                .build())
            // adding the parent is done automatically when a field is added to an enum, struct, and class.
            .add(parentType: .`enum`)
            .build()

        let result =
        "var hashValue: Int {\n" +
        "    return x.hashValue ^ y.hashValue &* 16777619\n" +
        "}"

        XCTAssertEqual(result, field.toString())

//        print(field.toString())
//        print(result)
    }

}

