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
                          typeKeys: [String: String]?,
                          semaphore: DispatchSemaphore?,
                          queue: DispatchQueue?,
                          completion: @escaping (ResolvedEntityContainer) -> ()) {
    if let queue = queue {
        let lock = NSLock()
        for (key, val) in annotatedProtocolMap {
            _ = semaphore?.wait(timeout: DispatchTime.distantFuture)
            queue.async {
                generateUniqueModels(key: key, entity: val, typeKeys: typeKeys, protocolMap: protocolMap, inheritanceMap: inheritanceMap, lock: lock, completion: completion)
                semaphore?.signal()
            }
        }
        queue.sync(flags: .barrier) { }
    } else {
        for (key, val) in annotatedProtocolMap {
            generateUniqueModels(key: key, entity: val, typeKeys: typeKeys, protocolMap: protocolMap, inheritanceMap: inheritanceMap, lock: nil, completion: completion)
        }
    }
}

func generateUniqueModels(key: String,
                          entity: Entity,
                          typeKeys: [String: String]?,
                          protocolMap: [String: Entity],
                          inheritanceMap: [String: Entity]) -> ResolvedEntityContainer {
    
    let (models, processedModels, attributes, paths, pathToContentList) = lookupEntities(key: key, protocolMap: protocolMap, inheritanceMap: inheritanceMap)
    
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
    
    let whitelist = typealiasWhitelist(in: uniqueModels)
    let resolvedEntity = ResolvedEntity(key: key, entity: entity, uniqueModels: uniqueModels, attributes: attributes, typealiasWhitelist: whitelist)
    
    return ResolvedEntityContainer(entity: resolvedEntity, paths: paths, imports: pathToContentList)
}



func generateUniqueModels(key: String,
                          entity: Entity,
                          typeKeys: [String: String]?,
                          protocolMap: [String: Entity],
                          inheritanceMap: [String: Entity],
                          lock: NSLock? = nil,
                          completion: @escaping (ResolvedEntityContainer) -> ()) {
    let ret = generateUniqueModels(key: key, entity: entity, typeKeys: typeKeys, protocolMap: protocolMap, inheritanceMap: inheritanceMap)
    
    lock?.lock()
    completion(ret)
    lock?.unlock()
}


