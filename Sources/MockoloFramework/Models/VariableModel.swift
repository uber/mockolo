import Foundation
import SourceKittenFramework
import SwiftSyntax

final class VariableModel: Model {
    var name: String
    var type: Type
    var offset: Int64
    var length: Int64
    let accessControlLevelDescription: String
    let attributes: [String]?
    var canBeInitParam: Bool
    let processed: Bool
    var data: Data? = nil
    var filePath: String = ""
    var isStatic = false
    var modelDescription: String? = nil
    var modelType: ModelType {
        return .variable
    }

    var staticKind: String {
        return isStatic ? .static : ""
    }

    init(name: String,
         typeName: String,
         acl: String?,
         isStatic: Bool,
         canBeInitParam: Bool,
         offset: Int64,
         length: Int64,
         modelDescription: String?,
         processed: Bool) {

        self.name = name.trimmingCharacters(in: .whitespaces)
        self.type = Type(typeName.trimmingCharacters(in: .whitespaces))
        self.offset = offset
        self.length = length
        self.canBeInitParam = canBeInitParam
        self.processed = processed
        self.accessControlLevelDescription = acl ?? ""
        self.attributes = nil
        self.modelDescription = modelDescription
    }
    
    init(_ ast: Structure, filepath: String, data: Data, processed: Bool) {
        name = ast.name
        type = Type(ast.typeName)
        offset = ast.range.offset
        length = ast.range.length
        canBeInitParam = ast.canBeInitParam
        isStatic = ast.isStaticVariable
        accessControlLevelDescription = ast.accessControlLevelDescription
        attributes = ast.hasAvailableAttribute ? ast.extractAttributes(data, filterOn: SwiftDeclarationAttributeKind.available.rawValue) : nil
        self.processed = processed
        self.data = data
        self.filePath = filepath
    }
    
    func render(with identifier: String, typeKeys: [String: String]?) -> String? {
        if processed {
            
            if let modelDescription = modelDescription {
                return modelDescription
            }
            
            if let ret = self.data?.toString(offset: self.offset, length: self.length) {
                if !ret.contains(identifier),
                    let first = ret.components(separatedBy: CharacterSet(arrayLiteral: ":", "=")).first,
                    let found = first.components(separatedBy: " ").filter({!$0.isEmpty}).last {
                    let replaced = ret.replacingOccurrences(of: found, with: identifier)
                    return replaced
                }
                return ret
            }
            return nil
        }

        if let rxVar = applyRxVariableTemplate(name: identifier,
                                               type: type,
                                               typeKeys: typeKeys,
                                               staticKind: staticKind,
                                               accessControlLevelDescription: accessControlLevelDescription) {
            return rxVar
        }
        return applyVariableTemplate(name: identifier,
                                     type: type,
                                     typeKeys: typeKeys, 
                                     staticKind: staticKind,
                                     accessControlLevelDescription: accessControlLevelDescription)
    }
}
