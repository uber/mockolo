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
    var mediumName: String
    var mediumLongName: String
    var longName: String
    var fullName: String
    var offset: Int64
    let accessControlLevelDescription: String
    let attributes: [String]
    let defaultValue: String?
    let staticKind: String
    let genericTypeParams: [ParamModel]
    let params: [ParamModel]
    let handler: ClosureModel
    let processed: Bool
    
    init(_ ast: Structure, content: String, processed: Bool) {
        var comps = ast.name.components(separatedBy: CharacterSet(arrayLiteral: ":", "(", ")")).filter{!$0.isEmpty}
        let nameString = comps.removeFirst()
        self.name = nameString
        self.type = ast.typeName == UnknownVal ? "" : ast.typeName
        self.staticKind = ast.isStaticMethod ? .static : ""
        self.processed = processed
        self.offset = ast.offset
        let paramDecls = ast.substructures.filter{$0.isVarParameter}
        assert(paramDecls.count == comps.count)
        
        self.params = zip(paramDecls, comps).map { ParamModel($0, label: $1) }
        

        let paramNames = paramDecls.map {$0.name}
        let paramTypes = paramDecls.map {$0.typeName}
        self.genericTypeParams = ast.substructures
            .filter {$0.isGenericTypeParam}
            .map { ParamModel($0, label: $0.name, isGeneric: true) }
        let genericNameTypes = self.genericTypeParams.map { $0.name.capitlizeFirstLetter + $0.type.displayableForType }.joined()
        
        self.mediumName = self.name + genericNameTypes + paramNames.map{ nameString.lowercased().contains($0.lowercased()) ? "" :  $0.capitlizeFirstLetter}.joined()

        self.mediumLongName =  self.name + genericNameTypes + self.type.displayableForType

        self.longName = self.mediumName + self.type.displayableForType

        self.fullName = self.name + genericNameTypes +
            zip(paramNames, paramTypes).map{ nameString.lowercased().contains($0.lowercased()) ? "" :  $0.capitlizeFirstLetter + $1.displayableForType}.joined() +
            self.type.displayableForType
        
        self.handler = ClosureModel(name: self.name,
                                    mediumName: self.mediumName,
                                    mediumLongName: self.mediumLongName,
                                    longName: self.longName,
                                    fullName: self.fullName,
                                    genericTypeParams: genericTypeParams,
                                    paramNames: paramNames,
                                    paramTypes: paramTypes,
                                    returnType: ast.typeName,
                                    staticKind: staticKind)
        self.accessControlLevelDescription = ast.accessControlLevelDescription
        self.defaultValue = defaultVal(typeName: ast.typeName)
        self.attributes = ast.hasAvailableAttribute ? ast.extractAttributes(content, filterOn: SwiftDeclarationAttributeKind.available.rawValue) : []
    }
    
    func render(with identifier: String) -> String? {
        guard !processed else { return nil }
        let genericTypeDecls = genericTypeParams.compactMap {$0.render(with: "")}
        let paramDecls = params.compactMap{$0.render(with: "")}
        let returnType = type != UnknownVal ? type : ""
        let handlerName = (identifier == name ? handler.name :
            (identifier == mediumName ? handler.mediumName :
                (identifier == mediumLongName ? handler.mediumLongName :
                    (identifier == longName ? handler.longName :
                        handler.fullName))))
        let handlerReturn = handler.render(with: handlerName) ?? ""
        let result = applyMethodTemplate(name: name,
                                         identifier: identifier,
                                         genericTypeDecls: genericTypeDecls,
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
