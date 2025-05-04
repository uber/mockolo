#if compiler(>=6.0)
class SendableTests: MockoloTestCase {
    func testSendableProtocol() {
        verify(srcContent: sendableProtocol._source,
               dstContent: sendableProtocol.expected._source,
               enableFuncArgsHistory: true)
    }

    func testUncheckedSendableClass() {
        verify(srcContent: uncheckedSendableClass._source,
               dstContent: uncheckedSendableClass.expected._source,
               declType: .classType)
    }

    func testConfirmingSendableProtocol() {
        verify(srcContent: confirmedSendableProtocol._source,
               dstContent: confirmedSendableProtocol.expected._source)
    }
}
#endif
