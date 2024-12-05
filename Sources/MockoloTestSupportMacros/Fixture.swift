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
            .replacing("@Fixture", with: "", maxReplacements: 1)
            .trimmingCharacters(in: .whitespacesAndNewlines)

        let varDecl = VariableDeclSyntax(
            .let,
            name: "\(name)_rawSyntax",
            type: TypeAnnotationSyntax(type: "String" as TypeSyntax),
            initializer: .init(value: StringLiteralExprSyntax(content: codeContent))
        )

        return [
            DeclSyntax(varDecl),
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
