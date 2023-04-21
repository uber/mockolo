import Foundation

class TestableImportStatementsTests: MockoloTestCase {
    
    func testTestableImportStatements() {
        verify(srcContent: testableImports,
               dstContent: testableImportsMock,
               testableImports: ["SomeImport1", "SomeImport2"])
    }

    func testTestableImportStatementsWithOverlap() {
        verify(srcContent: testableImportsWithOverlap,
               dstContent: testableImportsWithOverlapMock,
               testableImports: ["SomeImport1"])
    }
}
