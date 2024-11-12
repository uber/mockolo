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

import Foundation

extension NominalModel {
    func applyNominalTemplate(name: String,
                              identifier: String,
                              accessLevel: String,
                              attribute: String,
                              inheritedTypes: [String],
                              metadata: AnnotationMetadata?,
                              arguments: GenerationArguments,
                              initParamCandidates: [VariableModel],
                              declaredInits: [MethodModel],
                              entities: [(String, Model)]) -> String {

        processCombineAliases(entities: entities)
        
        let acl = accessLevel.isEmpty ? "" : accessLevel + " "
        let typealiases = typealiasWhitelist(in: entities)
        let renderedEntities = entities
            .compactMap { (uniqueId: String, model: Model) -> String? in
                if model.modelType == .typeAlias, let _ = typealiases?[model.name] {
                    // this case will be handlded by typealiasWhitelist look up later
                    return nil
                }
                if model.modelType == .variable, model.name == String.hasBlankInit {
                    return nil
                }
                if model.modelType == .method, let model = model as? MethodModel, model.isInitializer, !model.processed {
                    return nil
                }
                if let ret = model.render(
                    context: .init(
                        overloadingResolvedName: uniqueId,
                        enclosingType: type,
                        annotatedTypeKind: declKindOfMockAnnotatedBaseType
                    ),
                    arguments: arguments
                ) {
                    return ret
                }
                return nil
            }
            .joined(separator: "\n")
        
        var typealiasTemplate = ""
        let addAcl = declKindOfMockAnnotatedBaseType == .protocol ? acl : ""
        if let typealiasWhitelist = typealiases {
            typealiasTemplate = typealiasWhitelist.map { (arg: (key: String, value: [String])) -> String in
                let joinedType = arg.value.sorted().joined(separator: " & ")
                return  "\(1.tab)\(addAcl)\(String.typealias) \(arg.key) = \(joinedType)"
            }.joined(separator: "\n")
        }
        
        var moduleDot = ""
        if let moduleName = metadata?.module, !moduleName.isEmpty {
            moduleDot = moduleName + "."
        }
        
        let extraInits = extraInitsIfNeeded(initParamCandidates: initParamCandidates, declaredInits: declaredInits, acl: acl, declKindOfMockAnnotatedBaseType: declKindOfMockAnnotatedBaseType, overrides: metadata?.varTypes)

        var inheritedTypes = inheritedTypes
        inheritedTypes.insert("\(moduleDot)\(identifier)", at: 0)

        var body = ""
        if !typealiasTemplate.isEmpty {
            body += "\(typealiasTemplate)\n"
        }
        if !extraInits.isEmpty {
            body += "\(extraInits)\n"
        }
        if !renderedEntities.isEmpty {
            body += "\(renderedEntities)"
        }

        let finalStr = arguments.mockFinal ? "\(String.final) " : ""
        let template = """
        \(attribute)
        \(acl)\(finalStr)\(declKind.rawValue) \(name): \(inheritedTypes.joined(separator: ", ")) {
        \(body)
        }
        """

        if namespaces.isEmpty {
            return template
        } else {
            return """
            extension \(namespaces.joined(separator: ".")) {
            \(template.addingIndent(1))
            }
            """
        }
    }
    
    private func extraInitsIfNeeded(
        initParamCandidates: [VariableModel],
        declaredInits: [MethodModel],
        acl: String,
        declKindOfMockAnnotatedBaseType: NominalTypeDeclKind,
        overrides: [String: String]?
    ) -> String {
        
        let declaredInitParamsPerInit = declaredInits.map { $0.params }

        var needParamedInit = false
        var needBlankInit = false
        
        if declaredInits.isEmpty, initParamCandidates.isEmpty {
            needBlankInit = true
            needParamedInit = false
        } else {
            if declKindOfMockAnnotatedBaseType == .protocol {
                needParamedInit = !initParamCandidates.isEmpty
                needBlankInit = true

                let buffer = initParamCandidates.sorted(path: \.fullName, fallback: \.name)
                for paramList in declaredInitParamsPerInit {
                    if paramList.isEmpty {
                        needBlankInit = false
                    } else {
                        let list = paramList.sorted(path: \.fullName, fallback: \.name)
                        if list.count > 0, list.count == buffer.count {
                            let hasDuplicates = zip(list, buffer).contains(where: { $0.fullName == $1.fullName })
                            if hasDuplicates {
                                needParamedInit = false
                            }
                        }
                    }
                }
            }
        }
        
        var initTemplate = ""
        if needParamedInit {
            var paramsAssign = ""
            let params = initParamCandidates
                .map { (element: VariableModel) -> String in
                    if let val = element.type.defaultVal(with: overrides, overrideKey: element.name, isInitParam: true) {
                        return "\(element.name): \(element.type.typeName) = \(val)"
                    }
                    var prefix = ""
                    if element.type.hasClosure {
                        if !element.type.isOptional {
                            prefix = String.escaping + " "
                        }
                    }
                    return "\(element.name): \(prefix)\(element.type.typeName)"
                }
                .joined(separator: ", ")

            paramsAssign = initParamCandidates.map { (element: VariableModel) in
                switch element.storageKind {
                case .stored:
                    return "\(2.tab)self.\(element.underlyingName) = \(element.name.safeName)"
                case .computed:
                    return "\(2.tab)self.\(element.name)\(String.handlerSuffix) = { \(element.name.safeName) }"
                }
            }.joined(separator: "\n")
            
            initTemplate = """
            \(1.tab)\(acl)init(\(params)) {
            \(paramsAssign)
            \(1.tab)}
            """
        }
        
        let extraInitParamNames = initParamCandidates.map{$0.name}
        let extraVarsToDecl = Dictionary(
            grouping: declaredInitParamsPerInit.flatMap {
                $0.filter { !extraInitParamNames.contains($0.name) }
            },
            by: \.name
        )
            .compactMap { (name: String, params: [ParamModel]) in
                let shouldErase = params.contains { params[0].type.typeName != $0.type.typeName }
                return params[0].asInitVarDecl(eraseType: shouldErase)
            }
            .sorted()
            .joined(separator: "\n")

        let declaredInitStr = declaredInits.compactMap { (m: MethodModel) -> String? in
            if case let .initKind(required, override) = m.kind, !m.processed {
                let modifier = required ? "\(String.required) " : (override ? "\(String.override) " : "")
                let mAcl = m.accessLevel.isEmpty ? "" : "\(m.accessLevel) "
                let genericTypeDeclsStr = m.genericTypeParams.compactMap {$0.render()}.joined(separator: ", ")
                let genericTypesStr = genericTypeDeclsStr.isEmpty ? "" : "<\(genericTypeDeclsStr)>"
                let paramDeclsStr = m.params.compactMap{$0.render()}.joined(separator: ", ")
                let suffixStr = applyFunctionSuffixTemplate(
                    isAsync: m.isAsync,
                    throwing: m.throwing
                )

                if override {
                    let paramsList = m.params.map { param in
                        return "\(param.name): \(param.name.safeName)"
                    }.joined(separator: ", ")

                    return """
                    \(1.tab)\(modifier)\(mAcl)init\(genericTypesStr)(\(paramDeclsStr)) \(suffixStr){
                    \(2.tab)super.init(\(paramsList))
                    \(1.tab)}
                    """
                } else {
                    let paramsAssign = m.params.map { param in
                        let underVars = initParamCandidates.compactMap { return $0.name.safeName == param.name.safeName ? $0.underlyingName : nil}
                        if let underVar = underVars.first {
                            return "\(2.tab)self.\(underVar) = \(param.name.safeName)"
                        } else {
                            return "\(2.tab)self.\(param.underlyingName) = \(param.name.safeName)"
                        }
                    }.joined(separator: "\n")

                    return """
                    \(1.tab)\(modifier)\(mAcl)init\(genericTypesStr)(\(paramDeclsStr)) \(suffixStr){
                    \(paramsAssign)
                    \(1.tab)}
                    """
                }
            }
            return nil
        }.sorted().joined(separator: "\n")

        var template = ""

        if !extraVarsToDecl.isEmpty {
            template += "\(1.tab)\(extraVarsToDecl)\n"
        }

        if needBlankInit {
            // In case of protocol mocking, we want to provide a blank init (if not present already) for convenience,
            // where instance vars do not have to be set in init since they all have get/set (see VariableTemplate).
            let blankInit = "\(acl)init() { }"
            template += "\(1.tab)\(blankInit)\n"
        }

        if !initTemplate.isEmpty {
            template += "\(initTemplate)\n"
        }

        if !declaredInitStr.isEmpty {
            template += "\(declaredInitStr)\n"
        }

        return template
    }
    
    
    /// Returns a map of typealiases with conflicting types to be whitelisted
    /// @param models Potentially contains typealias models
    /// @returns A map of typealiases with multiple possible types
    func typealiasWhitelist(`in` models: [(String, Model)]) -> [String: [String]]? {
        var aliasMap = [String: Set<String>]()
        for (_, model) in models {
            if let alias = model as? TypeAliasModel {
                aliasMap[alias.name, default: []].insert(alias.type.typeName)
            }
        }
        let aliasDupes = aliasMap.filter {$0.value.count > 1}
        return aliasDupes.isEmpty ? nil : aliasDupes.mapValues {$0.sorted()}
    }

    // Finds all combine properties that are attempting to use a property wrapper alias
    // and locates the matching property within the class, if one exists.
    //
    private func processCombineAliases(entities: [(String, Model)]) {
        var variableModels = [VariableModel]()
        var nameToVariableModels = [String: VariableModel]()

        for entity in entities {
            guard let variableModel = entity.1 as? VariableModel else {
                continue
            }
            variableModels.append(variableModel)
            nameToVariableModels[variableModel.name] = variableModel
        }

        for variableModel in variableModels {
            guard case .property(let wrapper, let name) = variableModel.combineType else {
                continue
            }

            // If a variable member in this entity already exists, link the two together.
            // Otherwise, the user's setup is incorrect and we will fallback to using a PassthroughSubject.
            //
            if let matchingAliasModel = nameToVariableModels[name] {
                variableModel.wrapperAliasModel = matchingAliasModel
                matchingAliasModel.propertyWrapper = wrapper
            } else {
                variableModel.combineType = .passthroughSubject
            }
        }
    }
}
