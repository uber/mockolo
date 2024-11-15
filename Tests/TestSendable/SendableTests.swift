class SendableTests: MockoloTestCase {
    func testSendableProtocol() {
        verify(srcContent: sendableProtocol,
               dstContent: sendableProtocolMock,
               enableFuncArgsHistory: true)
    }

    func testUncheckedSendableClass() {
        verify(srcContent: uncheckedSendableClass,
               dstContent: uncheckedSendableClassMock,
               declType: .classType)
    }

    func testConfirmingSendableProtocol() {
        verify(srcContent: confirmedSendableProtocol,
               dstContent: confirmedSendableProtocolMock)
    }
}
