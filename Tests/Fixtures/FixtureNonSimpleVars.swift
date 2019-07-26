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


let emojiVars = """
/// \(String.mockAnnotation)
protocol EmojiVars: EmojiParent {
    @available(iOS 10.0, *)
    var 😂: Emoji { get set }
}
"""


let emojiParentMock = """
import Foundation

class EmojiParentMock: EmojiParent {
init(😂: Emoji, 👌😳: Emoji, dict: Dictionary<String, Int> = Dictionary<String, Int>()) {
    self.dict = dict
    self.😂 = 😂
    self.👌😳 = 👌😳
}
var dict: Dictionary<String, Int> { get set }

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


"""


let emojiVarsMock =
"""
@available(iOS 10.0, *)
class EmojiVarsMock: EmojiVars {
    
    
    init() {}
    init(😂: Emoji) {
        self.😂 = 😂
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
}

"""

let emojiCombMock =
"""
import Foundation

@available(iOS 10.0, *)
class EmojiVarsMock: EmojiVars {
    
    
    init() {}
    init(😂: Emoji, dict: Dictionary<String, Int> = Dictionary<String, Int>(), 👍: Emoji, 👌😳: Emoji) {
        self.😂 = 😂
        self.dict = dict
        self.👍 = 👍
        self.👌😳 = 👌😳
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
    var dict: Dictionary<String, Int> { get set }
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
}

"""

