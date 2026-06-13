#if canImport(Testing)
import Testing
import SwiftSyntax
import SwiftSyntaxBuilder
@testable import MockoloFramework

@Suite struct ParseAttributeTests {
    @Test(arguments: [
        ("@available(macOS 10.15, *)", true),
        ("@available(iOS, introduced: 13.0)", true),
        ("@available(iOS, unavailable)", true),
        ("@available(iOS, deprecated: 14.0)", false),
        ("@available(iOS, obsoleted: 15.0)", true),
        ("@available(*, deprecated)", false),
        ("@available(*, noasync)", false),
        ("@available(*, message: \"foo\")", false),
    ])
    func isPlatformAvailability(input: String, expectedIsPlatform: Bool) throws {
        let decl = try ProtocolDeclSyntax("\(raw: input) protocol Foo {}")
        let parsed = decl.attributes.parsedAttributes

        let attribute = try #require(parsed.first)
        #expect(attribute.isPlatformAvailable == expectedIsPlatform)
    }

    @Test func multipleAttributes() throws {
        let decl = try ProtocolDeclSyntax("""
        @available(iOS 13.0, *) @available(*, deprecated)
        protocol Foo {}
        """)
        let parsed = decl.attributes.parsedAttributes

        try #require(parsed.count == 2)
        #expect(parsed[0].isPlatformAvailable)
        #expect(parsed[1].isBehavioralAvailable)
    }

    @Test func mixedArguments() throws {
        let decl = try ProtocolDeclSyntax("""
        @available(iOS, introduced: 13.0, deprecated: 14.0, message: \"Use something else\")
        protocol Foo {}
        """)
        let parsed = decl.attributes.parsedAttributes

        let attribute = try #require(parsed.first)
        #expect(attribute.isPlatformAvailable)
    }
}
#endif
