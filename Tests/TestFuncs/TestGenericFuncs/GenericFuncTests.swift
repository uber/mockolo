import Foundation

class GenericFuncTests: MockoloTestCase {

    func testOptionalGenerics() {
        verify(srcContent: genericOptionalType._source,
               dstContent: genericOptionalType.expected._source)
    }

    func testGenericFuncs() {
        verify(srcContent: genericFunc._source,
               dstContent: genericFunc.expected._source)
    }

    func testGenericClosure() {
        verify(srcContent: genericClosure._source,
               dstContent: genericClosure.expected._source)
    }

    func testGenericClosureNeedsEscaping() {
        verify(srcContent: genericClosureNeedsEscaping._source,
               dstContent: genericClosureNeedsEscaping.expected._source)
    }

    func testWhereClause() {
        verify(srcContent: funcWhereClause._source,
               dstContent: funcWhereClause.expected._source)
    }
    
    func testWhereClauseWithSameSignature() {
        verify(srcContent: funcDuplicateSignatureDifferentWhereClause._source,
               dstContent: funcDuplicateSignatureDifferentWhereClause.expected._source)
    }
    
    func testWhereClauseWithSameSignatureAndEqualityConstraints() {
        verify(srcContent: funcDuplicateSignatureDifferentWhereClauseEquality._source,
               dstContent: funcDuplicateSignatureDifferentWhereClauseEquality.expected._source)
    }
}


