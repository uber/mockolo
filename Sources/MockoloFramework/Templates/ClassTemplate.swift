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

func applyClassTemplate(name: String,
                        identifier: String,
                        typeKeys: [String: String]?,
                        accessControlLevelDescription: String,
                        attribute: String,
                        declType: DeclType,
                        typealiasWhitelist: [String: [String]]?,
                        entities: [(String, Model)]) -> String {
    
    let extraInits = extraInitsIfNeeded(entities, accessControlLevelDescription: accessControlLevelDescription, declType: declType, typeKeys: typeKeys)
    
    let renderedEntities = entities
        .compactMap { (uniqueId: String, model: Model) -> (String, Int64)? in
            if model.modelType == .typeAlias, let _ = typealiasWhitelist?[model.name] {
                // this case will be handlded by typealiasWhitelist look up later
                return nil
            }
            if model.modelType == .variable, model.name == String.doneInit {
                return nil
            }
            if let ret = model.render(with: uniqueId, typeKeys: typeKeys) {
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
    if let typealiasWhitelist = typealiasWhitelist {
        typealiasTemplate = typealiasWhitelist.map { (arg: (key: String, value: [String])) -> String in
            let joinedType = arg.value.sorted().joined(separator: " & ")
            return  "\(String.typealias) \(arg.key) = \(joinedType)"
        }.joined(separator: "\n")
    }
    
    let template =
    """
    \(attribute)
    \(accessControlLevelDescription)class \(name): \(identifier) {
        \(typealiasTemplate)
        \(extraInits)
        \(renderedEntities)
    }
    """
    
    return template
}


private func extraInitsIfNeeded(_ entities: [(String, Model)],
                              accessControlLevelDescription: String,
                              declType: DeclType,
                              typeKeys: [String: String]?) -> String {
    
    let declaredInits = entities.filter {$0.1.isInitializer}.compactMap{ $0.1 as? MethodModel }
    let declaredInitParamsPerInit = declaredInits.map { $0.params }
    let hasBlankInit = !declaredInits.filter { $0.params.isEmpty }.isEmpty
    
    let extraInitParamCandidates = sortedInitVars(in: entities.map{$0.1})
    let extraInitParamCandidatesSorted = extraInitParamCandidates.sorted(path: \.name)

    var needParamedInit = true
    var needBlankInit = false

    if declaredInits.isEmpty, extraInitParamCandidates.isEmpty {
        needBlankInit = true
        needParamedInit = false
    } else {
        if declType == .protocolType {
            needBlankInit = !hasBlankInit
            needParamedInit = declaredInitParamsPerInit.isEmpty && !extraInitParamCandidates.isEmpty
        } else {
            var matchingParamsFound = false
            for declaredParams in declaredInitParamsPerInit {
                if declaredParams.count == extraInitParamCandidates.count {
                    let declaredParamsByName = declaredParams.sorted(path: \.name)
                    let matchingParams = zip(extraInitParamCandidatesSorted, declaredParamsByName).filter { $0.name == $1.name && $0.type.typeName == $1.type.typeName }
                    if !matchingParams.isEmpty {
                        matchingParamsFound = true
                        break
                    }
                }
            }
            
            if matchingParamsFound || extraInitParamCandidates.isEmpty {
                needParamedInit = false
            }
        }
    }

    var initTemplate = ""
    if needParamedInit {
        var paramsAssign = ""
        let params = extraInitParamCandidates
            .map { (element: Model) -> String in
                if let val =  element.type.defaultVal(with: typeKeys, isInitParam: true), !val.isEmpty {
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
        
        paramsAssign = extraInitParamCandidates.map { p in
            return """
            self.\(p.name) = \(p.name)
            """
        }.joined(separator: "\n")
        
        initTemplate = """
        \(accessControlLevelDescription)init(\(params)) {
            \(paramsAssign)
            \(String.doneInit) = true
        }
        """
    }
    
    
    let extraInitParamNames = extraInitParamCandidates.map{$0.name}
    let extraVarsToDecl = declaredInitParamsPerInit.flatMap{$0}.compactMap { (p: ParamModel) -> String? in
        if !extraInitParamNames.contains(p.name) {
            return p.asVarDecl
        }
        return nil
    }
    .joined(separator: "\n")

    var blankInit = ""
    if needBlankInit {
        // In case of protocol mocking, we want to provide a blank init (if not present already) for convenience,
        // where instance vars do not have to be set in init since they all have get/set (see VariableTemplate).
        blankInit = "\(accessControlLevelDescription)init() { \(String.doneInit) = true }"
    }

    let initFlag =  "private var \(String.doneInit) = false"
    let template = """
        \(initFlag)
        \(extraVarsToDecl)
        \(blankInit)
        \(initTemplate)
    """
    
    return template
}


/// Returns models that can be used as parameters to an initializer
/// @param models The models (processed and unprocessed) of the current entity
/// @returns A list of init parameter models
private func sortedInitVars(`in` models: [Model]) -> [Model] {
    let processed = models.filter {$0.processed && $0.canBeInitParam}
    let unprocessed = models.filter {!$0.processed && $0.canBeInitParam}

    // Named params in init should be unique. Add a duplicate param check to ensure it.
    let curVarsSorted = unprocessed.sorted(path: \.offset, fallback: \.name)
        
    let curVarNames = curVarsSorted.map(path: \.name)
    let parentVars = processed.filter {!curVarNames.contains($0.name)}
    let parentVarsSorted = parentVars.sorted(path: \.offset, fallback: \.name)
    let result = [curVarsSorted, parentVarsSorted].flatMap{$0}
    return result
}

