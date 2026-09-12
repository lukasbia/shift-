import Foundation

struct VariableDeclaration: ASTNode {
    let isMutable: Bool
    let name: Identifier
    let type: TypeSyntax?
    let initializer: Expression?
    let location: SourceLocation
}

struct FunctionDeclaration: ASTNode {
    let name: Identifier
    let parameters: [FunctionParameter]
    let returnType: TypeSyntax?
    let body: CodeBlock
    let modifiers: [DeclarationModifier]
    let location: SourceLocation
}

struct FunctionParameter: ASTNode {
    let externalLabel: String?
    let name: Identifier
    let type: TypeSyntax
    let location: SourceLocation
}

struct StructDeclaration: ASTNode {
    let name: Identifier
    let members: [Declaration]
    let location: SourceLocation
}

struct ClassDeclaration: ASTNode {
    let name: Identifier
    let members: [Declaration]
    let location: SourceLocation
}

struct EnumDeclaration: ASTNode {
    let name: Identifier
    let cases: [EnumCase]
    let location: SourceLocation
}

struct EnumCase: ASTNode {
    let name: Identifier
    let associatedValues: [TypeSyntax]
    let location: SourceLocation
}

struct ProtocolDeclaration: ASTNode {
    let name: Identifier
    let members: [Declaration]
    let location: SourceLocation
}

struct ExtensionDeclaration: ASTNode {
    let extendedType: TypeSyntax
    let members: [Declaration]
    let location: SourceLocation
}

enum DeclarationModifier {
    case `public`
    case `private`
    case `internal`
    case `static`
    case `mutating`
    case `unsafe`
}