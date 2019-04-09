import SwiftMockGenCore

let tuplesBrackets = """

/// \(String.mockAnnotation)
protocol NonSimpleTypes {
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
}
"""


let tuplesBracketsMock = """
class NonSimpleTypesMock: NonSimpleTypes {
    
    init() {
        
    }
    
    var updateCallCount = 0
    var updateHandler: (() -> ([String: Int]))?
    func update() -> [String: Int] {
        updateCallCount += 1
        if let updateHandler = updateHandler {
            return updateHandler()
        }
        return [String: Int]()
    }
    var updateDictionaryStringIntCallCount = 0
    var updateDictionaryStringIntHandler: (() -> (Dictionary<String, Int>))?
    func update() -> Dictionary<String, Int> {
        updateDictionaryStringIntCallCount += 1
        if let updateDictionaryStringIntHandler = updateDictionaryStringIntHandler {
            return updateDictionaryStringIntHandler()
        }
        return Dictionary<String, Int>()
    }
    var updateObservableDoubleFloatCallCount = 0
    var updateObservableDoubleFloatHandler: (() -> (Observable<Double, Float>))?
    func update() -> Observable<Double, Float> {
        updateObservableDoubleFloatCallCount += 1
        if let updateObservableDoubleFloatHandler = updateObservableDoubleFloatHandler {
            return updateObservableDoubleFloatHandler()
        }
        return Observable.empty()
    }
    var updateStringCallCount = 0
    var updateStringHandler: (() -> ([String]))?
    func update() -> [String] {
        updateStringCallCount += 1
        if let updateStringHandler = updateStringHandler {
            return updateStringHandler()
        }
        return [String]()
    }
    var updateStringArrayIntCallCount = 0
    var updateStringArrayIntHandler: (() -> ([String: Array<Int>]))?
    func update() -> [String: Array<Int>] {
        updateStringArrayIntCallCount += 1
        if let updateStringArrayIntHandler = updateStringArrayIntHandler {
            return updateStringArrayIntHandler()
        }
        return [String: Array<Int>]()
    }
    var updateStringDictionaryIntDoubleCallCount = 0
    var updateStringDictionaryIntDoubleHandler: (() -> ([String: Dictionary<Int, Double>]))?
    func update() -> [String: Dictionary<Int, Double>] {
        updateStringDictionaryIntDoubleCallCount += 1
        if let updateStringDictionaryIntDoubleHandler = updateStringDictionaryIntDoubleHandler {
            return updateStringDictionaryIntDoubleHandler()
        }
        return [String: Dictionary<Int, Double>]()
    }
    var updateStringIntArrayStringCallCount = 0
    var updateStringIntArrayStringHandler: (() -> ([[String]], [Int], Array<[String]>))?
    func update() -> ([[String]], [Int], Array<[String]>) {
        updateStringIntArrayStringCallCount += 1
        if let updateStringIntArrayStringHandler = updateStringIntArrayStringHandler {
            return updateStringIntArrayStringHandler()
        }
        return ( [[String]](), [Int](), Array<[String]>())
    }
    var updateArrayStringIntCallCount = 0
    var updateArrayStringIntHandler: (() -> (Array<[String: Int]>))?
    func update() -> Array<[String: Int]> {
        updateArrayStringIntCallCount += 1
        if let updateArrayStringIntHandler = updateArrayStringIntHandler {
            return updateArrayStringIntHandler()
        }
        return Array<[String: Int]>()
    }
    var updateArrayDictionaryStringIntCallCount = 0
    var updateArrayDictionaryStringIntHandler: (() -> (Array<Dictionary<String, Int>>))?
    func update() -> Array<Dictionary<String, Int>> {
        updateArrayDictionaryStringIntCallCount += 1
        if let updateArrayDictionaryStringIntHandler = updateArrayDictionaryStringIntHandler {
            return updateArrayDictionaryStringIntHandler()
        }
        return Array<Dictionary<String, Int>>()
    }
    var updateArrayStringArrayIntCallCount = 0
    var updateArrayStringArrayIntHandler: (() -> (Array<String>, Array<Int>))?
    func update() -> (Array<String>, Array<Int>) {
        updateArrayStringArrayIntCallCount += 1
        if let updateArrayStringArrayIntHandler = updateArrayStringArrayIntHandler {
            return updateArrayStringArrayIntHandler()
        }
        return ( Array<String>(), Array<Int>())
    }
    var updateArrayStringCallCount = 0
    var updateArrayStringHandler: (() -> (Array<String>))?
    func update() -> Array<String> {
        updateArrayStringCallCount += 1
        if let updateArrayStringHandler = updateArrayStringHandler {
            return updateArrayStringHandler()
        }
        return Array<String>()
    }
    var updateResultDoubleStatusBoolCallCount = 0
    var updateResultDoubleStatusBoolHandler: (() -> (result: Double?, status: Bool))?
    func update() -> (result: Double?, status: Bool) {
        updateResultDoubleStatusBoolCallCount += 1
        if let updateResultDoubleStatusBoolHandler = updateResultDoubleStatusBoolHandler {
            return updateResultDoubleStatusBoolHandler()
        }
        return ( nil, false)
    }
    var updateIntDictionaryIntStringCallCount = 0
    var updateIntDictionaryIntStringHandler: (() -> (Int, Dictionary<Int, String>))?
    func update() -> (Int, Dictionary<Int, String>) {
        updateIntDictionaryIntStringCallCount += 1
        if let updateIntDictionaryIntStringHandler = updateIntDictionaryIntStringHandler {
            return updateIntDictionaryIntStringHandler()
        }
        return ( 0, Dictionary<Int, String>())
    }
    var updateDoubleIntFloatStringIntDoubleIntCallCount = 0
    var updateDoubleIntFloatStringIntDoubleIntHandler: (() -> ((Double, Int, (Float, (String, Int, Double), Int), Float, (Int, String), Array<String>)))?
    func update() -> (Double, Int, (Float, (String, Int, Double), Int), Float, (Int, String), Array<String>) {
        updateDoubleIntFloatStringIntDoubleIntCallCount += 1
        if let updateDoubleIntFloatStringIntDoubleIntHandler = updateDoubleIntFloatStringIntDoubleIntHandler {
            return updateDoubleIntFloatStringIntDoubleIntHandler()
        }
        return ( 0.0, 0, ( 0.0, ( "", 0, 0.0), 0), 0.0, ( 0, ""), Array<String>())
    }
    var updateArgCallCount = 0
    var updateArgHandler: ((Int, Float) -> (Dictionary<String, Float>))?
    func update(arg: Int, some: Float) -> Dictionary<String, Float> {
        updateArgCallCount += 1
        if let updateArgHandler = updateArgHandler {
            return updateArgHandler(arg, some)
        }
        return Dictionary<String, Float>()
    }
    var updateArgSomeCallCount = 0
    var updateArgSomeHandler: ((Int, Float) -> (Observable<Int>))?
    func update(arg: Int, some: Float) -> Observable<Int> {
        updateArgSomeCallCount += 1
        if let updateArgSomeHandler = updateArgSomeHandler {
            return updateArgSomeHandler(arg, some)
        }
        return Observable.empty()
    }
    var updateArgSomeIntCallCount = 0
    var updateArgSomeIntHandler: ((Int, Float) -> ((String) -> Observable<Double>))?
    func update(arg: Int, some: Float) -> (String) -> Observable<Double> {
        updateArgSomeIntCallCount += 1
        if let updateArgSomeIntHandler = updateArgSomeIntHandler {
            return updateArgSomeIntHandler(arg, some)
        }
        fatalError("updateArgSomeIntHandler returns can't have a default value thus its handler must be set")
    }
}
"""
