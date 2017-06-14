//
//  PoetFile.swift
//  SwiftPoet
//
//  Created by Kyle Dorman on 1/25/16.
//
//

import Foundation

// Represents a list of PoetSpecs in a single file
public protocol PoetFileProtocol {
    var fileName: String? { get }
    var specList: [PoetSpec] { get }
    var fileContents: String { get }

    func append(_ item: PoetSpec)
}


open class PoetFile: PoetFileProtocol, Importable {
    open fileprivate(set) var fileName: String?
    open fileprivate(set) var specList: [PoetSpec]
    open var fileContents: String {
        return toFile()
    }

    open var imports: Set<String> {
        return collectImports()
    }

    fileprivate var framework: String?

    public init(list: [PoetSpec], framework: String? = nil) {
        self.specList = list
        self.fileName = list.first?.name
        self.framework = framework
    }

    public convenience init(spec: PoetSpec, framework: String? = nil) {
        self.init(list: [spec], framework: framework)
    }

    open func append(_ item: PoetSpec) {
        specList.append(item)
        if fileName == nil {
            fileName = item.name
        }
    }

    open func collectImports() -> Set<String> {
        return specList.reduce(Set<String>()) { set, spec in
            return set.union(spec.collectImports())
        }
    }

    fileprivate func toFile() -> String {
        let codeWriter = CodeWriter()
        codeWriter.emitFileHeader(fileName: fileName, framework: framework, specs: specList)
        codeWriter.emit(imports: imports)
        codeWriter.emit(specs: specList)
        return codeWriter.out
    }
}
