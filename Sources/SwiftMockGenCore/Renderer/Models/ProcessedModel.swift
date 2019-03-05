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

struct ProcessedModel: Model {
    var name: String
    var longName: String
    var type: String
    var offset: Int64
    var nonOptionalOrRxVarList: [(offset: Int64, name: String, typeName: String)]
    
    init(_ ast: Structure, content: String) {
        self.name = ast.name
        self.longName = ast.name
        self.type = ast.typeName
        self.offset = ast.offset
        self.nonOptionalOrRxVarList = ast.substructures
            .filter { $0.isVariable &&
                !$0.isTypeNonOptional &&
                !$0.typeName.hasPrefix(ObservableVarPrefix) &&
                !$0.name.hasPrefix(UnderlyingVarPrefix) &&
                !$0.name.hasSuffix(CallCountSuffix) &&
                !$0.name.hasSuffix(ClosureVarSuffix)}
            .map{ ($0.offset, $0.name, $0.typeName) }
            .sorted {$0.offset < $1.offset}
    }
    
    func render(with identifier: String) -> String? {
        // This is intentional as this model has already been processed,
        // i.e. result has been rendered and can be retrieved without rendering.
        return nil
    }
}
