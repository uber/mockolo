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
import SwiftSyntax

/// Metadata containing unique models and potential init params ready to be rendered for output
struct ResolvedEntity {
    let key: String
    let entity: Entity
    let uniqueModels: [(String, Model)]
    let attributes: [String]
    let hasInit: Bool
    let initVars: [Model]?
    let typealiasWhitelist: [String: [String]]?
    
    func model() -> Model {
        return ClassModel(identifier: key,
                          acl: entity.acl,
                          attributes: attributes,
                          offset: entity.offset,
                          needInit: !hasInit,
                          initParams: initVars,
                          typealiasWhitelist: typealiasWhitelist,
                          entities: uniqueModels)
    }
}

struct ResolvedEntityContainer {
    let entity: ResolvedEntity
    let imports: [(String, Data, Int64)]
}

/// Metadata for a type being mocked
final class Entity {
    var name: String = ""
    var filepath: String = ""
    var data: Data? = nil
    var members: [Model]
    var offset: Int64 = 0
    var acl: String = ""
    var attributes: [String]
    var parents: [String]? = nil
    var hasInit: Bool = false
    var isAnnotated: Bool = false
    var metadata: [String: String]? = nil
    var isProcessed: Bool = false
    
    init(name: String,
         filepath: String,
         data: Data?,
         acl: String,
         attributes: [String] = [],
         parents: [String]?,
         hasInit: Bool,
         offset: Int64,
         isAnnotated: Bool,
         metadata: [String: String]?,
         members: [Model],
         isProcessed: Bool) {
        self.name = name
        self.filepath = filepath
        self.data = data
        self.acl = acl
        self.attributes = attributes
        self.parents = parents
        self.hasInit = hasInit
        self.isAnnotated = isAnnotated
        self.metadata = metadata
        self.isProcessed = isProcessed
        self.offset = offset
        self.members = members
    }
    
    var inheritedTypes: [String] {
        if let parents = parents {
            return parents
        }
        return []
    }
    
    func subAttributes() -> [String]? {
        if isProcessed {
            return nil
        }
        return attributes
    }
    
    static func model(for element: Structure, filepath: String, data: Data, metadata: [String: String]?, processed: Bool = false) -> Model? {
        if element.isVariable {
            return VariableModel(element, filepath: filepath, data: data, processed: processed)
        } else if element.isMethod {
            return MethodModel(element, filepath: filepath, data: data,  processed: processed)
        } else if element.isAssociatedType {
            return TypeAliasModel(element, filepath: filepath, data: data, overrideTypes: metadata, processed: processed)
        }
        
        return nil
    }
}
