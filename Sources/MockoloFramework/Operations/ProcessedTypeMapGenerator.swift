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

/// Performs processed mock type map generation
func generateProcessedTypeMap(_ paths: [String],
                              semaphore: DispatchSemaphore?,
                              queue: DispatchQueue?,
                              process: @escaping ([Entity], [String]) -> ()) {
    if let queue = queue {
        let lock = NSLock()
        
        for filePath in paths {
            _ = semaphore?.wait(timeout: DispatchTime.distantFuture)
            queue.async {
                    _ = generateProcessedModels(filePath, lock: lock, process: process)
                semaphore?.signal()
            }
        }
        // Wait for queue to drain
        queue.sync(flags: .barrier) {}
    } else {
        for filePath in paths {
            _ = generateProcessedModels(filePath, lock: nil, process: process)
        }
    }
}

private func generateProcessedModels(_ path: String,
                                     lock: NSLock?,
                                     process: @escaping ([Entity], [String]) -> ()) -> Bool {
    guard let content = try? String(contentsOfFile: path) else { return false }
//    guard content.contains("public class") else { return false }

    if let topstructure = try? Structure(path: path) {
        let subs = topstructure.substructures
        let results = subs.compactMap { current -> Entity? in
//            if current.accessControlLevel == "public" {
            
            return Entity(name: current.name, filepath: path, content: content, ast: current, isAnnotated: false, metadata: nil, isProcessed: true)
//            }
//            return nil
        }
        
        let imports = findImportLines(content: content, offset: subs.first?.offset)
        lock?.lock()
        process(results, imports)
        lock?.unlock()
        return true
    }
    return false
}
