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


public struct ImportStatement: Hashable {
    
    struct InsideDirective: Hashable {
        var clauseType: IfMacroModel.Clause.ClauseType
        var blockId: String
        var condition: String?
        var key: String {
            "\(condition ?? ""):\(blockId):\(clauseType)"
        }
        var sortedKey: String? {
            clauseType == .if ? (condition ?? "") + blockId : nil
        }
        
        init?(key: String) {
            let parts = key.split(separator: ":").map { String($0) }
            guard let clauseType = IfMacroModel.Clause.ClauseType(parts[2]) else {
                return nil
            }
            self.clauseType = clauseType
            self.blockId = parts[1]
            self.condition = switch clauseType {
                case .if, .elseif:
                parts[0]
            case .else:
                nil
            }
        }
    }
    
    var line: String
    var insideDirective: InsideDirective?
    
    init(line: String, compilerDirectiveKey: String? = nil) {
        self.line = line
        if let compilerDirectiveKey {
            self.insideDirective = .init(key: compilerDirectiveKey)
        }
    }
    
    mutating func makeTestable() {
        line = line.asTestableImport
    }
}
