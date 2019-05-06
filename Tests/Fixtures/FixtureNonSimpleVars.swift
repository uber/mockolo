import MockoloFramework

let nonSimpleVars = """
import Foundation

/// \(String.mockAnnotation)
@objc
public protocol NonSimpleVars {
@available(iOS 10.0, *)
var dict: Dictionary<String, Int> { get set }
}
"""

let nonSimpleVarsMock = """
import Foundation

@available(iOS 10.0, *)
public class NonSimpleVarsMock: NonSimpleVars {
    @available(iOS 10.0, *)
    public init() {}
    public init(dict: Dictionary<String, Int> = Dictionary<String, Int>()) {
        self.dict = dict
    }
    var dictSetCallCount = 0
    var underlyingDict: Dictionary<String, Int> = Dictionary<String, Int>()
    public var dict: Dictionary<String, Int> {
        get {
            return underlyingDict
        }
        set {
            underlyingDict = newValue
            dictSetCallCount += 1
        }
    }
}
"""
