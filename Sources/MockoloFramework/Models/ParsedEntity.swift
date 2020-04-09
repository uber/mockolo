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
    
    var declaredInits: [MethodModel] {
        return uniqueModels.filter {$0.1.isInitializer}.compactMap{ $0.1 as? MethodModel }
    }
    
    var hasDeclaredEmptyInit: Bool {
        return !declaredInits.filter { $0.params.isEmpty }.isEmpty
    }
    
    var declaredInitParams: [ParamModel] {
        return declaredInits.map { $0.params }.flatMap{$0}
    }

    var initParamCandidates: [Model] {
        return sortedInitVars(in: uniqueModels.map{$0.1})
    }

    /// Returns models that can be used as parameters to an initializer
    /// @param models The models of the current entity including unprocessed (ones to generate) and
    ///             processed (already mocked by a previous run if any) models.
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

    
    func model() -> Model {
        return ClassModel(identifier: key,
                          acl: entity.entityNode.accessLevel,
                          declType: entity.entityNode.declType,
                          attributes: attributes,
                          offset: entity.entityNode.offset,
                          metadata: entity.metadata,
                          initParamCandidates: initParamCandidates,
                          declaredInits: declaredInits,
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
    var accessLevel: String { get }
    var attributesDescription: String { get }
    var declType: DeclType { get }
    var inheritedTypes: [String] { get }
    var offset: Int64 { get }
    var hasBlankInit: Bool { get }
    func subContainer(metadata: AnnotationMetadata?, declType: DeclType, path: String?, data: Data?, isProcessed: Bool) -> EntityNodeSubContainer
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

/// Contains arguments to annotation
/// e.g. @mockable(module: prefix = Foo; typealias: T = Any; U = String; rx: barStream = PublishSubject)
struct AnnotationMetadata {
    var module: String?
    var typeAliases: [String: String]?
    var varTypes: [String: String]?
}

public typealias ImportMap = [String: [String: [String]]]

/// Metadata for a type being mocked
public final class Entity {
    var filepath: String = ""
    var data: Data? = nil
    let entityNode: EntityNode
    let isProcessed: Bool
    let metadata: AnnotationMetadata?

    var isAnnotated: Bool {
        return metadata != nil
    }

    static func node(with entityNode: EntityNode,
                     filepath: String,
                     data: Data? = nil,
                     isPrivate: Bool,
                     isFinal: Bool,
                     metadata: AnnotationMetadata?,
                     processed: Bool) -> Entity? {
        
        guard !isPrivate, !isFinal else {return nil}
        
        let node = Entity(entityNode: entityNode,
                          filepath: filepath,
                          data: data,
                          metadata: metadata,
                          isProcessed: processed)
        
        return node
    }

    init(entityNode: EntityNode,
         filepath: String = "",
         data: Data? = nil,
         metadata: AnnotationMetadata?,
         isProcessed: Bool) {
        self.entityNode = entityNode
        self.filepath = filepath
        self.data = data
        self.metadata = metadata
        self.isProcessed = isProcessed
    }
}
