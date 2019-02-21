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

func generateParentMocksMap(_ paths: [String],
                            exclude: [String]? = nil,
                            semaphore: DispatchSemaphore?,
                            timeout: Int,
                            queue: DispatchQueue?,
                            process: @escaping (Structure, File, [Model]) -> ()) -> Int {
    var count = 0
    if let queue = queue {
        let lock = NSLock()
        
        for filePath in paths {
            _ = semaphore?.wait(timeout: DispatchTime.now() + DispatchTimeInterval.seconds(timeout))
            queue.async {
                let result = generateProcessedModels(filePath, lock: lock, process: process)
                count += result ? 1 : 0
                semaphore?.signal()
            }
        }
        // Wait for queue to drain
        queue.sync(flags: .barrier) {}
    } else {
        for filePath in paths {
            let result = generateProcessedModels(filePath, lock: nil, process: process)
            count += result ? 1 : 0
        }
    }
    
    return count
}

private func generateProcessedModels(_ path: String,
                                     lock: NSLock?,
                                     process: @escaping (Structure, File, [Model]) -> ()) -> Bool {
    guard let file = File(path: path) else { return false }

    if let topstructure = try? Structure(file: file) {
        
        for substructure in topstructure.substructures {
            if substructure.isClass, substructure.name.hasSuffix("Mock") {
                let childEntities = substructure.substructures.compactMap { (child: Structure) -> Model? in
                    return model(for: child, content: file.contents, processed: true)
                }
                lock?.lock()
                process(substructure, file, childEntities)
                lock?.unlock()
            }
        }
        return true
    }
    return false
}

