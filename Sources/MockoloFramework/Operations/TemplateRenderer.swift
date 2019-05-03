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
import SourceKittenFramework

/// Renders models with temeplates for output

func renderTemplates(entities: [ResolvedEntity],
                     typeKeys: [String],
                     semaphore: DispatchSemaphore?,
                     timeout: Int,
                     queue: DispatchQueue?,
                     process: @escaping (String, Int64) -> ()) -> Int {
    var count = 0
    if let queue = queue {
        let lock = NSLock()
        for element in entities {
            _ = semaphore?.wait(timeout: DispatchTime.now() + DispatchTimeInterval.seconds(timeout))
            queue.async {
                let result = renderTemplates(entityMetadata: element, typeKeys: typeKeys, lock: lock, process: process)
                count += result ? 1 : 0
                semaphore?.signal()
            }
        }
        queue.sync(flags: .barrier) { }
    } else {
        for element in entities {
            let result = renderTemplates(entityMetadata: element, typeKeys: typeKeys, lock: nil, process: process)
            count += result ? 1 : 0
        }
    }
    
    return count
}

private func renderTemplates(entityMetadata: ResolvedEntity,
                             typeKeys: [String]?,
                             lock: NSLock? = nil,
                             process: @escaping (String, Int64) -> ()) -> Bool {
    
    let renderedEntities = entityMetadata.uniqueModels
        .compactMap { (name: String, model: Model) -> String? in
            return model.render(with: name, typeKeys: typeKeys)
    }
    
    let mockModel = ClassModel(entityMetadata.entity.ast,
                               content: entityMetadata.entity.content,
                               identifier: entityMetadata.key,
                               additionalAttributes: entityMetadata.attributes,
                               initParams: entityMetadata.initVars,
                               entities: [renderedEntities.joined(separator: "\n")])
    
    if let mockString = mockModel.render(with: entityMetadata.key, typeKeys: typeKeys), !mockString.isEmpty {
        lock?.lock()
        process(mockString, entityMetadata.entity.ast.offset)
        lock?.unlock()
        return true
    }
    return false
}

