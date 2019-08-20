import Foundation

class EmojiTests: MockoloTestCase {
   
    func testEmojis() {
        verify(srcContent: emojiVars,
               dstContent: emojiVarsMock)
    }

    func testEmojisExtract() {
        verify(srcContent: emojiVars,
               mockContent: emojiParentMock,
               dstContent: emojiCombMock)
    }
}
