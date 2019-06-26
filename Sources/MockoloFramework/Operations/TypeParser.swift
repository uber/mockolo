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

/// Parses type strings containing (nested) tuples and brackets, and provides default values for each if possible.

private let defaultValuesDict =
    ["Int": "0",
     "Int64": "0",
     "Int32": "0",
     "Int16": "0",
     "Int8": "0",
     "UInt": "0",
     "UInt64": "0",
     "UInt32": "0",
     "UInt16": "0",
     "UInt8": "0",
     "Float": "0.0",
     "CGFloat": "0.0",
     "Double": "0.0",
     "Bool": "false",
     "String": "\"\"",
     "Character": "\"\"",
     "TimeInterval": "0.0",
     "NSTimeInterval": "0.0",
     "RxTimeInterval": "0.0",
     "PublishSubject": "PublishSubject()",
     "Date": "Date()",
     "NSDate": "NSDate()",
     "CGRect": ".zero",
     "CGSize": ".zero",
     "CGPoint": ".zero",
     "UIEdgeInsets": ".zero",
     "UIColor": ".white",
     "UIFont": ".systemFont(ofSize: 12)",
     "UIImage": "UIImage()",
     "UIView": "UIView(frame: .zero)",
     "UIViewController": "UIViewController()",
     "UICollectionView": "UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())",
     "UICollectionViewLayout": "UICollectionViewLayout()",
     "UIScrollView": "UIScrollView()",
     "UIScrollViewKeyboardDismissMode": ".interactive",
     "UIAccessibilityTraits": ".none",
     "Void": "Void",
     "URL": "URL(fileURLWithPath: \"\")",
     "NSURL": "NSURL(fileURLWithPath: \"\")",
     "UUID": "UUID()",
];

private func defaultVal(typeName: String, initParam: Bool = false) -> String? {
    if typeName.hasSuffix("?") {
        return "nil"
    }
    
    if typeName.hasPrefix("["), typeName.hasSuffix("]") {
        return "\(typeName)()"
    }
    
    if typeName.hasPrefix(String.observableVarPrefix), typeName.hasSuffix(">") {
        return initParam ? "\(String.publishSubject)()" : String.observableEmpty
    }
    
    if typeName.hasPrefix(String.rxObservableVarPrefix), typeName.hasSuffix(">") {
        return initParam ? "\(String.rxPublishSubject)()" : String.rxObservableEmpty
    }
    
    if typeName.hasSuffix(">") &&
        (typeName.hasPrefix("Array<") ||
            typeName.hasPrefix("Set<") ||
            typeName.hasPrefix("Dictionary<") ||
            typeName.hasPrefix("PublishSubject<")) {
        return "\(typeName)()"
    }
    
    if let val = defaultValuesDict[typeName] {
        return val
    }
    return nil
}

// Process substrings containing angled or square brackets by replacing a comma delimiter
// with another delimiter (e.g. ;) to make it easier to parse tuples
// @param arg The type string to be parsed
// @param left The opening bracket character
// @param right The closing bracket character
// @returns The processed string with a new delimiter
private func parseBrackets(_ arg: String, left: String, right: String) -> String {
    var mutableArg = arg
    var nextRange: Range<String.Index>? = nil
    while let leftRange = mutableArg.range(of: left, options: String.CompareOptions.caseInsensitive, range: nextRange, locale: nil),
        let rightRange = mutableArg.range(of: right, options: String.CompareOptions.caseInsensitive, range: nextRange, locale: nil) {
            let bound = leftRange.lowerBound..<rightRange.lowerBound
            let sub = mutableArg.substring(with: bound)
            let newsub = sub.replacingOccurrences(of: ",", with: ";")
            mutableArg = mutableArg.replacingOccurrences(of: sub, with: newsub)
            
            if let nextIdx = mutableArg.index(rightRange.upperBound, offsetBy: 1, limitedBy: mutableArg.endIndex) {
                nextRange = nextIdx..<mutableArg.endIndex
            } else {
                break
            }
    }
    
    return mutableArg
}

// Parse the string containing tuples or brackets and returns a default value for each type component
// @param arg The type string to be parsed
// @returns The parsed string containing a default value for each type component
private func parseParens(_ arg: String) -> String? {
    var stack = [[String]]()
    
    // First process substrings with brackets: replace a comma with another delimiter
    var parsedArg = parseBrackets(arg, left: "<", right: ">")
    parsedArg = parseBrackets(parsedArg, left: "[", right: "]")
    
    // Separate the input by a comma delimiter and process each sub component
    let comps = parsedArg.components(separatedBy: CharacterSet(charactersIn: ",")).filter(path: \.isNotEmpty)
    if comps.count == 1 {
        let sub = parsedArg.trimmingCharacters(in: CharacterSet.whitespaces)
        // There's only one component, so just look up the default value for the component
        if let val = defaultVal(typeName: sub) {
            return val
        }
        
        // In case it contains a label, look up the type portion
        if let labelSub = sub.components(separatedBy: ":").last?.trimmingCharacters(in: CharacterSet.whitespaces) {
            return defaultVal(typeName: labelSub)
        }
    } else {
        let subcomps = comps.filter(path: \.isNotEmpty)
        
        for comp in subcomps {
            var sub = comp.trimmingCharacters(in: CharacterSet.whitespaces)
            
            // Process tuples by stripping parens and recursively calling on the remaining substring portion
            if sub.hasPrefix("("), sub.hasSuffix(")") {
                sub.removeFirst()
                sub.removeLast()
                stack.append(["("])
                if let val = parseParens(sub) {
                    stack[stack.count - 1].append(val)
                } else {
                    return nil
                }
                stack[stack.count - 1].append(")")
            } else if sub.hasPrefix("(") {
                sub.removeFirst()
                stack.append(["("])
                if let val = parseParens(sub) {
                    stack[stack.count - 1].append(val)
                } else {
                    return nil
                }
            } else if sub.hasSuffix(")") {
                sub.removeLast()
                if !stack.isEmpty {  // Adding this as a safe guard but this check should not be needed
                    if let val = parseParens(sub) {
                        stack[stack.count - 1].append(val)
                    } else {
                        return nil
                    }
                    stack[stack.count - 1].append(")")
                }
                stack.append([""])
            } else {
                if let val = parseParens(sub), !val.isEmpty {
                    if stack.isEmpty {
                        stack.append([val])
                    } else {
                        stack[stack.count - 1].append(val)
                    }
                } else {
                    return nil
                }
            }
        }
    }
    
    // Now combine them with a comma delimiter
    let result = stack.flatMap{$0}.filter(path: \.isNotEmpty).joined(separator: ", ")
    return result
}

// Cleanup the input string if it contains extra unneeded commas
private func lintCommas(_ arg: String) -> String {
    // Replace the other delimiter back to a comma delimiter
    var replaced = arg.replacingOccurrences(of: ";", with: ",")
    // Remove any excessive commas added from joining
    for left in ["(,", "( ,"] {
        replaced = replaced.replacingOccurrences(of: left, with: "(")
    }
    for right in [",)", ", )"] {
        replaced = replaced.replacingOccurrences(of: right, with: ")")
    }
    return replaced
}

/// Parses a type string containing (nested) tuples or brackets and returns a default value for each type component
func processDefaultVal(typeName: String, typeKeys: [String: String]? = nil, initParam: Bool = false) -> String? {
    
    if let val = defaultVal(typeName: typeName, initParam: initParam) {
        return val
    }
    if let val = typeKeys?[typeName] {
        return val
    }
    if let result = parseParens(typeName) {
        return lintCommas(result)
    }
    return nil
}
