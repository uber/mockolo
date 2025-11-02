final class ACLImportTests: MockoloTestCase {
    func testSingle() {
        verify(srcContent: FixtureACLImport.primary,
               dstContent: FixtureACLImport.primaryMock)
    }
    
    func testSingleTestable() {
        verify(srcContent: FixtureACLImport.primary,
               dstContent: FixtureACLImport.primaryTestableMock,
               testableImports: ["B", "C", "D", "E", "F"])
    }
    
    func testMultiple() {
        verify(srcContents: [FixtureACLImport.primary, FixtureACLImport.secondary],
               dstContent: FixtureACLImport.primarySecondaryMock)
    }
}
