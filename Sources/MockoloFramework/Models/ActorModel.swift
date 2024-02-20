//
//  ActorModel.swift
//  MockoloFramework
//
//  Created by treastrain on 2023/03/04.
//

import Foundation

final class ActorModel: Model {
    var name: String
    var offset: Int64
    var type: Type
    let attribute: String
    let accessLevel: String
    let identifier: String
    let declType: DeclType
    let entities: [(String, Model)]
    let initParamCandidates: [Model]
    let declaredInits: [MethodModel]
    let metadata: AnnotationMetadata?
    
    var modelType: ModelType {
        return .actor
    }
    
    init(identifier: String,
         acl: String,
         declType: DeclType,
         attributes: [String],
         offset: Int64,
         metadata: AnnotationMetadata?,
         initParamCandidates: [Model],
         declaredInits: [MethodModel],
         entities: [(String, Model)]) {
        self.identifier = identifier
        self.name = identifier + "Mock"
        self.type = Type(.actor)
        self.declType = declType
        self.entities = entities
        self.declaredInits = declaredInits
        self.initParamCandidates = initParamCandidates
        self.metadata = metadata
        self.offset = offset
        self.attribute = Set(attributes.filter {$0.contains(String.available)}).joined(separator: " ")
        self.accessLevel = acl
    }
    
    func render(with identifier: String, encloser: String, useTemplateFunc: Bool, useMockObservable: Bool, allowSetCallCount: Bool, mockFinal: Bool, enableFuncArgsHistory: Bool, disableCombineDefaultValues: Bool) -> String? {
        return applyActorTemplate(name: name, identifier: self.identifier, accessLevel: accessLevel, attribute: attribute, declType: declType, metadata: metadata, useTemplateFunc: useTemplateFunc, useMockObservable: useMockObservable, allowSetCallCount: allowSetCallCount, mockFinal: mockFinal, enableFuncArgsHistory: enableFuncArgsHistory, disableCombineDefaultValues: disableCombineDefaultValues, initParamCandidates: initParamCandidates, declaredInits: declaredInits, entities: entities)
    }
}
