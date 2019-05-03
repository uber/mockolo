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

struct ClassModel: Model {
    var name: String
    var offset: Int64
    var type: String
    let attribute: String
    let accessControlLevelDescription: String
    let identifier: String
    let entities: [(String, Model)]
    let initParams: [VariableModel]?

    init(_ ast: Structure,
         content: String,
         identifier: String,
         additionalAttributes: [String],
         initParams: [VariableModel]?,
         entities: [(String, Model)]) {
        self.identifier = identifier
        self.name = identifier + "Mock"
        self.type = .class
        self.entities = entities
        self.initParams = initParams
        self.offset = ast.offset
        var mutableAttributes = additionalAttributes
        let curAttributes = ast.extractAttributes(content, filterOn: SwiftDeclarationAttributeKind.available.rawValue)
        mutableAttributes.append(contentsOf: curAttributes)
        let attributeSet = Set(mutableAttributes)
        self.attribute = attributeSet.joined(separator: " ")
        self.accessControlLevelDescription = ast.accessControlLevelDescription.isEmpty ? "" : ast.accessControlLevelDescription + " "
    }
    
    func render(with identifier: String, typeKeys: [String: String]? = nil) -> String? {
        return applyClassTemplate(name: name, identifier: self.identifier, typeKeys: typeKeys, accessControlLevelDescription: accessControlLevelDescription, attribute: attribute, initParams: initParams, entities: entities)
    }
}
