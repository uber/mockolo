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

func renderMocks(inheritanceMap: [String: (Structure, File, [Model])],
                 annotatedProtocolMap: [String: ProtocolMapEntryType],
                 typeKeys: [String],
                 semaphore: DispatchSemaphore?,
                 queue: DispatchQueue?,
                 process: @escaping (Structure, File, String, Int64) -> ()) -> Bool {
    
    if let queue = queue {
        let lock = NSLock()
        
        for key in annotatedProtocolMap.keys {
            _ = semaphore?.wait(timeout: DispatchTime.distantFuture)
            queue.async {
                _ = renderMocksForClass(inheritanceMap: inheritanceMap, key: key, annotatedProtocolMap: annotatedProtocolMap, typeKeys: typeKeys, lock: lock, process: process)
                semaphore?.signal()
            }
        }
        queue.sync(flags: .barrier) { }
    } else {
        for key in annotatedProtocolMap.keys {
            _ = renderMocksForClass(inheritanceMap: inheritanceMap, key: key, annotatedProtocolMap: annotatedProtocolMap, typeKeys: typeKeys, lock: nil, process: process)
        }
    }
    return false
}

private func renderMocksForClass(inheritanceMap: [String: (Structure, File, [Model])],
                                 key: String,
                                 annotatedProtocolMap: [String: ProtocolMapEntryType],
                                 typeKeys: [String],
                                 lock: NSLock? = nil,
                                 process: @escaping (Structure, File, String, Int64) -> ()) -> Bool {

    if let val = annotatedProtocolMap[key] {
        let protocolStructure = val.structure
        let file = val.file
        let (models, processedModels, attributes) = lookupEntities(name: key, inheritanceMap: inheritanceMap, annotatedProtocolMap: annotatedProtocolMap)

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
        processedElements.forEach { (key, val) in
            processedLookup[key] = val
        }

        let unmockedUniqueEntities = uniqueEntities(in: models, exclude: processedLookup, fullnames: processedFullNames).filter {!$0.value.processed}

        let processedElementsMap = Dictionary(grouping: processedModels) { element in element.fullName }
            .compactMap { (key, value) in value.first }
            .map { element in (element.fullName, element) }
        let mockedUniqueEntities = Dictionary(uniqueKeysWithValues: processedElementsMap)

        let uniqueModels = [mockedUniqueEntities, unmockedUniqueEntities].flatMap {$0}
        let renderedEntities = uniqueModels.sorted {$0.1.offset < $1.1.offset}
            .compactMap { (name: String, model: Model) -> String? in
            return model.render(with: name, typeKeys: typeKeys)
        }
        
        let nonOptionalVarList = nonOptionalVars(in: unmockedUniqueEntities, processed: mockedUniqueEntities)
        let mockModel = ClassModel(protocolStructure,
                                   content: file.contents,
                                   identifier: key,
                                   additionalAttributes: attributes,
                                   initParams: nonOptionalVarList,
                                   entities: [renderedEntities.joined(separator: "\n")])
        if let mockString = mockModel.render(with: key, typeKeys: typeKeys), !mockString.isEmpty {
            lock?.lock()
            process(protocolStructure, file, mockString, protocolStructure.offset)
            lock?.unlock()
        }
    }
    return false
}

private func uniqueEntities(`in` models: [Model], exclude: [String: Model], fullnames: [String]) -> [String: Model] {
    return uniquifyDuplicates(group: Dictionary(grouping: models) { $0.name(by: 0) }, level: 0, lookup: exclude, fullNameVisited: fullnames)
}

// Uniquify multiple entities with the same name, e.g. func signature, using the verbosity level
// @param group The dictionary containing entity name and corresponding models
// @param level The verbosiy level used for uniquing entity names
// @param lookup Used to look up whether an entity name has already been used and thus needs
//               to be differentiated
// @param fullNameVisited Used to look up an entity full name to detect true duplicates (e.g.
//        overloaded functions in multiple parent protocols)
// @returns a dictionary with unique entity names and corresponding models
private func uniquifyDuplicates(group: [String: [Model]],
                                level: Int,
                                lookup: [String: Model]?,
                                fullNameVisited: [String]) -> [String: Model] {
    
    var bufferKeyModelMap = [String: Model]()
    var bufferFullNameVisited = [String]()
    group.forEach { (key: String, models: [Model]) in
        if let lookup = lookup, lookup[key] != nil {
            // An entity with the given key already exists, so look up a more verbose name for these entities
            let subgroup = Dictionary(grouping: models, by: { (modelElement: Model) -> String in
                return modelElement.name(by: level + 1)
            })
            if !fullNameVisited.isEmpty {
                bufferFullNameVisited.append(contentsOf: fullNameVisited)
            }
            let subresult = uniquifyDuplicates(group: subgroup, level: level+1, lookup: bufferKeyModelMap, fullNameVisited: bufferFullNameVisited)
            bufferKeyModelMap.merge(subresult, uniquingKeysWith: { (bufferElement: Model, subresultElement: Model) -> Model in
                return subresultElement
            })
        } else if let first = models.first {
            if fullNameVisited.contains(first.fullName) {
                // Full name looked up before so don't do anything
            } else if models.count > 1 {
                // There are multiple entities with the same name key; map one of them with the
                // given key and look up a more verbose name for the rest to differentiate them
                bufferKeyModelMap[key] = first
                // Mark the full name of the given key as visited to detect other entities with
                // the same full name (true duplicates)
                bufferFullNameVisited.append(first.fullName)
                
                if !fullNameVisited.isEmpty {
                    bufferFullNameVisited.append(contentsOf: fullNameVisited)
                }

                let nextModels = models[1...]
                let subgroup = Dictionary(grouping: nextModels, by: { (modelElement: Model) -> String in
                    let distinctName = modelElement.name(by: level + 1)
                    return distinctName
                })
                
                let subresult = uniquifyDuplicates(group: subgroup, level: level+1, lookup: bufferKeyModelMap, fullNameVisited: bufferFullNameVisited)
                bufferKeyModelMap.merge(subresult, uniquingKeysWith: { (bufferElement: Model, addedElement: Model) -> Model in
                    return addedElement
                })
            } else {
                
                // There are no duplicate entities at this point so map them by their (verbose) name
                models.forEach{ (submodel: Model) in
                    let nameKey = submodel.name(by: level)
                    let element = [nameKey : submodel]
                    
                    bufferKeyModelMap.merge(element, uniquingKeysWith: { (bufferElement: Model, addedElement: Model) -> Model in
                        return addedElement
                    })
                }
            }
        }
    }
    return bufferKeyModelMap
}

private func nonOptionalVars(`in` models: [String: Model], processed: [String: Model]) -> [VariableModel] {
    // Named params in init should be unique. Add a duplicate param check to ensure it.
    let curVars = models.values.compactMap{$0 as? VariableModel}.filter(path: \.canBeInitParam).sorted(path: \.offset)
    let curVarNames = curVars.map(path: \.name)
    let parentVars = processed.values.compactMap{$0 as? VariableModel}.filter {!curVarNames.contains($0.name) && $0.canBeInitParam}.sorted(path: \.offset)
    let result = [curVars, parentVars].flatMap{$0}
    return result
}
