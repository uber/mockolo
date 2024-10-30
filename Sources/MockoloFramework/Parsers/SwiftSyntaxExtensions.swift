//
//  SwiftSyntaxExtensions.swift
//  MockoloFramework
//
//  Created by Ellie Shin on 10/29/19.
//

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


extension AttributeListSyntax {
    var trimmedDescription: String? {
        return self.trimmed.description.trimmingCharacters(in: .whitespacesAndNewlines)
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
        return self.tokens(viewMode: .sourceAccurate).filter {$0.tokenKind == .keyword(.static) }.count > 0
    }

    var isRequired: Bool {
        return self.tokens(viewMode: .sourceAccurate).filter {$0.text == String.required }.count > 0
    }

    var isConvenience: Bool {
        return self.tokens(viewMode: .sourceAccurate).filter {$0.text == String.convenience }.count > 0
    }

    var isOverride: Bool {
        return self.tokens(viewMode: .sourceAccurate).filter {$0.text == String.override }.count > 0
    }

    var isFinal: Bool {
        return self.tokens(viewMode: .sourceAccurate).filter {$0.text == String.final }.count > 0
    }

    var isPrivate: Bool {
        return self.tokens(viewMode: .sourceAccurate).filter {$0.tokenKind == .keyword(.private) || $0.tokenKind == .keyword(.fileprivate) }.count > 0
    }

    var isPublic: Bool {
        return self.tokens(viewMode: .sourceAccurate).filter {$0.tokenKind == .keyword(.public) }.count > 0
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

    var typesDescription: String {
        return self.inheritedTypes.description
    }
}

extension MemberBlockItemSyntax {
    private func validateMember(_ modifiers: DeclModifierListSyntax?, _ declType: DeclType, processed: Bool) -> Bool {
        if let mods = modifiers {
            if !processed && mods.isPrivate || mods.isStatic && declType == .classType {
                return false
            }
        }
        return true
    }

    private func validateInit(_ initDecl: InitializerDeclSyntax, _ declType: DeclType, processed: Bool) -> Bool {
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

    private func memberAcl(_ modifiers: DeclModifierListSyntax?, _ encloserAcl: String, _ declType: DeclType) -> String {
        if declType == .protocolType {
            return encloserAcl
        }
        return modifiers?.acl ?? ""
    }

    func transformToModel(with encloserAcl: String, declType: DeclType, metadata: AnnotationMetadata?, processed: Bool) -> (Model, String?, Bool)? {
        if let varMember = self.decl.as(VariableDeclSyntax.self) {
            if validateMember(varMember.modifiers, declType, processed: processed) {
                let acl = memberAcl(varMember.modifiers, encloserAcl, declType)
                if let item = varMember.models(with: acl, declType: declType, metadata: metadata, processed: processed).first {
                    return (item, varMember.attributes.trimmedDescription, false)
                }
            }
        } else if let funcMember = self.decl.as(FunctionDeclSyntax.self) {
            if validateMember(funcMember.modifiers, declType, processed: processed) {
                let acl = memberAcl(funcMember.modifiers, encloserAcl, declType)
                let item = funcMember.model(with: acl, declType: declType, funcsWithArgsHistory: metadata?.funcsWithArgsHistory, customModifiers: metadata?.modifiers, processed: processed)
                return (item, funcMember.attributes.trimmedDescription, false)
            }
        } else if let subscriptMember = self.decl.as(SubscriptDeclSyntax.self) {
            if validateMember(subscriptMember.modifiers, declType, processed: processed) {
                let acl = memberAcl(subscriptMember.modifiers, encloserAcl, declType)
                let item = subscriptMember.model(with: acl, declType: declType, processed: processed)
                return (item, subscriptMember.attributes.trimmedDescription, false)
            }
        } else if let initMember = self.decl.as(InitializerDeclSyntax.self) {
            if validateInit(initMember, declType, processed: processed) {
                let acl = memberAcl(initMember.modifiers, encloserAcl, declType)
                let item = initMember.model(with: acl, declType: declType, processed: processed)
                return (item, initMember.attributes.trimmedDescription, true)
            }
        } else if let patMember = self.decl.as(AssociatedTypeDeclSyntax.self) {
            let acl = memberAcl(patMember.modifiers, encloserAcl, declType)
            let item = patMember.model(with: acl, declType: declType, overrides: metadata?.typeAliases, processed: processed)
            return (item, patMember.attributes.trimmedDescription, false)
        } else if let taMember = self.decl.as(TypeAliasDeclSyntax.self) {
            let acl = memberAcl(taMember.modifiers, encloserAcl, declType)
            let item = taMember.model(with: acl, declType: declType, overrides: metadata?.typeAliases, processed: processed)
            return (item, taMember.attributes.trimmedDescription, false)
        } else if let ifMacroMember = self.decl.as(IfConfigDeclSyntax.self) {
            let (item, attr, initFlag) = ifMacroMember.model(with: encloserAcl, declType: declType, metadata: metadata, processed: processed)
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

    func memberData(with encloserAcl: String, declType: DeclType, metadata: AnnotationMetadata?, processed: Bool) -> EntityNodeSubContainer {
        var attributeList = [String]()
        var memberList = [Model]()
        var hasInit = false

        for m in self {
            if let (item, attr, initFlag) = m.transformToModel(with: encloserAcl, declType: declType, metadata: metadata, processed: processed) {
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
    func model(with encloserAcl: String, declType: DeclType, metadata: AnnotationMetadata?, processed: Bool) -> (Model, String?, Bool) {
        var subModels = [Model]()
        var attrDesc: String?
        var hasInit = false

        var name = ""
        for cl in self.clauses {
            if let desc = cl.condition?.description {
                if let list = cl.elements?.as(MemberBlockItemListSyntax.self) {
                    name = desc
                    for element in list {
                        if let (item, attr, initFlag) = element.transformToModel(with: encloserAcl, declType: declType, metadata: metadata, processed: processed) {
                            subModels.append(item)
                            if let attr = attr, attr.contains(String.available) {
                                attrDesc = attr
                            }
                            hasInit = hasInit || initFlag
                        }
                    }
                }
            }
        }

        let macroModel = IfMacroModel(name: name, offset: self.offset, entities: subModels)
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

    var accessLevel: String {
        return self.modifiers.acl 
    }

    var declType: DeclType {
        return .protocolType
    }

    var isPrivate: Bool {
        return self.modifiers.isPrivate 
    }

    var inheritedTypes: [String] {
        return inheritanceClause?.types ?? []
    }

    var attributesDescription: String {
        self.attributes.trimmedDescription ?? ""
    }

    var offset: Int64 {
        return Int64(self.position.utf8Offset)
    }

    func annotationMetadata(with annotation: String) -> AnnotationMetadata? {
        return leadingTrivia.annotationMetadata(with: annotation)
    }

    var hasBlankInit: Bool {
        return false
    }

    func subContainer(metadata: AnnotationMetadata?, declType: DeclType, path: String?, isProcessed: Bool) -> EntityNodeSubContainer {
        return self.memberBlock.members.memberData(with: accessLevel, declType: declType, metadata: metadata, processed: isProcessed)
    }
}

extension ClassDeclSyntax: EntityNode {
    var namespaces: [String] {
        return findNamespaces(parent: parent)
    }

    var nameText: String {
        return name.text
    }

    var accessLevel: String {
        return self.modifiers.acl 
    }

    var declType: DeclType {
        return .classType
    }

    var inheritedTypes: [String] {
        return inheritanceClause?.types ?? []
    }

    var attributesDescription: String {
        self.attributes.trimmedDescription ?? ""
    }

    var offset: Int64 {
        return Int64(self.position.utf8Offset)
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
        return leadingTrivia.annotationMetadata(with: annotation)
    }

    func subContainer(metadata: AnnotationMetadata?, declType: DeclType, path: String?, isProcessed: Bool) -> EntityNodeSubContainer {
        return self.memberBlock.members.memberData(with: accessLevel, declType: declType, metadata: nil, processed: isProcessed)
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

extension VariableDeclSyntax {
    func models(with acl: String, declType: DeclType, metadata: AnnotationMetadata?, processed: Bool) -> [Model] {
        // Detect whether it's static
        let isStatic = self.modifiers.isStatic

        // Need to access pattern bindings to get name, type, and other info of a var decl
        let varmodels = self.bindings.compactMap { (v: PatternBindingSyntax) -> Model in
            let name = v.pattern.firstToken(viewMode: .sourceAccurate)?.text ?? String.unknownVal
            var typeName = ""
            var potentialInitParam = false

            // Get the type info and whether it can be a var param for an initializer
            if let vtype = v.typeAnnotation?.type.description.trimmingCharacters(in: .whitespaces) {
                potentialInitParam = name.canBeInitParam(type: vtype, isStatic: isStatic)
                typeName = vtype
            }

            let storageType: VariableModel.MockStorageType
            switch v.accessorBlock?.accessors {
            case .accessors(let accessorDecls):
                if accessorDecls.contains(where: { $0.accessorSpecifier.tokenKind == .keyword(.set) }) {
                    storageType = .stored(needsSetCount: true)
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
                            storageType = .stored(needsSetCount: false)
                        } else {
                            storageType = .computed(getterEffects)
                        }
                    } else { // is class
                        storageType = .computed(.empty)
                    }
                } else {
                    // will never happens
                    storageType = .stored(needsSetCount: false) // fallback
                }
            case .getter:
                storageType = .computed(.empty)
            case nil:
                storageType = .stored(needsSetCount: true)
            }

            let varmodel = VariableModel(name: name,
                                         typeName: typeName,
                                         acl: acl,
                                         encloserType: declType,
                                         isStatic: isStatic,
                                         storageType: storageType,
                                         canBeInitParam: potentialInitParam,
                                         offset: v.offset,
                                         rxTypes: metadata?.varTypes,
                                         customModifiers: metadata?.modifiers,
                                         modelDescription: self.description,
                                         combineType: metadata?.combineTypes?[name] ?? metadata?.combineTypes?["all"],
                                         processed: processed)
            return varmodel
        }
        return varmodels
    }
}

extension SubscriptDeclSyntax {
    func model(with acl: String, declType: DeclType, processed: Bool) -> Model {
        let isStatic = self.modifiers.isStatic

        let params = self.parameterClause.parameters.compactMap { $0.model(inInit: false, declType: declType) }
        let genericTypeParams = self.genericParameterClause?.parameters.compactMap { $0.model(inInit: false) } ?? []
        let genericWhereClause = self.genericWhereClause?.description

        let subscriptModel = MethodModel(name: self.subscriptKeyword.text,
                                         typeName: self.returnClause.type.description,
                                         kind: .subscriptKind,
                                         encloserType: declType,
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

    func model(with acl: String, declType: DeclType, funcsWithArgsHistory: [String]?, customModifiers: [String : Modifier]?, processed: Bool) -> Model {
        let isStatic = self.modifiers.isStatic

        let params = self.signature.parameterClause.parameters.compactMap { $0.model(inInit: false, declType: declType) }
        let genericTypeParams = self.genericParameterClause?.parameters.compactMap { $0.model(inInit: false) } ?? []
        let genericWhereClause = self.genericWhereClause?.description

        let funcmodel = MethodModel(name: self.name.description,
                                    typeName: self.signature.returnClause?.type.description ?? "",
                                    kind: .funcKind,
                                    encloserType: declType,
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
    func isRequired(with declType: DeclType) -> Bool {
        if declType == .protocolType {
            return true
        } else if declType == .classType {
            if modifiers.isConvenience {
                return false
            }
            return modifiers.isRequired
        }
        return false
    }

    func model(with acl: String, declType: DeclType, processed: Bool) -> Model {
        let requiredInit = isRequired(with: declType)

        let params = self.signature.parameterClause.parameters.compactMap { $0.model(inInit: true, declType: declType) }
        let genericTypeParams = self.genericParameterClause?.parameters.compactMap { $0.model(inInit: true) } ?? []
        let genericWhereClause = self.genericWhereClause?.description

        return MethodModel(name: "init",
                           typeName: "",
                           kind: .initKind(required: requiredInit, override: declType == .classType),
                           encloserType: declType,
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
        let first = self.firstName.text
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

        // Variadic args are not detected in the parser so need to manually look up
        var type = self.type.description 
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

extension AssociatedTypeDeclSyntax {
    func model(with acl: String, declType: DeclType, overrides: [String: String]?, processed: Bool) -> Model {
        // Get the inhertied type for an associated type if any
        var t = self.inheritanceClause?.typesDescription ?? ""
        t.append(self.genericWhereClause?.description ?? "")

        return TypeAliasModel(name: self.name.text,
                              typeName: t,
                              acl: acl,
                              encloserType: declType,
                              overrideTypes: overrides,
                              offset: self.offset,
                              length: self.length,
                              modelDescription: self.description,
                              processed: processed)
    }
}

extension TypeAliasDeclSyntax {
    func model(with acl: String, declType: DeclType, overrides: [String: String]?, processed: Bool) -> Model {
        return TypeAliasModel(name: self.name.text,
                              typeName: self.initializer.value.description,
                              acl: acl,
                              encloserType: declType,
                              overrideTypes: overrides,
                              offset: self.offset,
                              length: self.length,
                              modelDescription: self.description,
                              useDescription: true,
                              processed: processed)
    }
}

final class EntityVisitor: SyntaxVisitor {
    var entities: [Entity] = []
    var imports: [String: [String]] = [:]
    let annotation: String
    let fileMacro: String
    let path: String
    let declType: DeclType
    init(_ path: String, annotation: String = "", fileMacro: String?, declType: DeclType) {
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
        if let ret = node.path.firstToken(viewMode: .sourceAccurate)?.text {
            let desc = node.importKeyword.text + " " + ret
            imports["", default: []].append(desc)
        }
        return .skipChildren
    }

    override func visit(_ node: IfConfigDeclSyntax) -> SyntaxVisitorContinueKind {
        for cl in node.clauses {
            let macroName: String
            if let conditionDescription = cl.condition?.trimmedDescription {
                macroName = conditionDescription
            } else {
                return .visitChildren
            }

            guard macroName != fileMacro else { return .visitChildren }

            if let list = cl.elements?.as(CodeBlockItemListSyntax.self) {
                for el in list {
                    if let importItem = el.item.as(ImportDeclSyntax.self) {
                        let key = macroName
                        if imports[key] == nil {
                            imports[key] = []
                        }
                        imports[key]?.append(importItem.trimmedDescription)

                    } else if let nested = el.item.as(IfConfigDeclSyntax.self) {
                        let key = macroName
                        if imports[key] == nil {
                            imports[key] = []
                        }
                        imports[key]?.append(nested.trimmedDescription)
                    } else {
                        return .visitChildren
                    }
                }
            }
        }
        return .skipChildren
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

extension ThrowingKind {
    fileprivate init(_ syntax: ThrowsClauseSyntax?) {
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
