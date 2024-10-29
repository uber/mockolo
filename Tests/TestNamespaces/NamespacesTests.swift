class NamespacesTests: MockoloTestCase {
    func testModuleOverride() {
        verify(srcContent: moduleOverride,
               dstContent: moduleOverrideMock)
    }

    func testNestedProtocol() {
        verify(srcContent: nestedProtocol,
               dstContent: nestedProtocolMock)
    }
}
