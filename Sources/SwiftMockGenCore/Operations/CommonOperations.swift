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

func lookupEntities(name: String,
                    inheritanceMap: [String: (structure: Structure, file: File, models: [Model])],
                    annotatedProtocolMap: [String: ProtocolMapEntryType]) -> ([Model], [String], [String]) {
    
    var models = [Model]()
    var attributes = [""]
    var processedResults = [""]
    // Look up the mock entities of a protocol specified by the name.
    if let current = annotatedProtocolMap[name] {
        let curStructure = current.structure
        let curModels = current.models
        let curAttributes = current.attributes
        
        models.append(contentsOf: curModels)
        attributes.append(contentsOf: curAttributes)
        
        // If the protocol inherits other protocols, look up their entities as well.
        for parent in curStructure.inheritedTypes {
            if parent != ClassString, parent != AnyString, parent != AnyObjectString {
                let (parentModels, parentAttributes, parentResults) = lookupEntities(name: parent, inheritanceMap: inheritanceMap, annotatedProtocolMap: annotatedProtocolMap)
                models.append(contentsOf: parentModels)
                attributes.append(contentsOf: parentAttributes)
                processedResults.append(contentsOf: parentResults)
            }
        }
    } else if let parentMock = inheritanceMap["\(name)Mock"] {
        // If the parent protocol is not in the protocol map, look it up in the input parent mocks map.
        let parentStructure = parentMock.structure
        let parentFile = parentMock.file
        let parentModels = parentMock.models
        
        let content = parentFile.contents
        models.append(contentsOf: parentModels)
        var body = parentStructure.extractBody(content)

        // Remove an initializer from the parent mock class as the leaf mock class will have its own
        if let initStructure = parentStructure.substructures.filter({$0.isInitializer}).first {
            let offset = Int(initStructure.offset - parentStructure.bodyOffset)
            let len = Int(initStructure.length)
            if let range = Range(NSRange(location: offset, length: len), in: body) {
                body.removeSubrange(range)
            }
        }
        processedResults.append(body)
        
        let parentAttributes = parentStructure.extractAttributes(parentFile.contents, filterOn: SwiftDeclarationAttributeKind.available.rawValue)
        attributes.append(contentsOf: parentAttributes)
    }
    
    return (models, attributes, processedResults)
}
