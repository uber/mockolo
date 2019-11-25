//
//  SwiftSyntaxExtensions.swift
//  MockoloFramework
//
//  Created by Ellie Shin on 10/29/19.
//

import Foundation
import SwiftSyntax

extension Trivia {
    private func metadata(with annotation: String, in val: String) -> AnnotationMetadata? {
        if val.contains(annotation) {
            var aliasMap: [String: String]?
            let comps = val.components(separatedBy: annotation)
            if var last = comps.last, !last.isEmpty {
                if last.hasPrefix("(") {
                    last.removeFirst()
                }
                if last.hasSuffix(")") {
                    last.removeLast()
                }
                if let aliaseArg = last.components(separatedBy: String.typealiasColon).last, !aliaseArg.isEmpty {
                    let aliases = aliaseArg.components(separatedBy: String.annotationArgDelimiter)
                    aliasMap = [String: String]()
                    aliases.forEach { (item: String) in
                        let keyVal = item.components(separatedBy: "=").map{$0.trimmingCharacters(in: CharacterSet.whitespaces)}
                        if let k = keyVal.first, let v = keyVal.last {
                            aliasMap?[k] = v
                        }
                    }
                }
            }
            return AnnotationMetadata(typealiases: aliasMap)
        }
        return nil
    }
    func annotationMetadata(with annotation: String) -> AnnotationMetadata? {
        var ret: AnnotationMetadata?
        for i in 0..<count {
            let trivia = self[i]
            switch trivia {
            case .docLineComment(let val):
                ret = metadata(with: annotation, in: val)
                if ret != nil {
                    return ret
                }
            case .docBlockComment(let val):
                ret = metadata(with: annotation, in: val)
                if ret != nil {
                    return ret
                }
            default:
                continue
            }
        }
        return nil
    }
}

extension Syntax {
    var name: String {
        if let decl = self as? ProtocolDeclSyntax {
            return decl.identifier.description.trimmingCharacters(in: .whitespaces)
        }
        if let decl = self as? ClassDeclSyntax {
            return decl.identifier.description.trimmingCharacters(in: .whitespaces)
        }
        return .unknownVal
    }
    
    var isProtocol: Bool {
        return self is ProtocolDeclSyntax
    }
    
    var isClass: Bool {
        return self is ClassDeclSyntax
    }
    
    func annotationMetadata(with annotation: String) -> AnnotationMetadata? {
        return leadingTrivia?.annotationMetadata(with: annotation)
    }
    
    // MARK - update the following
    var offset: Int64 {
        return Int64(self.position.utf8Offset)
    }
    
    var length: Int64 {
        return Int64(self.totalLength.utf8Length)
    }
}


class EntityVisitor: SyntaxVisitor {
    var topLevel: Bool = false
    var entities: [Entity] = []
    var current: Entity?
    var imports: [String] = []
    let annotation: String
    
    init(annotation: String = "") {
        self.annotation = annotation
    }
    
    func reset() {
        topLevel = false
        current = nil
        entities = []
        imports = []
    }
    
    func visit(_ node: MemberDeclBlockSyntax) -> SyntaxVisitorContinueKind {
        topLevel = false
        return .visitChildren
    }
    
    func visit(_ node: DeclModifierSyntax) -> SyntaxVisitorContinueKind {
        if topLevel {
            current?.acl = node.name.text
        }
        return .visitChildren
    }
    
    func visit(_ node: AttributeListSyntax) -> SyntaxVisitorContinueKind {
        current?.attributes.append(node.withoutTrivia().description.trimmingCharacters(in: .whitespacesAndNewlines))
        return .visitChildren
    }
    
    func visit(_ node: VariableDeclSyntax) -> SyntaxVisitorContinueKind {
        for v in node.bindings {
            let name = v.pattern.firstToken?.text ?? String.unknownVal
            var typeName = ""
            var canBeInitParam = false
            
            var isStatic = false
            if let mds = node.modifiers {
                for m in mds {
                    for t in m.tokens {
                        if t.text == .static {
                            isStatic = true
                            break
                        }
                    }
                }
            }
            
            if let vtype = v.typeAnnotation?.type.description {
                typeName = vtype
                canBeInitParam = !isStatic &&
                    !vtype.hasSuffix("?") &&
                    !name.hasPrefix(.underlyingVarPrefix) &&
                    !name.hasSuffix(.closureVarSuffix) &&
                    !name.hasSuffix(.callCountSuffix) &&
                    !name.hasSuffix(.subjectSuffix) &&
                    vtype != .unknownVal
            }
            
            if let varmodel = Entity.model(name: name,
                                           typeName: typeName,
                                           acl: current?.acl,
                                           isStatic: isStatic,
                                           canBeInitParam: canBeInitParam,
                                           offset: v.offset,
                                           length: v.length,
                                           modelDescription: node.description,
                                           processed: current?.isProcessed ?? false) {
                current?.members.append(varmodel)
            }
        }
        return .visitChildren
    }
    
    func visit(_ node: AssociatedtypeDeclSyntax) -> SyntaxVisitorContinueKind {
        
        var t = node.inheritanceClause?.inheritedTypeCollection.description ?? ""
        t.append(node.genericWhereClause?.description ?? "")
        
        if let patmodel = Entity.model(name: node.identifier.text,
                                       typeName: t,
                                       acl: current?.acl,
                                       overrideTypes: current?.overrides,
                                       offset: node.offset,
                                       length: node.length,
                                       modelDescription: node.description,
                                       processed: current?.isProcessed ?? false) {
            current?.members.append(patmodel)
        }
        return .visitChildren
    }
    
    func visit(_ node: InitializerDeclSyntax) -> SyntaxVisitorContinueKind {
        current?.hasInit = true
        if let initmodel = Entity.model(name: "init",
                                        typeName: "",
                                        acl: current?.acl,
                                        throwsOrRethrows: node.throwsOrRethrowsKeyword?.text,
                                        isStatic: false,
                                        isInitializer: true,
                                        offset: node.offset,
                                        length: node.length,
                                        modelDescription: node.description,
                                        processed: current?.isProcessed ?? false) {
            current?.members.append(initmodel)
        }
        return .visitChildren
    }
    
    func visit(_ node: FunctionDeclSyntax) -> SyntaxVisitorContinueKind {
        var isStatic = false
        if let mds = node.modifiers {
            for m in mds {
                for t in m.tokens {
                    if t.text == .static {
                        isStatic = true
                        break
                    }
                }
            }
        }
        
        if let funcmodel = Entity.model(name: node.identifier.description,
                                        typeName: node.signature.output?.returnType.description ?? "",
                                        acl: current?.acl,
                                        throwsOrRethrows: node.signature.throwsOrRethrowsKeyword?.text,
                                        isStatic: isStatic,
                                        isInitializer: false,
                                        offset: node.offset,
                                        length: node.length,
                                        modelDescription: node.description,
                                        processed: current?.isProcessed ?? false) {
            current?.members.append(funcmodel)
        }
        return .visitChildren
    }
    
    func visit(_ node: FunctionParameterSyntax) -> SyntaxVisitorContinueKind {
        var label = ""
        var name = ""
        if let first = node.firstName?.text {
            if let second = node.secondName?.text {
                label = first
                name = second
            } else {
                name = first
            }
        }
        
        var type = node.type?.description ?? ""
        if node.description.contains(type + "...") {
            type.append("...")
        }
        
        if let p = Entity.model(name: name,
                                label: label,
                                typeName: type,
                                isGeneric: false,
                                isInitializer: current?.members.last?.isInitializer ?? false,
                                offset: node.offset,
                                length: node.length) as? ParamModel {
            (current?.members.last as? MethodModel)?.params.append(p)
        }
        return .visitChildren
    }
    func visit(_ node: GenericParameterSyntax) -> SyntaxVisitorContinueKind {
        if let p = Entity.model(name: node.name.text,
                                label: "",
                                typeName: node.inheritedType?.description ?? "",
                                isGeneric: true,
                                isInitializer: current?.members.last?.isInitializer ?? false,
                                offset: node.offset,
                                length: node.length) as? ParamModel {
            (current?.members.last as? MethodModel)?.genericTypeParams.append(p)
        }
        
        return .visitChildren
    }
    
    func visit(_ node: ImportDeclSyntax) -> SyntaxVisitorContinueKind {
        if let ret = node.path.firstToken?.text {
            let desc = node.importTok.text + " " + ret
            imports.append(desc)
        }
        return .visitChildren
    }
    
    func visit(_ node: ProtocolDeclSyntax) -> SyntaxVisitorContinueKind {
        topLevel = true
        current = nil
        
        var parentList = [String]()
        if let parents = node.inheritanceClause?.inheritedTypeCollection {
            for p in parents {
                if let pname = p.firstToken?.text {
                    parentList.append(pname)
                }
            }
        }
        
        var isAnnotated = false
        var overrides: [String: String]? = nil
        if !annotation.isEmpty {
            let metadata = node.annotationMetadata(with: annotation)
            isAnnotated = metadata != nil
            overrides = metadata?.typealiases
        }
        
        let ent = Entity(name: node.name,
                         isAnnotated: isAnnotated,
                         overrides: overrides,
                         inheritedTypes: parentList,
                         offset: node.offset,
                         isProcessed: false)
        
        entities.append(ent)
        current = ent
        return .visitChildren
    }
    
    func visit(_ node: ClassDeclSyntax) -> SyntaxVisitorContinueKind {
        topLevel = true
        current = nil
        
        
        let ent = Entity(name: node.name,
                         offset: node.offset,
                         isProcessed: true)
        
        entities.append(ent)
        current = ent
        return .visitChildren
    }
}

extension SyntaxParser {
    public static func parse(_ fileData: Data, path: String,
                             diagnosticEngine: DiagnosticEngine? = nil) throws -> SourceFileSyntax {
        // Avoid using `String(contentsOf:)` because it creates a wrapped NSString.
        let source = fileData.withUnsafeBytes { buf in
            return String(decoding: buf.bindMemory(to: UInt8.self), as: UTF8.self)
        }
        return try parse(source: source, filenameForDiagnostics: path,
                         diagnosticEngine: diagnosticEngine)
    }
    
    public static func parse(_ path: String) throws -> SourceFileSyntax {
        guard let fileData = FileManager.default.contents(atPath: path) else {
            fatalError("Retrieving contents of \(path) failed")
        }
        return try parse(fileData, path: path)
    }
}
