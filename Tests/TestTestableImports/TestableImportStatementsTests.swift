import Foundation

class TestableImportStatementsTests: MockoloTestCase {
    
    func testTesableImportStatements() {
        verify(srcContent: testableImports,
               dstContent: testableImportsMock,
               testableImports: ["SomeImport1", "SomeImport2"])
    }

    func testTesableImportStatementsWithOverlap() {
        verify(srcContent: testableImportsWithOverlap,
               dstContent: testableImportsWithOverlapMock,
               testableImports: ["SomeImport1"])
    }
}
