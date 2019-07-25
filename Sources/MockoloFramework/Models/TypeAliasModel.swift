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


struct TypeAliasModel: Model {
    var name: String
    var type: String
    var offset: Int64 = .max
    var length: Int64
    var typeOffset: Int64
    var typeLength: Int64
    let accessControlLevelDescription: String
    let processed: Bool
    let content: String
    let overrideTypes: [String: String]?
    
    var modelType: ModelType {
        return .typeAlias
    }

    init(_ ast: Structure, content: String, overrideTypes: [String: String]?, processed: Bool) {
        self.name = ast.name
        self.offset = ast.offset
        self.length = ast.length
        self.typeOffset = ast.nameOffset + ast.nameLength + 1
        self.typeLength = ast.offset + ast.length - typeOffset
        self.accessControlLevelDescription = ast.accessControlLevelDescription
        self.processed = processed
        self.content = content
        self.overrideTypes = overrideTypes
        // If there's an override typealias value, set it to type
        if let val = overrideTypes?[self.name] {
            self.type  = val
        } else {
            // Sourcekit doesn't give inheritance type info for an associatedtype, so need to manually parse it from the content
            if typeLength < 0 {
                self.type = String.any
            } else {
                self.type = content.extract(offset: typeOffset, length: typeLength).trimmingCharacters(in: CharacterSet.whitespaces)
            }
        }
    }

    var fullName: String {
        return self.name + self.type.displayableForType
    }
    
    func name(by level: Int) -> String {
        return fullName
    }
    
    func render(with identifier: String, typeKeys: [String: String]? = nil) -> String? {
        var acl = self.accessControlLevelDescription
        if !acl.isEmpty {
            acl = acl + " "
        }
        
        let ret = """
            \(acl)\(String.typealias) \(self.name) = \(self.type)
        """
        return ret
    }
}
