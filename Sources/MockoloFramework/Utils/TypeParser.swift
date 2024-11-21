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

fileprivate var validIdentifierChars: CharacterSet = {
    var valid = CharacterSet.alphanumerics
    valid.insert(charactersIn: "_.")
    return valid
}()

/// Decl(e.g. class/struct/protocol/enum) or return type (e.g. var/func)
public final class SwiftType {
    let typeName: String
    let cast: String?
    var cachedDefaultVal: String?

    init(_ type: String, cast: String? = nil){
        self.typeName = type == .unknownVal ? "" : type
        self.cast = cast
    }

    var isInOut: Bool {
        return typeName.hasPrefix(String.inout)
    }

    var isAutoclosure: Bool {
        return typeName.hasPrefix(String.autoclosure)
    }

    var isOpaqueType: Bool {
        typeName.contains(String.some + " ")
    }

    var isRxObservable: Bool {
        return typeName.hasPrefix(.rxObservableLeftAngleBracket) || typeName.hasPrefix(.observableLeftAngleBracket)
    }

    var isUnknown: Bool {
        return typeName.isEmpty || typeName == String.unknownVal
    }

    var isOptional: Bool {
        if !typeName.hasSuffix("?") {
            return false
        }
        let sliceLast = typeName.index(before: typeName.endIndex)
        let slice = typeName[typeName.startIndex..<sliceLast]
        let sub = SwiftType(String(slice))
        return sub.isSingular
    }

    /// Returns true if this type is Implicitly Unwrapped Optional
    var isIUO: Bool {
        if !typeName.hasSuffix("!") {
            return false
        }
        let sliceLast = typeName.index(before: typeName.endIndex)
        let slice = typeName[typeName.startIndex..<sliceLast]
        let sub = SwiftType(String(slice))
        return sub.isSingular
    }

    var base: String {
        if isOptional || isIUO {
            return String(typeName.dropLast(1))
        }
        return typeName
    }

    var underlyingType: String {
        var ret = typeName

        // If @escaping, remove as it can only be used for a func parameter.
        if isEscaping, let escapeRemoved = ret.components(separatedBy: String.escaping).last?.trimmingCharacters(in: .whitespaces) {
            ret = escapeRemoved
        }

        // Use force unwrapped for the underlying type so it doesn't always have to be set in the init (need to allow blank init).
        if hasClosure || hasExistentialAny {
            ret = "(\(ret))!"
        } else {
            if isOptional {
                ret.removeLast()
            }
            if !isIUO {
                ret.append("!")
            }
        }

        return ret
    }

    /// Returns true if this type is a single atomic type (e.g. an identifier, a tuple, etc).
    /// If it can be split into an input / output, e.g. T -> U, it will return false.
    /// Note that (T -> U) will be considered atomic, but T -> U won't.
    var isSingular: Bool {
        if typeName.hasPrefix("@") {
            return false
        }

        if isIdentifier {
            return true
        }

        if hasClosure {
            if splitByClosure {
                return false
            }
            return true
        }

        return isValidBracketed || isValidParened
    }

    var hasClosure: Bool {
        return typeName.range(of: String.closureArrow) != nil
    }

    var hasExistentialAny: Bool {
        return typeName.hasPrefix(.any)
    }

    var isEscaping: Bool {
        return typeName.hasPrefix(String.escaping)
    }

    var isSelf: Bool {
        return typeName == String.`Self`
    }

    var splitByClosure: Bool {
        let arg = typeName
        if let closureOpRange = arg.range(of: String.closureArrow) {
            let leftHalf = String(arg[arg.startIndex..<closureOpRange.lowerBound])
            let rightHalf = String(arg[arg.index(after: closureOpRange.upperBound)..<arg.endIndex])

            let l = SwiftType(leftHalf)
            let r = SwiftType(rightHalf)

            if l.isSingular || r.isSingular {
                return true
            }
        }
        return false
    }

    var isParened: Bool {
        return typeName.hasPrefix("(") && typeName.hasSuffix(")")
    }

    var isBracketed: Bool {
        return typeName.hasSuffix(">") || typeName.hasSuffix("]")
    }

    var isValidBracketed: Bool {
        return isBracketed && hasValidBrackets
    }
    var isValidParened: Bool {
        return isParened && hasValidParens
    }

    var displayName: String {
        return typeName.displayableComponents.map{$0 == .unknownVal ? "" : $0.capitalizeFirstLetter}.joined()
    }

    var isIdentifier: Bool {
        if isUnknown {
            return false
        }

        var typeName = typeName
        if typeName.hasPrefix(.any.withSpace) {
            typeName.removeFirst(String.any.withSpace.count)
        }

        for scalar in typeName.unicodeScalars {
            if scalar == " " {
                return false
            }

            if !validIdentifierChars.contains(scalar) && !scalar.properties.isEmoji {
                return false
            }
        }

        return true
    }

    var hasValidBrackets: Bool {
        let arg = typeName
        if let _ = arg.rangeOfCharacter(from: CharacterSet(arrayLiteral: "<", "["), options: [], range: nil) {
            let scalars = arg.unicodeScalars
            let suffix = scalars.last!
            var angleBracketCount = 0
            var squareBracketCount = 0
            for s in scalars {
                if s == "<" {
                    angleBracketCount += 1
                }
                if s == ">" {
                    angleBracketCount -= 1
                    if angleBracketCount < 0 {
                        return false
                    }
                }
                if s == "[" {
                    squareBracketCount += 1
                }
                if s == "]" {
                    squareBracketCount -= 1
                    if squareBracketCount < 0 {
                        return false
                    }
                }
            }

            if squareBracketCount == 0, angleBracketCount == 0, suffix == ">" || suffix == "]" {
                return true
            }
        }

        return false
    }

    var hasValidParens: Bool {
        let arg = typeName
        if  let _ = arg.rangeOfCharacter(from: CharacterSet(arrayLiteral: "("), options: [], range: nil) {
            let scalars = arg.unicodeScalars
            let prefix = scalars.first!
            let suffix = scalars.last!
            var count = 0
            for s in scalars {
                if s == prefix, s != "(" {
                    return false
                }
                if s == suffix, s != ")" {
                    return false
                }

                if s == "(" {
                    count += 1
                }
                if s == ")" {
                    count -= 1
                    if count < 0 {
                        return false
                    }
                }
            }

            if count == 0 {
                return true
            }
        }
        return false
    }


    var tupleComponents: [String] {
        let arg = typeName
        let scalars = arg.unicodeScalars
        var count = 0
        var inBracket = false
        var start = scalars.startIndex
        var components = [String]()
        var bracket = BracketType.angle

        for pos in scalars.indices {
            let s = scalars[pos]

            if !inBracket {
                if s == "," || s == ")" {
                    let comps = scalars[start..<pos]
                    let comp = String(comps)
                    components.append(comp)
                    components.append(String(s))
                    start = scalars.index(pos, offsetBy: 1)
                } else if s == "(" {
                    components.append(String(s))
                    start = scalars.index(pos, offsetBy: 1)
                } else if s == ":" || s == "=" || s == " " {
                    start = scalars.index(pos, offsetBy: 1)
                }
            }

            if s == "<" {
                if !inBracket {
                    bracket = .angle
                    inBracket = true
                }

                if bracket == .angle {
                    count += 1
                }
            }
            if s == ">", bracket == .angle {
                count -= 1
                if count == 0 {
                    inBracket = false
                }
            }

            if s == "["  {
                if !inBracket {
                    bracket = .square
                    inBracket = true
                }

                if bracket == .square {
                    count += 1
                }
            }
            if s == "]", bracket == .square {
                count -= 1
                if count == 0 {
                    inBracket = false
                }
            }
        }

        if start != scalars.endIndex {
            let comps = scalars[start..<scalars.endIndex]
            let comp = String(comps)
            components.append(comp)
        }

        return components
    }


    /// Parses a type string containing (nested) tuples or brackets and returns a default value for each type component
    ///
    ///  if nil, no default val available
    ///  if "nil", type is optional
    ///  if "non-nil", type is non-optional
    ///  if "", type is String, with an empty string value
    func defaultVal(with overrides: [String: String]? = nil, overrideKey: String = "", isInitParam: Bool = false) -> String? {
        if let val = cachedDefaultVal {
            return val
        }

        let (subjectType, typeParam, subjectVal) = parseRxVar(overrides: overrides, overrideKey: overrideKey, isInitParam: isInitParam)
        if subjectType != nil {
            let prefix = typeName.hasPrefix(String.rxObservableLeftAngleBracket) ? String.rxObservableLeftAngleBracket : String.observableLeftAngleBracket
            var rxEmpty = String.observableEmpty
            if let t = typeParam {
                rxEmpty = "\(prefix)\(t)>.empty()"
            }
            cachedDefaultVal = isInitParam ? subjectVal : rxEmpty
            return cachedDefaultVal
        }

        if let val = parseDefaultVal(isInitParam: isInitParam) {
            cachedDefaultVal = val
            return cachedDefaultVal
        }

        // There is no "existential any" to the customDefaultValueMap key.
        if let val = SwiftType.customDefaultValueMap?[typeName.removingExistentialAny] {
            cachedDefaultVal = val
            return val
        }
        return nil
    }

    func parseRxVar(overrides: [String: String]?, overrideKey: String, isInitParam: Bool) -> (String?, String?, String?) {
        if typeName.hasPrefix(String.observableLeftAngleBracket) || typeName.hasPrefix(String.rxObservableLeftAngleBracket),
            let range = typeName.range(of: String.observableLeftAngleBracket), let lastIdx = typeName.lastIndex(of: ">") {
            let typeParamStr = typeName[range.upperBound..<lastIdx]

            var subjectKind = ""
            var underlyingSubjectType = ""
            if let rxTypes = overrides {
                if let val = rxTypes[overrideKey], val.hasSuffix(String.subjectSuffix) {
                    subjectKind = val
                } else if let val = rxTypes["all"], val.hasSuffix(String.subjectSuffix) {
                    subjectKind = val
                }
            }

            if subjectKind.isEmpty {
                subjectKind = String.publishSubject
            }
            underlyingSubjectType = "\(subjectKind)<\(typeParamStr)>"

            var underlyingSubjectTypeDefaultVal: String? = nil
            if subjectKind == String.publishSubject {
                underlyingSubjectTypeDefaultVal = "\(underlyingSubjectType)()"
            } else if subjectKind == String.replaySubject {
                underlyingSubjectTypeDefaultVal = "\(underlyingSubjectType)\(String.replaySubjectCreate)"
            } else if subjectKind == String.behaviorSubject {
                if let val = SwiftType(String(typeParamStr)).defaultSingularVal(isInitParam: isInitParam, overrides: overrides, overrideKey: overrideKey) {
                    underlyingSubjectTypeDefaultVal = "\(underlyingSubjectType)(value: \(val))"
                }
            }
            return (underlyingSubjectType, String(typeParamStr), underlyingSubjectTypeDefaultVal)
        }
        return (nil, nil, nil)
    }

    private func parseDefaultVal(isInitParam: Bool) -> String? {
        let arg = self

        if let val = defaultSingularVal(isInitParam: isInitParam) {
            return val
        }

        if hasClosure {
            return nil
        }

        if !arg.isSingular {
            return nil
        }

        let ret = arg.tupleComponents
        var vals = [String]()
        for sub in ret {
            if sub == "," || sub == ":" || sub == "(" || sub == ")" || sub == "=" || sub == " " || sub == "" {
                vals.append(sub)
            } else {
                if let val = SwiftType(sub).defaultSingularVal(isInitParam: isInitParam) {
                    vals.append(val)
                } else {
                    return nil
                }
            }
        }

        if !vals.isEmpty {
            var ret = vals.joined()
            ret = ret.replacingOccurrences(of: ",", with: ", ")
            ret = ret.replacingOccurrences(of: ",  ", with: ", ")
            return ret
        }

        return nil
    }

    private func defaultSingularVal(isInitParam: Bool = false, overrides: [String: String]? = nil, overrideKey: String = "") -> String? {
        let arg = self

        if arg.isOptional {
            return "nil"
        }

        if arg.isValidBracketed {
            if let idx = arg.typeName.firstIndex(of: "<") {
                let sub = String(arg.typeName[arg.typeName.startIndex..<idx])
                if bracketPrefixTypes.contains(sub) {
                    return "\(arg.typeName)()"
                } else if let val = rxTypes[sub], let suffix = val {
                    return "\(arg.typeName)\(suffix)"
                } else {
                    return nil
                }
            }
            return "\(arg.typeName)()"
        }

        if let val = SwiftType.defaultValueMap[arg.typeName] {
            return val
        }
        return nil
    }

    static func toClosureType(
        params: [SwiftType],
        typeParams: [String],
        isAsync: Bool,
        throwing: ThrowingKind,
        returnType: SwiftType,
        encloser: SwiftType
    ) -> SwiftType {
        let displayableParamTypes = params.map { (subtype: SwiftType) -> String in
            return subtype.processTypeParams(with: typeParams)
        }

        let displayableParamStr = displayableParamTypes.joined(separator: ", ")
        var displayableReturnType = returnType.typeName

        let returnComps = displayableReturnType.literalComponents

        var returnAsStr = ""
        var asSuffix = "!"
        var returnTypeCast = ""
        if typeParams.contains(where: { returnComps.contains($0)}) {
            returnAsStr = returnType.typeName
            if returnType.isOptional {
                displayableReturnType = .anyType + "?"
                returnAsStr.removeLast()
                asSuffix = "?"
            } else if returnType.isIUO {
                displayableReturnType = .anyType + "!"
                returnAsStr.removeLast()
            } else if returnType.isSelf {
                returnAsStr = String.`Self`
            } else {
                displayableReturnType = .anyType
            }

            if !returnAsStr.isEmpty {
                returnTypeCast = " as\(asSuffix) " + returnAsStr
            }
        }

        if returnType.isSelf {
            displayableReturnType = encloser.typeName
            returnTypeCast = " as! " + String.`Self`
        }

        if !(SwiftType(displayableReturnType).isSingular || SwiftType(displayableReturnType).isOptional) {
            displayableReturnType = "(\(displayableReturnType))"
        }

        let suffixStr = applyFunctionSuffixTemplate(
            isAsync: isAsync,
            throwing: throwing
        )

        let typeStr = "((\(displayableParamStr)) \(suffixStr)-> \(displayableReturnType))?"
        return SwiftType(typeStr, cast: returnTypeCast)
    }
    
    static func toArgumentsHistoryType(with params: [SwiftType], typeParams: [String]) -> SwiftType {
        // Expected only history capturable types.
        let displayableParamTypes = params.compactMap { (subtype: SwiftType) -> String? in
            var processedType = subtype.processTypeParams(with: typeParams)
            
            if subtype.isInOut {
                processedType = String(processedType.dropFirst((String.inout + " ").count))
            }
            if subtype.isIUO {
                processedType = String(processedType.dropLast("!".count))
            }
            
            return processedType
        }
        
        let displayableParamStr = displayableParamTypes.joined(separator: ", ")

        if displayableParamTypes.count >= 2 {
            return SwiftType("[(\(displayableParamStr))]")
        } else {
            return SwiftType("[\(displayableParamStr)]")
        }
    }


    func processTypeParams(with typeParamList: [String]) -> String {
        let closureRng = typeName.range(of: String.closureArrow)
        let isEscaping = typeName.hasPrefix(String.escaping)

        let isTypeOptional = isOptional
        var ret = typeName
        if let closureRng = closureRng {
            let left = ret[ret.startIndex..<closureRng.lowerBound]
            let right = ret[closureRng.lowerBound..<ret.endIndex]
            ret = left + right.replacingOccurrences(of: "\(String.some) ", with: "\(String.any) ")
            
            for item in typeParamList {
                if isEscaping, left.literalComponents.contains(item) {
                    ret = String.anyType
                    if isTypeOptional {
                        ret += "?"
                    }
                    return ret
                }
            }

            for item in typeParamList {
                if ret.literalComponents.contains(item) {
                    ret = ret.replacingOccurrences(of: item, with: String.anyType)
                }
            }
            return ret
        } else {
            let hasGenericType = typeParamList.filter{ (item: String) -> Bool in
                ret.literalComponents.contains(item)
            }.isEmpty == false

            if hasGenericType || isOpaqueType {
                ret = .anyType
                if isTypeOptional {
                    ret += "?"
                }
            }
            return ret
        }
    }

    public static var customDefaultValueMap: [String: String]?

    private let bracketPrefixTypes = ["Array", "Set", "Dictionary"]
    private let rxTypes = [String.publishSubject : "()",
                           String.replaySubject : String.replaySubjectCreate,
                           String.behaviorSubject : nil,
                           String.behaviorRelay: nil,
                           String.observableLeftAngleBracket: String.empty,
                           String.rxObservableLeftAngleBracket: String.empty]

    enum BracketType {
        case angle
        case square
    }


    private static let defaultValueMap =
        ["Int": "0",
         "Int8": "0",
         "Int16": "0",
         "Int32": "0",
         "Int64": "0",
         "UInt": "0",
         "UInt8": "0",
         "UInt16": "0",
         "UInt32": "0",
         "UInt64": "0",
         "CGFloat": "0.0",
         "Float": "0.0",
         "Double": "0.0",
         "Bool": "false",
         "String": "\"\"",
         "Character": "\"\"",
         "TimeInterval": "0.0",
         "NSTimeInterval": "0.0",
         "PublishSubject": "PublishSubject()",
         "Data": "Data()",
         "Date": "Date()",
         "NSDate": "NSDate()",
         "CGRect": ".zero",
         "CGSize": ".zero",
         "CGPoint": ".zero",
         "UIEdgeInsets": ".zero",
         "UIColor": ".black",
         "UIFont": ".systemFont(ofSize: 12)",
         "UIImage": "UIImage()",
         "UIScrollViewKeyboardDismissMode": ".interactive",
         "UIAccessibilityTraits": ".none",
         "Void": "Void",
         "()": "()",
         "URL": "URL(fileURLWithPath: \"\")",
         "NSURL": "NSURL(fileURLWithPath: \"\")",
         "UUID": "UUID()",
    ];
}
