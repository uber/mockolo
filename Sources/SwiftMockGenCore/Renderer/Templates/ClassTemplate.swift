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
                        accessControlLevelDescription: String,
                        attribute: String,
                        initParams: [VarWithOffset],
                        entities: [String]) -> String {
    
    let params = initParams.map { (offset: Int64, name: String, typeName: String) -> String in
        if let val = defaultVal(typeName: typeName) {
            return "\(name): \(typeName) = \(val)"
        }
        return "\(name): \(typeName)"
    }.joined(separator: ", ")

    let paramsAssign = initParams.map { "self.\($0.name) = \($0.name)" }.joined(separator: "\n")
    let result = """
    \(attribute)
    \(accessControlLevelDescription)class \(name): \(identifier) {
        \(accessControlLevelDescription)init(\(params)) {
            \(paramsAssign)
        }
        \(entities.joined(separator: "\n"))
    }
    """
    return result
}
