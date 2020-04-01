import MockoloFramework

let overload1 = """
import AVFoundation

/// \(String.mockAnnotation)
protocol P1: P0 {
}
"""

let overloadParent1 = """
import Foundation
import CoreLocation

public class P0Mock: P0 {
    
    init() {
        
    }
    var updateCallCount = 0
    var updateHandler: (([String], Bool, @escaping () -> ()) -> ())?
    func update(arg: [String], once: Bool, closure: @escaping () -> ())  {
        updateCallCount += 1
        if let updateHandler = updateHandler {
            return updateHandler(arg, once, closure)
        }
        
    }
    var updateArgCallCount = 0
    var updateArgHandler: (([String], Any, Bool, Any) -> ())?
    func update<T>(arg: [String], value: T, once: Bool, closure: @escaping (T) -> ())  {
        updateArgCallCount += 1
        if let updateArgHandler = updateArgHandler {
            return updateArgHandler(arg, value, once, closure)
        }
        
    }
}
"""

let overloadMock1 =
"""
import AVFoundation
import CoreLocation
import Foundation

class P1Mock: P1 {
    
    
    
    init() {        
        
    }
    var updateCallCount = 0
    var updateHandler: (([String], Bool, @escaping () -> ()) -> ())?
    func update(arg: [String], once: Bool, closure: @escaping () -> ())  {
        updateCallCount += 1
        if let updateHandler = updateHandler {
            return updateHandler(arg, once, closure)
        }
        
    }
    var updateArgCallCount = 0
    var updateArgHandler: (([String], Any, Bool, Any) -> ())?
    func update<T>(arg: [String], value: T, once: Bool, closure: @escaping (T) -> ())  {
        updateArgCallCount += 1
        if let updateArgHandler = updateArgHandler {
            return updateArgHandler(arg, value, once, closure)
        }
        
    }
}
"""
