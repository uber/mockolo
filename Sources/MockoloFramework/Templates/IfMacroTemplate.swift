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

extension IfMacroModel {
    func applyMacroTemplate(name: String,
                            useTemplateFunc: Bool,
                            useMockObservable: Bool,
                            mockFinal: Bool,
                            enableFuncArgsHistory: Bool,
                            entities: [Model]) -> String {
        let rendered = entities
            .compactMap {$0.render(with: $0.name, encloser: "", useTemplateFunc: useTemplateFunc, useMockObservable: useMockObservable, mockFinal: mockFinal, enableFuncArgsHistory: enableFuncArgsHistory) }
            .joined(separator: "\n")
        
        let template = """
        \(1.tab)#if \(name)
        \(rendered)
        \(1.tab)#endif
        """
        return template
    }
}
