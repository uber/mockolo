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

struct ClosureModel: Model {
    var name: String
    var type: String
    let nameSuffix = "Handler"
    var longName: String
    var fullName: String
    var offset: Int64 = .max
    let defaultValue: String
    let defaultReturnType: String
    let staticKind: String
    let paramNames: [String]
    let paramTypes: [String]
    
    init(name: String, longName: String, fullName: String, paramNames: [String], paramTypes: [String], returnType: String, staticKind: String) {
        self.name = name + nameSuffix
        self.longName = longName + nameSuffix
        self.fullName = fullName + nameSuffix
        let paramStr = paramTypes.joined(separator: ", ")
        let returnStr = returnType == UnknownVal ? "" : returnType  
        self.type = "((" + paramStr + ") -> (" + returnStr + "))?"
        self.defaultReturnType = returnType
        self.defaultValue = "nil"
        self.staticKind = staticKind
        self.paramNames = paramNames
        self.paramTypes = paramTypes
    }
    
    func render(with identifier: String) -> String? {
        return applyClosureTemplate(name: identifier, type: type, paramVals: paramNames, paramTypes: paramTypes, returnDefaultVal: defaultValue, returnDefaultType: defaultReturnType)
    }
}
