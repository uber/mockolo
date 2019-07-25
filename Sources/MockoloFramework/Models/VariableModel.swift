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
    var filePath: String

    let cacheKey: NSString
    
    var modelType: ModelType {
        return .variable
    }
    
    init(_ ast: Structure, filepath: String, content: String, processed: Bool) {
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
        self.filePath = filepath
        self.cacheKey = NSString(string: "\(filePath)_\(name)_\(type)_\(offset)_\(length)")
    }
    
    func render(with identifier: String, typeKeys: [String: String]?) -> String? {
        if processed {

            if let val = cacheKey.cached() {
                return val
            }
            
            var ret = self.content.extract(offset: self.offset, length: self.length)
            if !ret.contains(identifier),
                let first = ret.components(separatedBy: CharacterSet(arrayLiteral: ":", "=")).first,
                let found = first.components(separatedBy: " ").filter({!$0.isEmpty}).last {
                ret = ret.replacingOccurrences(of: found, with: identifier)
            }
            
            cacheKey.cache(with: ret)
            return ret
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
