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

public enum MethodKind: Equatable {
    case funcKind
    case initKind(required: Bool, override: Bool)
    case subscriptKind
}

final class MethodModel: Model {
    var filePath: String = ""
    var data: Data? = nil
    var name: String
    var type: Type
    var offset: Int64
    let length: Int64
    let accessLevel: String
    var attributes: [String]? = nil
    let genericTypeParams: [ParamModel]
    let params: [ParamModel]
    let processed: Bool
    var modelDescription: String? = nil
    var isStatic: Bool
    let shouldOverride: Bool
    let suffix: String
    let kind: MethodKind
    let funcsWithArgsHistory: [String]
    var modelType: ModelType {
        return .method
    }
    
    private var staticKind: String {
        return isStatic ? .static : ""
    }
    
    var isInitializer: Bool {
        if case .initKind(_, _) = kind {
            return true
        }
        return false
    }
    
    var isSubscript: Bool {
        if case .subscriptKind = kind {
            return true
        }
        return false
    }
    
    lazy var signatureComponents: [String] = {
        let paramLabels = self.params.map {$0.label != "_" ? $0.label : ""}
        let paramNames = self.params.map(path: \.name)
        let paramTypes = self.params.map(path: \.type)
        let nameString = self.name
        var args = zip(paramLabels, paramNames).compactMap { (argLabel: String, argName: String) -> String? in
            let val = argLabel.isEmpty ? argName : argLabel
            if val.count < 2 || !nameString.lowercased().hasSuffix(val.lowercased()) {
                return val.capitlizeFirstLetter
            }
            return nil
        }
        
        let genericTypeNames = self.genericTypeParams.map { $0.name.capitlizeFirstLetter + $0.type.displayName }
        args.append(contentsOf: genericTypeNames)
        
        args.append(contentsOf: paramTypes.map(path: \.displayName))
        var displayType = self.type.displayName
        let capped = min(displayType.count, 32)
        displayType.removeLast(displayType.count-capped)
        args.append(displayType)
        args.append(self.staticKind)
        let ret = args.filter{ arg in !arg.isEmpty }
        return ret
    }()
    
    lazy var argsHistory: ArgumentsHistoryModel? = {
        if isInitializer || isSubscript {
            return nil
        }

        let ret = ArgumentsHistoryModel(name: name,
                                        genericTypeParams: genericTypeParams,
                                        params: params,
                                        isHistoryAnnotated: funcsWithArgsHistory.contains(name),
                                        suffix: suffix)
        
        return ret
    }()

    func handler(encloser: String) -> ClosureModel? {
        if isInitializer {
            return nil
        }
        
        let paramNames = self.params.map(path: \.name)
        let paramTypes = self.params.map(path: \.type)
        let ret = ClosureModel(name: name,
                               genericTypeParams: genericTypeParams,
                               paramNames: paramNames,
                               paramTypes: paramTypes,
                               suffix: suffix,
                               returnType: type,
                               encloser: encloser)
        
        return ret
    }
    
    
    init(name: String,
         typeName: String,
         kind: MethodKind,
         encloserType: DeclType,
         acl: String,
         genericTypeParams: [ParamModel],
         params: [ParamModel],
         throwsOrRethrows: String,
         isStatic: Bool,
         offset: Int64,
         length: Int64,
         funcsWithArgsHistory: [String],
         modelDescription: String?,
         processed: Bool) {
        self.name = name.trimmingCharacters(in: .whitespaces)
        self.type = Type(typeName.trimmingCharacters(in: .whitespaces))
        self.suffix = throwsOrRethrows
        self.offset = offset
        self.length = length
        self.kind = kind
        self.isStatic = isStatic
        self.shouldOverride = encloserType == .classType
        self.params = params
        self.genericTypeParams = genericTypeParams
        self.processed = processed
        self.funcsWithArgsHistory = funcsWithArgsHistory
        self.modelDescription = modelDescription
        self.accessLevel = acl
    }
    
    var fullName: String {
        return self.name + self.signatureComponents.joined() + staticKind
    }
    
    func name(by level: Int) -> String {
        if level <= 0 {
            return name
        }
        let diff = level - self.signatureComponents.count
        let postfix = diff > 0 ? String(diff) : self.signatureComponents[level - 1]
        return name(by: level - 1) + postfix
    }
    
    func render(with identifier: String, encloser: String, useTemplateFunc: Bool, useMockObservable: Bool, mockFinal: Bool = false, enableFuncArgsHistory: Bool) -> String? {
        if processed {
            var prefix = shouldOverride  ? "\(String.override) " : ""

            if case .initKind(required: let isRequired, override: _) = self.kind {
                if isRequired {
                    prefix = ""
                }
            }
            
            if let ret = modelDescription?.trimmingCharacters(in: .newlines) ?? self.data?.toString(offset: offset, length: length) {
                return prefix + ret
            }
            return nil
        }
        
        let result = applyMethodTemplate(name: name,
                                         identifier: identifier,
                                         kind: kind,
                                         useTemplateFunc: useTemplateFunc,
                                         enableFuncArgsHistory: enableFuncArgsHistory,
                                         isStatic: isStatic,
                                         isOverride: shouldOverride,
                                         genericTypeParams: genericTypeParams,
                                         params: params,
                                         returnType: type,
                                         accessLevel: accessLevel,
                                         suffix: suffix,
                                         argsHistory: argsHistory,
                                         handler: handler(encloser: encloser))
        return result
    }
}
