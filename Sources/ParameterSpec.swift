//
//  ParameterSpec.swift
//  SwiftPoet
//
//  Created by Kyle Dorman on 11/10/15.
//
//

import Foundation

public enum DefaultValueType {
    case `nil`
    case string(String)
    case other(Any)
}

public protocol ParameterSpecProtocol {
    var label: String? { get }
    var type: TypeName { get }
    var defaultValue: DefaultValueType? { get }
}

open class ParameterSpec: PoetSpec, ParameterSpecProtocol {
    open let label: String?
    open let type: TypeName
    open let defaultValue: DefaultValueType?

    fileprivate init(builder: ParameterSpecBuilder) {
        self.label = builder.label
        self.type = builder.type
        self.defaultValue = builder.defaultValue
        super.init(name: builder.name, construct: builder.construct, modifiers: builder.modifiers,
                   description: builder.description, generatorInfo: builder.generatorInfo, framework: builder.framework, imports: builder.imports)
    }

    open static func builder(for name: String, label: String? = nil, type: TypeName, construct: Construct? = nil, defaultValue: DefaultValueType? = nil) -> ParameterSpecBuilder {
        return ParameterSpecBuilder(name: name, label: label, type: type, construct: construct, defaultValue: defaultValue)
    }

    open override func collectImports() -> Set<String> {
        return type.collectImports().union(imports)
    }

    @discardableResult
    open override func emit(to writer: CodeWriter) -> CodeWriter {
        let cbBuilder = CodeBlock.builder()
        if (construct == .mutableParam) {
            cbBuilder.add(literal: construct)
        }
        if let label = label {
            cbBuilder.add(literal: label, trimString: true)
        }
        cbBuilder.add(literal: name)
        cbBuilder.add(literal: ":", trimString: true)
        cbBuilder.add(literal: type)
        if let defaultValue = defaultValue {
            cbBuilder.add(literal: "=")
            switch defaultValue {
            case .nil:
                cbBuilder.add(literal: "nil")
            case .string(let str):
                cbBuilder.add(literal: "\"\(str)\"")
            case .other(let val):
                cbBuilder.add(literal: "\(val)")
            }
        }
        writer.emit(codeBlock: cbBuilder.build())
        return writer
    }
}

open class ParameterSpecBuilder: PoetSpecBuilder, Builder, ParameterSpecProtocol {
    public typealias Result = ParameterSpec
    open static let defaultConstruct: Construct = .param

    open let label: String?
    open let type: TypeName
    open let defaultValue: DefaultValueType?

    fileprivate init(name: String, label: String? = nil, type: TypeName, construct: Construct? = nil, defaultValue: DefaultValueType? = nil) {
        self.label = label
        self.type = type
        self.defaultValue = defaultValue
        let requiredConstruct = construct == nil || construct! != .mutableParam ? ParameterSpecBuilder.defaultConstruct : construct!
        super.init(name: name.cleaned(.paramName), construct: requiredConstruct)
    }

    open func build() -> Result {
        return ParameterSpec(builder: self)
    }

}

// MARK: Chaining
extension ParameterSpecBuilder {

    @discardableResult
    public func add(modifier toAdd: Modifier) -> Self {
        mutatingAdd(modifier: toAdd)
        return self
    }

    @discardableResult
    public func add(modifiers toAdd: [Modifier]) -> Self {
        mutatingAdd(modifiers: toAdd)
        return self
    }

    @discardableResult
    public func add(description toAdd: String?) -> Self {
        mutatingAdd(description: toAdd)
        return self
    }

    @discardableResult
    public func add(generatorInfo toAdd: String?) -> Self {
        mutatingAdd(generatorInfo: toAdd)
        return self
    }

    @discardableResult
    public func add(framework toAdd: String?) -> Self {
        mutatingAdd(framework: toAdd)
        return self
    }

    @discardableResult
    public func add(import toAdd: String) -> Self {
        mutatingAdd(import: toAdd)
        return self
    }

    @discardableResult
    public func add(imports toAdd: [String]) -> Self {
        mutatingAdd(imports: toAdd)
        return self
    }
}
