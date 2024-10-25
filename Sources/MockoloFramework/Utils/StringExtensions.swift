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
@_spi(RawSyntax) import SwiftSyntax
@_spi(Diagnostics) import SwiftParser

extension Int {
    var tab: String {
        return String(repeating: "    ", count: self)
    }
}

extension String {
    static public let protocolDecl = "protocol ".data(using: .utf8)
    static public let classDecl = "class ".data(using: .utf8)

    static let `try` = "try"
    static let `throws` = "throws"
    static let `rethrows` = "rethrows"
    static let async = "async"
    static let await = "await"
    static let `inout` = "inout"
    static let hasBlankInit = "_hasBlankInit"
    static let `Self` = "Self"
    static let `static` = "static"
    static let importSpace = "import "
    static public let `class` = "class"
    static let `actor` = "actor"
    static let actorProtocol = "Actor"
    static public let `final` = "final"
    static let override = "override"
    static let privateSet = "private(set)"
    static let mockType = "protocol"
    static let unknownVal = "Unknown"
    static let prefix = "prefix"
    static let anyType = "Any"
    static let neverType = "Never"
    static let any = "any"
    static let some = "some"
    static let anyObject = "AnyObject"
    static let fatalError = "fatalError"
    static let available = "available"
    static let `public` = "public"
    static let `open` = "open"
    static let initializer = "init"
    static let argsHistorySuffix = "ArgValues"
    static let handlerSuffix = "Handler"
    static let observable = "Observable"
    static let rxObservable = "RxSwift.Observable"
    static let observableLeftAngleBracket = observable + "<"
    static let rxObservableLeftAngleBracket = rxObservable + "<"
    static let anyPublisher = "AnyPublisher"
    static let anyPublisherLeftAngleBracket = anyPublisher + "<"
    static let eraseToAnyPublisher = "eraseToAnyPublisher"
    static let passthroughSubject = "PassthroughSubject"
    static let currentValueSubject = "CurrentValueSubject"
    static let publishSubject = "PublishSubject"
    static let behaviorSubject = "BehaviorSubject"
    static let replaySubject = "ReplaySubject"
    static let replaySubjectCreate = ".create(bufferSize: 1)"
    static let behaviorRelay = "BehaviorRelay"
    static let variable = "Variable"
    static let empty = ".empty()"
    static let observableEmpty = "Observable.empty()"
    static let rxObservableEmpty = "RxSwift.Observable.empty()"
    static let `required` = "required"
    static let `convenience` = "convenience"
    static let closureArrow = "->"
    static let moduleColon = "module:"
    static let typealiasColon = "typealias:"
    static let combineColon = "combine:"
    static let rxColon = "rx:"
    static let varColon = "var:"
    static let historyColon = "history:"
    static let modifiersColon = "modifiers:"
    static let overrideColon = "override:"
    static let `typealias` = "typealias"
    static let annotationArgDelimiter = ";"
    static let subjectSuffix = "Subject"
    static let underlyingVarPrefix = "_"
    static let setCallCountSuffix = "SetCallCount"
    static let callCountSuffix = "CallCount"
    static let initializerLeftParen = "init("
    static let `escaping` = "@escaping"
    static let autoclosure = "@autoclosure"
    static let name = "name"
    static let sendable = "Sendable"
    static let uncheckedSendable = "@unchecked Sendable"
    static public let mockAnnotation = "@mockable"
    static public let mockObservable = "@MockObservable"
    static public let poundIf = "#if "
    static public let poundEndIf = "#endif"
    static public let headerDoc =
    """
    ///
    /// @Generated by Mockolo
    ///
    """

    var safeName: String {
        var text = self
        if let keyword = text.withSyntaxText(Keyword.init),
           TokenKind.keyword(keyword).isLexerClassifiedKeyword {
            return "`\(self)`"
        }
        return self
    }

    var withSpace: String {
        return "\(self) "
    }

    var withLeftAngleBracket: String {
        return "\(self)<"
    }

    var withRightAngleBracket: String {
        return "\(self)>"
    }

    var withColon: String {
        return "\(self):"
    }

    var withLeftParen: String {
        return "\(self)("
    }

    var withRightParen: String {
        return "\(self))"
    }

    mutating func withoutTrailingCharacters(_ characters: [String]) -> String {
        for character in characters {
            if hasSuffix(character) {
                _ = self.removeLast()
            }
        }
        return self
    }


    func canBeInitParam(type: String, isStatic: Bool) -> Bool {
        return !(isStatic || type == .unknownVal || type.hasPrefix(.anyPublisher) || (type.hasSuffix("?") && type.contains(String.closureArrow)) ||  isGenerated(type: SwiftType(type)))
    }

    func isGenerated(type: SwiftType) -> Bool {
          return self.hasPrefix(.underlyingVarPrefix) ||
              self.hasSuffix(.setCallCountSuffix) ||
              self.hasSuffix(.callCountSuffix) ||
              self.hasSuffix(.subjectSuffix) ||
              (self.hasSuffix(.handlerSuffix) && type.isOptional)
    }

    func arguments(with delimiter: String) -> [String: String]? {
        let argstr = self
        let args = argstr.components(separatedBy: delimiter)
        var argsMap = [String: String]()
        for item in args {
            let keyVal = item.components(separatedBy: "=").map{$0.trimmingCharacters(in: .whitespaces)}

            if let k = keyVal.first {
                if k.contains(":") {
                    break
                }

                if let v = keyVal.last {
                    argsMap[k] = v
                }
            }
        }
        return !argsMap.isEmpty ? argsMap : nil
    }
    
    func deletingPrefix(_ prefix: String) -> String {
        guard self.hasPrefix(prefix) else { return self }
        return String(self.dropFirst(prefix.count))
    }
}

let separatorsForDisplay = CharacterSet(charactersIn: "<>[] :,()_-.&@#!{}@+\"\'")
let separatorsForLiterals = CharacterSet(charactersIn: "?<>[] :,()_-.&@#!{}@+\"\'")

extension StringProtocol {
    var isNotEmpty: Bool {
        return !isEmpty
    }

    var capitalizeFirstLetter: String {
        return prefix(1).capitalized + dropFirst()
    }

    func shouldParse(with exclusionList: [String]) -> Bool {
        guard hasSuffix(".swift") else { return false }
        guard !exclusionList.isEmpty else { return true }

        if let name = components(separatedBy: ".swift").first {
            for ex in exclusionList {
                if name.hasSuffix(ex) {
                    return false
                }
            }
            return true
        }

        return false
    }

    var literalComponents: [String] {
        return self.components(separatedBy: separatorsForLiterals)
    }

    var displayableComponents: [String] {
        let ret = self.replacingOccurrences(of: "?", with: "Optional")
        return ret.components(separatedBy: separatorsForDisplay).filter {!$0.isEmpty}
    }

    var components: [String] {
        return self.components(separatedBy: separatorsForDisplay).filter {!$0.isEmpty}
    }

    var asTestableImport: String {
        return "@testable \(self.asImport)"
    }

    var asImport: String {
        return "import \(self)"
    }

    var moduleNameInImport: String {
        guard self.hasPrefix(String.importSpace) else { return "" }
        return self.dropFirst(String.importSpace.count).trimmingCharacters(in: .whitespaces)
    }
}
