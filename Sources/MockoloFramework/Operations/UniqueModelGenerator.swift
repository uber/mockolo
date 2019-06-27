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
import SourceKittenFramework

/// Performs uniquifying operations on models of an entity

func generateUniqueModels(protocolMap: [String: [String: Entity]],
                          annotatedProtocolMap: [String: [String: Entity]],
                          processedMap: [String: Entity],
                          typeKeys: [String: String]?,
                          semaphore: DispatchSemaphore?,
                          queue: DispatchQueue?,
                          process: @escaping (ResolvedEntity, [(String, String)]) -> ()) {
    if let queue = queue {
        let lock = NSLock()
        for (namespace, entryDict) in annotatedProtocolMap {
            for (key, val) in entryDict {
                _ = semaphore?.wait(timeout: DispatchTime.distantFuture)
                queue.async {
                    generateUniqueModels(namespace: namespace, key: key, entity: val, typeKeys: typeKeys, protocolMap: protocolMap, processedMap: processedMap, lock: lock, process: process)
                    semaphore?.signal()
                }
            }
        }
        queue.sync(flags: .barrier) { }
    } else {
        for (namespace, entryDict) in annotatedProtocolMap {
            for (key, val) in entryDict {
                generateUniqueModels(namespace: namespace, key: key, entity: val, typeKeys: typeKeys, protocolMap: protocolMap, processedMap: processedMap, lock: nil, process: process)
            }
        }
    }
}

private func generateUniqueModels(namespace: String,
                                  key: String,
                                  entity: Entity,
                                  typeKeys: [String: String]?,
                                  protocolMap: [String: [String: Entity]],
                                  processedMap: [String: Entity],
                                  lock: NSLock? = nil) -> ResolvedEntityContainer {
    
    let (models, processedModels, attributes, pathToContentList) = lookupEntities(namespace: namespace, key: key, protocolMap: protocolMap, processedMap: processedMap, level: 0)
    let containsInit = models.filter(path: \.isInitializer).count > 0

    let processedFullNames = processedModels.compactMap {$0.fullName}

    let processedElements = processedModels.compactMap { (element: Model) -> (String, Model)? in
        if let rng = element.name.range(of: String.setCallCountSuffix) {
            return (element.name.substring(to: rng.lowerBound), element)
        }
        if let rng = element.name.range(of: String.callCountSuffix) {
            return (element.name.substring(to: rng.lowerBound), element)
        }
        return nil
    }
    
    var processedLookup = Dictionary<String, Model>()
    processedElements.forEach { (key, val) in processedLookup[key] = val }
    
    let unmockedUniqueEntities = uniqueEntities(in: models, exclude: processedLookup, fullnames: processedFullNames).filter {!$0.value.processed}
    
    let processedElementsMap = Dictionary(grouping: processedModels) { element in element.fullName }
        .compactMap { (key, value) in value.first }
        .map { element in (element.fullName, element) }
    let mockedUniqueEntities = Dictionary(uniqueKeysWithValues: processedElementsMap)
    
    let uniqueModels = [mockedUniqueEntities, unmockedUniqueEntities].flatMap {$0}.sorted {$0.1.offset < $1.1.offset}
    let initVars = containsInit ? nil: potentialInitVars(in: unmockedUniqueEntities, processed: mockedUniqueEntities)
    
    let resolvedEntity = ResolvedEntity(namespace: namespace, identifier: key, entity: entity, uniqueModels: uniqueModels, attributes: attributes, hasInit: containsInit, initVars: initVars)
    return ResolvedEntityContainer(entity: resolvedEntity, imports: pathToContentList)
}


func generateUniqueModels(namespace: String,
                          key: String,
                          entity: Entity,
                          typeKeys: [String: String]?,
                          protocolMap: [String: [String: Entity]],
                          processedMap: [String: Entity],
                          lock: NSLock? = nil,
                          process: @escaping (ResolvedEntity, [(String, String)]) -> ()) {
    let ret = generateUniqueModels(namespace: namespace, key: key, entity: entity, typeKeys: typeKeys, protocolMap: protocolMap, processedMap: processedMap)
    
    lock?.lock()
    process(ret.entity, ret.imports)
    lock?.unlock()
}


