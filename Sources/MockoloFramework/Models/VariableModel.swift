import Foundation
import SourceKittenFramework

final class VariableModel: Model {
    var name: String
    var type: Type
    var offset: Int64
    var length: Int64
    let accessControlLevelDescription: String
    let attributes: [String]?
    let staticKind: String
    var canBeInitParam: Bool
    let processed: Bool
    let data: Data
    var filePath: String
    var modelType: ModelType {
        return .variable
    }
    
    init(_ ast: Structure, filepath: String, data: Data, processed: Bool) {
        name = ast.name
        type = Type(ast.typeName)
        offset = ast.range.offset
        length = ast.range.length
        canBeInitParam = ast.canBeInitParam
        staticKind = ast.isStaticVariable ? .static : ""
        accessControlLevelDescription = ast.accessControlLevelDescription
        attributes = ast.hasAvailableAttribute ? ast.extractAttributes(data, filterOn: SwiftDeclarationAttributeKind.available.rawValue) : nil
        self.processed = processed
        self.data = data
        self.filePath = filepath
    }
    
    func render(with identifier: String, typeKeys: [String: String]?) -> String? {
        if processed {
            var ret = self.data.toString(offset: self.offset, length: self.length)
            if !ret.contains(identifier),
                let first = ret.components(separatedBy: CharacterSet(arrayLiteral: ":", "=")).first,
                let found = first.components(separatedBy: " ").filter({!$0.isEmpty}).last {
                ret = ret.replacingOccurrences(of: found, with: identifier)
            }
            return ret
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
