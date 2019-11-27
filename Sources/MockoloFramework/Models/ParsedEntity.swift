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
    var filepath: String = ""
    var data: Data? = nil

    let name: String
    let members: [Model]
    let offset: Int64
    let acl: String
    let attributes: [String]
    let inheritedTypes: [String]
    let hasInit: Bool
    let isAnnotated: Bool
    let overrides: [String: String]?
    let isProcessed: Bool
    
    init(name: String,
         filepath: String = "",
         data: Data? = nil,
         isAnnotated: Bool,
         overrides: [String: String]?,
         acl: String,
         attributes: [String],
         inheritedTypes: [String],
         members: [Model],
         hasInit: Bool,
         offset: Int64,
         isProcessed: Bool) {
        self.name = name
        self.filepath = filepath
        self.data = data
        self.acl = acl
        self.attributes = attributes
        self.inheritedTypes = inheritedTypes
        self.hasInit = hasInit
        self.isAnnotated = isAnnotated
        self.overrides = overrides
        self.isProcessed = isProcessed
        self.offset = offset
        self.members = members
    }

    
    func subAttributes() -> [String]? {
        if isProcessed {
            return nil
        }
        return attributes.filter {$0.contains(String.available)}
    }

    static func model(name: String,
                      label: String = "",
                      typeName: String,
                      acl: String? = nil,
                      overrideTypes: [String: String]? = nil,
                      throwsOrRethrows: String? = nil,
                      isStatic: Bool = false,
                      isGeneric: Bool = false,
                      isInitializer: Bool = false,
                      canBeInitParam: Bool = false,
                      offset: Int64,
                      length: Int64,
                      modelDescription: String? = nil,
                      processed: Bool = false) -> Model? {
        return nil
    }
    
    static func model(for element: Structure, filepath: String, data: Data, overrides: [String: String]?, processed: Bool = false) -> Model? {
        if element.isVariable {
            return VariableModel(element, filepath: filepath, data: data, processed: processed)
        } else if element.isMethod {
            return MethodModel(element, filepath: filepath, data: data,  processed: processed)
        } else if element.isAssociatedType {
            return TypeAliasModel(element, filepath: filepath, data: data, overrideTypes: overrides, processed: processed)
        }
        
        return nil
    }
}
