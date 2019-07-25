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

/// Metadata containing unique models and potential init params ready to be rendered for output
struct ResolvedEntity {
    let key: String
    let entity: Entity
    let uniqueModels: [(String, Model)]
    let attributes: [String]
    let hasInit: Bool
    let initVars: [Model]?
    let typealiasWhitelist: [String: [String]]?
    
    func model() -> Model {
        return ClassModel(entity.ast,
                          content: entity.content,
                          identifier: key,
                          additionalAttributes: attributes,
                          needInit: !hasInit,
                          initParams: initVars,
                          typealiasWhitelist: typealiasWhitelist,
                          entities: uniqueModels)
    }
}

struct ResolvedEntityContainer {
    let entity: ResolvedEntity
    let imports: [(String, String)]
}



/// Metadata for a type being mocked
struct Entity {
    let name: String
    let filepath: String
    let content: String
    let ast: Structure
    let isAnnotated: Bool
    let metadata: [String: String]?
    let isProcessed: Bool
    
    var hasInit: Bool {
        return ast.substructures.filter(path: \.isInitializer).count > 0
    }
    
    func subModels() -> [Model] {
        return ast.substructures.compactMap { (child: Structure) -> Model? in
            return model(for: child, filepath: filepath, content: content, processed: isProcessed)
        }
    }
    
    func subAttributes() -> [String]? {
        if isProcessed {
            return nil
        }
        
        return ast.substructures.compactMap { (child: Structure) -> [String]? in
            return child.extractAttributes(content, filterOn: SwiftDeclarationAttributeKind.available.rawValue)
            }.flatMap {$0}
    }
    
    func model(for element: Structure, filepath: String, content: String, processed: Bool = false) -> Model? {
        if element.isVariable {
            return VariableModel(element, filepath: filepath, content: content, processed: processed)
        } else if element.isMethod {
            return MethodModel(element, filepath: filepath, content: content, processed: processed)
        } else if element.isAssociatedType {
            return TypeAliasModel(element, filepath: filepath, content: content, overrideTypes: metadata, processed: processed)
        }
        
        return nil
    }
}
