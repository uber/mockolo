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

/// A structure defining an "import" statement parsed by `Generator`, including various modifiers.
struct Import: CustomStringConvertible {
    
    /// The access level of the import
    enum ACL: String {
        case `private`
        case `fileprivate`
        case `internal`
        case `package`
        case `public`
        
        var rank: Int {
            switch self {
            case .private: 0
            case .fileprivate: 1
            case .internal: 2
            case .package: 3
            case .public: 4
            }
        }
    }
    
    /// A modifier that precedes the "import" keyword. ACL and "@testable" are mutually exclusive.
    enum Modifier: RawRepresentable {
        case acl(ACL)
        case testable
        
        var rawValue: String {
            switch self {
            case .acl(let acl): acl.rawValue
            case .testable: "@testable"
            }
        }
        
        init?(rawValue: String) {
            if rawValue == "@testable" {
                self = .testable
            } else if let acl = ACL(rawValue: rawValue) {
                self = .acl(acl)
            } else {
                return nil
            }
        }
    }
    
    /// Name of the module
    let moduleName: String
    
    /// A modifier preceding the "import" keyword (e.g. public, internal, @testable)
    private(set) var modifier: Modifier?
    
    /// An opaque string preceding the entire import statement (typically `#if FOO\n` for nested macro support)
    let prefix: String?
    
    /// An opaque string following the entire import statement (typically `\n#endif` for nested macro support)
    let suffix: String?
    
    var description: String {
        let line: String
        if let modifier {
            line = "\(modifier.rawValue) import \(moduleName)"
        } else {
            line = "import \(moduleName)"
        }
        return [prefix, line, suffix].compactMap { $0 }.joined()
    }
    
    init(
        moduleName: String,
        modifier: Modifier? = nil,
        prefix: String? = nil,
        suffix: String? = nil
    ) {
        self.moduleName = moduleName
        self.modifier = modifier
        self.prefix = prefix
        self.suffix = suffix
    }
}
 
extension Import {
    
    /// Returns a copy with a `.testable` modifier
    var asTestable: Import {
        var new = self
        new.modifier = .testable
        return new
    }
    
    /// Creates an `Import` by parsing a `String` provided by `Generator`.
    /// It is typically a single line, but can be wrapped by `#if FOO\n...\n#endif` when it's a nested macro.
    init?(line: String) {
        guard let importSpaceRange = line.range(of: String.importSpace) else { return nil }
        
        let firstNewlineIndex = line.firstIndex(of: "\n")
        let lastNewlineIndex = line.lastIndex(of: "\n")
        let startIndex = firstNewlineIndex ?? line.startIndex
        let endIndex = lastNewlineIndex ?? line.endIndex
        
        moduleName = String(line[importSpaceRange.upperBound..<endIndex])
        
        if importSpaceRange.lowerBound == startIndex {
            modifier = nil
        } else {
            let modifierEndIndex = line.index(before: importSpaceRange.lowerBound)
            modifier = Modifier(rawValue: String(line[startIndex..<modifierEndIndex]))
        }
        
        `prefix` = firstNewlineIndex.map { String(line[...$0]) }
        suffix = lastNewlineIndex.map { String(line[$0...]) }
    }
}

extension Array where Element == Import {
    
    /// Prepares a list of imports for output:
    /// - consolidates imports of the same module
    /// - maintains the highest given ACL for a given module
    /// - overrides the ACL for a given import with `@testable` if any are marked as such
    /// - sorts by module name
    func resolved() -> [Import] {
        var modifierByModuleName = [String: Import.Modifier]()
        var prefixByModuleName = [String: String]()
        var suffixByModuleName = [String: String]()
        
        for imp in self {
            switch (imp.modifier, modifierByModuleName[imp.moduleName]) {
            case let (.acl(acl), .acl(existingACL)):
                if acl.rank > existingACL.rank {
                    modifierByModuleName[imp.moduleName] = .acl(acl)
                }
            case (.testable, .acl(.internal)), (.testable, .acl(.package)):
                modifierByModuleName[imp.moduleName] = .testable
            case (.some(let modifier), .none):
                modifierByModuleName[imp.moduleName] = modifier
            default:
                break
            }
            
            if let prefix = imp.prefix {
                prefixByModuleName[imp.moduleName] = prefix
            }
            if let suffix = imp.suffix {
                suffixByModuleName[imp.moduleName] = suffix
            }
        }
        
        return Set(map(\.moduleName)).sorted().map {
            Import(
                moduleName: $0,
                modifier: modifierByModuleName[$0],
                prefix: prefixByModuleName[$0],
                suffix: suffixByModuleName[$0]
            )
        }
    }
    
    /// Converts a list of imports into a file-ready `String` 
    func lines() -> String {
        map { $0.description }.joined(separator: "\n")
    }
}
