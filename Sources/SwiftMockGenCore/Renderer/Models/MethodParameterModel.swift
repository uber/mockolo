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

struct ParamModel: Model {
    var name: String
    var longName: String
    var fullName: String
    var offset: Int64 = .max
    var type: String
    let label: String?
    init(_ ast: Structure, label: String) {
        self.name = ast.name
        self.longName = self.name
        self.fullName = self.name
        self.type = ast.typeName
        self.label = self.name != label ? label: nil
    }
    
    func render(with identifier: String) -> String? {
        var labelStr = ""
        if let label = label {
            labelStr = "\(label) "
        }
        return "\(labelStr)\(name): \(type)"
    }
}
