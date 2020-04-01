import MockoloFramework

let overload6 =
"""
/// \(String.mockAnnotation)
protocol SomeVC {
func popViewController(viewController: UIViewController)
func popViewController()
}
"""

let overloadMock6 =
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


let overload7 =
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


let overloadMock7 =
"""
public class FooMock: Foo {
    
    

    public init() {
        
    }
    public var customizeCallCount = 0
    public var customizeHandler: ((String?) -> ())?
    public func customize(text: String?)  {
        customizeCallCount += 1
        if let customizeHandler = customizeHandler {
            customizeHandler(text)
        }
        
    }
    public var customizeTextCallCount = 0
    public var customizeTextHandler: ((String?, UIColor?) -> ())?
    public func customize(text: String?, textColor: UIColor?)  {
        customizeTextCallCount += 1
        if let customizeTextHandler = customizeTextHandler {
            customizeTextHandler(text, textColor)
        }
        
    }
    public var customizeTextTextColorCallCount = 0
    public var customizeTextTextColorHandler: ((String?, UIColor?, String?) -> ())?
    public func customize(text: String?, textColor: UIColor?, loadId: String?)  {
        customizeTextTextColorCallCount += 1
        if let customizeTextTextColorHandler = customizeTextTextColorHandler {
            customizeTextTextColorHandler(text, textColor, loadId)
        }
        
    }
}
"""


let sameNameVarFunc = """
/// \(String.mockAnnotation)
public protocol Bar: class {
var talk: Int { get }
}

/// \(String.mockAnnotation)
public protocol Foo: Bar {
func talk(_ dismiss: Bool)
}
"""

let sameNameVarFuncMock = """

public class BarMock: Bar {
    
    
    
    public init() {  }
    public init(talk: Int = 0) {
        self.talk = talk
        
    }
    public var talkSetCallCount = 0
    public var talk: Int = 0 { didSet { talkSetCallCount += 1 } }
}

public class FooMock: Foo {
    
    
    
    public init() {  }
    public init(talk: Int = 0) {
        self.talk = talk
        
    }
    public var talkSetCallCount = 0
    public var talk: Int = 0 { didSet { talkSetCallCount += 1 } }
    public var talkDismissCallCount = 0
    public var talkDismissHandler: ((Bool) -> ())?
    public func talk(_ dismiss: Bool)  {
        talkDismissCallCount += 1
        if let talkDismissHandler = talkDismissHandler {
            talkDismissHandler(dismiss)
        }
        
    }
}

"""
