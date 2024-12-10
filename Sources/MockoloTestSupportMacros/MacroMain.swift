import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main struct MacroMain: CompilerPlugin {
    let providingMacros: [any Macro.Type] = [
        Fixture.self,
    ]
}
