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

    init(_ ast: Structure, filepath: String, data: Data, overrideTypes: [String: String]?, processed: Bool) {
        self.name = ast.name
        self.filePath = filepath
        self.offset = ast.offset
        self.length = ast.length
        self.typeOffset = ast.nameOffset + ast.nameLength + 1
        self.typeLength = ast.offset + ast.length - typeOffset
        self.accessLevel = ast.accessLevel
        self.processed = processed
        self.overrideTypes = overrideTypes
        self.modelDescription = ast.description
        // If there's an override typealias value, set it to type
        if let val = overrideTypes?[self.name] {
            self.type  = Type(val)
        } else {
            // Sourcekit doesn't give inheritance type info for an associatedtype, so need to manually parse it from the content
            if typeLength < 0 {
                self.type = Type(String.any)
            } else {
                let charset = CharacterSet(arrayLiteral: "=", ":").union(.whitespaces)
                let typeArg = data.toString(offset: typeOffset, length: typeLength).trimmingCharacters(in: charset)
                self.type = Type(typeArg)
            }
        }
    }

    var fullName: String {
        return self.name + self.type.displayName
    }
    
    func name(by level: Int) -> String {
        return fullName
    }
    
    func render(with identifier: String, encloser: String, useTemplateFunc: Bool = false, useMockObservable: Bool = false, enableFuncArgsHistory: Bool = false) -> String? {
        if processed || useDescription, let modelDescription = modelDescription?.trimmingCharacters(in: .whitespacesAndNewlines) {
            if addAcl {
                return "\(1.tab)\(accessLevel) \(modelDescription)"
            }
            return "\(1.tab)\(modelDescription)"
        }
        
        return applyTypealiasTemplate(name: name, type: type, acl: accessLevel)
    }
}
