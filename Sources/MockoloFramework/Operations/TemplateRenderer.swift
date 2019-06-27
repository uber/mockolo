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
                     typeKeys: [String: String]?,
                     semaphore: DispatchSemaphore?,
                     queue: DispatchQueue?,
                     process: @escaping (String, String, Int64) -> ()) {
    if let queue = queue {
        let lock = NSLock()
        for element in entities {
            _ = semaphore?.wait(timeout: DispatchTime.distantFuture)
            queue.async {
                _ = renderTemplates(resolvedEntity: element, typeKeys: typeKeys, lock: lock, process: process)
                semaphore?.signal()
            }
        }
        queue.sync(flags: .barrier) { }
    } else {
        for element in entities {
            _ = renderTemplates(resolvedEntity: element, typeKeys: typeKeys, lock: nil, process: process)
        }
    }
}

private func renderTemplates(resolvedEntity: ResolvedEntity,
                             typeKeys: [String: String]?,
                             lock: NSLock? = nil,
                             process: @escaping (String, String, Int64) -> ()) -> Bool {
    
    let mockModel = resolvedEntity.model()
    if let mockString = mockModel.render(with: resolvedEntity.identifier, typeKeys: typeKeys), !mockString.isEmpty {
        lock?.lock()
        process(resolvedEntity.namespace, mockString, mockModel.offset)
        lock?.unlock()
        return true
    }
    return false
}

