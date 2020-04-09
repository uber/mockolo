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

/// Used to resolve inheritance, uniquify duplicate entities, and compute potential init params.

/// Resolves inheritance by looking up the given protocol map and inheritance map
/// @param key The entity name to look up
/// @param protocolMap Used to look up the current entity and its inheritance types
/// @param inheritanceMap Used to look up inherited types if not contained in protocolMap
/// @returns a list of models representing sub-entities of the current entity, a list of models processed in dependent mock files if exists,
///          cumulated attributes, and a map of filepaths and file contents (used for import lines lookup later).
func lookupEntities(key: String,
                    declType: DeclType,
                    protocolMap: [String: Entity],
                    inheritanceMap: [String: Entity]) -> ([Model], [Model], [String], [String], [(String, Data, Int64)]) {
    
    // Used to keep track of types to be mocked
    var models = [Model]()
    // Used to keep track of types that were already mocked
    var processedModels = [Model]()
    // Gather attributes declared in current or parent protocols
    var attributes = [String]()
    // Gather filepaths and contents used for imports
    var pathToContents = [(String, Data, Int64)]()
    // Gather filepaths used for imports
    var paths = [String]()

    // Look up the mock entities of a protocol specified by the name.
    if let current = protocolMap[key] {
        let sub = current.entityNode.subContainer(metadata: current.metadata, declType: declType, path: current.filepath, data: current.data, isProcessed: current.isProcessed)
        models.append(contentsOf: sub.members)
        if !current.isProcessed {
            attributes.append(contentsOf: sub.attributes)
        }
        if let data = current.data {
            pathToContents.append((current.filepath, data, current.entityNode.offset))
        }
        paths.append(current.filepath)
        
        
        if declType == .protocolType { // TODO: remove this once parent protocol (current decl = classtype) handling is resolved.
            // If the protocol inherits other protocols, look up their entities as well.
            for parent in current.entityNode.inheritedTypes {
                if parent != .class, parent != .any, parent != .anyObject {
                    let (parentModels, parentProcessedModels, parentAttributes, parentPaths, parentPathToContents) = lookupEntities(key: parent, declType: declType, protocolMap: protocolMap, inheritanceMap: inheritanceMap)
                    models.append(contentsOf: parentModels)
                    processedModels.append(contentsOf: parentProcessedModels)
                    attributes.append(contentsOf: parentAttributes)
                    paths.append(contentsOf: parentPaths)
                    pathToContents.append(contentsOf:parentPathToContents)
                }
            }
        }
    } else if let parentMock = inheritanceMap["\(key)Mock"], declType == .protocolType {
        // If the parent protocol is not in the protocol map, look it up in the input parent mocks map.
        let sub = parentMock.entityNode.subContainer(metadata: parentMock.metadata, declType: declType, path: parentMock.filepath, data: parentMock.data, isProcessed: parentMock.isProcessed)
        processedModels.append(contentsOf: sub.members)
        if !parentMock.isProcessed {
            attributes.append(contentsOf: sub.attributes)
        }
        if let data = parentMock.data {
            pathToContents.append((parentMock.filepath, data, parentMock.entityNode.offset))
        }
        paths.append(parentMock.filepath)
    }
    
    return (models, processedModels, attributes, paths, pathToContents)
}


/// Uniquify multiple entities with the same name, e.g. func signature, using the verbosity level
/// @param group The dictionary containing entity name and corresponding models
/// @param level The verbosiy level used for uniquing entity names
/// @param nameByLevelVisited Used to look up whether an entity name has already been used and thus needs
///                           to be differentiated
/// @param fullNameVisited Used to look up an entity full name to detect true duplicates (e.g.
///        overloaded functions in multiple parent protocols)
/// @returns a dictionary with unique entity names and corresponding models
private func uniquifyDuplicates(group: [String: [Model]],
                                level: Int,
                                nameByLevelVisited: [String: Model]?,
                                fullNameVisited: [String]) -> [String: Model] {
    
    var bufferNameByLevelVisited = [String: Model]()
    var bufferFullNameVisited = [String]()
    group.forEach { (key: String, models: [Model]) in
        if let nameByLevelVisited = nameByLevelVisited, nameByLevelVisited[key] != nil {
            // An entity with the given key already exists, so look up a more verbose name for these entities
            let subgroup = Dictionary(grouping: models, by: { (modelElement: Model) -> String in
                return modelElement.name(by: level + 1)
            })
            if !fullNameVisited.isEmpty {
                bufferFullNameVisited.append(contentsOf: fullNameVisited)
            }
            let subresult = uniquifyDuplicates(group: subgroup, level: level+1, nameByLevelVisited: bufferNameByLevelVisited, fullNameVisited: bufferFullNameVisited)
            bufferNameByLevelVisited.merge(subresult, uniquingKeysWith: { (bufferElement: Model, subresultElement: Model) -> Model in
                return subresultElement
            })
        } else {
            // Check if full name has been looked up
            let visited = models.filter {fullNameVisited.contains($0.fullName)}.compactMap{$0}
            let unvisited = models.filter {!fullNameVisited.contains($0.fullName)}.compactMap{$0}
            
            if let first = unvisited.first {
                // If not, add it to the fullname map to keep track of duplicates
                if !visited.isEmpty {
                    bufferFullNameVisited.append(contentsOf: visited.map{$0.fullName})
                }
                bufferFullNameVisited.append(first.fullName)
                
                // There could be multiple entities with the same name key; add the first one to
                // a buffer and use a more verbose name key for the rest to differentiate them
                bufferNameByLevelVisited[key] = first
                let nextModels = unvisited[1...]
                let subgroup = Dictionary(grouping: nextModels, by: { (modelElement: Model) -> String in
                    let distinctName = modelElement.name(by: level + 1)
                    return distinctName
                })
                
                let subresult = uniquifyDuplicates(group: subgroup, level: level+1, nameByLevelVisited: bufferNameByLevelVisited, fullNameVisited: bufferFullNameVisited)
                bufferNameByLevelVisited.merge(subresult, uniquingKeysWith: { (bufferElement: Model, addedElement: Model) -> Model in
                    return addedElement
                })
            }
        }
    }
    return bufferNameByLevelVisited
}

/// Uniquify multiple entities with the same name
/// @param models The entity models that possibly contain duplciates
/// @param exclude The models that are used for lookup only
/// @param fullnames Used to look up full identifiers
/// @returns A map of unique models
func uniqueEntities(`in` models: [Model], exclude: [String: Model], fullnames: [String]) -> [String: Model] {
    return uniquifyDuplicates(group: Dictionary(grouping: models) { $0.name(by: 0) }, level: 0, nameByLevelVisited: exclude, fullNameVisited: fullnames)
}

