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

public enum ModelType {
    case variable
    case method
    case typeAlias
    case parameter
    case macro
    case nominal
    case argumentsHistory
    case closure
    case associatedType
}

enum NominalTypeDeclKind: String {
    case `class`
    case `actor`
    case `protocol`
}

struct RenderContext {
    var overloadingResolvedName: String?
    var enclosingType: SwiftType?
    var annotatedTypeKind: NominalTypeDeclKind?
    var requiresSendable: Bool = false
}

/// Represents a model for an entity such as var, func, class, etc.
protocol Model: AnyObject {
    /// Identifier
    var name: String { get }

    /// Fully qualified identifier
    var fullName: String { get }

    /// Type of this model
    var modelType: ModelType { get }

    /// Indicates whether mock generation for this model has been processed
    var processed: Bool { get }

    /// Offset where this type is declared
    var offset: Int64 { get }

    /// Applies a corresponding template to this model to output mocks
    func render(
        context: RenderContext,
        arguments: GenerationArguments
    ) -> String?

    /// Used to differentiate multiple entities with the same name
    /// @param level The verbosity level
    /// @returns a unique name given the verbosity (default is name)
    func name(by level: Int) -> String
}

extension Model {
    func name(by level: Int) -> String {
        return name
    }

    var fullName: String {
        return name
    }

    var processed: Bool {
        return false
    }
}

protocol TypealiasRenderableModel: Model {
    var hasGenericConstraints: Bool { get }
    var defaultType: SwiftType? { get }
}
