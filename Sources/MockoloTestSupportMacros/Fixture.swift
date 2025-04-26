import SwiftBasicFormat
import SwiftSyntax
import SwiftSyntaxMacros

struct Fixture: MemberMacro {
    struct Arguments {
        var imports: [String]?
        var includesConcurrencyHelpers: Bool = false
    }

    static func extractArguments(from attribute: AttributeSyntax) throws -> Arguments {
        var result = Arguments()
        guard let arguments = attribute.arguments?.as(LabeledExprListSyntax.self) else {
            return result
        }
        for argument in arguments {
            if argument.label?.text == "includesConcurrencyHelpers",
                let literal = argument.expression.as(BooleanLiteralExprSyntax.self) {
                switch literal.literal.text {
                case "true": result.includesConcurrencyHelpers = true
                case "false": result.includesConcurrencyHelpers = false
                default: throw MessageError("Unexpected literal.")
                }
            }
            if argument.label?.text == "imports",
               let expr = argument.expression.as(ArrayExprSyntax.self) {
                result.imports = try expr.elements.map { element in
                    guard let literal = element.expression.as(StringLiteralExprSyntax.self) else {
                        throw MessageError("Must be string literal.")
                    }
                    guard literal.segments.count == 1 else {
                        throw MessageError("Cannot use string interpolation.")
                    }
                    return literal.segments.description
                }
            }
        }
        return result
    }

    static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        let argument = try extractArguments(from: node)

        let baseItems = declaration.memberBlock.members.filter { (item: MemberBlockItemSyntax) in
            if let decl = item.decl.asProtocol(WithAttributesSyntax.self) {
                let isFixtureAnnotated = decl.attributes.contains { (attr: AttributeListSyntax.Element) in
                    return attr.trimmedDescription == "@Fixture"
                }
                return !isFixtureAnnotated
            }
            return true
        }

        let baseIndent = Trivia(pieces: node.leadingTrivia.filter(\.isSpaceOrTab))
        let indent = BasicFormat.inferIndentation(of: declaration) ?? .spaces(4)
        var sourceContent = baseItems.trimmedDescription(matching: \.isNewline)

        if let imports = argument.imports {
            sourceContent = imports.map {
                "\(baseIndent)\(indent)import \($0)\n"
            }.joined() + "\n" + sourceContent
        }

        var _sourceInitExpr = StringLiteralExprSyntax(
            multilineContent: sourceContent,
            endIndent: baseIndent + indent
        )
        if argument.includesConcurrencyHelpers {
            _sourceInitExpr.segments.append(
                .expressionSegment(ExpressionSegmentSyntax(
                    pounds: .rawStringPoundDelimiter("##"),
                    expressions: [.init(
                        expression: #""\n\n" + concurrencyHelpers._generatedSource"# as ExprSyntax
                    )]
                ))
            )
        }

        return [DeclSyntax(VariableDeclSyntax(
            modifiers: [.init(name: .keyword(.static))],
            .let,
            name: "_source",
            initializer: InitializerClauseSyntax(
                value: _sourceInitExpr
            )
        ))]
    }
}

extension StringLiteralExprSyntax {
    fileprivate init(multilineContent: String, endIndent: Trivia) {
        self = StringLiteralExprSyntax(
            openingPounds: .rawStringPoundDelimiter("##"),
            openingQuote: .multilineStringQuoteToken(),
            segments: [.stringSegment(.init(content: .stringSegment(multilineContent)))],
            closingQuote: .multilineStringQuoteToken(leadingTrivia: endIndent),
            closingPounds: .rawStringPoundDelimiter("##")
        )
    }
}
