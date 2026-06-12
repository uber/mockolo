//
//  Copyright (c) 2026. Uber Technologies
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

/// Represents an attribute attached to a declaration, parsed from an `AttributeList`.
struct Attribute: Hashable {
    enum Kind: Hashable {
        /// Any attribute other than `@available` (e.g. `@objc`, `@MainActor`).
        case regular
        /// An `@available` that only affects usage diagnostics
        /// (e.g. `@available(*, deprecated)`); kept on the generated member.
        case behavioralAvailable
        /// An `@available` that gates the existence of the declaration
        /// (e.g. `@available(iOS 15.0, *)`, `introduced:`, `obsoleted:`,
        /// platform-scoped `unavailable`); hoisted to the mock declaration
        /// since the mock's infrastructure references the member's types
        /// unconditionally.
        case platformAvailable
    }

    /// Source text of the attribute, e.g. `@available(iOS 15.0, *)`.
    let description: String
    let kind: Kind

    var isAvailable: Bool { kind != .regular }

    var isBehavioralAvailable: Bool { kind == .behavioralAvailable }

    var isPlatformAvailable: Bool { kind == .platformAvailable }
}
