
import Foundation
import SourceKittenFramework

func renderMethod(_ element: Structure, attributes: String) -> String {
    var comps = element.name.components(separatedBy: CharacterSet(charactersIn: "():"))
    let methodShortName = comps.removeFirst()
    let paramStructures = element.substructures.filter{$0.isParameter}
    
    let paramDecls = renderMethodParamDecls(paramStructures, words: comps)
    let handlerParamDecls = renderUnderlyingMethodParamDecls(paramStructures)
    let handlerParamVals = renderMethodParamNames(paramStructures, capitalized: false)
    let suffixes = renderMethodParamNames(paramStructures, capitalized: true)
    
    let returnDefaultStr = renderUnderlyingMethodReturnDefaultStatement(element)
    let returnType = element.typeName != "Unknown" ? element.typeName : ""
    
    let result = applyMethodTemplate(methodShortName: methodShortName,
                                     attributes: attributes,
                                     suffixes: suffixes,
                                     paramDecls: paramDecls,
                                     returnType: returnType,
                                     handlerParamDecls: handlerParamDecls,
                                     handlerParamVals: handlerParamVals,
                                     handlerReturnDefault: returnDefaultStr)
    return result
}

func renderVariable(_ element: Structure, attributes: String) -> String {
    if let rxVar = applyRxVariableTemplate(element, attributes: attributes) {
        return rxVar
    }
    return applyVariableTemplate(element, attributes: attributes)
}

func renderAttributes(_ element: Structure, content: String) -> String {
    var attributesStr = ""
    if let attributes = element.attributes {
        let result = attributes.map { (str: String) -> String in
            if str == "available" {
                return "@" + str + "(iOS 10.0, *)"
                //                let lastLines = line.lastLines(4, file: file)
                //                let targetLines = lastLines.filter{ (l: Line) -> Bool in
                //                    l.content.contains(str)
                //                }
                //
                //                if let targetLine = targetLines.first, let range = targetLine.content.range(of: "\(str)(\\d+, *)", options: String.CompareOptions.regularExpression, range: nil, locale: nil) {
                //                    let result = targetLine.content.substring(with: range)
                //                    return "@" + result
                //                }
            } else if str == element.accessControlLevel {
                return ""
            }
            return "@" + str
        }
        
        attributesStr = result.joined(separator: " ")
        
        if attributes.contains(element.accessControlLevel) {
            attributesStr = "\(attributesStr) \(element.accessControlLevel)"
        }
    }
    return attributesStr
}

private func renderMethodParamDecls(_ elements: [Structure], words: [String]) -> [String] {
    return zip(elements, words).map { (element: Structure, word: String) -> String in
        var prefix = ""
        if element.name != word {
            prefix = "\(word) "
        }
        return "\(prefix)\(element.name): \(element.typeName)"
    }
}

private func renderUnderlyingMethodParamDecls(_ elements: [Structure]) -> [String] {
    return elements.map { (element: Structure) -> String in
        return "_ \(element.name): \(element.typeName)"
    }
}

private func renderMethodParamNames(_ elements: [Structure], capitalized: Bool) -> [String] {
    return elements.map { (element: Structure) -> String in
        return capitalized ? element.name.capitlizeFirstLetter() : element.name
    }
}

private func renderUnderlyingMethodReturnDefaultStatement(_ element: Structure) -> String {
    if element.typeName != "Unknown" {
        let errorMsg = "fatalError"
        let returnType = element.typeName.trimmingCharacters(in: CharacterSet(charactersIn: "()"))
        
        // TODO: need to handle ',' in return type like Hashtable<Int, String>, (Observable<(Int, String)>, Bool)
        let returnStmts = returnType.components(separatedBy: ",").compactMap { (sub: String) -> String? in
            if sub.isEmpty {
                return nil
            }
            let subComps = sub.components(separatedBy: ":")
            let subComp = (subComps.last ?? sub).trimmingCharacters(in: CharacterSet.whitespaces)
            if subComp.hasSuffix("?") {
                return "nil"
            }
            if subComp.hasPrefix("Observable<") {
                return "Observable.empty()"
            }
            return errorMsg
        }
        
        if returnStmts.contains(errorMsg) {
            return "\(errorMsg)(\"\(element.name) returns can't have a default value thus its handler must be set\")"
        } else if returnStmts.count > 1 {
            return "return (\(returnStmts.joined(separator: ", ")))"
        } else if let returnStmts = returnStmts.first {
            return  "return \(returnStmts)"
        }
    }
    return ""
}

private func resolveDefaultVal(of typeName: String) -> String {
    if typeName.hasSuffix("?"){
        return "nil"
    } else {
        // TODO: handle a comma case, e.g. in Observable<Int, String>, (Array<Int, String>, String)
        let subTypes = typeName.trimmingCharacters(in: CharacterSet(charactersIn: "()")).components(separatedBy: ",")
        let subTypeDefaultVals = subTypes.compactMap { (subType: String) -> String? in
            return defaultVal(of: subType)
        }
        
        if subTypeDefaultVals.count > 1 {
            return "(\(subTypeDefaultVals.joined(separator: ", ")))"
        } else if let val = subTypeDefaultVals.first {
            return val
        }
    }
    return ""
}

func applyVariableTemplate(_ element: Structure, attributes: String) -> String {
    let underlyingName = "underlying\(element.name.capitlizeFirstLetter())"
    let underlyingSetCallCount = "\(element.name)SetCallCount"
    let underlyingVarDefaultVal = resolveDefaultVal(of: element.typeName)
    
    var underlyingType = element.typeName
    if underlyingVarDefaultVal.isEmpty {
        if underlyingType.hasSuffix("?") {
            underlyingType.removeLast()
        }
        if !underlyingType.hasSuffix("!") {
            underlyingType.append("!")
        }
    }
    
    let template = """
    var \(underlyingSetCallCount) = 0
    var \(underlyingName): \(underlyingType) \(underlyingVarDefaultVal.isEmpty ? "" : "= \(underlyingVarDefaultVal)")
    \(attributes)
    var \(element.name): \(element.typeName) {
        get {
             return \(underlyingName)
        }
        set {
             \(underlyingName) = newValue
            \(underlyingSetCallCount) += 1
        }
    }
    """
    return template
}

func applyRxVariableTemplate(_ element: Structure, attributes: String) -> String? {
    if let range = element.typeName.range(of: "Observable<"), let lastIdx = element.typeName.lastIndex(of: ">") {
        let typeParamStr = element.typeName[range.upperBound..<lastIdx]
        
        let underlying = "\(element.name)Subject"
        let underlyingSetCallCount = "\(underlying)SetCallCount"
        let underlyingType = "PublishSubject<\(typeParamStr)>"
        let template = """
        var \(underlyingSetCallCount) = 0
        var \(underlying) = \(underlyingType)() {
            didSet {
                 \(underlyingSetCallCount) += 1
            }
        }
        \(attributes)
        var \(element.name): \(element.typeName) {
            return \(underlying)
        }
        """
        return template
    }
    return nil
}


func applyMethodTemplate(methodShortName: String,
                         attributes: String,
                         suffixes: [String],
                         paramDecls: [String],
                         returnType: String,
                         handlerParamDecls: [String],
                         handlerParamVals: [String],
                         handlerReturnDefault: String) -> String {
    let suffixStr = suffixes.joined()
    let methodIdentifier = methodShortName.contains(suffixStr) ? methodShortName : methodShortName + suffixStr
    let callCount = "\(methodIdentifier)CallCount"
    let handlerName = "\(methodIdentifier)Handler"
    let handlerParamStr = handlerParamDecls.joined(separator: ", ")
    let handlerParamValsStr = handlerParamVals.joined(separator: ", ")
    let paramDeclsStr = paramDecls.joined(separator: ", ")
    
    let template = """
    var \(callCount) = 0
    var \(handlerName): ((\(handlerParamStr)) \(returnType.isEmpty ? "-> ()" : "-> \(returnType)"))?
    \(attributes)
    func \(methodShortName)(\(paramDeclsStr)) \(returnType.isEmpty ? "" : "-> \(returnType)") {
        \(callCount) += 1
        if let \(handlerName) = \(handlerName) {
            return \(handlerName)(\(handlerParamValsStr))
        }
        \(handlerReturnDefault)
    }
    """
    return template
}

