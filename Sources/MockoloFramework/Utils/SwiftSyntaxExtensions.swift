//
//  SwiftSyntaxExtensions.swift
//  MockoloFramework
//
//  Created by Ellie Shin on 10/29/19.
//

import Foundation
import SwiftSyntax

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

extension Syntax {
    var offset: Int64 {
        return Int64(self.position.utf8Offset)
    }
    
    var length: Int64 {
        return Int64(self.totalLength.utf8Length)
    }

    func annotationMetadata(with annotation: String) -> AnnotationMetadata? {
        return leadingTrivia?.annotationMetadata(with: annotation)
    }
}

final class EntityVisitor: SyntaxVisitor {
    var entities: [Entity] = []
    var imports: [String] = []
    let annotation: String
    
    init(annotation: String = "") {
        self.annotation = annotation
    }
    
    func reset() {
        entities = []
        imports = []
    }

    // Returns access control level
    private func acl(_  modifiers: ModifierListSyntax) -> String {
        for m in modifiers {
            for token in m.tokens {
                switch token.tokenKind {
                case .publicKeyword, .internalKeyword, .privateKeyword, .fileprivateKeyword:
                    return token.text
                default:
                    // For some reason openKeyword option is not available in TokenKind so need to address separately
                    if token.text == String.open {
                        return token.text
                    }
                    return ""
                }
            }
        }
        return ""
    }
    
    private func hasStaticModifier(_  modifiers: ModifierListSyntax) -> Bool {
        return modifiers.tokens.filter {$0.tokenKind == .staticKeyword }.count > 0
    }
    
    private func typealiasModel(_ node: AssociatedtypeDeclSyntax, overrides: [String: String]?, acl: String, processed: Bool) -> Model? {
        // Get the inhertied type for an associated type if any
        var t = node.inheritanceClause?.inheritedTypeCollection.description ?? ""
        t.append(node.genericWhereClause?.description ?? "")
        
        return Entity.model(name: node.identifier.text,
                              typeName: t,
                              acl: acl,
                              overrideTypes: overrides,
                              offset: node.offset,
                              length: node.length,
                              modelDescription: node.description,
                              processed: processed)
    }
    
    private func initModel(_ node: InitializerDeclSyntax, acl: String, processed: Bool) -> Model? {
        let params = node.parameters.parameterList.compactMap { paramModel($0, isInitializer: true) }
        let genericTypeParams = node.genericParameterClause?.genericParameterList.compactMap { genericTypeParamModel($0, isInitializer: true) }
        
        return Entity.model(name: "init",
                           typeName: "",
                           acl: acl,
                           genericTypeParams: genericTypeParams,
                           params: params,
                           throwsOrRethrows: node.throwsOrRethrowsKeyword?.text,
                           isStatic: false,
                           isInitializer: true,
                           offset: node.offset,
                           length: node.length,
                           modelDescription: node.description,
                           processed: processed)
    }
    
    private func funcModel(_ node: FunctionDeclSyntax, acl: String, processed: Bool) -> Model? {
        var isStatic = false
        if let modifiers = node.modifiers {
            isStatic = hasStaticModifier(modifiers)
        }
        
        let params = node.signature.input.parameterList.compactMap { paramModel($0, isInitializer: false) }
        let genericTypeParams = node.genericParameterClause?.genericParameterList.compactMap { genericTypeParamModel($0, isInitializer: false) }
        
        let funcmodel = Entity.model(name: node.identifier.description,
                                    typeName: node.signature.output?.returnType.description ?? "",
                                    acl: acl,
                                    genericTypeParams: genericTypeParams,
                                    params: params,
                                    throwsOrRethrows: node.signature.throwsOrRethrowsKeyword?.text,
                                    isStatic: isStatic,
                                    isInitializer: false,
                                    offset: node.offset,
                                    length: node.length,
                                    modelDescription: node.description,
                                    processed: processed)
        return funcmodel
    }
    
    private func paramModel(_ node: FunctionParameterSyntax, isInitializer: Bool) -> Model? {
        var label = ""
        var name = ""
        // Get label and name of args
        if let first = node.firstName?.text {
            if let second = node.secondName?.text {
                label = first
                name = second
            } else {
                name = first
            }
        }
        
        // Variadic args are not detected in the parser so need to manually look up
        var type = node.type?.description ?? ""
        if node.description.contains(type + "...") {
            type.append("...")
        }
        
        return Entity.model(label: label,
                          name: name,
                          typeName: type,
                          isGeneric: false,
                          isInitializer: isInitializer,
                          offset: node.offset,
                          length: node.length)
    }
    
    private func genericTypeParamModel(_ node: GenericParameterSyntax, isInitializer: Bool) -> Model? {
        return Entity.model(label: "",
                            name: node.name.text,
                            typeName: node.inheritedType?.description ?? "",
                            isGeneric: true,
                            isInitializer: isInitializer,
                            offset: node.offset,
                            length: node.length)
    }
    
    private func varModels(_ node: VariableDeclSyntax, acl: String, processed: Bool) -> [Model] {
        // Detect whether it's static
        var isStatic = false
        if let modifiers = node.modifiers {
            isStatic = hasStaticModifier(modifiers)
        }

        // Need to access pattern bindings to get name, type, and other info of a var decl
        let varmodels = node.bindings.compactMap { (v: PatternBindingSyntax) -> Model? in
            let name = v.pattern.firstToken?.text ?? String.unknownVal
            var typeName = ""
            var canBeInitParam = false
            
            // Get the type info and whether it can be a var param for an initializer
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
            
            let varmodel = Entity.model(name: name,
                                         typeName: typeName,
                                         acl: acl,
                                         isStatic: isStatic,
                                         canBeInitParam: canBeInitParam,
                                         offset: v.offset,
                                         length: v.length,
                                         modelDescription: node.description,
                                         processed: processed)
            return varmodel
        }
        return varmodels
    }
    
    private func memberList(_ members: MemberDeclListSyntax, overrides: [String: String]?, acl: String, processed: Bool) -> ([String], [Model], Bool) {
        var attributeList = [String]()
        var memberList = [Model]()
        var hasInit = false
        
        for m in members {
            if let varMember = m.decl as? VariableDeclSyntax {
                let ret = varModels(varMember, acl: acl, processed: processed)
                memberList.append(contentsOf: ret)
                if let attrDesc = varMember.attributes?.withoutTrivia().description {
                    attributeList.append(attrDesc.trimmingCharacters(in: .whitespacesAndNewlines))
                }
            } else if let funcMember = m.decl as? FunctionDeclSyntax {
                if let ret = funcModel(funcMember, acl: acl, processed: processed) {
                    memberList.append(ret)
                }
                if let attrDesc = funcMember.attributes?.withoutTrivia().description {
                    attributeList.append(attrDesc.trimmingCharacters(in: .whitespacesAndNewlines))
                }
            } else if let initMember = m.decl as? InitializerDeclSyntax {
                hasInit = true
                if let ret = initModel(initMember, acl: acl, processed: processed) {
                    memberList.append(ret)
                }
                if let attrDesc = initMember.attributes?.withoutTrivia().description {
                    attributeList.append(attrDesc.trimmingCharacters(in: .whitespacesAndNewlines))
                }
            } else if let patMember = m.decl as? AssociatedtypeDeclSyntax {
                if let ret = typealiasModel(patMember, overrides: overrides, acl: acl, processed: processed) {
                    memberList.append(ret)
                }
                if let attrDesc = patMember.attributes?.withoutTrivia().description {
                    attributeList.append(attrDesc.trimmingCharacters(in: .whitespacesAndNewlines))
                }
            }
        }
        
        return (attributeList, memberList, hasInit)
    }
    
    func visit(_ node: ProtocolDeclSyntax) -> SyntaxVisitorContinueKind {
        var isAnnotated = false
        var overrides: [String: String]? = nil
        if !annotation.isEmpty {
            let metadata = node.annotationMetadata(with: annotation)
            isAnnotated = metadata != nil
            overrides = metadata?.typealiases
        }
        
        var parentList = [String]()
        if let parents = node.inheritanceClause?.inheritedTypeCollection {
            for p in parents {
                if let pname = p.firstToken?.text {
                    parentList.append(pname)
                }
            }
        }
        
        var aclDesc = ""
        if let mds = node.modifiers{
            aclDesc = acl(mds)
        }
        
        let (attributes, members, hasInit) = memberList(node.members.members, overrides: overrides, acl: aclDesc, processed: false)
        
        var attributeList = attributes
        if let attrDesc = node.attributes?.withoutTrivia().description {
            attributeList.append(attrDesc.trimmingCharacters(in: .whitespacesAndNewlines))
        }
        
        let ent = Entity(name: node.identifier.text,
                         isAnnotated: isAnnotated,
                         overrides: overrides,
                         acl: aclDesc,
                         attributes: attributeList,
                         inheritedTypes: parentList,
                         members: members,
                         hasInit: hasInit,
                         offset: node.offset,
                         isProcessed: false)
        entities.append(ent)
        return .skipChildren
    }
    
    func visit(_ node: ClassDeclSyntax) -> SyntaxVisitorContinueKind {
        var aclDesc = ""
        if let mds = node.modifiers {
            aclDesc = acl(mds)
        }
        
        let (attributes, members, hasInit) = memberList(node.members.members, overrides: nil, acl: aclDesc, processed: true)
        
        var attributeList = attributes
        if let attrDesc = node.attributes?.withoutTrivia().description {
            attributeList.append(attrDesc.trimmingCharacters(in: .whitespacesAndNewlines))
        }
        
        let ent = Entity(name: node.identifier.text,
                         isAnnotated: false,
                         overrides: nil,
                         acl: aclDesc,
                         attributes: attributeList,
                         inheritedTypes: [],
                         members: members,
                         hasInit: hasInit,
                         offset: node.offset,
                         isProcessed: false)
        entities.append(ent)
        return .skipChildren
    }
    
    func visit(_ node: ImportDeclSyntax) -> SyntaxVisitorContinueKind {
        if let ret = node.path.firstToken?.text {
            let desc = node.importTok.text + " " + ret
            imports.append(desc)
        }
        return .visitChildren
    }
}

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
