import Foundation

class CombineTests: MockoloTestCase {

    func testCombine() {
        verify(srcContent: combineProtocol,
               dstContent: combineProtocolMock)
    }

    func testCombinePublished() {
        verify(srcContent: combinePublishedProtocol,
               dstContent: combinePublishedProtocolMock)
    }

    func testCombineNullable() {
        verify(srcContent: combineNullableProtocol,
               dstContent: combineNullableProtocolMock)
    }

    func testCombineMultiParents() {
        verify(srcContent: combineMultiParents,
               dstContent: combineMultiParentsMock)
    }

    func testCombineMockContent() {
        verify(srcContent: combineMockContentProtocol,
               mockContent: combineMockContentMock,
               dstContent: combineMockContentResult)
    }

    func testCombine_disableCombineDefaultValues() {
        verify(srcContent: combineProtocol,
               dstContent: combineDisabledProtocolMock,
               disableCombineDefaultValues: true
            )
    }

    func testCombine_currentValueSubject_defaultValue() {
        verify(
            srcContent: combineDefaultSubjectProtocol,
            dstContent: combineDefaultSubjectProtocolMock
        )
    }
}

