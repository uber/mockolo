
import Foundation
import SourceKittenFramework

let AnnotationString = "@CreateMock"
let MockTypeString = "protocol "

extension String {
    func capitlizeFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }
    func shouldParse(with exclusionList: [String]? = nil) -> Bool {
        guard hasSuffix(".swift") else { return false }
        let filtered = exclusionList?.filter { (suffix: String) -> Bool in
            hasSuffix(suffix)
        }
        return filtered?.count ?? 0 == 0
    }
}

extension Line {
    func isAnnotated(annotatedLines: [Int], declLines: [Int]) -> Bool {
        let annotatedLinesSplit = annotatedLines.split(whereSeparator: { (line: Int) -> Bool in
            line > self.index
        })
        let lastAnnotatedLine = annotatedLinesSplit.first?.last ?? 0
        
        let declLinesSplit = declLines.split(whereSeparator: { (line: Int) -> Bool in
            line >= self.index
        })
        let prevDeclLine = declLinesSplit.first?.last ?? 0
        
        // E.g. annotated lines: 1 10 (18) 20 30
        //      decl lines: 2 12 18 21 33
        return lastAnnotatedLine > prevDeclLine
    }
}

extension Structure {
    // TODO: current line for any src -- this just handles protocol decl for now
    func currentLine(in file: File) -> Line? {
        let curDeclLines = file.lines.filter { (line: Line) -> Bool in
            if line.content.contains(self.name) {
                let parts = line.content.components(separatedBy: MockTypeString)
                let name = parts.last?.components(separatedBy: CharacterSet(charactersIn: ": {")).first
                return name == self.name
            }
            return false
        }
        return curDeclLines.first
    }
}


func extract(_ source: [String: SourceKitRepresentable], from content: String) -> String? {
    let substring = range(for: source).flatMap { range -> String? in
        guard let subdata = content.data(using: .utf8)?.subdata(in: Int(range.offset)..<Int(range.offset + range.length)) else {
            return nil
        }
        return String(data: subdata, encoding: .utf8)
    }
    
    return substring?.isEmpty == true ? nil : substring?.trimmingCharacters(in: .whitespacesAndNewlines)
}

func range(`for` source: [String: SourceKitRepresentable]) -> (offset: Int64, length: Int64)? {
    func extract(_ offset: SwiftDocKey, _ length: SwiftDocKey) -> (offset: Int64, length: Int64)? {
        if let offset = source[offset.rawValue] as? Int64, let length = source[length.rawValue] as? Int64 {
            return (offset, length)
        }
        return nil
    }

    return extract(.offset, .length)
}


func defaultVal(of typeName: String) -> String? {
    if typeName.hasSuffix("?") {
        return "nil"
    }
    
    if (typeName.hasPrefix("[") && typeName.hasSuffix("]")) || typeName.hasPrefix("Array") || typeName.hasPrefix("Dictionary") {
        return "\(typeName)()"
    }
    if typeName == "Bool" {
        return "false"
    }
    if typeName == "String" || typeName == "Character" {
        return "\"\""
    }
    
    if typeName == "Int" ||
        typeName == "Int8" ||
        typeName == "Int16" ||
        typeName == "Int32" ||
        typeName == "Int64" ||
        typeName == "Double" ||
        typeName == "CGFloat" ||
        typeName == "Float" {
        return "0"
    }
    return nil
}
