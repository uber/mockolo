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

/// Performs uniquifying operations on models of an entity

func generateUniqueModels(protocolMap: [String: Entity],
                          annotatedProtocolMap: [String: Entity],
                          inheritanceMap: [String: Entity],
                          completion: @escaping (ResolvedEntityContainer) -> ()) {
    scan(annotatedProtocolMap) { (key, val, lock) in
        let ret = generateUniqueModels(key: key, entity: val, protocolMap: protocolMap, inheritanceMap: inheritanceMap)
        lock?.lock()
        completion(ret)
        lock?.unlock()
    }
}

private func generateUniqueModels(key: String,
                                  entity: Entity,
                                  protocolMap: [String: Entity],
                                  inheritanceMap: [String: Entity]) -> ResolvedEntityContainer {
    
    let (models, processedModels, attributes, paths, pathToContentList) = lookupEntities(key: key, declType: entity.entityNode.declType, protocolMap: protocolMap, inheritanceMap: inheritanceMap)

    combinePostLookup(models: models)
    
    let processedFullNames = processedModels.compactMap {$0.fullName}

    let processedElements = processedModels.compactMap { (element: Model) -> (String, Model)? in
        let name = element.name
        if let rng = name.range(of: String.setCallCountSuffix) {
            return (String(name[name.startIndex..<rng.lowerBound]), element)
        }
        if let rng = name.range(of: String.callCountSuffix) {
            return (String(name[name.startIndex..<rng.lowerBound]), element)
        }
        return nil
    }
    
    var processedLookup = Dictionary<String, Model>()
    processedElements.forEach { (key, val) in processedLookup[key] = val }
    
    let nonMethodModels = models.filter {$0.modelType != .method}
    let methodModels = models.filter {$0.modelType == .method}
    let orderedModels = [nonMethodModels, methodModels].flatMap {$0}
    let x = uniqueEntities(in: orderedModels, exclude: processedLookup, fullnames: processedFullNames)
    let unmockedUniqueEntities = x.filter {!$0.value.processed}
    
    let processedElementsMap = Dictionary(grouping: processedModels) { element in element.fullName }
        .compactMap { (key, value) in value.first }
        .map { element in (element.fullName, element) }
    let mockedUniqueEntities = Dictionary(uniqueKeysWithValues: processedElementsMap)

    let uniqueModels = [mockedUniqueEntities, unmockedUniqueEntities].flatMap {$0}
    
    let resolvedEntity = ResolvedEntity(key: key, entity: entity, uniqueModels: uniqueModels, attributes: attributes)
    
    return ResolvedEntityContainer(entity: resolvedEntity, paths: paths, imports: pathToContentList)
}

private func combinePostLookup(models: [Model]) {
    var variableModels = [VariableModel]()
    var nameToVariableModels = [String: VariableModel]()

    for model in models {
        guard let variableModel = model as? VariableModel else {
            continue
        }
        variableModels.append(variableModel)
        nameToVariableModels[variableModel.name] = variableModel
    }

    for variableModel in variableModels {
        guard let combinePublishedAlias = variableModel.combinePublishedAlias else {
            continue
        }

        // If a variable member in this entity already exists, link the two together.
        // Otherwise, create a model representing this entity. This is needed for it to be considered
        // as an init param.
        let publishedModel: VariableModel

        if let matchingPublishedModel = nameToVariableModels[combinePublishedAlias.propertyName] {
            publishedModel = matchingPublishedModel
            variableModel.publishedAliasModel = publishedModel
            publishedModel.propertyWrapper = variableModel.combinePublishedAlias?.propertyWrapper
        } else {
            // Invalid alias. Fallback to PassthroughSubject
            //
            variableModel.combinePublishedAlias = nil
            variableModel.combineSubjectType = .passthroughSubject
        }
    }
}
