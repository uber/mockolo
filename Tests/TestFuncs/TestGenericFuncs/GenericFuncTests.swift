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


