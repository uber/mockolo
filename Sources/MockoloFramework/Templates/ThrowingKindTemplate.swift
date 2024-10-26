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

extension ThrowingKind {
    /// if this method is called to render handler for closure, rethrows should be replaced with throws.
    ///
    /// - example:
    ///     ```
    ///     // handler shouldn't use rethrows, instead use throws
    ///     var fooHandler: (() -> throws -> Void) throws -> Void
    ///     func foo(bar: () throws -> Void) rethrows -> Void
    ///     ```
    func applyThrowingTemplate(
        appliesforClosureHandler: Bool
    ) -> String {
        switch self {
        case .none:
            return ""
        case .any:
            return .throws
        case .rethrows:
            if appliesforClosureHandler {
                return .throws
            }
            return .rethrows
        case .typed(let errorType):
            return "\(String.throws)(\(errorType))"
        }
    }
}
