//
//  TypeReferenceNameTests.swift
//  SwiftPoetTests
//
//  Created by Nikita Korchagin on 07/02/2018.
//  Copyright © 2018 Gilt Groupe. All rights reserved.
//

import XCTest
@testable import SwiftPoet

class TypeReferenceNameTests: XCTestCase {

    func testCustomTypeReferenceName() {
        let typeStr = "Cell.Type"
        let type = TypeReferenceName(keyword: typeStr)

        XCTAssertEqual(type.literalValue(), typeStr)
    }

    func testChain() {
        let typeStr = "Chain.Type"
        let type = TypeReferenceName(typesChain: ["Chain", "Type"])

        XCTAssertEqual(type.literalValue(), typeStr)
    }

    func testGenerics() {
        let arrayTypeStr = "Custom.Array<Namespace.Any>"
        let dictTypeStr = "Custom.Dictionary<Namespace.String,Namespace.Any>"
        let arrayTypeReferenceName = TypeReferenceName(keyword: arrayTypeStr)
        let dictTypeReferenceName = TypeReferenceName(keyword: dictTypeStr)

        XCTAssertEqual(arrayTypeReferenceName.literalValue(), arrayTypeStr)
        XCTAssertNotNil(arrayTypeReferenceName.leftInnerType)
        XCTAssertEqual(arrayTypeReferenceName.leftInnerType?.literalValue() ?? "", "Namespace.Any")

        XCTAssertEqual(dictTypeReferenceName.literalValue(), dictTypeStr)
        XCTAssertNotNil(dictTypeReferenceName.leftInnerType)
        XCTAssertNotNil(dictTypeReferenceName.rightInnerType)
        XCTAssertEqual(dictTypeReferenceName.leftInnerType?.literalValue() ?? "", "Namespace.String")
        XCTAssertEqual(dictTypeReferenceName.rightInnerType?.literalValue() ?? "", "Namespace.Any")
    }

    func testArrayType() {
        let typeStr = "[Namespace.Any]"
        let complexTypeStr = "[Custom.Double?]?"
        let typeName = TypeReferenceName(keyword: typeStr)
        let complexTypeReferenceName = TypeReferenceName(keyword: complexTypeStr)

        XCTAssertEqual(typeName.literalValue(), "Array<Namespace.Any>")
        XCTAssertNotNil(typeName.leftInnerType)
        XCTAssertEqual(typeName.leftInnerType?.literalValue() ?? "", "Namespace.Any")

        XCTAssertEqual(complexTypeReferenceName.literalValue(), "Array<Custom.Double?>?")
        XCTAssertTrue(complexTypeReferenceName.optional)
        XCTAssertNotNil(complexTypeReferenceName.leftInnerType)
        XCTAssertEqual(complexTypeReferenceName.leftInnerType?.literalValue() ?? "", "Custom.Double?")
    }

    func testDictionaryType() {
        let typeStr = "[Custom.String:Namespace.Any]"
        let complexTypeStr = "[Custom.String?:Namespace.Any]?"
        let typeName = TypeReferenceName(keyword: typeStr)
        let complexTypeReferenceName = TypeReferenceName(keyword: complexTypeStr)


        XCTAssertEqual(typeName.literalValue(), "Dictionary<Custom.String,Namespace.Any>")
        XCTAssertNotNil(typeName.leftInnerType)
        XCTAssertNotNil(typeName.rightInnerType)
        XCTAssertEqual(typeName.leftInnerType?.literalValue() ?? "", "Custom.String")
        XCTAssertEqual(typeName.rightInnerType?.literalValue() ?? "", "Namespace.Any")

        XCTAssertEqual(complexTypeReferenceName.literalValue(), "Dictionary<Custom.String?,Namespace.Any>?")
        XCTAssertTrue(complexTypeReferenceName.optional)
        XCTAssertNotNil(complexTypeReferenceName.leftInnerType)
        XCTAssertNotNil(complexTypeReferenceName.rightInnerType)
        XCTAssertTrue(complexTypeReferenceName.leftInnerType?.optional ?? false)
        XCTAssertEqual(complexTypeReferenceName.leftInnerType?.literalValue() ?? "", "Custom.String?")
        XCTAssertEqual(complexTypeReferenceName.rightInnerType?.literalValue() ?? "", "Namespace.Any")
    }

    func testClosure() {
        let typeStr = "(Custom.String, Custom.String) -> Custom.Int"
        let optionalTypeStr = "((Custom.String, Dictionary<Custom.Int>) -> Array<Custom.String>)?"
        let typeName = TypeReferenceName(keyword: typeStr)
        let optionalTypeReferenceName = TypeReferenceName(keyword: optionalTypeStr)

        XCTAssertEqual(typeName.literalValue(), typeStr)
        XCTAssertNotNil(typeName.innerTypes.first)
        XCTAssertEqual(typeName.innerTypes[1].literalValue(), "Custom.String")
        XCTAssertEqual(typeName.keyword, "Closure")

        XCTAssertEqual(optionalTypeReferenceName.literalValue(), optionalTypeStr)
        XCTAssertNotNil(optionalTypeReferenceName.innerTypes.first)
        XCTAssertEqual(optionalTypeReferenceName.keyword, "Closure")
    }

    func testRegexMatches() {
        XCTAssertTrue(TypeReferenceName.containsGenerics("Custom.Array<Custom.String>"))
        XCTAssertTrue(TypeReferenceName.containsGenerics("Custom.Array<Custom.String>?"))
        XCTAssertTrue(TypeReferenceName.containsGenerics("Custom.Dictionary<Custom.String, Custom.String>"))
        XCTAssertTrue(TypeReferenceName.containsGenerics("Custom.Dictionary<Custom.String, Custom.String>?"))
        XCTAssertFalse(TypeReferenceName.containsGenerics("Custom.Array<>"))
        XCTAssertFalse(TypeReferenceName.containsGenerics("Custom.Array<>?"))
        XCTAssertFalse(TypeReferenceName.containsGenerics("Custom.String"))
        XCTAssertFalse(TypeReferenceName.containsGenerics("Custom.String?"))

        XCTAssertTrue(TypeReferenceName.isOptional("Custom.String?"))
        XCTAssertFalse(TypeReferenceName.isOptional("Custom.String"))

        XCTAssertTrue(TypeReferenceName.isArray("[Custom.String]"))
        XCTAssertTrue(TypeReferenceName.isArray("[Custom.String]?"))
        XCTAssertFalse(TypeReferenceName.isArray("[]?"))
        XCTAssertFalse(TypeReferenceName.isArray("[]?"))
        XCTAssertFalse(TypeReferenceName.isArray("Custom.String?"))
        XCTAssertFalse(TypeReferenceName.isArray("Custom.String?"))
        XCTAssertFalse(TypeReferenceName.isArray("[Custom.String?"))

        XCTAssertTrue(TypeReferenceName.isDictionary("[Custom.String:Custom.String]"))
        XCTAssertTrue(TypeReferenceName.isDictionary("[Custom.String: Custom.String]?"))
        XCTAssertTrue(TypeReferenceName.isDictionary("[Custom.String?: Custom.String?]?"))
        XCTAssertFalse(TypeReferenceName.isDictionary("[:]?"))
        XCTAssertFalse(TypeReferenceName.isDictionary("[Custom.String:]?"))
        XCTAssertFalse(TypeReferenceName.isDictionary("Custom.String?"))
        XCTAssertFalse(TypeReferenceName.isDictionary("Custom.String?"))
        XCTAssertFalse(TypeReferenceName.isDictionary("[Custom.String:?"))

        XCTAssertTrue(TypeReferenceName.isClosure("(Custom.String) -> Custom.Int"))
        XCTAssertTrue(TypeReferenceName.isClosure("(Custom.String, Custom.String) -> Custom.Array<Custom.String>"))
        XCTAssertFalse(TypeReferenceName.isClosure("Custom.String ->"))
        XCTAssertTrue(TypeReferenceName.isOptionalClosure("((Custom.String, Custom.String) -> Custom.Int)?"))
        XCTAssertFalse(TypeReferenceName.isOptionalClosure("(Custom.String, Custom.String) -> Custom.Int?"))
    }

}
