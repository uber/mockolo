class TestableImportStatementsTests: MockoloTestCase {
    func testTestableImportStatements() {
        verify(srcContent: testableImports._source,
               dstContent: testableImports.expected._source,
               testableImports: ["SomeImport1", "SomeImport2"])
    }

    func testTestableImportStatementsWithOverlap() {
        verify(srcContent: testableImportsWithOverlap._source,
               dstContent: testableImportsWithOverlap.expected._source,
               testableImports: ["SomeImport1"])
    }
}
