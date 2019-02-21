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
import Utility
import Basic

func main() {
    
    let parser = ArgumentParser(usage: "<subcommand> <options>", overview: "Swift mock generator.")
    let command = ExecuteCommand(name: "generate", overview: "Generates mock classes for a specified target.", parser: parser)
    let inputs = Array(CommandLine.arguments.dropFirst())

    print("Start...")
    do {
        /* Example:
         .build/release/swiftmockgen generate
         --sourcefiles apps/src/File1.swift, apps/src/File2.swift
         --outputfile apps/result/Mocks.swift
         --mockfiles "apps/libFoo/FooMocks.swift", "apps/libBar/BarMocks.swift"
         --exclude-suffixes "Mocks", "Tests", "Models", "Services"
         */
        let args = try parser.parse(inputs)
        command.execute(with: args)
    } catch {
        fatalError("Command-line pasing error (use --help for help): \(error)")
    }
    
    print("Done.")
}


main()
