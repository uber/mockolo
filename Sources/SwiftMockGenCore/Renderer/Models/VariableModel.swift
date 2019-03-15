import Foundation
import SourceKittenFramework

struct VariableModel: Model {
    
    var name: String
    var type: String
    var mediumName: String
    var longName: String
    var fullName: String
    var offset: Int64
    let accessControlLevelDescription: String
    let attributes: [String]?
    let defaultValue: String?
    let staticKind: String
    let canBeInitParam: Bool
    let processed: Bool
    
    init(_ ast: Structure, content: String, processed: Bool) {
        name = ast.name
        type = ast.typeName
        mediumName = name
        longName = name
        fullName = name
        offset = ast.offset
        canBeInitParam = ast.canBeInitParam
        staticKind = ast.isStaticVariable ? StaticKindString : ""
        accessControlLevelDescription = ast.accessControlLevelDescription
        defaultValue = defaultVal(typeName: ast.typeName)
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
