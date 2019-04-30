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
struct ProcessedTypeMapGenerator {
    static func execute(_ paths: [String],
                        semaphore: DispatchSemaphore?,
                        timeout: Int,
                        queue: DispatchQueue?,
                        process: @escaping ([Entity], [String]) -> ()) -> Int {
        var count = 0
        if let queue = queue {
            let lock = NSLock()
            
            for filePath in paths {
                _ = semaphore?.wait(timeout: DispatchTime.now() + DispatchTimeInterval.seconds(timeout))
                queue.async {
                    if let content = try? String(contentsOfFile: filePath) {
                        let result = generateProcessedModels(filePath, content: content, lock: lock, process: process)
                        count += result ? 1 : 0
                    }
                    semaphore?.signal()
                }
            }
            // Wait for queue to drain
            queue.sync(flags: .barrier) {}
        } else {
            for filePath in paths {
                if let content = try? String(contentsOfFile: filePath) {
                    let result = generateProcessedModels(filePath, content: content, lock: nil, process: process)
                    count += result ? 1 : 0
                }
            }
        }
        
        return count
    }
    
    static private func generateProcessedModels(_ path: String,
                                                content: String,
                                                lock: NSLock?,
                                                process: @escaping ([Entity], [String]) -> ()) -> Bool {
        guard let content = try? String(contentsOfFile: path) else { return false }
        let imports = Resolver.findImportLines(content: content)
        
        if let topstructure = try? Structure(path: path) {
            let results = topstructure.substructures.map { current -> Entity in
                
                let node = Entity(name: current.name, filepath: path, content: content, ast: current, isAnnotated: false, isProcessed: true, models: nil, attributes: nil)
                return node
            }
            
            lock?.lock()
            process(results, imports)
            lock?.unlock()
            return true
        }
        return false
    }
    
}
