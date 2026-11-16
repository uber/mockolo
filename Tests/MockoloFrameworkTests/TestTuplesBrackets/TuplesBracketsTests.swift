import Foundation

class TuplesBracketsTests: MockoloTestCase {
    
    func testTuplesBrackets() {
        verify(srcContent: tuplesBrackets,
               dstContent: tuplesBracketsMock)
    }
}
