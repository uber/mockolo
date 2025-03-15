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

final class NominalModel: Model {
    let name: String
    let namespaces: [String]
    let offset: Int64
    let inheritedTypeName: String
    let type: SwiftType
    let attribute: String
    let accessLevel: String
    let declKindOfMockAnnotatedBaseType: NominalTypeDeclKind
    let entities: [(String, Model)]
    let initParamCandidates: [VariableModel]
    let declaredInits: [MethodModel]
    let declKind: NominalTypeDeclKind
    let requiresSendable: Bool

    var modelType: ModelType {
        return .nominal
    }
    
    init(name: String,
         namespaces: [String],
         acl: String,
         declKindOfMockAnnotatedBaseType: NominalTypeDeclKind,
         declKind: NominalTypeDeclKind,
         attributes: [String],
         offset: Int64,
         inheritedTypeName: String,
         initParamCandidates: [VariableModel],
         declaredInits: [MethodModel],
         entities: [(String, Model)],
         requiresSendable: Bool) {
        self.name = name
        self.type = SwiftType(self.name)
        self.namespaces = namespaces
        self.declKindOfMockAnnotatedBaseType = declKindOfMockAnnotatedBaseType
        self.declKind = declKind
        self.entities = entities
        self.declaredInits = declaredInits
        self.initParamCandidates = initParamCandidates
        self.offset = offset
        self.inheritedTypeName = inheritedTypeName
        self.attribute = Set(attributes.filter {$0.contains(String.available)}).joined(separator: " ")
        self.accessLevel = acl
        self.requiresSendable = requiresSendable
    }
    
    func render(
        context: RenderContext,
        arguments: GenerationArguments
    ) -> String? {
        return applyNominalTemplate(
            name: name,
            accessLevel: accessLevel,
            attribute: attribute,
            metadata: context.metadata,
            arguments: arguments,
            initParamCandidates: initParamCandidates,
            declaredInits: declaredInits,
            entities: entities
        )
    }
}
