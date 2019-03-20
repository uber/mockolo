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

/// Represents entities such as var, func, class, etc. to be
/// rendered (with templates) for mock output.
protocol Model {
    /// Identifier
    var name: String { get set }

    /// Decl(e.g. class/struct/protocol/enum) or return type (e.g. var/func)
    var type: String { get set }

    /// Offset where this type is declared
    var offset: Int64 { get set }

    /// Applies a corresponding template to this model to output mocks
    func render(with identifier: String) -> String?

    /// Used to differentiate multiple entities with the same name
    /// @param level The verbosity level
    /// @returns a unique name given the verbosity (default is name)
    func name(by level: Int) -> String
}

extension Model {
    func name(by level: Int) -> String {
        return name
    }
}
