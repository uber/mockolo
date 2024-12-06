import MockoloFramework

let testableImports = """
\(String.headerDoc)
import Foundation

/// @mockable
protocol SimpleVar {
    var name: Int { get set }
}
"""

let testableImportsMock = """
import Foundation
@testable import SomeImport1
@testable import SomeImport2

class SimpleVarMock: SimpleVar {
    init() { }
    init(name: Int = 0) {
        self.name = name
    }


    private(set) var nameSetCallCount = 0
    var name: Int = 0 { didSet { nameSetCallCount += 1 } }
}
"""

let testableImportsWithOverlap = """
\(String.headerDoc)
import Foundation
import SomeImport1

/// @mockable
protocol SimpleVar {
    var name: Int { get set }
}
"""

let testableImportsWithOverlapMock = """
import Foundation
@testable import SomeImport1

class SimpleVarMock: SimpleVar {
    init() { }
    init(name: Int = 0) {
        self.name = name
    }

    private(set) var nameSetCallCount = 0
    var name: Int = 0 { didSet { nameSetCallCount += 1 } }
}
"""
