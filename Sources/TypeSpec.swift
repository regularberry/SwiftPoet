//
//  TypeSpec.swift
//  SwiftPoet
//
//  Created by Kyle Dorman on 11/10/15.
//
//

import Foundation

public protocol TypeSpecProtocol {
    var methods: [MethodSpec] { get }
    var fields: [FieldSpec] { get }
    var superType: TypeName? { get }
    var protocols: [TypeName] { get }
    var subtypes: [TypeSpec] { get }
}

open class TypeSpec: PoetSpec, TypeSpecProtocol {
    open let methods: [MethodSpec]
    open let fields: [FieldSpec]
    open let superType: TypeName?
    open let protocols: [TypeName]
    open let subtypes: [TypeSpec]

    public init(builder: TypeSpecBuilder) {
        methods = builder.methods
        fields = builder.fields
        superType = builder.superType
        protocols = builder.protocols
        subtypes = builder.subtypes

        super.init(name: builder.name, construct: builder.construct, modifiers: builder.modifiers, description: builder.description, generatorInfo: builder.generatorInfo, framework: builder.framework, imports: builder.imports)
    }

    open override func collectImports() -> Set<String> {
        let externalImports = [
            methods.reduce(Set<String>()) { set, m in
            return set.union(m.collectImports())
            },
            fields.reduce(Set<String>()) { set, f in
                return set.union(f.collectImports())
            },
            protocols.reduce(Set<String>()) { set, sp in
                set.union(sp.collectImports())
            },
            superType?.collectImports()]

        return externalImports.reduce(imports) { set, list in
            guard let list = list else {
                return set
            }
            return set.union(list)
        }
    }

    @discardableResult
    open override func emit(to writer: CodeWriter) -> CodeWriter {
        writer.emit(documentationFor: self)
        writer.emit(modifiers: modifiers)

        let cbBuilder = CodeBlock.builder()
        cbBuilder.add(literal: construct)
        cbBuilder.add(literal: name)
        writer.emit(codeBlock: cbBuilder.build())
        writer.emit(superType: superType, protocols: protocols)
        writer.emit(type: .beginStatement)
        writer.emitNewLine()

        var first = true

        fields.forEach { spec in
            if !first { writer.emitNewLine() }
            spec.emit(to: writer)
            first = false
        }
        
        if !subtypes.isEmpty {
            writer.emitNewLine()
        }
        
        subtypes.forEach { subtype in
            writer.emitNewLine()
            subtype.emit(to: writer)
            writer.emitNewLine()
        }

        if !methods.isEmpty {
            writer.emitNewLine()
        }

        methods.forEach { spec in
            writer.emitNewLine()
            spec.emit(to: writer)
            writer.emitNewLine()
        }

        writer.emit(type: .endStatement)
        
        return writer
    }
}

open class TypeSpecBuilder: PoetSpecBuilder, TypeSpecProtocol {
    open fileprivate(set) var methods = [MethodSpec]()
    open fileprivate(set) var fields = [FieldSpec]()
    open fileprivate(set) var protocols = [TypeName]()
    open fileprivate(set) var superType: TypeName? = nil
    open fileprivate(set) var subtypes: [TypeSpec] = [TypeSpec]()

    public override init(name: String, construct: Construct) {
        super.init(name: name.cleaned(.typeName), construct: construct)
    }

    internal func mutatingAdd(method toAdd: MethodSpec) {
        if !methods.contains(toAdd) {
            self.methods.append(toAdd)
            toAdd.parentType = self.construct
        }
    }

    internal func mutatingAdd(methods toAdd: [MethodSpec]) {
        for method in toAdd {
            mutatingAdd(method: method)
        }
    }

    internal func mutatingAdd(field toAdd: FieldSpec) {
        if !fields.contains(toAdd) {
            self.fields.append(toAdd)
            toAdd.parentType = self.construct
        }
    }

    internal func mutatingAdd(fields toAdd: [FieldSpec]) {
        for field in toAdd {
            mutatingAdd(field: field)
        }
    }

    internal func mutatingAdd(protocol toAdd: TypeName) {
        if !protocols.contains(toAdd) {
            protocols.append(toAdd)
        }
    }

    internal func mutatingAdd(protocols toAdd: [TypeName]) {
        for prot in toAdd {
            mutatingAdd(protocol: prot)
        }
    }

    internal func mutatingAdd(superType toAdd: TypeName) {
        self.superType = toAdd
    }
    
    internal func mutatingAdd(subtype toAdd: TypeSpec) {
        subtypes.append(toAdd)
    }
    
    internal func mutatingAdd(subtypes toAdd: [TypeSpec]) {
        for subtype in toAdd {
            mutatingAdd(subtype: subtype)
        }
    }
}
