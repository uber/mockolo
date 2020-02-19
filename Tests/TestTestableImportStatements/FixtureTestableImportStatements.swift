import MockoloFramework

let testableImports = """
\(String.headerDoc)
import Foundation

/// \(String.mockAnnotation)
protocol SimpleVar {
    var name: Int { get set }
}
"""

let testableImportsMock =
"""

import Foundation
@testable import SomeImport1
@testable import SomeImport2


class SimpleVarMock: SimpleVar {
    
    private var _doneInit = false
    init() { _doneInit = true }
    init(name: Int = 0) {
        self.name = name
        _doneInit = true
    }
    
    var nameSetCallCount = 0
    var underlyingName: Int = 0
    var name: Int {
        get { return underlyingName }
        set {
            underlyingName = newValue
            if _doneInit { nameSetCallCount += 1 }
        }
    }
}
"""

let testableImportsWithOverlap = """
\(String.headerDoc)
import Foundation
import SomeImport1

/// \(String.mockAnnotation)
protocol SimpleVar {
    var name: Int { get set }
}
"""

let testableImportsWithOverlapMock =
"""

import Foundation
@testable import SomeImport1


class SimpleVarMock: SimpleVar {
    
    private var _doneInit = false
    init() { _doneInit = true }
    init(name: Int = 0) {
        self.name = name
        _doneInit = true
    }
    
    var nameSetCallCount = 0
    var underlyingName: Int = 0
    var name: Int {
        get { return underlyingName }
        set {
            underlyingName = newValue
            if _doneInit { nameSetCallCount += 1 }
        }
    }
}
"""
