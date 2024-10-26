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

final class ParamModel: Model {
    var name: String
    var offset: Int64
    var length: Int64
    var type: SwiftType
    let label: String
    let isGeneric: Bool
    let inInit: Bool
    let needVarDecl: Bool

    var isStatic: Bool {
        return false
    }
    
    var modelType: ModelType {
        return .parameter
    }

    var fullName: String {
        return label + "_" + name
    }
    
    init(label: String = "", name: String, typeName: String, isGeneric: Bool = false, inInit: Bool = false, needVarDecl: Bool, offset: Int64, length: Int64) {
        self.name = name.trimmingCharacters(in: .whitespaces)
        self.type = SwiftType(typeName.trimmingCharacters(in: .whitespaces))
        let labelStr = label.trimmingCharacters(in: .whitespaces)
        self.label = name != labelStr ? labelStr : ""
        self.offset = offset
        self.length = length
        self.isGeneric = isGeneric
        self.inInit = inInit
        self.needVarDecl = needVarDecl
    }
    
    var underlyingName: String {
        return "_\(name)"
    }

    /// - Parameters:
    ///     - eraseType:
    ///         If other initializers in decl has same name as this param and type is different from each other,
    ///         please pass `True` to this parameter. Default value is `false`.
    ///
    /// ```
    ///     protocol A {
    ///         init(param: String)
    ///         init(param: any Sequence<Character>)
    ///     }
    ///     class B: A {
    ///         var param: Any! // NOTE: type erasing
    ///         init () {}
    ///         required init(param: String) {
    ///           self.param = param
    ///         }
    ///         required init(param: any Sequence<Character>) {
    ///             self.param = param
    ///         }
    ///     }
    /// ```
    func asInitVarDecl(eraseType: Bool) -> String? {
        if self.inInit, self.needVarDecl {
            let type: SwiftType
            if eraseType {
                type = SwiftType(.anyType)
            } else {
                type = self.type
            }
            return applyVarTemplate(type: type)
        }
        return nil
    }
    
    func render(with identifier: String, encloser: String, useTemplateFunc: Bool = false, useMockObservable: Bool = false, allowSetCallCount: Bool = false, mockFinal: Bool = false,  enableFuncArgsHistory: Bool = false, disableCombineDefaultValues: Bool = false) -> String? {
        return applyParamTemplate(name: name, label: label, type: type, inInit: inInit)
    }
}
