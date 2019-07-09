import MockoloFramework

let duplicates4 =
"""
/// \(String.mockAnnotation)
protocol SomeVC {
func popViewController(viewController: UIViewController)
func popViewController()
}
"""

let duplicatesMock4 =
"""
class SomeVCMock: SomeVC {
    
    
    init() {
        
    }
    var popViewControllerCallCount = 0
    var popViewControllerHandler: ((UIViewController) -> ())?
    func popViewController(viewController: UIViewController)  {
        popViewControllerCallCount += 1
        if let popViewControllerHandler = popViewControllerHandler {
            popViewControllerHandler(viewController)
        }
        
    }
    var popViewController1CallCount = 0
    var popViewController1Handler: (() -> ())?
    func popViewController()  {
        popViewController1CallCount += 1
        if let popViewController1Handler = popViewController1Handler {
            popViewController1Handler()
        }
        
    }
}

"""


let duplicates5 =
"""
public protocol Bar2 {
func customize(text: String?)

}
public protocol Bar3 {
func customize(text: String?)
}

public protocol Bar4 {
func customize(text: String?, textColor: UIColor?)
}

public protocol Bar5 {
func customize(text: String?, textColor: UIColor?, loadId: String?)
}

/// \(String.mockAnnotation)
public protocol Foo: Bar2, Bar3, Bar4, Bar5 {
}
"""


let duplicatesMock5 =
"""
public class FooMock: Foo {
    
    
    public init() {
        
    }
    var customizeCallCount = 0
    public var customizeHandler: ((String?) -> ())?
    public func customize(text: String?)  {
        customizeCallCount += 1
        if let customizeHandler = customizeHandler {
            customizeHandler(text)
        }
        
    }
    var customizeTextCallCount = 0
    public var customizeTextHandler: ((String?, UIColor?) -> ())?
    public func customize(text: String?, textColor: UIColor?)  {
        customizeTextCallCount += 1
        if let customizeTextHandler = customizeTextHandler {
            customizeTextHandler(text, textColor)
        }
        
    }
    var customizeTextTextColorCallCount = 0
    public var customizeTextTextColorHandler: ((String?, UIColor?, String?) -> ())?
    public func customize(text: String?, textColor: UIColor?, loadId: String?)  {
        customizeTextTextColorCallCount += 1
        if let customizeTextTextColorHandler = customizeTextTextColorHandler {
            customizeTextTextColorHandler(text, textColor, loadId)
        }
        
    }
}
"""


let sameVarFuncName = """
/// \(String.mockAnnotation)
public protocol Bar: class {
var talk: Int { get }
}

/// \(String.mockAnnotation)
public protocol Foo: Bar {
func talk(_ dismiss: Bool)
}
"""

let sameVarFuncNameMock =

"""
public class BarMock: Bar {
    
    public init() {}
    public init(talk: Int = 0) {
        self.talk = talk
    }
    var talkSetCallCount = 0
    var underlyingTalk: Int = 0
    public var talk: Int {
        get {
            return underlyingTalk
        }
        set {
            underlyingTalk = newValue
            talkSetCallCount += 1
        }
    }
}

public class FooMock: Foo {
    
    public init() {}
    public init(talk: Int = 0) {
        self.talk = talk
    }
    var talkSetCallCount = 0
    var underlyingTalk: Int = 0
    public var talk: Int {
        get {
            return underlyingTalk
        }
        set {
            underlyingTalk = newValue
            talkSetCallCount += 1
        }
    }
    var talkDismissCallCount = 0
    public var talkDismissHandler: ((Bool) -> ())?
    public func talk(_ dismiss: Bool)  {
        talkDismissCallCount += 1
        if let talkDismissHandler = talkDismissHandler {
            talkDismissHandler(dismiss)
        }
        
    }
}

"""
