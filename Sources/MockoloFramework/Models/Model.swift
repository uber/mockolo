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

public enum ModelType {
    case variable, method, typeAlias, parameter, `class`
}

/// Represents a model for an entity such as var, func, class, etc.
public protocol Model {
    /// Identifier
    var name: String { get set }

    /// Fully qualified identifier
    var fullName: String { get }

    /// Type of this model
    var modelType: ModelType { get }
    
    /// Indicates whether mock generation for this model has been processed
    var processed: Bool { get }
    
    /// Indicates whether this model can be used as a parameter to an initializer
    var canBeInitParam: Bool { get }

    /// Indicates whether this model maps to an init method
    var isInitializer: Bool { get }

    /// Decl(e.g. class/struct/protocol/enum) or return type (e.g. var/func)
    var type: Type { get set }

    /// Offset where this type is declared
    var offset: Int64 { get set }

    /// Applies a corresponding template to this model to output mocks
    func render(with identifier: String, typeKeys: [String: String]?) -> String?

    /// Used to differentiate multiple entities with the same name
    /// @param level The verbosity level
    /// @returns a unique name given the verbosity (default is name)
    func name(by level: Int) -> String
    
    func isEqual(_ other: Model) -> Bool

    func isLessThan(_ other: Model) -> Bool
}

extension Model {
    func isEqual(_ other: Model) -> Bool {
        return self.fullName == other.fullName &&
            self.type.typeName == other.type.typeName &&
            self.modelType == other.modelType
    }
    
    func isLessThan(_ other: Model) -> Bool {
        if self.offset == other.offset {
            return self.name < other.name
        }
        return self.offset < other.offset
    }

    func name(by level: Int) -> String {
        return name
    }
    
    var fullName: String {
        return name
    }
    
    var processed: Bool {
        return false
    }
    
    var canBeInitParam: Bool {
        return false
    }

    var isInitializer: Bool {
        return false
    }
}
