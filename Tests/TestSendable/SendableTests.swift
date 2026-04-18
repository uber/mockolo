#if compiler(>=6.0)
class SendableTests: MockoloTestCase {
    func testSendableSubscript() {
        verify(srcContent: sendableSubscript._source,
               dstContent: sendableSubscript.expected._source)
    }

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

    func testAvailableSendableProtocol() {
        verify(srcContent: availableSendableProtocol._source,
               dstContent: availableSendableProtocol.expected._source)
    }

    func testAvailableInheritedProtocol() {
        verify(srcContent: availableInheritedProtocol._source,
               dstContent: availableInheritedProtocol.expected._source)
    }
}
#endif
