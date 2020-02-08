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

/// Metadata containing unique models and potential init params ready to be rendered for output
struct ResolvedEntity {
    let key: String
    let entity: Entity
    let uniqueModels: [(String, Model)]
    let attributes: [String]
    let typealiasWhitelist: [String: [String]]?
    
    func model() -> Model {
        return ClassModel(identifier: key,
                          acl: entity.entityNode.acl,
                          declType: entity.entityNode.declType,
                          attributes: attributes,
                          offset: entity.entityNode.offset,
                          typealiasWhitelist: typealiasWhitelist,
                          entities: uniqueModels)
    }
}

struct ResolvedEntityContainer {
    let entity: ResolvedEntity
    let paths: [String]
    let imports: [(String, Data, Int64)]
}

protocol EntityNode {
    var name: String { get }
    var acl: String { get }
    var attributesDescription: String { get }
    var declType: DeclType { get }
    var inheritedTypes: [String] { get }
    var offset: Int64 { get }
    func subContainer(overrides: [String: String]?, declType: DeclType, path: String?, data: Data?, isProcessed: Bool) -> EntityNodeSubContainer
}

final class EntityNodeSubContainer {
    let attributes: [String]
    let members: [Model]
    let hasInit: Bool
    init(attributes: [String], members: [Model], hasInit: Bool) {
        self.attributes = attributes
        self.members = members
        self.hasInit = hasInit
    }
}

// Contains arguments to annotation
// Ex. @mockable(typealias: T = Any; U = String; ...)
struct AnnotationMetadata {
    var typealiases: [String: String]?
}


/// Metadata for a type being mocked
public final class Entity {
    var filepath: String = ""
    var data: Data? = nil

    let isAnnotated: Bool
    let overrides: [String: String]?
    let entityNode: EntityNode
    let isProcessed: Bool
    
    static func node(with entityNode: EntityNode,
                     filepath: String = "",
                     data: Data? = nil,
                     isPrivate: Bool,
                     isFinal: Bool,
                     metadata: AnnotationMetadata?,
                     processed: Bool) -> Entity? {
        
        guard !isPrivate, !isFinal else {return nil}

        let node = Entity(entityNode: entityNode,
                          filepath: filepath,
                          data: data,
                          isAnnotated: metadata != nil,
                          overrides: metadata?.typealiases,
                          isProcessed: processed)
        
        return node
    }

    init(entityNode: EntityNode,
         filepath: String = "",
         data: Data? = nil,
         isAnnotated: Bool,
         overrides: [String: String]?,
         isProcessed: Bool) {
        self.entityNode = entityNode
        self.filepath = filepath
        self.data = data
        self.isAnnotated = isAnnotated
        self.overrides = overrides
        self.isProcessed = isProcessed
    }
}
