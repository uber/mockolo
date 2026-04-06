import Testing
@testable import MockoloFramework

@Test("Protocol inside #if block with non-import declaration")
func testProtocolInsideIfBlockWithNonImportDeclaration() {
    verify(srcContent: FixtureConditionalImportBlocks.protocolInIfBlock,
           dstContent: FixtureConditionalImportBlocks.protocolInIfBlockMock)
}

@Test("Conditional import block preserved")
func testConditionalImportBlockPreserved() {
    verify(srcContent: FixtureConditionalImportBlocks.conditionalImportBlock,
           dstContent: FixtureConditionalImportBlocks.conditionalImportBlockMock)
}

@Test("Nested #if blocks with multiple protocols")
func testNestedIfBlocksWithMultipleProtocols() {
    verify(srcContent: FixtureConditionalImportBlocks.nestedIfBlocks,
           dstContent: FixtureConditionalImportBlocks.nestedIfBlocksMock)
}

@Test("#if block with imports and protocol")
func testIfBlockWithImportsAndProtocol() {
    verify(srcContent: FixtureConditionalImportBlocks.ifBlockWithImportsAndProtocol,
           dstContent: FixtureConditionalImportBlocks.ifBlockWithImportsAndProtocolMock)
}

@Test("Mixed nested #if blocks")
func testMixedNestedBlocks() {
    verify(srcContent: FixtureConditionalImportBlocks.mixedNestedBlocks,
           dstContent: FixtureConditionalImportBlocks.mixedNestedBlocksMock)
}
