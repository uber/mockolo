import Foundation
import SourceKittenFramework

struct VariableModel: Model {
    var name: String
    var type: String
    var offset: Int64
    var length: Int64
    let accessControlLevelDescription: String
    let attributes: [String]?
    let staticKind: String
    var canBeInitParam: Bool
    let processed: Bool
    let content: String

    init(_ ast: Structure, content: String, processed: Bool) {
        name = ast.name
        type = ast.typeName
        offset = ast.range.offset
        length = ast.range.length
        canBeInitParam = ast.canBeInitParam
        staticKind = ast.isStaticVariable ? .static : ""
        accessControlLevelDescription = ast.accessControlLevelDescription
        attributes = ast.hasAvailableAttribute ? ast.extractAttributes(content, filterOn: SwiftDeclarationAttributeKind.available.rawValue) : nil
        self.processed = processed
        self.content = content
    }
    
    func render(with identifier: String, typeKeys: [String: String]?) -> String? {
        if processed {
            return self.content.extract(offset: self.offset, length: self.length)
        }

        if let rxVar = applyRxVariableTemplate(name: identifier,
                                               typeName: type,
                                               typeKeys: typeKeys,
                                               staticKind: staticKind,
                                               accessControlLevelDescription: accessControlLevelDescription) {
            return rxVar
        }
        return applyVariableTemplate(name: identifier,
                                     typeName: type,
                                     typeKeys: typeKeys, 
                                     staticKind: staticKind,
                                     accessControlLevelDescription: accessControlLevelDescription)
    }
}
