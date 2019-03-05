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

struct MethodModel: Model {
    var name: String
    var type: String
    var longName: String
    var offset: Int64 = .max
    var useLongName: Bool = false
    let accessControlLevelDescription: String
    let attributes: [String]
    let defaultValue: String?
    let staticKind: String
    let params: [ParamModel]
    let handler: ClosureModel
    
    init(_ ast: Structure, content: String) {
        var nameComps = ast.name.components(separatedBy: CharacterSet(arrayLiteral: ":", "(", ")")).filter{!$0.isEmpty}
        self.name = nameComps.removeFirst()
        self.type = ast.typeName == UnknownVal ? "" : ast.typeName  
        self.staticKind = ast.isStaticMethod ? StaticKindString : ""
        
        let paramDecls = ast.substructures.filter{$0.isVarParameter}
        assert(paramDecls.count == nameComps.count)
        
        self.params = zip(paramDecls, nameComps).map { ParamModel($0, label: $1) }
        
        let paramTypes = paramDecls.map {$0.typeName}
        let paramNames = paramDecls.map {$0.name}

        self.longName = self.name + paramNames.map{$0.capitlizeFirstLetter()}.joined()

        self.handler = ClosureModel(name: name, longName: longName, paramNames: paramNames, paramTypes: paramTypes, returnType: ast.typeName, staticKind: staticKind)
        self.accessControlLevelDescription = ast.accessControlLevelDescription
        self.defaultValue = defaultVal(typeName: ast.typeName)
        self.attributes = ast.hasAvailableAttribute ? ast.extractAttributes(content, filterOn: SwiftDeclarationAttributeKind.available.rawValue) : []
    }
    
    func render(with identifier: String) -> String? {
        let paramDecls = params.compactMap{$0.render(with: "")}
        let returnType = type != UnknownVal ? type : ""
        let handlerName = name == identifier ? handler.name : handler.longName
        let handlerReturn = handler.render(with: handlerName) ?? ""
        let result = applyMethodTemplate(name: name,
                                         identifier: identifier,
                                         paramDecls: paramDecls,
                                         returnType: returnType,
                                         staticKind: staticKind,
                                         accessControlLevelDescription: accessControlLevelDescription,
                                         handlerVarName: handlerName,
                                         handlerVarType: handler.type,
                                         handlerReturn: handlerReturn)
        return result
    }
}
