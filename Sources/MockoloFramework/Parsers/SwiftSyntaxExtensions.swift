//
//  Copyright (c) 2018. Uber Technologies
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Algorithms
import Foundation
import SwiftSyntax
import SwiftParser

extension Parser {
    public static func parse(_ path: String) -> SourceFileSyntax {
        guard let fileData = FileManager.default.contents(atPath: path) else {
            fatalError("Retrieving contents of \(path) failed")
        }
        return fileData.withUnsafeBytes { buf in
            parse(source: buf.bindMemory(to: UInt8.self))
        }
    }
}

extension SyntaxProtocol {
    var offset: Int64 {
        return Int64(self.position.utf8Offset)
    }

    var length: Int64 {
        return Int64(self.totalLength.utf8Length)
    }
}

extension DeclModifierListSyntax {
    var acl: String {
        for modifier in self {
            for token in modifier.tokens(viewMode: .sourceAccurate) {
                switch token.tokenKind {
                case .keyword(.private),
                        .keyword(.fileprivate),
                        .keyword(.internal),
                        .keyword(.package),
                        .keyword(.public),
                        .keyword(.open):
                    return token.text
                default:
                    return ""
                }
            }
        }
        return ""
    }

    var isStatic: Bool {
        return self.tokens(viewMode: .sourceAccurate).contains {$0.tokenKind == .keyword(.static) }
    }

    var isRequired: Bool {
        return self.tokens(viewMode: .sourceAccurate).contains {$0.text == String.required }
    }

    var isConvenience: Bool {
        return self.tokens(viewMode: .sourceAccurate).contains {$0.text == String.convenience }
    }

    var isOverride: Bool {
        return self.tokens(viewMode: .sourceAccurate).contains {$0.text == String.override }
    }

    var isFinal: Bool {
        return self.tokens(viewMode: .sourceAccurate).contains {$0.text == String.final }
    }

    var isPrivate: Bool {
        return self.tokens(viewMode: .sourceAccurate).contains {$0.tokenKind == .keyword(.private) || $0.tokenKind == .keyword(.fileprivate) }
    }

    var isPublic: Bool {
        return self.tokens(viewMode: .sourceAccurate).contains {$0.tokenKind == .keyword(.public) }
    }
}

extension InheritanceClauseSyntax {
    var types: [String] {
        var list = [String]()
        for element in self.inheritedTypes {
            let elementNameList = parseElementType(type: element.type)
            list.append(contentsOf: elementNameList)
        }
        return list
    }

    private func parseElementType(type: TypeSyntax) -> [String] {
        if let simpleTypeIdentifier = type.as(IdentifierTypeSyntax.self) {
            // example: `protocol A: B {}`
            return [simpleTypeIdentifier.name.text]
        } else if let tupleType = type.as(TupleTypeSyntax.self) {
            // example: `protocol A: (B) {}`
            return tupleType.elements.map(\.type).map(parseElementType(type:)).flatMap { $0 }
        } else if let compositionType = type.as(CompositionTypeSyntax.self) {
            // example: `protocol A: B & C {}`
            return compositionType.elements.map(\.type).map(parseElementType(type:)).flatMap { $0 }
        } else if let attributedType = type.as(AttributedTypeSyntax.self) {
            // example: `protocol A: @unchecked B {}`
            if let baseType = attributedType.baseType.as(IdentifierTypeSyntax.self) {
                return [baseType.name.text]
            }
        }
        return []
    }
}

extension MemberBlockItemSyntax {
    private func validateMember(_ modifiers: DeclModifierListSyntax?, _ declKind: NominalTypeDeclKind, processed: Bool) -> Bool {
        if let mods = modifiers {
            if !processed && mods.isPrivate || mods.isStatic && declKind == .class {
                return false
            }
        }
        return true
    }

    private func validateInit(_ initDecl: InitializerDeclSyntax, _ declKind: NominalTypeDeclKind, processed: Bool) -> Bool {
        let modifiers = initDecl.modifiers
        let isRequired = modifiers.isRequired
        if processed {
            return isRequired
        }
        let isConvenience = modifiers.isConvenience
        let isPrivate = modifiers.isPrivate

        if isConvenience || isPrivate {
            return false
        }
        return true
    }

    private func memberAcl(_ modifiers: DeclModifierListSyntax?, _ encloserAcl: String, _ declKind: NominalTypeDeclKind) -> String {
        if declKind == .protocol {
            return encloserAcl
        }
        return modifiers?.acl ?? ""
    }

    func transformToModel(with encloserAcl: String, declKind: NominalTypeDeclKind, metadata: AnnotationMetadata?, processed: Bool) -> (Model, String?, Bool)? {
        if let varMember = self.decl.as(VariableDeclSyntax.self) {
            if validateMember(varMember.modifiers, declKind, processed: processed) {
                let acl = memberAcl(varMember.modifiers, encloserAcl, declKind)
                if let item = varMember.models(with: acl, metadata: metadata, processed: processed).first {
                    return (item, varMember.attributes.trimmedDescription, false)
                }
            }
        } else if let funcMember = self.decl.as(FunctionDeclSyntax.self) {
            if validateMember(funcMember.modifiers, declKind, processed: processed) {
                let acl = memberAcl(funcMember.modifiers, encloserAcl, declKind)
                let item = funcMember.model(with: acl, declKind: declKind, funcsWithArgsHistory: metadata?.funcsWithArgsHistory, customModifiers: metadata?.modifiers, processed: processed)
                return (item, funcMember.attributes.trimmedDescription, false)
            }
        } else if let subscriptMember = self.decl.as(SubscriptDeclSyntax.self) {
            if validateMember(subscriptMember.modifiers, declKind, processed: processed) {
                let acl = memberAcl(subscriptMember.modifiers, encloserAcl, declKind)
                let item = subscriptMember.model(with: acl, declKind: declKind, processed: processed)
                return (item, subscriptMember.attributes.trimmedDescription, false)
            }
        } else if let initMember = self.decl.as(InitializerDeclSyntax.self) {
            if validateInit(initMember, declKind, processed: processed) {
                let acl = memberAcl(initMember.modifiers, encloserAcl, declKind)
                let item = initMember.model(with: acl, declKind: declKind, processed: processed)
                return (item, initMember.attributes.trimmedDescription, true)
            }
        } else if let patMember = self.decl.as(AssociatedTypeDeclSyntax.self) {
            let acl = memberAcl(patMember.modifiers, encloserAcl, declKind)
            let item = patMember.model(with: acl, declKind: declKind, overrides: metadata?.typeAliases)
            return (item, patMember.attributes.trimmedDescription, false)
        } else if let taMember = self.decl.as(TypeAliasDeclSyntax.self) {
            let acl = memberAcl(taMember.modifiers, encloserAcl, declKind)
            let item = taMember.model(with: acl, declKind: declKind, overrides: metadata?.typeAliases, processed: processed)
            return (item, taMember.attributes.trimmedDescription, false)
        } else if let ifMacroMember = self.decl.as(IfConfigDeclSyntax.self) {
            let (item, attr, initFlag) = ifMacroMember.model(with: encloserAcl, declKind: declKind, metadata: metadata, processed: processed)
            return (item, attr, initFlag)
        }

        return nil
    }
}

extension MemberBlockItemListSyntax {
    var hasBlankInit: Bool {
        for member in self {
            if let varMember = member.decl.as(VariableDeclSyntax.self) {
                for v in varMember.bindings {
                    if let name = v.pattern.firstToken(viewMode: .sourceAccurate)?.text {
                        if name == String.hasBlankInit {
                            return true
                        }
                    }
                }
            }
        }
        return false
    }

    func memberData(with encloserAcl: String, declKind: NominalTypeDeclKind, metadata: AnnotationMetadata?, processed: Bool) -> EntityNodeSubContainer {
        var attributeList = [String]()
        var memberList = [Model]()
        var hasInit = false

        for m in self {
            if let (item, attr, initFlag) = m.transformToModel(with: encloserAcl, declKind: declKind, metadata: metadata, processed: processed) {
                memberList.append(item)
                if let attrDesc = attr {
                    attributeList.append(attrDesc)
                }
                hasInit = hasInit || initFlag
            }
        }
        return EntityNodeSubContainer(attributes: attributeList, members: memberList, hasInit: hasInit)
    }
}

extension IfConfigDeclSyntax {
    func model(with encloserAcl: String, declKind: NominalTypeDeclKind, metadata: AnnotationMetadata?, processed: Bool) -> (Model, String?, Bool) {
        var clauseList = [IfMacroModel.Clause]()
        var attrDesc: String?
        var hasInit = false

        for (index, cl) in self.clauses.enumerated() {
            guard let clauseType = ClauseType(cl) else {
                continue
            }

            var subModels = [Model]()
            if let list = cl.elements?.as(MemberBlockItemListSyntax.self) {
                for element in list {
                    if let (item, attr, initFlag) = element.transformToModel(with: encloserAcl, declKind: declKind, metadata: metadata, processed: processed) {
                        subModels.append(item)
                        if let attr = attr, attr.contains(String.available) {
                            attrDesc = attr
                        }
                        hasInit = hasInit || initFlag
                    }
                }
            }

            // Process entities for this clause
            let uniqueSubModels = uniqueEntities(
                in: subModels,
                exclude: [:],
                fullnames: []
            ).sorted(path: \.value.offset, fallback: \.key)

            clauseList.append(IfMacroModel.Clause(
                type: clauseType,
                entities: uniqueSubModels
            ))
        }

        let macroModel = IfMacroModel(clauses: clauseList, offset: self.offset)
        return (macroModel, attrDesc, hasInit)
    }
}

extension ProtocolDeclSyntax: EntityNode {
    var namespaces: [String] {
        return findNamespaces(parent: parent)
    }

    var nameText: String {
        return name.text
    }

    var mayHaveGlobalActor: Bool {
        return attributes.mayHaveGlobalActor
    }

    var accessLevel: String {
        return self.modifiers.acl 
    }

    var declKind: NominalTypeDeclKind {
        return .protocol
    }

    var isPrivate: Bool {
        return self.modifiers.isPrivate 
    }

    var inheritedTypes: [String] {
        return inheritanceClause?.types ?? []
    }

    var genericWhereConstraints: [String] {
        return genericWhereClause?.requirements.map { $0.with(\.trailingComma, nil).trimmedDescription } ?? []
    }

    var attributesDescription: String {
        self.attributes.trimmedDescription
    }

    func annotationMetadata(with annotation: String) -> AnnotationMetadata? {
        let trivias = [
            leadingTrivia,
            protocolKeyword.leadingTrivia,
            modifiers.leadingTrivia,
        ] + attributes.map(\.leadingTrivia)
        return trivias.firstNonNil { $0.annotationMetadata(with: annotation) }
    }

    var hasBlankInit: Bool {
        return false
    }

    func subContainer(metadata: AnnotationMetadata?, declKind: NominalTypeDeclKind, path: String?, isProcessed: Bool) -> EntityNodeSubContainer {
        return self.memberBlock.members.memberData(with: accessLevel, declKind: declKind, metadata: metadata, processed: isProcessed)
    }
}

extension ClassDeclSyntax: EntityNode {
    var namespaces: [String] {
        return findNamespaces(parent: parent)
    }

    var nameText: String {
        return name.text
    }

    var mayHaveGlobalActor: Bool {
        return attributes.mayHaveGlobalActor
    }

    var accessLevel: String {
        return self.modifiers.acl 
    }

    var declKind: NominalTypeDeclKind {
        return .class
    }

    var inheritedTypes: [String] {
        return inheritanceClause?.types ?? []
    }

    var genericWhereConstraints: [String] {
        return genericWhereClause?.requirements.map { $0.with(\.trailingComma, nil).trimmedDescription } ?? []
    }

    var attributesDescription: String {
        self.attributes.trimmedDescription
    }

    var isFinal: Bool {
        return self.modifiers.isFinal 
    }

    var isPrivate: Bool {
        return self.modifiers.isPrivate 
    }

    var isPublic: Bool {
        return self.modifiers.isPublic 
    }

    var hasBlankInit: Bool {
        return self.memberBlock.members.hasBlankInit
    }

    func annotationMetadata(with annotation: String) -> AnnotationMetadata? {
        let trivias = [
            leadingTrivia,
            classKeyword.leadingTrivia,
            modifiers.leadingTrivia,
        ] + attributes.map(\.leadingTrivia)
        return trivias.firstNonNil { $0.annotationMetadata(with: annotation) }
    }

    func subContainer(metadata: AnnotationMetadata?, declKind: NominalTypeDeclKind, path: String?, isProcessed: Bool) -> EntityNodeSubContainer {
        return self.memberBlock.members.memberData(with: accessLevel, declKind: declKind, metadata: nil, processed: isProcessed)
    }
}

fileprivate func findNamespaces(parent: Syntax?) -> [String] {
    guard let parent else {
        return []
    }
    return sequence(first: parent, next: \.parent)
        .compactMap { element in
            if let decl = element.as(StructDeclSyntax.self) {
                return decl.name.trimmedDescription
            } else if let decl = element.as(EnumDeclSyntax.self) {
                return decl.name.trimmedDescription
            } else if let decl = element.as(ClassDeclSyntax.self) {
                return decl.name.trimmedDescription
            } else if let decl = element.as(ActorDeclSyntax.self) {
                return decl.name.trimmedDescription
            } else if let decl = element.as(ExtensionDeclSyntax.self) {
                return decl.extendedType.trimmedDescription
            } else {
                return nil
            }
        }
        .reversed()
}

extension AttributeListSyntax {
    fileprivate var mayHaveGlobalActor: Bool {
        let wellKnownGlobalActor: Set<String> = [.mainActor]
        return self.contains { element in
            switch element {
            case .attribute(let attribute):
                return wellKnownGlobalActor.contains(attribute.attributeName.trimmedDescription)
            case .ifConfigDecl(let ifConfig):
                return ifConfig.clauses.contains { clause in
                    if case .attributes(let attributes) = clause.elements {
                        return attributes.mayHaveGlobalActor
                    }
                    return false
                }
            }
        }
    }
}

extension VariableDeclSyntax {
    func models(with acl: String, metadata: AnnotationMetadata?, processed: Bool) -> [Model] {
        // Detect whether it's static
        let isStatic = self.modifiers.isStatic

        // Need to access pattern bindings to get name, type, and other info of a var decl
        let varmodels = self.bindings.compactMap { (v: PatternBindingSyntax) -> Model in
            let name = v.pattern.trimmedDescription
            var swiftType: SwiftType?
            var potentialInitParam = false

            // Get the type info and whether it can be a var param for an initializer
            if let vtype = v.typeAnnotation?.type {
                let type = SwiftType(typeSyntax: vtype)
                potentialInitParam = name.canBeInitParam(type: type, isStatic: isStatic)
                swiftType = type
            } else {
                swiftType = nil
            }

            let storageKind: VariableModel.MockStorageKind
            switch v.accessorBlock?.accessors {
            case .accessors(let accessorDecls):
                if accessorDecls.contains(where: { $0.accessorSpecifier.tokenKind == .keyword(.set) }) {
                    storageKind = .stored(needsSetCount: true)
                } else if let getterDecl = accessorDecls.first(where: { $0.accessorSpecifier.tokenKind == .keyword(.get) }) {
                    if getterDecl.body == nil { // is protoccol
                        var getterEffects = VariableModel.GetterEffects.empty
                        if getterDecl.effectSpecifiers?.asyncSpecifier != nil {
                            getterEffects.isAsync = true
                        }
                        if let `throws` = getterDecl.effectSpecifiers?.throwsClause {
                            getterEffects.throwing = .init(`throws`)
                        }
                        if getterEffects == .empty {
                            storageKind = .stored(needsSetCount: false)
                        } else {
                            storageKind = .computed(getterEffects)
                        }
                    } else { // is class
                        storageKind = .computed(.empty)
                    }
                } else {
                    // will never happens
                    storageKind = .stored(needsSetCount: false) // fallback
                }
            case .getter:
                storageKind = .computed(.empty)
            case nil:
                storageKind = .stored(needsSetCount: true)
            }

            return VariableModel(name: name,
                                 type: swiftType,
                                 acl: acl,
                                 isStatic: isStatic,
                                 storageKind: storageKind,
                                 canBeInitParam: potentialInitParam,
                                 offset: v.offset,
                                 rxTypes: metadata?.varTypes,
                                 customModifiers: metadata?.modifiers,
                                 modelDescription: self.description,
                                 combineType: metadata?.combineTypes?[name] ?? metadata?.combineTypes?["all"],
                                 processed: processed)
        }
        return varmodels
    }
}

extension SubscriptDeclSyntax {
    func model(with acl: String, declKind: NominalTypeDeclKind, processed: Bool) -> Model {
        let isStatic = self.modifiers.isStatic

        let params = self.parameterClause.parameters.enumerated().compactMap {
            $1.model(inInit: false, declKind: declKind, index: $0)
        }
        let genericTypeParams = self.genericParameterClause?.parameters.compactMap { $0.model(inInit: false) } ?? []
        let genericWhereClause = self.genericWhereClause?.description

        let subscriptModel = MethodModel(name: self.subscriptKeyword.text,
                                         returnType: SwiftType(typeSyntax: self.returnClause.type),
                                         kind: .subscriptKind,
                                         acl: acl,
                                         genericTypeParams: genericTypeParams,
                                         genericWhereClause: genericWhereClause,
                                         params: params,
                                         isAsync: false,
                                         throwing: .none,
                                         isStatic: isStatic,
                                         offset: self.offset,
                                         length: self.length,
                                         funcsWithArgsHistory: [],
                                         customModifiers: [:],
                                         modelDescription: self.description,
                                         processed: processed)
        return subscriptModel
    }
}

extension FunctionDeclSyntax {

    func model(with acl: String, declKind: NominalTypeDeclKind, funcsWithArgsHistory: [String]?, customModifiers: [String : Modifier]?, processed: Bool) -> Model {
        let isStatic = self.modifiers.isStatic

        let params = self.signature.parameterClause.parameters.enumerated().compactMap {
            $1.model(inInit: false, declKind: declKind, index: $0)
        }
        let genericTypeParams = self.genericParameterClause?.parameters.compactMap { $0.model(inInit: false) } ?? []
        let genericWhereClause = self.genericWhereClause?.description

        let funcmodel = MethodModel(name: self.name.description,
                                    returnType: (self.signature.returnClause?.type).map { SwiftType(typeSyntax: $0) },
                                    kind: .funcKind,
                                    acl: acl,
                                    genericTypeParams: genericTypeParams,
                                    genericWhereClause: genericWhereClause,
                                    params: params,
                                    isAsync: self.signature.effectSpecifiers?.asyncSpecifier != nil,
                                    throwing: .init(self.signature.effectSpecifiers?.throwsClause),
                                    isStatic: isStatic,
                                    offset: self.offset,
                                    length: self.length,
                                    funcsWithArgsHistory: funcsWithArgsHistory ?? [],
                                    customModifiers: customModifiers ?? [:],
                                    modelDescription: self.description,
                                    processed: processed)
        return funcmodel
    }
}

extension InitializerDeclSyntax {
    func isRequired(with declKind: NominalTypeDeclKind) -> Bool {
        switch declKind {
        case .class:
            if modifiers.isConvenience {
                return false
            }
            return modifiers.isRequired
        case .protocol:
            return true
        default:
            return false // Other types do not support inheritance
        }
    }

    func model(with acl: String, declKind: NominalTypeDeclKind, processed: Bool) -> Model {
        let requiredInit = isRequired(with: declKind)

        let params = self.signature.parameterClause.parameters.enumerated().compactMap {
            $1.model(inInit: true, declKind: declKind, index: $0)
        }
        let genericTypeParams = self.genericParameterClause?.parameters.compactMap { $0.model(inInit: true) } ?? []
        let genericWhereClause = self.genericWhereClause?.description

        return MethodModel(name: "init",
                           returnType: nil,
                           kind: .initKind(required: requiredInit, override: declKind == .class),
                           acl: acl,
                           genericTypeParams: genericTypeParams,
                           genericWhereClause: genericWhereClause,
                           params: params,
                           isAsync: self.signature.effectSpecifiers?.asyncSpecifier != nil,
                           throwing: .init(self.signature.effectSpecifiers?.throwsClause),
                           isStatic: false,
                           offset: self.offset,
                           length: self.length,
                           funcsWithArgsHistory: [],
                           customModifiers: [:],
                           modelDescription: self.description,
                           processed: processed)
    }

}


extension GenericParameterSyntax {
    func model(inInit: Bool) -> ParamModel {
        return ParamModel(label: "",
                          name: self.name.text,
                          // .Void is not correct but this is due to the old implementation. see: https://github.com/uber/mockolo/blob/8c628aaa552bea925e67002dfa48e5338e2d3b26/Sources/MockoloFramework/Templates/ParamTemplate.swift#L30
                          type: self.inheritedType.map { SwiftType(typeSyntax: $0) } ?? .Void,
                          isGeneric: true,
                          inInit: inInit,
                          needsVarDecl: false,
                          offset: self.offset,
                          length: self.length)
    }
}

extension FunctionParameterSyntax {
    func model(inInit: Bool, declKind: NominalTypeDeclKind, index: Int) -> ParamModel {
        let label: String
        let name: String
        // Get label and name of args
        let first = self.firstName.text
        if let second = self.secondName?.text {
            label = first
            if second == "_" {
                name = "_\(index)"
            } else {
                name = second
            }
        } else {
            if first == "_" {
                label = first
                name = "_\(index)"
            } else {
                label = ""
                name = first
            }
        }

        var type = SwiftType(typeSyntax: self.type)
        type.hasEllipsis = ellipsis != nil

        return ParamModel(label: label,
                          name: name,
                          type: type,
                          isGeneric: false,
                          inInit: inInit,
                          needsVarDecl: declKind == .protocol,
                          offset: self.offset,
                          length: self.length)
    }

}

extension AssociatedTypeDeclSyntax {
    func model(with acl: String, declKind: NominalTypeDeclKind, overrides: [String: String]?) -> Model {
        if let overrideType = overrides?[self.name.text] {
            return TypeAliasModel(
                name: self.name.text,
                type: .init(kind: .nominal(.init(name: overrideType))),
                acl: acl,
                offset: self.offset,
                length: self.length,
                modelDescription: nil,
                processed: false
            )
        }

        return AssociatedTypeModel(name: self.name.text,
                                   inheritances: self.inheritanceClause?.inheritedTypes.map { $0.with(\.trailingComma, nil).trimmedDescription } ?? [],
                                   defaultType: (self.initializer?.value).map { SwiftType(typeSyntax: $0) },
                                   whereConstraints: self.genericWhereClause?.requirements.map { $0.with(\.trailingComma, nil).trimmedDescription } ?? [],
                                   acl: acl,
                                   offset: self.offset,
                                   length: self.length)
    }
}

extension TypeAliasDeclSyntax {
    func model(with acl: String, declKind: NominalTypeDeclKind, overrides: [String: String]?, processed: Bool) -> Model {
        let type = overrides?[self.name.text].map {
            SwiftType(kind: .nominal(.init(name: $0)))
        } ?? SwiftType(typeSyntax: self.initializer.value)

        return TypeAliasModel(name: self.name.text,
                              type: type,
                              acl: acl,
                              offset: self.offset,
                              length: self.length,
                              modelDescription: self.description,
                              useDescription: true,
                              processed: processed)
    }
}

final class EntityVisitor: SyntaxVisitor {
    var entities: [Entity] = []
    var imports: [ImportContent] = []
    let annotation: String
    let fileMacro: String
    let path: String
    let declType: FindTargetDeclType
    init(_ path: String, annotation: String = "", fileMacro: String?, declType: FindTargetDeclType) {
        self.annotation = annotation
        self.fileMacro = fileMacro ?? ""
        self.path = path
        self.declType = declType
        super.init(viewMode: .sourceAccurate)
    }

    override func visit(_ node: ProtocolDeclSyntax) -> SyntaxVisitorContinueKind {
        let metadata = node.annotationMetadata(with: annotation)
        if let ent = Entity.node(with: node, filepath: path, isPrivate: node.isPrivate, isFinal: false, metadata: metadata, processed: false) {
            entities.append(ent)
        }
        return .skipChildren
    }

    override func visit(_ node: StructDeclSyntax) -> SyntaxVisitorContinueKind {
        return node.genericParameterClause != nil ? .skipChildren : .visitChildren
    }

    override func visit(_ node: EnumDeclSyntax) -> SyntaxVisitorContinueKind {
        return node.genericParameterClause != nil ? .skipChildren : .visitChildren
    }

    override func visit(_ node: ClassDeclSyntax) -> SyntaxVisitorContinueKind {
        if node.nameText.hasSuffix("Mock") {
            // this mock class node must be public else wouldn't have compiled before
            if let ent = Entity.node(with: node, filepath: path, isPrivate: node.isPrivate, isFinal: false, metadata: nil, processed: true) {
                entities.append(ent)
            }
        } else {
            if declType == .classType || declType == .all {
                let metadata = node.annotationMetadata(with: annotation)
                if let ent = Entity.node(with: node, filepath: path, isPrivate: node.isPrivate, isFinal: node.isFinal, metadata: metadata, processed: false) {
                    entities.append(ent)
                }
            }
        }
        return node.genericParameterClause != nil ? .skipChildren : .visitChildren
    }

    override func visit(_ node: ActorDeclSyntax) -> SyntaxVisitorContinueKind {
        return node.genericParameterClause != nil ? .skipChildren : .visitChildren
    }

    override func visit(_ node: ImportDeclSyntax) -> SyntaxVisitorContinueKind {
        // Top-level import (not inside #if)
        if let `import` = Import(line: node.trimmedDescription) {
            imports.append(.simple(`import`))
        }
        return .skipChildren
    }

    override func visit(_ node: IfConfigDeclSyntax) -> SyntaxVisitorContinueKind {
        // Check if this is a file macro that should be ignored
        if let firstCondition = node.clauses.first?.condition?.trimmedDescription,
           firstCondition == fileMacro {
            return .visitChildren
        }

        // Parse conditional import block recursively
        let block = parseIfConfigDecl(node)
        imports.append(.conditional(block))
        return .skipChildren
    }

    /// Recursively parses an IfConfigDeclSyntax into a ConditionalImportBlock
    private func parseIfConfigDecl(_ node: IfConfigDeclSyntax) -> ConditionalImportBlock {
        var clauseList = [ConditionalImportBlock.Clause]()

        for cl in node.clauses {
            guard let clauseType = ClauseType(cl) else {
                continue
            }

            var contents = [ImportContent]()
            if let list = cl.elements?.as(CodeBlockItemListSyntax.self) {
                for el in list {
                    if let importItem = el.item.as(ImportDeclSyntax.self) {
                        // Simple import
                        if let imp = Import(line: importItem.trimmedDescription) {
                            contents.append(.simple(imp))
                        }
                    } else if let nested = el.item.as(IfConfigDeclSyntax.self) {
                        // Nested #if block (recursive)
                        let nestedBlock = parseIfConfigDecl(nested)
                        contents.append(.conditional(nestedBlock))
                    }
                }
            }

            clauseList.append(ConditionalImportBlock.Clause(
                type: clauseType,
                contents: contents
            ))
        }

        return ConditionalImportBlock(clauses: clauseList, offset: node.offset)
    }

    override func visit(_ node: InitializerDeclSyntax) -> SyntaxVisitorContinueKind {
        return .skipChildren
    }
    
    override func visit(_ node: FunctionDeclSyntax) -> SyntaxVisitorContinueKind {
        return .skipChildren
    }

    override func visit(_ node: VariableDeclSyntax) -> SyntaxVisitorContinueKind {
        return .skipChildren
    }
}

extension Trivia {
    // This parses arguments in annotation which can be used to override certain types.
    //
    // E.g. given /// @mockable(typealias: T = Any; U = AnyObject), it returns
    // a dictionary: [T: Any, U: AnyObject] which will be used to override inhertied types
    // of typealias decls for T and U.
    private func metadata(with annotation: String, in val: String) -> AnnotationMetadata? {
        guard val.contains(annotation) else {
            return nil
        }

        let comps = val.components(separatedBy: annotation)
        var ret = AnnotationMetadata()

        guard var argsStr = comps.last, !argsStr.isEmpty else {
            return ret
        }

        if argsStr.hasPrefix("(") {
            argsStr.removeFirst()
        }
        if argsStr.hasSuffix(")") {
            argsStr.removeLast()
        }
        if let arguments = parseArguments(argsStr, identifier: .typealiasColon) {
            ret.typeAliases = arguments
        }
        if let arguments = parseArguments(argsStr, identifier: .moduleColon) {

            ret.module = arguments[.prefix]
        }
        if let arguments = parseArguments(argsStr, identifier: .overrideColon) {

            ret.nameOverride = arguments[.name]
        }
        if let arguments = parseArguments(argsStr, identifier: .rxColon) {

            ret.varTypes = arguments
        }
        if let arguments = parseArguments(argsStr, identifier: .varColon) {

            if ret.varTypes == nil {
                ret.varTypes = arguments
            } else {
                ret.varTypes?.merge(arguments, uniquingKeysWith: {$1})
            }
        }
        if let arguments = parseArguments(argsStr, identifier: .historyColon) {

            ret.funcsWithArgsHistory = arguments.compactMap { k, v in v == "true" ? k : nil }
        }
        if let arguments = parseArguments(argsStr, identifier: .combineColon) {

            ret.combineTypes = ret.combineTypes ?? [String: CombineType]()

            let currentValueSubjectStr = CombineType.currentValueSubject.typeName.lowercased()
            for pair in arguments {
                if pair.value.hasPrefix("@") {
                    let parts = pair.value.split(separator: " ")
                    if parts.count == 2 {
                        ret.combineTypes?[pair.key] = .property(wrapper: String(parts[0]), name: String(parts[1]))
                        continue
                    }
                }

                if pair.value.lowercased() == currentValueSubjectStr {
                    ret.combineTypes?[pair.key] = .currentValueSubject
                } else {
                    ret.combineTypes?[pair.key] = .passthroughSubject
                }
            }
        }
        if let arguments = parseArguments(argsStr, identifier: .modifiersColon) {

            var modifiers: [String: Modifier] = [:]
            for tuple in arguments {
                guard let modifier: Modifier = Modifier(rawValue: tuple.value) else {
                    continue
                }
                modifiers[tuple.key] = modifier
            }
            ret.modifiers = modifiers
        }
        return ret
    }

    private func parseArguments(_ argsStr: String, identifier: String) -> [String: String]? {
        guard
            argsStr.contains(identifier),
            let subStr = argsStr.components(separatedBy: identifier).last,
            !subStr.isEmpty
        else {
            return nil
        }

        return subStr.arguments(with: .annotationArgDelimiter)
    }

    // Looks up an annotation (e.g. /// @mockable) and its arguments if any.
    // See metadata(with:, in:) for more info on the annotation arguments.
    func annotationMetadata(with annotation: String) -> AnnotationMetadata? {
        guard !annotation.isEmpty else { return nil }

        var ret: AnnotationMetadata?
        for trivia in self {
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

extension ThrowingKind {
    init(_ syntax: ThrowsClauseSyntax?) {
        guard let syntax else {
            self = .none
            return
        }
        if syntax.throwsSpecifier.tokenKind == .keyword(.rethrows) {
            self = .rethrows
        } else {
            if let type = syntax.type {
                self = .typed(errorType: type.trimmedDescription)
            } else {
                self = .any
            }
        }
    }
}

extension ClauseType {
    init?(_ syntax: IfConfigClauseSyntax) {
        switch syntax.poundKeyword.tokenKind {
        case .poundIf:
            self = .if(syntax.condition?.trimmedDescription ?? "")
        case .poundElseif:
            self = .elseif(syntax.condition?.trimmedDescription ?? "")
        case .poundElse:
            self = .else
        default:
            return nil
        }
    }
}
