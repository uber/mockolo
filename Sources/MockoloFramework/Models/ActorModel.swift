/// 
/// Copyright (c) 2023 Uber Technologies
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

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
