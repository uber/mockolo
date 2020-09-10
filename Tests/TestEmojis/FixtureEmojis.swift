import MockoloFramework


let emojiVars = """
/// \(String.mockAnnotation)
protocol EmojiVars: EmojiParent {
    @available(iOS 10.0, *)
    var 😂: Emoji { get set }
}

"""

let emojiParentMock =
"""
import Foundation

public class EmojiParentMock: EmojiParent {
    init(👌😳👍: Emoji, dict: Dictionary<String, Int> = Dictionary<String, Int>()) {
        self.dict = dict
        self._👌😳👍 = 👌😳👍
    }

    private(set) var dictSetCallCount = 0
    var dict: Dictionary<String, Int> = Dictionary<String, Int>() { didSet { dictSetCallCount += 1 } }

    private(set) var 👍SetCallCount = 0
    private var _👍: Emoji!  { didSet { 👍SetCallCount += 1 } }
    var 👍: Emoji {
        get { return _👍 }
        set { _👍 = newValue }
    }
    
    private(set) var 👌😳👍SetCallCount = 0
    private(set) var _👌😳👍: Emoji! { didSet { 👌😳👍SetCallCount += 1 } }
    var 👌😳👍: Emoji {
        get { return _👌😳👍 }
        set { _👌😳👍 = newValue }
    }
}

"""


let emojiVarsMock = """
@available(iOS 10.0, *)
class EmojiVarsMock: EmojiVars {
    init() { }
    init(😂: Emoji) {
        self._😂 = 😂
    }


    private(set) var 😂SetCallCount = 0
    private var _😂: Emoji!  { didSet { 😂SetCallCount += 1 } }
    var 😂: Emoji {
        get { return _😂 }
        set { _😂 = newValue }
    }
}

"""


let emojiCombMock = """
import Foundation


@available(iOS 10.0, *)
class EmojiVarsMock: EmojiVars {
    init() { }
    init(😂: Emoji, dict: Dictionary<String, Int> = Dictionary<String, Int>(), 👍: Emoji, 👌😳👍: Emoji) {
        self._😂 = 😂
        self.dict = dict
        self._👍 = 👍
        self._👌😳👍 = 👌😳👍
    }


    private(set) var 😂SetCallCount = 0
    private var _😂: Emoji!  { didSet { 😂SetCallCount += 1 } }
    var 😂: Emoji {
        get { return _😂 }
        set { _😂 = newValue }
    }
    private(set) var dictSetCallCount = 0
    var dict: Dictionary<String, Int> = Dictionary<String, Int>() { didSet { dictSetCallCount += 1 } }
    private(set) var 👍SetCallCount = 0
    private var _👍: Emoji!  { didSet { 👍SetCallCount += 1 } }
    var 👍: Emoji {
        get { return _👍 }
        set { _👍 = newValue }
    }
    
    private(set) var 👌😳👍SetCallCount = 0
    private(set) var _👌😳👍: Emoji! { didSet { 👌😳👍SetCallCount += 1 } }
    var 👌😳👍: Emoji {
        get { return _👌😳👍 }
        set { _👌😳👍 = newValue }
    }
}

"""

let familyEmoji =
"""
/// \(String.mockAnnotation)
protocol Family: FamilyEmoji {
    var 안녕하세요: String { get set }
}
"""

let familyEmojiParentMock =
"""
class FamilyEmojiMock: FamilyEmoji {
    init() {}
    init(👪🏽: Int = 0) {
        self._👪🏽 = 👪🏽
    }
    
    var 👪🏽SetCallCount = 0
    private var _👪🏽: Int = 0
    var 👪🏽: Int {
        get { return _👪🏽 }
        set { _👪🏽 = newValue }
    }
}
"""

let familyEmojiMock =
"""
class FamilyMock: Family {
    init() {}
    init(안녕하세요: String = "", 👪🏽: Int = 0) {
        self.안녕하세요 = 안녕하세요
        self.👪🏽 = 👪🏽
    }
    
    var 안녕하세요SetCallCount = 0
    var underlying안녕하세요: String = ""
    var 안녕하세요: String {
        get {
            return underlying안녕하세요
        }
        set {
            underlying안녕하세요 = newValue
            안녕하세요SetCallCount += 1
        }
    }
    var 👪🏽SetCallCount = 0
    var underlying👪🏽: Int = 0
    var 👪🏽: Int {
        get {
            return underlying👪🏽
        }
        set {
            underlying👪🏽 = newValue
            👪🏽SetCallCount += 1
        }
    }
}
"""


let krJp =
"""
/// \(String.mockAnnotation)
protocol Hello: Hi {
    var 天気が: String { get set }
}
"""

let krJpParentMock =
"""
class HiMock: Hi {
    init() {}
    init(연락하기: Int = 0) {
        self._연락하기 = 연락하기
    }

    var 연락하기SetCallCount = 0
    private var _연락하기: Int = 0
    var 연락하기: Int {
        get { return _연락하기 }
        set { _연락하기 = newValue }
    }
}
"""

let krJpMock =
"""

class HelloMock: Hello {
    init() {}
    init(天気が: String = "", 연락하기: Int = 0) {
        self.天気が = 天気が
        self.연락하기 = 연락하기
    }

    var 天気がSetCallCount = 0
    var underlying天気が: String = ""
    var 天気が: String {
        get {
            return underlying天気が
        }
        set {
            underlying天気が = newValue
            天気がSetCallCount += 1
        }
    }
    var 연락하기SetCallCount = 0
    var underlying연락하기: Int = 0
    var 연락하기: Int {
        get {
            return underlying연락하기
        }
        set {
            underlying연락하기 = newValue
            연락하기SetCallCount += 1
        }
    }
}

"""

