//
//  ControlFlowTests.swift
//  SwiftPoet
//
//  Created by Kyle Dorman on 11/18/15.
//
//

import XCTest
import SwiftPoet

class ControlFlowTests: XCTestCase {

    func testIfLetStatement() {
        let left = CodeBlock.builder().add(literal: "let name").build()
        let right = CodeBlock.builder().add(literal: "NSDate() as? String").build()
        let comparison = ComparisonList(lhs: left, comparator: .OptionalCheck, rhs: right)

        let controlFlow = ControlFlow.ifControlFlow(comparison) {
            return CodeBlock.builder().add(literal: "print(\"Crazy conversion!!!\")").build()
        }

        let result =
        "if let name = NSDate() as? String {\n" +
        "    print(\"Crazy conversion!!!\")\n" +
        "}"

//        print(result)
//        print(controlFlow.toString())

        XCTAssertEqual(result, controlFlow.toString())
    }

    func testIfStatement() {
        let left = CodeBlock.builder().add(literal: "[1, 2, 3].count").build()
        let right = CodeBlock.builder().add(literal: "0").build()
        let comparison = ComparisonList(lhs: left, comparator: .GreaterThan, rhs: right)

        let controlFlow = ControlFlow.ifControlFlow(comparison) {
            return CodeBlock.builder().add(literal: "print(\"Crazy conversion!!!\")").build()
        }

        let result =
        "if [1, 2, 3].count > 0 {\n" +
        "    print(\"Crazy conversion!!!\")\n" +
        "}"

//        print(result)
//        print(controlFlow.toString())

        XCTAssertEqual(result, controlFlow.toString())
    }

    func testGuardStatement() {
        let left = CodeBlock.builder().add(literal: "[1, 2, 3].count").build()
        let right = CodeBlock.builder().add(literal: "1").build()
        let comparison = ComparisonList(lhs: left, comparator: .LessThanOrEqualTo, rhs: right)

        let controlFlow = ControlFlow.guardControlFlow(comparison) {
            return CodeBlock.builder().add(literal: "print(\"Crazy conversion!!!\")").build()
        }

        let result =
        "guard [1, 2, 3].count <= 1 else {\n" +
        "    print(\"Crazy conversion!!!\")\n" +
        "}"

//        print(result)
//        print(controlFlow.toString())

        XCTAssertEqual(result, controlFlow.toString())
    }

    func testIfElseIfElseStatement() {
        let leftOne = CodeBlock.builder().add(literal: "let val").build()
        let rightOne = CodeBlock.builder().add(literal: "optionalValueOne").build()
        let comparisonOne = ComparisonList(lhs: leftOne, comparator: .OptionalCheck, rhs: rightOne)

        let leftTwo = CodeBlock.builder().add(literal: "let val").build()
        let rightTwo = CodeBlock.builder().add(literal: "optionalValueTwo").build()
        let comparisonTwo = ComparisonList(lhs: leftTwo, comparator: .OptionalCheck, rhs: rightTwo)

        let cb = CodeBlock.builder()
            .add(codeBlock: ControlFlow.ifControlFlow(comparisonOne) {
                return CodeBlock.builder().add(literal: "print(\"Inside if statement\")").build()
            })
            .add(codeBlock: ControlFlow.elseIfControlFlow(comparisonTwo) {
                return CodeBlock.builder().add(literal: "print(\"Inside if else statement\")").build()
            })
            .add(codeBlock: ControlFlow.elseControlFlow(nil) {
                return CodeBlock.builder().add(literal: "print(\"Inside else statement\")").build()
            })
            .build()

        let result =
        "\n" +
        "if let val = optionalValueOne {\n" +
        "    print(\"Inside if statement\")\n" +
        "}\n" +
        "else if let val = optionalValueTwo {\n" +
        "    print(\"Inside if else statement\")\n" +
        "}\n" +
        "else {\n" +
        "    print(\"Inside else statement\")\n" +
        "}"

//        print(result)
//        print(cb.toString())

        XCTAssertEqual(result, cb.toString())
    }

    func testTwoOptionals() {
        let leftOne = CodeBlock.builder().add(literal: "let name").build()
        let rightOne = CodeBlock.builder().add(literal: "NSDate() as? String").build()
        let comparisonOne = ComparisonListItem(comparison: Comparison(lhs: leftOne, comparator: .OptionalCheck, rhs: rightOne))

        let leftTwo = CodeBlock.builder().add(literal: "let age").build()
        let rightTwo = CodeBlock.builder().add(literal: "100 as? String").build()
        let comparisonTwo = ComparisonListItem(comparison: Comparison(lhs: leftTwo, comparator: .OptionalCheck, rhs: rightTwo), requirement: Requirement.OptionalList)

        let comparisons = ComparisonList(list: [comparisonOne, comparisonTwo])

        let controlFlow = ControlFlow.ifControlFlow(comparisons) {
            return CodeBlock.builder().add(literal: "print(\"Crazy conversion!!!\")").build()
        }

        let result =
        "if let name = NSDate() as? String, let age = 100 as? String {\n" +
            "    print(\"Crazy conversion!!!\")\n" +
        "}"

//        print(result)
//        print(controlFlow.toString())

        XCTAssertEqual(result, controlFlow.toString())
    }

    func testColsure() {
        let closure = ControlFlow.closure(parameterList: "key, value", canThrow: true, returnType: "[String]") {
            let left = CodeBlock.builder().add(literal: "key").build()
            let right = CodeBlock.builder().add(literal: "key").build()
            return CodeBlock.builder()
                .add(codeLine: "let result = [String]()")
                .add(codeBlock: ControlFlow.ifControlFlow(ComparisonList(lhs: left, comparator: .OptionalCheck, rhs:right)) {
                    return CodeBlock.builder().add(literal: "result.append(key + value)").build()
                })
                .add(codeLine: "return result")
                .build()
        }

        let result =
        " {\n" +
        "    (key, value) throws -> [String] in\n" +
        "        \n" +
        "        let result = [String]()\n" +
        "        if key = key {\n" +
        "            result.append(key + value)\n" +
        "        }\n" +
        "        return result\n" +
        "}"

//        print(closure.toString())
//        print(result)

        XCTAssertEqual(closure.toString(), result)
    }



}
