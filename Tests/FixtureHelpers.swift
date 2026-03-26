enum FixtureHelpers {

    static let someProtocol =
        """
        /// @mockable
        public protocol SomeProtocol: Parent {
            func run()
        }
        """
    
    static let someProtocolMock =
        """
        public class SomeProtocolMock: SomeProtocol {
            public init() { }


            public private(set) var runCallCount = 0
            public var runHandler: (() -> ())?
            public func run() {
                runCallCount += 1
                if let runHandler = runHandler {
                    runHandler()
                }
                
            }
        }
        """

    static let someProtocol2 =
        """
        /// @mockable
        public protocol SomeProtocol2: Parent {
            func run()
        }
        """
    
    static let someProtocol2Mock =
        """
        public class SomeProtocol2Mock: SomeProtocol2 {
            public init() { }


            public private(set) var runCallCount = 0
            public var runHandler: (() -> ())?
            public func run() {
                runCallCount += 1
                if let runHandler = runHandler {
                    runHandler()
                }
                
            }
        }
        """
}
