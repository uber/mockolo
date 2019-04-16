import Foundation
import SourceKittenFramework

struct VariableModel: Model {
    
    var name: String
    var type: String
    var offset: Int64
    let range: (offset: Int64, length: Int64)
    let accessControlLevelDescription: String
    let attributes: [String]?
    let staticKind: String
    let canBeInitParam: Bool
    let isClosureVariable: Bool
    let processed: Bool
    let content: String

    init(_ ast: Structure, content: String, processed: Bool) {
        name = ast.name
        type = ast.typeName
        offset = ast.offset
        range = ast.range
        canBeInitParam = ast.canBeInitParam
        isClosureVariable = ast.isClosureVariable
        staticKind = ast.isStaticVariable ? .static : ""
        accessControlLevelDescription = ast.accessControlLevelDescription
        attributes = ast.hasAvailableAttribute ? ast.extractAttributes(content, filterOn: SwiftDeclarationAttributeKind.available.rawValue) : nil
        self.processed = processed
        self.content = content
    }
    
    
    func render(with identifier: String, typeKeys: [String]?) -> String? {
        if processed {
            return extract(offset: self.range.offset-1, length: self.range.length+1, content: self.content)
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
