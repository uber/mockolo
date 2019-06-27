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

/// Combines a list of entities and import lines and header and writes the final output
func write(candidateMap: [String: [(String, Int64)]],
           processedImportLines: [String: [String]],
           pathToContentMap: [String: [(String, String)]],
           header: String?,
           macro: String?,
           to outputFilePath: String) -> String {
    
    var total = ""
    let sorted = candidateMap.sorted(by: {$0.key < $1.key})
    sorted.forEach { (arg: (namespace: String, candidates: [(String, Int64)])) in
        var importLines = [String: [String]]()
        if let list = pathToContentMap[arg.namespace] {
            for (filepath, filecontent) in list {
                if importLines[filepath] == nil {
                    importLines[filepath] = findImportLines(content: filecontent)
                }
            }
            
            let imports = importLines.values.joined().map { line in
                return line.trimmingCharacters(in: CharacterSet.whitespaces)
            }
            
            let importsSet = Set(imports)
            let entities = arg.candidates.sorted{$0.1 < $1.1}.map{$0.0}
            
            let headerStr = (header ?? "") + .headerDoc
            var macroStart = ""
            var macroEnd = ""
            if let mcr = macro, !mcr.isEmpty {
                macroStart = .poundIf + mcr
                macroEnd = .poundEndIf
            }
            
            let markline = arg.namespace.isEmpty ? "" : "/// MARK - \(arg.namespace)"
            let ret = [headerStr, markline, macroStart, importsSet.joined(separator: "\n"), entities.joined(separator: "\n"), macroEnd].joined(separator: "\n\n")
            total += "\n\n" + ret
        }
    }
    
    _ = try? total.write(toFile: outputFilePath, atomically: true, encoding: .utf8)
    return total
}
