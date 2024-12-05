import SwiftSyntax
import SwiftSyntaxMacros

struct Fixture: PeerMacro {
    static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let name = extractDeclIdentifier(declaration: declaration) else {
            throw MacroExpansionErrorMessage("unsupported decl kind.")
        }

        let codeContent = declaration.description
            .replacingOccurrences(of: "@Fixture", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        return [
            DeclSyntax(try EnumDeclSyntax("enum \(name)_Fixture") {
                try VariableDeclSyntax("static var code: String") {
                    ReturnStmtSyntax(expression: StringLiteralExprSyntax(content: codeContent))
                }
            }),
        ]
    }
}

func extractDeclIdentifier(declaration: some DeclSyntaxProtocol) -> TokenSyntax? {
    if let decl = declaration.as(ClassDeclSyntax.self) {
        return decl.name
    }
    if let decl = declaration.as(StructDeclSyntax.self) {
        return decl.name
    }
    if let decl = declaration.as(ProtocolDeclSyntax.self) {
        return decl.name
    }
    if let decl = declaration.as(ActorDeclSyntax.self) {
        return decl.name
    }
    if let decl = declaration.as(EnumDeclSyntax.self) {
        return decl.name
    }
    return nil
}
