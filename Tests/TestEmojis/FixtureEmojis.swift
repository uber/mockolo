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

class EmojiParentMock: EmojiParent {
    private var _doneInit = false
    init(😂: Emoji, 👌😳👍: Emoji, dict: Dictionary<String, Int> = Dictionary<String, Int>()) {
        self.dict = dict
        self.😂 = 😂
        self.👌😳👍 = 👌😳👍
        _doneInit = true
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
            if _doneInit { 👍SetCallCount += 1 }
        }
    }
    
    var 👌😳👍SetCallCount = 0
    var underlying👌😳👍: Emoji!
    var 👌😳👍: Emoji {
        get {
            return underlying👌😳👍
        }
        set {
            underlying👌😳👍 = newValue
            if _doneInit { 👌😳👍SetCallCount += 1 }
        }
    }


"""


let emojiVarsMock =
"""
    @available(iOS 10.0, *)
    class EmojiVarsMock: EmojiVars {

        private var _doneInit = false
        init() { _doneInit = true }
        init(😂: Emoji) {
            self.😂 = 😂
            _doneInit = true
        }
            
        var 😂SetCallCount = 0
        var underlying😂: Emoji!
        var 😂: Emoji {
            get { return underlying😂 }
            set {
                underlying😂 = newValue
                if _doneInit { 😂SetCallCount += 1 }
            }
        }
    }
"""


let emojiCombMock =
"""
    import Foundation

    @available(iOS 10.0, *)
    class EmojiVarsMock: EmojiVars {

        private var _doneInit = false
            init() { _doneInit = true }
        init(😂: Emoji, dict: Dictionary<String, Int> = Dictionary<String, Int>(), 👍: Emoji, 👌😳👍: Emoji) {
            self.😂 = 😂
            self.dict = dict
            self.👍 = 👍
            self.👌😳👍 = 👌😳👍
            _doneInit = true
        }
            
        var 😂SetCallCount = 0
        var underlying😂: Emoji!
        var 😂: Emoji {
            get { return underlying😂 }
            set {
                underlying😂 = newValue
                if _doneInit { 😂SetCallCount += 1 }
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
                if _doneInit { 👍SetCallCount += 1 }
            }
        }
    var 👌😳👍SetCallCount = 0
    var underlying👌😳👍: Emoji!
    var 👌😳👍: Emoji {
            get {
                return underlying👌😳👍
            }
            set {
                underlying👌😳👍 = newValue
                if _doneInit { 👌😳👍SetCallCount += 1 }
            }
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
        self.👪🏽 = 👪🏽
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
        self.연락하기 = 연락하기
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

