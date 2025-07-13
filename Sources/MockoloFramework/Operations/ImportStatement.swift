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
        var directiveId: Int
        var parentDirectiveId: Int?
        var clauseId: Int
        var condition: String?
        
        init(
            clauseType: IfMacroModel.Clause.ClauseType,
            directiveId: Int,
            parentDirectiveId: Int?,
            clauseId: Int,
            condition: String?
        ) {
            self.clauseType = clauseType
            self.directiveId = directiveId
            self.parentDirectiveId = parentDirectiveId
            self.clauseId = clauseId
            self.condition = condition
        }
    }
    
    var line: String
    var insideDirective: InsideDirective?
    
    init(line: String, insideDirective: InsideDirective? = nil) {
        self.line = line
        self.insideDirective = insideDirective
    }
}
