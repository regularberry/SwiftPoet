//
//  StringExtension.swift
//  SwiftPoet
//
//  Created by Kyle Dorman on 1/29/16.
//
//

import Foundation

extension String {
    public func toCodeBlock() -> CodeBlock {
        return CodeBlock.builder().add(literal: self).build()
    }
}

extension String
{
    public enum Case {
        case typeName
        case paramName
    }
}

extension StringProtocol {
    public func cleaned(_ stringCase: String.Case) -> String {
        switch stringCase {
        case .typeName:
            return ReservedWords.safeWord(PoetUtil.stripSpaceAndPunctuation(self).joined(separator: ""))
        case .paramName:
            let cleanedNameChars = PoetUtil.stripSpaceAndPunctuation(self).joined(separator: "")
            return ReservedWords.safeWord(PoetUtil.lowercaseFirstChar(cleanedNameChars))
        }
    }
}
