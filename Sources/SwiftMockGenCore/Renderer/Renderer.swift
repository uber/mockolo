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

func model(for element: Structure, content: String, processed: Bool = false) -> Model? {
    if processed {
        return ProcessedModel(element, content: content)
    }

    if element.isVariable {
        return VariableModel(element, content: content)
    } else if element.isMethod {
        return MethodModel(element, content: content)
    }
    
    return nil
}

func renderEntity(_ entity: [String: Model]) -> [String] {
    let result = entity.compactMap { (arg: (name: String, model: Model)) -> String? in
        return arg.model.render(with: arg.name)
    }
    return result
}
