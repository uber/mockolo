import MockoloFramework

@Fixture enum simpleFuncs {
    /// @mockable
    public protocol SimpleFunc {
        func update(arg: Int) -> String
    }

    @Fixture enum expected {
        public class SimpleFuncMock: SimpleFunc {
            public init() { }


            public private(set) var updateCallCount = 0
            public var updateHandler: ((Int) -> String)?
            public func update(arg: Int) -> String {
                updateCallCount += 1
                if let updateHandler = updateHandler {
                    return updateHandler(arg)
                }
                return ""
            }
        }
    }

    @Fixture enum allowCallCountExpected {
        public class SimpleFuncMock: SimpleFunc {
            public init() { }


            public var updateCallCount = 0
            public var updateHandler: ((Int) -> String)?
            public func update(arg: Int) -> String {
                updateCallCount += 1
                if let updateHandler = updateHandler {
                    return updateHandler(arg)
                }
                return ""
            }
        }
    }

    @Fixture enum mockFuncExpected {
        public class SimpleFuncMock: SimpleFunc {
            public init() { }


            public private(set) var updateCallCount = 0
            public var updateHandler: ((Int) -> String)?
            public func update(arg: Int) -> String {
                mockFunc(&updateCallCount)("update", updateHandler?(arg), .val(""))
            }
        }
    }
}


