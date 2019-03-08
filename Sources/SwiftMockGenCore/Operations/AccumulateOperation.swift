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

func renderMocks(inheritanceMap: [String: (Structure, File, [Model])],
                 annotatedProtocolMap: [String: ProtocolMapEntryType],
                 semaphore: DispatchSemaphore?,
                 queue: DispatchQueue?,
                 process: @escaping (Structure, File, String) -> ()) -> Bool {
    
    if let queue = queue {
        let lock = NSLock()
        
        for key in annotatedProtocolMap.keys {
            _ = semaphore?.wait(timeout: DispatchTime.distantFuture)
            queue.async {
                _ = renderMocksForClass(inheritanceMap: inheritanceMap, key: key, annotatedProtocolMap: annotatedProtocolMap, lock: lock, process: process)
                semaphore?.signal()
            }
        }
        queue.sync(flags: .barrier) { }
    } else {
        for key in annotatedProtocolMap.keys {
            _ = renderMocksForClass(inheritanceMap: inheritanceMap, key: key, annotatedProtocolMap: annotatedProtocolMap, lock: nil, process: process)
        }
    }
    return false
}

private func renderMocksForClass(inheritanceMap: [String: (Structure, File, [Model])],
                                 key: String,
                                 annotatedProtocolMap: [String: ProtocolMapEntryType],
                                 lock: NSLock? = nil,
                                 process: @escaping (Structure, File, String) -> ()) -> Bool {
    if let val = annotatedProtocolMap[key] {
        let protocolStructure = val.structure
        let file = val.file
        
        let (models, attributes, processedResults) = lookupEntities(name: key, inheritanceMap: inheritanceMap, annotatedProtocolMap: annotatedProtocolMap)
        
        let uniqueVals = uniqueEntities(in: models).sorted { $0.value.offset < $1.value.offset }
        let renderedEntities = uniqueVals.compactMap { (name: String, model: Model) -> String? in
            return model.render(with: name)
        }

        let nonOptionalOrRxVarList = nonOptionalOrRxVars(in: models)

        let mockModel = ClassModel(protocolStructure,
                                   content: file.contents,
                                   identifier: key,
                                   additionalAttributes: attributes,
                                   initParams: nonOptionalOrRxVarList,
                                   entities: [processedResults.joined(), renderedEntities.joined(separator: "\n")])
        if let mockString = mockModel.render(with: key), !mockString.isEmpty {
            lock?.lock()
            process(protocolStructure, file, mockString)
            lock?.unlock()
        }
    }
    return false
}

private func uniqueEntities(`in` models: [Model]) -> [String: Model] {
    let entities = Dictionary(grouping: models) { $0.name }
    var result = [String: Model]()

    var keydByReturnType = [String: [Model]]()
    
    _ = entities.map { (key: String, value: [Model]) in
        if value.count > 1 {
            _ = value.map { ($0.type, $0) }.map{ (t: String, mdl: Model)  in
                if keydByReturnType[t] == nil {
                    keydByReturnType[t] = [mdl]
                } else {
                    keydByReturnType[t]?.append(mdl)
                }
            }
            
            keydByReturnType.forEach{ (t: String, mdls: [Model]) in
                if mdls.count > 1 {
                    mdls.map { result[$0.fullName] = $0 }
                } else {
                    mdls.map { result[$0.longName] = $0 }
                }
            }
        } else {
            _ = value.map { result[$0.name] = $0 }
        }
    }
    
    return result
}


private func nonOptionalOrRxVars(`in` models: [Model]) -> [VarWithOffset] {

    var result = models.compactMap { (model: Model) -> [VarWithOffset]? in
        if let processed = model as? ProcessedModel {
            return processed.nonOptionalOrRxVarList
        }
        return nil
        }.flatMap {$0}
    
    // Named params in init should be unique. Get the list of the
    // init params from the processed model to compare with the
    // VariableModels below, so no duplicate init params are added.
    let processedModelParamKeys = result.map {$0.name}
    
    let varlist = models.compactMap { (model: Model) -> VarWithOffset? in
        if let varModel = model as? VariableModel,
            varModel.canBeInitParam,
            !processedModelParamKeys.contains(varModel.name) {
            return (varModel.offset, varModel.name, varModel.type)
        }
        return nil
        }.sorted {$0.offset < $1.offset}
    
    result.append(contentsOf: varlist)
    return result
}

