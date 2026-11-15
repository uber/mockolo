import ArgumentParser
import Foundation

enum ConfigSchema {
    private indirect enum Shape: CustomStringConvertible {
        case string
        case integer
        case boolean
        case array(Shape)
        case map(Shape)

        var description: String {
            switch self {
            case .string: "string"
            case .integer: "integer"
            case .boolean: "boolean"
            case .array(let element): "array of \(element)s"
            case .map: "object"
            }
        }
    }

    private enum JSONValue: Decodable {
        case null
        case bool
        case integer
        case number
        case string
        case array([JSONValue])
        case object([String: JSONValue])

        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if container.decodeNil() {
                self = .null
            } else if try attempt(Bool.self) != nil {
                self = .bool
            } else if let isInteger = isInteger() {
                self = isInteger ? .integer : .number
            } else if try attempt(String.self) != nil {
                self = .string
            } else if let values = try attempt([JSONValue].self) {
                self = .array(values)
            } else {
                self = .object(try container.decode([String: JSONValue].self))
            }

            func attempt<T: Decodable>(_ type: T.Type) throws -> T? {
                do {
                    return try container.decode(type)
                } catch DecodingError.typeMismatch {
                    return nil
                }
            }
            /// True for an Int, false for any other number (a fraction or out of range), nil for a non-number.
            func isInteger() -> Bool? {
                do {
                    return try attempt(Int.self) != nil ? true : nil
                } catch {
                    return false
                }
            }
        }
    }

    private static let schema: [String: Shape] = [
        "sources": .array(.string),
        "destination": .string,
        "module": .string,
        "dependencies": .map(.array(.string)),
        "annotation": .string,
        "header": .string,
        "macro": .string,
        "concurrencyLimit": .integer,
        "loggingLevel": .integer,
        "mockFinal": .boolean,
        "enableArgsHistory": .boolean,
        "mockAll": .boolean,
        "allowSetCallCount": .boolean,
        "disableCombineDefaultValues": .boolean,
        "useTemplateFunc": .boolean,
        "customImports": .array(.string),
        "testableImports": .array(.string),
        "excludeImports": .array(.string),
        "excludeSuffixes": .array(.string),
        "mockfiles": .array(.string),
    ]

    static func decode(_ data: Data, path: String) throws -> Config {
        let decoder = JSONDecoder()
        #if canImport(Darwin) || compiler(>=6.0)
        decoder.allowsJSON5 = true
        #endif
        let json: JSONValue
        do {
            json = try decoder.decode(JSONValue.self, from: data)
        } catch DecodingError.dataCorrupted(let context) {
            let underlying = context.underlyingError.map {
                ($0 as NSError).userInfo[NSDebugDescriptionErrorKey] as? String ?? "\($0)"
            } ?? context.debugDescription
            throw ValidationError("\(path): invalid JSON5: \(underlying)")
        }
        guard case .object(let object) = json else {
            throw ValidationError("\(path): expected object")
        }
        if let unknown = object.keys.filter({ schema[$0] == nil }).min() {
            throw ValidationError("\(path): \(unknown): unknown key")
        }
        let mismatches = object.sorted { $0.key < $1.key }.lazy.compactMap { key, value in
            schema[key].flatMap { mismatch(value, $0, at: key) }
        }
        if let error = mismatches.first {
            throw ValidationError("\(path): \(error)")
        }
        return try decoder.decode(Config.self, from: data)
    }

    /// Returns "<key path>: expected <shape>" for the first value in `value` that does not match `shape`.
    private static func mismatch(_ value: JSONValue, _ shape: Shape, at keyPath: String) -> String? {
        switch (shape, value) {
        case (.string, .string), (.integer, .integer), (.boolean, .bool):
            return nil
        case (.array(let element), .array(let values)):
            return values.indices.lazy.compactMap { mismatch(values[$0], element, at: "\(keyPath)[\($0)]") }.first
        case (.map(let element), .object(let values)):
            return values.sorted { $0.key < $1.key }.lazy.compactMap { key, value in
                mismatch(value, element, at: "\(keyPath).\(key)")
            }.first
        default:
            return "\(keyPath): expected \(shape)"
        }
    }
}
