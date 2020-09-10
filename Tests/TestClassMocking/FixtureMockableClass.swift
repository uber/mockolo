import MockoloFramework

let klass =
"""
/// \(String.mockAnnotation)
public class Low: Mid {

    var name: String = "k2"

    required init(arg: String) {
        super.init(orderId: 1)
        self.name = arg
    }

    required init(orderId: Int) {
        super.init(orderId: orderId)
    }

    init(i: Int) {
        super.init(orderId: i)
    }

    convenience init(d: Double) {
        self.init(i: 1)
    }

    override var what: Float {
        get {
            return 3.4
        }
        set {}
    }

    override func bar() {
        
    }

    func foo() -> Int {
        return 5
    }

    private func omg() {

    }
}

public class Mid: High {
    var what: Float = 0.0
    func bar() {}
}
"""

let klassParent =
"""
public class High {
    required init(orderId: Int) {
        self.order = orderId
    }
     init(orderId: Int, loc: String) {
        self.order = orderId
    }
    var order: Int
    func baz() -> Double { return 5.6 }
}
"""

let klassParentMock =
"""
public class HighMock: High {
    

    required init(orderId: Int) {
        super.init(orderId: orderId)
        
    }

    override init(orderId: Int, loc: String) {
        super.init(orderId: orderId, loc: loc)
        
    }

    private(set) var orderSetCallCount = 0
    private(set) var underlyingOrder: Int = 0
    override var order: Int {
        get { return underlyingOrder }
        set {
            underlyingOrder = newValue
            if _doneInit { orderSetCallCount += 1 }
        }
    }

    private(set) var bazCallCount = 0
    var bazHandler: (() -> (Double))?
    override func baz() -> Double {
        bazCallCount += 1
    
        if let bazHandler = bazHandler {
            return bazHandler()
        }
        return 0.0
    }
}

"""

let klassMock = """

public class LowMock: Low {
    override init(i: Int = 0) {
        super.init(i: i)
    }
    required init(arg: String = "") {
        super.init(arg: arg)
    }
    required init(orderId: Int = 0) {
        super.init(orderId: orderId)
    }


    private(set) var nameSetCallCount = 0
    override var name: String = "" { didSet { nameSetCallCount += 1 } }

    private(set) var whatSetCallCount = 0
    override var what: Float = 0.0 { didSet { whatSetCallCount += 1 } }

    private(set) var barCallCount = 0
    var barHandler: (() -> ())?
    override func bar()  {
        barCallCount += 1
        if let barHandler = barHandler {
            barHandler()
        }
        
    }

    private(set) var fooCallCount = 0
    var fooHandler: (() -> (Int))?
    override func foo() -> Int {
        fooCallCount += 1
        if let fooHandler = fooHandler {
            return fooHandler()
        }
        return 0
    }
}

"""

let klassLongerMock = """

public class LowMock: Low {
    override init(i: Int = 0) {
        super.init(i: i)
    }
    required init(arg: String = "") {
        super.init(arg: arg)
    }
    required init(orderId: Int = 0) {
        super.init(orderId: orderId)
    }


    private(set) var nameSetCallCount = 0
    override var name: String = "" { didSet { nameSetCallCount += 1 } }

    private(set) var whatSetCallCount = 0
    override var what: Float = 0.0 { didSet { whatSetCallCount += 1 } }

    private(set)  var barCallCount = 0
    var barHandler: (() -> ())?
    override func bar()  {
        barCallCount += 1
        if let barHandler = barHandler {
            barHandler()
        }
        
    }

    private(set) var fooCallCount = 0
    var fooHandler: (() -> (Int))?
    override func foo() -> Int {
        fooCallCount += 1
        if let fooHandler = fooHandler {
            return fooHandler()
        }
        return 0
    }
}

"""
