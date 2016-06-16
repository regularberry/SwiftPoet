//
//  CodeWriter.swift
//  SwiftPoet
//
//  Created by Kyle Dorman on 11/10/15.
//
//

import Foundation

public typealias Appendable = String.CharacterView

@objc public class CodeWriter: NSObject {
    private var _out: Appendable
    public var out: String {
        return String(_out)
    }

    private var indentLevel: Int

    public init(out: Appendable = Appendable(""), indentLevel: Int = 0) {
        self._out = out
        self.indentLevel = indentLevel
    }
}

// MARK: Indentation
public extension CodeWriter {
    @discardableResult
    public func indent() -> CodeWriter {
        return indent(levels: 1)
    }

    @discardableResult
    public func indent(levels: Int) -> CodeWriter {
        return indentLevels(levels: levels)
    }

    @discardableResult
    public func unindent() -> CodeWriter {
        return unindent(levels: 1)
    }

    @discardableResult
    public func unindent(levels: Int) -> CodeWriter {
        return indentLevels(levels: -levels)
    }

    @discardableResult
    private func indentLevels(levels: Int) -> CodeWriter {
        indentLevel = max(indentLevel + levels, 0)
        return self
    }
}

extension CodeWriter {
    //
    //  FileName.swift
    //  Framework
    //
    //  Contains:
    //  PoetSpecType PoetSpecName
    //  PoetSpecType2 PoetSpecName2
    //
    //  Created by SwiftPoet on MM/DD/YYYY
    //
    //
    public func emitFileHeader(fileName: String?, framework: String?, specs: [PoetSpecType]) {
        let specStr: [String] = specs.map { spec in
            return headerLine(withString: "\(spec.construct.stringValue) \(spec.name)")
        }

        var header: [String] = [headerLine()]
        if let fileName = fileName {
            header.append(headerLine(withString: "\(fileName).swift"))
        }
        header.append(headerLine())
        if let framework = framework {
            header.append(headerLine(withString: framework))
            header.append(headerLine())
        }

        if !specStr.isEmpty {
            header.append(headerLine(withString: "Contains:"))
            header.append(contentsOf: specStr)
            header.append(headerLine())
        }

        header.append(headerLine(withString: generatedByAt()))
        header.append(headerLine())
        header.append(headerLine())
        
        _out.append(contentsOf: header.joined(separator: "\n").characters)
        self.emitNewLine()
        self.emitNewLine()
    }

    private func headerLine(withString str: String? = nil) -> String {
        guard let str = str else {
            return "//"
        }
        return "//  \(str)"
    }

    private func createdAt() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .shortStyle
        return formatter.string(from: Date())
    }

    private func generatedByAt() -> String {
        return "Generated by SwiftPoet on \(createdAt())"
    }

    public func emit(imports: Set<String>) {
        if (imports.count > 0) {
            let importString = imports.joined(separator: "\nimport ")
            _out.append(contentsOf: "import ".characters)
            _out.append(contentsOf: importString.characters)
            _out.append(contentsOf: "\n\n".characters)
        }
    }

    public func emitDocumentation(forType type: TypeSpec) {
        if let docs = type.description {
            var specDoc = "" as String

            let firstline = String.indent(s: "/**\n", i: indentLevel)
            let lastline = String.indent(s: "*/\n", i: indentLevel)
            let indentedDocs = String.indent(s: docs + "\n", i: indentLevel + 1)

            specDoc.append(firstline)
            specDoc.append(indentedDocs)
            specDoc.append(lastline)
            _out.append(contentsOf: specDoc.characters)
        }
    }

    public func emitDocumentation(forField field: FieldSpec) {
        if let docs = field.description {
            let comment = String.indent(s: "// \(docs)\n", i: indentLevel)
            _out.append(contentsOf: comment.characters)
        }
    }

    public func emitDocumentation(forMethod method: MethodSpec) {
        guard method.description != nil || method.parameters.count > 0 else {
            return
        }

        var specDoc = "" as String

        let firstline = String.indent(s: "/**\n", i: indentLevel)
        let lastline = String.indent(s: "*/\n", i: indentLevel)
        let indentedDocs = PoetUtil.fmap(data: method.description) {
            String.indent(s: $0 + "\n", i: self.indentLevel + 1)
        }

        specDoc.append(firstline)
        if indentedDocs != nil {
            specDoc.append(indentedDocs!)
        }

        var first = true
        method.parameters.forEach { p in
            if first && method.description != nil {
                specDoc.append("\n")
            } else if !first {
                specDoc.append("\n\n")
            }
            first = false

            var paramDoc = ":param:    \(p.name)"
            if let desc = p.description {
                paramDoc.append(" \(desc)")
            }
            specDoc.append(String.indent(s: paramDoc, i: indentLevel + 1))
        }
        specDoc.append("\n")
        specDoc.append(lastline)
        _out.append(contentsOf: specDoc.characters)
    }

    public func emitModifiers(modifiers: Set<Modifier>) {
        guard modifiers.count > 0 else {
            _out.append(contentsOf: String.indent(s: "", i: indentLevel).characters)
            return
        }

        let modListStr = Array(modifiers).map { m in
            return m.rawString
        }.joined(separator: " ") + " "

        _out.append(contentsOf: String.indent(s: modListStr, i: indentLevel).characters)
    }

    @discardableResult
    public func emit(codeBlock: CodeBlock) -> CodeWriter {
        var first = true
        codeBlock.emittableObjects.forEach { either in
            switch either {
            case .Right(let cb):
                self.emitNewLine()
                self.emitWithIndentation(cb: cb)
            case .Left(let emitObject):
                switch emitObject.type {
                case .Literal:
                    self.emitLiteral(o: emitObject.any, first: first)
                case .BeginStatement:
                    self.emitBeginStatement()
                case .EndStatement:
                    self.emitEndStatement()
                case .NewLine:
                    self.emitNewLine()
                case .IncreaseIndentation:
                    self.indent()
                case .DecreaseIndentation:
                    self.unindent()
                case .CodeLine:
                    self.emitNewLine()
                    self.emitWithIndentation(any: emitObject.any as! Literal)
                case .Emitter:
                    self.emitEmitter(o: emitObject.any, first: first)
                }
                first = false
            }
        }
        return self
    }

    @discardableResult
    public func emit(type: EmitType, any: Any? = nil) -> CodeWriter {
        let cbBuilder = CodeBlock.builder()
        cbBuilder.addEmitObject(type: type, any: any)
        return self.emit(codeBlock: cbBuilder.build())
    }

    private func emitLiteral(o: Any?, first: Bool = false) {
        if let _ = o as? TypeSpec {
            // Dunno
        } else if let literalType = o as? Literal {
            var lv = literalType.literalValue().characters
            if !first { lv.insert(" ", at: lv.startIndex) }
            _out.append(contentsOf: lv)
        } else if let str = o as? String {
            _out.append(contentsOf: str.characters)
        }
    }

    private func emitEmitter(o: Any?, first: Bool = true) {
        if let emitter = o as? Emitter {
            if !first { _out.append(" ") }
            emitter.emit(codeWriter: self)
        }
    }

    @discardableResult
    public func emitInheritance(superType: TypeName?, protocols: [TypeName]?) -> CodeWriter {

        var inheritanceValues: [String?] = [superType?.literalValue()]
        if let protocols = protocols {
            inheritanceValues.append(contentsOf: protocols.map({ $0.literalValue()}))
        }

        let stringValues = inheritanceValues.flatMap({ $0})

        if stringValues.count > 0 {
            _out.append(contentsOf: ": ".characters)
            _out.append(contentsOf: stringValues.joined(separator: ", ").characters)
        }

        return self
    }

    private func emitBeginStatement() {
        let begin = " {"
        _out.append(contentsOf: begin.characters)
        indent()
    }

    private func emitEndStatement() {
        let newline = "\n"
        unindent()
        let endBracket = String.indent(s: "}", i: indentLevel)
        let end = newline + endBracket
        _out.append(contentsOf: end.characters)
    }

    public func emitNewLine() {
        _out.append("\n")
    }

    private func emitIndentation() {
        _out.append(contentsOf: String.indent(s: "", i: indentLevel).characters)
    }

    public func emitWithIndentation(cb: CodeBlock) {
        self.emitIndentation()
        emit(codeBlock: cb)
    }

    public func emitWithIndentation(any: Literal) {
        self.emitIndentation()
        self.emitLiteral(o: any, first: true)
    }

    public func emit(specs: [Emitter]) {
        _out.append(contentsOf: (specs.map { spec in
            spec.toString()
        }).joined(separator: "\n\n").characters)
        emitNewLine()
    }
}

extension String {
    private static let indentSpacing = ("    ").characters

    private static func indent(s: String, i: Int) -> String {
        var retVal = s
        i.times {
            retVal.insert(contentsOf: String.indentSpacing, at: s.startIndex)
        }
        return retVal
    }
}

extension Int {
    private func times(fn: () -> Void) {
        for _ in 0..<self {
            fn()
        }
    }
}

