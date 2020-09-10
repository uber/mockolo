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

extension ClassModel {
    func applyClassTemplate(name: String,
                            identifier: String,
                            accessLevel: String,
                            attribute: String,
                            declType: DeclType,
                            metadata: AnnotationMetadata?,
                            useTemplateFunc: Bool,
                            useMockObservable: Bool,
                            mockFinal: Bool,
                            enableFuncArgsHistory: Bool,
                            initParamCandidates: [Model],
                            declaredInits: [MethodModel],
                            entities: [(String, Model)]) -> String {
        
        let acl = accessLevel.isEmpty ? "" : accessLevel + " "
        let typealiases = typealiasWhitelist(in: entities)
        let renderedEntities = entities
            .compactMap { (uniqueId: String, model: Model) -> (String, Int64)? in
                if model.modelType == .typeAlias, let _ = typealiases?[model.name] {
                    // this case will be handlded by typealiasWhitelist look up later
                    return nil
                }
                if model.modelType == .variable, model.name == String.hasBlankInit {
                    return nil
                }
                if model.modelType == .method, model.isInitializer, !model.processed {
                    return nil
                }
                if let ret = model.render(with: uniqueId, encloser: name, useTemplateFunc: useTemplateFunc, useMockObservable: useMockObservable, mockFinal: mockFinal, enableFuncArgsHistory: enableFuncArgsHistory) {
                    return (ret, model.offset)
                }
                return nil
        }
        .sorted { (left: (String, Int64), right: (String, Int64)) -> Bool in
            if left.1 == right.1 {
                return left.0 < right.0
            }
            return left.1 < right.1
        }
        .map {$0.0}
        .joined(separator: "\n")
        
        var typealiasTemplate = ""
        let addAcl = declType == .protocolType ? acl : ""
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
        
        let extraInits = extraInitsIfNeeded(initParamCandidates: initParamCandidates, declaredInits: declaredInits,  acl: acl, declType: declType, overrides: metadata?.varTypes)

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

        let finalStr = mockFinal ? "\(String.final) " : ""
        let template = """
        \(attribute)
        \(acl)\(finalStr)class \(name): \(moduleDot)\(identifier) {
        \(body)
        }
        """
        
        return template
    }
    
    private func extraInitsIfNeeded(initParamCandidates: [Model],
                                    declaredInits: [MethodModel],
                                    acl: String,
                                    declType: DeclType,
                                    overrides: [String: String]?) -> String {
        
        let declaredInitParamsPerInit = declaredInits.map { $0.params }
        
        var needParamedInit = false
        var needBlankInit = false
        
        if declaredInits.isEmpty, initParamCandidates.isEmpty {
            needBlankInit = true
            needParamedInit = false
        } else {
            if declType == .protocolType {
                needParamedInit = !initParamCandidates.isEmpty
                needBlankInit = true

                let buffer = initParamCandidates.sorted(path: \.fullName, fallback: \.name)
                for paramList in declaredInitParamsPerInit {
                    if paramList.isEmpty {
                        needBlankInit = false
                    } else {
                        let list = paramList.sorted(path: \.fullName, fallback: \.name)
                        if list.count > 0, list.count == buffer.count {
                            let dups = zip(list, buffer).filter {$0.0.fullName == $0.1.fullName}
                            if !dups.isEmpty {
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
                .map { (element: Model) -> String in
                    if let val =  element.type.defaultVal(with: overrides, overrideKey: element.name, isInitParam: true) {
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

            
            paramsAssign = initParamCandidates.map { p in
                return "\(2.tab)self.\(p.underlyingName) = \(p.name.safeName)"
                
            }.joined(separator: "\n")
            
            initTemplate = """
            \(1.tab)\(acl)init(\(params)) {
            \(paramsAssign)
            \(1.tab)}
            """
        }
        
        let extraInitParamNames = initParamCandidates.map{$0.name}
        let extraVarsToDecl = declaredInitParamsPerInit.flatMap{$0}.compactMap { (p: ParamModel) -> String? in
            if !extraInitParamNames.contains(p.name) {
                return p.asVarDecl
            }
            return nil
        }
        .joined(separator: "\n")

        let declaredInitStr = declaredInits.compactMap { (m: MethodModel) -> String? in
            if case let .initKind(required, override) = m.kind, !m.processed {
                let modifier = required ? "\(String.required) " : (override ? "\(String.override) " : "")
                let mAcl = m.accessLevel.isEmpty ? "" : "\(m.accessLevel) "
                let genericTypeDeclsStr = m.genericTypeParams.compactMap {$0.render(with: "", encloser: "")}.joined(separator: ", ")
                let genericTypesStr = genericTypeDeclsStr.isEmpty ? "" : "<\(genericTypeDeclsStr)>"
                let paramDeclsStr = m.params.compactMap{$0.render(with: "", encloser: "")}.joined(separator: ", ")

                if override {
                    let paramsList = m.params.map { param in
                        return "\(param.name): \(param.name.safeName)"
                    }.joined(separator: ", ")

                    return """
                    \(1.tab)\(modifier)\(mAcl)init\(genericTypesStr)(\(paramDeclsStr)) {
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
                    \(1.tab)\(modifier)\(mAcl)init\(genericTypesStr)(\(paramDeclsStr)) {
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
        let typealiasModels = models.filter{$0.1.modelType == .typeAlias}
        var aliasMap = [String: [String]]()
        typealiasModels.forEach { (arg: (key: String, value: Model)) in
            
            let alias = arg.value
            if aliasMap[alias.name] == nil {
                aliasMap[alias.name] = [alias.type.typeName]
            } else {
                if let val = aliasMap[alias.name], !val.contains(alias.type.typeName) {
                    aliasMap[alias.name]?.append(alias.type.typeName)
                }
            }
        }
        let aliasDupes = aliasMap.filter {$0.value.count > 1}
        return aliasDupes.isEmpty ? nil : aliasDupes
    }
}
