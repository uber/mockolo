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

final class IfMacroModel: Model {
    let name: String
    let offset: Int64
    let entities: [Model]

    var modelType: ModelType {
        return .macro
    }

    var fullName: String {
        return entities.map {$0.fullName}.joined(separator: "_")
    }
    
    init(name: String,
         offset: Int64,
         entities: [Model]) {
        self.name = name
        self.entities = entities
        self.offset = offset
    }
    
    func render(
        context: RenderContext,
        arguments: GenerationArguments
    ) -> String? {
        return applyMacroTemplate(
            name: name,
            context: context,
            arguments: arguments,
            entities: entities
        )
    }
}
