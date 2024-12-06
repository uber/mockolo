import SwiftBasicFormat
import SwiftSyntax
import SwiftSyntaxMacros

struct FixtureExpression: ExpressionMacro {
    static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> ExprSyntax {
        guard let trailingClosure = node.trailingClosure else {
            throw MacroExpansionErrorMessage("Please use trailing closure here.")
        }

        guard let (sourceStmts, returnStmt) = splitReturnStmt(statements: trailingClosure.statements) else {
            throw MacroExpansionErrorMessage("Please write `return { ... }`")
        }

        let indent = BasicFormat.inferIndentation(of: node) ?? .spaces(4)

        let sourceContent = sourceStmts
            .trimmed(matching: \.isNewline)
            .description

        let expectedContent = returnStmt.expression?.as(ClosureExprSyntax.self)?
            .statements
            .trimmed(matching: \.isNewline)
            .description ?? ""

        return ExprSyntax(
            FunctionCallExprSyntax(callee: "FixtureContent" as ExprSyntax) {
                LabeledExprSyntax(
                    label: "source",
                    expression: StringLiteralExprSyntax(multilineContent: sourceContent, indent: indent)
                )
                LabeledExprSyntax(
                    label: "expected",
                    expression: StringLiteralExprSyntax(multilineContent: expectedContent, indent: indent + indent)
                )
            }
        )
    }
}

extension StringLiteralExprSyntax {
    fileprivate init(multilineContent: String, indent: Trivia) {
        self = StringLiteralExprSyntax(
            openingQuote: .multilineStringQuoteToken(),
            segments: [.stringSegment(.init(content: .stringSegment(multilineContent)))],
            closingQuote: .multilineStringQuoteToken(leadingTrivia: indent, trailingTrivia: .newline)
        )
    }
}

private func splitReturnStmt(statements: CodeBlockItemListSyntax) -> (CodeBlockItemListSyntax, ReturnStmtSyntax)? {
    var found: ReturnStmtSyntax?
    let filtered = statements.filter { (item: CodeBlockItemSyntax) in
        if let returnStmt = item.item.as(ReturnStmtSyntax.self) {
            found = returnStmt
            return false
        }
        return true
    }
    guard let found else {
        return nil
    }
    return (filtered, found)
}
