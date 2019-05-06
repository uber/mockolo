import MockoloFramework


let emojiVars = """
/// \(String.mockAnnotation)
protocol EmojiVars: NonSimpleVars {
var 😂: Emoji { get set }
var 👍: Emoji { get set }
@available(iOS 10.0, *)
var 👌😳: Emoji { get set }
}
"""

let emojiVarsMock = """
import Foundation

@available(iOS 10.0, *)
class EmojiVarsMock: EmojiVars {
    init() {}
    init(😂: Emoji, 👍: Emoji, 👌😳: Emoji, dict: Dictionary<String, Int> = Dictionary<String, Int>()) {
        self.😂 = 😂
        self.👍 = 👍
        self.👌😳 = 👌😳
        self.dict = dict
    }
    var 😂SetCallCount = 0
    var underlying😂: Emoji!
    var 😂: Emoji {
        get {
            return underlying😂
        }
        set {
            underlying😂 = newValue
            😂SetCallCount += 1
        }
    }
    var 👍SetCallCount = 0
    var underlying👍: Emoji!
    var 👍: Emoji {
        get {
            return underlying👍
        }
        set {
            underlying👍 = newValue
            👍SetCallCount += 1
        }
    }
    var 👌😳SetCallCount = 0
    var underlying👌😳: Emoji!
    var 👌😳: Emoji {
        get {
            return underlying👌😳
        }
        set {
            underlying👌😳 = newValue
            👌😳SetCallCount += 1
        }
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
