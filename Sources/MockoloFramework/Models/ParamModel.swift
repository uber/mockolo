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

struct ParamModel: Model {
    var name: String
    var offset: Int64 = .max
    var type: String
    let label: String
    let isGeneric: Bool
    let isInitializer: Bool

    init(_ ast: Structure, label: String = "", isGeneric: Bool = false, isInitializer: Bool = false) {
        self.name = ast.name
        self.isGeneric = isGeneric
        self.isInitializer = isInitializer
        self.type = isGeneric ? (ast.inheritedTypes.first ?? .unknownVal) : ast.typeName
        self.label = ast.name != label ? label: ""
    }

    var asVarDecl: String? {
        if self.isInitializer {
            assert(!type.isEmpty && type != .unknownVal)
            let vardecl =
            """
            private var \(name): \(type.forceUnwrappedType)
            """
            return vardecl
        }
        return nil
    }
    
    func render(with identifier: String, typeKeys: [String: String]? = nil) -> String? {
        var result = name
        if !label.isEmpty {
            result = "\(label) \(name)"
        }
        if !type.isEmpty, type != .unknownVal {
            result = "\(result): \(type)"
        }
        return result
    }
}
