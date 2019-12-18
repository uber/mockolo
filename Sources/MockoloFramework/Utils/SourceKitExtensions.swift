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


// Contains arguments to annotation
// Ex. @mockable(typealias: T = Any; U = String; ...)
struct AnnotationMetadata {
    var typealiases: [String: String]?
}

extension Structure: EntityNode {
    
    init(path: String) throws {
        self.init(sourceKitResponse: try Request.customRequest(request: [
            "key.request": UID("source.request.editor.open"),
            "key.name": path,
            "key.sourcefile": path
            ]).send())
    }

    func annotationMetadata(with annotation: Data, in data: Data) -> AnnotationMetadata? {
        guard let extracted = data.sliced(offset: docOffset, length: docLength) else { return nil }
        guard let _ = extracted.range(of: annotation) else { return nil }
        var ret = AnnotationMetadata()
        
        // Look up the typealias argument if any
        if let arg = Data.typealias,
            let argRange = extracted.range(of: arg) {
            let args = extracted[argRange.endIndex...]
            let argsStr = String(data: args, encoding: .utf8)?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)

            if var patValStr = argsStr {
                patValStr.removeLast()
                let aliases = patValStr.components(separatedBy: String.annotationArgDelimiter).filter { !$0.isEmpty }
                var aliasMap = [String: String]()

                aliases.forEach { (item: String) in
                    let keyVal = item.components(separatedBy: "=").map{$0.trimmingCharacters(in: CharacterSet.whitespaces)}
                    if let key = keyVal.first, let val = keyVal.last {
                        aliasMap[key] = val
                    }
                }
                ret.typealiases = aliasMap
            }
        }
        return ret
    }
    
    
    func extractAttributes(_ data: Data, filterOn: String? = nil) -> [String] {
        guard let attributeDict = attributes else {
            return []
        }
        
        return attributeDict.compactMap { (attribute: [String: SourceKitRepresentable]) -> String? in
            if let attributeVal = attribute["key.attribute"] as? String {
                if let filterAttribute = filterOn, attributeVal != filterAttribute {
                    return nil
                }
                
                return extract(attribute, from: data)
            }
            return nil
        }
    
    }
    
    
    func extract(_ source: [String: SourceKitRepresentable], from data: Data) -> String {
        if let offset = source[SwiftDocKey.offset.rawValue] as? Int64,
            let len = source[SwiftDocKey.length.rawValue] as? Int64 {
            return data.toString(offset: offset, length: len)
        }
        return ""
    }

    
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
    
    func subContainer(overrides: [String: String]?, path: String?, data: Data?, isProcessed: Bool) -> EntityNodeSubContainer {
        let memberList = members(with: path, data: data, overrides: overrides, processed: isProcessed)
        let subAttributes = memberAttributes(with: data)
        return EntityNodeSubContainer(attributes: subAttributes, members: memberList, hasInit: hasInitMember)
    }
    
    func members(with path: String?, data: Data?, overrides: [String: String]?, processed: Bool) -> [Model] {
        guard let path = path, let data = data else { return [] }
        return self.substructures.compactMap { (child: Structure) -> Model? in
            return model(for: child, filepath: path, data: data, overrides: overrides, processed: processed)
        }
    }
    
    func memberAttributes(with data: Data?) -> [String] {
        guard let data = data else { return [] }
        return self.substructures.compactMap { (child: Structure) -> [String]? in
            return child.extractAttributes(data, filterOn: SwiftDeclarationAttributeKind.available.rawValue)
        }.flatMap {$0}
    }
    
    func model(for element: Structure, filepath: String, data: Data, overrides: [String: String]?, processed: Bool = false) -> Model? {
        if element.isVariable {
            return VariableModel(element, filepath: filepath, data: data, processed: processed)
        } else if element.isMethod || element.isSubscript {
            return MethodModel(element, filepath: filepath, data: data, processed: processed)
        } else if element.isAssociatedType {
            return TypeAliasModel(element, filepath: filepath, data: data, overrideTypes: overrides, processed: processed)
        }
        
        return nil
    }

    
    var acl: String {
        return accessControlLevelDescription
    }
    
    var attributesDescription: String {
        return attributes?.description ?? ""
    }
    
    
    var hasInitMember: Bool {
        return self.substructures.filter(path: \.isInitializer).count > 0
    }
    
    var name: String {
        // A type must have a name.
        return dictionary["key.name"] as? String ?? .unknownVal
    }
    
    var kind: String {
        return dictionary["key.kind"] as? String ?? .unknownVal
    }
    var typeName: String {
        return dictionary["key.typename"] as? String ?? .unknownVal
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
        return .unknownVal
    }
    var isInitializer: Bool {
        return name.hasPrefix(.initializerPrefix) && isInstanceMethod
    }
    
    var isSubscript: Bool {
        return kind == SwiftDeclarationKind.functionSubscript.rawValue
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
    
    var isAssociatedType: Bool {
        return kind == SwiftDeclarationKind.associatedtype.rawValue
    }
    
    var isClosureVariable: Bool {
        return isVariable && typeName.contains(String.closureArrow)
    }
    
    var isGenericTypeParam: Bool {
        return kind == SwiftDeclarationKind.genericTypeParam.rawValue
    }
    var isGenericMethod: Bool {
        return isMethod && substructures.filter({$0.kind == SwiftDeclarationKind.genericTypeParam.rawValue}).count > 0
    }
    
    var canBeInitParam: Bool {
        return isInstanceVariable &&
            isTypeNonOptional &&
            !name.hasPrefix(.underlyingVarPrefix) &&
            !name.hasSuffix(.closureVarSuffix) &&
            !name.hasSuffix(.callCountSuffix) &&
            !name.hasSuffix(.subjectSuffix) &&
            typeName != .unknownVal
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
    
    var nameOffset: Int64 {
        return dictionary[SwiftDocKey.nameOffset.rawValue] as? Int64 ?? -1
    }
    
    var nameLength: Int64 {
        return dictionary[SwiftDocKey.nameLength.rawValue] as? Int64 ?? -1
    }

    var docOffset: Int64 {
        return dictionary["key.docoffset"] as? Int64 ?? -1
    }
    
    var docLength: Int64 {
        return dictionary["key.doclength"] as? Int64 ?? -1
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
    
}

