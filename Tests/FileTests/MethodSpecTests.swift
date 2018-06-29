//
//  MethodSpecTests.swift
//  SwiftPoet
//
//  Created by Kyle Dorman on 11/17/15.
//
//

import XCTest
import SwiftPoet

class MethodSpecTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testEmptyProtocolMethod() {
        let mb = MethodSpec.builder(for: "Test")
        mb.add(parentType: .protocol)

        let method = mb.build()

        XCTAssertEqual("func test()", method.toString())
    }

    func testDefaultParameterMethod() {
        let mb = MethodSpec.builder(for: "Test")
        mb.add(parentType: .method)

        let pb = ParameterSpec.builder(for: "name", type: TypeName.StringType)
                .add(initializer: CodeBlock.builder()
                        .add(literal: "\"Test\"")
                        .build()
                ).build()

        mb.add(parameter: pb)

        let method = mb.build()

        let result = """
/**
    - Parameters:

      - name
*/
func test(name: String = "Test") {
}
"""
        XCTAssertEqual(result, method.toString())
    }

    func testProtocolMethodOneParam() {
        let mb = MethodSpec.builder(for: "Test")
        mb.add(parentType: .protocol)
        mb.add(returnType: TypeName.StringType)

        let pb = ParameterSpec.builder(for: "name", type: TypeName.StringType)
        mb.add(parameter: pb.build())

        let method = mb.build()

        let result =
        "/**\n" +
        "    - Parameters:\n\n" +
        "      - name\n" +
        "*/\n" +
        "func test(name: String) -> String"

        //        print(result)
        //        print(method.toString())

        XCTAssertEqual(result, method.toString())
    }

    func testProtocolMethodManyParam() {
        let mb = MethodSpec.builder(for: "build_person")
        mb.add(parentType: .protocol)
        mb.add(returnType: TypeName(keyword: "Person"))

        let pb1 = ParameterSpec.builder(for: "name", type: TypeName.StringType)
        mb.add(parameter: pb1.build())
        let pb2 = ParameterSpec.builder(for: "age", type: TypeName.IntegerType)
        mb.add(parameter: pb2.build())
        let pb3 = ParameterSpec.builder(for: "homeOwner", type: TypeName.BooleanType)
        mb.add(parameter: pb3.build())
        let pb4 = ParameterSpec.builder(for: "petName", type: TypeName.StringOptional)
        mb.add(parameter: pb4.build())

        let method = mb.build()

        let result =
        "/**\n" +
        "    - Parameters:\n\n" +
        "      - name\n\n" +
        "      - age\n\n" +
        "      - homeOwner\n\n" +
        "      - petName\n" +
        "*/\n" +
        "func buildPerson(name: String, age: Int, homeOwner: Bool, petName: String?) -> Person"

//        print(result)
//        print(method.toString())

        XCTAssertEqual(result, method.toString())
    }

    func testProtocolMethodOneParamWithDocs() {
        let mb = MethodSpec.builder(for: "Test")
            .add(parentType: .protocol)
            .add(returnType: TypeName.StringType)
            .add(description: "This is a test description")

        let pb = ParameterSpec.builder(for: "name", type: TypeName.StringType)
            .add(description: "The name of the test")

        mb.add(parameter: pb.build())

        let method = mb.build()

        let result =
        "/**\n" +
        "    This is a test description\n" +
        "\n" +
        "    - Parameters:\n\n" +
        "      - name: The name of the test\n" +
        "*/\n" +
        "func test(name: String) -> String"

//        print(result)
//        print(method.toString())

        XCTAssertEqual(result, method.toString())
    }

    func testEmptyMethod() {
        let method = MethodSpec.builder(for: "Test")
            .add(returnType: TypeName.StringType)
            .build()

        let result =
        "func test() -> String {\n" +
        "}"

//        print(result)
//        print(method.toString())

        XCTAssertEqual(result, method.toString())
    }

    func testMethodWithCodeBlock() {
        let method = MethodSpec.builder(for: "Test")
            .add(returnType: TypeName.StringType)
            .add(codeBlock: CodeBlock.builder()
                .add(literal: "return \"test\"")
                .build())
            .build()

        let result =
        "func test() -> String {\n" +
        "    return \"test\"\n" +
        "}"

//        print(result)
//        print(method.toString())

        XCTAssertEqual(result, method.toString())
    }

    func testMethodWithCodeBlockAndParam() {
        let mb = MethodSpec.builder(for: "Test")
        mb.add(returnType: TypeName.StringType)

        let cbBuilder = CodeBlock.builder()
        cbBuilder.add(type: .literal, data: "return name")
        mb.add(codeBlock: cbBuilder.build())

        let pb = ParameterSpec.builder(for: "name", type: TypeName.StringType)
        mb.add(parameter: pb.build())

        let method = mb.build()

        let result =
        "/**\n" +
        "    - Parameters:\n\n" +
        "      - name\n" +
        "*/\n" +
        "func test(name: String) -> String {\n" +
        "    return name\n" +
        "}"

//        print(result)
//        print(method.toString())

        XCTAssertEqual(result, method.toString())
    }

    func testMethodWithGuard() {
        let mb = MethodSpec.builder(for: "Test")
        .add(returnType: TypeName.StringType)

        let cbBuilder = CodeBlock.builder()
        cbBuilder.add(literal: "return name")
        mb.add(codeBlock: cbBuilder.build())

        let pb = ParameterSpec.builder(for: "name", type: TypeName.StringType)
        mb.add(parameter: pb.build())

        let method = mb.build()

        let result =
        "/**\n" +
            "    - Parameters:\n\n" +
            "      - name\n" +
            "*/\n" +
            "func test(name: String) -> String {\n" +
            "    return name\n" +
        "}"

        //        print(result)
        //        print(method.toString())
        
        XCTAssertEqual(result, method.toString())
    }
    
    func testOptionalInit() {
        let method = MethodSpec.builder(for: "init?")
            .build()
        
        let result =
        "init?() {\n" +
        "}"
        
        //        print(result)
        //        print(method.toString())
        
        XCTAssertEqual(result, method.toString())
    }

    func testEquality() {
        /*
         static func == (lhs: GridPoint, rhs: GridPoint) -> Bool {
            return lhs.x == rhs.x && lhs.y == rhs.y
         }
         */
        let type = TypeName(keyword: "GridPoint")
        let method = MethodSpec.builder(for: "==")
            .add(modifier: .Static)
            .add(parameters: [
                ParameterSpec.builder(for: "lhs", type: type).build(),
                ParameterSpec.builder(for: "rhs", type: type).build()
            ])
            .add(returnType: TypeName.BooleanType)
            .add(codeBlock: CodeBlock.builder().add(literal: "return lhs.x == rhs.x && lhs.y == rhs.y").build())
            .build()

        let result =
        "/**\n" +
        "    - Parameters:\n\n" +
        "      - lhs\n" +
        "\n" +
        "      - rhs\n" +
        "*/\n" +
        "static func ==(lhs: GridPoint, rhs: GridPoint) -> Bool {\n" +
        "    return lhs.x == rhs.x && lhs.y == rhs.y\n" +
        "}"

//        print(method.toString())
//        print(result)

        XCTAssertEqual(result, method.toString())
    }

}
