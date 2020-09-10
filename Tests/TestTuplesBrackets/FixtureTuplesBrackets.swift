import MockoloFramework

let tuplesBrackets = """

/// \(String.mockAnnotation)
protocol NonSimpleTypes {
func variadicFunc(_ arg: Int, for key: String)
func variadicFunc(_ arg: Int, for key: String...)
func update() -> (state: State?, other: SomeEnum)
func update() -> Observable<(ItemType, ())>
func update() -> Observable<(ItemType, ())>?
func update() -> Observable<[SomeKey: SomeType]>
func update() -> [String: Int]
func update() -> Dictionary<String, Int>
func update() -> Observable<Double, Float>
func update() -> [String]
func update() -> [[String]]
func update() -> [String: Array<Int>]
func update() -> [String: Dictionary<Int, Double>]
func update() -> ([[String]], [Int], Array<[String]>)
func update() -> Array<[String: Int]>
func update() -> Array<Dictionary<String, Int>>
func update() -> (Array<String>, Array<Int>)
func update() -> Array<String>
func update() -> (result: Double?, status: Bool)
func update() -> (Int, Dictionary<Int, String>)
func update() -> (Double, Int, (Float, (String, Int, Double), Int), Float, (Int, String), Array<String>)
func update(arg: Int, some: Float) -> Dictionary<String, Float>
func update(arg: Int, some: Float) -> Observable<Int>
func update(arg: Int, some: Float) -> (String) -> Observable<Double>
func update() -> (Dictionary<A, (Array<(T, U)>, B)>, Int)
}
"""


let tuplesBracketsMock = """


class NonSimpleTypesMock: NonSimpleTypes {
    init() { }


    private(set) var variadicFuncCallCount = 0
    var variadicFuncHandler: ((Int, String) -> ())?
    func variadicFunc(_ arg: Int, for key: String)  {
        variadicFuncCallCount += 1
        if let variadicFuncHandler = variadicFuncHandler {
            variadicFuncHandler(arg, key)
        }
        
    }

    private(set) var updateCallCount = 0
    var updateHandler: (() -> (state: State?, other: SomeEnum))?
    func update() -> (state: State?, other: SomeEnum) {
        updateCallCount += 1
        if let updateHandler = updateHandler {
            return updateHandler()
        }
        fatalError("updateHandler returns can't have a default value thus its handler must be set")
    }

    private(set) var updateObservableItemTypeCallCount = 0
    var updateObservableItemTypeHandler: (() -> (Observable<(ItemType, ())>))?
    func update() -> Observable<(ItemType, ())> {
        updateObservableItemTypeCallCount += 1
        if let updateObservableItemTypeHandler = updateObservableItemTypeHandler {
            return updateObservableItemTypeHandler()
        }
        return Observable<(ItemType, ())>.empty()
    }

    private(set) var updateObservableItemTypeOptionalCallCount = 0
    var updateObservableItemTypeOptionalHandler: (() -> (Observable<(ItemType, ())>?))?
    func update() -> Observable<(ItemType, ())>? {
        updateObservableItemTypeOptionalCallCount += 1
        if let updateObservableItemTypeOptionalHandler = updateObservableItemTypeOptionalHandler {
            return updateObservableItemTypeOptionalHandler()
        }
        return Observable<(ItemType, ())>.empty()
    }

    private(set) var updateObservableSomeKeySomeTypeCallCount = 0
    var updateObservableSomeKeySomeTypeHandler: (() -> (Observable<[SomeKey: SomeType]>))?
    func update() -> Observable<[SomeKey: SomeType]> {
        updateObservableSomeKeySomeTypeCallCount += 1
        if let updateObservableSomeKeySomeTypeHandler = updateObservableSomeKeySomeTypeHandler {
            return updateObservableSomeKeySomeTypeHandler()
        }
        return Observable<[SomeKey: SomeType]>.empty()
    }

    private(set) var updateStringIntCallCount = 0
    var updateStringIntHandler: (() -> ([String: Int]))?
    func update() -> [String: Int] {
        updateStringIntCallCount += 1
        if let updateStringIntHandler = updateStringIntHandler {
            return updateStringIntHandler()
        }
        return [String: Int]()
    }

    private(set) var updateDictionaryStringIntCallCount = 0
    var updateDictionaryStringIntHandler: (() -> (Dictionary<String, Int>))?
    func update() -> Dictionary<String, Int> {
        updateDictionaryStringIntCallCount += 1
        if let updateDictionaryStringIntHandler = updateDictionaryStringIntHandler {
            return updateDictionaryStringIntHandler()
        }
        return Dictionary<String, Int>()
    }

    private(set) var updateObservableDoubleFloatCallCount = 0
    var updateObservableDoubleFloatHandler: (() -> (Observable<Double, Float>))?
    func update() -> Observable<Double, Float> {
        updateObservableDoubleFloatCallCount += 1
        if let updateObservableDoubleFloatHandler = updateObservableDoubleFloatHandler {
            return updateObservableDoubleFloatHandler()
        }
        return Observable<Double, Float>.empty()
    }

    private(set) var updateStringCallCount = 0
    var updateStringHandler: (() -> ([String]))?
    func update() -> [String] {
        updateStringCallCount += 1
        if let updateStringHandler = updateStringHandler {
            return updateStringHandler()
        }
        return [String]()
    }

    private(set) var updateStringArrayIntCallCount = 0
    var updateStringArrayIntHandler: (() -> ([String: Array<Int>]))?
    func update() -> [String: Array<Int>] {
        updateStringArrayIntCallCount += 1
        if let updateStringArrayIntHandler = updateStringArrayIntHandler {
            return updateStringArrayIntHandler()
        }
        fatalError("updateStringArrayIntHandler returns can't have a default value thus its handler must be set")
    }

    private(set) var updateStringDictionaryIntDoubleCallCount = 0
    var updateStringDictionaryIntDoubleHandler: (() -> ([String: Dictionary<Int, Double>]))?
    func update() -> [String: Dictionary<Int, Double>] {
        updateStringDictionaryIntDoubleCallCount += 1
        if let updateStringDictionaryIntDoubleHandler = updateStringDictionaryIntDoubleHandler {
            return updateStringDictionaryIntDoubleHandler()
        }
        fatalError("updateStringDictionaryIntDoubleHandler returns can't have a default value thus its handler must be set")
    }

    private(set) var updateStringIntArrayStringCallCount = 0
    var updateStringIntArrayStringHandler: (() -> ([[String]], [Int], Array<[String]>))?
    func update() -> ([[String]], [Int], Array<[String]>) {
        updateStringIntArrayStringCallCount += 1
        if let updateStringIntArrayStringHandler = updateStringIntArrayStringHandler {
            return updateStringIntArrayStringHandler()
        }
        return ([[String]](), [Int](), Array<[String]>())
    }

    private(set) var updateArrayStringIntCallCount = 0
    var updateArrayStringIntHandler: (() -> (Array<[String: Int]>))?
    func update() -> Array<[String: Int]> {
        updateArrayStringIntCallCount += 1
        if let updateArrayStringIntHandler = updateArrayStringIntHandler {
            return updateArrayStringIntHandler()
        }
        return Array<[String: Int]>()
    }

    private(set) var updateArrayDictionaryStringIntCallCount = 0
    var updateArrayDictionaryStringIntHandler: (() -> (Array<Dictionary<String, Int>>))?
    func update() -> Array<Dictionary<String, Int>> {
        updateArrayDictionaryStringIntCallCount += 1
        if let updateArrayDictionaryStringIntHandler = updateArrayDictionaryStringIntHandler {
            return updateArrayDictionaryStringIntHandler()
        }
        return Array<Dictionary<String, Int>>()
    }

    private(set) var updateArrayStringArrayIntCallCount = 0
    var updateArrayStringArrayIntHandler: (() -> (Array<String>, Array<Int>))?
    func update() -> (Array<String>, Array<Int>) {
        updateArrayStringArrayIntCallCount += 1
        if let updateArrayStringArrayIntHandler = updateArrayStringArrayIntHandler {
            return updateArrayStringArrayIntHandler()
        }
        return (Array<String>(), Array<Int>())
    }

    private(set) var updateArrayStringCallCount = 0
    var updateArrayStringHandler: (() -> (Array<String>))?
    func update() -> Array<String> {
        updateArrayStringCallCount += 1
        if let updateArrayStringHandler = updateArrayStringHandler {
            return updateArrayStringHandler()
        }
        return Array<String>()
    }

    private(set) var updateResultDoubleOptionalStatusBoolCallCount = 0
    var updateResultDoubleOptionalStatusBoolHandler: (() -> (result: Double?, status: Bool))?
    func update() -> (result: Double?, status: Bool) {
        updateResultDoubleOptionalStatusBoolCallCount += 1
        if let updateResultDoubleOptionalStatusBoolHandler = updateResultDoubleOptionalStatusBoolHandler {
            return updateResultDoubleOptionalStatusBoolHandler()
        }
        return (nil, false)
    }

    private(set) var updateIntDictionaryIntStringCallCount = 0
    var updateIntDictionaryIntStringHandler: (() -> (Int, Dictionary<Int, String>))?
    func update() -> (Int, Dictionary<Int, String>) {
        updateIntDictionaryIntStringCallCount += 1
        if let updateIntDictionaryIntStringHandler = updateIntDictionaryIntStringHandler {
            return updateIntDictionaryIntStringHandler()
        }
        return (0, Dictionary<Int, String>())
    }

    private(set) var updateDoubleIntFloatStringIntDoubleIntCallCount = 0
    var updateDoubleIntFloatStringIntDoubleIntHandler: (() -> ((Double, Int, (Float, (String, Int, Double), Int), Float, (Int, String), Array<String>)))?
    func update() -> (Double, Int, (Float, (String, Int, Double), Int), Float, (Int, String), Array<String>) {
        updateDoubleIntFloatStringIntDoubleIntCallCount += 1
        if let updateDoubleIntFloatStringIntDoubleIntHandler = updateDoubleIntFloatStringIntDoubleIntHandler {
            return updateDoubleIntFloatStringIntDoubleIntHandler()
        }
        return (0.0, 0, (0.0, ("", 0, 0.0), 0), 0.0, (0, ""), Array<String>())
    }

    private(set) var updateArgCallCount = 0
    var updateArgHandler: ((Int, Float) -> (Dictionary<String, Float>))?
    func update(arg: Int, some: Float) -> Dictionary<String, Float> {
        updateArgCallCount += 1
        if let updateArgHandler = updateArgHandler {
            return updateArgHandler(arg, some)
        }
        return Dictionary<String, Float>()
    }

    private(set) var updateArgSomeCallCount = 0
    var updateArgSomeHandler: ((Int, Float) -> (Observable<Int>))?
    func update(arg: Int, some: Float) -> Observable<Int> {
        updateArgSomeCallCount += 1
        if let updateArgSomeHandler = updateArgSomeHandler {
            return updateArgSomeHandler(arg, some)
        }
        return Observable<Int>.empty()
    }

    private(set) var updateArgSomeIntCallCount = 0
    var updateArgSomeIntHandler: ((Int, Float) -> ((String) -> Observable<Double>))?
    func update(arg: Int, some: Float) -> (String) -> Observable<Double> {
        updateArgSomeIntCallCount += 1
        if let updateArgSomeIntHandler = updateArgSomeIntHandler {
            return updateArgSomeIntHandler(arg, some)
        }
        fatalError("updateArgSomeIntHandler returns can't have a default value thus its handler must be set")
    }

    private(set) var updateDictionaryAArrayTUBIntCallCount = 0
    var updateDictionaryAArrayTUBIntHandler: (() -> ((Dictionary<A, (Array<(T, U)>, B)>, Int)))?
    func update() -> (Dictionary<A, (Array<(T, U)>, B)>, Int) {
        updateDictionaryAArrayTUBIntCallCount += 1
        if let updateDictionaryAArrayTUBIntHandler = updateDictionaryAArrayTUBIntHandler {
            return updateDictionaryAArrayTUBIntHandler()
        }
        return (Dictionary<A, (Array<(T, U)>, B)>(), 0)
    }
}


"""
