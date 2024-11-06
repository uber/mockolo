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

final class TypeAliasModel: Model {
    let name: String
    let type: SwiftType
    let offset: Int64
    let length: Int64
    let accessLevel: String
    let processed: Bool
    let useDescription: Bool
    let modelDescription: String?
    let overrideTypes: [String: String]?

    var modelType: ModelType {
        return .typeAlias
    }

    init(name: String, typeName: String, acl: String?, overrideTypes: [String: String]?, offset: Int64, length: Int64, modelDescription: String?, useDescription: Bool = false, processed: Bool) {
        self.name = name
        self.accessLevel = acl ?? ""
        self.offset = offset
        self.length = length
        self.processed = processed
        self.modelDescription = modelDescription
        self.overrideTypes = overrideTypes
        self.useDescription = useDescription
        // If there's an override typealias value, set it to type
        if let val = overrideTypes?[self.name] {
            self.type  = SwiftType(val)
        } else {
            self.type = typeName.isEmpty ? SwiftType(String.anyType) : SwiftType(typeName)
        }
    }

    var fullName: String {
        return self.name + self.type.displayName
    }

    func name(by level: Int) -> String {
        return fullName
    }

    func render(
        context: RenderContext,
        arguments: GenerationArguments
    ) -> String? {
        let addAcl = context.annotatedTypeKind == .protocol && !processed
        if processed || useDescription, let modelDescription = modelDescription?.trimmingCharacters(in: .whitespacesAndNewlines) {
            if addAcl {
                return "\(1.tab)\(accessLevel) \(modelDescription)"
            }
            return "\(1.tab)\(modelDescription)"
        }
        
        return applyTypealiasTemplate(name: name, type: type, acl: accessLevel)
    }
}
