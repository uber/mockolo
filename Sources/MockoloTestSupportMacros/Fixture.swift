import SwiftBasicFormat
import SwiftSyntax
import SwiftSyntaxMacros

struct Fixture: MemberMacro {
    static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        let baseItems = declaration.memberBlock.members.filter { (item: MemberBlockItemSyntax) in
            if let decl = item.decl.asProtocol(WithAttributesSyntax.self) {
                let isFixtureAnnotated = decl.attributes.contains { (attr: AttributeListSyntax.Element) in
                    return attr.trimmedDescription == "@Fixture"
                }
                return !isFixtureAnnotated
            }
            return true
        }

        let indent = BasicFormat.inferIndentation(of: declaration) ?? .spaces(4)
        let sourceContent = baseItems.trimmedDescription(matching: \.isNewline)

        let varDecl = VariableDeclSyntax(
            modifiers: [.init(name: .keyword(.static))],
            .let,
            name: "_source",
            initializer: .init(
                value: StringLiteralExprSyntax(
                    multilineContent: sourceContent,
                    endIndent: Trivia(pieces: node.leadingTrivia.filter(\.isSpaceOrTab)) + indent
                )
            )
        )

        return [DeclSyntax(varDecl)]
    }
}

extension StringLiteralExprSyntax {
    fileprivate init(multilineContent: String, endIndent: Trivia) {
        self = StringLiteralExprSyntax(
            openingQuote: .multilineStringQuoteToken(),
            segments: [.stringSegment(.init(content: .stringSegment(multilineContent)))],
            closingQuote: .multilineStringQuoteToken(leadingTrivia: endIndent)
        )
    }
}
