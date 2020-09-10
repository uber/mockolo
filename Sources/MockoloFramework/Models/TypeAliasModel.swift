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
    var filePath: String = ""
    var name: String
    var type: Type
    var offset: Int64 = .max
    var length: Int64
    var typeOffset: Int64 = 0
    var typeLength: Int64 = 0
    let accessLevel: String
    let processed: Bool
    var useDescription: Bool = false
    var modelDescription: String? = nil
    let overrideTypes: [String: String]?
    var addAcl: Bool = false
    
    var modelType: ModelType {
        return .typeAlias
    }

    init(name: String, typeName: String, acl: String?, encloserType: DeclType, overrideTypes: [String: String]?, offset: Int64, length: Int64, modelDescription: String?, useDescription: Bool = false, processed: Bool) {
        self.name = name
        self.accessLevel = acl ?? ""
        self.offset = offset
        self.length = length
        self.processed = processed
        self.modelDescription = modelDescription
        self.overrideTypes = overrideTypes
        self.useDescription = useDescription
        self.addAcl = encloserType == .protocolType
        // If there's an override typealias value, set it to type
        if let val = overrideTypes?[self.name] {
            self.type  = Type(val)
        } else {
            self.type = typeName.isEmpty ? Type(String.any) : Type(typeName)
        }
    }

    var fullName: String {
        return self.name + self.type.displayName
    }
    
    func name(by level: Int) -> String {
        return fullName
    }
    
    func render(with identifier: String, encloser: String, useTemplateFunc: Bool = false, useMockObservable: Bool = false, mockFinal: Bool = false, enableFuncArgsHistory: Bool = false) -> String? {
        if processed || useDescription, let modelDescription = modelDescription?.trimmingCharacters(in: .whitespacesAndNewlines) {
            if addAcl {
                return "\(1.tab)\(accessLevel) \(modelDescription)"
            }
            return "\(1.tab)\(modelDescription)"
        }
        
        return applyTypealiasTemplate(name: name, type: type, acl: accessLevel)
    }
}
