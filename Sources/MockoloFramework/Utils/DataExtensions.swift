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

extension Data {
    static public let typealiasColon = String.typealiasColon.data(using: String.Encoding.utf8)
    static public let rxColon = String.rxColon.data(using: String.Encoding.utf8)

    public func sliced(offset: Int64, length: Int64) -> Data? {
        guard offset >= 0, length > 0 else { return nil }
        let start = Int(offset)
        let end = Int(offset + length)
        guard end < self.count else { return nil }
        let subdata = self[start..<end]
        return subdata
    }

    public func toString(offset: Int64, length: Int64) -> String {
        guard let subdata = sliced(offset: offset, length: length) else { return "" }
        return String(data: subdata, encoding: .utf8) ?? ""
    }


    /// Returns import lines of a file
    /// @param content The source file content
    /// @returns A list of import lines from the content
    func findImportLines(at offset: Int64?) -> [String] {
        if let offset = offset, offset > 0 {
            let part = self.toString(offset: 0, length: offset)
            let lines = part.components(separatedBy: "\n")
            let importlines = lines.filter {$0.trimmingCharacters(in: .whitespaces).hasPrefix(String.importSpace)}
            return importlines
        }
        return []
    }

    func parseAnnotationArguments(for keys: String...) -> [String: [String: String]]? {
        let extracted = self
        var ret = [String: [String: String]]()
        for k in keys {
            if let key = k.data(using: .utf8), let keyRange = extracted.range(of: key) {
                let argsData = extracted[keyRange.endIndex...]
                let argsStr = String(data: argsData, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)
                if var mutableStr = argsStr {
                    if mutableStr.hasSuffix(")") {
                        mutableStr.removeLast()
                    }
                    let overrideArgs = mutableStr.arguments(with: String.annotationArgDelimiter)
                    ret[k] = overrideArgs
                }
            }
        }
        return ret
    }
}


