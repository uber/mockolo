import MockoloFramework


let klassParent =
"""

public class High {
     init(orderId: Int) {
        self.order = orderId
    }
     init(orderId: Int, loc: String) {
        self.order = orderId
    }
    var order: Int
    func baz() -> Double { return 5.6 }
}

"""

let klass =
"""
protocol Level {
    var name: String { get set }
    func foo() -> Int
    init(arg: String)
}

public class Mid: High {
    var what: Float = 0.0
    func bar() {}
}

/// \(String.mockAnnotation)
public class Low: Mid {

    var name: String = "k2"

    required init(arg: String) {
        super.init(orderId: 1)
        self.name = arg
    }
    
    init(i: Int) {
        super.init(orderId: i)
    }

    init(d: Double) {
        super.init(orderId: 9, loc: "")
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
}

"""


let klassParentMock =
"""
public class HighMock: High {
    private var _doneInit = false

    override init(orderId: Int) {
        super.init(orderId: orderId)
        _doneInit = true
    }

    override init(orderId: Int, loc: String) {
        super.init(orderId: orderId, loc: m)
        _doneInit = true
    }

    var orderSetCallCount = 0
    var underlyingOrder: Int = 0
    override var order: Int {
        get { return underlyingOrder }
        set {
            underlyingOrder = newValue
            if _doneInit { orderSetCallCount += 1 }
        }
    }

    var bazCallCount = 0
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

let klassMock =
"""
    public class LowMock: Low {

        private var _doneInit = false
            
        
            
        public var nameSetCallCount = 0
        var underlyingName: String = ""
        public override var name: String {
            get { return underlyingName }
            set {
                underlyingName = newValue
                if _doneInit { nameSetCallCount += 1 }
            }
        }
        required public init(arg: String) {
        super.init(arg: arg)
            _doneInit = true
        }
        override public init(i: Int) {
        super.init(i: i)
            _doneInit = true
        }
        override public init(d: Double) {
        super.init(d: d)
            _doneInit = true
        }
        
        public var whatSetCallCount = 0
        var underlyingWhat: Float = 0.0
        public override var what: Float {
            get { return underlyingWhat }
            set {
                underlyingWhat = newValue
                if _doneInit { whatSetCallCount += 1 }
            }
        }
        public var barCallCount = 0
        public var barHandler: (() -> ())?
        public override func bar()  {
            barCallCount += 1

            if let barHandler = barHandler {
                barHandler()
            }
            
        }
        public var fooCallCount = 0
        public var fooHandler: (() -> (Int))?
        public override func foo() -> Int {
            fooCallCount += 1

            if let fooHandler = fooHandler {
                return fooHandler()
            }
            return 0
        }
    }


"""



let klassLongerMock =
"""
    public class LowMock: Low {

        private var _doneInit = false
            
        
            
        public var nameSetCallCount = 0
        var underlyingName: String = ""
        public override var name: String {
            get { return underlyingName }
            set {
                underlyingName = newValue
                if _doneInit { nameSetCallCount += 1 }
            }
        }
        required public init(arg: String) {
        super.init(arg: arg)
            _doneInit = true
        }
        override public init(i: Int) {
        super.init(i: i)
            _doneInit = true
        }


        var orderSetCallCount = 0

        var underlyingOrder: Int = 0
        override public init(d: Double) {
        super.init(d: d)
            _doneInit = true
        }

        override var order: Int {
            get { return underlyingOrder }
            set {
                underlyingOrder = newValue
                if _doneInit { orderSetCallCount += 1 }
            }
        }
        
        public var whatSetCallCount = 0
        var underlyingWhat: Float = 0.0
        public override var what: Float {
            get { return underlyingWhat }
            set {
                underlyingWhat = newValue
                if _doneInit { whatSetCallCount += 1 }
            }
        }
        public var barCallCount = 0
        public var barHandler: (() -> ())?
        public override func bar()  {
            barCallCount += 1

            if let barHandler = barHandler {
                barHandler()
            }
            
        }


        var bazCallCount = 0
        public var fooCallCount = 0
        public var fooHandler: (() -> (Int))?
        public override func foo() -> Int {
            fooCallCount += 1

            if let fooHandler = fooHandler {
                return fooHandler()
            }
            return 0
        }

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
