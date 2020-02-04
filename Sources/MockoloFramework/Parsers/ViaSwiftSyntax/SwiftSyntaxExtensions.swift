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
}

extension AttributeListSyntax {
    var trimmedDescription: String? {
        return self.withoutTrivia().description.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

extension ModifierListSyntax {
    var acl: String {
        for modifier in self {
            for token in modifier.tokens {
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
    
    var isStatic: Bool {
        return self.tokens.filter {$0.tokenKind == .staticKeyword }.count > 0
    }

    var isRequired: Bool {
        return self.tokens.filter {$0.text == String.required }.count > 0
    }

    var isConvenience: Bool {
        return self.tokens.filter {$0.text == String.convenience }.count > 0
    }

    var isOverride: Bool {
        return self.tokens.filter {$0.text == String.override }.count > 0
    }
    
    var isFinal: Bool {
        return self.tokens.filter {$0.text == String.final }.count > 0
    }

    var isPrivate: Bool {
        return self.tokens.filter {$0.tokenKind == .privateKeyword || $0.tokenKind == .fileprivateKeyword }.count > 0
    }

    var isPublic: Bool {
        return self.tokens.filter {$0.tokenKind == .publicKeyword }.count > 0
    }
}

extension TypeInheritanceClauseSyntax {
    var types: [String] {
        var list = [String]()
        for element in self.inheritedTypeCollection {
            if let elementName = element.firstToken?.text {
                list.append(elementName)
            }
        }
        return list
    }
    
    var typesDescription: String {
        return self.inheritedTypeCollection.description
    }
}

extension MemberDeclListSyntax {
    
    private func validateMember(_ modifiers: ModifierListSyntax?, _ declType: DeclType) -> Bool {
        if let mods = modifiers, mods.isStatic, declType == .classType {
            return false
        }
        return true
    }
    
    private func validateInit(_ initDecl: InitializerDeclSyntax, _ declType: DeclType, processed: Bool) -> Bool {
        var isRequired = declType == .protocolType
        if !isRequired {
            if let modifiers = initDecl.modifiers {
                isRequired = modifiers.isRequired
            }
        }

        if processed {
            return isRequired
        }

        var isConvenience = false
        var isPrivate = false
        if let modifiers = initDecl.modifiers {
            isConvenience = modifiers.isConvenience
            isPrivate = modifiers.isPrivate
        }
        
        if isConvenience || isPrivate {
            return false
        }
        return true
    }
    
    private func memberAcl(_ modifiers: ModifierListSyntax?, _ encloserAcl: String, _ declType: DeclType) -> String {
        if declType == .protocolType {
             return encloserAcl
        }
        
        return modifiers?.acl ?? ""
    }
    
    func memberData(with encloserAcl: String, declType: DeclType, overrides: [String: String]?, processed: Bool) -> EntityNodeSubContainer {
        var attributeList = [String]()
        var memberList = [Model]()
        var hasInit = false
        var attrDesc: String? = nil
        
        for m in self {
            if let varMember = m.decl as? VariableDeclSyntax {
                if validateMember(varMember.modifiers, declType) {
                    let acl = memberAcl(varMember.modifiers, encloserAcl, declType)
                    memberList.append(contentsOf: varMember.models(with: acl, declType: declType, processed: processed))
                    attrDesc = varMember.attributes?.trimmedDescription
                }
            } else if let funcMember = m.decl as? FunctionDeclSyntax {
                if validateMember(funcMember.modifiers, declType) {
                    let acl = memberAcl(funcMember.modifiers, encloserAcl, declType)
                    memberList.append(funcMember.model(with: acl, declType: declType, processed: processed))
                    attrDesc = funcMember.attributes?.trimmedDescription
                }
            } else if let subscriptMember = m.decl as? SubscriptDeclSyntax {
                if validateMember(subscriptMember.modifiers, declType) {
                    let acl = memberAcl(subscriptMember.modifiers, encloserAcl, declType)
                    memberList.append(subscriptMember.model(with: acl, declType: declType, processed: processed))
                    attrDesc = subscriptMember.attributes?.trimmedDescription
                }
            } else if let initMember = m.decl as? InitializerDeclSyntax {
                if validateInit(initMember, declType, processed: processed) {
                    hasInit = true
                    let acl = memberAcl(initMember.modifiers, encloserAcl, declType)
                    memberList.append(initMember.model(with: acl, declType: declType, processed: processed))
                    attrDesc = initMember.attributes?.trimmedDescription
                }
            } else if let patMember = m.decl as? AssociatedtypeDeclSyntax {
                let acl = memberAcl(patMember.modifiers, encloserAcl, declType)
                memberList.append(patMember.model(with: acl, overrides: overrides, processed: processed))
                attrDesc = patMember.attributes?.trimmedDescription
            } else if let taMember = m.decl as? TypealiasDeclSyntax {
                let acl = memberAcl(taMember.modifiers, encloserAcl, declType)
                memberList.append(taMember.model(with: acl, overrides: overrides, processed: processed))
                attrDesc = taMember.attributes?.trimmedDescription
            }
            
            if let attrDesc = attrDesc {
                attributeList.append(attrDesc.trimmingCharacters(in: .whitespacesAndNewlines))
            }
        }
        
        return EntityNodeSubContainer(attributes: attributeList, members: memberList, hasInit: hasInit)
    }
}

extension ProtocolDeclSyntax: EntityNode {
    var name: String {
        return identifier.text
    }
    
    var acl: String {
        return self.modifiers?.acl ?? ""
    }
    
    var declType: DeclType {
        return .protocolType
    }
    
    var isPrivate: Bool {
        return self.modifiers?.isPrivate ?? false
    }

    var inheritedTypes: [String] {
        return inheritanceClause?.types ?? []
    }
    
    var attributesDescription: String {
        self.attributes?.trimmedDescription ?? ""
    }
    
    var offset: Int64 {
        return Int64(self.position.utf8Offset)
    }
    
    func annotationMetadata(with annotation: String) -> AnnotationMetadata? {
        return leadingTrivia?.annotationMetadata(with: annotation)
    }
    
    func subContainer(overrides: [String: String]?, declType: DeclType, path: String?, data: Data?, isProcessed: Bool) -> EntityNodeSubContainer {
        return self.members.members.memberData(with: acl, declType: declType, overrides: overrides, processed: isProcessed)
    }
}

extension ClassDeclSyntax: EntityNode {
    
    var name: String {
        return identifier.text
    }
    
    var acl: String {
        return self.modifiers?.acl ?? ""
    }

    var declType: DeclType {
        return .classType
    }

    var inheritedTypes: [String] {
        return inheritanceClause?.types ?? []
    }
    
    var attributesDescription: String {
        self.attributes?.trimmedDescription ?? ""
    }
    
    var offset: Int64 {
        return Int64(self.position.utf8Offset)
    }
    
    var isFinal: Bool {
        return self.modifiers?.isFinal ?? false
    }

    var isPrivate: Bool {
        return self.modifiers?.isPrivate ?? false
    }

    var isPublic: Bool {
        return self.modifiers?.isPublic ?? false
    }

    func annotationMetadata(with annotation: String) -> AnnotationMetadata? {
        return leadingTrivia?.annotationMetadata(with: annotation)
    }
    
    func subContainer(overrides: [String: String]?, declType: DeclType, path: String?, data: Data?, isProcessed: Bool) -> EntityNodeSubContainer {
        return self.members.members.memberData(with: acl, declType: declType, overrides: nil, processed: isProcessed)
    }
}

extension VariableDeclSyntax {
    
    func models(with acl: String, declType: DeclType, processed: Bool) -> [Model] {
        // Detect whether it's static
        var isStatic = false
        if let modifiers = self.modifiers {
            isStatic = modifiers.isStatic
        }
        
        // Need to access pattern bindings to get name, type, and other info of a var decl
        let varmodels = self.bindings.compactMap { (v: PatternBindingSyntax) -> Model in
            let name = v.pattern.firstToken?.text ?? String.unknownVal
            var typeName = ""
            var potentialInitParam = false
            
            // Get the type info and whether it can be a var param for an initializer
            if let vtype = v.typeAnnotation?.type.description {
                typeName = vtype
                potentialInitParam = !isStatic &&
                    !vtype.hasSuffix("?") &&
                    !name.hasPrefix(.underlyingVarPrefix) &&
                    !name.hasSuffix(.closureVarSuffix) &&
                    !name.hasSuffix(.callCountSuffix) &&
                    !name.hasSuffix(.subjectSuffix) &&
                    vtype != .unknownVal
            }
            
            let varmodel = VariableModel(name: name,
                                         typeName: typeName,
                                         acl: acl,
                                         encloserType: declType,
                                         isStatic: isStatic,
                                         canBeInitParam: potentialInitParam,
                                         offset: v.offset,
                                         length: v.length,
                                         modelDescription: self.description,
                                         processed: processed)
            return varmodel
        }
        return varmodels
    }
}

extension SubscriptDeclSyntax {
    func model(with acl: String, declType: DeclType, processed: Bool) -> Model {
        var isStatic = false
        if let modifiers = self.modifiers {
            isStatic = modifiers.isStatic
        }

        let params = self.indices.parameterList.compactMap { $0.model(inInit: false, declType: declType) }
        let genericTypeParams = self.genericParameterClause?.genericParameterList.compactMap { $0.model(inInit: false) } ?? []
        
        let subscriptModel = MethodModel(name: self.subscriptKeyword.text,
                                            typeName: self.result.returnType.description,
                                            kind: .subscriptKind,
                                            encloserType: declType,
                                            acl: acl,
                                            genericTypeParams: genericTypeParams,
                                            params: params,
                                            throwsOrRethrows: "",
                                            isStatic: isStatic,
                                            offset: self.offset,
                                            length: self.length,
                                            modelDescription: self.description,
                                            processed: processed)
        return subscriptModel
    }
}

extension FunctionDeclSyntax {
    
    func model(with acl: String, declType: DeclType, processed: Bool) -> Model {
        var isStatic = false
        if let modifiers = self.modifiers {
            isStatic = modifiers.isStatic
        }

        let params = self.signature.input.parameterList.compactMap { $0.model(inInit: false, declType: declType) }
        let genericTypeParams = self.genericParameterClause?.genericParameterList.compactMap { $0.model(inInit: false) } ?? []
        
        let funcmodel = MethodModel(name: self.identifier.description,
                                    typeName: self.signature.output?.returnType.description ?? "",
                                    kind: .funcKind,
                                    encloserType: declType,
                                    acl: acl,
                                    genericTypeParams: genericTypeParams,
                                    params: params,
                                    throwsOrRethrows: self.signature.throwsOrRethrowsKeyword?.text ?? "",
                                    isStatic: isStatic,
                                    offset: self.offset,
                                    length: self.length,
                                    modelDescription: self.description,
                                    processed: processed)
        return funcmodel
    }
}

extension InitializerDeclSyntax {
    func isRequired(with declType: DeclType) -> Bool {
        if declType == .protocolType {
            return true
        } else if declType == .classType {
            if let modifiers = self.modifiers {
                
                if modifiers.isConvenience {
                    return false
                }
                return modifiers.isRequired
            }
        }
        return false
    }
    
    func model(with acl: String, declType: DeclType, processed: Bool) -> Model {
        let requiredInit = isRequired(with: declType)
        
        let params = self.parameters.parameterList.compactMap { $0.model(inInit: true, declType: declType) }
        let genericTypeParams = self.genericParameterClause?.genericParameterList.compactMap { $0.model(inInit: true) } ?? []
        
        return MethodModel(name: "init",
                           typeName: "",
                           kind: .initKind(required: requiredInit),
                           encloserType: declType,
                           acl: acl,
                           genericTypeParams: genericTypeParams,
                           params: params,
                           throwsOrRethrows: self.throwsOrRethrowsKeyword?.text ?? "",
                           isStatic: false,
                           offset: self.offset,
                           length: self.length,
                           modelDescription: self.description,
                           processed: processed)
    }
    
}


extension GenericParameterSyntax {
    func model(inInit: Bool) -> ParamModel {
        return ParamModel(label: "",
                          name: self.name.text,
                          typeName: self.inheritedType?.description ?? "",
                          isGeneric: true,
                          inInit: inInit,
                          needVarDecl: false,
                          offset: self.offset,
                          length: self.length)
    }
    
}

extension FunctionParameterSyntax {
    func model(inInit: Bool, declType: DeclType) -> ParamModel {
        var label = ""
        var name = ""
        // Get label and name of args
        if let first = self.firstName?.text {
            if let second = self.secondName?.text {
                label = first
                name = second
            } else {
                if first == "_" {
                    label = first
                    name = first + "arg"
                } else {
                    name = first
                }
            }
        }
        
        // Variadic args are not detected in the parser so need to manually look up
        var type = self.type?.description ?? ""
        if self.description.contains(type + "...") {
            type.append("...")
        }
        
        return ParamModel(label: label,
                          name: name,
                          typeName: type,
                          isGeneric: false,
                          inInit: inInit,
                          needVarDecl: declType == .protocolType,
                          offset: self.offset,
                          length: self.length)
    }
    
}

extension AssociatedtypeDeclSyntax {
    func model(with acl: String, overrides: [String: String]?, processed: Bool) -> Model {
        // Get the inhertied type for an associated type if any
        var t = self.inheritanceClause?.typesDescription ?? ""
        t.append(self.genericWhereClause?.description ?? "")
        
        return TypeAliasModel(name: self.identifier.text,
                              typeName: t,
                              acl: acl,
                              overrideTypes: overrides,
                              offset: self.offset,
                              length: self.length,
                              modelDescription: self.description,
                              processed: processed)
    }
}


extension TypealiasDeclSyntax {
    func model(with acl: String, overrides: [String: String]?, processed: Bool) -> Model {
        // Get the inhertied type for an associated type if any
//        var t = self.inheritanceClause?.typesDescription ?? ""
//        t.append(self.genericWhereClause?.description ?? "")
//
//        return TypeAliasModel(name: self.identifier.text,
//                              typeName: t,
//                              acl: acl,
//                              overrideTypes: overrides,
//                              offset: self.offset,
//                              length: self.length,
//                              modelDescription: self.description,
//                              processed: processed)
        fatalError()
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
    
    func visit(_ node: ProtocolDeclSyntax) -> SyntaxVisitorContinueKind {
        let metadata = node.annotationMetadata(with: annotation)
        if let ent = Entity.node(with: node, isPrivate: node.isPrivate, isFinal: false, metadata: metadata, processed: false) {
            entities.append(ent)
        }
        return .skipChildren
    }
    
    func visit(_ node: ClassDeclSyntax) -> SyntaxVisitorContinueKind {
        if node.name.hasSuffix("Mock") {
            // this mock class node must be public else wouldn't have compiled before
            if let ent = Entity.node(with: node, isPrivate: node.isPrivate, isFinal: false, metadata: nil, processed: true) {
                entities.append(ent)
            }
        } else {
            let metadata = node.annotationMetadata(with: annotation)
            if let ent = Entity.node(with: node, isPrivate: node.isPrivate, isFinal: node.isFinal, metadata: metadata, processed: false) {
                entities.append(ent)
            }
        }
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
    // This parses arguments in annotation which can be used to override certain types.
    //
    // E.g. given /// @mockable(typealias: T = Any; U = AnyObject), it returns
    // a dictionary: [T: Any, U: AnyObject] which will be used to override inhertied types
    // of typealias decls for T and U.
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
    
    // Looks up an annotation (e.g. /// @mockable) and its arguments if any.
    // See metadata(with:, in:) for more info on the annotation arguments.
    func annotationMetadata(with annotation: String) -> AnnotationMetadata? {
        guard !annotation.isEmpty else { return nil }
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
