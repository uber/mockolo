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
        
        // Look up override arguments if any
        if let argsMap = extracted.parseAnnotationArguments(for: String.typealiasColon, String.moduleColon, String.rxColon, String.varColon) {
            if let val = argsMap[.typealiasColon] {
                ret.typeAliases = val
            }
            if let val = argsMap[.rxColon] {
                ret.varTypes = val
            }
            if let val = argsMap[.varColon] {
                if ret.varTypes == nil {
                   ret.varTypes = val
                } else {
                    ret.varTypes?.merge(val, uniquingKeysWith: {$1})
                }
            }
            if let val = argsMap[.moduleColon] {
                ret.module = val[.name]
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
    
    func subContainer(metadata: AnnotationMetadata?, declType: DeclType, path: String?, data: Data?, isProcessed: Bool) -> EntityNodeSubContainer {
        let memberList = members(with: path, encloserType: declType, data: data, metadata: metadata, processed: isProcessed)
        let subAttributes = memberAttributes(with: data)
        return EntityNodeSubContainer(attributes: subAttributes, members: memberList, hasInit: hasInitMember)
    }
    
    func members(with path: String?, encloserType: DeclType, data: Data?, metadata: AnnotationMetadata?, processed: Bool) -> [Model] {
        guard let path = path, let data = data else { return [] }
        return self.substructures.compactMap { (child: Structure) -> Model? in
            return model(for: child, encloserType: encloserType, filepath: path, data: data, metadata: metadata, processed: processed)
        }
    }
    
    func memberAttributes(with data: Data?) -> [String] {
        guard let data = data else { return [] }
        return self.substructures.compactMap { (child: Structure) -> [String]? in
            return child.extractAttributes(data, filterOn: SwiftDeclarationAttributeKind.available.rawValue)
        }.flatMap {$0}
    }
    
    private func validateMember(_ element: Structure, _ declType: DeclType, processed: Bool) -> Bool {
        if !processed, element.isPrivate {
            return false
        }
        if element.isStatic, declType == .classType {
            return false
        }
        return true
    }
    
    private func validateInit(_ element: Structure, _ declType: DeclType, processed: Bool) -> Bool {
        if element.isPrivate {
            return false
        }
        let isRequired = element.isRequired
        if processed {
            return isRequired
        }

        if element.isConvenience || element.isPrivate {
            return false
        }
        return true
    }
    
    func model(for element: Structure, encloserType: DeclType, filepath: String, data: Data, metadata: AnnotationMetadata?, processed: Bool = false) -> Model? {
        if element.isVariable {
            if validateMember(element, declType, processed: processed) {
                return VariableModel(element, encloserType: encloserType, filepath: filepath, data: data, overrideTypes: metadata?.varTypes, processed: processed)
            }
        } else if element.isMethod || element.isSubscript { // initializer is considered a method by sourcekit
            var validated = false
            if element.isInitializer {
                validated = validateInit(element, declType, processed: processed)
            } else {
                validated = validateMember(element, declType, processed: processed)
            }
            
            if validated {
                return MethodModel(element, encloserType: encloserType, filepath: filepath, data: data, processed: processed)
            }
            return nil

        } else if element.isAssociatedType || element.isTypealias {
            return TypeAliasModel(element, filepath: filepath, data: data, overrideTypes: metadata?.typeAliases, processed: processed)
        }
        
        return nil
    }

    
    var acl: String {
        return accessControlLevelDescription
    }
    
    var attributesDescription: String {
        return attributes?.description ?? ""
    }
    
    var declType: DeclType {
        return isProtocol ? .protocolType : (isClass ? .classType : .other)
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
    
    var isPrivate: Bool {
        if let attrs = attributeValues {
            return attrs.contains(SwiftDeclarationAttributeKind.private.rawValue) || attrs.contains(SwiftDeclarationAttributeKind.fileprivate.rawValue)
        }
        
        return false
    }
    var isFinal: Bool {
        return attributeValues?.contains(SwiftDeclarationAttributeKind.final.rawValue) ?? false
    }
    
    var isInitializer: Bool {
        return name.hasPrefix(.initializerLeftParen) && isInstanceMethod
    }

    var hasBlankInit: Bool {
        return !substructures.filter{$0.name == .hasBlankInit}.isEmpty
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

    var isStatic: Bool {
        return isStaticMethod || isStaticVariable
    }

    var isOverride: Bool {
        return attributeValues?.contains(SwiftDeclarationAttributeKind.override.rawValue) ?? false
    }

    var isRequired: Bool {
        return attributeValues?.contains(SwiftDeclarationAttributeKind.required.rawValue) ?? false
    }

    var isConvenience: Bool {
        return attributeValues?.contains(SwiftDeclarationAttributeKind.convenience.rawValue) ?? false
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
        return kind == SwiftDeclarationKind.varParameter.rawValue
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
    
    var isTypealias: Bool {
        return kind == SwiftDeclarationKind.typealias.rawValue
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
        return name.canBeInitParam(type: typeName, isStatic: !isInstanceVariable)
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
