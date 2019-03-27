import Foundation
import SourceKittenFramework

struct VariableModel: Model {
    
    var name: String
    var type: String
    var offset: Int64
    let accessControlLevelDescription: String
    let attributes: [String]?
    let staticKind: String
    let canBeInitParam: Bool
    let processed: Bool
    
    init(_ ast: Structure, content: String, processed: Bool) {
        name = ast.name
        type = ast.typeName
        offset = ast.offset
        canBeInitParam = ast.canBeInitParam
        staticKind = ast.isStaticVariable ? .static : ""
        accessControlLevelDescription = ast.accessControlLevelDescription
        attributes = ast.hasAvailableAttribute ? ast.extractAttributes(content, filterOn: SwiftDeclarationAttributeKind.available.rawValue) : nil
        self.processed = processed
    }
    
    
    func render(with identifier: String) -> String? {
        guard !processed else { return nil }

        if let rxVar = applyRxVariableTemplate(name: identifier,
                                               typeName: type,
                                               staticKind: staticKind,
                                               accessControlLevelDescription: accessControlLevelDescription) {
            return rxVar
        }
        return applyVariableTemplate(name: identifier,
                                     typeName: type,
                                     staticKind: staticKind,
                                     accessControlLevelDescription: accessControlLevelDescription)
    }
}
