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

extension NominalModel {
    func applyNominalTemplate(name: String,
                              accessLevel: String,
                              attribute: String,
                              arguments: GenerationArguments,
                              initParamCandidates: [VariableModel],
                              declaredInits: [MethodModel],
                              entities: [(String, Model)]) -> String {

        processCombineAliases(entities: entities)
        
        let acl = accessLevel.isEmpty ? "" : accessLevel + " "

        let (aliasItems,
             typeparameters,
             whereClauses,
             renderedModelNames) = processAssociatedTypes(in: entities, acl: acl)
        let renderedEntities = entities
            .compactMap { (uniqueId: String, model: Model) -> String? in
                if model is TypealiasRenderableModel && renderedModelNames.contains(model.name) {
                    // this case will be handlded by typealiasWhitelist look up later
                    return nil
                }
                if model.modelType == .variable, model.name == String.hasBlankInit {
                    return nil
                }
                if model.modelType == .method, let model = model as? MethodModel, model.isInitializer, !model.processed {
                    return nil
                }

                return model.render(
                    context: .init(
                        overloadingResolvedName: uniqueId,
                        enclosingType: type,
                        annotatedTypeKind: declKindOfMockAnnotatedBaseType,
                        mockDeclKind: declKind,
                        requiresSendable: requiresSendable
                    ),
                    arguments: arguments
                )
            }
            .joined(separator: "\n")

        let extraInits = extraInitsIfNeeded(
            initParamCandidates: initParamCandidates,
            declaredInits: declaredInits,
            acl: acl,
            declKindOfMockAnnotatedBaseType: declKindOfMockAnnotatedBaseType,
            context: .init(
                enclosingType: type,
                annotatedTypeKind: declKindOfMockAnnotatedBaseType,
                mockDeclKind: declKind,
                requiresSendable: requiresSendable
            ),
            arguments: arguments
        )

        var body = ""
        if !extraInits.isEmpty {
            body += "\(extraInits)\n"
        }
        if !aliasItems.isEmpty {
            body += "\(aliasItems)\n"
        }
        if !renderedEntities.isEmpty {
            body += "\(renderedEntities)"
        }
        var uncheckedSendableStr = ""
        if requiresSendable {
            uncheckedSendableStr = ", @unchecked Sendable"
        }

        let finalStr = arguments.mockFinal || requiresSendable ? String.final.withSpace : ""
        let template = """
        \(attribute)
        \(acl)\(finalStr)\(declKind.rawValue) \(name)\(typeparameters): \(inheritedTypeName)\(uncheckedSendableStr) \(whereClauses){
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
        context: RenderContext,
        arguments: GenerationArguments
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
                .compactMap { (element: VariableModel) -> String? in
                    if let val = element.type?.defaultVal(with: element.rxTypes, overrideKey: element.name, isInitParam: true) {
                        return "\(element.name): \(element.type!.typeName) = \(val)"
                    }

                    if var elementType = element.type {
                        if !elementType.isEscapable {
                            elementType.attributes.insert(.escaping, at: 0)
                        }
                        return "\(element.name): \(elementType)"
                    } else {
                        return nil
                    }
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
                let genericTypeDeclsStr = m.genericTypeParams.render(context: context, arguments: arguments)
                let genericTypesStr = genericTypeDeclsStr.isEmpty ? "" : "<\(genericTypeDeclsStr)>"
                let paramDeclsStr = m.params.render(context: context, arguments: arguments)
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
            template += "\(extraVarsToDecl)\n"
        }

        if needBlankInit {
            let blankInit: String
            if context.annotatedTypeKind == .class {
                blankInit = "\(acl)override init() { }"
            } else {
                // In case of protocol mocking, we want to provide a blank init (if not present already) for convenience,
                // where instance vars do not have to be set in init since they all have get/set (see VariableTemplate).
                blankInit = "\(acl)init() { }"
            }
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

    func processAssociatedTypes(`in` models: [(String, Model)], acl: String) -> (
        aliasItems: String,
        typeparameters: String,
        whereClauses: String,
        renderedModelNames: Set<String>
    ) {
        let addAcl = declKindOfMockAnnotatedBaseType == .protocol ? acl : ""
        let allWhereConstraints = genericWhereConstraints + models.flatMap { ($1 as? AssociatedTypeModel)?.whereConstraints ?? [] }
        let hasWhereConstraints = !allWhereConstraints.isEmpty

        let aliasModels = [String: [TypealiasRenderableModel]](
            grouping: models.compactMap { $1 as? TypealiasRenderableModel },
            by: \.name
        ).sorted(path: \.key)

        // If there is a where, do not output typealias as it may not satisfy the conditions
        if hasWhereConstraints {
            let aliasItems = aliasModels.compactMap { (name, candidates) in
                if let defaultType = candidates.firstNonNil(\.defaultType) {
                    return """
                    \(1.tab)// Unavailable due to the presence of generic constraints
                    \(1.tab)// \(addAcl)\(String.typealias) \(name) = \(defaultType.displayName)
                    
                    """
                }
                return nil
            }.joined(separator: "\n")
            let typeparameters = aliasModels.map { (name, candidates) in
                mergeAssociatedTypes(
                    name: name,
                    models: candidates.compactMap { $0 as? AssociatedTypeModel }
                )
            }
            return (
                aliasItems: aliasItems,
                typeparameters: typeparameters.isEmpty ? "" : "<\(typeparameters.joined(separator: ", "))>",
                whereClauses: allWhereConstraints.isEmpty ? "" : "where \(allWhereConstraints.joined(separator: ", ")) ",
                renderedModelNames: Set(aliasModels.map(\.key))
            )
        }

        var aliasItems: String = ""
        var typeparameters: [String] = []
        var renderedModelNames: Set<String> = []
        for (name, candidates) in aliasModels {
            // If only one default type exists and the others have no constraints, use it directly.
            let havingDefaults = candidates.filter { $0.defaultType != nil }
            if havingDefaults.count == 1 && !candidates
                .filter({ $0 !== havingDefaults[0] })
                .contains(where: \.hasGenericConstraints) {
                continue
            }

            // If there are no constraints on all candidates, use Any automatically.
            if candidates.allSatisfy({ !$0.hasGenericConstraints }) {
                aliasItems.append("\(1.tab)\(addAcl)\(String.typealias) \(name) = Any\n")
            } else {
                // The other cases, gather all constraints
                let typeparameter = mergeAssociatedTypes(
                    name: name,
                    models: candidates.compactMap { $0 as? AssociatedTypeModel }
                )
                typeparameters.append(typeparameter)
            }

            renderedModelNames.insert(name)
        }

        return (
            aliasItems: aliasItems,
            typeparameters: typeparameters.isEmpty ? "" : "<\(typeparameters.joined(separator: ", "))>",
            whereClauses: allWhereConstraints.isEmpty ? "" : "where \(allWhereConstraints.joined(separator: ", ")) ",
            renderedModelNames: renderedModelNames
        )

        func mergeAssociatedTypes(name: String, models: [AssociatedTypeModel]) -> String {
            let inheritances = models.flatMap(\.inheritances)

            let typeparameter = if inheritances.isEmpty {
                name
            } else {
                "\(name): \(inheritances.joined(separator: " & "))"
            }
            return typeparameter
        }
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
