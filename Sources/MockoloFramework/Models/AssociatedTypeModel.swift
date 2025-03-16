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

final class AssociatedTypeModel: Model {
    let name: String
    let inheritance: String?
    let defaultType: SwiftType?
    let whereConditions: [String]
    let offset: Int64
    let length: Int64
    let accessLevel: String

    var modelType: ModelType {
        return .associatedType
    }

    init(
        name: String,
        inheritance: String?,
        defaultTypeName: String?,
        whereConditions: [String],
        acl: String?,
        offset: Int64,
        length: Int64
    ) {
        self.name = name
        self.inheritance = inheritance
        self.defaultType = defaultTypeName.map { SwiftType($0) }
        self.whereConditions = whereConditions
        self.offset = offset
        self.length = length
        self.accessLevel = acl ?? ""
    }

    var fullName: String {
        return self.name
        + (self.inheritance ?? "")
        + (self.defaultType?.displayName ?? "")
        + self.whereConditions.joined()
    }

    func name(by level: Int) -> String {
        return fullName
    }

    var hasCondition: Bool {
        inheritance != nil || !whereConditions.isEmpty
    }

    var hasDefaultType: Bool {
        defaultType != nil || !hasCondition
    }

    func render(
        context: RenderContext,
        arguments: GenerationArguments
    ) -> String? {
        if let defaultType {
            return renderTypealias(typeName: defaultType.typeName)
        }

        if hasCondition {
            return nil
        } else {
            return renderTypealias(typeName: .anyType)
        }

        func renderTypealias(typeName: String) -> String {
            var aclStr = accessLevel
            if !aclStr.isEmpty {
                aclStr = aclStr + " "
            }

            return "\(1.tab)\(aclStr)\(String.typealias) \(name) = \(typeName)"
        }
    }
}
