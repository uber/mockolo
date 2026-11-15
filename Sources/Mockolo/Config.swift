import ArgumentParser
import Foundation
import MockoloFramework

struct Config: Decodable {
    var sources: [String]?
    var destination: String?
    var module: String?
    var dependencies: [String: [String]]?
}

struct ConfigFile {
    var path: String
    var config: Config

    private var directory: String {
        URL(fileURLWithPath: path).deletingLastPathComponent().path
    }

    var destinationPath: String? {
        config.destination.map { resolvePath($0, relativeTo: directory) }
    }

    static func load(from path: String) throws -> ConfigFile {
        guard let data = FileManager.default.contents(atPath: path) else {
            throw ValidationError("\(path): could not read file")
        }
        let config = try ConfigSchema.decode(data, path: path)
        if config.module?.isEmpty == true {
            throw ValidationError("\(path): module: must not be empty")
        }
        if config.dependencies?.keys.contains("") == true {
            throw ValidationError("\(path): dependencies: module name must not be empty")
        }
        return ConfigFile(path: path, config: config)
    }

    func sourceFiles() throws -> [String] {
        try files(config.sources ?? [], keyPath: "sources")
    }

    func dependencyFiles() throws -> [String] {
        try (config.dependencies ?? [:]).sorted { $0.key < $1.key }.flatMap { module, paths in
            try files(paths, keyPath: "dependencies.\(module)")
        }
    }

    /// Resolves `paths` against the config file's directory and expands directories to the files they contain.
    private func files(_ paths: [String], keyPath: String) throws -> [String] {
        var result = [String]()
        for (index, entry) in paths.enumerated() {
            let resolved = resolvePath(entry, relativeTo: directory)
            var isDirectory: ObjCBool = false
            guard FileManager.default.fileExists(atPath: resolved, isDirectory: &isDirectory) else {
                throw ValidationError("\(path): \(keyPath)[\(index)]: no such file or directory: \(resolved)")
            }
            if isDirectory.boolValue {
                var contents = [String]()
                scanDirs([resolved]) { contents.append($0) }
                result.append(contentsOf: contents.sorted())
            } else {
                result.append(resolved)
            }
        }
        return result
    }
}

func resolvePath(_ path: String, relativeTo base: String) -> String {
    if path.hasPrefix("/") {
        return path
    }
    if path.hasPrefix("~") {
        let home = FileManager.default.homeDirectoryForCurrentUser.path
        return path.replacingOccurrences(of: "~", with: home, range: path.range(of: "~"))
    }
    return base + "/" + path
}
