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

public class ParserViaSourceKit: SourceParsing {
    
    public init() {}
    
    public func parseProcessedDecls(_ paths: [String],
                                    fileMacro: String?,
                                    completion: @escaping ([Entity], ImportMap?) -> ()) {
        scan(paths) { (filePath, lock) in
            self.generateProcessedASTs(filePath, lock: lock, completion: completion)
        }
    }
    
    public func parseDecls(_ paths: [String]?,
                           isDirs: Bool,
                           exclusionSuffixes: [String]? = nil,
                           annotation: String,
                           fileMacro: String?,
                           declType: DeclType,
                           completion: @escaping ([Entity], ImportMap?) -> ()) {
        guard !annotation.isEmpty else { return }
        guard let paths = paths else { return }
        if isDirs {
            generateASTs(dirs: paths, exclusionSuffixes: exclusionSuffixes, annotation: annotation, fileMacro: fileMacro, declType: declType, completion: completion)
        } else {
            generateASTs(files: paths, exclusionSuffixes: exclusionSuffixes, annotation: annotation, fileMacro: fileMacro, declType: declType, completion: completion)
        }
    }
    
    private func generateASTs(dirs: [String],
                              exclusionSuffixes: [String]? = nil,
                              annotation: String,
                              fileMacro: String?,
                              declType: DeclType,
                              completion: @escaping ([Entity], ImportMap?) -> ()) {
        
        guard let annotationData = annotation.data(using: .utf8) else {
            fatalError("Annotation is invalid: \(annotation)")
        }
        
        scan(dirs: dirs) { (path, lock) in
            self.generateASTs(path,
                              exclusionSuffixes: exclusionSuffixes,
                              annotationData: annotationData,
                              declType: declType,
                              lock: lock,
                              completion: completion)
        }
    }
    
    private func generateASTs(files: [String],
                              exclusionSuffixes: [String]? = nil,
                              annotation: String,
                              fileMacro: String?,
                              declType: DeclType,
                              completion: @escaping ([Entity], ImportMap?) -> ()) {
        guard let annotationData = annotation.data(using: .utf8) else {
            fatalError("Annotation is invalid: \(annotation)")
        }
        
        scan(files) { (path, lock) in
            self.generateASTs(path,
                              exclusionSuffixes: exclusionSuffixes,
                              annotationData: annotationData,
                              declType: declType,
                              lock: lock,
                              completion: completion)
        }
    }
    
    private func generateASTs(_ path: String,
                              exclusionSuffixes: [String]? = nil,
                              annotationData: Data,
                              declType: DeclType,
                              lock: NSLock?,
                              completion: @escaping ([Entity], ImportMap?) -> ()) {
        
        guard path.shouldParse(with: exclusionSuffixes) else { return }
        guard let content = FileManager.default.contents(atPath: path) else {
            fatalError("Retrieving contents of \(path) failed")
        }
        
        do {
            var results = [Entity]()
            let topstructure = try Structure(path: path)
            for current in topstructure.substructures {
                var parseCurrent = false
                switch declType {
                case .protocolType:
                    parseCurrent = current.isProtocol
                case .classType:
                    parseCurrent = current.isClass
                case .other:
                    parseCurrent = false
                case .all:
                    parseCurrent = true
                }
                
                guard parseCurrent else { continue }
                let metadata = current.annotationMetadata(with: annotationData, in: content)
                if let node = Entity.node(with: current, filepath: path, data: content, isPrivate: current.isPrivate, isFinal: current.isFinal, metadata: metadata, processed: false) {
                    results.append(node)
                }
            }
            
            lock?.lock()
            completion(results, nil)
            lock?.unlock()
            
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    private func generateProcessedASTs(_ path: String,
                                       lock: NSLock?,
                                       completion: @escaping ([Entity], ImportMap?) -> ()) {
        
        guard let content = FileManager.default.contents(atPath: path) else {
            fatalError("Retrieving contents of \(path) failed")
        }
        
        do {
            let topstructure = try Structure(path: path)
            let subs = topstructure.substructures
            let results = subs.compactMap { current -> Entity? in
                return Entity.node(with: current, filepath: path, data: content, isPrivate: current.isPrivate, isFinal: current.isFinal, metadata: nil, processed: true)
            }
            
            let imports = content.findImportLines(at: subs.first?.offset)
            lock?.lock()
            completion(results, [path: ["": imports]])
            lock?.unlock()
        } catch {
            fatalError(error.localizedDescription)
        }
    }
}


