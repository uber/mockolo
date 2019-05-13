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

func applyClassTemplate(name: String,
                        identifier: String,
                        typeKeys: [String: String]?,
                        accessControlLevelDescription: String,
                        attribute: String,
                        needInit: Bool,
                        initParams: [VariableModel]?,
                        entities: [(String, Model)]) -> String {
    
    var initTemplate = ""
    if needInit {
        var extraInitBlock = ""
        var paramsAssign = ""
        var params = ""
        if let initParams = initParams, !initParams.isEmpty {
            params = initParams
                .map { (element: VariableModel) -> String in
                    
                    if let val = processDefaultVal(typeName: element.type, typeKeys: typeKeys, initParam: true), !val.isEmpty {
                        return "\(element.name): \(element.type) = \(val)"
                    }
                    var prefix = ""
                    if element.isClosureVariable {
                        prefix = String.escaping + " "
                    }
                    return "\(element.name): \(prefix)\(element.type)"
                }
                .joined(separator: ", ")
            
            // Besides the default init, we want to provide an empty init block (unless the default init is empty)
            // since vars do not need to be set via init (since they all have get/set; see VariableTemplate for more detail)
            extraInitBlock = "\(accessControlLevelDescription)init() {}"
            paramsAssign = initParams.map { "self.\($0.name) = \($0.name)" }.joined(separator: "\n")
        }
        
        initTemplate =
        """
        \(extraInitBlock)
        \(accessControlLevelDescription)init(\(params)) {
            \(paramsAssign)
        }
        """
    }
    
    let renderedEntities = entities
        .compactMap { (name: String, model: Model) -> String? in
            return model.render(with: name, typeKeys: typeKeys)
    }.joined(separator: "\n")
    
    let template =
    """
    \(attribute)
    \(accessControlLevelDescription)class \(name): \(identifier) {
        \(initTemplate)
        \(renderedEntities)
    }
    """
    return template
}
