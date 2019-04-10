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


/// TODO: remove this file once SwiftScanner is added as a dependency and the following ACLs become public.

let UnknownVal = "Unknown"

extension Structure {
    
    /// The substructures of this structure.
    var substructures: [Structure] {
        let substructures = (dictionary["key.substructure"] as? [SourceKitRepresentable]) ?? []
        
        let result = substructures.compactMap { (substructure: SourceKitRepresentable) -> Structure? in
            if let structure = substructure as? [String: SourceKitRepresentable] {
                return Structure(sourceKitResponse: structure)
            } else {
                return nil
            }
        }
        return result
    }
    
    var name: String {
        // A type must have a name.
        return dictionary["key.name"] as? String ?? UnknownVal
    }
    
    var kind: String {
        return dictionary["key.kind"] as? String ?? UnknownVal
    }
    var typeName: String {
        return dictionary["key.typename"] as? String ?? UnknownVal
    }
    
    var hasAvailableAttribute: Bool {
        return kind == SwiftDeclarationAttributeKind.available.rawValue
    }
    
    var accessControlLevelDescription: String {
        return accessControlLevel == "internal" ? "" : accessControlLevel
    }
    
    var accessControlLevel: String {
        if let access = dictionary["key.accessibility"] as? String, let level = access.components(separatedBy: ".").last {
            return level
        }
        return UnknownVal
    }
    var isInitializer: Bool {
        return name.hasPrefix(.initializerPrefix) && isInstanceMethod
    }
    
    var isInstanceVariable: Bool {
        return kind == SwiftDeclarationKind.varInstance.rawValue
    }
    
    var isStaticVariable: Bool {
        return kind == SwiftDeclarationKind.varStatic.rawValue
    }
    
    var isStaticMethod: Bool {
        return kind == SwiftDeclarationKind.functionMethodStatic.rawValue
    }
    
    var isProtocol: Bool {
        return kind == SwiftDeclarationKind.protocol.rawValue
    }
    
    var isClass: Bool {
        return kind == SwiftDeclarationKind.class.rawValue
    }
    
    var isVariable: Bool {
        return isStaticVariable || isInstanceVariable
    }
    
    var isInstanceMethod: Bool {
        return kind == SwiftDeclarationKind.functionMethodInstance.rawValue
    }
    
    var isVarParameter: Bool {
        return kind == "source.lang.swift.decl.var.parameter"
    }

    var isTypeNonOptional: Bool {
        return !typeName.hasSuffix("?")
    }

    var isMethod: Bool {
        return isInstanceMethod || isStaticMethod
    }
    
    var isClosureVariable: Bool {
        return isVariable && typeName.contains("->")
    }
    
    var isGenericTypeParam: Bool {
        return kind == SwiftDeclarationKind.genericTypeParam.rawValue
    }
    var isGenericMethod: Bool {
        return isMethod && substructures.filter({$0.kind == SwiftDeclarationKind.genericTypeParam.rawValue}).count > 0
    }
    
    var canBeInitParam: Bool {
        return isVariable &&
            isTypeNonOptional &&
            !name.hasPrefix(.underlyingVarPrefix) &&
            !name.hasSuffix(.closureVarSuffix) &&
            !name.hasSuffix(.callCountSuffix) &&
            !name.hasSuffix(.subjectSuffix) &&
            typeName != UnknownVal
    }
    
    var inheritedTypes: [String] {
        let types = dictionary["key.inheritedtypes"] as? [SourceKitRepresentable] ?? []
        return types.compactMap { (item: SourceKitRepresentable) -> String? in
            (item as? [String: String])?["key.name"]
        }
    }
    
    var attributes: [[String: SourceKitRepresentable]]? {
        return dictionary["key.attributes"] as? [[String: SourceKitRepresentable]]
    }
    
    var attributeValues: [String]? {
        return attributes?.compactMap { $0["key.attribute"] as? String}
    }
    
    var range: (offset: Int64, length: Int64) {
        var offsetMin: Int64 = .max
        var offsetMax: Int64 = -1
        // Get the min/max offsets for attributes if any (e.g. @objc, public, static, etc) for this node
        if let attributes = attributes {
            let result = attributes.reduce((.max, -1), { (prevResult, curAttribute) -> (Int64, Int64) in
                var (minOffset, maxOffset) = prevResult
                if let offset = curAttribute[SwiftDocKey.offset.rawValue] as? Int64 {
                    if minOffset > offset {
                        minOffset = offset
                    }
                    if let len = curAttribute[SwiftDocKey.length.rawValue] as? Int64, maxOffset < offset + len {
                        maxOffset = offset + len
                    }
                }
                return (minOffset, maxOffset)
            })
            offsetMin = result.0
            offsetMax = result.1
        }
        
        // Compare with the offset and length of this node
        if offsetMin > offset {
            offsetMin = offset
        }
        if offsetMax < offset + length {
            offsetMax = offset + length
        }
        let len = offsetMax - offsetMin
        // Return the start offset and the length
        return (offsetMin, len)
    }
    
    
    var offset: Int64 {
        return dictionary[SwiftDocKey.offset.rawValue] as? Int64 ?? -1
    }

    var length: Int64 {
        return dictionary[SwiftDocKey.length.rawValue] as? Int64 ?? 0
    }
    var bodyOffset: Int64 {
        return dictionary[SwiftDocKey.bodyOffset.rawValue] as? Int64 ?? -1
    }

    func extract(offset: Int64, length: Int64, content: String) -> String {
        let end = offset + length - 1
        let start = offset
        
        if start >= 0 && length > 0 {
            if end > content.count {
                print("No content found", start, length, end, content.count)
                return ""
            }
            
            let startIdx = content.index(content.startIndex, offsetBy: Int(start))
            let endIdx = content.index(content.startIndex, offsetBy: Int(end))
            let body = content[startIdx ..< endIdx]
            return String(body)
        }
        return ""
    }
    
    // This extracts the body of this structure, i.e. it doens't include the decl or signature
    func extractBody(_ file: String) -> String {
        let start = dictionary["key.bodyoffset"] as? Int64 ?? -1
        let len = dictionary["key.bodylength"] as? Int64 ?? 0
        return extract(offset: start, length: len, content: file)
    }
}

func scanDirectory(_ path: String, with callBack: (String) -> Void) {
    let errorHandler = { (url: URL, error: Error) -> Bool in
        fatalError("Failed to traverse \(url) with error \(error).")
    }
    if let enumerator = FileManager.default.enumerator(at: URL(fileURLWithPath: path), includingPropertiesForKeys: nil, options: [.skipsHiddenFiles], errorHandler: errorHandler) {
        while let nextObjc = enumerator.nextObject() {
            if let fileUrl = nextObjc as? URL {
                callBack(fileUrl.path)
            }
        }
    }
}

func scanPaths(_ paths: [String], with callBack: (String) -> Void) {
    for path in paths {
        scanDirectory(path, with: callBack)
    }
}
