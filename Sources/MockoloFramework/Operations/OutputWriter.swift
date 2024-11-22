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
func write(candidates: [(String, Int64)],
           header: String?,
           macro: String?,
           imports: String,
           helpers: [String],
           to outputFilePath: String) throws -> String {

    let entities = candidates
        .sorted { (left: (String, Int64), right: (String, Int64)) -> Bool in
            if left.1 == right.1 {
                return left.0 < right.0
            }
            return left.1 < right.1
        }
        .map{$0.0}
    
    let headerStr = (header ?? "") + .headerDoc
    var macroStart = ""
    var macroEnd = ""
    if let macro, !macro.isEmpty {
        macroStart = .poundIf + macro
        macroEnd = .poundEndIf
    }
    let ret = [
        headerStr,
        macroStart,
        imports,
        entities.joined(separator: "\n"),
        helpers.joined(separator: "\n\n"),
        macroEnd,
    ].joined(separator: "\n\n")
    let currentFileContents = try? String(contentsOfFile: outputFilePath, encoding: .utf8)
    guard currentFileContents != ret else {
        log("Not writing the file as content is unchanged", level: .info)
        return ret
    }

    _ = try ret.write(toFile: outputFilePath, atomically: true, encoding: .utf8)
    return ret
}

