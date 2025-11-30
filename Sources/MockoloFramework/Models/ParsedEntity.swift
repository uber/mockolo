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

import Algorithms

/// Metadata containing unique models and potential init params ready to be rendered for output
struct ResolvedEntity {
    var key: String
    var entity: Entity
    var uniqueModels: [(String, Model)]
    var attributes: [String]
    var inheritedTypes: [String]

    var declaredInits: [MethodModel] {
        return uniqueModels.compactMap { (_, model) in
            guard let model = model as? MethodModel,
                  model.isInitializer else { return nil }
            return model
        }
    }

    var initParamCandidates: [VariableModel] {
        return sortedInitVars(
            in: uniqueModels.compactMap{ $0.1 as? VariableModel }
        )
    }

    var inheritsActorProtocol: Bool {
        return inheritedTypes.contains(.actorProtocol)
    }

    /// Returns models that can be used as parameters to an initializer
    /// @param models The models of the current entity including unprocessed (ones to generate) and
    ///             processed (already mocked by a previous run if any) models.
    /// @returns A list of init parameter models
    private func sortedInitVars(`in` models: [VariableModel]) -> [VariableModel] {
        let (unprocessed, processed) = models.filter(\.canBeInitParam).partitioned(by: \.processed)

        // Named params in init should be unique. Add a duplicate param check to ensure it.
        let curVarsSorted = unprocessed.sorted(path: \.offset, fallback: \.name)

        let curVarNames = curVarsSorted.map(\.name)
        let parentVars = processed.filter {!curVarNames.contains($0.name)}
        let parentVarsSorted = parentVars.sorted(path: \.offset, fallback: \.name)
        let result = [curVarsSorted, parentVarsSorted].flatMap{$0}
        return result
    }

    var requiresSendable: Bool {
        return inheritedTypes.contains(.sendable) || inheritedTypes.contains(.error)
    }

    func model() -> Model {
        let metadata = entity.metadata
        return NominalModel(selfType: .init(name: metadata?.nameOverride ?? (key + "Mock")),
                            namespaces: entity.entityNode.namespaces,
                            acl: entity.entityNode.accessLevel,
                            declKindOfMockAnnotatedBaseType: entity.entityNode.declKind,
                            declKind: inheritsActorProtocol ? .actor : .class,
                            attributes: attributes,
                            offset: entity.entityNode.offset,
                            inheritedTypeName: (entity.metadata?.module?.withDot ?? "") + key,
                            genericWhereConstraints: entity.entityNode.genericWhereConstraints,
                            initParamCandidates: initParamCandidates,
                            declaredInits: declaredInits,
                            entities: uniqueModels,
                            requiresSendable: requiresSendable)
    }
}

struct ResolvedEntityContainer {
    var entity: ResolvedEntity
    var paths: [String]
}

protocol EntityNode {
    var namespaces: [String] { get }
    var nameText: String { get }
    var mayHaveGlobalActor: Bool { get }
    var accessLevel: String { get }
    var attributesDescription: String { get }
    var declKind: NominalTypeDeclKind { get }
    var inheritedTypes: [String] { get }
    var genericWhereConstraints: [String] { get }
    var offset: Int64 { get }
    var hasBlankInit: Bool { get }
    func subContainer(metadata: AnnotationMetadata?, declKind: NominalTypeDeclKind, path: String?, isProcessed: Bool) -> EntityNodeSubContainer
}

struct EntityNodeSubContainer {
    var attributes: [String]
    var members: [Model]
    var hasInit: Bool
}

public enum CombineType {
    case passthroughSubject
    case currentValueSubject
    case property(wrapper: String, name: String)

    var typeName: String {
        switch self {
        case .passthroughSubject:
            return .passthroughSubject
        case .currentValueSubject:
            return .currentValueSubject
        case .property:
            return ""
        }
    }
}

/// Contains arguments to annotation
/// e.g. @mockable(module: prefix = Foo; typealias: T = Any; U = String; rx: barStream = PublishSubject; history: bazFunc = true; modifiers: someVar = weak; combine: fooPublisher = CurrentValueSubject; otherPublisher = @Published otherProperty, override: name = FooMock)
struct AnnotationMetadata {
    var nameOverride: String?
    var module: String?
    var typeAliases: [String: String]?
    var varTypes: [String: String]?
    var funcsWithArgsHistory: [String]?
    var modifiers: [String: Modifier]?
    var combineTypes: [String: CombineType]?
}

struct GenerationArguments {
    var useTemplateFunc: Bool
    var allowSetCallCount: Bool
    var mockFinal: Bool
    var enableFuncArgsHistory: Bool
    var disableCombineDefaultValues: Bool
    static let `default` = GenerationArguments(
        useTemplateFunc: false,
        allowSetCallCount: false,
        mockFinal: false,
        enableFuncArgsHistory: false,
        disableCombineDefaultValues: false
    )
}

/// Structured import data parsed from a source file
public struct ParsedImports {
    /// Top-level imports without conditional compilation
    public var topLevel: [Import]
    /// Conditional import blocks (#if/#elseif/#else/#endif)
    public var conditional: [ConditionalImportBlock]

    public init(topLevel: [Import] = [], conditional: [ConditionalImportBlock] = []) {
        self.topLevel = topLevel
        self.conditional = conditional
    }
}

public typealias ImportMap = [String: ParsedImports]

/// Metadata for a type being mocked
public final class Entity {
    let entityNode: EntityNode
    let filepath: String
    let metadata: AnnotationMetadata?
    let isProcessed: Bool

    var isAnnotated: Bool {
        return metadata != nil
    }

    static func node(with entityNode: EntityNode,
                     filepath: String,
                     isPrivate: Bool,
                     isFinal: Bool,
                     metadata: AnnotationMetadata?,
                     processed: Bool) -> Entity? {

        guard !isPrivate, !isFinal else {return nil}

        return Entity(entityNode: entityNode,
                      filepath: filepath,
                      metadata: metadata,
                      isProcessed: processed)
    }

    init(entityNode: EntityNode,
         filepath: String,
         metadata: AnnotationMetadata?,
         isProcessed: Bool) {
        self.entityNode = entityNode
        self.filepath = filepath
        self.metadata = metadata
        self.isProcessed = isProcessed
    }
}

enum Modifier: String {
    case weak = "weak"
    case dynamic = "dynamic"
}
