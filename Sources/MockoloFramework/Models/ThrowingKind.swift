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

enum ThrowingKind: Equatable {
    case none
    case any
    case `rethrows`
    case typed(errorType: String)

    var hasError: Bool {
        switch self {
        case .none:
            return false
        case .any:
            return true
        case .rethrows:
            return true
        case .typed(let errorType):
            return errorType != .neverType && errorType != "Swift.\(String.neverType)"
        }
    }
}

extension ThrowingKind {
    /// Replace rethrows with throws.
    var coerceRethrowsToThrows: ThrowingKind {
        if case .rethrows = self {
            return .any
        }
        return self
    }
}
