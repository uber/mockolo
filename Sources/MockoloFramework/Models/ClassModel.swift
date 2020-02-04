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

final class ClassModel: Model {
    var name: String
    var offset: Int64
    var type: Type
    let attribute: String
    let accessControlLevelDescription: String
    let identifier: String
    let declType: DeclType
    let entities: [(String, Model)]
    let typealiasWhitelist: [String: [String]]?
    var modelType: ModelType {
        return .class
    }
    
    init(identifier: String,
         acl: String,
         declType: DeclType,
         attributes: [String],
         offset: Int64,
         typealiasWhitelist: [String: [String]]?,
         entities: [(String, Model)]) {
        self.identifier = identifier 
        self.name = identifier + "Mock"
        self.type = Type(.class)
        self.declType = declType
        self.entities = entities
        self.offset = offset
        self.attribute = Set(attributes.filter {$0.contains(String.available)}).joined(separator: " ")
        self.accessControlLevelDescription = acl.isEmpty ? "" : acl + " "
        self.typealiasWhitelist = typealiasWhitelist
    }
    
    func render(with identifier: String, typeKeys: [String: String]? = nil) -> String? {
        return applyClassTemplate(name: name, identifier: self.identifier, typeKeys: typeKeys, accessControlLevelDescription: accessControlLevelDescription, attribute: attribute, declType: declType, typealiasWhitelist: typealiasWhitelist, entities: entities)
    }
}
