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
struct Writer {
    static func execute(candidates: [(String, Int64)],
                        processedImportLines: [String: [String]],
                        pathToContentMap: [(String, String)],
                        to outputFilePath: String) -> String {
        
        var importLines = processedImportLines
        for (filepath, filecontent) in pathToContentMap {
            if importLines[filepath] == nil {
                importLines[filepath] = Resolver.findImportLines(content: filecontent)
            }
        }
        
        let imports = importLines.values.joined().map { line in
            return line.trimmingCharacters(in: CharacterSet.whitespaces)
        }
        
        let importsSet = Set(imports)
        let entities = candidates.sorted{$0.1 < $1.1}.map{$0.0}
        
        let ret = [.headerDoc, .poundIfMock, importsSet.joined(separator: "\n"), entities.joined(separator: "\n"), .poundEndIf].joined(separator: "\n")
        
        _ = try? ret.write(toFile: outputFilePath, atomically: true, encoding: .utf8)
        return ret
    }
}
