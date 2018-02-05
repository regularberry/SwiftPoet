//
//  NestedTypeTest.swift
//  SwiftPoetTests
//
//  Created by Eugene Kazaev on 05/02/2018.
//  Copyright © 2018 Gilt Groupe. All rights reserved.
//

import XCTest
import SwiftPoet

class NestedTypeTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testClassNestedType() {
        let cb = ClassSpec.builder(for: "TopLevelClass")

        let eb = EnumSpec.builder(for: "NestedEnum")
        eb.add(description: "This is a test nested enum")
        eb.add(modifiers: [Modifier.Private, Modifier.Mutating])
        eb.add(protocols: [TypeName(keyword: "TestProtocol"), TypeName(keyword: "OtherProtocol")])

        let f1 = FieldSpec.builder(for: "test_case_one")
        f1.add(description: "This is the first test case")
        let cb1 = CodeBlock.builder()
        cb1.add(literal: "\"test_case_one\"")

        f1.add(initializer: cb1.build())

        eb.add(field: f1.build())

        cb.add(nestedType: eb.build())

        let classSpec = cb.build()

        let result = """
        class TopLevelClass {
        
            /**
                This is a test nested enum
            */
            private enum NestedEnum: TestProtocol, OtherProtocol {
                // This is the first test case
                case testCaseOne = \"test_case_one\"
            }
        
        }
        """

        XCTAssertEqual(result, classSpec.toString())
    }


    func testStructNestedType() {
        let sb = StructSpec.builder(for: "TopLevelStruct")
        sb.add(fields: [FieldSpec.builder(for: "v", type: TypeName.StringType, construct: .mutableParam).build()])

        let nsb = StructSpec.builder(for: "NestedStruct")
        nsb.add(description: "This is a test nested struct")
        nsb.add(fields: [FieldSpec.builder(for: "v1", type: TypeName.IntegerType, construct: .mutableParam).build()])
        sb.add(nestedType: nsb.build())

        let structSpec = sb.build()

        let result = """
        struct TopLevelStruct {
        
            /**
                This is a test nested struct
            */
            struct NestedStruct {
                var v1: Int
        
                /**
                    :param:    v1
                */
                internal init(v1: Int) {
                    
                    self.v1 = v1
                }
        
            }
        
            var v: String
        
            /**
                :param:    v
            */
            internal init(v: String) {
                
                self.v = v
            }
        
        }
        """

        XCTAssertEqual(result, structSpec.toString())
    }


    func testEnumNestedType() {
        let eb = EnumSpec.builder(for: "TopLevelEnum")
        eb.add(fields: [FieldSpec.builder(for: "v", type: TypeName.StringType, construct: .mutableParam).build()])
        let f1 = FieldSpec.builder(for: "test_case_one")
                .add(description: "This is the first test case")
                .add(initializer: CodeBlock.builder().add(literal: "\"test_case_one\"").build())
        eb.add(field: f1.build())

        let ncb = ClassSpec.builder(for: "NestedClass")
        ncb.add(description: "This is a test nested class")
        ncb.add(fields: [FieldSpec.builder(for: "v1", type: TypeName.IntegerType, construct: .mutableParam).build()])
        eb.add(nestedType: ncb.build())

        let enumSpec = eb.build()

        let result = """
        enum TopLevelEnum {
        
            /**
                This is a test nested class
            */
            class NestedClass {
                var v1: Int
            }
        
            var v: String
            // This is the first test case
            case testCaseOne = "test_case_one"
        }
        """

        XCTAssertEqual(result, enumSpec.toString())
    }

    func test2NestedTypes() {
        let cb = ClassSpec.builder(for: "TopLevelClass")

        cb.add(nestedType: StructSpec.builder(for: "FirstNestedStruct").build())
        cb.add(nestedType: StructSpec.builder(for: "SecondNestedStruct").build())

        let classSpec = cb.build()

        let result = """
        class TopLevelClass {
        
            struct FirstNestedStruct {
        
        
                internal init() {
                    
                }
        
            }
        
            struct SecondNestedStruct {
        
        
                internal init() {
                    
                }
        
            }
        
        }
        """

        XCTAssertEqual(result, classSpec.toString())
    }
}
