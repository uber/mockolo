import XCTest
@testable import MockoloFramework

final class ConditionalImportBlocksTests: MockoloTestCase {
    func testProtocolInsideIfBlockWithNonImportDeclaration() {
        verify(srcContent: FixtureConditionalImportBlocks.protocolInIfBlock,
               dstContent: FixtureConditionalImportBlocks.protocolInIfBlockMock)
    }
    func testConditionalImportBlockPreserved() {
        verify(srcContent: FixtureConditionalImportBlocks.conditionalImportBlock,
               dstContent: FixtureConditionalImportBlocks.conditionalImportBlockMock)
    }
    func testNestedIfBlocksWithMultipleProtocols() {
        verify(srcContent: FixtureConditionalImportBlocks.nestedIfBlocks,
               dstContent: FixtureConditionalImportBlocks.nestedIfBlocksMock)
    }
    func testIfBlockWithImportsAndProtocol() {
        verify(srcContent: FixtureConditionalImportBlocks.ifBlockWithImportsAndProtocol,
               dstContent: FixtureConditionalImportBlocks.ifBlockWithImportsAndProtocolMock)
    }
    func testMixedNestedBlocks() {
        verify(srcContent: FixtureConditionalImportBlocks.mixedNestedBlocks,
               dstContent: FixtureConditionalImportBlocks.mixedNestedBlocksMock)
    }
}
